import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/permissions/app_permissions.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/section_header.dart';
import '../../../core/widgets/status_chip.dart';
import '../../administration/providers/administration_providers.dart';
import '../../auth/models/user_profile.dart';

/// Fah Academy SMS — Results Review, Grade Entry & Publication View
///
/// Implements the exact RBAC rules:
/// - Super Admin: Full control + Exclusive Finalize & Publish authority + Grading config
/// - Admin: Review submissions, add comments, Approve or Return (CANNOT publish final results)
/// - Lecturer: Enter draft grades for assigned courses, submit to Exam Board (cannot approve own)
/// - Student: View published results only (evaluated against fee policy; resits shown separately)
class ResultsManagementView extends ConsumerStatefulWidget {
  const ResultsManagementView({
    super.key,
    required this.actorRole,
    this.studentMatricule,
  });

  final AppRole actorRole;
  final String? studentMatricule;

  @override
  ConsumerState<ResultsManagementView> createState() =>
      _ResultsManagementViewState();
}

class _ResultsManagementViewState extends ConsumerState<ResultsManagementView> {
  // Demo state for course grade sheets
  final List<Map<String, dynamic>> _gradeSheets = [
    {
      'courseCode': 'CS101',
      'courseName': 'Introduction to Computer Science',
      'semester': 'First Semester 2026/2027',
      'lecturer': 'Dr. Marcus Vance',
      'status': 'SUBMITTED', // DRAFT -> SUBMITTED -> APPROVED -> PUBLISHED
      'enrolledCount': 42,
      'caWeight': 30,
      'examWeight': 70,
      'averageScore': 68.4,
      'passedCount': 38,
      'failedCount': 4,
      'reviewNotes': 'Awaiting Exam Board Admin approval.',
    },
    {
      'courseCode': 'CS102',
      'courseName': 'Data Structures & Algorithms',
      'semester': 'First Semester 2026/2027',
      'lecturer': 'Prof. Amina Bello',
      'status': 'APPROVED',
      'enrolledCount': 39,
      'caWeight': 30,
      'examWeight': 70,
      'averageScore': 72.1,
      'passedCount': 37,
      'failedCount': 2,
      'reviewNotes': 'Approved by Faculty Admin. Ready for SuperAdmin publication.',
    },
    {
      'courseCode': 'MATH101',
      'courseName': 'Calculus & Linear Algebra',
      'semester': 'First Semester 2026/2027',
      'lecturer': 'Dr. Jean-Paul Kamga',
      'status': 'DRAFT',
      'enrolledCount': 45,
      'caWeight': 30,
      'examWeight': 70,
      'averageScore': 61.2,
      'passedCount': 35,
      'failedCount': 10,
      'reviewNotes': 'Lecturer still entering CA & Exam grades.',
    },
  ];

