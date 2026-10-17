import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';

class MatriculeBadge extends StatelessWidget {
  const MatriculeBadge({
    super.key,
    required this.matricule,
  });

  final String matricule;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.accentContainer,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppColors.accent),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.badge_outlined, size: 14, color: AppColors.accent),
          const SizedBox(width: 4),
          Text(
            matricule,
            style: const TextStyle(
              color: AppColors.accent,
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}
