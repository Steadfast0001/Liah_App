import 'package:flutter/material.dart';

import 'app_colors.dart';

enum ResultPublicationStatus {
  published,
  unpublished,
  restricted,
}

class StudentResultsPage extends StatefulWidget {
  const StudentResultsPage({super.key});

  @override
  State<StudentResultsPage> createState() => _StudentResultsPageState();
}

class _StudentResultsPageState extends State<StudentResultsPage> {
  String _selectedSemester = '2025/2026 Semester 2';

  final List<String> _semesters = [
    '2026/2027 Semester 1',
    '2025/2026 Semester 2',
    '2025/2026 Semester 1',
  ];

  // Specific rule: Distinct state for unpublished, published, and restricted results
  final Map<String, ResultPublicationStatus> _semesterStatusMap = {
    '2026/2027 Semester 1': ResultPublicationStatus.unpublished, // Undergoing senate moderation
    '2025/2026 Semester 2': ResultPublicationStatus.published,   // Published & Available
    '2025/2026 Semester 1': ResultPublicationStatus.published,   // Published & Available
  };

  // Specific rule: Do not fabricate a GPA or CGPA when required data is missing
  final Map<String, double?> _semesterGpaMap = {
    '2026/2027 Semester 1': null, // Missing / Unpublished -> MUST NOT fabricate!
    '2025/2026 Semester 2': 3.68,
    '2025/2026 Semester 1': 3.56,
  };

  final double _cgpa = 3.62;

  // Grade records for 2025/2026 Semester 2 (Published)
  // Specific rule: Display original failed attempt separately from any resit attempt!
  final List<Map<String, dynamic>> _publishedCourseResults = [
    {
      'code': 'SWE102',
      'title': 'Object-Oriented Design in C++',
      'caMark': 26.5, // out of 30
      'examMark': 58.0, // out of 70
      'totalScore': 84.5,
      'grade': 'A',
      'gradePoint': 4.0,
      'credits': 4,
      'sessionType': 'Normal Session',
      'status': 'Passed',
    },
    {
      'code': 'CEF104',
      'title': 'Computer Systems & Digital Electronics',
      'caMark': 22.0,
      'examMark': 48.0,
      'totalScore': 70.0,
      'grade': 'B+',
      'gradePoint': 3.5,
      'credits': 4,
      'sessionType': 'Normal Session',
      'status': 'Passed',
    },
    {
      'code': 'MAT102',
      'title': 'Linear Algebra & Analytic Geometry',
      'caMark': 20.0,
      'examMark': 42.0,
      'totalScore': 62.0,
      'grade': 'B',
      'gradePoint': 3.0,
      'credits': 4,
      'sessionType': 'Normal Session',
      'status': 'Passed',
    },
    // FAILED ATTEMPT (Documented explicitly)
    {
      'code': 'PHY102',
      'title': 'Electricity, Magnetism & Wave Mechanics',
      'caMark': 11.0,
      'examMark': 24.0,
      'totalScore': 35.0,
      'grade': 'F',
      'gradePoint': 0.0,
      'credits': 4,
      'sessionType': 'Normal Session (Initial Attempt)',
      'status': 'Failed',
    },
    // SEPARATE RESIT (RATTRAPAGE) ATTEMPT
    {
      'code': 'PHY102',
      'title': 'Electricity, Magnetism & Wave Mechanics',
      'caMark': 11.0, // Retained CA /30
      'examMark': 43.0, // Resit exam /70
      'totalScore': 54.0,
      'grade': 'C',
      'gradePoint': 2.0,
      'credits': 4,
      'sessionType': 'Rattrapage / Resit Attempt',
      'status': 'Passed (Resit)',
    },
    {
      'code': 'ENG102',
      'title': 'Bilingual Written & Oral Expression',
      'caMark': 25.0,
      'examMark': 50.0,
      'totalScore': 75.0,
      'grade': 'A-',
      'gradePoint': 3.7,
      'credits': 4,
      'sessionType': 'Normal Session',
      'status': 'Passed',
    },
  ];

