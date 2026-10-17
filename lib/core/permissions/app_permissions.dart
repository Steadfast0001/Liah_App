import '../../features/administration/models/password_reset_authority.dart';
import '../../features/auth/models/user_profile.dart';

/// Fah Academy SMS — Role-Based Access Control (RBAC) Permissions
///
/// Translated directly from the Fah Academy SMS Page Access Matrix
/// and Action-Level Permission Matrix.
enum AppPermission {
  manageUsers,
  manageStudents,
  manageStaff,
  manageAdmissions,
  manageAcademicStructure,
  manageCourseRegistration,
  manageFeePolicies,
  verifyPayments,
  manageAttendance,
  enterGrades,
  approveResults,
  publishResults,
  viewOwnResults,
  manageResits,
  manageTimetable,
  manageDocuments,
  manageAnnouncements,
  viewAuditLogs,
  viewReports,
  systemSettings,
  overrideWorkflows,
}

/// Central RBAC Policy Authority for Fah Academy SMS.
///
/// Controls both page-level navigation guards and action-level button/workflow permissions.
abstract final class RolePermissions {
  static const Map<AppRole, Set<AppPermission>> _rolePermissionMap = {
    AppRole.superAdmin: {
      AppPermission.manageUsers,
      AppPermission.manageStudents,
      AppPermission.manageStaff,
      AppPermission.manageAdmissions,
      AppPermission.manageAcademicStructure,
      AppPermission.manageCourseRegistration,
      AppPermission.manageFeePolicies,
      AppPermission.verifyPayments,
      AppPermission.manageAttendance,
      AppPermission.enterGrades,
      AppPermission.approveResults,
      AppPermission.publishResults,
      AppPermission.viewOwnResults,
      AppPermission.manageResits,
      AppPermission.manageTimetable,
      AppPermission.manageDocuments,
      AppPermission.manageAnnouncements,
      AppPermission.viewAuditLogs,
      AppPermission.viewReports,
      AppPermission.systemSettings,
      AppPermission.overrideWorkflows,
    },
    AppRole.admin: {
      AppPermission.manageStudents,
      AppPermission.manageStaff,
      AppPermission.manageAdmissions,
      AppPermission.manageAcademicStructure,
      AppPermission.manageCourseRegistration,
      AppPermission.verifyPayments,
      AppPermission.manageAttendance,
      AppPermission.enterGrades,
      AppPermission.approveResults,
      // NOTE: publishResults is strictly Super Admin-only by policy!
      AppPermission.viewOwnResults,
      AppPermission.manageResits,
      AppPermission.manageTimetable,
      AppPermission.manageDocuments,
      AppPermission.manageAnnouncements,
      AppPermission.viewReports,
    },
    AppRole.lecturer: {
      AppPermission.manageAttendance,
      AppPermission.enterGrades,
      // NOTE: Cannot approve own submission, cannot publish
      AppPermission.manageResits,
      AppPermission.manageTimetable,
      AppPermission.manageDocuments,
      AppPermission.manageAnnouncements,
      AppPermission.viewReports,
    },
    AppRole.student: {
      AppPermission.viewOwnResults,
      AppPermission.manageCourseRegistration,
      AppPermission.manageDocuments,
      AppPermission.manageAnnouncements,
    },
  };

  /// Checks if [role] has the given [permission].
  static bool hasPermission(AppRole role, AppPermission permission) {
    return _rolePermissionMap[role]?.contains(permission) ?? false;
  }

  // =========================================================================
  // ACTION-LEVEL PERMISSION GUARDS (Table 7)
  // =========================================================================

  /// Super Admin exclusively creates Admin accounts.
  static bool canCreateAdmin(AppRole role) => role == AppRole.superAdmin;

  /// Super Admin and Admin can create student accounts.
  static bool canCreateStudent(AppRole role) =>
      role == AppRole.superAdmin || role == AppRole.admin;

  /// Password reset authority:
  /// - SuperAdmin can reset Admins, Lecturers, and Students.
  /// - Admin can reset Lecturers and Students only.
  /// - Admin CANNOT reset Admins or SuperAdmin.
  static bool canResetPassword({
    required AppRole actorRole,
    required AppRole targetRole,
  }) {
    return PasswordResetAuthority.canReset(
      actorRole: actorRole,
      targetRole: targetRole,
    );
  }

  /// Only Super Admin can change user roles in DB.
  static bool canChangeUserRoles(AppRole role) => role == AppRole.superAdmin;

  /// Only Super Admin can alter institutional fee structures and semester credit limits.
  static bool canChangeFeeStructures(AppRole role) =>
      role == AppRole.superAdmin;

  /// Super Admin and Admin can record verified payments.
  static bool canVerifyPayment(AppRole role) =>
      role == AppRole.superAdmin || role == AppRole.admin;

  /// Students can register for courses if eligible; Admins/SuperAdmin have administrative override.
  static bool canRegisterCourseForSelf(AppRole role) =>
      role == AppRole.student ||
      role == AppRole.admin ||
      role == AppRole.superAdmin;

  /// Lecturers record assigned attendance; Admins and SuperAdmins have oversight/correction authority.
  static bool canRecordAttendance(AppRole role) => role != AppRole.student;

  /// Lecturers enter draft marks; Admins review; SuperAdmins have oversight.
  static bool canEnterGrades(AppRole role) => role != AppRole.student;

  /// Admin and SuperAdmin can approve grade submissions. Lecturers cannot approve own submission.
  static bool canApproveGradeSubmission(
    AppRole role, {
    bool isOwnSubmission = false,
  }) {
    if (isOwnSubmission) return false;
    return role == AppRole.superAdmin || role == AppRole.admin;
  }

  /// CRITICAL DISTINCTION: Results Finalization & Publishing
  /// Only Super Admin can finalize and publish results to students.
  /// Admin is DENIED by default until explicitly authorized.
  static bool canPublishFinalResults(AppRole role) =>
      role == AppRole.superAdmin;

  /// Record resit attempts without erasing original failed grades.
  static bool canRecordResit(AppRole role) => role != AppRole.student;

  /// Change semester access policies (prerequisites & fee clearance milestones).
  static bool canChangeSemesterAccessPolicies(AppRole role) =>
      role == AppRole.superAdmin;

  /// Inspect full security audit logs.
  static bool canReadAuditLogs(AppRole role) => role == AppRole.superAdmin;

  /// Override academic or registration workflows.
  static bool canOverrideWorkflow(AppRole role) =>
      role == AppRole.superAdmin;
}
