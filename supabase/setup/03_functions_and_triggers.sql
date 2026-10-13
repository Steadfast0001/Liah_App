-- =============================================================================
-- STEP 3: Functions, Triggers & Auth Helpers
-- Run this third in Supabase SQL Editor:
-- https://supabase.com/dashboard/project/nqdlptrodovwbtqabxyu/sql/new
-- =============================================================================

-- Automatic profile creation on auth.users insert
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $func$
DECLARE
  v_full_name TEXT;
  v_phone TEXT;
  v_role_code TEXT;
  v_role_id UUID;
BEGIN
  v_full_name := COALESCE(NULLIF(TRIM(NEW.raw_user_meta_data->>'full_name'), ''), SPLIT_PART(NEW.email, '@', 1));
  v_phone := NULLIF(TRIM(NEW.raw_user_meta_data->>'phone'), '');
  v_role_code := NULLIF(TRIM(NEW.raw_user_meta_data->>'role'), '');

  INSERT INTO public.profiles (id, email, full_name, phone, is_active)
  VALUES (NEW.id, NEW.email, v_full_name, v_phone, TRUE)
  ON CONFLICT (id) DO UPDATE
    SET email = EXCLUDED.email,
        full_name = COALESCE(NULLIF(EXCLUDED.full_name, ''), public.profiles.full_name),
        phone = COALESCE(EXCLUDED.phone, public.profiles.phone),
        updated_at = NOW();

  IF v_role_code IS NOT NULL THEN
    SELECT id INTO v_role_id FROM public.roles WHERE code = v_role_code LIMIT 1;
    IF v_role_id IS NOT NULL THEN
      INSERT INTO public.profile_roles (profile_id, role_id)
      VALUES (NEW.id, v_role_id) ON CONFLICT DO NOTHING;
    END IF;
  END IF;

  RETURN NEW;
END;
$func$;

DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- Role & Permission checking helpers
CREATE OR REPLACE FUNCTION public.has_role(role_code TEXT)
RETURNS BOOLEAN
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public
AS $func$
  SELECT EXISTS (
    SELECT 1 FROM public.profile_roles pr
    JOIN public.roles r ON r.id = pr.role_id
    WHERE pr.profile_id = auth.uid() AND r.code = role_code
  );
$func$;

CREATE OR REPLACE FUNCTION public.has_permission(permission_code TEXT)
RETURNS BOOLEAN
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public
AS $func$
  SELECT EXISTS (
    SELECT 1 FROM public.profile_roles pr
    JOIN public.role_permissions rp ON rp.role_id = pr.role_id
    JOIN public.permissions p ON p.id = rp.permission_id
    WHERE pr.profile_id = auth.uid() AND p.code = permission_code
  );
$func$;

CREATE OR REPLACE FUNCTION public.is_student_owner(student_row_id UUID)
RETURNS BOOLEAN
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public
AS $func$
  SELECT EXISTS (
    SELECT 1 FROM public.students s
    WHERE s.id = student_row_id AND s.profile_id = auth.uid()
  );
$func$;

CREATE OR REPLACE FUNCTION public.user_has_permission(p_user_id UUID, p_permission_code TEXT)
RETURNS BOOLEAN
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public
AS $func$
  SELECT EXISTS (
    SELECT 1 FROM public.profile_roles pr
    JOIN public.role_permissions rp ON rp.role_id = pr.role_id
    JOIN public.permissions p ON p.id = rp.permission_id
    WHERE pr.profile_id = p_user_id AND p.code = p_permission_code
  );
$func$;

-- Sequential Matricule Generator
CREATE SEQUENCE IF NOT EXISTS public.student_matricule_seq START WITH 1 INCREMENT BY 1;

CREATE OR REPLACE FUNCTION public.generate_student_matricule(
  p_program_code TEXT,
  p_intake_year INT DEFAULT EXTRACT(YEAR FROM CURRENT_DATE)::INT
)
RETURNS TEXT
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $func$
DECLARE
  v_seq BIGINT;
  v_clean_code TEXT;
BEGIN
  v_seq := nextval('public.student_matricule_seq');
  v_clean_code := UPPER(REGEXP_REPLACE(COALESCE(p_program_code, 'GEN'), '[^A-Za-z0-9]', '', 'g'));
  RETURN format('LA-%s-%s-%s', p_intake_year, v_clean_code, LPAD(v_seq::TEXT, 4, '0'));
END;
$func$;

GRANT EXECUTE ON FUNCTION public.user_has_permission(UUID, TEXT) TO service_role;
GRANT EXECUTE ON FUNCTION public.generate_student_matricule(TEXT, INT) TO service_role;
