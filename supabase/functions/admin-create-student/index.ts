import { requirePermission } from "../_shared/auth.ts";
import { serveProtected } from "../_shared/handler.ts";
import { errorResponse, json } from "../_shared/response.ts";

interface CreateStudentPayload {
  email?: string;
  full_name?: string;
  program_id?: string;
  cohort_id?: string | null;
  phone?: string | null;
  password?: string;
}

serveProtected("admin-create-student", async (req, { userId, service }) => {
  const canManageUsers = await requirePermission(service, userId, "users.manage");
  const canWriteStudents = canManageUsers ||
    await requirePermission(service, userId, "students.write");

  if (!canWriteStudents) {
    return errorResponse("Permission denied", 403, "forbidden");
  }

  let body: CreateStudentPayload;
  try {
    body = await req.json();
  } catch {
    return errorResponse("Invalid JSON payload", 400, "invalid_json");
  }

  const email = body.email?.trim().toLowerCase();
  const fullName = body.full_name?.trim();
  const programId = body.program_id?.trim();
  const cohortId = body.cohort_id?.trim() || null;
  const phone = body.phone?.trim() || null;

  if (!email || !email.includes("@")) {
    return errorResponse("Valid email is required", 400, "invalid_email");
  }
  if (!fullName) {
    return errorResponse("full_name is required", 400, "missing_full_name");
  }
  if (!programId) {
    return errorResponse("program_id is required", 400, "missing_program_id");
  }

  // 1. Validate program exists
  const { data: program, error: programErr } = await service
    .from("programs")
    .select("id, code, is_active")
    .eq("id", programId)
    .maybeSingle();

  if (programErr || !program) {
    return errorResponse("Program not found", 404, "program_not_found");
  }

  // 2. Resolve intake year from cohort (if provided) or current year
  let intakeYear = new Date().getFullYear();
  if (cohortId) {
    const { data: cohort } = await service
      .from("cohorts")
      .select("id, intake_year")
      .eq("id", cohortId)
      .maybeSingle();
    if (cohort?.intake_year) {
      intakeYear = cohort.intake_year;
    }
  }

  // 3. Create Supabase Auth user
  const tempPassword = body.password?.trim() ||
    `Liah@${Math.random().toString(36).slice(-6)}${Math.floor(10 + Math.random() * 89)}`;

  const { data: createdAuth, error: authErr } = await service.auth.admin.createUser({
    email,
    password: tempPassword,
    email_confirm: true,
    user_metadata: {
      full_name: fullName,
      phone,
      role: "student",
    },
  });

  if (authErr || !createdAuth.user) {
    return errorResponse(
      authErr?.message ?? "Failed to create auth user",
      400,
      "auth_create_failed",
    );
  }

  const profileId = createdAuth.user.id;

  // 4. Upsert profile (in case trigger hasn't run or needs explicit fields)
  const { error: profileErr } = await service.from("profiles").upsert({
    id: profileId,
    email,
    full_name: fullName,
    phone,
    is_active: true,
  });

  if (profileErr) {
    return errorResponse(profileErr.message, 500, "profile_upsert_failed");
  }

  // 5. Assign 'student' role in profile_roles
  const { data: studentRole } = await service
    .from("roles")
    .select("id")
    .eq("code", "student")
    .maybeSingle();

  if (studentRole?.id) {
    await service.from("profile_roles").upsert({
      profile_id: profileId,
      role_id: studentRole.id,
      assigned_by: userId,
    });
  }

  // 6. Generate matricule
  let matricule = `LA-${intakeYear}-${program.code}-${Math.floor(1000 + Math.random() * 9000)}`;
  const { data: rpcMatricule } = await service.rpc("generate_student_matricule", {
    p_program_code: program.code,
    p_intake_year: intakeYear,
  });
  if (typeof rpcMatricule === "string" && rpcMatricule.length > 0) {
    matricule = rpcMatricule;
  }

  // 7. Insert student record
  const { data: studentRow, error: studentErr } = await service
    .from("students")
    .insert({
      profile_id: profileId,
      matricule,
      program_id: programId,
      cohort_id: cohortId,
      status: "active",
    })
    .select("id, matricule, profile_id")
    .single();

  if (studentErr || !studentRow) {
    return errorResponse(
      studentErr?.message ?? "Failed to create student record",
      500,
      "student_insert_failed",
    );
  }

  // 8. Enroll in current semester if one exists
  const { data: currentSemester } = await service
    .from("semesters")
    .select("id")
    .eq("is_current", true)
    .maybeSingle();

  if (currentSemester?.id) {
    await service.from("student_enrollments").upsert({
      student_id: studentRow.id,
      semester_id: currentSemester.id,
      enrollment_status: "enrolled",
    });
  }

  // 9. Audit log
  await service.from("audit_logs").insert({
    actor_profile_id: userId,
    action: "student.created",
    entity_type: "students",
    entity_id: studentRow.id,
    details: {
      matricule: studentRow.matricule,
      email,
      program_id: programId,
      cohort_id: cohortId,
    },
  });

  return json({
    student_id: studentRow.id,
    matricule: studentRow.matricule,
    profile_id: studentRow.profile_id,
    temporary_password: tempPassword,
  }, 201);
});
