import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'course_registration_page.dart';

class StudentAcademicsPage extends StatefulWidget {
  const StudentAcademicsPage({
    super.key,
    this.academicYear = '2026/2027',
    this.program = 'B.Eng. Software Engineering',
    this.level = 'Level 200 (Year 2)',
    this.cohort = 'Cohort 2024/2025',
  });

  final String academicYear;
  final String program;
  final String level;
  final String cohort;

  @override
  State<StudentAcademicsPage> createState() => _StudentAcademicsPageState();
}

class _StudentAcademicsPageState extends State<StudentAcademicsPage> {
  int _selectedSemesterIndex = 0; // 0: Semester 1, 1: Semester 2

  final List<Map<String, dynamic>> _semester1Courses = [
    {
      'code': 'SWE201',
      'title': 'Data Structures & Algorithms',
      'credits': 4,
      'lecturer': 'Dr. Paul F. Tiku',
      'status': 'Registered',
      'schedule': 'Mon 10:00 - 12:00, Wed 14:00 - 16:00',
    },
    {
      'code': 'SWE203',
      'title': 'Object-Oriented Programming (Java)',
      'credits': 4,
      'lecturer': 'Engr. Divine Mbella',
      'status': 'Registered',
      'schedule': 'Tue 08:00 - 10:00, Thu 10:00 - 12:00',
    },
    {
      'code': 'CEF205',
      'title': 'Computer Architecture & Assembly',
      'credits': 4,
      'lecturer': 'Dr. Marie Ngu',
      'status': 'Registered',
      'schedule': 'Mon 14:00 - 16:00, Fri 10:00 - 12:00',
    },
    {
      'code': 'MAT201',
      'title': 'Advanced Calculus & Real Analysis',
      'credits': 4,
      'lecturer': 'Prof. Fonkeng Joseph',
      'status': 'Registered',
      'schedule': 'Wed 08:00 - 10:00, Fri 14:00 - 16:00',
    },
    {
      'code': 'ENG203',
      'title': 'Technical Communication & French',
      'credits': 4,
      'lecturer': 'Mme. Clarisse Eyenga',
      'status': 'Registered',
      'schedule': 'Tue 14:00 - 16:00',
    },
    {
      'code': 'ICT207',
      'title': 'Database Management Systems (SQL)',
      'credits': 4,
      'lecturer': 'Dr. Jean-Pierre Ndongo',
      'status': 'Registered',
      'schedule': 'Thu 14:00 - 17:00 (Lab 2)',
    },
  ];

  final List<Map<String, dynamic>> _semester2Courses = [
    {
      'code': 'SWE202',
      'title': 'Software Modeling & Design (UML)',
      'credits': 4,
      'lecturer': 'Dr. Paul F. Tiku',
      'status': 'Upcoming',
      'schedule': 'Spring Term 2027',
    },
    {
      'code': 'SWE204',
      'title': 'Web Application Engineering',
      'credits': 4,
      'lecturer': 'Engr. Divine Mbella',
      'status': 'Upcoming',
      'schedule': 'Spring Term 2027',
    },
    {
      'code': 'ICT208',
      'title': 'Computer Networks & Protocols',
      'credits': 4,
      'lecturer': 'Dr. Marie Ngu',
      'status': 'Upcoming',
      'schedule': 'Spring Term 2027',
    },
    {
      'code': 'MAT202',
      'title': 'Discrete Mathematics & Logic',
      'credits': 4,
      'lecturer': 'Prof. Fonkeng Joseph',
      'status': 'Upcoming',
      'schedule': 'Spring Term 2027',
    },
    {
      'code': 'SWE206',
      'title': 'Operating Systems & Linux Kernel',
      'credits': 4,
      'lecturer': 'Dr. Jean-Pierre Ndongo',
      'status': 'Upcoming',
      'schedule': 'Spring Term 2027',
    },
  ];

