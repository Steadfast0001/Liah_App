import { SupabaseClient, User } from "https://esm.sh/@supabase/supabase-js@2.49.1";

export async function requireUser(
  client: SupabaseClient,
): Promise<User | Response> {
  const { data, error } = await client.auth.getUser();
  if (error || !data.user) {
    return new Response(JSON.stringify({ error: "unauthorized" }), {
      status: 401,
      headers: { "Content-Type": "application/json" },
    });
  }
  return data.user;
}

export async function requirePermission(
  service: SupabaseClient,
  userId: string,
  permissionCode: string,
): Promise<boolean> {
  const { data, error } = await service.rpc("user_has_permission", {
    p_user_id: userId,
    p_permission_code: permissionCode,
  });
  if (error) {
    console.error("user_has_permission rpc failed", error);
    return false;
  }
  return data === true;
}
