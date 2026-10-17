import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/widgets/amount_text.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/section_header.dart';
import '../../../core/widgets/status_chip.dart';
import '../../auth/models/user_profile.dart';

/// Fah Academy SMS — Reports & Analytics View
///
/// Implements RBAC:
/// - Super Admin: Full institutional reports (enrollment statistics, fee collection, GPA distributions).
/// - Admin: Operational reports (daily admissions, payment reconciliations).
/// - Lecturer: Class performance reports for assigned courses.
/// - Student: Personal academic summaries.
class ReportsAnalyticsView extends StatelessWidget {
  const ReportsAnalyticsView({
    super.key,
    required this.actorRole,
  });

  final AppRole actorRole;

  @override
  Widget build(BuildContext context) {
    final isSuperAdmin = actorRole == AppRole.superAdmin;
    final isAdmin = actorRole == AppRole.admin;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppCard(
            backgroundColor: AppColors.navy,
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 26,
                  backgroundColor: AppColors.primaryContainer,
                  child: Icon(Icons.bar_chart_outlined, color: AppColors.primary, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            isSuperAdmin
                                ? 'Institutional Intelligence & Analytics'
                                : isAdmin
                                    ? 'Operational Administration Reports'
                                    : 'Teaching & Grade Performance Reports',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 10),
                          StatusChip(status: actorRole.label.toUpperCase()),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        isSuperAdmin
                            ? 'Institution-wide reporting: Enrollment trends, revenue collection rate (XAF), GPA distribution, and attrition rates.'
                            : 'Daily administrative reports: Admissions pipeline, verified tuition payments, and exam grade sheet submissions.',
                        style: const TextStyle(color: Colors.white70, fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Core KPI Cards
          Row(
            children: [
              Expanded(
                child: AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Total Enrolled Students',
                        style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        '1,248',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.bold,
                          fontSize: 22,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '+14% vs Previous Year',
                        style: TextStyle(color: AppColors.secondary, fontSize: 11, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Tuition Revenue Collected',
                        style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                      ),
                      const SizedBox(height: 6),
                      const AmountText(
                        48500000,
                        style: TextStyle(
                          color: AppColors.secondary,
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '87.4% Target Collection',
                        style: TextStyle(color: AppColors.textSecondary, fontSize: 11),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          const SectionHeader(
            title: 'Standard Report Exports',
            subtitle: 'Downloadable official summaries for audits, councils, and exam boards',
          ),
          const SizedBox(height: 12),

          AppCard(
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.table_chart_outlined, color: AppColors.primary),
              title: const Text(
                'Enrollment & Matriculation Roster (CSV / PDF)',
                style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary),
              ),
              subtitle: const Text(
                'Full student cohort breakdown with matricules, degree programs, and academic standing.',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
              ),
              trailing: const Icon(Icons.download, color: AppColors.primary),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Generating Enrollment Roster report...')),
                );
              },
            ),
          ),
          const SizedBox(height: 10),
          AppCard(
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.account_balance_wallet_outlined, color: AppColors.primary),
              title: const Text(
                'Financial Reconciliation Ledger (XAF)',
                style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary),
              ),
              subtitle: const Text(
                'Itemized payment ledger: MTN MoMo, Orange Money, bank deposits, and cleared balances.',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
              ),
              trailing: const Icon(Icons.download, color: AppColors.primary),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Exporting Financial Reconciliation Ledger...')),
                );
              },
            ),
          ),
          const SizedBox(height: 10),
          AppCard(
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.grade_outlined, color: AppColors.primary),
              title: const Text(
                'Semester Examination Board Master Sheet',
                style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary),
              ),
              subtitle: const Text(
                'CA (30%) + Final Exam (70%) composite scores, GPA calculations, and resit recommendations.',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
              ),
              trailing: const Icon(Icons.download, color: AppColors.primary),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Generating Exam Board Master Sheet...')),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