  void _showCourseDetailModal(Map<String, dynamic> course) {
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
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.navy,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: AppColors.gold),
                    ),
                    child: Text(
                      course['code'],
                      style: const TextStyle(color: AppColors.gold, fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F5132),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      course['status'],
                      style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                course['title'],
                style: const TextStyle(color: AppColors.onNavy, fontSize: 17, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              _buildDetailItem('Assigned Lecturer', course['lecturer'], Icons.person_outline),
              const SizedBox(height: 8),
              _buildDetailItem('Credit Allocation', '${course['credits']} Credit Units (MINESUP Standard)', Icons.stars_outlined),
              const SizedBox(height: 8),
              _buildDetailItem('Lecture Schedule', course['schedule'], Icons.schedule_outlined),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.gold,
                  minimumSize: const Size.fromHeight(44),
                ),
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Close', style: TextStyle(color: AppColors.navyDeep, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailItem(String label, String value, IconData icon) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: AppColors.gold),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(color: AppColors.muted, fontSize: 11)),
              Text(value, style: const TextStyle(color: AppColors.onNavy, fontSize: 13, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final activeCourses = _selectedSemesterIndex == 0 ? _semester1Courses : _semester2Courses;
    final totalCredits = activeCourses.fold<int>(0, (sum, c) => sum + (c['credits'] as int));

    return Scaffold(
      backgroundColor: AppColors.navy,
      appBar: AppBar(
        backgroundColor: AppColors.navy,
        elevation: 0,
        title: const Text('Academics & Courses', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
        actions: [
          TextButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CourseRegistrationPage()),
              );
            },
            icon: const Icon(Icons.add_circle_outline, size: 16, color: AppColors.gold),
            label: const Text('Register', style: TextStyle(color: AppColors.gold, fontWeight: FontWeight.bold, fontSize: 13)),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Program & Academic Context Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(widget.program, style: const TextStyle(color: AppColors.onNavy, fontWeight: FontWeight.bold, fontSize: 15)),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.navy,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: AppColors.gold),
                          ),
                          child: Text(widget.academicYear, style: const TextStyle(color: AppColors.gold, fontSize: 11, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${widget.level} • ${widget.cohort}',
                      style: const TextStyle(color: AppColors.muted, fontSize: 12),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // 2. Semester Selector Tabs
              Container(
                decoration: BoxDecoration(
                  color: AppColors.navyDeep,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () => setState(() => _selectedSemesterIndex = 0),
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: _selectedSemesterIndex == 0 ? AppColors.gold : Colors.transparent,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            'First Semester',
                            style: TextStyle(
                              color: _selectedSemesterIndex == 0 ? AppColors.navyDeep : AppColors.muted,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: InkWell(
                        onTap: () => setState(() => _selectedSemesterIndex = 1),
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: _selectedSemesterIndex == 1 ? AppColors.gold : Colors.transparent,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            'Second Semester',
                            style: TextStyle(
                              color: _selectedSemesterIndex == 1 ? AppColors.navyDeep : AppColors.muted,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // 3. Registered-Course Count and Credits Summary Banner
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.school, color: AppColors.gold, size: 18),
                        const SizedBox(width: 8),
                        Text(
                          '${activeCourses.length} Registered Courses',
                          style: const TextStyle(color: AppColors.onNavy, fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.goldTint,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '$totalCredits Total Credits',
                        style: const TextStyle(color: AppColors.gold, fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // 4. Course Offerings List
              ListView.builder(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: activeCourses.length,
                itemBuilder: (context, i) {
                  final course = activeCourses[i];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      leading: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.navy,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Text(
                          course['code'],
                          style: const TextStyle(color: AppColors.gold, fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                      ),
                      title: Text(
                        course['title'],
                        style: const TextStyle(color: AppColors.onNavy, fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 3),
                          Text('${course['lecturer']} • ${course['credits']} cr', style: const TextStyle(color: AppColors.muted, fontSize: 11.5)),
                        ],
                      ),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: AppColors.muted),
                      onTap: () => _showCourseDetailModal(course),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
