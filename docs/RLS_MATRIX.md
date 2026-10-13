# RLS Matrix (MVP)

Default: **RLS enabled, deny by default** on all public tables.

## Helpers

| Function | Purpose |
|----------|---------|
| `has_role(text)` | Current user role check |
| `has_permission(text)` | Current user permission check |
| `is_student_owner(uuid)` | Row belongs to current student |
| `current_student_id()` | Resolve student id for auth user |
| `user_has_permission(uuid, text)` | Edge Functions (service role) |

## Policies (initial)

| Table | SELECT | INSERT/UPDATE/DELETE |
|-------|--------|----------------------|
| `profiles` | Self + `students.read` | Self update only |
| `students` | Owner + `students.read` | Edge Functions |
| `course_registrations` | Owner + staff read | Edge Functions |
| `final_results` | Student if published; staff with grade perms | Edge Functions |
| `student_charges`, `payments` | Owner + `finance.read` | Edge Functions |
| `notifications` | Own | Own mark read |
| `announcements` | Published | Admin functions |
| Reference (`departments`, `programs`, …) | Authenticated read | Admin / super admin |

Expand this document as policies are added per table.
