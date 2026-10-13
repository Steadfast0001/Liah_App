-- =============================================================================
-- Liah Academy SMS — Complete Remote Database Setup (Clean SQL for Supabase)
-- =============================================================================

CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- ---------------------------------------------------------------------------
-- 0. Custom Types
-- ---------------------------------------------------------------------------
DROP TYPE IF EXISTS public.course_registration_status CASCADE;
CREATE TYPE public.course_registration_status AS ENUM (
  'registered',
  'dropped',
  'completed',
  'failed'
);

DROP TYPE IF EXISTS public.result_workflow_status CASCADE;
CREATE TYPE public.result_workflow_status AS ENUM (
  'draft',
  'submitted',
  'approved',
  'finalized',
  'published'
);

DROP TYPE IF EXISTS public.charge_status CASCADE;
CREATE TYPE public.charge_status AS ENUM (
  'pending',
  'partial',
  'paid',
  'waived',
  'overdue'
);

DROP TYPE IF EXISTS public.payment_provider CASCADE;
CREATE TYPE public.payment_provider AS ENUM (
  'mtn_momo',
  'orange_money',
  'bank',
  'cash'
);

DROP TYPE IF EXISTS public.payment_status CASCADE;
CREATE TYPE public.payment_status AS ENUM (
  'pending',
  'processing',
  'verified',
  'failed',
  'refunded'
);

