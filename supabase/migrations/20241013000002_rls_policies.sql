-- RLS: default deny + permission helpers

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

CREATE OR REPLACE FUNCTION public.has_role(role_code TEXT)
RETURNS BOOLEAN
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
  SELECT EXISTS (
    SELECT 1
    FROM public.profile_roles pr
    JOIN public.roles r ON r.id = pr.role_id
    WHERE pr.profile_id = auth.uid()
      AND r.code = role_code
  );
$$;

CREATE OR REPLACE FUNCTION public.has_permission(permission_code TEXT)
RETURNS BOOLEAN
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
  SELECT EXISTS (
    SELECT 1
    FROM public.profile_roles pr
    JOIN public.role_permissions rp ON rp.role_id = pr.role_id
    JOIN public.permissions p ON p.id = rp.permission_id
    WHERE pr.profile_id = auth.uid()
      AND p.code = permission_code
  );
$$;

CREATE OR REPLACE FUNCTION public.is_student_owner(student_row_id UUID)
RETURNS BOOLEAN
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
  SELECT EXISTS (
    SELECT 1
    FROM public.students s
    WHERE s.id = student_row_id
      AND s.profile_id = auth.uid()
  );
$$;

CREATE OR REPLACE FUNCTION public.current_student_id()
RETURNS UUID
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
  SELECT s.id
  FROM public.students s
  WHERE s.profile_id = auth.uid()
  LIMIT 1;
$$;

-- Profiles: self read/update; staff with students.read can read all
CREATE POLICY profiles_select_self ON public.profiles
  FOR SELECT TO authenticated
  USING (
    id = auth.uid()
    OR public.has_permission('students.read')
    OR public.has_role('super_admin')
  );

CREATE POLICY profiles_update_self ON public.profiles
  FOR UPDATE TO authenticated
  USING (id = auth.uid())
  WITH CHECK (id = auth.uid());

-- Students: owner or staff read
CREATE POLICY students_select ON public.students
  FOR SELECT TO authenticated
  USING (
    profile_id = auth.uid()
    OR public.has_permission('students.read')
  );

-- Course registrations: owner read; writes via Edge Functions (no insert/update policies)

CREATE POLICY course_registrations_select ON public.course_registrations
  FOR SELECT TO authenticated
  USING (
    public.is_student_owner(student_id)
    OR public.has_permission('students.read')
  );

-- Final results: students see published only; staff per permission
CREATE POLICY final_results_select ON public.final_results
  FOR SELECT TO authenticated
  USING (
    (
      public.is_student_owner(student_id)
      AND workflow_status = 'published'
    )
    OR public.has_permission('grades.submit')
    OR public.has_permission('grades.approve')
    OR public.has_role('super_admin')
  );

-- Notifications: own only
CREATE POLICY notifications_select_own ON public.notifications
  FOR SELECT TO authenticated
  USING (profile_id = auth.uid());

CREATE POLICY notifications_update_own ON public.notifications
  FOR UPDATE TO authenticated
  USING (profile_id = auth.uid())
  WITH CHECK (profile_id = auth.uid());

-- Announcements: authenticated read published
CREATE POLICY announcements_select ON public.announcements
  FOR SELECT TO authenticated
  USING (published_at IS NOT NULL AND published_at <= NOW());

-- Finance: student sees own charges/payments
CREATE POLICY student_charges_select ON public.student_charges
  FOR SELECT TO authenticated
  USING (
    public.is_student_owner(student_id)
    OR public.has_permission('finance.read')
  );

CREATE POLICY payments_select ON public.payments
  FOR SELECT TO authenticated
  USING (
    public.is_student_owner(student_id)
    OR public.has_permission('finance.read')
  );

-- Reference data: read for authenticated (writes via admin/super_admin functions later)
CREATE POLICY departments_select ON public.departments
  FOR SELECT TO authenticated USING (TRUE);

CREATE POLICY programs_select ON public.programs
  FOR SELECT TO authenticated USING (TRUE);

CREATE POLICY semesters_select ON public.semesters
  FOR SELECT TO authenticated USING (TRUE);

CREATE POLICY courses_select ON public.courses
  FOR SELECT TO authenticated USING (TRUE);

CREATE POLICY course_offerings_select ON public.course_offerings
  FOR SELECT TO authenticated USING (TRUE);

-- Roles/permissions: read own assignments
CREATE POLICY profile_roles_select_own ON public.profile_roles
  FOR SELECT TO authenticated
  USING (profile_id = auth.uid() OR public.has_role('super_admin'));

CREATE POLICY roles_select ON public.roles
  FOR SELECT TO authenticated
  USING (public.has_role('super_admin') OR public.has_role('admin'));

CREATE POLICY permissions_select ON public.permissions
  FOR SELECT TO authenticated
  USING (public.has_role('super_admin'));

GRANT USAGE ON SCHEMA public TO authenticated;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO authenticated;
