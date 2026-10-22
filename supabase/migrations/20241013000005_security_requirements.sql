-- =============================================================================
-- Migration: 20241013000005_security_requirements.sql
-- Enforces:
-- 1. Full RLS & Default Deny on all tables including attendance & storage
-- 2. Student record protection (own records only; published results only)
-- 3. Lecturer access strictly scoped to assigned offerings
-- 4. Admin permission & institutional scope limits
-- 5. Backend verification for Super Admin actions (never client role string)
-- 6. Sensitive audit logging with credential scrubbing
-- 7. Private storage bucket policies with MIME & ownership validation
-- 8. Idempotent payment webhook tracking
-- 9. MFA verification helper for privileged operations
-- =============================================================================

-- -----------------------------------------------------------------------------
-- 1. Ensure Attendance & Session Tables Exist with RLS
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.attendance_sessions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  course_offering_id UUID NOT NULL REFERENCES public.course_offerings (id) ON DELETE CASCADE,
  session_date DATE NOT NULL DEFAULT CURRENT_DATE,
  start_time TIME NOT NULL,
  end_time TIME NOT NULL,
  topic TEXT,
  venue TEXT,
  conducted_by UUID REFERENCES public.staff (id),
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS public.attendance_records (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  session_id UUID NOT NULL REFERENCES public.attendance_sessions (id) ON DELETE CASCADE,
  student_id UUID NOT NULL REFERENCES public.students (id) ON DELETE CASCADE,
  status TEXT NOT NULL DEFAULT 'present' CHECK (status IN ('present', 'absent', 'late', 'excused')),
  remarks TEXT,
  marked_by UUID REFERENCES public.staff (id),
  marked_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE (session_id, student_id)
);

ALTER TABLE public.attendance_sessions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.attendance_records ENABLE ROW LEVEL SECURITY;

-- -----------------------------------------------------------------------------
-- 2. Staff and Course Assignment Helper Functions
-- -----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.current_staff_id()
RETURNS UUID
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
  SELECT s.id
  FROM public.staff s
  WHERE s.profile_id = auth.uid()
  LIMIT 1;
$$;

CREATE OR REPLACE FUNCTION public.is_assigned_lecturer(p_course_offering_id UUID)
RETURNS BOOLEAN
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
  SELECT EXISTS (
    SELECT 1
    FROM public.staff_assignments sa
    JOIN public.staff s ON s.id = sa.staff_id
    WHERE s.profile_id = auth.uid()
      AND sa.course_offering_id = p_course_offering_id
  );
$$;

-- -----------------------------------------------------------------------------
-- 3. Lecturer Scoped Access: Assessments & Attendance
-- -----------------------------------------------------------------------------

-- Assessment Configs
DROP POLICY IF EXISTS assessment_configs_select ON public.assessment_configs;
CREATE POLICY assessment_configs_select ON public.assessment_configs
  FOR SELECT TO authenticated
  USING (
    public.is_assigned_lecturer(course_offering_id)
    OR public.has_permission('grades.approve')
    OR public.has_role('super_admin')
    OR public.has_role('admin')
    OR EXISTS (
      SELECT 1 FROM public.course_registrations cr
      WHERE cr.course_offering_id = assessment_configs.course_offering_id
        AND cr.student_id = public.current_student_id()
    )
  );

DROP POLICY IF EXISTS assessment_configs_write ON public.assessment_configs;
CREATE POLICY assessment_configs_write ON public.assessment_configs
  FOR ALL TO authenticated
  USING (
    public.is_assigned_lecturer(course_offering_id)
    OR public.has_role('super_admin')
  )
  WITH CHECK (
    public.is_assigned_lecturer(course_offering_id)
    OR public.has_role('super_admin')
  );

-- Assessment Scores
DROP POLICY IF EXISTS assessment_scores_select ON public.assessment_scores;
CREATE POLICY assessment_scores_select ON public.assessment_scores
  FOR SELECT TO authenticated
  USING (
    public.is_assigned_lecturer((
      SELECT ac.course_offering_id
      FROM public.assessment_configs ac
      WHERE ac.id = assessment_config_id
    ))
    OR (
      student_id = public.current_student_id()
      AND EXISTS (
        SELECT 1 FROM public.final_results fr
        JOIN public.assessment_configs ac ON ac.course_offering_id = fr.course_offering_id
        WHERE ac.id = assessment_config_id
          AND fr.student_id = public.current_student_id()
          AND fr.workflow_status = 'published'
      )
    )
    OR public.has_permission('grades.approve')
    OR public.has_role('super_admin')
  );

