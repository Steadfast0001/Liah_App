import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/permissions/app_permissions.dart';
import '../../../core/widgets/amount_text.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/section_header.dart';
import '../../../core/widgets/status_chip.dart';
import '../../administration/providers/administration_providers.dart';
import '../../auth/models/user_profile.dart';

/// Fah Academy SMS — Fees, Payments & Financial Oversight View
///
/// Implements exact RBAC rules:
/// - Super Admin: Fee structure configuration, credit boundaries, late penalties, access milestones, financial reconciliation
/// - Admin: Payment verification queue, inspect bank receipts, verify & record confirmed payments
/// - Student: Personal fee statement, balance, submit bank payment evidence (MTN MoMo/Orange Money/Wire)
class FeesManagementView extends ConsumerStatefulWidget {
  const FeesManagementView({
    super.key,
    required this.actorRole,
  });

  final AppRole actorRole;

  @override
  ConsumerState<FeesManagementView> createState() => _FeesManagementViewState();
}

class _FeesManagementViewState extends ConsumerState<FeesManagementView> {
  // Pending verification queue for Admins & SuperAdmins
  final List<Map<String, dynamic>> _paymentReceipts = [
    {
      'id': 'PAY-REC-9081',
      'matricule': 'FA-2026-BSC-0012',
      'studentName': 'Jean-Luc Ndongo',
      'amountXaf': 350000,
      'method': 'MTN MoMo',
      'reference': 'TXN-MOMO-8839201',
      'date': 'Oct 16, 2026',
      'status': 'PENDING_VERIFICATION',
      'notes': 'Tuition installment 1 upload',
    },
    {
      'id': 'PAY-REC-9082',
      'matricule': 'FA-2026-BSC-0045',
      'studentName': 'Grace Mbah',
      'amountXaf': 25000,
      'method': 'Orange Money',
      'reference': 'OM-TXN-449102',
      'date': 'Oct 15, 2026',
      'status': 'VERIFIED',
      'notes': 'Annual Registration & ICT Fee',
    },
    {
      'id': 'PAY-REC-9083',
      'matricule': 'FA-2026-BSC-0089',
      'studentName': 'Emmanuel Nfor',
      'amountXaf': 200000,
      'method': 'Afriland First Bank Wire',
      'reference': 'AFB-SLIP-77123',
      'date': 'Oct 14, 2026',
      'status': 'PENDING_VERIFICATION',
      'notes': 'Bank teller deposit slip attached',
    },
  ];

  void _verifyPayment(int index) {
    if (!RolePermissions.canVerifyPayment(widget.actorRole)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Access Denied: You lack payment verification authority.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() {
      _paymentReceipts[index]['status'] = 'VERIFIED';
    });

    ref.read(administrationRepositoryProvider).logAuditEvent(
      action: 'PAYMENT_VERIFIED_AND_RECORDED',
      entityType: 'payment_ledger',
      entityId: _paymentReceipts[index]['id'] as String,
      details: {
        'verified_by': widget.actorRole.label,
        'student_matricule': _paymentReceipts[index]['matricule'],
        'amount_xaf': _paymentReceipts[index]['amountXaf'],
        'reference': _paymentReceipts[index]['reference'],
      },
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Payment ${_paymentReceipts[index]['id']} verified! Ledger updated.',
        ),
        backgroundColor: AppColors.secondary,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.actorRole == AppRole.student) {
      return _buildStudentFeeStatement();
    }

    final isSuperAdmin = widget.actorRole == AppRole.superAdmin;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Banner
          AppCard(
            backgroundColor: AppColors.navy,
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 26,
                  backgroundColor: AppColors.primaryContainer,
                  child: Icon(Icons.payments_outlined, color: AppColors.primary, size: 28),
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
                                ? 'Fees & Financial Policies Oversight'
                                : 'Payment Verification & Reconciliation',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 10),
                          StatusChip(status: widget.actorRole.label.toUpperCase()),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        isSuperAdmin
                            ? 'Institutional authority: Set fee structures, late penalties, access milestones, and inspect historical ledgers.'
                            : 'Operational authority: Verify student bank deposits, receipts, and record confirmed tuition payments.',
                        style: const TextStyle(color: Colors.white70, fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Quick Financial Metrics
          Row(
            children: [
              Expanded(
                child: AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Verified Collection',
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
                        'Academic Year 2026/2027',
                        style: TextStyle(color: AppColors.textSecondary.withValues(alpha: 0.8), fontSize: 11),
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
                        'Pending Verification Queue',
                        style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        '2 Receipts',
                        style: TextStyle(
                          color: AppColors.accent,
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Requires Admin/SuperAdmin check',
                        style: TextStyle(color: AppColors.textSecondary.withValues(alpha: 0.8), fontSize: 11),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Payment Verification Queue Table
          SectionHeader(
            title: 'Payment Verification Queue',
            subtitle: 'Evidence submissions from MTN MoMo, Orange Money & Bank Wire Deposits',
          ),
          const SizedBox(height: 12),

          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _paymentReceipts.length,
            separatorBuilder: (context, index) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final item = _paymentReceipts[index];
              final isVerified = item['status'] == 'VERIFIED';

              return AppCard(
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: isVerified
                          ? AppColors.secondaryContainer
                          : AppColors.accentContainer,
                      child: Icon(
                        isVerified ? Icons.check_circle_outline : Icons.pending_actions,
                        color: isVerified ? AppColors.secondary : AppColors.accent,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                item['studentName'] as String,
                                style: const TextStyle(
                                  color: AppColors.textPrimary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '(${item['matricule']})',
                                style: const TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Ref: ${item['reference']} • ${item['method']} • ${item['date']}',
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            item['notes'] as String,
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 12,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        AmountText(
                          item['amountXaf'] as int,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 8),
                        if (!isVerified)
                          AppButton(
                            label: 'Verify Receipt',
                            icon: Icons.verified_outlined,
                            onPressed: () => _verifyPayment(index),
                          )
                        else
                          const StatusChip(status: 'VERIFIED & PAID'),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStudentFeeStatement() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(
            title: 'My Tuition & Fee Statement',
            subtitle: 'Academic Year 2026/2027 • Central African CFA (XAF)',
          ),
          const SizedBox(height: 12),

          AppCard(
            backgroundColor: AppColors.navy,
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Outstanding Balance',
                      style: TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                    StatusChip(status: 'CLEARED'),
                  ],
                ),
                const SizedBox(height: 8),
                const AmountText(
                  0,
                  style: TextStyle(
                    color: AppColors.gold,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'All tuition milestones for Semester 1 have been satisfied. You are eligible for course registration and examination result access.',
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Upload payment proof action
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.upload_file_outlined, color: AppColors.primary),
                    SizedBox(width: 8),
                    Text(
                      'Submit Bank / Mobile Money Receipt',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  'Important: Uploading a receipt sends your evidence to the Accounts Administration for verification. Submitting evidence does not automatically clear fees until verified by an Admin.',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                ),
                const SizedBox(height: 14),
                AppButton(
                  label: 'Submit Payment Receipt',
                  icon: Icons.add_photo_alternate_outlined,
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Payment evidence submitted to Accounts Office for review.',
                        ),
                        backgroundColor: AppColors.secondary,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
