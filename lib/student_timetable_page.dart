import 'package:flutter/material.dart';

import 'app_colors.dart';

class StudentTimetablePage extends StatefulWidget {
  const StudentTimetablePage({super.key});

  @override
  State<StudentTimetablePage> createState() => _StudentTimetablePageState();
}

class _StudentTimetablePageState extends State<StudentTimetablePage> {
  int _selectedDayIndex = 0; // 0: Mon, 1: Tue, 2: Wed, 3: Thu, 4: Fri
  int _selectedWeekOffset = 0; // 0: Current week, +1: Next week, -1: Prev week
  bool _isWeekView = false;

  final List<String> _days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday'];

  final Map<int, List<Map<String, dynamic>>> _timetableData = {
    0: [
      {
        'code': 'SWE201',
        'title': 'Data Structures & Algorithms',
        'time': '10:00 - 12:00',
        'venue': 'Amphi 250 (Main Campus)',
        'lecturer': 'Dr. Paul F. Tiku',
        'type': 'Lecture',
      },
      {
        'code': 'CEF205',
        'title': 'Computer Architecture & Assembly',
        'time': '14:00 - 16:00',
        'venue': 'Hardware Lab 1',
        'lecturer': 'Dr. Marie Ngu',
        'type': 'Practical Lab',
      },
    ],
    1: [
      {
        'code': 'SWE203',
        'title': 'Object-Oriented Programming (Java)',
        'time': '08:00 - 10:00',
        'venue': 'Amphi 100',
        'lecturer': 'Engr. Divine Mbella',
        'type': 'Lecture',
      },
      {
        'code': 'ENG203',
        'title': 'Technical Communication & French',
        'time': '14:00 - 16:00',
        'venue': 'Hall B',
        'lecturer': 'Mme. Clarisse Eyenga',
        'type': 'Tutorial',
      },
    ],
    2: [
      {
        'code': 'MAT201',
        'title': 'Advanced Calculus & Real Analysis',
        'time': '08:00 - 10:00',
        'venue': 'Amphi 250',
        'lecturer': 'Prof. Fonkeng Joseph',
        'type': 'Lecture',
      },
      {
        'code': 'SWE201',
        'title': 'Data Structures Lab Session',
        'time': '14:00 - 16:00',
        'venue': 'Computer Lab 3',
        'lecturer': 'Dr. Paul F. Tiku',
        'type': 'Lab Practice',
      },
    ],
    3: [
      {
        'code': 'SWE203',
        'title': 'OOP Java Coding Lab',
        'time': '10:00 - 12:00',
        'venue': 'Computer Lab 2',
        'lecturer': 'Engr. Divine Mbella',
        'type': 'Lab Practice',
      },
      {
        'code': 'ICT207',
        'title': 'Database Management Systems (SQL)',
        'time': '14:00 - 17:00',
        'venue': 'Amphi 150',
        'lecturer': 'Dr. Jean-Pierre Ndongo',
        'type': 'Lecture & Workshop',
      },
    ],
    4: [
      {
        'code': 'CEF205',
        'title': 'Digital Logic Tutorial',
        'time': '10:00 - 12:00',
        'venue': 'Room 104',
        'lecturer': 'Dr. Marie Ngu',
        'type': 'Tutorial',
      },
      {
        'code': 'MAT201',
        'title': 'Calculus Problem Session',
        'time': '14:00 - 16:00',
        'venue': 'Amphi 100',
        'lecturer': 'Prof. Fonkeng Joseph',
        'type': 'Tutorial',
      },
    ],
  };