DROP POLICY IF EXISTS assessment_scores_write ON public.assessment_scores;
CREATE POLICY assessment_scores_write ON public.assessment_scores
  FOR ALL TO authenticated
  USING (
    public.is_assigned_lecturer((
      SELECT ac.course_offering_id
      FROM public.assessment_configs ac
      WHERE ac.id = assessment_config_id
    ))
    OR public.has_role('super_admin')
  )
  WITH CHECK (
    public.is_assigned_lecturer((
      SELECT ac.course_offering_id
      FROM public.assessment_configs ac
      WHERE ac.id = assessment_config_id
    ))
    OR public.has_role('super_admin')
  );

-- Attendance Sessions
DROP POLICY IF EXISTS attendance_sessions_select ON public.attendance_sessions;
CREATE POLICY attendance_sessions_select ON public.attendance_sessions
  FOR SELECT TO authenticated
  USING (
    public.is_assigned_lecturer(course_offering_id)
    OR public.has_permission('students.read')
    OR public.has_role('super_admin')
    OR EXISTS (
      SELECT 1 FROM public.course_registrations cr
      WHERE cr.course_offering_id = attendance_sessions.course_offering_id
        AND cr.student_id = public.current_student_id()
    )
  );

DROP POLICY IF EXISTS attendance_sessions_write ON public.attendance_sessions;
CREATE POLICY attendance_sessions_write ON public.attendance_sessions
  FOR ALL TO authenticated
  USING (
    public.is_assigned_lecturer(course_offering_id)
    OR public.has_role('super_admin')
  )
  WITH CHECK (
    public.is_assigned_lecturer(course_offering_id)
    OR public.has_role('super_admin')
  );

-- Attendance Records
DROP POLICY IF EXISTS attendance_records_select ON public.attendance_records;
CREATE POLICY attendance_records_select ON public.attendance_records
  FOR SELECT TO authenticated
  USING (
    student_id = public.current_student_id()
    OR public.is_assigned_lecturer((
      SELECT atts.course_offering_id
      FROM public.attendance_sessions atts
      WHERE atts.id = session_id
    ))
    OR public.has_permission('students.read')
    OR public.has_role('super_admin')
  );

DROP POLICY IF EXISTS attendance_records_write ON public.attendance_records;
CREATE POLICY attendance_records_write ON public.attendance_records
  FOR ALL TO authenticated
  USING (
    public.is_assigned_lecturer((
      SELECT atts.course_offering_id
      FROM public.attendance_sessions atts
      WHERE atts.id = session_id
    ))
    OR public.has_role('super_admin')
  )
  WITH CHECK (
    public.is_assigned_lecturer((
      SELECT atts.course_offering_id
      FROM public.attendance_sessions atts
      WHERE atts.id = session_id
    ))
    OR public.has_role('super_admin')
  );

-- -----------------------------------------------------------------------------
-- 4. Student Protected Records (Self Only)
-- -----------------------------------------------------------------------------
-- Final Results: Students only see PUBLISHED results
DROP POLICY IF EXISTS final_results_select ON public.final_results;
CREATE POLICY final_results_select ON public.final_results
  FOR SELECT TO authenticated
  USING (
    (student_id = public.current_student_id() AND workflow_status = 'published')
    OR public.is_assigned_lecturer(course_offering_id)
    OR public.has_permission('grades.submit')
    OR public.has_permission('grades.approve')
    OR public.has_role('super_admin')
  );

-- Resits: Students only see PUBLISHED resit attempts
DROP POLICY IF EXISTS resit_attempts_select ON public.resit_attempts;
CREATE POLICY resit_attempts_select ON public.resit_attempts
  FOR SELECT TO authenticated
  USING (
    (student_id = public.current_student_id() AND workflow_status = 'published')
    OR public.is_assigned_lecturer((
      SELECT fr.course_offering_id FROM public.final_results fr WHERE fr.id = final_result_id
    ))
    OR public.has_permission('grades.approve')
    OR public.has_role('super_admin')
  );