  void _showResultDetailModal(Map<String, dynamic> item) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        final isFailed = item['grade'] == 'F';
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('${item['code']}: ${item['title']}', style: const TextStyle(color: AppColors.onNavy, fontSize: 15, fontWeight: FontWeight.bold)),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: isFailed ? const Color(0xFF5E1717) : const Color(0xFF0F5132),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'Grade ${item['grade']}',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: AppColors.navy, borderRadius: BorderRadius.circular(6)),
                child: Text('Session: ${item['sessionType']}', style: const TextStyle(color: AppColors.gold, fontWeight: FontWeight.bold, fontSize: 11)),
              ),
              const SizedBox(height: 14),
              _buildModalMetricRow('Continuous Assessment (CA)', '${item['caMark']} / 30'),
              const SizedBox(height: 6),
              _buildModalMetricRow('Final Examination Mark', '${item['examMark']} / 70'),
              const SizedBox(height: 6),
              _buildModalMetricRow('Total Score', '${item['totalScore']} / 100'),
              const SizedBox(height: 6),
              _buildModalMetricRow('Credit Units', '${item['credits']} Credits'),
              const SizedBox(height: 6),
              _buildModalMetricRow('Grade Point Value (GP)', '${item['gradePoint']}'),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.gold, minimumSize: const Size.fromHeight(42)),
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Close', style: TextStyle(color: AppColors.navyDeep, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildModalMetricRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: AppColors.muted, fontSize: 12)),
        Text(value, style: const TextStyle(color: AppColors.onNavy, fontWeight: FontWeight.bold, fontSize: 13)),
      ],
    );
  }

  void _downloadOfficialResultSheet() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Downloading official authorized Result Sheet (PDF) for $_selectedSemester...'),
        backgroundColor: const Color(0xFF0F5132),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final status = _semesterStatusMap[_selectedSemester] ?? ResultPublicationStatus.published;
    final gpa = _semesterGpaMap[_selectedSemester];

    return Scaffold(
      backgroundColor: AppColors.navy,
      appBar: AppBar(
        backgroundColor: AppColors.navy,
        elevation: 0,
        title: const Text('Academic Results & GPA', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
        actions: [
          if (status == ResultPublicationStatus.published)
            IconButton(
              icon: const Icon(Icons.download, color: AppColors.gold),
              tooltip: 'Download Result Sheet (PDF)',
              onPressed: _downloadOfficialResultSheet,
            ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Semester Selector Dropdown
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Select Academic Semester:', style: TextStyle(color: AppColors.muted, fontSize: 12)),
                    DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedSemester,
                        dropdownColor: AppColors.surface,
                        style: const TextStyle(color: AppColors.gold, fontWeight: FontWeight.bold, fontSize: 13),
                        items: _semesters.map((s) {
                          return DropdownMenuItem<String>(value: s, child: Text(s));
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) setState(() => _selectedSemester = val);
                        },
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // 2. Performance Summary Card (GPA & CGPA)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('SEMESTER GPA', style: TextStyle(color: AppColors.muted, fontSize: 10, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          // Specific rule: Do not fabricate a GPA when data is missing/unpublished
                          Text(
                            gpa != null ? gpa.toStringAsFixed(2) : '— (Pending)',
                            style: TextStyle(
                              color: gpa != null ? AppColors.gold : AppColors.muted,
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 2),
                          const Text('Scale of 4.00', style: TextStyle(color: AppColors.muted, fontSize: 10)),
                        ],
                      ),
                    ),
                    Container(width: 1, height: 44, color: AppColors.border),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('CUMULATIVE CGPA', style: TextStyle(color: AppColors.muted, fontSize: 10, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 4),
                            Text(
                              _cgpa.toStringAsFixed(2),
                              style: const TextStyle(color: AppColors.onNavy, fontSize: 22, fontWeight: FontWeight.w900),
                            ),
                            const SizedBox(height: 2),
                            const Text('First Class Honors', style: TextStyle(color: Color(0xFF34D399), fontSize: 10, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // 3. Status Handling: Published vs Unpublished vs Restricted
              if (status == ResultPublicationStatus.unpublished) ...[
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF261D05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.gold.withValues(alpha: 0.6)),
                  ),
                  child: const Column(
                    children: [
                      Icon(Icons.hourglass_top, color: AppColors.gold, size: 38),
                      SizedBox(height: 12),
                      Text(
                        'Results Under Senate Moderation',
                        style: TextStyle(color: AppColors.onNavy, fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Results for 2026/2027 Semester 1 are currently undergoing departmental moderation and senate ratification. They have not yet been published.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: AppColors.muted, fontSize: 12, height: 1.4),
                      ),
                    ],
                  ),
                ),
              ] else if (status == ResultPublicationStatus.restricted) ...[
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF3B1010),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFF87171)),
                  ),
                  child: const Column(
                    children: [
                      Icon(Icons.lock, color: Color(0xFFF87171), size: 38),
                      SizedBox(height: 12),
                      Text(
                        'Semester Results Restricted',
                        style: TextStyle(color: AppColors.onNavy, fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Results for this semester are restricted due to outstanding fee balance. Please clear pending fees with the Bursary to unblock your result slip.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: AppColors.muted, fontSize: 12, height: 1.4),
                      ),
                    ],
                  ),
                ),
              ] else ...[
                // Published Results List
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('OFFICIAL COURSE SCORES', style: TextStyle(color: AppColors.onNavy, fontSize: 13, fontWeight: FontWeight.bold)),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.gold,
                        foregroundColor: AppColors.navyDeep,
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      onPressed: _downloadOfficialResultSheet,
                      icon: const Icon(Icons.picture_as_pdf, size: 14),
                      label: const Text('Result Slip', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                ListView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: _publishedCourseResults.length,
                  itemBuilder: (context, i) {
                    final item = _publishedCourseResults[i];
                    final isFailed = item['grade'] == 'F';
                    final isResit = item['sessionType'].toString().contains('Resit') || item['sessionType'].toString().contains('Rattrapage');

                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isFailed ? const Color(0xFFF87171).withValues(alpha: 0.6) : AppColors.border,
                          width: isFailed ? 1.2 : 0.8,
                        ),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        leading: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: isFailed ? const Color(0xFF5E1717) : (isResit ? const Color(0xFF261D05) : AppColors.navy),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: isFailed ? const Color(0xFFF87171) : (isResit ? AppColors.gold : AppColors.border)),
                          ),
                          child: Center(
                            child: Text(
                              item['grade'],
                              style: TextStyle(
                                color: isFailed ? const Color(0xFFF87171) : (isResit ? AppColors.gold : AppColors.onNavy),
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        ),
                        title: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(item['code'], style: const TextStyle(color: AppColors.gold, fontWeight: FontWeight.bold, fontSize: 13)),
                            Text('${item['totalScore']} / 100', style: const TextStyle(color: AppColors.onNavy, fontWeight: FontWeight.w700, fontSize: 13)),
                          ],
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 3),
                            Text(item['title'], style: const TextStyle(color: AppColors.onNavy, fontSize: 12, fontWeight: FontWeight.w500)),
                            const SizedBox(height: 3),
                            Row(
                              children: [
                                Text('CA: ${item['caMark']}/30', style: const TextStyle(color: AppColors.muted, fontSize: 11)),
                                const SizedBox(width: 8),
                                Text('Exam: ${item['examMark']}/70', style: const TextStyle(color: AppColors.muted, fontSize: 11)),
                                const SizedBox(width: 8),
                                Text('(${item['sessionType']})', style: TextStyle(color: isFailed ? const Color(0xFFF87171) : AppColors.gold, fontSize: 10, fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ],
                        ),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 13, color: AppColors.muted),
                        onTap: () => _showResultDetailModal(item),
                      ),
                    );
                  },
                ),
              ],
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
