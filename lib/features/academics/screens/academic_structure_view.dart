import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/permissions/app_permissions.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/section_header.dart';
import '../../../core/widgets/status_chip.dart';
import '../../auth/models/user_profile.dart';

/// Fah Academy SMS — Academic Structure & Operations View
///
/// Implements RBAC:
/// - Super Admin: Full creation & edit of departments, programs, academic years, semesters, cohorts, courses, prerequisites.
/// - Admin: Operational oversight, cohort assignments, class rosters.
/// - Lecturer: View assigned courses & timetable.
/// - Student: View enrolled program, registered courses & requirements.
class AcademicStructureView extends StatefulWidget {
  const AcademicStructureView({
    super.key,
    required this.actorRole,
  });

  final AppRole actorRole;

  @override
  State<AcademicStructureView> createState() => _AcademicStructureViewState();
}

class _AcademicStructureViewState extends State<AcademicStructureView> {
  int _selectedTab = 0; // 0: Departments & Programs, 1: Courses & Prerequisites, 2: Cohorts & Semesters

  final List<Map<String, dynamic>> _departments = [
    {
      'name': 'Faculty of Engineering & Technology',
      'code': 'FET',
      'head': 'Prof. Daniel Fong',
      'programs': [
        'B.Sc. Computer Science (4 Years)',
        'B.Eng. Software Engineering (4 Years)',
        'B.Sc. Information Technology (3 Years)',
      ],
    },
    {
      'name': 'Faculty of Business & Management Sciences',
      'code': 'FBMS',
      'head': 'Dr. Beatrice Mbock',
      'programs': [
        'B.Sc. Accounting & Finance (3 Years)',
        'B.Sc. Marketing & International Trade (3 Years)',
      ],
    },
  ];

  final List<Map<String, dynamic>> _courses = [
    {
      'code': 'CS101',
      'title': 'Introduction to Computer Science',
      'credits': 4,
      'department': 'FET',
      'level': 'Level 100',
      'prerequisite': 'None',
      'semester': 'Semester 1',
    },
    {
      'code': 'CS102',
      'title': 'Data Structures & Algorithms',
      'credits': 4,
      'department': 'FET',
      'level': 'Level 100',
      'prerequisite': 'CS101 (Intro to CS)',
      'semester': 'Semester 2',
    },
    {
      'code': 'MATH101',
      'title': 'Calculus & Linear Algebra',
      'credits': 3,
      'department': 'FET',
      'level': 'Level 100',
      'prerequisite': 'GCE A/L Mathematics',
      'semester': 'Semester 1',
    },
    {
      'code': 'SE201',
      'title': 'Software Architecture & Design Patterns',
      'credits': 4,
      'department': 'FET',
      'level': 'Level 200',
      'prerequisite': 'CS102 (Data Structures)',
      'semester': 'Semester 1',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final isSuperAdmin = widget.actorRole == AppRole.superAdmin;
    final isAdmin = widget.actorRole == AppRole.admin;
    final canEditStructure = RolePermissions.hasPermission(
      widget.actorRole,
      AppPermission.manageAcademicStructure,
    );

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
                  child: Icon(Icons.school_outlined, color: AppColors.primary, size: 28),
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
                                ? 'Academic Structure & Curriculum Setup'
                                : isAdmin
                                    ? 'Academic Operations & Cohorts'
                                    : 'Academic Curriculum & Courses',
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
                            ? 'Configure faculties, degree programs, semester calendar, course prerequisites, and credit rules.'
                            : 'Manage class allocations, student cohorts, assigned lecturers, and lecture hall timetables.',
                        style: const TextStyle(color: Colors.white70, fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Sub-tabs
          Row(
            children: [
              ChoiceChip(
                label: const Text('Departments & Programs'),
                selected: _selectedTab == 0,
                onSelected: (val) => setState(() => _selectedTab = 0),
              ),
              const SizedBox(width: 8),
              ChoiceChip(
                label: const Text('Course Catalog & Prerequisites'),
                selected: _selectedTab == 1,
                onSelected: (val) => setState(() => _selectedTab = 1),
              ),
              const SizedBox(width: 8),
              ChoiceChip(
                label: const Text('Cohorts & Calendar'),
                selected: _selectedTab == 2,
                onSelected: (val) => setState(() => _selectedTab = 2),
              ),
            ],
          ),
          const SizedBox(height: 16),

          if (_selectedTab == 0) ...[
            SectionHeader(
              title: 'Faculties & Degree Programs',
              subtitle: 'Institutional academic units',
              trailing: canEditStructure && isSuperAdmin
                  ? AppButton(
                      label: 'Add Faculty / Program',
                      icon: Icons.add,
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Add program dialog opened.')),
                        );
                      },
                    )
                  : null,
            ),
            const SizedBox(height: 12),
            for (final dept in _departments) ...[
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          dept['name'] as String,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        StatusChip(status: dept['code'] as String),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Dean / HOD: ${dept['head']}',
                      style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Degree Offerings:',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 6),
                    for (final prog in (dept['programs'] as List<String>))
                      Padding(
                        padding: const EdgeInsets.only(left: 8, bottom: 4),
                        child: Row(
                          children: [
                            const Icon(Icons.check_circle_outline, size: 14, color: AppColors.secondary),
                            const SizedBox(width: 6),
                            Text(prog, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
            ],
          ] else if (_selectedTab == 1) ...[
            SectionHeader(
              title: 'Course Catalog & Prerequisite Chains',
              subtitle: 'Courses offered with strict credit unit & prerequisite policies',
              trailing: canEditStructure && isSuperAdmin
                  ? AppButton(
                      label: 'Create Course',
                      icon: Icons.add,
                      onPressed: () {},
                    )
                  : null,
            ),
            const SizedBox(height: 12),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _courses.length,
              separatorBuilder: (context, index) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final c = _courses[index];
                return AppCard(
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppColors.primaryContainer,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          children: [
                            Text(
                              c['code'] as String,
                              style: const TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              '${c['credits']} CU',
                              style: const TextStyle(color: AppColors.textSecondary, fontSize: 11),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              c['title'] as String,
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Level: ${c['level']} • ${c['semester']} • Dept: ${c['department']}',
                              style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(Icons.link, size: 14, color: AppColors.accent),
                                const SizedBox(width: 4),
                                Text(
                                  'Prerequisite: ${c['prerequisite']}',
                                  style: const TextStyle(
                                    color: AppColors.accent,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
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
              },
            ),
          ] else ...[
            const SectionHeader(
              title: 'Cohorts & Academic Semesters',
              subtitle: 'Active enrollment cohorts and academic calendar windows',
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
                        'Academic Year: 2026/2027',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      StatusChip(status: 'ACTIVE SEMESTER 1'),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Semester 1 Duration: Oct 01, 2026 - Feb 28, 2027\nCourse Registration Window: Open (15 - 24 CU)\nExam Period: Feb 10 - Feb 22, 2027',
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
