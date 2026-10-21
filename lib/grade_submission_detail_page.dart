import 'package:flutter/material.dart';
import 'package:liah_app/app_colors.dart';
import 'package:liah_app/grade_entry_page.dart';

/// Grade Submission Detail Page (Section 5 — Lecturer / Staff Pages)
/// UI content: Submitted grade sheet, status, submission date and Admin comments.
/// Required interactions: View status and revise only when returned or otherwise permitted.
class GradeSubmissionDetailPage extends StatefulWidget {
  final String courseCode;
  final String submissionStatus; // 'Submitted' | 'Returned with Corrections' | 'Approved by Senate'

  const GradeSubmissionDetailPage({
    super.key,
    this.courseCode = 'SWE201',
    this.submissionStatus = 'Returned with Corrections',
  });

  @override
  State<GradeSubmissionDetailPage> createState() => _GradeSubmissionDetailPageState();
}

class _GradeSubmissionDetailPageState extends State<GradeSubmissionDetailPage> {
  late String _currentStatus;

  @override
  void initState() {
    super.initState();
    _currentStatus = widget.submissionStatus;
  }

  bool get _isRevisionPermitted {
    return _currentStatus == 'Returned with Corrections' || _currentStatus == 'Draft';
  }

  void _downloadOfficialSubmissionPdf() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.surfaceRaised,
        content: Row(
          children: [
            const Icon(Icons.picture_as_pdf, color: AppColors.gold, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Official grade submission record for ${widget.courseCode} downloaded as PDF.',
                style: const TextStyle(color: AppColors.onNavy, fontSize: 13),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Color statusColor = const Color(0xFFF59E0B);
    if (_currentStatus == 'Approved by Senate') {
      statusColor = const Color(0xFF10B981);
    } else if (_currentStatus == 'Returned with Corrections') {
      statusColor = const Color(0xFFEF4444);
    } else if (_currentStatus == 'Submitted') {
      statusColor = const Color(0xFF3B82F6);
    }

    return Scaffold(
      backgroundColor: AppColors.navy,
      appBar: AppBar(
        backgroundColor: AppColors.navyDeep,
        elevation: 0,
        title: Text(
          '${widget.courseCode} Grade Submission Record',
          style: const TextStyle(color: AppColors.onNavy, fontSize: 16, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf, color: AppColors.gold),
            tooltip: 'Download PDF',
            onPressed: _downloadOfficialSubmissionPdf,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Status & Metadata Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border, width: 0.8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.navy,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: AppColors.gold),
                        ),
                        child: Text(
                          widget.courseCode,
                          style: const TextStyle(color: AppColors.gold, fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: statusColor, width: 0.8),
                        ),
                        child: Text(
                          _currentStatus,
                          style: TextStyle(color: statusColor, fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Data Structures & Algorithms (2026/2027 S1)',
                    style: TextStyle(color: AppColors.onNavy, fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  _buildMetaRow(Icons.calendar_today, 'Submission Timestamp', '18 Oct 2026 at 16:45 GMT+1'),
                  const SizedBox(height: 6),
                  _buildMetaRow(Icons.person, 'Submitted By', 'Engr. Divine Mbella (Senior Lecturer)'),
                  const SizedBox(height: 6),
                  _buildMetaRow(Icons.groups, 'Audited Records', '42 Enrolled Students (40 Completed, 2 Medicals)'),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 2. Admin & HOD Review Comments Section
            const Text(
              'DEPARTMENT & SENATE MODERATION FEEDBACK',
              style: TextStyle(color: AppColors.gold, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.5),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: _currentStatus == 'Returned with Corrections' ? const Color(0xFFEF4444) : AppColors.border,
                  width: 0.8,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        _currentStatus == 'Returned with Corrections' ? Icons.warning_amber_rounded : Icons.comment_outlined,
                        size: 18,
                        color: _currentStatus == 'Returned with Corrections' ? const Color(0xFFEF4444) : AppColors.gold,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _currentStatus == 'Returned with Corrections'
                            ? 'Action Required: Returned by HOD'
                            : 'Moderation Remarks',
                        style: TextStyle(
                          color: _currentStatus == 'Returned with Corrections' ? const Color(0xFFEF4444) : AppColors.onNavy,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _currentStatus == 'Returned with Corrections'
                        ? 'HOD Remarks (Prof. Fonkeng): "Please review CA scores for student Alain Fotso (LIAH-2024-SW0514) who submitted an authorized medical certificate for the mid-term test. Re-submit the adjusted sheet by Friday 17:00."'
                        : 'Grade moderation completed with no abnormalities. Distributed normal bell curve verified against MINESUP standards.',
                    style: const TextStyle(color: AppColors.onNavy, fontSize: 12.5, height: 1.4),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 3. Grade Distribution Summary
            const Text(
              'GRADE DISTRIBUTION BREAKDOWN',
              style: TextStyle(color: AppColors.gold, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.5),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.border, width: 0.8),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildGradeCountPill('A', '8', const Color(0xFF10B981)),
                      _buildGradeCountPill('B+', '12', const Color(0xFF34D399)),
                      _buildGradeCountPill('B', '10', const Color(0xFF60A5FA)),
                      _buildGradeCountPill('C+', '6', const Color(0xFFF59E0B)),
                      _buildGradeCountPill('C', '4', const Color(0xFFFBBF24)),
                      _buildGradeCountPill('F', '2', const Color(0xFFEF4444)),
                    ],
                  ),
                  const Divider(color: AppColors.border, height: 20),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Class Average Score: 68.4 / 100', style: TextStyle(color: AppColors.muted, fontSize: 12)),
                      Text('Pass Rate: 95.2%', style: TextStyle(color: Color(0xFF10B981), fontWeight: FontWeight.bold, fontSize: 12)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // 4. Revise Action Button (Enabled only if returned or permitted)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.edit_note, size: 18),
                label: Text(
                  _isRevisionPermitted
                      ? 'Revise & Correct Grade Sheet'
                      : 'Revision Locked (Approved by Senate)',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isRevisionPermitted ? AppColors.gold : AppColors.border,
                  foregroundColor: AppColors.navyDeep,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: !_isRevisionPermitted
                    ? null
                    : () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (_) => GradeEntryPage(initialCourseCode: widget.courseCode),
                          ),
                        );
                      },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetaRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 14, color: AppColors.gold),
        const SizedBox(width: 8),
        Text('$label: ', style: const TextStyle(color: AppColors.muted, fontSize: 11.5)),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(color: AppColors.onNavy, fontSize: 12, fontWeight: FontWeight.w600),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildGradeCountPill(String grade, String count, Color color) {
    return Column(
      children: [
        Text(
          grade,
          style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 14),
        ),
        const SizedBox(height: 2),
        Text(
          '$count std',
          style: const TextStyle(color: AppColors.muted, fontSize: 10),
        ),
      ],
    );
  }
}
