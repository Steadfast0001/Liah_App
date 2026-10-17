import 'package:equatable/equatable.dart';

class AdminAccount extends Equatable {
  const AdminAccount({
    required this.id,
    required this.email,
    required this.fullName,
    this.phone,
    required this.isActive,
    required this.role,
    required this.createdAt,
    this.lastLoginAt,
  });

  final String id;
  final String email;
  final String fullName;
  final String? phone;
  final bool isActive;
  final String role; // 'admin' or 'super_admin'
  final DateTime createdAt;
  final DateTime? lastLoginAt;

  bool get isSuperAdmin => role == 'super_admin';

  factory AdminAccount.fromJson(Map<String, dynamic> json) {
    return AdminAccount(
      id: json['id']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      fullName: json['full_name']?.toString() ?? 'Admin',
      phone: json['phone']?.toString(),
      isActive: (json['is_active'] as bool?) ?? true,
      role: json['role']?.toString() ?? 'admin',
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
      lastLoginAt: json['last_login_at'] != null
          ? DateTime.tryParse(json['last_login_at'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        'full_name': fullName,
        'phone': phone,
        'is_active': isActive,
        'role': role,
        'created_at': createdAt.toIso8601String(),
        'last_login_at': lastLoginAt?.toIso8601String(),
      };

  @override
  List<Object?> get props => [
        id,
        email,
        fullName,
        phone,
        isActive,
        role,
        createdAt,
        lastLoginAt,
      ];
}
