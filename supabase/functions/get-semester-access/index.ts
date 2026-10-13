import { serveProtected } from "../_shared/handler.ts";
import { errorResponse, json } from "../_shared/response.ts";

interface SemesterAccessPayload {
  semester_id?: string;
}

serveProtected("get-semester-access", async (req, { userId, service }) => {
  let body: SemesterAccessPayload = {};
  try {
    body = await req.json();
  } catch {
    // Allow empty body to fall back to current semester
  }

  // Resolve semester (explicit or current)
  let semesterQuery = service
    .from("semesters")
    .select("id, label, registration_opens_at, registration_closes_at, is_current");

  if (body.semester_id) {
    semesterQuery = semesterQuery.eq("id", body.semester_id);
  } else {
    semesterQuery = semesterQuery.eq("is_current", true);
  }

  const { data: semester, error: semErr } = await semesterQuery.maybeSingle();
  if (semErr || !semester) {
    return errorResponse("Semester not found", 404, "semester_not_found");
  }

  // Resolve student record for current user
  const { data: student } = await service
    .from("students")
    .select("id, status")
    .eq("profile_id", userId)
    .maybeSingle();

  const messages: string[] = [];
  const now = new Date();
  const opensAt = semester.registration_opens_at
    ? new Date(semester.registration_opens_at)
    : null;
  const closesAt = semester.registration_closes_at
    ? new Date(semester.registration_closes_at)
    : null;

  let windowOpen = true;
  if (opensAt && now < opensAt) {
    windowOpen = false;
    messages.push(`Registration opens on ${opensAt.toISOString().slice(0, 10)}.`);
  }
  if (closesAt && now > closesAt) {
    windowOpen = false;
    messages.push(`Registration closed on ${closesAt.toISOString().slice(0, 10)}.`);
  }

  if (!student) {
    return json({
      semester_id: semester.id,
      can_register: false,
      can_view_results: true,
      fee_status: "not_applicable",
      messages: ["No student profile linked to this account."],
    });
  }

  if (student.status !== "active") {
    messages.push(`Student status is '${student.status}'.`);
  }

  // Check student charges for this semester
  const { data: charges } = await service
    .from("student_charges")
    .select("amount_xaf, amount_paid_xaf, status")
    .eq("student_id", student.id)
    .eq("semester_id", semester.id);

  let feeStatus = "cleared";
  if (charges && charges.length > 0) {
    const totalDue = charges.reduce((acc, c) => acc + Number(c.amount_xaf ?? 0), 0);
    const totalPaid = charges.reduce((acc, c) => acc + Number(c.amount_paid_xaf ?? 0), 0);
    const hasOverdue = charges.some((c) => c.status === "overdue");
    if (hasOverdue) {
      feeStatus = "overdue";
      messages.push("You have overdue semester charges.");
    } else if (totalPaid < totalDue) {
      feeStatus = totalPaid > 0 ? "partial" : "pending";
    }
  }

  const canRegister = student.status === "active" && windowOpen && feeStatus !== "overdue";
  const canViewResults = feeStatus !== "overdue";

  return json({
    semester_id: semester.id,
    can_register: canRegister,
    can_view_results: canViewResults,
    fee_status: feeStatus,
    messages,
  });
});
