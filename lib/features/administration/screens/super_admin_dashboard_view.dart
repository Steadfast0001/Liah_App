import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/status_chip.dart';
import '../../auth/models/user_profile.dart';
import '../providers/administration_providers.dart';
import '../widgets/admin_management_view.dart';
import '../widgets/audit_log_table.dart';
import '../widgets/fee_config_view.dart';

class SuperAdminDashboardView extends ConsumerStatefulWidget {
  const SuperAdminDashboardView({super.key});

  @override
  ConsumerState<SuperAdminDashboardView> createState() => _SuperAdminDashboardViewState();
}

class _SuperAdminDashboardViewState extends ConsumerState<SuperAdminDashboardView>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // SuperAdmin Header Card
          AppCard(
            backgroundColor: AppColors.primary,
            borderColor: AppColors.primaryLight,
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 26,
                  backgroundColor: AppColors.primaryContainer,
                  child: Icon(Icons.shield_outlined, color: AppColors.primary, size: 30),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Text(
                            'SuperAdmin Master Control',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 10),
                          const StatusChip(status: 'FULL ACCESS'),
                        ],
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Full system control: Manage administrators, configure tuition fees, execute workflow overrides, and review security audit logs.',
                        style: TextStyle(color: Colors.white70, fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Tab Bar
          TabBar(
            controller: _tabController,
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.textSecondary,
            indicatorColor: AppColors.primary,
            tabs: const [
              Tab(icon: Icon(Icons.admin_panel_settings_outlined), text: 'Admin Management'),
              Tab(icon: Icon(Icons.request_quote_outlined), text: 'Fee & Credit Rules'),
              Tab(icon: Icon(Icons.history_edu_outlined), text: 'Audit Logs'),
              Tab(icon: Icon(Icons.tune_outlined), text: 'Workflow Overrides'),
            ],
          ),
          const SizedBox(height: 20),

          // Tab Body
          SizedBox(
            height: 600,
            child: TabBarView(
              controller: _tabController,
              children: [
                const SingleChildScrollView(
                  child: AdminManagementView(actorRole: AppRole.superAdmin),
                ),
                const SingleChildScrollView(child: FeeConfigView()),
                const SingleChildScrollView(child: AuditLogTable()),
                _buildWorkflowOverridesTab(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWorkflowOverridesTab(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Emergency Workflow Overrides',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Allows SuperAdmin to bypass registration windows, force-publish finalized results, or unlock academic terms.',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
          ),
          const SizedBox(height: 18),
          AppCard(
            child: ListTile(
              leading: const Icon(Icons.lock_open_outlined, color: AppColors.accent),
              title: const Text(
                'Unlock Semester Registration Window',
                style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary),
              ),
              subtitle: const Text('Bypass deadline restrictions for students requiring late enrollment.'),
              trailing: ElevatedButton(
                onPressed: () async {
                  await ref.read(administrationRepositoryProvider).overrideWorkflow(
                        workflowType: 'semester_registration_override',
                        targetId: 'semester-active',
                        reason: 'SuperAdmin manual override for academic enrollment.',
                        actorRole: AppRole.superAdmin,
                      );
                  ref.invalidate(auditLogsProvider);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Registration window override executed and logged.'),
                        backgroundColor: AppColors.secondary,
                      ),
                    );
                  }
                },
                child: const Text('Execute Override'),
              ),
            ),
          ),
          const SizedBox(height: 12),
          AppCard(
            child: ListTile(
              leading: const Icon(Icons.publish_outlined, color: AppColors.primary),
              title: const Text(
                'Force Publish Exam Board Results',
                style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary),
              ),
              subtitle: const Text('Transition finalized results to published status across academic departments.'),
              trailing: ElevatedButton(
                onPressed: () async {
                  await ref.read(administrationRepositoryProvider).overrideWorkflow(
                        workflowType: 'exam_results_override',
                        targetId: 'exam-board-all',
                        reason: 'SuperAdmin force publish authorization.',
                        actorRole: AppRole.superAdmin,
                      );
                  ref.invalidate(auditLogsProvider);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Results publication override authorized and logged.'),
                        backgroundColor: AppColors.secondary,
                      ),
                    );
                  }
                },
                child: const Text('Force Publish'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
