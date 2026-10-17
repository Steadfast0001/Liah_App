-- =============================================================================
-- STEP 5: Database RPC for Student Account Creation (Direct Backend Fallback)
-- Run this in Supabase SQL Editor:
-- https://supabase.com/dashboard/project/nqdlptrodovwbtqabxyu/sql/new
-- =============================================================================

CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- 1. Ensure students permissions & RLS policies allow authorized creation
DROP POLICY IF EXISTS students_insert ON public.students;
CREATE POLICY students_insert ON public.students FOR INSERT TO authenticated
  WITH CHECK (public.has_permission('students.write') OR public.has_role('admin') OR public.has_role('super_admin'));

DROP POLICY IF EXISTS students_update ON public.students;
CREATE POLICY students_update ON public.students FOR UPDATE TO authenticated
  USING (public.has_permission('students.write') OR public.has_role('admin') OR public.has_role('super_admin'))
  WITH CHECK (public.has_permission('students.write') OR public.has_role('admin') OR public.has_role('super_admin'));

-- 2. Stored Procedure for privileged student creation directly in database
CREATE OR REPLACE FUNCTION public.admin_create_student(
  p_email TEXT,
  p_full_name TEXT,
  p_program_id UUID,
  p_cohort_id UUID DEFAULT NULL,
  p_phone TEXT DEFAULT NULL,
  p_password TEXT DEFAULT NULL
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, auth, extensions
AS $$
DECLARE
  v_caller_id UUID;
  v_user_id UUID;
  v_role_id UUID;
  v_program_code TEXT;
  v_intake_year INT;
  v_matricule TEXT;
  v_student_id UUID;
  v_current_semester_id UUID;
  v_temp_password TEXT;
  v_has_provider_id BOOLEAN;
  v_has_sso BOOLEAN;
  v_has_anon BOOLEAN;
BEGIN
  -- 1. Authorization check: Super Admin, Admin, or users with students.write / users.manage permission
  v_caller_id := auth.uid();
  IF v_caller_id IS NOT NULL THEN
    IF NOT (
      public.has_role('super_admin') OR 
      public.has_role('admin') OR 
      public.has_permission('students.write') OR 
      public.has_permission('users.manage')
    ) THEN
      RAISE EXCEPTION 'Permission denied: Insufficient privileges to create student accounts.';
    END IF;
  END IF;

  -- 2. Validate input parameters
  IF p_email IS NULL OR p_email NOT LIKE '%@%' THEN
    RAISE EXCEPTION 'A valid email address is required.';
  END IF;
  IF p_full_name IS NULL OR TRIM(p_full_name) = '' THEN
    RAISE EXCEPTION 'Full name is required.';
  END IF;
  IF p_program_id IS NULL THEN
    RAISE EXCEPTION 'Program ID is required.';
  END IF;

  -- 3. Validate program
  SELECT code INTO v_program_code FROM public.programs WHERE id = p_program_id;
  IF v_program_code IS NULL THEN
    RAISE EXCEPTION 'Selected program does not exist.';
  END IF;

  -- 4. Resolve intake year from cohort or current year
  v_intake_year := EXTRACT(YEAR FROM CURRENT_DATE)::INT;
  IF p_cohort_id IS NOT NULL THEN
    SELECT intake_year INTO v_intake_year FROM public.cohorts WHERE id = p_cohort_id;
    IF v_intake_year IS NULL THEN
      v_intake_year := EXTRACT(YEAR FROM CURRENT_DATE)::INT;
    END IF;
  END IF;

  -- 5. Password resolution
  v_temp_password := COALESCE(NULLIF(TRIM(p_password), ''), 'Liah@' || SUBSTRING(gen_random_uuid()::TEXT, 1, 8));

  -- 6. Check columns
  SELECT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_schema = 'auth' AND table_name = 'identities' AND column_name = 'provider_id'
  ) INTO v_has_provider_id;

  SELECT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_schema = 'auth' AND table_name = 'users' AND column_name = 'is_sso_user'
  ) INTO v_has_sso;

  SELECT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_schema = 'auth' AND table_name = 'users' AND column_name = 'is_anonymous'
  ) INTO v_has_anon;

  -- 7. Find or Create Auth User
  SELECT id INTO v_user_id FROM auth.users WHERE LOWER(email) = LOWER(p_email);

  IF v_user_id IS NULL THEN
    v_user_id := gen_random_uuid();
    INSERT INTO auth.users (
      instance_id,
      id,
      aud,
      role,
      email,
      encrypted_password,
      email_confirmed_at,
      raw_app_meta_data,
      raw_user_meta_data,
      created_at,
      updated_at,
      confirmation_token,
      recovery_token,
      email_change_token_new,
      email_change
    ) VALUES (
      '00000000-0000-0000-0000-000000000000',
      v_user_id,
      'authenticated',
      'authenticated',
      LOWER(p_email),
      crypt(v_temp_password, gen_salt('bf')),
      NOW(),
      '{"provider":"email","providers":["email"]}'::jsonb,
      jsonb_build_object('full_name', p_full_name, 'role', 'student', 'phone', p_phone),
      NOW(),
      NOW(),
      '',
      '',
      '',
      ''
    );
  ELSE
    UPDATE auth.users SET
      encrypted_password = crypt(v_temp_password, gen_salt('bf')),
      email_confirmed_at = NOW(),
      aud = 'authenticated',
      role = 'authenticated',
      raw_app_meta_data = '{"provider":"email","providers":["email"]}'::jsonb,
      raw_user_meta_data = jsonb_build_object('full_name', p_full_name, 'role', 'student', 'phone', p_phone),
      updated_at = NOW()
    WHERE id = v_user_id;
  END IF;

  IF v_has_sso THEN
    EXECUTE format('UPDATE auth.users SET is_sso_user = FALSE WHERE id = %L', v_user_id);
  END IF;
  IF v_has_anon THEN
    EXECUTE format('UPDATE auth.users SET is_anonymous = FALSE WHERE id = %L', v_user_id);
  END IF;

  -- 8. Sync auth.identities
  BEGIN
    IF v_has_provider_id THEN
      IF EXISTS (SELECT 1 FROM auth.identities WHERE user_id = v_user_id AND provider = 'email') THEN
        UPDATE auth.identities SET
          identity_data = jsonb_build_object('sub', v_user_id::text, 'email', LOWER(p_email)),
          provider_id = v_user_id::text,
          last_sign_in_at = NOW(),
          updated_at = NOW()
        WHERE user_id = v_user_id AND provider = 'email';
      ELSE
        INSERT INTO auth.identities (
          id, user_id, identity_data, provider, provider_id, last_sign_in_at, created_at, updated_at
        ) VALUES (
          v_user_id::text, v_user_id, jsonb_build_object('sub', v_user_id::text, 'email', LOWER(p_email)), 'email', v_user_id::text, NOW(), NOW(), NOW()
        );
      END IF;
    ELSE
      IF EXISTS (SELECT 1 FROM auth.identities WHERE user_id = v_user_id AND provider = 'email') THEN
        UPDATE auth.identities SET
          identity_data = jsonb_build_object('sub', v_user_id::text, 'email', LOWER(p_email)),
          last_sign_in_at = NOW(),
          updated_at = NOW()
        WHERE user_id = v_user_id AND provider = 'email';
      ELSE
        INSERT INTO auth.identities (
          id, user_id, identity_data, provider, last_sign_in_at, created_at, updated_at
        ) VALUES (
          v_user_id::text, v_user_id, jsonb_build_object('sub', v_user_id::text, 'email', LOWER(p_email)), 'email', NOW(), NOW(), NOW()
        );
      END IF;
    END IF;
  EXCEPTION WHEN OTHERS THEN
    NULL;
  END;

  -- 9. Upsert Profile
  INSERT INTO public.profiles (id, email, full_name, phone, is_active)
  VALUES (v_user_id, LOWER(p_email), p_full_name, p_phone, TRUE)
  ON CONFLICT (id) DO UPDATE SET
    email = EXCLUDED.email,
    full_name = EXCLUDED.full_name,
    phone = COALESCE(EXCLUDED.phone, public.profiles.phone),
    is_active = TRUE,
    updated_at = NOW();

  -- 10. Link student role
  SELECT id INTO v_role_id FROM public.roles WHERE code = 'student' LIMIT 1;
  IF v_role_id IS NOT NULL THEN
    INSERT INTO public.profile_roles (profile_id, role_id, assigned_by)
    VALUES (v_user_id, v_role_id, v_caller_id)
    ON CONFLICT DO NOTHING;
  END IF;

  -- 11. Generate matricule
  v_matricule := public.generate_student_matricule(v_program_code, v_intake_year);

  -- 12. Insert or update student record
  SELECT id INTO v_student_id FROM public.students WHERE profile_id = v_user_id;

  IF v_student_id IS NULL THEN
    INSERT INTO public.students (
      profile_id,
      matricule,
      program_id,
      cohort_id,
      status,
      admission_date
    ) VALUES (
      v_user_id,
      v_matricule,
      p_program_id,
      p_cohort_id,
      'active',
      CURRENT_DATE
    )
    RETURNING id INTO v_student_id;
  ELSE
    UPDATE public.students SET
      program_id = p_program_id,
      cohort_id = COALESCE(p_cohort_id, public.students.cohort_id),
      status = 'active',
      updated_at = NOW()
    WHERE id = v_student_id;
    SELECT matricule INTO v_matricule FROM public.students WHERE id = v_student_id;
  END IF;

  -- 13. Enroll into current semester if one exists
  SELECT id INTO v_current_semester_id FROM public.semesters WHERE is_current = TRUE LIMIT 1;
  IF v_current_semester_id IS NOT NULL THEN
    INSERT INTO public.student_enrollments (student_id, semester_id, enrollment_status)
    VALUES (v_student_id, v_current_semester_id, 'enrolled')
    ON CONFLICT DO NOTHING;
  END IF;

  -- 14. Audit log entry
  INSERT INTO public.audit_logs (actor_profile_id, action, entity_type, entity_id, details)
  VALUES (
    v_caller_id,
    'student.created',
    'students',
    v_student_id,
    jsonb_build_object(
      'matricule', v_matricule,
      'email', LOWER(p_email),
      'program_id', p_program_id,
      'cohort_id', p_cohort_id
    )
  );

  RETURN jsonb_build_object(
    'student_id', v_student_id,
    'matricule', v_matricule,
    'profile_id', v_user_id,
    'temporary_password', v_temp_password
  );
END;
$$;

GRANT EXECUTE ON FUNCTION public.admin_create_student TO authenticated, service_role;
