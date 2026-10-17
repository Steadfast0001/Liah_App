import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../data/repositories/administration_repository_impl.dart';
import '../../domain/entities/admin_account.dart';
import '../../domain/entities/audit_log.dart';
import '../../domain/entities/fee_config.dart';
import '../../domain/repositories/administration_repository.dart';

final administrationRepositoryProvider = Provider<AdministrationRepository>((ref) {
  return AdministrationRepositoryImpl(Supabase.instance.client);
});

final auditLogsProvider = FutureProvider<List<AuditLogEntry>>((ref) async {
  final repo = ref.watch(administrationRepositoryProvider);
  return repo.fetchAuditLogs();
});

final adminAccountsProvider = FutureProvider<List<AdminAccount>>((ref) async {
  final repo = ref.watch(administrationRepositoryProvider);
  return repo.fetchAdminAccounts();
});

final feeConfigurationProvider = FutureProvider<FeeConfiguration>((ref) async {
  final repo = ref.watch(administrationRepositoryProvider);
  return repo.fetchFeeConfiguration();
});
