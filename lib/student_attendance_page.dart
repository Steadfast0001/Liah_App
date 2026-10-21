import 'package:flutter/material.dart';

import 'app_colors.dart';

class StudentAttendancePage extends StatefulWidget {
  const StudentAttendancePage({super.key});

  @override
  State<StudentAttendancePage> createState() => _StudentAttendancePageState();
}

class _StudentAttendancePageState extends State<StudentAttendancePage> {
  String _selectedCourseCode = 'ALL';

  final List<String> _courseCodes = ['ALL', 'SWE201', 'SWE203', 'CEF205', 'MAT201', 'ENG203', 'ICT207'];

  final List<Map<String, dynamic>> _courseSummaries = [
    {
      'code': 'SWE201',
      'title': 'Data Structures & Algorithms',
      'attended': 22,
      'total': 24,
      'percentage': 91.7,
      'lecturer': 'Dr. Paul F. Tiku',
    },
    {
      'code': 'SWE203',
      'title': 'Object-Oriented Programming (Java)',
      'attended': 18,
      'total': 20,
      'percentage': 90.0,
      'lecturer': 'Engr. Divine Mbella',
    },
    {
      'code': 'CEF205',
      'title': 'Computer Architecture & Assembly',
      'attended': 15,
      'total': 20,
      'percentage': 75.0,
      'lecturer': 'Dr. Marie Ngu',
    },
    {
      'code': 'MAT201',
      'title': 'Advanced Calculus & Real Analysis',
      'attended': 13,
      'total': 20,
      'percentage': 65.0, // Below 75% MINESUP threshold
      'lecturer': 'Prof. Fonkeng Joseph',
    },
    {
      'code': 'ENG203',
      'title': 'Technical Communication & French',
      'attended': 10,
      'total': 10,
      'percentage': 100.0,
      'lecturer': 'Mme. Clarisse Eyenga',
    },
    {
      'code': 'ICT207',
      'title': 'Database Management Systems (SQL)',
      'attended': 16,
      'total': 18,
      'percentage': 88.9,
      'lecturer': 'Dr. Jean-Pierre Ndongo',
    },
  ];

  final List<Map<String, dynamic>> _allSessions = [
    {
      'courseCode': 'SWE201',
      'courseTitle': 'Data Structures',
      'date': '20 Oct 2026',
      'time': '10:00 - 12:00',
      'topic': 'Binary Search Trees & Balancing (AVL)',
      'status': 'Present',
      'room': 'Amphi 250',
      'lecturer': 'Dr. Paul F. Tiku',
    },
    {
      'courseCode': 'SWE203',
      'courseTitle': 'OOP Java',
      'date': '19 Oct 2026',
      'time': '08:00 - 10:00',
      'topic': 'Polymorphism & Abstract Class Hierarchies',
      'status': 'Present',
      'room': 'Amphi 100',
      'lecturer': 'Engr. Divine Mbella',
    },
    {
      'courseCode': 'MAT201',
      'courseTitle': 'Advanced Calculus',
      'date': '18 Oct 2026',
      'time': '08:00 - 10:00',
      'topic': 'Multiple Integrals in Polar Coordinates',
      'status': 'Absent',
      'room': 'Amphi 250',
      'lecturer': 'Prof. Fonkeng Joseph',
    },
    {
      'courseCode': 'CEF205',
      'courseTitle': 'Computer Architecture',
      'date': '17 Oct 2026',
      'time': '14:00 - 16:00',
      'topic': 'Pipelining & Hazard Mitigation',
      'status': 'Late',
      'room': 'Hardware Lab 1',
      'lecturer': 'Dr. Marie Ngu',
    },
    {
      'courseCode': 'ICT207',
      'courseTitle': 'Database Systems',
      'date': '16 Oct 2026',
      'time': '14:00 - 17:00',
      'topic': 'Indexing Strategies & B-Trees in Postgres',
      'status': 'Present',
      'room': 'Amphi 150',
      'lecturer': 'Dr. Jean-Pierre Ndongo',
    },
  ];

