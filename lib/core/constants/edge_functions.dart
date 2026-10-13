/// Supabase Edge Function names (must match `supabase/functions/*`).
abstract final class EdgeFunctions {
  static const adminCreateStudent = 'admin-create-student';
  static const adminCreateStaff = 'admin-create-staff';
  static const superAdminChangeStudentEmail = 'super-admin-change-student-email';
  static const registerCourse = 'register-course';
  static const dropCourse = 'drop-course';
  static const getSemesterAccess = 'get-semester-access';
  static const createPaymentIntent = 'create-payment-intent';
  static const verifyPayment = 'verify-payment';
  static const submitCourseGrades = 'submit-course-grades';
  static const approveResults = 'approve-results';
  static const finalizeResults = 'finalize-results';
  static const publishResults = 'publish-results';
  static const generateTranscript = 'generate-transcript';
  static const createNotification = 'create-notification';
}
