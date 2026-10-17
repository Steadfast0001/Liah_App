import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/section_header.dart';
import '../../../core/widgets/status_chip.dart';
import '../../auth/models/user_profile.dart';

/// Fah Academy SMS — Announcements & Bulletins View
class AnnouncementsView extends StatelessWidget {
  const AnnouncementsView({
    super.key,
    required this.actorRole,
  });

  final AppRole actorRole;

  @override
  Widget build(BuildContext context) {
    final canPublish = actorRole == AppRole.superAdmin || actorRole == AppRole.admin;

    final announcements = [
      {
        'title': 'First Semester 2026/2027 Course Registration Deadline',
        'audience': 'ALL STUDENTS',
        'date': 'Oct 16, 2026',
        'content':
            'Students are reminded that the add/drop window for course registration closes on November 05, 2026. Minimum credit load is 15 CU and maximum is 24 CU.',
        'author': 'Academic Registrar',
      },
      {
        'title': 'Continuous Assessment (CA) Submission Timelines',
        'audience': 'LECTURERS & STAFF',
        'date': 'Oct 14, 2026',
        'content':
            'Course lecturers are requested to submit draft Continuous Assessment (30%) results to the Exam Board before December 15, 2026.',
        'author': 'Vice-Dean of Academic Affairs',
      },
      {
        'title': 'Campus Mobile Money Tuition Integration Active',
        'audience': 'CAMPUS-WIDE',
        'date': 'Oct 10, 2026',
        'content':
            'Tuition installments can now be settled directly via MTN Mobile Money and Orange Money with instant receipt generation.',
        'author': 'Finance & Accounts Office',
      },
    ];

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
                  child: Icon(Icons.campaign_outlined, color: AppColors.primary, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Text(
                            'Institutional Announcements & Notices',
                            style: TextStyle(
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
                      const Text(
                        'Official notices, exam schedules, registration deadlines, and administrative communiqués.',
                        style: TextStyle(color: Colors.white70, fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          SectionHeader(
            title: 'Recent Broadcasts',
            subtitle: 'Targeted communications across Fah Academy SMS',
            trailing: canPublish
                ? AppButton(
                    label: 'Publish Announcement',
                    icon: Icons.add,
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Announcement composition dialog opened.'),
                          backgroundColor: AppColors.secondary,
                        ),
                      );
                    },
                  )
                : null,
          ),
          const SizedBox(height: 12),

          for (final a in announcements) ...[
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        a['title'] as String,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      StatusChip(status: a['audience'] as String),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Published by ${a['author']} • ${a['date']}',
                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    a['content'] as String,
                    style: const TextStyle(color: AppColors.textPrimary, fontSize: 13),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
          ],
        ],
      ),
    );
  }
}