-- Stored Documents: Owner or assigned student only
DROP POLICY IF EXISTS stored_documents_select ON public.stored_documents;
CREATE POLICY stored_documents_select ON public.stored_documents
  FOR SELECT TO authenticated
  USING (
    owner_profile_id = auth.uid()
    OR student_id = public.current_student_id()
    OR public.has_permission('students.read')
    OR public.has_role('super_admin')
  );

-- -----------------------------------------------------------------------------
-- 5. Super Admin Backend Enforcement Function
-- -----------------------------------------------------------------------------
-- Critical operations must execute through backend functions that verify database role
CREATE OR REPLACE FUNCTION public.assert_super_admin()
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  IF NOT public.has_role('super_admin') THEN
    RAISE EXCEPTION 'Access Denied: Action requires verified Super Admin role privileges (auth.uid: %)', auth.uid()
      USING ERRCODE = '42501';
  END IF;
END;
$$;

-- Backend function to manage roles with server-side Super Admin verification
CREATE OR REPLACE FUNCTION public.backend_assign_role(
  p_target_profile_id UUID,
  p_role_code TEXT
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_role_id UUID;
BEGIN
  -- Strict server-side verification:
  PERFORM public.assert_super_admin();

  SELECT id INTO v_role_id FROM public.roles WHERE code = p_role_code;
  IF v_role_id IS NULL THEN
    RAISE EXCEPTION 'Invalid role code: %', p_role_code;
  END IF;

  INSERT INTO public.profile_roles (profile_id, role_id)
  VALUES (p_target_profile_id, v_role_id)
  ON CONFLICT (profile_id, role_id) DO NOTHING;

  -- Audit log without sensitive credentials
  PERFORM public.log_sensitive_action(
    'role.assigned',
    'profiles',
    p_target_profile_id,
    jsonb_build_object('role_code', p_role_code)
  );

  RETURN jsonb_build_object('success', true, 'profile_id', p_target_profile_id, 'role', p_role_code);
END;
$$;

-- -----------------------------------------------------------------------------
-- 6. Sensitive Audit Logging with Credential Scrubbing
-- -----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.scrub_sensitive_payload(p_payload JSONB)
RETURNS JSONB
LANGUAGE plpgsql
IMMUTABLE
AS $$
DECLARE
  v_result JSONB := p_payload;
  v_sensitive_keys TEXT[] := ARRAY[
    'password', 'new_password', 'old_password', 'token', 'access_token',
    'refresh_token', 'secret', 'pin', 'cvv', 'card_number', 'pan', 'api_key'
  ];
  k TEXT;
BEGIN
  IF p_payload IS NULL OR jsonb_typeof(p_payload) != 'object' THEN
    RETURN p_payload;
  END IF;

  FOREACH k IN ARRAY v_sensitive_keys LOOP
    IF v_result ? k THEN
      v_result := jsonb_set(v_result, ARRAY[k], '"[REDACTED]"'::jsonb);
    END IF;
  END LOOP;

  RETURN v_result;
END;
$$;

CREATE OR REPLACE FUNCTION public.log_sensitive_action(
  p_action TEXT,
  p_entity_type TEXT,
  p_entity_id UUID,
  p_details JSONB DEFAULT '{}'::jsonb
)
RETURNS UUID
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_log_id UUID;
  v_sanitized_details JSONB;
BEGIN
  v_sanitized_details := public.scrub_sensitive_payload(p_details);

  INSERT INTO public.audit_logs (
    actor_profile_id,
    action,
    entity_type,
    entity_id,
    details,
    created_at
  )
  VALUES (
    auth.uid(),
    p_action,
    p_entity_type,
    p_entity_id,
    v_sanitized_details,
    NOW()
  )
  RETURNING id INTO v_log_id;

  RETURN v_log_id;
END;
$$;

-- Audit logs access: Super Admin only read; writes through log_sensitive_action
DROP POLICY IF EXISTS audit_logs_select ON public.audit_logs;
CREATE POLICY audit_logs_select ON public.audit_logs
  FOR SELECT TO authenticated
  USING (public.has_role('super_admin') OR public.has_permission('audit.read'));

-- -----------------------------------------------------------------------------
-- 7. Private Storage Buckets & Policies
-- -----------------------------------------------------------------------------
-- Create private buckets for documents, transcripts, receipts
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES
  ('documents', 'documents', FALSE, 10485760, ARRAY['application/pdf', 'image/jpeg', 'image/png']),
  ('receipts', 'receipts', FALSE, 5242880, ARRAY['application/pdf', 'image/jpeg', 'image/png']),
  ('transcripts', 'transcripts', FALSE, 10485760, ARRAY['application/pdf'])
ON CONFLICT (id) DO UPDATE SET
  public = FALSE,
  file_size_limit = EXCLUDED.file_size_limit,
  allowed_mime_types = EXCLUDED.allowed_mime_types;

-- Storage Objects RLS: Owner or staff with students.read
DROP POLICY IF EXISTS storage_objects_read ON storage.objects;
CREATE POLICY storage_objects_read ON storage.objects
  FOR SELECT TO authenticated
  USING (
    bucket_id IN ('documents', 'receipts', 'transcripts')
    AND (
      (storage.foldername(name))[1] = auth.uid()::text
      OR public.has_permission('students.read')
      OR public.has_role('super_admin')
    )
  );

DROP POLICY IF EXISTS storage_objects_insert ON storage.objects;
CREATE POLICY storage_objects_insert ON storage.objects
  FOR INSERT TO authenticated
  WITH CHECK (
    bucket_id IN ('documents', 'receipts', 'transcripts')
    AND (storage.foldername(name))[1] = auth.uid()::text
    AND (LOWER(storage.extension(name)) IN ('pdf', 'jpg', 'jpeg', 'png'))
  );

-- -----------------------------------------------------------------------------
-- 8. Idempotent Payment Webhook Processing Function
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.processed_webhook_events (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  provider TEXT NOT NULL,
  event_id TEXT NOT NULL,
  payment_id UUID REFERENCES public.payments(id),
  processed_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  idempotency_hash TEXT NOT NULL,
  UNIQUE(provider, event_id)
);

ALTER TABLE public.processed_webhook_events ENABLE ROW LEVEL SECURITY;

CREATE OR REPLACE FUNCTION public.process_idempotent_payment_webhook(
  p_provider TEXT,
  p_event_id TEXT,
  p_transaction_ref TEXT,
  p_amount_xaf BIGINT,
  p_status TEXT,
  p_payload JSONB
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_payment_id UUID;
  v_already_processed BOOLEAN;
  v_charge_id UUID;
BEGIN
  -- 1. Check idempotency
  SELECT EXISTS (
    SELECT 1 FROM public.processed_webhook_events
    WHERE provider = p_provider AND event_id = p_event_id
  ) INTO v_already_processed;

  IF v_already_processed THEN
    RETURN jsonb_build_object(
      'status', 'already_processed',
      'idempotent', true,
      'event_id', p_event_id
    );
  END IF;

  -- 2. Find or match payment record
  SELECT id INTO v_payment_id
  FROM public.payments
  WHERE external_reference = p_transaction_ref
  LIMIT 1;

  IF v_payment_id IS NOT NULL THEN
    UPDATE public.payments
    SET status = p_status::public.payment_status,
        verified_at = CASE WHEN p_status = 'verified' THEN NOW() ELSE verified_at END,
        updated_at = NOW()
    WHERE id = v_payment_id;
  END IF;

  -- 3. Record processed event
  INSERT INTO public.processed_webhook_events (
    provider,
    event_id,
    payment_id,
    idempotency_hash
  )
  VALUES (
    p_provider,
    p_event_id,
    v_payment_id,
    md5(p_provider || ':' || p_event_id || ':' || COALESCE(p_transaction_ref, ''))
  );

  -- 4. Scrubbed payment event log
  INSERT INTO public.payment_events (payment_id, event_type, payload)
  VALUES (
    v_payment_id,
    p_status,
    public.scrub_sensitive_payload(p_payload)
  );

  RETURN jsonb_build_object(
    'status', 'processed',
    'idempotent', false,
    'payment_id', v_payment_id,
    'event_id', p_event_id
  );
END;
$$;

-- -----------------------------------------------------------------------------
-- 9. MFA Verification Helper for Privileged Accounts
-- -----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.is_mfa_verified()
RETURNS BOOLEAN
LANGUAGE sql
STABLE
AS $$
  SELECT COALESCE(
    (auth.jwt() ->> 'aal') = 'aal2',
    FALSE
  );
$$;

GRANT USAGE ON SCHEMA public TO authenticated;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO authenticated;
