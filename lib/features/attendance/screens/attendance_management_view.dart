import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/permissions/app_permissions.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/section_header.dart';
import '../../../core/widgets/status_chip.dart';
import '../../auth/models/user_profile.dart';

/// Fah Academy SMS — Attendance & Timetable Management View
///
/// Implements RBAC:
/// - SuperAdmin & Admin: Full oversight & attendance corrections across all cohorts.
/// - Lecturer: Record attendance for assigned classes; view teaching timetable.
/// - Student: View personal attendance records & timetable.
class AttendanceManagementView extends StatefulWidget {
  const AttendanceManagementView({
    super.key,
    required this.actorRole,
  });

  final AppRole actorRole;

  @override
  State<AttendanceManagementView> createState() =>
      _AttendanceManagementViewState();
}

class _AttendanceManagementViewState extends State<AttendanceManagementView> {
  // Demo roster for recording attendance
  final List<Map<String, dynamic>> _roster = [
    {
      'matricule': 'FA-2026-BSC-0001',
      'name': 'Achu Brandon Ngu',
      'status': 'PRESENT',
    },
    {
      'matricule': 'FA-2026-BSC-0002',
      'name': 'Bih Clara Lum',
      'status': 'PRESENT',
    },
    {
      'matricule': 'FA-2026-BSC-0003',
      'name': 'Che Jude Ambe',
      'status': 'LATE',
    },
    {
      'matricule': 'FA-2026-BSC-0004',
      'name': 'Djeuga Audrey Ornella',
      'status': 'ABSENT',
    },
  ];

  void _cycleStatus(int index) {
    if (!RolePermissions.canRecordAttendance(widget.actorRole)) return;

    setState(() {
      final current = _roster[index]['status'];
      _roster[index]['status'] = switch (current) {
        'PRESENT' => 'LATE',
        'LATE' => 'ABSENT',
        _ => 'PRESENT',
      };
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.actorRole == AppRole.student) {
      return _buildStudentAttendanceView();
    }

    final isLecturer = widget.actorRole == AppRole.lecturer;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Banner
          AppCard(
            backgroundColor: AppColors.navy,
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 26,
                  backgroundColor: AppColors.primaryContainer,
                  child: Icon(Icons.fact_check_outlined, color: AppColors.primary, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            isLecturer
                                ? 'Lecture Attendance Session'
                                : 'Attendance & Timetable Oversight',
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
                        isLecturer
                            ? 'CS101: Introduction to Computer Science • Hall 3B • Today, 10:00 - 12:00'
                            : 'Monitor student lecture attendance percentages and schedule lectures across amphitheatres.',
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
            title: 'Class Roster Attendance Sheet',
            subtitle: 'Tap on any student status to toggle between PRESENT, LATE, or ABSENT',
            trailing: AppButton(
              label: 'Save & Submit Session',
              icon: Icons.save_outlined,
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Attendance session saved and synced to student portal.'),
                    backgroundColor: AppColors.secondary,
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 12),

          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _roster.length,
            separatorBuilder: (context, index) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final student = _roster[index];
              final status = student['status'] as String;

              final statusColor = switch (status) {
                'PRESENT' => AppColors.secondary,
                'LATE' => AppColors.warning,
                _ => AppColors.error,
              };

              return AppCard(
                onTap: () => _cycleStatus(index),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: statusColor.withValues(alpha: 0.15),
                      child: Text(
                        '${index + 1}',
                        style: TextStyle(
                          color: statusColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            student['name'] as String,
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            student['matricule'] as String,
                            style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    InkWell(
                      onTap: () => _cycleStatus(index),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: statusColor),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              status == 'PRESENT'
                                  ? Icons.check
                                  : status == 'LATE'
                                      ? Icons.access_time
                                      : Icons.close,
                              size: 14,
                              color: statusColor,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              status,
                              style: TextStyle(
                                color: statusColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
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

  Widget _buildStudentAttendanceView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(
            title: 'My Course Attendance Statistics',
            subtitle: 'Minimum 75% attendance required to sit for semester examinations',
          ),
          const SizedBox(height: 12),

          const AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'CS101: Intro to Computer Science',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    StatusChip(status: '92% ATTENDANCE'),
                  ],
                ),
                SizedBox(height: 8),
                Text(
                  '12 of 13 sessions attended • 1 Late • 0 Absences',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                ),
                SizedBox(height: 10),
                LinearProgressIndicator(
                  value: 0.92,
                  backgroundColor: AppColors.background,
                  color: AppColors.secondary,
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          const AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'MATH101: Calculus & Linear Algebra',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    StatusChip(status: '85% ATTENDANCE'),
                  ],
                ),
                SizedBox(height: 8),
                Text(
                  '11 of 13 sessions attended • 0 Late • 2 Absences',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                ),
                SizedBox(height: 10),
                LinearProgressIndicator(
                  value: 0.85,
                  backgroundColor: AppColors.background,
                  color: AppColors.primary,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
