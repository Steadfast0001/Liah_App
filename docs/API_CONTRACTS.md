# Edge Function API Contracts

All protected functions require:
- **Method:** `POST`
- **Headers:** `Authorization: Bearer <access_token>`, `Content-Type: application/json`

---

## 1. `admin-create-student` (Implemented)

Creates a Supabase Auth user (`email_confirm: true`), upserts `public.profiles`, assigns the `student` role in `public.profile_roles`, generates an official matricule (`LA-<YEAR>-<PROG>-<SEQ>`), creates the `public.students` record, enrolls the student in the current semester if one exists, and writes to `public.audit_logs`.

- **Required Permission:** `users.manage` or `students.write`
- **Request Body:**
  ```json
  {
    "email": "student@liahacademy.ac",
    "full_name": "Amina Ndongo",
    "program_id": "22222222-2222-2222-2222-222222222201",
    "cohort_id": "55555555-5555-5555-5555-555555555501",
    "phone": "+237600000000",
    "password": "OptionalInitialPassword123!"
  }
  ```
- **Response (`201 Created`):**
  ```json
  {
    "student_id": "uuid",
    "matricule": "LA-2026-BSCCS-0001",
    "profile_id": "uuid",
    "temporary_password": "string"
  }
  ```

---

## 2. `get-semester-access` (Implemented)

Checks whether the current student can register for courses and view results in the specified (or current) semester based on registration dates and `student_charges` status.

- **Request Body:** `{ "semester_id": "uuid (optional, defaults to current)" }`
- **Response (`200 OK`):**
  ```json
  {
    "semester_id": "uuid",
    "can_register": true,
    "can_view_results": true,
    "fee_status": "cleared | partial | pending | overdue",
    "messages": []
  }
  ```

---

## 3. `register-course` / `drop-course` (Implemented)

Registers or drops a course offering for a student within an active semester. Enforces `is_open_for_registration` and offering `capacity`.

- **Required Permission:** `registration.manage` (student) or `academics.manage` (staff override)
- **Request Body:**
  ```json
  {
    "course_offering_id": "uuid",
    "semester_id": "uuid",
    "student_id": "uuid (optional, defaults to authenticated student)"
  }
  ```
- **Response (`200 OK`):**
  ```json
  {
    "registration_id": "uuid",
    "status": "registered | dropped"
  }
  ```

---

## 4. Upcoming Phase Contracts (Stubs returning `501`)

### `create-payment-intent` / `verify-payment`
- **Intent Body:** `{ "semester_id", "amount_xaf", "provider": "mtn_momo" | "orange_money" }`
- **Intent Response:** `{ "payment_id", "external_reference", "status" }`
- **Verify Body:** `{ "payment_id" }`

### Result Workflow
- `submit-course-grades` → `{ "course_offering_id" }`
- `approve-results` → `{ "semester_id" | "course_offering_id" }`
- `finalize-results` → `{ "semester_id" }` (`grades.finalize` / `super_admin`)
- `publish-results` → `{ "semester_id" }` (`grades.publish`)

### `generate-transcript`
- **Body:** `{ "student_id" }`
- **Response:** `{ "document_id", "signed_url" }`
