-- =============================================================================
-- Create Demo Users: Student & Lecturer
-- Run in Supabase SQL Editor:
-- https://supabase.com/dashboard/project/nqdlptrodovwbtqabxyu/sql/new
-- =============================================================================

CREATE EXTENSION IF NOT EXISTS pgcrypto;

DO $$
DECLARE
  v_student_id UUID := 'a1111111-1111-1111-1111-111111111111';
  v_lecturer_id UUID := 'b2222222-2222-2222-2222-222222222222';
  v_student_role_id UUID;
  v_lecturer_role_id UUID;
BEGIN
  -- 1. Get role IDs
  SELECT id INTO v_student_role_id FROM public.roles WHERE code = 'student';
  SELECT id INTO v_lecturer_role_id FROM public.roles WHERE code = 'lecturer';

  -- 2. Insert or update student@liah.com in auth.users
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
    v_student_id,
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
  )
  ON CONFLICT (email) DO UPDATE SET
    encrypted_password = crypt('password123', gen_salt('bf')),
    email_confirmed_at = NOW(),
    raw_user_meta_data = '{"full_name":"Demo Student","role":"student"}',
    updated_at = NOW();

  -- Link profile
  INSERT INTO public.profiles (id, email, full_name, is_active)
  SELECT id, email, 'Demo Student', TRUE
  FROM auth.users WHERE email = 'student@liah.com'
  ON CONFLICT (id) DO UPDATE SET full_name = 'Demo Student', is_active = TRUE;

  -- Link student role
  IF v_student_role_id IS NOT NULL THEN
    INSERT INTO public.profile_roles (profile_id, role_id)
    SELECT u.id, v_student_role_id
    FROM auth.users u WHERE u.email = 'student@liah.com'
    ON CONFLICT DO NOTHING;
  END IF;

  -- 3. Insert or update lecturer@liah.com in auth.users
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
    v_lecturer_id,
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
  )
  ON CONFLICT (email) DO UPDATE SET
    encrypted_password = crypt('password123', gen_salt('bf')),
    email_confirmed_at = NOW(),
    raw_user_meta_data = '{"full_name":"Demo Lecturer","role":"lecturer"}',
    updated_at = NOW();

  -- Link profile
  INSERT INTO public.profiles (id, email, full_name, is_active)
  SELECT id, email, 'Demo Lecturer', TRUE
  FROM auth.users WHERE email = 'lecturer@liah.com'
  ON CONFLICT (id) DO UPDATE SET full_name = 'Demo Lecturer', is_active = TRUE;

  -- Link lecturer role
  IF v_lecturer_role_id IS NOT NULL THEN
    INSERT INTO public.profile_roles (profile_id, role_id)
    SELECT u.id, v_lecturer_role_id
    FROM auth.users u WHERE u.email = 'lecturer@liah.com'
    ON CONFLICT DO NOTHING;
  END IF;

END $$;
