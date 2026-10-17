-- =============================================================================
-- FAH / LIAH ACADEMY SMS: COMPLETE DATABASE FIX & ROLE USER SYNC SCRIPT (V3)
-- =============================================================================
-- Run in Supabase SQL Editor:
-- https://supabase.com/dashboard/project/nqdlptrodovwbtqabxyu/sql/new
-- =============================================================================

CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- 1. Ensure public.roles contains all 4 standard academy roles
INSERT INTO public.roles (code, name, description, is_system) VALUES
  ('super_admin', 'Super Admin', 'Full system control and governance', TRUE),
  ('admin', 'Administrator', 'Operational management, admissions, finance, results', TRUE),
  ('lecturer', 'Lecturer', 'Teaching duties, course assignments, grades, attendance', TRUE),
  ('student', 'Student', 'Student services, registrations, results, fees', TRUE)
ON CONFLICT (code) DO UPDATE SET
  name = EXCLUDED.name,
  description = EXCLUDED.description,
  is_system = TRUE;

-- 2. Clear out corrupted records for the non-working accounts so they re-create cleanly
DELETE FROM auth.identities WHERE user_id IN (
  SELECT id FROM auth.users WHERE LOWER(email) IN ('lecturer@liah.com', 'admin@liah.com', 'superadmin@liah.com')
);
DELETE FROM auth.users WHERE LOWER(email) IN ('lecturer@liah.com', 'admin@liah.com', 'superadmin@liah.com');

-- 3. Provision / Synchronize all 4 accounts cleanly
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
    v_email := LOWER(item->>'email');
    v_full_name := item->>'full_name';
    v_role_code := item->>'role';

    -- Find matching role in public.roles
    SELECT id INTO v_role_id FROM public.roles WHERE code = v_role_code LIMIT 1;
    IF v_role_id IS NULL THEN
      RAISE EXCEPTION 'Role % not found in public.roles', v_role_code;
    END IF;

    -- Check if user already exists
    SELECT id INTO v_user_id FROM auth.users WHERE LOWER(email) = v_email;

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
        v_email,
        crypt('password123', gen_salt('bf')),
        NOW(),
        '{"provider":"email","providers":["email"]}'::jsonb,
        jsonb_build_object('full_name', v_full_name, 'role', v_role_code),
        NOW(),
        NOW(),
        '',
        '',
        '',
        ''
      );
    ELSE
      UPDATE auth.users SET
        encrypted_password = crypt('password123', gen_salt('bf')),
        email_confirmed_at = NOW(),
        aud = 'authenticated',
        role = 'authenticated',
        raw_app_meta_data = '{"provider":"email","providers":["email"]}'::jsonb,
        raw_user_meta_data = jsonb_build_object('full_name', v_full_name, 'role', v_role_code),
        updated_at = NOW()
      WHERE id = v_user_id;
    END IF;

    -- Set safe flags if columns exist
    IF v_has_sso THEN
      EXECUTE format('UPDATE auth.users SET is_sso_user = FALSE WHERE id = %L', v_user_id);
    END IF;
    IF v_has_anon THEN
      EXECUTE format('UPDATE auth.users SET is_anonymous = FALSE WHERE id = %L', v_user_id);
    END IF;

    -- B. Ensure matching row in auth.identities (Required for GoTrue v2 password authentication)
    BEGIN
      IF v_has_provider_id THEN
        IF EXISTS (SELECT 1 FROM auth.identities WHERE user_id = v_user_id AND provider = 'email') THEN
          UPDATE auth.identities SET
            identity_data = jsonb_build_object('sub', v_user_id::text, 'email', v_email),
            provider_id = v_user_id::text,
            last_sign_in_at = NOW(),
            updated_at = NOW()
          WHERE user_id = v_user_id AND provider = 'email';
        ELSE
          INSERT INTO auth.identities (
            id, user_id, identity_data, provider, provider_id, last_sign_in_at, created_at, updated_at
          ) VALUES (
            v_user_id::text, v_user_id, jsonb_build_object('sub', v_user_id::text, 'email', v_email), 'email', v_user_id::text, NOW(), NOW(), NOW()
          );
        END IF;
      ELSE
        IF EXISTS (SELECT 1 FROM auth.identities WHERE user_id = v_user_id AND provider = 'email') THEN
          UPDATE auth.identities SET
            identity_data = jsonb_build_object('sub', v_user_id::text, 'email', v_email),
            last_sign_in_at = NOW(),
            updated_at = NOW()
          WHERE user_id = v_user_id AND provider = 'email';
        ELSE
          INSERT INTO auth.identities (
            id, user_id, identity_data, provider, last_sign_in_at, created_at, updated_at
          ) VALUES (
            v_user_id::text, v_user_id, jsonb_build_object('sub', v_user_id::text, 'email', v_email), 'email', NOW(), NOW(), NOW()
          );
        END IF;
      END IF;
    EXCEPTION WHEN OTHERS THEN
      RAISE NOTICE 'Notice on auth.identities for %: %', v_email, SQLERRM;
    END;

    -- C. Sync public.profiles
    INSERT INTO public.profiles (id, email, full_name, is_active)
    VALUES (v_user_id, v_email, v_full_name, TRUE)
    ON CONFLICT (id) DO UPDATE SET
      email = EXCLUDED.email,
      full_name = EXCLUDED.full_name,
      is_active = TRUE,
      updated_at = NOW();

    -- D. Sync public.profile_roles
    DELETE FROM public.profile_roles WHERE profile_id = v_user_id;
    INSERT INTO public.profile_roles (profile_id, role_id)
    VALUES (v_user_id, v_role_id)
    ON CONFLICT DO NOTHING;

    RAISE NOTICE 'Synchronized: % -> %', v_email, v_role_code;
  END LOOP;
END $$;

-- 4. Verification Table: Confirm all 4 roles are active
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
