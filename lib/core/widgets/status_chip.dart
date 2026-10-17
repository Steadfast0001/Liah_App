import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';

class StatusChip extends StatelessWidget {
  const StatusChip({
    super.key,
    required this.status,
  });

  final String status;

  @override
  Widget build(BuildContext context) {
    final normalized = status.trim().toLowerCase();
    final isPositive = const {
      'active',
      'registered',
      'paid',
      'verified',
      'published',
      'finalized',
      'approved',
      'cleared',
      'completed',
      'enrolled',
    }.contains(normalized);

    final isWarning = const {
      'pending',
      'partial',
      'submitted',
      'draft',
      'applicant',
      'processing',
      'on_leave',
    }.contains(normalized);

    final isDanger = const {
      'overdue',
      'failed',
      'dropped',
      'withdrawn',
      'suspended',
      'terminated',
    }.contains(normalized);

    final Color bg;
    final Color fg;
    final Color border;

    if (isPositive) {
      bg = AppColors.secondaryContainer;
      fg = AppColors.secondary;
      border = AppColors.secondary;
    } else if (isWarning) {
      bg = AppColors.warningContainer;
      fg = AppColors.warning;
      border = AppColors.warning;
    } else if (isDanger) {
      bg = AppColors.errorContainer;
      fg = AppColors.error;
      border = AppColors.error;
    } else {
      bg = AppColors.primaryContainer;
      fg = AppColors.primary;
      border = AppColors.primaryLight;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: border),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          color: fg,
          fontSize: 11,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}