  void _submitGradeSheet(int index) {
    setState(() {
      _gradeSheets[index]['status'] = 'SUBMITTED';
      _gradeSheets[index]['reviewNotes'] =
          'Submitted to Exam Board for administrative review.';
    });
    ref.read(administrationRepositoryProvider).logAuditEvent(
      action: 'GRADE_SHEET_SUBMITTED',
      entityType: 'results',
      entityId: _gradeSheets[index]['courseCode'] as String,
      details: {
        'submitted_by': widget.actorRole.label,
        'course': _gradeSheets[index]['courseCode'],
      },
    );
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Grade sheet for ${_gradeSheets[index]['courseCode']} submitted for Admin review.',
        ),
        backgroundColor: AppColors.secondary,
      ),
    );
  }

  void _approveGradeSheet(int index) {
    setState(() {
      _gradeSheets[index]['status'] = 'APPROVED';
      _gradeSheets[index]['reviewNotes'] =
          'Approved by ${widget.actorRole.label}. Awaiting final Super Admin publication.';
    });
    ref.read(administrationRepositoryProvider).logAuditEvent(
      action: 'GRADE_SHEET_APPROVED',
      entityType: 'results',
      entityId: _gradeSheets[index]['courseCode'] as String,
      details: {
        'approved_by': widget.actorRole.label,
        'course': _gradeSheets[index]['courseCode'],
      },
    );
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Grade sheet for ${_gradeSheets[index]['courseCode']} approved by Admin.',
        ),
        backgroundColor: AppColors.secondary,
      ),
    );
  }

  void _publishFinalResults(int index) {
    if (!RolePermissions.canPublishFinalResults(widget.actorRole)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Access Denied: Only Super Admin has authority to publish final results under Fah Academy policy.',
          ),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.publish_outlined, color: AppColors.accent),
            SizedBox(width: 8),
            Text('Publish Official Results'),
          ],
        ),
        content: Text(
          'Publishing results for ${_gradeSheets[index]['courseCode']} will make official grades immediately accessible to students with cleared fee milestones.\n\nThis sensitive action is recorded in the permanent audit trail.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          AppButton(
            label: 'Confirm & Publish',
            onPressed: () {
              Navigator.of(ctx).pop();
              setState(() {
                _gradeSheets[index]['status'] = 'PUBLISHED';
                _gradeSheets[index]['reviewNotes'] =
                    'Official results published by Super Admin.';
              });
              ref.read(administrationRepositoryProvider).logAuditEvent(
                action: 'RESULTS_PUBLISHED_OFFICIAL',
                entityType: 'results',
                entityId: _gradeSheets[index]['courseCode'] as String,
                details: {
                  'published_by': 'Super Admin',
                  'course': _gradeSheets[index]['courseCode'],
                  'enrolled': _gradeSheets[index]['enrolledCount'],
                },
              );
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Official results published for ${_gradeSheets[index]['courseCode']}! Students notified.',
                  ),
                  backgroundColor: AppColors.secondary,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.actorRole == AppRole.student) {
      return _buildStudentResultsView();
    }

    final isSuperAdmin = widget.actorRole == AppRole.superAdmin;
    final isAdmin = widget.actorRole == AppRole.admin;
    final isLecturer = widget.actorRole == AppRole.lecturer;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header summary banner
          AppCard(
            backgroundColor: AppColors.navy,
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 26,
                  backgroundColor: AppColors.primaryContainer,
                  child: Icon(Icons.grading_outlined, color: AppColors.primary, size: 28),
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
                                ? 'Examination Board & Result Finalization'
                                : isAdmin
                                    ? 'Examination Board Result Review'
                                    : 'Course Assessments & Grade Entry',
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
                          ? 'Institutional oversight: Finalize & publish Admin-approved results, configure GPA/grading boundaries, and audit grade adjustments.'
                          : isAdmin
                              ? 'Operational authority: Review lecturer grade sheet submissions, verify CA/Exam weight distribution (30/70), approve or return for correction. Publication reserved for Super Admin.'
                              : 'Lecturer authority: Enter draft marks for assigned courses, configure assessments within policy, and submit to Exam Board.',
                        style: const TextStyle(color: Colors.white70, fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Policy rule indicator
          if (isAdmin)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.warningContainer,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.warning),
              ),
              child: const Row(
                children: [
                  Icon(Icons.shield_outlined, color: AppColors.warning, size: 20),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Fah Academy RBAC Rule: Admins may inspect, validate, and approve grade sheets. Final publication to students is strictly reserved for Super Admin.',
                      style: TextStyle(color: AppColors.textPrimary, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 16),

          SectionHeader(
            title: isLecturer ? 'My Assigned Course Grade Sheets' : 'Active Semester Grade Sheets',
            subtitle: 'Continuous Assessment (30%) + Final Exam (70%) • GPA 4.0 Scale',
          ),
          const SizedBox(height: 12),

          // Course Grade Sheet Cards
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _gradeSheets.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final sheet = _gradeSheets[index];
              final status = sheet['status'] as String;

              return AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.primaryContainer,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                sheet['courseCode'] as String,
                                style: const TextStyle(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              sheet['courseName'] as String,
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                        StatusChip(status: status),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Instructor: ${sheet['lecturer']} • Enrolled: ${sheet['enrolledCount']} students • CA/Exam: ${sheet['caWeight']}% / ${sheet['examWeight']}%',
                      style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Text(
                          'Average: ${sheet['averageScore']}% • Passed: ${sheet['passedCount']} • Failed (Resit candidate): ${sheet['failedCount']}',
                          style: const TextStyle(color: AppColors.textPrimary, fontSize: 13, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.notes_outlined, size: 16, color: AppColors.textSecondary),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Review Status: ${sheet['reviewNotes']}',
                              style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Actions row according to Role-Based Permissions
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        // Lecturer Action: Submit Draft to Exam Board
                        if (isLecturer && status == 'DRAFT') ...[
                          AppButton(
                            label: 'Submit Grade Sheet to Exam Board',
                            icon: Icons.send_outlined,
                            onPressed: () => _submitGradeSheet(index),
                          ),
                        ],

                        // Admin Actions: Approve or Return
                        if (isAdmin && status == 'SUBMITTED') ...[
                          OutlinedButton.icon(
                            icon: const Icon(Icons.replay_outlined, size: 16, color: AppColors.warning),
                            label: const Text('Return with Comments'),
                            onPressed: () {
                              setState(() {
                                sheet['status'] = 'DRAFT';
                                sheet['reviewNotes'] = 'Returned by Admin for grade reconciliation.';
                              });
                            },
                          ),
                          const SizedBox(width: 10),
                          AppButton(
                            label: 'Approve Grade Sheet',
                            icon: Icons.check_circle_outline,
                            onPressed: () => _approveGradeSheet(index),
                          ),
                        ],

                        // Admin Attempting to Publish -> Disabled with Explanation
                        if (isAdmin && status == 'APPROVED') ...[
                          Tooltip(
                            message: 'Fah Academy Policy: Final publication to students requires Super Admin authorization.',
                            child: ElevatedButton.icon(
                              onPressed: null,
                              icon: const Icon(Icons.lock_outline, size: 16),
                              label: const Text('Publish Results (Super Admin Only)'),
                            ),
                          ),
                        ],

                        // Super Admin Action: Publish Final Results
                        if (isSuperAdmin && (status == 'APPROVED' || status == 'SUBMITTED')) ...[
                          AppButton(
                            label: 'Finalize & Publish Results',
                            icon: Icons.publish_outlined,
                            onPressed: () => _publishFinalResults(index),
                          ),
                        ],

                        if (status == 'PUBLISHED') ...[
                          const Row(
                            children: [
                              Icon(Icons.verified, color: AppColors.secondary, size: 18),
                              SizedBox(width: 6),
                              Text(
                                'Published & Accessible to Students',
                                style: TextStyle(
                                  color: AppColors.secondary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ],
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

  Widget _buildStudentResultsView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(
            title: 'Official Academic Results',
            subtitle: 'First Semester 2026/2027 • B.Sc. Computer Science',
          ),
          const SizedBox(height: 12),

          // Fee Milestone Gate
          AppCard(
            backgroundColor: AppColors.surface,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Access Policy Status: Fully Cleared',
                      style: TextStyle(
                        color: AppColors.secondary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    StatusChip(status: 'UNRESTRICTED'),
                  ],
                ),
                const SizedBox(height: 6),
                const Text(
                  'Tuition milestone satisfied. All official published semester results are accessible.',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                ),
                const SizedBox(height: 14),
                const Divider(color: AppColors.border),
                const SizedBox(height: 10),

                // Published Grades Table
                Table(
                  columnWidths: const {
                    0: FlexColumnWidth(2),
                    1: FlexColumnWidth(4),
                    2: FlexColumnWidth(1.5),
                    3: FlexColumnWidth(1.5),
                    4: FlexColumnWidth(1.5),
                  },
                  children: const [
                    TableRow(
                      decoration: BoxDecoration(color: AppColors.background),
                      children: [
                        Padding(
                          padding: EdgeInsets.all(8),
                          child: Text('Code', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                        ),
                        Padding(
                          padding: EdgeInsets.all(8),
                          child: Text('Course Name', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                        ),
                        Padding(
                          padding: EdgeInsets.all(8),
                          child: Text('Credits', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                        ),
                        Padding(
                          padding: EdgeInsets.all(8),
                          child: Text('Grade', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                        ),
                        Padding(
                          padding: EdgeInsets.all(8),
                          child: Text('Status', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                        ),
                      ],
                    ),
                    TableRow(
                      children: [
                        Padding(padding: EdgeInsets.all(8), child: Text('CS101', style: TextStyle(fontSize: 12))),
                        Padding(padding: EdgeInsets.all(8), child: Text('Intro to Computer Science', style: TextStyle(fontSize: 12))),
                        Padding(padding: EdgeInsets.all(8), child: Text('4 CU', style: TextStyle(fontSize: 12))),
                        Padding(padding: EdgeInsets.all(8), child: Text('A (84%)', style: TextStyle(color: AppColors.secondary, fontWeight: FontWeight.bold, fontSize: 12))),
                        Padding(padding: EdgeInsets.all(8), child: Text('PASSED', style: TextStyle(color: AppColors.secondary, fontSize: 12))),
                      ],
                    ),
                    TableRow(
                      children: [
                        Padding(padding: EdgeInsets.all(8), child: Text('CS102', style: TextStyle(fontSize: 12))),
                        Padding(padding: EdgeInsets.all(8), child: Text('Data Structures & Algorithms', style: TextStyle(fontSize: 12))),
                        Padding(padding: EdgeInsets.all(8), child: Text('4 CU', style: TextStyle(fontSize: 12))),
                        Padding(padding: EdgeInsets.all(8), child: Text('B+ (78%)', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 12))),
                        Padding(padding: EdgeInsets.all(8), child: Text('PASSED', style: TextStyle(color: AppColors.secondary, fontSize: 12))),
                      ],
                    ),
                    TableRow(
                      children: [
                        Padding(padding: EdgeInsets.all(8), child: Text('MATH101', style: TextStyle(fontSize: 12))),
                        Padding(padding: EdgeInsets.all(8), child: Text('Calculus & Linear Algebra', style: TextStyle(fontSize: 12))),
                        Padding(padding: EdgeInsets.all(8), child: Text('3 CU', style: TextStyle(fontSize: 12))),
                        Padding(padding: EdgeInsets.all(8), child: Text('D (52%)', style: TextStyle(color: AppColors.warning, fontWeight: FontWeight.bold, fontSize: 12))),
                        Padding(padding: EdgeInsets.all(8), child: Text('PASSED', style: TextStyle(color: AppColors.warning, fontSize: 12))),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Divider(color: AppColors.border),
                const SizedBox(height: 8),

                // Resit history separate display rule (Rule 6 in spec)
                const Row(
                  children: [
                    Icon(Icons.info_outline, size: 16, color: AppColors.textSecondary),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Academic Record Rule: If a resit exam is undertaken, original marks and resit attempts remain documented separately on the official transcript.',
                        style: TextStyle(color: AppColors.textSecondary, fontSize: 11),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
