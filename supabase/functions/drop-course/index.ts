import { requirePermission } from "../_shared/auth.ts";
import { serveProtected } from "../_shared/handler.ts";
import { errorResponse, json } from "../_shared/response.ts";

interface DropCoursePayload {
  course_offering_id?: string;
  semester_id?: string;
  student_id?: string;
}

serveProtected("drop-course", async (req, { userId, service }) => {
  const hasPerm = await requirePermission(service, userId, "registration.manage") ||
    await requirePermission(service, userId, "academics.manage");

  if (!hasPerm) {
    return errorResponse("Permission denied", 403, "forbidden");
  }

  let body: DropCoursePayload;
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

  let studentId = body.student_id?.trim();
  if (!studentId) {
    const { data: student } = await service
      .from("students")
      .select("id")
      .eq("profile_id", userId)
      .maybeSingle();

    if (!student) {
      return errorResponse("Student record not found for current user", 404, "student_not_found");
    }
    studentId = student.id;
  }

  const { data: registration, error: dropErr } = await service
    .from("course_registrations")
    .update({
      status: "dropped",
      dropped_at: new Date().toISOString(),
    })
    .eq("student_id", studentId)
    .eq("course_offering_id", courseOfferingId)
    .eq("semester_id", semesterId)
    .select("id, status")
    .maybeSingle();

  if (dropErr || !registration) {
    return errorResponse(
      dropErr?.message ?? "Active course registration not found",
      404,
      "registration_not_found",
    );
  }

  await service.from("audit_logs").insert({
    actor_profile_id: userId,
    action: "course.dropped",
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
