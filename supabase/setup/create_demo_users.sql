-- =============================================================================
-- Create Authentic Database Users: Student, Lecturer, Admin & Super Admin
-- Run in Supabase SQL Editor:
-- https://supabase.com/dashboard/project/nqdlptrodovwbtqabxyu/sql/new
-- =============================================================================

CREATE EXTENSION IF NOT EXISTS pgcrypto;

INSERT INTO public.roles (code, name, description, is_system) VALUES
  ('super_admin', 'Super Admin', 'Full system control', TRUE),
  ('admin', 'Administrator', 'Admissions, students, finance, results', TRUE),
  ('lecturer', 'Lecturer', 'Assigned courses, grades, attendance', TRUE),
  ('student', 'Student', 'Registration, fees, results, transcripts', TRUE)
ON CONFLICT (code) DO NOTHING;

DO $$
DECLARE
  users_data jsonb := '[
    {"email": "student@liah.com", "full_name": "Demo Student", "role": "student"},
    {"email": "lecturer@liah.com", "full_name": "Demo Lecturer", "role": "lecturer"},
    {"email": "admin@liah.com", "full_name": "Demo Admin", "role": "admin"},
    {"email": "superadmin@liah.com", "full_name": "Demo Super Admin", "role": "super_admin"}
  ]'::jsonb;

  item jsonb;
  v_email TEXT;
  v_full_name TEXT;
  v_role_code TEXT;
  v_user_id UUID;
  v_role_id UUID;
  v_has_provider_id BOOLEAN;
  v_has_sso BOOLEAN;
  v_has_anon BOOLEAN;
BEGIN
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

  FOR item IN SELECT * FROM jsonb_array_elements(users_data)
  LOOP
    v_email := item->>'email';
    v_full_name := item->>'full_name';
    v_role_code := item->>'role';

    SELECT id INTO v_role_id FROM public.roles WHERE code = v_role_code LIMIT 1;
    IF v_role_id IS NULL THEN
      RAISE EXCEPTION 'Role % not found in public.roles', v_role_code;
    END IF;

    SELECT id INTO v_user_id FROM auth.users WHERE LOWER(email) = LOWER(v_email);

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
        confirmed_at,
        raw_app_meta_data,
        raw_user_meta_data,
        created_at,
        updated_at
      ) VALUES (
        '00000000-0000-0000-0000-000000000000',
        v_user_id,
        'authenticated',
        'authenticated',
        LOWER(v_email),
        crypt('password123', gen_salt('bf')),
        NOW(),
        NOW(),
        '{"provider":"email","providers":["email"]}'::jsonb,
        jsonb_build_object('full_name', v_full_name, 'role', v_role_code),
        NOW(),
        NOW()
      );
    ELSE
      UPDATE auth.users SET
        encrypted_password = crypt('password123', gen_salt('bf')),
        email_confirmed_at = NOW(),
        confirmed_at = NOW(),
        aud = 'authenticated',
        role = 'authenticated',
        raw_app_meta_data = '{"provider":"email","providers":["email"]}'::jsonb,
        raw_user_meta_data = jsonb_build_object('full_name', v_full_name, 'role', v_role_code),
        updated_at = NOW()
      WHERE id = v_user_id;
    END IF;

    IF v_has_sso THEN
      EXECUTE format('UPDATE auth.users SET is_sso_user = FALSE WHERE id = %L', v_user_id);
    END IF;
    IF v_has_anon THEN
      EXECUTE format('UPDATE auth.users SET is_anonymous = FALSE WHERE id = %L', v_user_id);
    END IF;

    BEGIN
      IF v_has_provider_id THEN
        IF EXISTS (SELECT 1 FROM auth.identities WHERE user_id = v_user_id AND provider = 'email') THEN
          UPDATE auth.identities SET
            identity_data = jsonb_build_object('sub', v_user_id::text, 'email', LOWER(v_email)),
            provider_id = v_user_id::text,
            last_sign_in_at = NOW(),
            updated_at = NOW()
          WHERE user_id = v_user_id AND provider = 'email';
        ELSE
          INSERT INTO auth.identities (
            id, user_id, identity_data, provider, provider_id, last_sign_in_at, created_at, updated_at
          ) VALUES (
            v_user_id::text, v_user_id, jsonb_build_object('sub', v_user_id::text, 'email', LOWER(v_email)), 'email', v_user_id::text, NOW(), NOW(), NOW()
          );
        END IF;
      ELSE
        IF EXISTS (SELECT 1 FROM auth.identities WHERE user_id = v_user_id AND provider = 'email') THEN
          UPDATE auth.identities SET
            identity_data = jsonb_build_object('sub', v_user_id::text, 'email', LOWER(v_email)),
            last_sign_in_at = NOW(),
            updated_at = NOW()
          WHERE user_id = v_user_id AND provider = 'email';
        ELSE
          INSERT INTO auth.identities (
            id, user_id, identity_data, provider, last_sign_in_at, created_at, updated_at
          ) VALUES (
            v_user_id::text, v_user_id, jsonb_build_object('sub', v_user_id::text, 'email', LOWER(v_email)), 'email', NOW(), NOW(), NOW()
          );
        END IF;
      END IF;
    EXCEPTION WHEN OTHERS THEN
      RAISE NOTICE 'Notice: auth.identities for %: %', v_email, SQLERRM;
    END;

    INSERT INTO public.profiles (id, email, full_name, is_active)
    VALUES (v_user_id, LOWER(v_email), v_full_name, TRUE)
    ON CONFLICT (id) DO UPDATE SET
      email = EXCLUDED.email,
      full_name = EXCLUDED.full_name,
      is_active = TRUE,
      updated_at = NOW();

    DELETE FROM public.profile_roles WHERE profile_id = v_user_id;
    INSERT INTO public.profile_roles (profile_id, role_id)
    VALUES (v_user_id, v_role_id)
    ON CONFLICT DO NOTHING;
  END LOOP;
END $$;

SELECT 
  u.id,
  u.email,
  p.full_name,
  r.code AS assigned_role_code,
  r.name AS assigned_role_name,
  (u.email_confirmed_at IS NOT NULL) AS is_confirmed
FROM auth.users u
JOIN public.profiles p ON p.id = u.id
JOIN public.profile_roles pr ON pr.profile_id = p.id
JOIN public.roles r ON r.id = pr.role_id
WHERE u.email IN ('student@liah.com', 'lecturer@liah.com', 'admin@liah.com', 'superadmin@liah.com')
ORDER BY r.code;
