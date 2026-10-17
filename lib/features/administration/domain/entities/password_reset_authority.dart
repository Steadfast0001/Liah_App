import '../../../auth/domain/entities/user_profile.dart';

abstract final class PasswordResetAuthority {
  /// Checks whether [actorRole] is authorized to reset the password for [targetRole].
  ///
  /// Authority rules:
  /// - SuperAdmin can reset Admin, Lecturer, Student accounts.
  /// - Admin can reset Lecturer and Student accounts.
  /// - Admin CANNOT reset SuperAdmin or Admin accounts.
  static bool canReset({
    required AppRole actorRole,
    required AppRole targetRole,
  }) {
    if (actorRole == AppRole.superAdmin) {
      return true; // Super Admin has full password reset authority
    }
    if (actorRole == AppRole.admin) {
      // Admin cannot reset SuperAdmin or fellow Admin accounts
      return targetRole == AppRole.lecturer || targetRole == AppRole.student;
    }
    return false;
  }

  /// Returns user-friendly explanation of reset authority permissions.
  static String getPermissionDescription(AppRole actorRole) {
    return switch (actorRole) {
      AppRole.superAdmin =>
        'Full Authority: Can reset passwords for Admins, Staff/Lecturers, and Students.',
      AppRole.admin =>
        'Limited Authority: Can reset passwords for Staff/Lecturers and Students. Cannot reset Admin or SuperAdmin accounts.',
      _ => 'No password reset authority.',
    };
  }
}