  void _showCourseDetailModal(Map<String, dynamic> session) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.navy,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: AppColors.gold),
                    ),
                    child: Text(
                      session['code'],
                      style: const TextStyle(color: AppColors.gold, fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.goldTint,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      session['type'],
                      style: const TextStyle(color: AppColors.gold, fontWeight: FontWeight.bold, fontSize: 11),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                session['title'],
                style: const TextStyle(color: AppColors.onNavy, fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              _buildModalRow(Icons.schedule, 'Time', session['time']),
              const SizedBox(height: 8),
              _buildModalRow(Icons.location_on_outlined, 'Venue', session['venue']),
              const SizedBox(height: 8),
              _buildModalRow(Icons.person_outline, 'Lecturer', session['lecturer']),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.gold, minimumSize: const Size.fromHeight(44)),
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
        Icon(icon, size: 16, color: AppColors.gold),
        const SizedBox(width: 8),
        Text('$label: ', style: const TextStyle(color: AppColors.muted, fontSize: 12)),
        Expanded(
          child: Text(value, style: const TextStyle(color: AppColors.onNavy, fontWeight: FontWeight.w600, fontSize: 12.5)),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final daySessions = _timetableData[_selectedDayIndex] ?? [];
    final weekLabel = _selectedWeekOffset == 0
        ? 'Current Week (Week 8)'
        : (_selectedWeekOffset > 0 ? 'Next Week (Week ${_selectedWeekOffset + 8})' : 'Past Week');

    return Scaffold(
      backgroundColor: AppColors.navy,
      appBar: AppBar(
        backgroundColor: AppColors.navy,
        elevation: 0,
        title: const Text('Timetable & Schedule', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
        actions: [
          IconButton(
            icon: Icon(_isWeekView ? Icons.view_day_outlined : Icons.view_week_outlined, color: AppColors.gold),
            tooltip: _isWeekView ? 'Switch to Day View' : 'Switch to Week View',
            onPressed: () => setState(() => _isWeekView = !_isWeekView),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // 1. Week Navigator & Schedule Notice Banner
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              color: AppColors.navyDeep,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left, color: AppColors.gold),
                    onPressed: () => setState(() => _selectedWeekOffset--),
                  ),
                  Column(
                    children: [
                      Text(weekLabel, style: const TextStyle(color: AppColors.onNavy, fontWeight: FontWeight.bold, fontSize: 13)),
                      const Text('2026/2027 • First Semester', style: TextStyle(color: AppColors.muted, fontSize: 10.5)),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.chevron_right, color: AppColors.gold),
                    onPressed: () => setState(() => _selectedWeekOffset++),
                  ),
                ],
              ),
            ),

            // Schedule Notice Banner (e.g. Holiday / Special Schedule Notice)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: const Color(0xFF2E2405),
              child: const Row(
                children: [
                  Icon(Icons.info_outline, color: AppColors.gold, size: 16),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Schedule Notice: Amphi 250 acoustics maintenance on Thursday 14:00.',
                      style: TextStyle(color: AppColors.gold, fontSize: 11),
                    ),
                  ),
                ],
              ),
            ),

            // 2. Day Tabs (Day View)
            if (!_isWeekView) ...[
              Container(
                decoration: const BoxDecoration(
                  color: AppColors.surface,
                  border: Border(bottom: BorderSide(color: AppColors.border, width: 0.8)),
                ),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  child: Row(
                    children: List.generate(_days.length, (i) {
                      final isSelected = _selectedDayIndex == i;
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: ChoiceChip(
                          label: Text(_days[i]),
                          selected: isSelected,
                          selectedColor: AppColors.gold,
                          backgroundColor: AppColors.navy,
                          labelStyle: TextStyle(
                            color: isSelected ? AppColors.navyDeep : AppColors.muted,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                          onSelected: (val) {
                            if (val) setState(() => _selectedDayIndex = i);
                          },
                        ),
                      );
                    }),
                  ),
                ),
              ),
            ],

            // 3. Timetable Content (Day View or Full Week View)
            Expanded(
              child: _isWeekView
                  ? _buildWeekView()
                  : (daySessions.isEmpty
                      ? const Center(
                          child: Text('No lectures scheduled for this day.', style: TextStyle(color: AppColors.muted)),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: daySessions.length,
                          itemBuilder: (context, i) {
                            final session = daySessions[i];
                            return _buildSessionCard(session);
                          },
                        )),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSessionCard(Map<String, dynamic> session) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(14),
        leading: Container(
          width: 50,
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.navy,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.gold),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(session['code'].substring(0, 3), style: const TextStyle(color: AppColors.muted, fontSize: 9, fontWeight: FontWeight.bold)),
              Text(session['code'].substring(3), style: const TextStyle(color: AppColors.gold, fontSize: 13, fontWeight: FontWeight.w900)),
            ],
          ),
        ),
        title: Text(
          session['title'],
          style: const TextStyle(color: AppColors.onNavy, fontWeight: FontWeight.bold, fontSize: 13.5),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(Icons.access_time, size: 14, color: AppColors.gold),
                const SizedBox(width: 4),
                Text(session['time'], style: const TextStyle(color: AppColors.onNavy, fontSize: 12, fontWeight: FontWeight.w600)),
                const SizedBox(width: 10),
                const Icon(Icons.room, size: 14, color: AppColors.muted),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(session['venue'], style: const TextStyle(color: AppColors.muted, fontSize: 11.5), overflow: TextOverflow.ellipsis),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text('Lecturer: ${session['lecturer']}', style: const TextStyle(color: AppColors.muted, fontSize: 11)),
          ],
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: AppColors.muted),
        onTap: () => _showCourseDetailModal(session),
      ),
    );
  }

  Widget _buildWeekView() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _days.length,
      itemBuilder: (context, dayIdx) {
        final dayName = _days[dayIdx];
        final sessions = _timetableData[dayIdx] ?? [];

        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(dayName, style: const TextStyle(color: AppColors.gold, fontWeight: FontWeight.bold, fontSize: 13)),
                  Text('${sessions.length} sessions', style: const TextStyle(color: AppColors.muted, fontSize: 11)),
                ],
              ),
              const Divider(color: AppColors.border, height: 16),
              if (sessions.isEmpty)
                const Text('No classes', style: TextStyle(color: AppColors.muted, fontSize: 11))
              else
                ...sessions.map((s) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: InkWell(
                        onTap: () => _showCourseDetailModal(s),
                        child: Row(
                          children: [
                            Text(s['time'], style: const TextStyle(color: AppColors.muted, fontSize: 11, fontWeight: FontWeight.bold)),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text('${s['code']} • ${s['title']} (${s['venue']})',
                                  style: const TextStyle(color: AppColors.onNavy, fontSize: 11.5, fontWeight: FontWeight.w600),
                                  overflow: TextOverflow.ellipsis),
                            ),
                          ],
                        ),
                      ),
                    )),
            ],
          ),
        );
      },
    );
  }
}
