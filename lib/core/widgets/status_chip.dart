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
      bg = AppColors.successBackground;
      fg = AppColors.successText;
      border = AppColors.successText;
    } else if (isWarning) {
      bg = AppColors.goldTint;
      fg = AppColors.gold;
      border = AppColors.gold;
    } else if (isDanger) {
      bg = const Color(0xFFFDE8E8);
      fg = const Color(0xFF9B1C1C);
      border = const Color(0xFFF8B4B4);
    } else {
      bg = AppColors.surfaceRaised;
      fg = AppColors.onNavy;
      border = AppColors.border;
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
