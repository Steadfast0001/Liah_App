import { serveWebhook } from "../_shared/handler.ts";
import { json, errorResponse } from "../_shared/response.ts";

/**
 * Validates HMAC SHA-256 signature for incoming provider webhooks
 */
async function verifyWebhookSignature(
  rawBody: string,
  signatureHeader: string | null,
  secretKey: string
): Promise<boolean> {
  if (!signatureHeader || !secretKey) return false;

  try {
    const encoder = new TextEncoder();
    const key = await crypto.subtle.importKey(
      "raw",
      encoder.encode(secretKey),
      { name: "HMAC", hash: "SHA-256" },
      false,
      ["verify"]
    );

    const cleanSig = signatureHeader.replace(/^sha256=/, "");
    const sigBytes = new Uint8Array(
      cleanSig.match(/.{1,2}/g)?.map((byte) => parseInt(byte, 16)) || []
    );

    return await crypto.subtle.verify(
      "HMAC",
      key,
      sigBytes,
      encoder.encode(rawBody)
    );
  } catch (err) {
    console.error("[Orange Webhook] Signature verification error:", err);
    return false;
  }
}

/**
 * Scrubs passwords, PINs, tokens, CVVs, or card credentials from logs
 */
function sanitizeLogPayload(data: Record<string, unknown>): Record<string, unknown> {
  const sanitized = { ...data };
  const sensitiveKeys = ["pin", "password", "token", "secret", "cvv", "card_number", "pan"];
  for (const k of sensitiveKeys) {
    if (k in sanitized) {
      sanitized[k] = "[REDACTED]";
    }
  }
  return sanitized;
}

serveWebhook("payment-webhook-orange", async (req, { service }) => {
  const signature = req.headers.get("x-orange-signature") || req.headers.get("x-signature");
  const secretKey = Deno.env.get("ORANGE_WEBHOOK_SECRET") || "liah_orange_webhook_secret_production";

  const rawBody = await req.text();
  let payload: Record<string, unknown>;

  try {
    payload = JSON.parse(rawBody);
  } catch {
    return errorResponse("invalid_json_payload", 400);
  }

  // 1. Verify webhook signature if present in production
  if (Deno.env.get("ENVIRONMENT") === "production") {
    const isValid = await verifyWebhookSignature(rawBody, signature, secretKey);
    if (!isValid) {
      console.warn("[Orange Webhook] Unauthorized: Invalid signature");
      return errorResponse("invalid_signature", 401);
    }
  }

  // Safe logging: Never log sensitive credentials
  console.log("[Orange Webhook] Received sanitized payload:", sanitizeLogPayload(payload));

  const eventId = String(payload.notif_token || payload.txnid || payload.order_id || crypto.randomUUID());
  const externalRef = String(payload.order_id || payload.reference || "");
  const statusStr = String(payload.status || "SUCCESS").toUpperCase();
  const paymentStatus = statusStr === "SUCCESS" || statusStr === "SUCCESSFUL" ? "verified" : "failed";
  const amountXaf = Number(payload.amount || 0);

  // 2. Execute Idempotent Processing via Database Function
  const { data: result, error: rpcError } = await service.rpc(
    "process_idempotent_payment_webhook",
    {
      p_provider: "om_orange",
      p_event_id: eventId,
      p_transaction_ref: externalRef,
      p_amount_xaf: amountXaf,
      p_status: paymentStatus,
      p_payload: sanitizeLogPayload(payload),
    }
  );

  if (rpcError) {
    console.error("[Orange Webhook] Database processing error:", rpcError);
    return errorResponse("database_error", 500);
  }

  return json({
    received: true,
    provider: "om_orange",
    idempotent: result?.idempotent ?? false,
    status: result?.status ?? "processed",
  }, 200);
});
