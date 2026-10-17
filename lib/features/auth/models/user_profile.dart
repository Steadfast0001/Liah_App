import 'package:equatable/equatable.dart';

enum AppRole {
  superAdmin('super_admin', 'Super Admin'),
  admin('admin', 'Administrator'),
  lecturer('lecturer', 'Lecturer'),
  student('student', 'Student');

  const AppRole(this.code, this.label);
  final String code;
  final String label;

  static AppRole? fromCode(String? code) {
    for (final role in AppRole.values) {
      if (role.code == code) return role;
    }
    return null;
  }
}

class UserProfile extends Equatable {
  const UserProfile({
    required this.id,
    required this.email,
    required this.fullName,
    this.phone,
    this.avatarUrl,
    this.isActive = true,
    this.roles = const [],
  });

  final String id;
  final String email;
  final String fullName;
  final String? phone;
  final String? avatarUrl;
  final bool isActive;
  final List<AppRole> roles;

  /// Highest-precedence role for shell navigation.
  AppRole get primaryRole {
    if (roles.contains(AppRole.superAdmin)) return AppRole.superAdmin;
    if (roles.contains(AppRole.admin)) return AppRole.admin;
    if (roles.contains(AppRole.lecturer)) return AppRole.lecturer;
    if (roles.contains(AppRole.student)) return AppRole.student;
    return AppRole.student;
  }

  bool hasRole(AppRole role) => roles.contains(role);

  bool get canManageStudents =>
      roles.contains(AppRole.superAdmin) || roles.contains(AppRole.admin);

  bool get canViewStudents =>
      canManageStudents || roles.contains(AppRole.lecturer);

  @override
  List<Object?> get props => [
        id,
        email,
        fullName,
        phone,
        avatarUrl,
        isActive,
        roles,
      ];
}
