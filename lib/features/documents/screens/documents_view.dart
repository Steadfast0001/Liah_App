import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/section_header.dart';
import '../../../core/widgets/status_chip.dart';
import '../../auth/models/user_profile.dart';

/// Fah Academy SMS — Documents & Official Transcripts View
///
/// Implements RBAC:
/// - Super Admin: Full oversight, issue official graduation transcripts, decree attestations.
/// - Admin: Manage and process authorized student records, admission packages.
/// - Lecturer: View assigned course documents & teaching materials.
/// - Student: Request official transcript PDF, download enrollment certificate, view issued files.
class DocumentsView extends StatelessWidget {
  const DocumentsView({
    super.key,
    required this.actorRole,
  });

  final AppRole actorRole;

  @override
  Widget build(BuildContext context) {
    final isStudent = actorRole == AppRole.student;

    final documents = [
      {
        'title': 'Official Academic Transcript (Partial/Full)',
        'type': 'PDF Document',
        'status': 'OFFICIAL',
        'date': 'Oct 15, 2026',
        'icon': Icons.description_outlined,
      },
      {
        'title': 'Certificate of School Attendance / Enrollment',
        'type': 'Attestation',
        'status': 'ACTIVE',
        'date': 'Oct 02, 2026',
        'icon': Icons.verified_outlined,
      },
      {
        'title': 'Official University Admission Letter',
        'type': 'Admission Paper',
        'status': 'ARCHIVED',
        'date': 'Sep 10, 2026',
        'icon': Icons.mail_outline,
      },
      {
        'title': 'Semester Course Registration Slip (19 CU)',
        'type': 'Registration Form',
        'status': 'VALIDATED',
        'date': 'Oct 05, 2026',
        'icon': Icons.receipt_long_outlined,
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
                  child: Icon(Icons.folder_shared_outlined, color: AppColors.primary, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            isStudent
                                ? 'My Official Documents & Transcripts'
                                : 'Document Repository & Transcripts',
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
                        isStudent
                            ? 'Download official transcripts, admission letters, and certificates issued by the Registrar.'
                            : 'Generate, sign, and archive official academic documents, attestations, and transcript requests.',
                        style: const TextStyle(color: Colors.white70, fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          SectionHeader(
            title: isStudent ? 'Available Official Records' : 'Institutional Document Archive',
            subtitle: 'Secure digital repository signed by Fah Academy Registrar',
            trailing: isStudent
                ? AppButton(
                    label: 'Request Official Transcript',
                    icon: Icons.add,
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Transcript request submitted to Registrar Office.'),
                          backgroundColor: AppColors.secondary,
                        ),
                      );
                    },
                  )
                : AppButton(
                    label: 'Upload / Issue Document',
                    icon: Icons.upload_file,
                    onPressed: () {},
                  ),
          ),
          const SizedBox(height: 12),

          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: documents.length,
            separatorBuilder: (context, index) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final doc = documents[index];
              return AppCard(
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: AppColors.primaryContainer,
                      child: Icon(doc['icon'] as IconData, color: AppColors.primary),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            doc['title'] as String,
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${doc['type']} • Issued: ${doc['date']}',
                            style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    AppButton(
                      label: 'Download PDF',
                      icon: Icons.download_outlined,
                      variant: AppButtonVariant.secondary,
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Downloading ${doc['title']}...'),
                            backgroundColor: AppColors.secondary,
                          ),
                        );
                      },
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
}
