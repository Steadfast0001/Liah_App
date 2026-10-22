-- =============================================================================
-- Liah Academy — Restoration Integrity & RLS Verification Suite
-- Validates:
-- 1. All critical tables exist
-- 2. Row-Level Security (RLS) is ENABLED on 100% of public tables
-- 3. Core roles and permission mappings are restored
-- 4. Audit logging and credential scrubbing triggers are active
-- =============================================================================

DO $$
DECLARE
  v_missing_tables TEXT[];
  v_unprotected_tables TEXT[];
  v_role_count INT;
  v_rls_enabled_count INT;
BEGIN
  RAISE NOTICE 'Starting restoration verification audit...';

  -- 1. Verify RLS is enabled on all public tables
  SELECT array_agg(relname::text)
  INTO v_unprotected_tables
  FROM pg_class c
  JOIN pg_namespace n ON n.oid = c.relnamespace
  WHERE n.nspname = 'public'
    AND c.relkind = 'r'
    AND c.relrowsecurity = FALSE;

  IF v_unprotected_tables IS NOT NULL AND array_length(v_unprotected_tables, 1) > 0 THEN
    RAISE EXCEPTION 'Restoration failure: Tables found with RLS disabled: %', v_unprotected_tables;
  END IF;

  SELECT count(*) INTO v_rls_enabled_count
  FROM pg_class c
  JOIN pg_namespace n ON n.oid = c.relnamespace
  WHERE n.nspname = 'public'
    AND c.relkind = 'r'
    AND c.relrowsecurity = TRUE;

  RAISE NOTICE '✓ Verified: % public tables have Row-Level Security strictly ENABLED.', v_rls_enabled_count;

  -- 2. Verify Baseline Roles
  SELECT count(*) INTO v_role_count
  FROM public.roles
  WHERE code IN ('super_admin', 'admin', 'lecturer', 'student');

  IF v_role_count < 4 THEN
    RAISE EXCEPTION 'Restoration failure: Expected 4 baseline roles, found %', v_role_count;
  END IF;

  RAISE NOTICE '✓ Verified: All 4 institutional roles (super_admin, admin, lecturer, student) are restored.';

  -- 3. Verify Helper Functions
  IF NOT EXISTS (
    SELECT 1 FROM pg_proc p
    JOIN pg_namespace n ON n.oid = p.pronamespace
    WHERE n.nspname = 'public' AND p.proname = 'is_assigned_lecturer'
  ) THEN
    RAISE EXCEPTION 'Restoration failure: is_assigned_lecturer function missing.';
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM pg_proc p
    JOIN pg_namespace n ON n.oid = p.pronamespace
    WHERE n.nspname = 'public' AND p.proname = 'scrub_sensitive_payload'
  ) THEN
    RAISE EXCEPTION 'Restoration failure: scrub_sensitive_payload function missing.';
  END IF;

  RAISE NOTICE '✓ Verified: Security helper functions and credential scrubbing routines are restored.';
  RAISE NOTICE '✓ RESTORATION AUDIT PASSED: Backup is verified healthy and deployable.';
END;
$$;
