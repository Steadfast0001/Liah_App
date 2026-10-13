import { handleCors } from "./cors.ts";
import { createServiceClient, createUserClient } from "./supabase.ts";
import { requireUser } from "./auth.ts";
import { errorResponse, json } from "./response.ts";

export type EdgeHandler = (
  req: Request,
  ctx: {
    userId: string;
    service: ReturnType<typeof createServiceClient>;
    userClient: ReturnType<typeof createUserClient>;
  },
) => Promise<Response>;

export function serveProtected(
  name: string,
  handler: EdgeHandler,
): void {
  Deno.serve(async (req) => {
    const cors = handleCors(req);
    if (cors) return cors;

    if (req.method !== "POST") {
      return errorResponse("method_not_allowed", 405);
    }

    const authHeader = req.headers.get("Authorization");
    if (!authHeader?.startsWith("Bearer ")) {
      return errorResponse("missing_authorization", 401);
    }

    const userClient = createUserClient(authHeader);
    const userResult = await requireUser(userClient);
    if (userResult instanceof Response) return userResult;

    const service = createServiceClient();

    try {
      return await handler(req, {
        userId: userResult.id,
        service,
        userClient,
      });
    } catch (e) {
      console.error(`[${name}]`, e);
      return errorResponse("internal_error", 500);
    }
  });
}

export function serveWebhook(name: string, handler: EdgeHandler): void {
  Deno.serve(async (req) => {
    const cors = handleCors(req);
    if (cors) return cors;

    const service = createServiceClient();
    const userClient = createUserClient("Bearer invalid");

    try {
      return await handler(req, {
        userId: "",
        service,
        userClient,
      });
    } catch (e) {
      console.error(`[${name}]`, e);
      return errorResponse("internal_error", 500);
    }
  });
}

/** Placeholder until business logic is implemented */
export function notImplemented(feature: string): Response {
  return json({ status: "not_implemented", feature }, 501);
}
