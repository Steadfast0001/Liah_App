# Open Policies & Decision Register

## 1. Server-Enforced Privileged Operations

Operations that **must never** be executed directly from the Flutter client:

- Creating student or staff Auth accounts (`admin-create-student`, `admin-create-staff`)
- Changing a student's login email (`super-admin-change-student-email`)
- Course registration and drop (`register-course`, `drop-course` — enforces capacity, window, and fee rules)
- Grade submission, approval, finalization, and publication (`submit-course-grades`, `approve-results`, `finalize-results`, `publish-results`)
- Mobile money payment intent creation and verification (`create-payment-intent`, `verify-payment`, webhooks)
- Official transcript PDF generation and private storage upload (`generate-transcript`)
- System role assignment (`super_admin` only)

All privileged writes run inside **Supabase Edge Functions** using the service role after explicit permission verification (`user_has_permission`) and write an immutable entry to `public.audit_logs`.

## 2. Client-Open Operations (RLS-Protected)

- Read own `profiles` row, `profile_roles`, `notifications`, and published `announcements`
- Read own `students` record, `course_registrations`, `student_charges`, `payments`, and `published` `final_results`
- Read academic reference tables (`departments`, `programs`, `academic_years`, `semesters`, `cohorts`, `courses`, `course_offerings`)
- Sign in, sign out, and password recovery via Supabase Auth (`enable_signup = false` in `supabase/config.toml`)

## 3. Open Policy Decisions Register

| ID | Topic | Current Default / MVP Rule | Status |
|----|-------|----------------------------|--------|
| `POL-01` | Minimum fee threshold for course registration | Allowed unless student has `overdue` charges in the semester (`get-semester-access`) | Configurable per semester |
| `POL-02` | Maximum credit units per semester | Tracked in UI; hard cap (e.g., 24–30 credits) can be enforced in `register-course` | Open |
| `POL-03` | Grading scale & GPA calculation | 4.00 scale (`grade_letter`, `grade_point` on `final_results`) | Pending academic board table |
| `POL-04` | Resit exam eligibility & score replacement | Tracked in `resit_attempts` linked to `final_results` | Open |
