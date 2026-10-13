import { requirePermission } from "../_shared/auth.ts";
import { serveProtected } from "../_shared/handler.ts";
import { errorResponse, json } from "../_shared/response.ts";

interface RegisterCoursePayload {
  course_offering_id?: string;
  semester_id?: string;
  student_id?: string;
}

serveProtected("register-course", async (req, { userId, service }) => {
  const hasPerm = await requirePermission(service, userId, "registration.manage") ||
    await requirePermission(service, userId, "academics.manage");

  if (!hasPerm) {
    return errorResponse("Permission denied", 403, "forbidden");
  }

  let body: RegisterCoursePayload;
  try {
    body = await req.json();
  } catch {
    return errorResponse("Invalid JSON payload", 400, "invalid_json");
  }

  const courseOfferingId = body.course_offering_id?.trim();
  const semesterId = body.semester_id?.trim();

  if (!courseOfferingId || !semesterId) {
    return errorResponse(
      "course_offering_id and semester_id are required",
      400,
      "missing_fields",
    );
  }

  // Resolve student_id (either current student or staff override)
  let studentId = body.student_id?.trim();
  if (!studentId) {
    const { data: student } = await service
      .from("students")
      .select("id, status")
      .eq("profile_id", userId)
      .maybeSingle();

    if (!student) {
      return errorResponse("Student record not found for current user", 404, "student_not_found");
    }
    if (student.status !== "active") {
      return errorResponse("Only active students can register courses", 403, "student_inactive");
    }
    studentId = student.id;
  }

  // Verify offering exists and belongs to the semester
  const { data: offering, error: offErr } = await service
    .from("course_offerings")
    .select("id, course_id, semester_id, capacity, is_open_for_registration")
    .eq("id", courseOfferingId)
    .maybeSingle();

  if (offErr || !offering) {
    return errorResponse("Course offering not found", 404, "offering_not_found");
  }

  if (offering.semester_id !== semesterId) {
    return errorResponse("Course offering does not belong to the specified semester", 400, "semester_mismatch");
  }

  if (!offering.is_open_for_registration) {
    return errorResponse("Course offering is closed for registration", 400, "offering_closed");
  }

  // Check capacity if set
  if (offering.capacity !== null && offering.capacity > 0) {
    const { count } = await service
      .from("course_registrations")
      .select("id", { count: "exact", head: true })
      .eq("course_offering_id", courseOfferingId)
      .eq("status", "registered");

    if ((count ?? 0) >= offering.capacity) {
      return errorResponse("Course offering has reached full capacity", 409, "capacity_full");
    }
  }

  // Upsert registration (re-activating if previously dropped)
  const { data: registration, error: regErr } = await service
    .from("course_registrations")
    .upsert(
      {
        student_id: studentId,
        course_offering_id: courseOfferingId,
        semester_id: semesterId,
        status: "registered",
        registered_at: new Date().toISOString(),
        dropped_at: null,
      },
      { onConflict: "student_id,course_offering_id" },
    )
    .select("id, status")
    .single();

  if (regErr || !registration) {
    return errorResponse(
      regErr?.message ?? "Failed to register course",
      500,
      "registration_failed",
    );
  }

  await service.from("audit_logs").insert({
    actor_profile_id: userId,
    action: "course.registered",
    entity_type: "course_registrations",
    entity_id: registration.id,
    details: {
      student_id: studentId,
      course_offering_id: courseOfferingId,
      semester_id: semesterId,
    },
  });

  return json({
    registration_id: registration.id,
    status: registration.status,
  });
});
