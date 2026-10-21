import 'package:flutter/material.dart';
import 'package:liah_app/app_colors.dart';
import 'package:liah_app/attendance_register_page.dart';

/// Staff Timetable Page (Section 5 — Lecturer / Staff Pages)
/// UI content: Weekly schedule, courses, venues and times.
/// Required interactions: Change week and inspect class details.
class StaffTimetablePage extends StatefulWidget {
  const StaffTimetablePage({super.key});

  @override
  State<StaffTimetablePage> createState() => _StaffTimetablePageState();
}

class _StaffTimetablePageState extends State<StaffTimetablePage> {
  int _currentWeekOffset = 0; // 0: Current Week, -1: Prev, +1: Next
  int _selectedDayIndex = 0; // 0: Mon, 1: Tue, 2: Wed, 3: Thu, 4: Fri
  bool _isWeekView = false;

  final List<String> _days = const ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday'];

  final Map<int, List<Map<String, dynamic>>> _scheduleData = {
    0: [
      {
        'code': 'SWE201',
        'title': 'Data Structures & Algorithms',
        'time': '10:00 - 12:00',
        'venue': 'Amphi 250 (Main Campus)',
        'cohort': 'Level 200 - Software Eng',
        'type': 'Theory Lecture',
        'students': 42,
      },
    ],
    1: [
      {
        'code': 'CEF205',
        'title': 'Computer Architecture & Assembly',
        'time': '14:00 - 16:00',
        'venue': 'Hardware Lab 1',
        'cohort': 'Level 200 - Computer Eng',
        'type': 'Practical Lab',
        'students': 38,
      },
    ],
    2: [
      {
        'code': 'SWE201',
        'title': 'Data Structures & Algorithms (Tutorial)',
        'time': '08:00 - 10:00',
        'venue': 'Amphi 100',
        'cohort': 'Level 200 - Software Eng',
        'type': 'Tutorial Session',
        'students': 42,
      },
    ],
    3: [
      {
        'code': 'CEF205',
        'title': 'Computer Architecture & Assembly',
        'time': '10:00 - 12:00',
        'venue': 'Hardware Lab 1',
        'cohort': 'Level 200 - Computer Eng',
        'type': 'Theory Lecture',
        'students': 38,
      },
      {
        'code': 'FAC-OFFICE',
        'title': 'Faculty Office Consultation Hours',
        'time': '14:00 - 16:00',
        'venue': 'Block C - Office 204',
        'cohort': 'All Engineering Students',
        'type': 'Office Consultation',
        'students': 0,
      },
    ],
    4: [
      {
        'code': 'SWE203',
        'title': 'Object-Oriented Programming (Java)',
        'time': '08:00 - 11:00',
        'venue': 'Software Lab 3',
        'cohort': 'Level 200 - Software Eng',
        'type': 'Lab Practical',
        'students': 36,
      },
    ],
  };

  String get _weekRangeTitle {
    if (_currentWeekOffset == 0) return 'Current Teaching Week • 19 - 23 Oct 2026';
    if (_currentWeekOffset == -1) return 'Previous Week • 12 - 16 Oct 2026';
    if (_currentWeekOffset == 1) return 'Next Week • 26 - 30 Oct 2026';
    return 'Teaching Week ${_currentWeekOffset > 0 ? "+$_currentWeekOffset" : "$_currentWeekOffset"}';
  }