  void _showSessionDetailModal(Map<String, dynamic> session) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        final isPresent = session['status'] == 'Present';
        final isLate = session['status'] == 'Late';
        final color = isPresent
            ? const Color(0xFF34D399)
            : (isLate ? Colors.orange : const Color(0xFFF87171));

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${session['courseCode']} Attendance Session',
                    style: const TextStyle(color: AppColors.onNavy, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: color),
                    ),
                    child: Text(
                      session['status'],
                      style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Text(session['topic'], style: const TextStyle(color: AppColors.onNavy, fontWeight: FontWeight.bold, fontSize: 14)),
              const SizedBox(height: 12),
              _buildModalRow(Icons.calendar_today, 'Session Date', session['date']),
              const SizedBox(height: 6),
              _buildModalRow(Icons.access_time, 'Lecture Time', session['time']),
              const SizedBox(height: 6),
              _buildModalRow(Icons.location_on_outlined, 'Lecture Hall', session['room']),
              const SizedBox(height: 6),
              _buildModalRow(Icons.person_outline, 'Signing Lecturer', session['lecturer']),
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

  Widget _buildModalRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 15, color: AppColors.gold),
        const SizedBox(width: 8),
        Text('$label: ', style: const TextStyle(color: AppColors.muted, fontSize: 12)),
        Expanded(
          child: Text(value, style: const TextStyle(color: AppColors.onNavy, fontSize: 12.5, fontWeight: FontWeight.w600)),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredSessions = _selectedCourseCode == 'ALL'
        ? _allSessions
        : _allSessions.where((s) => s['courseCode'] == _selectedCourseCode).toList();

    return Scaffold(
      backgroundColor: AppColors.navy,
      appBar: AppBar(
        backgroundColor: AppColors.navy,
        elevation: 0,
        title: const Text('Attendance Records', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. MINESUP Regulatory Policy Warning
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF261D05),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.gold.withValues(alpha: 0.6)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.gavel, color: AppColors.gold, size: 20),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'MINESUP Regulation: Minimum 75% course attendance is required to be certified for final semester examinations.',
                        style: TextStyle(color: AppColors.gold, fontSize: 11, height: 1.3),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // 2. Course Attendance Summary Carousel / Horizontal Cards
              const Text('COURSE ATTENDANCE RATIOS', style: TextStyle(color: AppColors.muted, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.6)),
              const SizedBox(height: 8),
              SizedBox(
                height: 120,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _courseSummaries.length,
                  itemBuilder: (context, i) {
                    final item = _courseSummaries[i];
                    final pct = item['percentage'] as double;
                    final isLow = pct < 75.0;

                    return Container(
                      width: 150,
                      margin: const EdgeInsets.only(right: 10),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isLow ? const Color(0xFFF87171) : AppColors.border,
                          width: isLow ? 1.2 : 0.8,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(item['code'], style: const TextStyle(color: AppColors.gold, fontWeight: FontWeight.bold, fontSize: 13)),
                              if (isLow)
                                const Icon(Icons.warning_amber_rounded, color: Color(0xFFF87171), size: 16),
                            ],
                          ),
                          Text('${pct.toStringAsFixed(1)}%', style: TextStyle(color: isLow ? const Color(0xFFF87171) : const Color(0xFF34D399), fontSize: 20, fontWeight: FontWeight.w900)),
                          Text(
                            '${item['attended']}/${item['total']} Sessions',
                            style: const TextStyle(color: AppColors.muted, fontSize: 11),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),

              // 3. Filter Selector
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('LOGGED SESSIONS', style: TextStyle(color: AppColors.onNavy, fontSize: 13, fontWeight: FontWeight.bold)),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedCourseCode,
                        dropdownColor: AppColors.surface,
                        icon: const Icon(Icons.filter_list, size: 16, color: AppColors.gold),
                        items: _courseCodes.map((c) {
                          return DropdownMenuItem<String>(
                            value: c,
                            child: Text(c, style: const TextStyle(color: AppColors.onNavy, fontSize: 12, fontWeight: FontWeight.bold)),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) setState(() => _selectedCourseCode = val);
                        },
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // 4. Session Records List
              if (filteredSessions.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 32),
                    child: Text('No attendance records logged for this filter.', style: TextStyle(color: AppColors.muted)),
                  ),
                )
              else
                ListView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: filteredSessions.length,
                  itemBuilder: (context, i) {
                    final session = filteredSessions[i];
                    final isPresent = session['status'] == 'Present';
                    final isLate = session['status'] == 'Late';
                    final badgeColor = isPresent
                        ? const Color(0xFF0F5132)
                        : (isLate ? const Color(0xFF3B2F0F) : const Color(0xFF5E1717));
                    final textColor = isPresent
                        ? const Color(0xFF34D399)
                        : (isLate ? Colors.orange : const Color(0xFFF87171));

                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                        leading: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: AppColors.navy,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Center(
                            child: Text(
                              session['courseCode'].substring(0, 3),
                              style: const TextStyle(color: AppColors.gold, fontWeight: FontWeight.bold, fontSize: 11),
                            ),
                          ),
                        ),
                        title: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('${session['courseCode']}: ${session['courseTitle']}', style: const TextStyle(color: AppColors.onNavy, fontWeight: FontWeight.bold, fontSize: 13)),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(color: badgeColor, borderRadius: BorderRadius.circular(4)),
                              child: Text(session['status'], style: TextStyle(color: textColor, fontSize: 10, fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 3),
                            Text(session['topic'], style: const TextStyle(color: AppColors.muted, fontSize: 11.5)),
                            const SizedBox(height: 2),
                            Text('${session['date']} • ${session['time']} • ${session['room']}', style: const TextStyle(color: AppColors.gold, fontSize: 10.5, fontWeight: FontWeight.w600)),
                          ],
                        ),
                        onTap: () => _showSessionDetailModal(session),
                      ),
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}
