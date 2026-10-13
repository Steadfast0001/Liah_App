-- Permission checks for Edge Functions (service role) by explicit user id

CREATE OR REPLACE FUNCTION public.user_has_permission(
  p_user_id UUID,
  p_permission_code TEXT
)
RETURNS BOOLEAN
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
  SELECT EXISTS (
    SELECT 1
    FROM public.profile_roles pr
    JOIN public.role_permissions rp ON rp.role_id = pr.role_id
    JOIN public.permissions p ON p.id = rp.permission_id
    WHERE pr.profile_id = p_user_id
      AND p.code = p_permission_code
  );
$$;

REVOKE ALL ON FUNCTION public.user_has_permission(UUID, TEXT) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.user_has_permission(UUID, TEXT) TO service_role;
