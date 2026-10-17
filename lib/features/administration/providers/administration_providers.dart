import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../services/administration_repository_impl.dart';
import '../models/admin_account.dart';
import '../models/audit_log.dart';
import '../models/fee_config.dart';
import '../services/administration_repository.dart';

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