-- ---------------------------------------------------------------------------
-- 1. Identity & Profiles
-- ---------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS public.profiles (
  id UUID PRIMARY KEY REFERENCES auth.users (id) ON DELETE CASCADE,
  email TEXT NOT NULL,
  full_name TEXT NOT NULL,
  phone TEXT,
  avatar_url TEXT,
  is_active BOOLEAN NOT NULL DEFAULT TRUE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE UNIQUE INDEX IF NOT EXISTS profiles_email_lower_idx ON public.profiles (LOWER(email));

-- ---------------------------------------------------------------------------
-- 2. Academic Structure
-- ---------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS public.departments (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  code TEXT NOT NULL UNIQUE,
  name TEXT NOT NULL,
  is_active BOOLEAN NOT NULL DEFAULT TRUE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS public.programs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  department_id UUID NOT NULL REFERENCES public.departments (id),
  code TEXT NOT NULL UNIQUE,
  name TEXT NOT NULL,
  duration_semesters INT NOT NULL CHECK (duration_semesters > 0),
  is_active BOOLEAN NOT NULL DEFAULT TRUE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS public.academic_years (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  label TEXT NOT NULL UNIQUE,
  starts_on DATE NOT NULL,
  ends_on DATE NOT NULL CHECK (ends_on > starts_on),
  is_current BOOLEAN NOT NULL DEFAULT FALSE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS public.semesters (
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

CREATE TABLE IF NOT EXISTS public.cohorts (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  program_id UUID NOT NULL REFERENCES public.programs (id),
  intake_year INT NOT NULL,
  label TEXT NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE (program_id, intake_year)
);

CREATE TABLE IF NOT EXISTS public.courses (
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

CREATE TABLE IF NOT EXISTS public.course_offerings (
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

CREATE TABLE IF NOT EXISTS public.course_prerequisites (
  course_id UUID NOT NULL REFERENCES public.courses (id) ON DELETE CASCADE,
  prerequisite_course_id UUID NOT NULL REFERENCES public.courses (id) ON DELETE CASCADE,
  PRIMARY KEY (course_id, prerequisite_course_id),
  CHECK (course_id <> prerequisite_course_id)
);

-- ---------------------------------------------------------------------------
-- 3. People
-- ---------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS public.students (
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

CREATE TABLE IF NOT EXISTS public.staff (
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

CREATE TABLE IF NOT EXISTS public.guardians (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  full_name TEXT NOT NULL,
  phone TEXT,
  email TEXT,
  relationship TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS public.student_guardians (
  student_id UUID NOT NULL REFERENCES public.students (id) ON DELETE CASCADE,
  guardian_id UUID NOT NULL REFERENCES public.guardians (id) ON DELETE CASCADE,
  is_primary BOOLEAN NOT NULL DEFAULT FALSE,
  PRIMARY KEY (student_id, guardian_id)
);

CREATE TABLE IF NOT EXISTS public.staff_assignments (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  staff_id UUID NOT NULL REFERENCES public.staff (id),
  course_offering_id UUID NOT NULL REFERENCES public.course_offerings (id),
  role TEXT NOT NULL DEFAULT 'lecturer'
    CHECK (role IN ('lecturer', 'assistant', 'coordinator')),
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE (staff_id, course_offering_id, role)
);

-- ---------------------------------------------------------------------------
-- 4. Enrollments & Registrations
-- ---------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS public.student_enrollments (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  student_id UUID NOT NULL REFERENCES public.students (id),
  semester_id UUID NOT NULL REFERENCES public.semesters (id),
  enrollment_status TEXT NOT NULL DEFAULT 'enrolled'
    CHECK (enrollment_status IN ('enrolled', 'completed', 'withdrawn')),
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE (student_id, semester_id)
);

CREATE TABLE IF NOT EXISTS public.course_registrations (
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

CREATE TABLE IF NOT EXISTS public.assessment_configs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  course_offering_id UUID NOT NULL REFERENCES public.course_offerings (id),
  name TEXT NOT NULL,
  weight_percent NUMERIC(5, 2) NOT NULL CHECK (weight_percent > 0 AND weight_percent <= 100),
  max_score NUMERIC(8, 2) NOT NULL DEFAULT 100,
  sort_order INT NOT NULL DEFAULT 0,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS public.assessment_scores (
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

CREATE TABLE IF NOT EXISTS public.final_results (
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

CREATE TABLE IF NOT EXISTS public.resit_attempts (
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
-- 5. Finance
-- ---------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS public.fee_categories (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  code TEXT NOT NULL UNIQUE,
  name TEXT NOT NULL,
  description TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS public.fee_structures (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  program_id UUID NOT NULL REFERENCES public.programs (id),
  fee_category_id UUID NOT NULL REFERENCES public.fee_categories (id),
  amount_xaf BIGINT NOT NULL CHECK (amount_xaf >= 0),
  effective_from DATE NOT NULL,
  effective_to DATE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS public.semester_fee_rules (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  semester_id UUID NOT NULL REFERENCES public.semesters (id),
  fee_category_id UUID NOT NULL REFERENCES public.fee_categories (id),
  amount_xaf BIGINT NOT NULL CHECK (amount_xaf >= 0),
  due_date DATE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE (semester_id, fee_category_id)
);

CREATE TABLE IF NOT EXISTS public.student_charges (
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

CREATE TABLE IF NOT EXISTS public.payments (
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

CREATE TABLE IF NOT EXISTS public.payment_events (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  payment_id UUID NOT NULL REFERENCES public.payments (id) ON DELETE CASCADE,
  event_type TEXT NOT NULL,
  payload JSONB NOT NULL DEFAULT '{}'::JSONB,
  received_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ---------------------------------------------------------------------------
-- 6. Documents, Notifications, Audit
-- ---------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS public.stored_documents (
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

CREATE TABLE IF NOT EXISTS public.announcements (
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

CREATE TABLE IF NOT EXISTS public.notifications (
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

CREATE TABLE IF NOT EXISTS public.audit_logs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  actor_profile_id UUID REFERENCES public.profiles (id),
  action TEXT NOT NULL,
  entity_type TEXT NOT NULL,
  entity_id UUID,
  details JSONB NOT NULL DEFAULT '{}'::JSONB,
  ip_address INET,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ---------------------------------------------------------------------------
-- 7. Roles & Permissions RBAC
-- ---------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS public.roles (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  code TEXT NOT NULL UNIQUE,
  name TEXT NOT NULL,
  description TEXT,
  is_system BOOLEAN NOT NULL DEFAULT FALSE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS public.permissions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  code TEXT NOT NULL UNIQUE,
  name TEXT NOT NULL,
  description TEXT,
  domain TEXT NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS public.role_permissions (
  role_id UUID NOT NULL REFERENCES public.roles (id) ON DELETE CASCADE,
  permission_id UUID NOT NULL REFERENCES public.permissions (id) ON DELETE CASCADE,
  PRIMARY KEY (role_id, permission_id)
);

CREATE TABLE IF NOT EXISTS public.profile_roles (
  profile_id UUID NOT NULL REFERENCES public.profiles (id) ON DELETE CASCADE,
  role_id UUID NOT NULL REFERENCES public.roles (id) ON DELETE CASCADE,
  assigned_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  assigned_by UUID REFERENCES public.profiles (id),
  PRIMARY KEY (profile_id, role_id)
);

-- Seed Roles
INSERT INTO public.roles (code, name, description, is_system) VALUES
  ('super_admin', 'Super Admin', 'Full system control', TRUE),
  ('admin', 'Administrator', 'Admissions, students, finance, results', TRUE),
  ('lecturer', 'Lecturer', 'Assigned courses, grades, attendance', TRUE),
  ('student', 'Student', 'Registration, fees, results, transcripts', TRUE)
ON CONFLICT (code) DO NOTHING;

-- Seed Permissions
INSERT INTO public.permissions (code, name, domain, description) VALUES
  ('users.manage', 'Manage users', 'identity', 'Create/update staff and student accounts'),
  ('roles.manage', 'Manage roles', 'identity', 'Assign roles (super admin only)'),
  ('academics.manage', 'Manage academics', 'academics', 'Programs, courses, semesters'),
  ('students.read', 'View students', 'people', 'Read student records'),
  ('students.write', 'Edit students', 'people', 'Update student records'),
  ('registration.manage', 'Course registration', 'registration', 'Register/drop courses'),
  ('grades.submit', 'Submit grades', 'results', 'Submit course grades for approval'),
  ('grades.approve', 'Approve results', 'results', 'Approve submitted results'),
  ('grades.finalize', 'Finalize results', 'results', 'Finalize approved results'),
  ('grades.publish', 'Publish results', 'results', 'Publish finalized results'),
  ('finance.read', 'View finance', 'finance', 'View charges and payments'),
  ('finance.verify', 'Verify payments', 'finance', 'Verify mobile money payments'),
  ('transcripts.generate', 'Generate transcripts', 'documents', 'Generate official transcripts'),
  ('audit.read', 'View audit log', 'audit', 'Read audit trail')
ON CONFLICT (code) DO NOTHING;

INSERT INTO public.role_permissions (role_id, permission_id)
SELECT r.id, p.id FROM public.roles r CROSS JOIN public.permissions p
WHERE r.code = 'super_admin' ON CONFLICT DO NOTHING;

INSERT INTO public.role_permissions (role_id, permission_id)
SELECT r.id, p.id FROM public.roles r
JOIN public.permissions p ON p.code IN (
  'users.manage', 'students.read', 'students.write', 'academics.manage',
  'grades.approve', 'finance.read', 'finance.verify'
) WHERE r.code = 'admin' ON CONFLICT DO NOTHING;

INSERT INTO public.role_permissions (role_id, permission_id)
SELECT r.id, p.id FROM public.roles r
JOIN public.permissions p ON p.code IN ('grades.submit', 'students.read')
WHERE r.code = 'lecturer' ON CONFLICT DO NOTHING;

INSERT INTO public.role_permissions (role_id, permission_id)
SELECT r.id, p.id FROM public.roles r
JOIN public.permissions p ON p.code IN ('registration.manage', 'finance.read', 'students.read')
WHERE r.code = 'student' ON CONFLICT DO NOTHING;

-- ---------------------------------------------------------------------------
-- 8. Functions & Triggers
-- ---------------------------------------------------------------------------

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

-- ---------------------------------------------------------------------------
-- Guarantee all enum columns exist (in case custom types were dropped with CASCADE in earlier runs)
ALTER TABLE public.course_registrations ADD COLUMN IF NOT EXISTS status public.course_registration_status NOT NULL DEFAULT 'registered';
ALTER TABLE public.final_results ADD COLUMN IF NOT EXISTS workflow_status public.result_workflow_status NOT NULL DEFAULT 'draft';
ALTER TABLE public.student_charges ADD COLUMN IF NOT EXISTS status public.charge_status NOT NULL DEFAULT 'pending';
ALTER TABLE public.payments ADD COLUMN IF NOT EXISTS provider public.payment_provider NOT NULL DEFAULT 'cash';
ALTER TABLE public.payments ADD COLUMN IF NOT EXISTS status public.payment_status NOT NULL DEFAULT 'pending';

ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.roles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.permissions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.role_permissions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.profile_roles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.departments ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.programs ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.academic_years ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.semesters ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.cohorts ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.courses ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.course_offerings ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.course_prerequisites ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.students ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.staff ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.guardians ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.student_guardians ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.staff_assignments ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.student_enrollments ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.course_registrations ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.assessment_configs ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.assessment_scores ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.final_results ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.resit_attempts ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.fee_categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.fee_structures ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.semester_fee_rules ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.student_charges ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.payments ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.payment_events ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.stored_documents ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.announcements ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.notifications ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.audit_logs ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS profiles_select ON public.profiles;
CREATE POLICY profiles_select ON public.profiles FOR SELECT TO authenticated
  USING (id = auth.uid() OR public.has_permission('students.read') OR public.has_role('super_admin'));

DROP POLICY IF EXISTS profiles_update ON public.profiles;
CREATE POLICY profiles_update ON public.profiles FOR UPDATE TO authenticated
  USING (id = auth.uid()) WITH CHECK (id = auth.uid());

DROP POLICY IF EXISTS roles_select ON public.roles;
CREATE POLICY roles_select ON public.roles FOR SELECT TO authenticated USING (TRUE);

DROP POLICY IF EXISTS profile_roles_select ON public.profile_roles;
CREATE POLICY profile_roles_select ON public.profile_roles FOR SELECT TO authenticated
  USING (profile_id = auth.uid() OR public.has_role('super_admin'));

DROP POLICY IF EXISTS academic_years_select ON public.academic_years;
CREATE POLICY academic_years_select ON public.academic_years FOR SELECT TO authenticated USING (TRUE);

DROP POLICY IF EXISTS departments_select ON public.departments;
CREATE POLICY departments_select ON public.departments FOR SELECT TO authenticated USING (TRUE);

DROP POLICY IF EXISTS programs_select ON public.programs;
CREATE POLICY programs_select ON public.programs FOR SELECT TO authenticated USING (TRUE);

DROP POLICY IF EXISTS semesters_select ON public.semesters;
CREATE POLICY semesters_select ON public.semesters FOR SELECT TO authenticated USING (TRUE);

DROP POLICY IF EXISTS cohorts_select ON public.cohorts;
CREATE POLICY cohorts_select ON public.cohorts FOR SELECT TO authenticated USING (TRUE);

DROP POLICY IF EXISTS courses_select ON public.courses;
CREATE POLICY courses_select ON public.courses FOR SELECT TO authenticated USING (TRUE);

DROP POLICY IF EXISTS course_offerings_select ON public.course_offerings;
CREATE POLICY course_offerings_select ON public.course_offerings FOR SELECT TO authenticated USING (TRUE);

DROP POLICY IF EXISTS course_prerequisites_select ON public.course_prerequisites;
CREATE POLICY course_prerequisites_select ON public.course_prerequisites FOR SELECT TO authenticated USING (TRUE);

DROP POLICY IF EXISTS students_select ON public.students;
CREATE POLICY students_select ON public.students FOR SELECT TO authenticated
  USING (profile_id = auth.uid() OR public.has_permission('students.read'));

DROP POLICY IF EXISTS course_registrations_select ON public.course_registrations;
CREATE POLICY course_registrations_select ON public.course_registrations FOR SELECT TO authenticated
  USING (public.is_student_owner(student_id) OR public.has_permission('students.read'));

DROP POLICY IF EXISTS student_charges_select ON public.student_charges;
CREATE POLICY student_charges_select ON public.student_charges FOR SELECT TO authenticated
  USING (public.is_student_owner(student_id) OR public.has_permission('finance.read'));

DROP POLICY IF EXISTS payments_select ON public.payments;
CREATE POLICY payments_select ON public.payments FOR SELECT TO authenticated
  USING (public.is_student_owner(student_id) OR public.has_permission('finance.read'));

DROP POLICY IF EXISTS final_results_select ON public.final_results;
CREATE POLICY final_results_select ON public.final_results FOR SELECT TO authenticated
  USING ((public.is_student_owner(student_id) AND workflow_status = 'published') OR public.has_permission('grades.submit') OR public.has_permission('grades.approve') OR public.has_role('super_admin'));

DROP POLICY IF EXISTS notifications_select ON public.notifications;
CREATE POLICY notifications_select ON public.notifications FOR SELECT TO authenticated USING (profile_id = auth.uid());

DROP POLICY IF EXISTS announcements_select ON public.announcements;
CREATE POLICY announcements_select ON public.announcements FOR SELECT TO authenticated
  USING (published_at IS NOT NULL AND published_at <= NOW());

GRANT USAGE ON SCHEMA public TO authenticated;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO authenticated;

-- ---------------------------------------------------------------------------
-- 10. Foundational Academic Seed Data
-- ---------------------------------------------------------------------------

INSERT INTO public.fee_categories (code, name, description) VALUES
  ('tuition', 'Tuition', 'Semester tuition'),
  ('registration', 'Registration', 'Course registration fee')
ON CONFLICT (code) DO NOTHING;

INSERT INTO public.departments (id, code, name, is_active) VALUES
  ('11111111-1111-1111-1111-111111111101', 'CS',  'Computer Science & IT', TRUE),
  ('11111111-1111-1111-1111-111111111102', 'BA',  'Business Administration', TRUE),
  ('11111111-1111-1111-1111-111111111103', 'ENG', 'Software & Systems Engineering', TRUE)
ON CONFLICT (code) DO NOTHING;

INSERT INTO public.programs (id, department_id, code, name, duration_semesters, is_active) VALUES
  ('22222222-2222-2222-2222-222222222201', '11111111-1111-1111-1111-111111111101', 'BSC-CS',  'B.Sc. Computer Science', 6, TRUE),
  ('22222222-2222-2222-2222-222222222202', '11111111-1111-1111-1111-111111111102', 'BBA',     'Bachelor of Business Administration', 6, TRUE),
  ('22222222-2222-2222-2222-222222222203', '11111111-1111-1111-1111-111111111103', 'BENG-SE', 'B.Eng. Software Engineering', 8, TRUE)
ON CONFLICT (code) DO NOTHING;

INSERT INTO public.academic_years (id, label, starts_on, ends_on, is_current) VALUES
  ('33333333-3333-3333-3333-333333333301', '2026/2027', '2026-09-01', '2027-06-30', TRUE)
ON CONFLICT (label) DO NOTHING;

INSERT INTO public.semesters (
  id, academic_year_id, term_number, label, starts_on, ends_on,
  registration_opens_at, registration_closes_at, is_current
) VALUES
  ('44444444-4444-4444-4444-444444444401', '33333333-3333-3333-3333-333333333301', 1, 'First Semester 2026/2027', '2026-09-01', '2027-01-31', NOW() - INTERVAL '30 days', NOW() + INTERVAL '60 days', TRUE),
  ('44444444-4444-4444-4444-444444444402', '33333333-3333-3333-3333-333333333301', 2, 'Second Semester 2026/2027', '2027-02-01', '2027-06-30', NULL, NULL, FALSE)
ON CONFLICT (academic_year_id, term_number) DO NOTHING;

INSERT INTO public.cohorts (id, program_id, intake_year, label) VALUES
  ('55555555-5555-5555-5555-555555555501', '22222222-2222-2222-2222-222222222201', 2026, 'BSC-CS 2026 Intake'),
  ('55555555-5555-5555-5555-555555555502', '22222222-2222-2222-2222-222222222202', 2026, 'BBA 2026 Intake'),
  ('55555555-5555-5555-5555-555555555503', '22222222-2222-2222-2222-222222222203', 2026, 'BENG-SE 2026 Intake')
ON CONFLICT (program_id, intake_year) DO NOTHING;

INSERT INTO public.courses (id, department_id, code, title, credit_units, level, is_active) VALUES
  ('66666666-6666-6666-6666-666666666601', '11111111-1111-1111-1111-111111111101', 'CS101',   'Introduction to Programming', 4, 100, TRUE),
  ('66666666-6666-6666-6666-666666666602', '11111111-1111-1111-1111-111111111101', 'CS102',   'Data Structures & Algorithms', 4, 100, TRUE),
  ('66666666-6666-6666-6666-666666666603', '11111111-1111-1111-1111-111111111101', 'CS103',   'Database Management Systems', 3, 100, TRUE),
  ('66666666-6666-6666-6666-666666666604', '11111111-1111-1111-1111-111111111103', 'SE101',   'Software Engineering Principles', 3, 100, TRUE),
  ('66666666-6666-6666-6666-666666666605', '11111111-1111-1111-1111-111111111102', 'BA101',   'Principles of Management', 3, 100, TRUE)
ON CONFLICT (code) DO NOTHING;

INSERT INTO public.course_offerings (id, course_id, semester_id, cohort_id, capacity, is_open_for_registration) VALUES
  ('77777777-7777-7777-7777-777777777701', '66666666-6666-6666-6666-666666666601', '44444444-4444-4444-4444-444444444401', NULL, 60, TRUE),
  ('77777777-7777-7777-7777-777777777702', '66666666-6666-6666-6666-666666666602', '44444444-4444-4444-4444-444444444401', NULL, 60, TRUE),
  ('77777777-7777-7777-7777-777777777703', '66666666-6666-6666-6666-666666666603', '44444444-4444-4444-4444-444444444401', NULL, 50, TRUE),
  ('77777777-7777-7777-7777-777777777704', '66666666-6666-6666-6666-666666666604', '44444444-4444-4444-4444-444444444401', NULL, 50, TRUE),
  ('77777777-7777-7777-7777-777777777705', '66666666-6666-6666-6666-666666666605', '44444444-4444-4444-4444-444444444401', NULL, 80, TRUE)
ON CONFLICT (course_id, semester_id, cohort_id) DO NOTHING;

-- ---------------------------------------------------------------------------
-- 11. Link info@liahacademy.com Admin Account
-- ---------------------------------------------------------------------------

INSERT INTO public.profiles (id, email, full_name, is_active)
SELECT id, email, 'Liah Academy Admin', TRUE
FROM auth.users
WHERE email = 'info@liahacademy.com'
ON CONFLICT (id) DO UPDATE SET full_name = 'Liah Academy Admin';

INSERT INTO public.profile_roles (profile_id, role_id)
SELECT u.id, r.id
FROM auth.users u
CROSS JOIN public.roles r
WHERE u.email = 'info@liahacademy.com' AND r.code = 'super_admin'
ON CONFLICT DO NOTHING;
