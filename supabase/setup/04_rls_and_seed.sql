-- =============================================================================
-- STEP 4: Row-Level Security, Seed Data & Admin Account Link
-- Run this fourth in Supabase SQL Editor:
-- https://supabase.com/dashboard/project/nqdlptrodovwbtqabxyu/sql/new
-- =============================================================================

-- Guarantee all enum columns exist (in case custom types were dropped with CASCADE in earlier runs)
ALTER TABLE public.course_registrations ADD COLUMN IF NOT EXISTS status public.course_registration_status NOT NULL DEFAULT 'registered';
ALTER TABLE public.final_results ADD COLUMN IF NOT EXISTS workflow_status public.result_workflow_status NOT NULL DEFAULT 'draft';
ALTER TABLE public.student_charges ADD COLUMN IF NOT EXISTS status public.charge_status NOT NULL DEFAULT 'pending';
ALTER TABLE public.payments ADD COLUMN IF NOT EXISTS provider public.payment_provider NOT NULL DEFAULT 'cash';
ALTER TABLE public.payments ADD COLUMN IF NOT EXISTS status public.payment_status NOT NULL DEFAULT 'pending';

-- 1. Enable RLS on all public tables
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

-- 2. Policies
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

-- 3. Foundational Academic Seed Data
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

-- 4. Link info@liahacademy.com as Super Admin
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
