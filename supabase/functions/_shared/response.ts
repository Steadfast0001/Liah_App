import { corsHeaders } from "./cors.ts";

export function json(
  body: unknown,
  status = 200,
): Response {
  return new Response(JSON.stringify(body), {
    status,
    headers: { ...corsHeaders, "Content-Type": "application/json" },
  });
}

export function errorResponse(
  message: string,
  status = 400,
  code?: string,
): Response {
  return json({ error: message, code }, status);
}
