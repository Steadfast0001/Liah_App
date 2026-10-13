-- Auth -> Profile mapping trigger, matricule generator, and academic table RLS policies

-- ---------------------------------------------------------------------------
-- 1. Auth -> Profile automatic mapping
-- ---------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_full_name TEXT;
  v_phone TEXT;
  v_role_code TEXT;
  v_role_id UUID;
BEGIN
  v_full_name := COALESCE(
    NULLIF(TRIM(NEW.raw_user_meta_data->>'full_name'), ''),
    SPLIT_PART(NEW.email, '@', 1)
  );
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
      VALUES (NEW.id, v_role_id)
      ON CONFLICT DO NOTHING;
    END IF;
  END IF;

  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- ---------------------------------------------------------------------------
-- 2. Student matricule generator helper
-- ---------------------------------------------------------------------------

CREATE SEQUENCE IF NOT EXISTS public.student_matricule_seq START WITH 1 INCREMENT BY 1;

CREATE OR REPLACE FUNCTION public.generate_student_matricule(
  p_program_code TEXT,
  p_intake_year INT DEFAULT EXTRACT(YEAR FROM CURRENT_DATE)::INT
)
RETURNS TEXT
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_seq BIGINT;
  v_clean_code TEXT;
BEGIN
  v_seq := nextval('public.student_matricule_seq');
  v_clean_code := UPPER(REGEXP_REPLACE(COALESCE(p_program_code, 'GEN'), '[^A-Za-z0-9]', '', 'g'));
  RETURN format('LA-%s-%s-%s', p_intake_year, v_clean_code, LPAD(v_seq::TEXT, 4, '0'));
END;
$$;

REVOKE ALL ON FUNCTION public.generate_student_matricule(TEXT, INT) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.generate_student_matricule(TEXT, INT) TO service_role;

-- ---------------------------------------------------------------------------
-- 3. Complete RLS policies for roles & basic academic tables
-- ---------------------------------------------------------------------------

-- Allow all authenticated users to read role definitions so they can resolve their own profile_roles
DROP POLICY IF EXISTS roles_select ON public.roles;
CREATE POLICY roles_select ON public.roles
  FOR SELECT TO authenticated
  USING (TRUE);

-- Missing SELECT policies on academic reference tables
CREATE POLICY academic_years_select ON public.academic_years
  FOR SELECT TO authenticated
  USING (TRUE);

CREATE POLICY cohorts_select ON public.cohorts
  FOR SELECT TO authenticated
  USING (TRUE);

CREATE POLICY course_prerequisites_select ON public.course_prerequisites
  FOR SELECT TO authenticated
  USING (TRUE);

-- Student enrollments: student owner or staff with students.read
CREATE POLICY student_enrollments_select ON public.student_enrollments
  FOR SELECT TO authenticated
  USING (
    public.is_student_owner(student_id)
    OR public.has_permission('students.read')
  );

-- Staff & assignments read policies
CREATE POLICY staff_select ON public.staff
  FOR SELECT TO authenticated
  USING (
    profile_id = auth.uid()
    OR public.has_permission('academics.manage')
    OR public.has_permission('students.read')
    OR public.has_role('super_admin')
  );

CREATE POLICY staff_assignments_select ON public.staff_assignments
  FOR SELECT TO authenticated
  USING (TRUE);

-- Academic management write policies (admin / super_admin with academics.manage)
CREATE POLICY departments_write ON public.departments
  FOR ALL TO authenticated
  USING (public.has_permission('academics.manage') OR public.has_role('super_admin'))
  WITH CHECK (public.has_permission('academics.manage') OR public.has_role('super_admin'));

CREATE POLICY programs_write ON public.programs
  FOR ALL TO authenticated
  USING (public.has_permission('academics.manage') OR public.has_role('super_admin'))
  WITH CHECK (public.has_permission('academics.manage') OR public.has_role('super_admin'));

CREATE POLICY academic_years_write ON public.academic_years
  FOR ALL TO authenticated
  USING (public.has_permission('academics.manage') OR public.has_role('super_admin'))
  WITH CHECK (public.has_permission('academics.manage') OR public.has_role('super_admin'));

CREATE POLICY semesters_write ON public.semesters
  FOR ALL TO authenticated
  USING (public.has_permission('academics.manage') OR public.has_role('super_admin'))
  WITH CHECK (public.has_permission('academics.manage') OR public.has_role('super_admin'));

CREATE POLICY cohorts_write ON public.cohorts
  FOR ALL TO authenticated
  USING (public.has_permission('academics.manage') OR public.has_role('super_admin'))
  WITH CHECK (public.has_permission('academics.manage') OR public.has_role('super_admin'));

CREATE POLICY courses_write ON public.courses
  FOR ALL TO authenticated
  USING (public.has_permission('academics.manage') OR public.has_role('super_admin'))
  WITH CHECK (public.has_permission('academics.manage') OR public.has_role('super_admin'));

CREATE POLICY course_offerings_write ON public.course_offerings
  FOR ALL TO authenticated
  USING (public.has_permission('academics.manage') OR public.has_role('super_admin'))
  WITH CHECK (public.has_permission('academics.manage') OR public.has_role('super_admin'));

GRANT INSERT, UPDATE, DELETE ON
  public.profiles,
  public.notifications,
  public.departments,
  public.programs,
  public.academic_years,
  public.semesters,
  public.cohorts,
  public.courses,
  public.course_offerings
TO authenticated;

-- Ensure 'admin' role also has 'users.manage' for creating student accounts
INSERT INTO public.role_permissions (role_id, permission_id)
SELECT r.id, p.id
FROM public.roles r
JOIN public.permissions p ON p.code = 'users.manage'
WHERE r.code = 'admin'
ON CONFLICT DO NOTHING;

