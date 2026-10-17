import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/widgets/amount_text.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/status_chip.dart';
import '../../../students/presentation/screens/create_student_screen.dart';
import '../../../students/presentation/screens/student_list_screen.dart';
import '../../../auth/domain/entities/user_profile.dart';
import '../widgets/password_reset_dialog.dart';

class AdminDashboardView extends ConsumerWidget {
  const AdminDashboardView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Admin Overview Header
          AppCard(
            backgroundColor: AppColors.primary,
            borderColor: AppColors.primaryLight,
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 26,
                  backgroundColor: AppColors.primaryContainer,
                  child: Icon(Icons.admin_panel_settings_outlined, color: AppColors.primary, size: 30),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Text(
                            'Administrator Control Panel',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 10),
                          const StatusChip(status: 'ADMIN ROLE'),
                        ],
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Operational authority: Manage admissions, approve tuition & fee payments, oversee academic staff & student rosters, and reset staff/student passwords.',
                        style: TextStyle(color: Colors.white70, fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Security Guard Info Banner
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.primaryContainer,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.primaryLight),
            ),
            child: const Row(
              children: [
                Icon(Icons.verified_user_outlined, color: AppColors.primary, size: 20),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Role-Based Security Policy: As an Administrator, you have authority to reset passwords for Staff & Students. SuperAdmin accounts and System Fee Bounds are protected and require SuperAdmin credentials.',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Section 1: Admissions & Payment Approvals
          Text(
            'Operational Workflows',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              // Admissions Card
              SizedBox(
                width: 320,
                child: AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Icon(Icons.how_to_reg_outlined, color: AppColors.primary, size: 28),
                          StatusChip(status: '3 PENDING'),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Admissions Management',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textPrimary),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Review incoming applications, approve admitted candidates, and issue official matricules.',
                        style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                      ),
                      const SizedBox(height: 16),
                      AppButton(
                        label: 'New Student Admission',
                        icon: Icons.person_add_alt_1,
                        fullWidth: true,
                        onPressed: () => context.push(CreateStudentScreen.routePath),
                      ),
                    ],
                  ),
                ),
              ),

              // Fee Payment Approvals Card
              SizedBox(
                width: 320,
                child: AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Icon(Icons.payments_outlined, color: AppColors.secondary, size: 28),
                          StatusChip(status: 'PAID RECENT'),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Payment Approvals',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textPrimary),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Reconcile student MTN MoMo and Orange Money tuition deposits and generate receipts.',
                        style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Last verified payment:', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                          const AmountText(350000),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // Staff & Student Password Reset Card
              SizedBox(
                width: 320,
                child: AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Icon(Icons.lock_reset_outlined, color: AppColors.accent, size: 28),
                          StatusChip(status: 'AUTHORIZED'),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Account Password Reset',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textPrimary),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Reset forgotten credentials for enrolled students or academic lecturers.',
                        style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                      ),
                      const SizedBox(height: 16),
                      AppButton(
                        label: 'Reset Staff / Student Account',
                        icon: Icons.vpn_key_outlined,
                        fullWidth: true,
                        onPressed: () {
                          showDialog<void>(
                            context: context,
                            builder: (_) => const PasswordResetDialog(
                              actorRole: AppRole.admin,
                              targetUserId: 'student-demo-id',
                              targetEmail: 'student@liah.com',
                              targetRole: AppRole.student,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Section 2: Student Management
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Student Directory Oversight',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
              ),
              TextButton.icon(
                onPressed: () => context.push(StudentListScreen.routePath),
                icon: const Icon(Icons.open_in_new, size: 16),
                label: const Text('View All Students'),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const StudentListScreen(embedded: true),
        ],
      ),
    );
  }
}
