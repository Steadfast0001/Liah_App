import 'package:flutter/material.dart';

import 'app_colors.dart';

class StudentAnnouncementsPage extends StatefulWidget {
  const StudentAnnouncementsPage({super.key});

  @override
  State<StudentAnnouncementsPage> createState() => _StudentAnnouncementsPageState();
}

class _StudentAnnouncementsPageState extends State<StudentAnnouncementsPage> {
  final List<Map<String, dynamic>> _announcements = [
    {
      'id': 'ann-1',
      'title': 'Mid-Semester Continuous Assessment (CA) Schedule',
      'message':
          'Official CA sessions for the 2026/2027 First Semester will take place from Monday 10 November to Saturday 15 November 2026. All students must present their student ID badge and course registration receipt before entering examination halls.',
      'date': '21 Oct 2026',
      'publisher': 'Office of the Academic Registrar',
      'category': 'Examinations',
      'attachment': 'CA_Timetable_Schedule_2026.pdf',
      'isRead': false,
    },
    {
      'id': 'ann-2',
      'title': 'Bursary Second Installment (XAF) Reminder',
      'message':
          'Students are advised that the deadline for clearing the second tuition installment (75% total fees) is Friday 31 October 2026. Meeting this milestone is mandatory for printing verified exam admission slips.',
      'date': '19 Oct 2026',
      'publisher': 'University Bursary Office',
      'category': 'Finance',
      'attachment': 'Bursary_Bank_Details_Instructions.pdf',
      'isRead': false,
    },
    {
      'id': 'ann-3',
      'title': 'Guest Lecture: Industrial Cloud Infrastructure in Central Africa',
      'message':
          'The Department of Software Engineering invites all Level 200 and Level 300 engineering students to a special lecture on DevOps, Kubernetes, and regional data sovereignty in Amphi 250 on Wednesday 28 October at 15:00.',
      'date': '15 Oct 2026',
      'publisher': 'Faculty of Engineering & Technology',
      'category': 'Academic Events',
      'attachment': null,
      'isRead': true,
    },
    {
      'id': 'ann-4',
      'title': 'MINESUP Inter-University Sports & Games Selection',
      'message':
          'Tryouts for the upcoming National University Games in Ngaoundéré will begin next week at the university sports complex. Registered student athletes should contact the Sports Directorate.',
      'date': '10 Oct 2026',
      'publisher': 'Directorate of Student Affairs',
      'category': 'Campus Life',
      'attachment': null,
      'isRead': true,
    },
  ];

  void _showNoticeDetailModal(Map<String, dynamic> notice) {
    setState(() => notice['isRead'] = true);

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.goldTint,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          notice['category'],
                          style: const TextStyle(color: AppColors.gold, fontWeight: FontWeight.bold, fontSize: 11),
                        ),
                      ),
                      Text(notice['date'], style: const TextStyle(color: AppColors.muted, fontSize: 11)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    notice['title'],
                    style: const TextStyle(color: AppColors.onNavy, fontSize: 17, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  Text('Published by: ${notice['publisher']}', style: const TextStyle(color: AppColors.gold, fontSize: 12, fontWeight: FontWeight.w600)),
                  const Divider(color: AppColors.border, height: 24),
                  Text(
                    notice['message'],
                    style: const TextStyle(color: AppColors.onNavy, fontSize: 13.5, height: 1.5),
                  ),
                  if (notice['attachment'] != null) ...[
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.navy,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.picture_as_pdf, color: AppColors.gold, size: 24),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Official Attachment', style: TextStyle(color: AppColors.muted, fontSize: 10)),
                                Text(notice['attachment']!, style: const TextStyle(color: AppColors.onNavy, fontWeight: FontWeight.bold, fontSize: 12)),
                              ],
                            ),
                          ),
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.gold,
                              foregroundColor: AppColors.navyDeep,
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Downloading ${notice['attachment']}...'), backgroundColor: const Color(0xFF0F5132)),
                              );
                            },
                            icon: const Icon(Icons.download, size: 14),
                            label: const Text('Download', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 20),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.gold, minimumSize: const Size.fromHeight(42)),
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text('Close', style: TextStyle(color: AppColors.navyDeep, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.navy,
      appBar: AppBar(
        backgroundColor: AppColors.navy,
        elevation: 0,
        title: const Text('Announcements Board', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
      ),
      body: SafeArea(
        child: ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          itemCount: _announcements.length,
          itemBuilder: (context, i) {
            final notice = _announcements[i];
            final isRead = notice['isRead'] as bool;

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isRead ? AppColors.border : AppColors.gold.withValues(alpha: 0.6),
                  width: isRead ? 0.8 : 1.2,
                ),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.navy,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    notice['attachment'] != null ? Icons.attach_file : Icons.campaign_outlined,
                    color: isRead ? AppColors.muted : AppColors.gold,
                    size: 22,
                  ),
                ),
                title: Row(
                  children: [
                    if (!isRead)
                      Container(
                        width: 7,
                        height: 7,
                        margin: const EdgeInsets.only(right: 6),
                        decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.gold),
                      ),
                    Expanded(
                      child: Text(
                        notice['title'],
                        style: TextStyle(
                          color: AppColors.onNavy,
                          fontWeight: isRead ? FontWeight.w600 : FontWeight.bold,
                          fontSize: 13.5,
                        ),
                      ),
                    ),
                  ],
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),
                    Text(
                      notice['message'],
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: AppColors.muted, fontSize: 11.5),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('${notice['publisher']} • ${notice['date']}', style: const TextStyle(color: AppColors.gold, fontSize: 10, fontWeight: FontWeight.bold)),
                        if (notice['attachment'] != null)
                          const Row(
                            children: [
                              Icon(Icons.attachment, size: 12, color: AppColors.muted),
                              SizedBox(width: 2),
                              Text('PDF Attached', style: TextStyle(color: AppColors.muted, fontSize: 10)),
                            ],
                          ),
                      ],
                    ),
                  ],
                ),
                onTap: () => _showNoticeDetailModal(notice),
              ),
            );
          },
        ),
      ),
    );
  }
}
