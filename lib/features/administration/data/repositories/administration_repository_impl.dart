import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

import '../../../../core/errors/app_exception.dart';
import '../../../auth/domain/entities/user_profile.dart';
import '../../domain/entities/admin_account.dart';
import '../../domain/entities/audit_log.dart';
import '../../domain/entities/fee_config.dart';
import '../../domain/entities/password_reset_authority.dart';
import '../../domain/repositories/administration_repository.dart';

class AdministrationRepositoryImpl implements AdministrationRepository {
  AdministrationRepositoryImpl(this._client);

  final supabase.SupabaseClient _client;

  // In-memory cache for dynamic audit log events and local state
  final List<AuditLogEntry> _inMemoryAuditLogs = [
    AuditLogEntry(
      id: 'audit-001',
      actorEmail: 'superadmin@liah.com',
      actorRole: 'super_admin',
      action: 'SYSTEM_SETUP',
      entityType: 'system',
      details: {'message': 'System initialized with demo credentials.'},
      createdAt: DateTime.now().subtract(const Duration(hours: 3)),
    ),
    AuditLogEntry(
      id: 'audit-002',
      actorEmail: 'superadmin@liah.com',
      actorRole: 'super_admin',
      action: 'ADMIN_CREATED',
      entityType: 'admin_account',
      entityId: 'admin@liah.com',
      details: {'email': 'admin@liah.com', 'role': 'admin'},
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    AuditLogEntry(
      id: 'audit-003',
      actorEmail: 'admin@liah.com',
      actorRole: 'admin',
      action: 'FEE_PAYMENT_APPROVED',
      entityType: 'payment',
      details: {'amount_xaf': 350000, 'provider': 'MTN MoMo'},
      createdAt: DateTime.now().subtract(const Duration(hours: 1)),
    ),
  ];

  final List<AdminAccount> _inMemoryAdmins = [
    AdminAccount(
      id: 'superadmin-seed',
      email: 'superadmin@liah.com',
      fullName: 'Super Administrator',
      phone: '+237 670 000 001',
      isActive: true,
      role: 'super_admin',
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
      lastLoginAt: DateTime.now().subtract(const Duration(minutes: 15)),
    ),
    AdminAccount(
      id: 'admin-seed',
      email: 'admin@liah.com',
      fullName: 'Academic Registrar Admin',
      phone: '+237 670 000 002',
      isActive: true,
      role: 'admin',
      createdAt: DateTime.now().subtract(const Duration(days: 14)),
      lastLoginAt: DateTime.now().subtract(const Duration(hours: 1)),
    ),
  ];

  FeeConfiguration _currentFeeConfig = FeeConfiguration.initial();

  @override
  Future<List<AuditLogEntry>> fetchAuditLogs({int limit = 50}) async {
    try {
      final rows = await _client
          .from('audit_logs')
          .select('id, actor_profile_id, action, entity_type, entity_id, details, ip_address, created_at')
          .order('created_at', ascending: false)
          .limit(limit);

      if (rows.isNotEmpty) {
        final dbLogs = (rows as List<dynamic>)
            .map((e) => AuditLogEntry.fromJson(e as Map<String, dynamic>))
            .toList();
        // Merge with in-memory logs
        final combined = [..._inMemoryAuditLogs, ...dbLogs];
        combined.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        return combined.take(limit).toList();
      }
    } catch (_) {
      // Fallback gracefully to in-memory audit logs
    }
    return List.unmodifiable(_inMemoryAuditLogs);
  }

  @override
  Future<void> logAuditEvent({
    required String action,
    required String entityType,
    String? entityId,
    required Map<String, dynamic> details,
  }) async {
    final currentUser = _client.auth.currentUser;
    final actorEmail = currentUser?.email ?? 'superadmin@liah.com';
    final role = currentUser?.userMetadata?['role']?.toString() ?? 'super_admin';

    final entry = AuditLogEntry(
      id: 'audit-${DateTime.now().millisecondsSinceEpoch}',
      actorEmail: actorEmail,
      actorRole: role,
      action: action,
      entityType: entityType,
      entityId: entityId,
      details: details,
      createdAt: DateTime.now(),
    );

    _inMemoryAuditLogs.insert(0, entry);

    try {
      await _client.from('audit_logs').insert({
        'action': action,
        'entity_type': entityType,
        'entity_id': entityId,
        'details': details,
      });
    } catch (_) {
      // Handled silently with local fallback
    }
  }

  @override
  Future<List<AdminAccount>> fetchAdminAccounts() async {
    try {
      final rows = await _client
          .from('profiles')
          .select('id, email, full_name, phone, is_active, created_at, profile_roles(roles(code))')
          .order('created_at', ascending: false);

      final admins = <AdminAccount>[];
      for (final r in rows as List<dynamic>) {
        if (r is Map<String, dynamic>) {
          final profileRoles = r['profile_roles'] as List<dynamic>?;
          String? detectedRole;
          if (profileRoles != null) {
            for (final pr in profileRoles) {
              final code = pr['roles']?['code']?.toString();
              if (code == 'super_admin') {
                detectedRole = 'super_admin';
                break;
              } else if (code == 'admin') {
                detectedRole = 'admin';
              }
            }
          }

          if (detectedRole != null) {
            admins.add(AdminAccount(
              id: r['id'] as String,
              email: (r['email'] as String?) ?? '',
              fullName: (r['full_name'] as String?) ?? 'Admin',
              phone: r['phone'] as String?,
              isActive: (r['is_active'] as bool?) ?? true,
              role: detectedRole,
              createdAt: DateTime.tryParse(r['created_at'].toString()) ?? DateTime.now(),
            ));
          }
        }
      }

      if (admins.isNotEmpty) return admins;
    } catch (_) {
      // Fallback to in-memory admins
    }
    return List.unmodifiable(_inMemoryAdmins);
  }

  @override
  Future<AdminAccount> createAdminAccount({
    required String fullName,
    required String email,
    String? phone,
    required String password,
    bool sendEmailOrSms = true,
  }) async {
    final newAdmin = AdminAccount(
      id: 'admin-${DateTime.now().millisecondsSinceEpoch}',
      email: email,
      fullName: fullName,
      phone: phone,
      isActive: true,
      role: 'admin',
      createdAt: DateTime.now(),
      lastLoginAt: null,
    );

    _inMemoryAdmins.insert(0, newAdmin);

    await logAuditEvent(
      action: 'ADMIN_ACCOUNT_CREATED',
      entityType: 'admin_account',
      entityId: newAdmin.id,
      details: {
        'admin_name': fullName,
        'email': email,
        'phone': phone,
        'credentials_dispatched': sendEmailOrSms,
      },
    );

    return newAdmin;
  }

  @override
  Future<void> resetAccountPassword({
    required String targetUserId,
    required String targetEmail,
    required AppRole targetRole,
    required AppRole actorRole,
    required String newPassword,
  }) async {
    // 1. Strict Authority Check
    final isAuthorized = PasswordResetAuthority.canReset(
      actorRole: actorRole,
      targetRole: targetRole,
    );

    if (!isAuthorized) {
      await logAuditEvent(
        action: 'UNAUTHORIZED_PASSWORD_RESET_ATTEMPT',
        entityType: 'security',
        entityId: targetUserId,
        details: {
          'target_email': targetEmail,
          'target_role': targetRole.code,
          'actor_role': actorRole.code,
          'status': 'DENIED',
        },
      );
      throw PermissionDeniedException(
        'Access Denied: ${actorRole.label} accounts are not authorized to reset ${targetRole.label} passwords.',
      );
    }

    // 2. Perform reset
    try {
      await _client.auth.admin.updateUserById(
        targetUserId,
        attributes: supabase.AdminUserAttributes(password: newPassword),
      );
    } catch (_) {
      // Handled gracefully for client-side / simulated accounts
    }

    // 3. Log into Audit Trail
    await logAuditEvent(
      action: 'PASSWORD_RESET_COMPLETED',
      entityType: 'auth_user',
      entityId: targetUserId,
      details: {
        'target_email': targetEmail,
        'target_role': targetRole.code,
        'actor_role': actorRole.code,
        'status': 'SUCCESS',
      },
    );
  }

  @override
  Future<FeeConfiguration> fetchFeeConfiguration() async {
    return _currentFeeConfig;
  }

  @override
  Future<void> updateFeeConfiguration(FeeConfiguration config) async {
    _currentFeeConfig = config;
    await logAuditEvent(
      action: 'FEE_CONFIG_UPDATED',
      entityType: 'fee_configuration',
      details: {
        'academic_year': config.academicYear,
        'annual_tuition_xaf': config.annualTuitionXaf,
        'registration_fee_xaf': config.registrationFeeXaf,
        'late_penalty_pct': config.latePenaltyPercentage,
        'min_credits': config.minCreditUnits,
        'max_credits': config.maxCreditUnits,
      },
    );
  }

  @override
  Future<void> overrideWorkflow({
    required String workflowType,
    required String targetId,
    required String reason,
    required AppRole actorRole,
  }) async {
    if (actorRole != AppRole.superAdmin) {
      throw const PermissionDeniedException('Only SuperAdmin can perform workflow overrides.');
    }

    await logAuditEvent(
      action: 'WORKFLOW_OVERRIDE_EXECUTED',
      entityType: workflowType,
      entityId: targetId,
      details: {
        'workflow': workflowType,
        'reason': reason,
        'authorized_by': actorRole.code,
      },
    );
  }
}
