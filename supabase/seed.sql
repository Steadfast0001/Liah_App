-- =============================================================================
-- Liah Academy SMS — Idempotent Seed Data (`supabase db reset`)
-- Includes roles, permissions, role_permissions, fee categories, and
-- foundational academic reference records for local development.
-- =============================================================================

-- 1. System Roles
INSERT INTO public.roles (code, name, description, is_system) VALUES
  ('super_admin', 'Super Admin', 'Full system control via privileged functions', TRUE),
  ('admin', 'Administrator', 'Admissions, students, finance review, result approval', TRUE),
  ('lecturer', 'Lecturer', 'Assigned courses, grades, attendance', TRUE),
  ('student', 'Student', 'Registration, fees, results, transcripts', TRUE)
ON CONFLICT (code) DO NOTHING;

-- 2. Permissions
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

-- 3. Role → Permission Matrix
INSERT INTO public.role_permissions (role_id, permission_id)
SELECT r.id, p.id
FROM public.roles r
CROSS JOIN public.permissions p
WHERE r.code = 'super_admin'
ON CONFLICT DO NOTHING;

INSERT INTO public.role_permissions (role_id, permission_id)
SELECT r.id, p.id
FROM public.roles r
JOIN public.permissions p ON p.code IN (
  'users.manage', 'students.read', 'students.write', 'academics.manage',
  'grades.approve', 'finance.read', 'finance.verify'
)
WHERE r.code = 'admin'
ON CONFLICT DO NOTHING;

INSERT INTO public.role_permissions (role_id, permission_id)
SELECT r.id, p.id
FROM public.roles r
JOIN public.permissions p ON p.code IN ('grades.submit', 'students.read')
WHERE r.code = 'lecturer'
ON CONFLICT DO NOTHING;

INSERT INTO public.role_permissions (role_id, permission_id)
SELECT r.id, p.id
FROM public.roles r
JOIN public.permissions p ON p.code IN (
  'registration.manage', 'finance.read', 'students.read'
)
WHERE r.code = 'student'
ON CONFLICT DO NOTHING;

-- 4. Fee Categories
INSERT INTO public.fee_categories (code, name, description) VALUES
  ('tuition', 'Tuition', 'Semester tuition'),
  ('registration', 'Registration', 'Course registration fee')
ON CONFLICT (code) DO NOTHING;

-- 5. Departments
INSERT INTO public.departments (id, code, name, is_active) VALUES
  ('11111111-1111-1111-1111-111111111101', 'CS',  'Computer Science & IT', TRUE),
  ('11111111-1111-1111-1111-111111111102', 'BA',  'Business Administration', TRUE),
  ('11111111-1111-1111-1111-111111111103', 'ENG', 'Software & Systems Engineering', TRUE)
ON CONFLICT (code) DO NOTHING;

-- 6. Programs
INSERT INTO public.programs (id, department_id, code, name, duration_semesters, is_active) VALUES
  ('22222222-2222-2222-2222-222222222201', '11111111-1111-1111-1111-111111111101', 'BSC-CS',  'B.Sc. Computer Science', 6, TRUE),
  ('22222222-2222-2222-2222-222222222202', '11111111-1111-1111-1111-111111111102', 'BBA',     'Bachelor of Business Administration', 6, TRUE),
  ('22222222-2222-2222-2222-222222222203', '11111111-1111-1111-1111-111111111103', 'BENG-SE', 'B.Eng. Software Engineering', 8, TRUE)
ON CONFLICT (code) DO NOTHING;

-- 7. Academic Year & Semesters
INSERT INTO public.academic_years (id, label, starts_on, ends_on, is_current) VALUES
  ('33333333-3333-3333-3333-333333333301', '2026/2027', '2026-09-01', '2027-06-30', TRUE)
ON CONFLICT (label) DO NOTHING;

INSERT INTO public.semesters (
  id, academic_year_id, term_number, label, starts_on, ends_on,
  registration_opens_at, registration_closes_at, is_current
) VALUES
  (
    '44444444-4444-4444-4444-444444444401',
    '33333333-3333-3333-3333-333333333301',
    1,
    'First Semester 2026/2027',
    '2026-09-01',
    '2027-01-31',
    NOW() - INTERVAL '30 days',
    NOW() + INTERVAL '60 days',
    TRUE
  ),
  (
    '44444444-4444-4444-4444-444444444402',
    '33333333-3333-3333-3333-333333333301',
    2,
    'Second Semester 2026/2027',
    '2027-02-01',
    '2027-06-30',
    NULL,
    NULL,
    FALSE
  )
ON CONFLICT (academic_year_id, term_number) DO NOTHING;

-- 8. Cohorts
INSERT INTO public.cohorts (id, program_id, intake_year, label) VALUES
  ('55555555-5555-5555-5555-555555555501', '22222222-2222-2222-2222-222222222201', 2026, 'BSC-CS 2026 Intake'),
  ('55555555-5555-5555-5555-555555555502', '22222222-2222-2222-2222-222222222202', 2026, 'BBA 2026 Intake'),
  ('55555555-5555-5555-5555-555555555503', '22222222-2222-2222-2222-222222222203', 2026, 'BENG-SE 2026 Intake')
ON CONFLICT (program_id, intake_year) DO NOTHING;

-- 9. Courses
INSERT INTO public.courses (id, department_id, code, title, credit_units, level, is_active) VALUES
  ('66666666-6666-6666-6666-666666666601', '11111111-1111-1111-1111-111111111101', 'CS101',   'Introduction to Programming', 4, 100, TRUE),
  ('66666666-6666-6666-6666-666666666602', '11111111-1111-1111-1111-111111111101', 'CS102',   'Data Structures & Algorithms', 4, 100, TRUE),
  ('66666666-6666-6666-6666-666666666603', '11111111-1111-1111-1111-111111111101', 'CS103',   'Database Management Systems', 3, 100, TRUE),
  ('66666666-6666-6666-6666-666666666604', '11111111-1111-1111-1111-111111111103', 'SE101',   'Software Engineering Principles', 3, 100, TRUE),
  ('66666666-6666-6666-6666-666666666605', '11111111-1111-1111-1111-111111111102', 'BA101',   'Principles of Management', 3, 100, TRUE)
ON CONFLICT (code) DO NOTHING;

-- 10. Course Offerings (First Semester 2026/2027)
INSERT INTO public.course_offerings (
  id, course_id, semester_id, cohort_id, capacity, is_open_for_registration
) VALUES
  ('77777777-7777-7777-7777-777777777701', '66666666-6666-6666-6666-666666666601', '44444444-4444-4444-4444-444444444401', NULL, 60, TRUE),
  ('77777777-7777-7777-7777-777777777702', '66666666-6666-6666-6666-666666666602', '44444444-4444-4444-4444-444444444401', NULL, 60, TRUE),
  ('77777777-7777-7777-7777-777777777703', '66666666-6666-6666-6666-666666666603', '44444444-4444-4444-4444-444444444401', NULL, 50, TRUE),
  ('77777777-7777-7777-7777-777777777704', '66666666-6666-6666-6666-666666666604', '44444444-4444-4444-4444-444444444401', NULL, 50, TRUE),
  ('77777777-7777-7777-7777-777777777705', '66666666-6666-6666-6666-666666666605', '44444444-4444-4444-4444-444444444401', NULL, 80, TRUE)
ON CONFLICT (course_id, semester_id, cohort_id) DO NOTHING;
