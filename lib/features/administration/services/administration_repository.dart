import '../../auth/models/user_profile.dart';
import '../models/admin_account.dart';
import '../models/audit_log.dart';
import '../models/fee_config.dart';

abstract interface class AdministrationRepository {
  Future<List<AuditLogEntry>> fetchAuditLogs({int limit = 50});

  Future<void> logAuditEvent({
    required String action,
    required String entityType,
    String? entityId,
    required Map<String, dynamic> details,
  });

  Future<List<AdminAccount>> fetchAdminAccounts();

  Future<AdminAccount> createAdminAccount({
    required String fullName,
    required String email,
    String? phone,
    required String password,
    bool sendEmailOrSms = true,
  });

  Future<void> resetAccountPassword({
    required String targetUserId,
    required String targetEmail,
    required AppRole targetRole,
    required AppRole actorRole,
    required String newPassword,
  });

  Future<FeeConfiguration> fetchFeeConfiguration();

  Future<void> updateFeeConfiguration(FeeConfiguration config);

  Future<void> overrideWorkflow({
    required String workflowType,
    required String targetId,
    required String reason,
    required AppRole actorRole,
  });
}
