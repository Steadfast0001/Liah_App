-- Liah Academy SMS — foundational schema
-- All privileged writes should go through Edge Functions where noted in docs.

CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- ---------------------------------------------------------------------------
-- Identity (profiles linked to auth.users)
-- ---------------------------------------------------------------------------

CREATE TABLE public.profiles (
  id UUID PRIMARY KEY REFERENCES auth.users (id) ON DELETE CASCADE,
  email TEXT NOT NULL,
  full_name TEXT NOT NULL,
  phone TEXT,
  avatar_url TEXT,
  is_active BOOLEAN NOT NULL DEFAULT TRUE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE UNIQUE INDEX profiles_email_lower_idx ON public.profiles (LOWER(email));

-- ---------------------------------------------------------------------------
-- Academic structure
-- ---------------------------------------------------------------------------

CREATE TABLE public.departments (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  code TEXT NOT NULL UNIQUE,
  name TEXT NOT NULL,
  is_active BOOLEAN NOT NULL DEFAULT TRUE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE public.programs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  department_id UUID NOT NULL REFERENCES public.departments (id),
  code TEXT NOT NULL UNIQUE,
  name TEXT NOT NULL,
  duration_semesters INT NOT NULL CHECK (duration_semesters > 0),
  is_active BOOLEAN NOT NULL DEFAULT TRUE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE public.academic_years (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  label TEXT NOT NULL UNIQUE,
  starts_on DATE NOT NULL,
  ends_on DATE NOT NULL CHECK (ends_on > starts_on),
  is_current BOOLEAN NOT NULL DEFAULT FALSE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE public.semesters (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  academic_year_id UUID NOT NULL REFERENCES public.academic_years (id),
  term_number INT NOT NULL CHECK (term_number IN (1, 2)),
  label TEXT NOT NULL,
  starts_on DATE NOT NULL,
  ends_on DATE NOT NULL CHECK (ends_on > starts_on),
  registration_opens_at TIMESTAMPTZ,
  registration_closes_at TIMESTAMPTZ,
  is_current BOOLEAN NOT NULL DEFAULT FALSE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE (academic_year_id, term_number)
);

CREATE TABLE public.cohorts (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  program_id UUID NOT NULL REFERENCES public.programs (id),
  intake_year INT NOT NULL,
  label TEXT NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE (program_id, intake_year)
);

CREATE TABLE public.courses (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  department_id UUID NOT NULL REFERENCES public.departments (id),
  code TEXT NOT NULL UNIQUE,
  title TEXT NOT NULL,
  credit_units INT NOT NULL CHECK (credit_units > 0),
  level INT,
  is_active BOOLEAN NOT NULL DEFAULT TRUE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE public.course_offerings (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  course_id UUID NOT NULL REFERENCES public.courses (id),
  semester_id UUID NOT NULL REFERENCES public.semesters (id),
  cohort_id UUID REFERENCES public.cohorts (id),
  capacity INT CHECK (capacity IS NULL OR capacity > 0),
  is_open_for_registration BOOLEAN NOT NULL DEFAULT FALSE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE (course_id, semester_id, cohort_id)
);

CREATE TABLE public.course_prerequisites (
  course_id UUID NOT NULL REFERENCES public.courses (id) ON DELETE CASCADE,
  prerequisite_course_id UUID NOT NULL REFERENCES public.courses (id) ON DELETE CASCADE,
  PRIMARY KEY (course_id, prerequisite_course_id),
  CHECK (course_id <> prerequisite_course_id)
);

-- ---------------------------------------------------------------------------
-- People
-- ---------------------------------------------------------------------------

CREATE TABLE public.students (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  profile_id UUID NOT NULL UNIQUE REFERENCES public.profiles (id),
  matricule TEXT NOT NULL UNIQUE,
  program_id UUID NOT NULL REFERENCES public.programs (id),
  cohort_id UUID REFERENCES public.cohorts (id),
  admission_date DATE NOT NULL DEFAULT CURRENT_DATE,
  status TEXT NOT NULL DEFAULT 'active'
    CHECK (status IN ('applicant', 'active', 'graduated', 'withdrawn', 'suspended')),
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE public.staff (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  profile_id UUID NOT NULL UNIQUE REFERENCES public.profiles (id),
  staff_number TEXT NOT NULL UNIQUE,
  department_id UUID REFERENCES public.departments (id),
  title TEXT,
  employment_status TEXT NOT NULL DEFAULT 'active'
    CHECK (employment_status IN ('active', 'on_leave', 'terminated')),
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE public.guardians (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  full_name TEXT NOT NULL,
  phone TEXT,
  email TEXT,
  relationship TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE public.student_guardians (
  student_id UUID NOT NULL REFERENCES public.students (id) ON DELETE CASCADE,
  guardian_id UUID NOT NULL REFERENCES public.guardians (id) ON DELETE CASCADE,
  is_primary BOOLEAN NOT NULL DEFAULT FALSE,
  PRIMARY KEY (student_id, guardian_id)
);

CREATE TABLE public.staff_assignments (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  staff_id UUID NOT NULL REFERENCES public.staff (id),
  course_offering_id UUID NOT NULL REFERENCES public.course_offerings (id),
  role TEXT NOT NULL DEFAULT 'lecturer'
    CHECK (role IN ('lecturer', 'assistant', 'coordinator')),
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE (staff_id, course_offering_id, role)
);

-- ---------------------------------------------------------------------------
-- Registration & results
-- ---------------------------------------------------------------------------

CREATE TABLE public.student_enrollments (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  student_id UUID NOT NULL REFERENCES public.students (id),
  semester_id UUID NOT NULL REFERENCES public.semesters (id),
  enrollment_status TEXT NOT NULL DEFAULT 'enrolled'
    CHECK (enrollment_status IN ('enrolled', 'completed', 'withdrawn')),
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE (student_id, semester_id)
);

CREATE TYPE public.course_registration_status AS ENUM (
  'registered',
  'dropped',
  'completed',
  'failed'
);

CREATE TABLE public.course_registrations (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  student_id UUID NOT NULL REFERENCES public.students (id),
  course_offering_id UUID NOT NULL REFERENCES public.course_offerings (id),
  semester_id UUID NOT NULL REFERENCES public.semesters (id),
  status public.course_registration_status NOT NULL DEFAULT 'registered',
  registered_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  dropped_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE (student_id, course_offering_id)
);

CREATE TYPE public.result_workflow_status AS ENUM (
  'draft',
  'submitted',
  'approved',
  'finalized',
  'published'
);

CREATE TABLE public.assessment_configs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  course_offering_id UUID NOT NULL REFERENCES public.course_offerings (id),
  name TEXT NOT NULL,
  weight_percent NUMERIC(5, 2) NOT NULL CHECK (weight_percent > 0 AND weight_percent <= 100),
  max_score NUMERIC(8, 2) NOT NULL DEFAULT 100,
  sort_order INT NOT NULL DEFAULT 0,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE public.assessment_scores (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  assessment_config_id UUID NOT NULL REFERENCES public.assessment_configs (id),
  student_id UUID NOT NULL REFERENCES public.students (id),
  score NUMERIC(8, 2) NOT NULL CHECK (score >= 0),
  recorded_by UUID REFERENCES public.profiles (id),
  recorded_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE (assessment_config_id, student_id)
);

CREATE TABLE public.final_results (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  student_id UUID NOT NULL REFERENCES public.students (id),
  course_offering_id UUID NOT NULL REFERENCES public.course_offerings (id),
  semester_id UUID NOT NULL REFERENCES public.semesters (id),
  total_score NUMERIC(8, 2),
  grade_letter TEXT,
  grade_point NUMERIC(4, 2),
  workflow_status public.result_workflow_status NOT NULL DEFAULT 'draft',
  submitted_at TIMESTAMPTZ,
  approved_at TIMESTAMPTZ,
  finalized_at TIMESTAMPTZ,
  published_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE (student_id, course_offering_id)
);

CREATE TABLE public.resit_attempts (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  final_result_id UUID NOT NULL REFERENCES public.final_results (id),
  attempt_number INT NOT NULL CHECK (attempt_number >= 1),
  total_score NUMERIC(8, 2),
  grade_letter TEXT,
  recorded_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE (final_result_id, attempt_number)
);

-- ---------------------------------------------------------------------------
-- Finance
-- ---------------------------------------------------------------------------

CREATE TABLE public.fee_categories (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  code TEXT NOT NULL UNIQUE,
  name TEXT NOT NULL,
  description TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE public.fee_structures (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  program_id UUID NOT NULL REFERENCES public.programs (id),
  fee_category_id UUID NOT NULL REFERENCES public.fee_categories (id),
  amount_xaf BIGINT NOT NULL CHECK (amount_xaf >= 0),
  effective_from DATE NOT NULL,
  effective_to DATE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE public.semester_fee_rules (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  semester_id UUID NOT NULL REFERENCES public.semesters (id),
  fee_category_id UUID NOT NULL REFERENCES public.fee_categories (id),
  amount_xaf BIGINT NOT NULL CHECK (amount_xaf >= 0),
  due_date DATE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE (semester_id, fee_category_id)
);

CREATE TYPE public.charge_status AS ENUM ('pending', 'partial', 'paid', 'waived', 'overdue');

CREATE TABLE public.student_charges (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  student_id UUID NOT NULL REFERENCES public.students (id),
  semester_id UUID NOT NULL REFERENCES public.semesters (id),
  fee_category_id UUID NOT NULL REFERENCES public.fee_categories (id),
  amount_xaf BIGINT NOT NULL CHECK (amount_xaf >= 0),
  amount_paid_xaf BIGINT NOT NULL DEFAULT 0 CHECK (amount_paid_xaf >= 0),
  status public.charge_status NOT NULL DEFAULT 'pending',
  due_date DATE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TYPE public.payment_provider AS ENUM ('mtn_momo', 'orange_money', 'bank', 'cash');
CREATE TYPE public.payment_status AS ENUM ('pending', 'processing', 'verified', 'failed', 'refunded');

CREATE TABLE public.payments (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  student_id UUID NOT NULL REFERENCES public.students (id),
  semester_id UUID REFERENCES public.semesters (id),
  provider public.payment_provider NOT NULL,
  external_reference TEXT,
  amount_xaf BIGINT NOT NULL CHECK (amount_xaf > 0),
  status public.payment_status NOT NULL DEFAULT 'pending',
  initiated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  verified_at TIMESTAMPTZ,
  metadata JSONB NOT NULL DEFAULT '{}'::JSONB,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE public.payment_events (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  payment_id UUID NOT NULL REFERENCES public.payments (id) ON DELETE CASCADE,
  event_type TEXT NOT NULL,
  payload JSONB NOT NULL DEFAULT '{}'::JSONB,
  received_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ---------------------------------------------------------------------------
-- Documents & communications
-- ---------------------------------------------------------------------------

CREATE TABLE public.stored_documents (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  owner_profile_id UUID REFERENCES public.profiles (id),
  student_id UUID REFERENCES public.students (id),
  bucket TEXT NOT NULL,
  storage_path TEXT NOT NULL,
  document_type TEXT NOT NULL,
  title TEXT NOT NULL,
  mime_type TEXT,
  uploaded_by UUID REFERENCES public.profiles (id),
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE public.announcements (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  title TEXT NOT NULL,
  body TEXT NOT NULL,
  audience TEXT NOT NULL DEFAULT 'all'
    CHECK (audience IN ('all', 'students', 'staff', 'program')),
  program_id UUID REFERENCES public.programs (id),
  published_at TIMESTAMPTZ,
  created_by UUID REFERENCES public.profiles (id),
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE public.notifications (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  profile_id UUID NOT NULL REFERENCES public.profiles (id),
  title TEXT NOT NULL,
  body TEXT NOT NULL,
  channel TEXT NOT NULL DEFAULT 'in_app'
    CHECK (channel IN ('in_app', 'email', 'sms')),
  read_at TIMESTAMPTZ,
  metadata JSONB NOT NULL DEFAULT '{}'::JSONB,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ---------------------------------------------------------------------------
-- Audit
-- ---------------------------------------------------------------------------

CREATE TABLE public.audit_logs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  actor_profile_id UUID REFERENCES public.profiles (id),
  action TEXT NOT NULL,
  entity_type TEXT NOT NULL,
  entity_id UUID,
  details JSONB NOT NULL DEFAULT '{}'::JSONB,
  ip_address INET,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX audit_logs_created_at_idx ON public.audit_logs (created_at DESC);
CREATE INDEX notifications_profile_unread_idx ON public.notifications (profile_id) WHERE read_at IS NULL;

-- updated_at trigger
CREATE OR REPLACE FUNCTION public.set_updated_at()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$;

DO $$
DECLARE
  t TEXT;
BEGIN
  FOR t IN
    SELECT unnest(ARRAY[
      'profiles', 'departments', 'programs', 'academic_years', 'semesters',
      'cohorts', 'courses', 'course_offerings', 'students', 'staff', 'guardians',
      'student_enrollments', 'course_registrations', 'assessment_configs',
      'assessment_scores', 'final_results', 'fee_structures', 'student_charges',
      'payments', 'announcements'
    ])
  LOOP
    EXECUTE format(
      'CREATE TRIGGER %I_set_updated_at BEFORE UPDATE ON public.%I
       FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();',
      t, t
    );
  END LOOP;
END;
$$;
