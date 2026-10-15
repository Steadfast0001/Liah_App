-- =============================================================================
-- Create Demo Users: Student, Lecturer, Admin & Super Admin
-- Run in Supabase SQL Editor:
-- https://supabase.com/dashboard/project/nqdlptrodovwbtqabxyu/sql/new
-- =============================================================================

CREATE EXTENSION IF NOT EXISTS pgcrypto;

DO $$
DECLARE
  v_student_role_id UUID;
  v_lecturer_role_id UUID;
  v_admin_role_id UUID;
  v_super_admin_role_id UUID;
  v_user_id UUID;
BEGIN
  -- 1. Fetch Role IDs from public.roles
  SELECT id INTO v_student_role_id FROM public.roles WHERE code = 'student';
  SELECT id INTO v_lecturer_role_id FROM public.roles WHERE code = 'lecturer';
  SELECT id INTO v_admin_role_id FROM public.roles WHERE code = 'admin';
  SELECT id INTO v_super_admin_role_id FROM public.roles WHERE code = 'super_admin';

  -- ===========================================================================
  -- 2. STUDENT: student@liah.com / password123
  -- ===========================================================================
  SELECT id INTO v_user_id FROM auth.users WHERE email = 'student@liah.com';
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
      recovery_token
    ) VALUES (
      '00000000-0000-0000-0000-000000000000',
      v_user_id,
      'authenticated',
      'authenticated',
      'student@liah.com',
      crypt('password123', gen_salt('bf')),
      NOW(),
      '{"provider":"email","providers":["email"]}',
      '{"full_name":"Demo Student","role":"student"}',
      NOW(),
      NOW(),
      '',
      ''
    );
  ELSE
    UPDATE auth.users SET
      encrypted_password = crypt('password123', gen_salt('bf')),
      email_confirmed_at = NOW(),
      raw_user_meta_data = '{"full_name":"Demo Student","role":"student"}',
      updated_at = NOW()
    WHERE id = v_user_id;
  END IF;

  INSERT INTO public.profiles (id, email, full_name, is_active)
  VALUES (v_user_id, 'student@liah.com', 'Demo Student', TRUE)
  ON CONFLICT (id) DO UPDATE SET full_name = 'Demo Student', is_active = TRUE;

  IF v_student_role_id IS NOT NULL THEN
    INSERT INTO public.profile_roles (profile_id, role_id)
    VALUES (v_user_id, v_student_role_id)
    ON CONFLICT DO NOTHING;
  END IF;

  -- ===========================================================================
  -- 3. LECTURER: lecturer@liah.com / password123
  -- ===========================================================================
  SELECT id INTO v_user_id FROM auth.users WHERE email = 'lecturer@liah.com';
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
      recovery_token
    ) VALUES (
      '00000000-0000-0000-0000-000000000000',
      v_user_id,
      'authenticated',
      'authenticated',
      'lecturer@liah.com',
      crypt('password123', gen_salt('bf')),
      NOW(),
      '{"provider":"email","providers":["email"]}',
      '{"full_name":"Demo Lecturer","role":"lecturer"}',
      NOW(),
      NOW(),
      '',
      ''
    );
  ELSE
    UPDATE auth.users SET
      encrypted_password = crypt('password123', gen_salt('bf')),
      email_confirmed_at = NOW(),
      raw_user_meta_data = '{"full_name":"Demo Lecturer","role":"lecturer"}',
      updated_at = NOW()
    WHERE id = v_user_id;
  END IF;

  INSERT INTO public.profiles (id, email, full_name, is_active)
  VALUES (v_user_id, 'lecturer@liah.com', 'Demo Lecturer', TRUE)
  ON CONFLICT (id) DO UPDATE SET full_name = 'Demo Lecturer', is_active = TRUE;

  IF v_lecturer_role_id IS NOT NULL THEN
    INSERT INTO public.profile_roles (profile_id, role_id)
    VALUES (v_user_id, v_lecturer_role_id)
    ON CONFLICT DO NOTHING;
  END IF;

  -- ===========================================================================
  -- 4. ADMIN: admin@liah.com / password123
  -- ===========================================================================
  SELECT id INTO v_user_id FROM auth.users WHERE email = 'admin@liah.com';
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
      recovery_token
    ) VALUES (
      '00000000-0000-0000-0000-000000000000',
      v_user_id,
      'authenticated',
      'authenticated',
      'admin@liah.com',
      crypt('password123', gen_salt('bf')),
      NOW(),
      '{"provider":"email","providers":["email"]}',
      '{"full_name":"Demo Admin","role":"admin"}',
      NOW(),
      NOW(),
      '',
      ''
    );
  ELSE
    UPDATE auth.users SET
      encrypted_password = crypt('password123', gen_salt('bf')),
      email_confirmed_at = NOW(),
      raw_user_meta_data = '{"full_name":"Demo Admin","role":"admin"}',
      updated_at = NOW()
    WHERE id = v_user_id;
  END IF;

  INSERT INTO public.profiles (id, email, full_name, is_active)
  VALUES (v_user_id, 'admin@liah.com', 'Demo Admin', TRUE)
  ON CONFLICT (id) DO UPDATE SET full_name = 'Demo Admin', is_active = TRUE;

  IF v_admin_role_id IS NOT NULL THEN
    INSERT INTO public.profile_roles (profile_id, role_id)
    VALUES (v_user_id, v_admin_role_id)
    ON CONFLICT DO NOTHING;
  END IF;

  -- ===========================================================================
  -- 5. SUPER ADMIN: superadmin@liah.com / password123
  -- ===========================================================================
  SELECT id INTO v_user_id FROM auth.users WHERE email = 'superadmin@liah.com';
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
      recovery_token
    ) VALUES (
      '00000000-0000-0000-0000-000000000000',
      v_user_id,
      'authenticated',
      'authenticated',
      'superadmin@liah.com',
      crypt('password123', gen_salt('bf')),
      NOW(),
      '{"provider":"email","providers":["email"]}',
      '{"full_name":"Demo Super Admin","role":"super_admin"}',
      NOW(),
      NOW(),
      '',
      ''
    );
  ELSE
    UPDATE auth.users SET
      encrypted_password = crypt('password123', gen_salt('bf')),
      email_confirmed_at = NOW(),
      raw_user_meta_data = '{"full_name":"Demo Super Admin","role":"super_admin"}',
      updated_at = NOW()
    WHERE id = v_user_id;
  END IF;

  INSERT INTO public.profiles (id, email, full_name, is_active)
  VALUES (v_user_id, 'superadmin@liah.com', 'Demo Super Admin', TRUE)
  ON CONFLICT (id) DO UPDATE SET full_name = 'Demo Super Admin', is_active = TRUE;

  IF v_super_admin_role_id IS NOT NULL THEN
    INSERT INTO public.profile_roles (profile_id, role_id)
    VALUES (v_user_id, v_super_admin_role_id)
    ON CONFLICT DO NOTHING;
  END IF;

END $$;
