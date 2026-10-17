import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/utils/date_format.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/status_chip.dart';
import '../providers/administration_providers.dart';

class AuditLogTable extends ConsumerStatefulWidget {
  const AuditLogTable({super.key});

  @override
  ConsumerState<AuditLogTable> createState() => _AuditLogTableState();
}

class _AuditLogTableState extends ConsumerState<AuditLogTable> {
  final _searchController = TextEditingController();
  String _filter = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final logsAsync = ref.watch(auditLogsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Security Audit Logs',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Immutable audit trail recording every administrative event, password reset, fee update, and 2FA login.',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                ),
              ],
            ),
            IconButton(
              tooltip: 'Refresh Logs',
              onPressed: () => ref.invalidate(auditLogsProvider),
              icon: const Icon(Icons.refresh, color: AppColors.primary),
            ),
          ],
        ),
        const SizedBox(height: 14),
        TextField(
          controller: _searchController,
          onChanged: (val) => setState(() => _filter = val.trim().toLowerCase()),
          decoration: InputDecoration(
            hintText: 'Search audit events, actor email, or entity type...',
            prefixIcon: const Icon(Icons.search, color: AppColors.textSecondary),
            filled: true,
            fillColor: AppColors.surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.border),
            ),
          ),
        ),
        const SizedBox(height: 14),
        logsAsync.when(
          loading: () => const Center(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: CircularProgressIndicator(),
            ),
          ),
          error: (err, _) => Text('Error loading audit trail: $err'),
          data: (logs) {
            final filtered = logs.where((l) {
              if (_filter.isEmpty) return true;
              return l.action.toLowerCase().contains(_filter) ||
                  l.actorEmail.toLowerCase().contains(_filter) ||
                  l.entityType.toLowerCase().contains(_filter);
            }).toList();

            if (filtered.isEmpty) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: Text('No audit log entries matching your query.'),
                ),
              );
            }

            return ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: filtered.length,
              separatorBuilder: (context, index) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final log = filtered[index];
                return AppCard(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.primaryContainer,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.security_outlined,
                          size: 18,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  log.action,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                StatusChip(status: log.actorRole.toUpperCase()),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Actor: ${log.actorEmail}  •  Target: ${log.entityType}',
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        AppDateFormat.shortDate(log.createdAt),
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }
}
