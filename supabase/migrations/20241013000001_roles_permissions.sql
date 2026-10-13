-- Roles, permissions, and profile role assignments

CREATE TABLE public.roles (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  code TEXT NOT NULL UNIQUE,
  name TEXT NOT NULL,
  description TEXT,
  is_system BOOLEAN NOT NULL DEFAULT FALSE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE public.permissions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  code TEXT NOT NULL UNIQUE,
  name TEXT NOT NULL,
  description TEXT,
  domain TEXT NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE public.role_permissions (
  role_id UUID NOT NULL REFERENCES public.roles (id) ON DELETE CASCADE,
  permission_id UUID NOT NULL REFERENCES public.permissions (id) ON DELETE CASCADE,
  PRIMARY KEY (role_id, permission_id)
);

CREATE TABLE public.profile_roles (
  profile_id UUID NOT NULL REFERENCES public.profiles (id) ON DELETE CASCADE,
  role_id UUID NOT NULL REFERENCES public.roles (id) ON DELETE CASCADE,
  assigned_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  assigned_by UUID REFERENCES public.profiles (id),
  PRIMARY KEY (profile_id, role_id)
);

-- Seed system roles
INSERT INTO public.roles (code, name, description, is_system) VALUES
  ('super_admin', 'Super Admin', 'Full system control via privileged functions', TRUE),
  ('admin', 'Administrator', 'Admissions, students, finance review, result approval', TRUE),
  ('lecturer', 'Lecturer', 'Assigned courses, grades, attendance', TRUE),
  ('student', 'Student', 'Registration, fees, results, transcripts', TRUE);

-- Seed permissions (expand as features land)
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
  ('audit.read', 'View audit log', 'audit', 'Read audit trail');

-- Role → permission matrix (minimal MVP)
INSERT INTO public.role_permissions (role_id, permission_id)
SELECT r.id, p.id
FROM public.roles r
CROSS JOIN public.permissions p
WHERE r.code = 'super_admin';

INSERT INTO public.role_permissions (role_id, permission_id)
SELECT r.id, p.id
FROM public.roles r
JOIN public.permissions p ON p.code IN (
  'students.read', 'students.write', 'academics.manage',
  'grades.approve', 'finance.read', 'finance.verify'
)
WHERE r.code = 'admin';

INSERT INTO public.role_permissions (role_id, permission_id)
SELECT r.id, p.id
FROM public.roles r
JOIN public.permissions p ON p.code IN ('grades.submit', 'students.read')
WHERE r.code = 'lecturer';

INSERT INTO public.role_permissions (role_id, permission_id)
SELECT r.id, p.id
FROM public.roles r
JOIN public.permissions p ON p.code IN (
  'registration.manage', 'finance.read', 'students.read'
)
WHERE r.code = 'student';