  void _showSessionDetailModal(Map<String, dynamic> session) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
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
              const SizedBox(height: 14),
              _buildModalRow(Icons.schedule, 'Time', session['time']),
              const SizedBox(height: 8),
              _buildModalRow(Icons.location_on_outlined, 'Venue', session['venue']),
              const SizedBox(height: 8),
              _buildModalRow(Icons.groups_outlined, 'Enrolled Cohort', '${session['cohort']} (${session['students']} students)'),
              const SizedBox(height: 20),
              if (session['students'] > 0)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.how_to_reg, size: 16),
                    label: const Text('Launch Attendance Register', style: TextStyle(fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.gold,
                      foregroundColor: AppColors.navyDeep,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    onPressed: () {
                      Navigator.pop(ctx);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => AttendanceRegisterPage(initialCourseCode: session['code']),
                        ),
                      );
                    },
                  ),
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
        const SizedBox(width: 10),
        Text('$label: ', style: const TextStyle(color: AppColors.muted, fontSize: 12)),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(color: AppColors.onNavy, fontSize: 12.5, fontWeight: FontWeight.w600),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  void _downloadTimetablePdf() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        backgroundColor: AppColors.surfaceRaised,
        content: Row(
          children: [
            Icon(Icons.picture_as_pdf, color: AppColors.gold, size: 20),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                'Faculty teaching timetable downloaded as official PDF.',
                style: TextStyle(color: AppColors.onNavy, fontSize: 13),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final daySessions = _scheduleData[_selectedDayIndex] ?? [];

    return Scaffold(
      backgroundColor: AppColors.navy,
      appBar: AppBar(
        backgroundColor: AppColors.navyDeep,
        elevation: 0,
        title: const Text(
          'Teaching Timetable',
          style: TextStyle(color: AppColors.onNavy, fontSize: 16, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: Icon(_isWeekView ? Icons.view_day_outlined : Icons.view_week_outlined, color: AppColors.gold),
            tooltip: _isWeekView ? 'Switch to Day View' : 'Switch to Week View',
            onPressed: () => setState(() => _isWeekView = !_isWeekView),
          ),
          IconButton(
            icon: const Icon(Icons.picture_as_pdf, color: AppColors.gold),
            tooltip: 'Download Timetable PDF',
            onPressed: _downloadTimetablePdf,
          ),
        ],
      ),
      body: Column(
        children: [
          // 1. Week Navigation Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: const BoxDecoration(
              color: AppColors.surface,
              border: Border(bottom: BorderSide(color: AppColors.border, width: 0.8)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left, color: AppColors.gold),
                  onPressed: () => setState(() => _currentWeekOffset--),
                ),
                Text(
                  _weekRangeTitle,
                  style: const TextStyle(color: AppColors.gold, fontSize: 12.5, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right, color: AppColors.gold),
                  onPressed: () => setState(() => _currentWeekOffset++),
                ),
              ],
            ),
          ),

          // 2. Day Selector Tabs (if not full week view)
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

          // 3. Timetable Content (Day View or Full Week Grid View)
          Expanded(
            child: _isWeekView
                ? _buildWeekView()
                : (daySessions.isEmpty
                    ? const Center(
                        child: Text('No teaching sessions scheduled for this day.', style: TextStyle(color: AppColors.muted)),
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
    );
  }

  Widget _buildSessionCard(Map<String, dynamic> session) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border, width: 0.8),
      ),
      child: ListTile(
        onTap: () => _showSessionDetailModal(session),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.gold.withValues(alpha: 0.15),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.school, color: AppColors.gold, size: 20),
        ),
        title: Row(
          children: [
            Text(
              session['code'],
              style: const TextStyle(color: AppColors.gold, fontWeight: FontWeight.bold, fontSize: 13),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                session['title'],
                style: const TextStyle(color: AppColors.onNavy, fontWeight: FontWeight.bold, fontSize: 13),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.schedule, size: 12, color: AppColors.muted),
                const SizedBox(width: 4),
                Text(session['time'], style: const TextStyle(color: AppColors.muted, fontSize: 11.5)),
                const SizedBox(width: 10),
                const Icon(Icons.location_on_outlined, size: 12, color: AppColors.muted),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(session['venue'], style: const TextStyle(color: AppColors.muted, fontSize: 11.5), overflow: TextOverflow.ellipsis),
                ),
              ],
            ),
          ],
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: AppColors.muted),
      ),
    );
  }

  Widget _buildWeekView() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _days.length,
      itemBuilder: (context, dayIdx) {
        final dayName = _days[dayIdx];
        final sessions = _scheduleData[dayIdx] ?? [];

        return Container(
          margin: const EdgeInsets.only(bottom: 14),
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
                const Text('No teaching commitments', style: TextStyle(color: AppColors.muted, fontSize: 11))
              else
                ...sessions.map((s) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: InkWell(
                        onTap: () => _showSessionDetailModal(s),
                        child: Row(
                          children: [
                            Text(s['time'], style: const TextStyle(color: AppColors.muted, fontSize: 11, fontWeight: FontWeight.bold)),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                '${s['code']} • ${s['title']} (${s['venue']})',
                                style: const TextStyle(color: AppColors.onNavy, fontSize: 11.5, fontWeight: FontWeight.w600),
                                overflow: TextOverflow.ellipsis,
                              ),
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
