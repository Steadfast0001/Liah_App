# Data Model — Liah Academy SMS

Source of truth: `supabase/migrations/20241013000000_initial_schema.sql`.

## Domains

| Domain | Tables |
|--------|--------|
| Identity & access | `profiles`, `roles`, `permissions`, `role_permissions`, `profile_roles`, `audit_logs` |
| Academic | `departments`, `programs`, `academic_years`, `semesters`, `cohorts`, `courses`, `course_offerings`, `course_prerequisites` |
| People | `students`, `staff`, `guardians`, `student_guardians`, `staff_assignments` |
| Registration & results | `student_enrollments`, `course_registrations`, `assessment_configs`, `assessment_scores`, `final_results`, `resit_attempts` |
| Finance | `fee_categories`, `fee_structures`, `semester_fee_rules`, `student_charges`, `payments`, `payment_events` |
| Documents & comms | `stored_documents`, `announcements`, `notifications` |

## Conventions

- Primary keys: UUID (`gen_random_uuid()`).
- Money: integer `*_xaf` (Central African CFA, no decimals).
- Matricule: unique on `students.matricule`, display-only in the app.
- Result visibility: students only see `final_results` where `workflow_status = 'published'`.
