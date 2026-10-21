import 'package:flutter/material.dart';

import 'app_colors.dart';

enum CourseRegistrationState {
  available,
  selected,
  registered,
  prerequisiteBlocked,
  closed,
}

class CourseOfferingItem {
  final String code;
  final String title;
  final int credits;
  final String? prerequisite;
  final String lecturer;
  final CourseRegistrationState state;
  final String? blockedReason;

  const CourseOfferingItem({
    required this.code,
    required this.title,
    required this.credits,
    this.prerequisite,
    required this.lecturer,
    required this.state,
    this.blockedReason,
  });
}

class CourseRegistrationPage extends StatefulWidget {
  const CourseRegistrationPage({
    super.key,
    this.initialRegisteredCodes,
    this.registrationClosed = false,
    this.hasFeeRestriction = false,
  });

  final Set<String>? initialRegisteredCodes;
  final bool registrationClosed;
  final bool hasFeeRestriction;

  @override
  State<CourseRegistrationPage> createState() => _CourseRegistrationPageState();
}

class _CourseRegistrationPageState extends State<CourseRegistrationPage> {
  // Deadline string
  static const String registrationDeadline =
      'Deadline: 15 November 2026 • 23:59 GMT+1';

  late Set<String> _registeredCourseCodes;
  late Set<String> _selectedCourseCodes;
  bool _isSubmitting = false;

  final List<CourseOfferingItem> _allEligibleCourses = const [
    CourseOfferingItem(
      code: 'SWE201',
      title: 'Data Structures & Algorithms',
      credits: 4,
      prerequisite: 'SWE101 (Intro to Programming)',
      lecturer: 'Dr. Paul F. Tiku',
      state: CourseRegistrationState.registered,
    ),
    CourseOfferingItem(
      code: 'SWE203',
      title: 'Object-Oriented Programming (Java)',
      credits: 4,
      prerequisite: 'SWE101 (Intro to Programming)',
      lecturer: 'Engr. Divine Mbella',
      state: CourseRegistrationState.registered,
    ),
    CourseOfferingItem(
      code: 'CEF205',
      title: 'Computer Architecture & Assembly',
      credits: 4,
      prerequisite: 'PHY102 (Electricity & Magnetism)',
      lecturer: 'Dr. Marie Ngu',
      state: CourseRegistrationState.registered,
    ),
    CourseOfferingItem(
      code: 'MAT201',
      title: 'Advanced Calculus & Real Analysis',
      credits: 4,
      prerequisite: 'MAT101 (Linear Algebra & Calculus)',
      lecturer: 'Prof. Fonkeng Joseph',
      state: CourseRegistrationState.available,
    ),
    CourseOfferingItem(
      code: 'ENG203',
      title: 'Technical Communication & French',
      credits: 4,
      prerequisite: null,
      lecturer: 'Mme. Clarisse Eyenga',
      state: CourseRegistrationState.available,
    ),
    CourseOfferingItem(
      code: 'ICT207',
      title: 'Database Management Systems (SQL)',
      credits: 4,
      prerequisite: null,
      lecturer: 'Dr. Jean-Pierre Ndongo',
      state: CourseRegistrationState.available,
    ),
    CourseOfferingItem(
      code: 'SWE205',
      title: 'Advanced Software Testing & QA',
      credits: 4,
      prerequisite: 'SWE201 (Data Structures)',
      lecturer: 'Dr. Paul F. Tiku',
      state: CourseRegistrationState.prerequisiteBlocked,
      blockedReason: 'Requires SWE201 to be completed and graded first.',
    ),
    CourseOfferingItem(
      code: 'ICT209',
      title: 'Special Topics in Artificial Intelligence',
      credits: 4,
      prerequisite: null,
      lecturer: 'Guest Lecturer',
      state: CourseRegistrationState.closed,
      blockedReason: 'Cohort quota full (60/60 Students enrolled).',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _registeredCourseCodes = widget.initialRegisteredCodes ?? {'SWE201', 'SWE203', 'CEF205'};
    _selectedCourseCodes = {'MAT201', 'ENG203', 'ICT207'};
  }

  int get _totalSelectedCredits {
    int total = 0;
    for (final c in _allEligibleCourses) {
      if (_registeredCourseCodes.contains(c.code) || _selectedCourseCodes.contains(c.code)) {
        total += c.credits;
      }
    }
    return total;
  }

  void _toggleSelection(CourseOfferingItem course) {
    if (_registeredCourseCodes.contains(course.code)) return;
    if (course.state == CourseRegistrationState.prerequisiteBlocked ||
        course.state == CourseRegistrationState.closed) {
      _showPrerequisiteDetails(course);
      return;
    }

    setState(() {
      if (_selectedCourseCodes.contains(course.code)) {
        _selectedCourseCodes.remove(course.code);
      } else {
        _selectedCourseCodes.add(course.code);
      }
    });
  }

  void _showPrerequisiteDetails(CourseOfferingItem course) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: AppColors.surface,
          title: Row(
            children: [
              Icon(
                course.state == CourseRegistrationState.closed
                    ? Icons.lock_clock
                    : Icons.warning_amber_rounded,
                color: course.state == CourseRegistrationState.closed ? Colors.orange : const Color(0xFFF87171),
              ),
              const SizedBox(width: 8),
              Text(
                course.state == CourseRegistrationState.closed ? 'Course Closed' : 'Prerequisite Requirement',
                style: const TextStyle(color: AppColors.onNavy, fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('${course.code}: ${course.title}', style: const TextStyle(color: AppColors.onNavy, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              if (course.prerequisite != null) ...[
                const Text('Required Prerequisite:', style: TextStyle(color: AppColors.muted, fontSize: 12)),
                const SizedBox(height: 2),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: AppColors.navy, borderRadius: BorderRadius.circular(6)),
                  child: Text(course.prerequisite!, style: const TextStyle(color: AppColors.gold, fontWeight: FontWeight.bold, fontSize: 12)),
                ),
                const SizedBox(height: 10),
              ],
              Text(
                course.blockedReason ?? 'You cannot select this course at this time.',
                style: const TextStyle(color: AppColors.muted, fontSize: 12, height: 1.4),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.gold),
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Understood', style: TextStyle(color: AppColors.navyDeep, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  void _showConfirmRegistrationDialog() {
    if (widget.registrationClosed) {
      _showErrorAlert('Registration is currently closed by the Academic Registrar.');
      return;
    }
    if (widget.hasFeeRestriction) {
      _showErrorAlert('Registration blocked: Minimum 50% tuition payment required before course enrollment.');
      return;
    }

    final totalCourses = _registeredCourseCodes.length + _selectedCourseCodes.length;
    final totalCredits = _totalSelectedCredits;

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: AppColors.surface,
          title: const Row(
            children: [
              Icon(Icons.check_circle_outline, color: AppColors.gold),
              SizedBox(width: 8),
              Text('Confirm Course Registration', style: TextStyle(color: AppColors.onNavy, fontSize: 16, fontWeight: FontWeight.bold)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'You are registering for $totalCourses courses totaling $totalCredits Credit Units for 2026/2027 Semester 1.',
                style: const TextStyle(color: AppColors.onNavy, fontSize: 13, height: 1.4),
              ),
              const SizedBox(height: 14),
              const Text('Selected for Submission:', style: TextStyle(color: AppColors.muted, fontSize: 11, fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              ..._selectedCourseCodes.map((code) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 3),
                  child: Row(
                    children: [
                      const Icon(Icons.arrow_right, color: AppColors.gold, size: 16),
                      Text(code, style: const TextStyle(color: AppColors.gold, fontWeight: FontWeight.bold, fontSize: 12)),
                    ],
                  ),
                );
              }),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel', style: TextStyle(color: AppColors.muted)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.gold),
              onPressed: () async {
                Navigator.pop(ctx);
                await _submitCourseRegistration();
              },
              child: const Text('Confirm & Submit', style: TextStyle(color: AppColors.navyDeep, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  Future<void> _submitCourseRegistration() async {
    setState(() => _isSubmitting = true);
    await Future.delayed(const Duration(milliseconds: 800));

    if (!mounted) return;
    setState(() {
      _registeredCourseCodes.addAll(_selectedCourseCodes);
      _selectedCourseCodes.clear();
      _isSubmitting = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Course registration submitted and validated with registry!'),
        backgroundColor: Color(0xFF0F5132),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showErrorAlert(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Row(
          children: [
            Icon(Icons.error_outline, color: Color(0xFFF87171)),
            SizedBox(width: 8),
            Text('Registration Notice', style: TextStyle(color: AppColors.onNavy, fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Text(message, style: const TextStyle(color: AppColors.muted, fontSize: 13, height: 1.4)),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.gold),
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close', style: TextStyle(color: AppColors.navyDeep, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.navy,
      appBar: AppBar(
        backgroundColor: AppColors.navy,
        elevation: 0,
        title: const Text('Course Registration', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // 1. Registration Deadline & Fee Warning Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              color: const Color(0xFF13204D),
              child: Row(
                children: [
                  const Icon(Icons.timer_outlined, color: AppColors.gold, size: 18),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      registrationDeadline,
                      style: TextStyle(color: AppColors.gold, fontWeight: FontWeight.bold, fontSize: 11.5),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F5132),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text('Open', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),

            // 2. Credits Calculation Indicator Banner
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: const BoxDecoration(
                color: AppColors.surface,
                border: Border(bottom: BorderSide(color: AppColors.border, width: 0.8)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('TOTAL SELECTED CREDITS', style: TextStyle(color: AppColors.muted, fontSize: 10, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 2),
                      Text(
                        '$_totalSelectedCredits / 30 Credit Units',
                        style: const TextStyle(color: AppColors.gold, fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ],
                  ),
                  Text(
                    'Min 18 • Max 30 Cr',
                    style: TextStyle(
                      color: _totalSelectedCredits < 18 ? const Color(0xFFF87171) : const Color(0xFF34D399),
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            // 3. Eligible Courses List
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                itemCount: _allEligibleCourses.length,
                itemBuilder: (context, i) {
                  final course = _allEligibleCourses[i];
                  final isAlreadyRegistered = _registeredCourseCodes.contains(course.code);
                  final isSelected = _selectedCourseCodes.contains(course.code);
                  final isBlocked = course.state == CourseRegistrationState.prerequisiteBlocked;
                  final isClosed = course.state == CourseRegistrationState.closed;

                  Color badgeColor = AppColors.border;
                  String statusLabel = 'Available';
                  if (isAlreadyRegistered) {
                    badgeColor = const Color(0xFF0F5132);
                    statusLabel = 'Registered';
                  } else if (isSelected) {
                    badgeColor = AppColors.gold;
                    statusLabel = 'Selected';
                  } else if (isBlocked) {
                    badgeColor = const Color(0xFF5E1717);
                    statusLabel = 'Prerequisite Blocked';
                  } else if (isClosed) {
                    badgeColor = const Color(0xFF3B2F0F);
                    statusLabel = 'Closed';
                  }

                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isSelected ? AppColors.gold : AppColors.border,
                        width: isSelected ? 1.5 : 0.8,
                      ),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      leading: Checkbox(
                        activeColor: AppColors.gold,
                        checkColor: AppColors.navyDeep,
                        value: isAlreadyRegistered || isSelected,
                        onChanged: (isAlreadyRegistered || isBlocked || isClosed)
                            ? null
                            : (_) => _toggleSelection(course),
                      ),
                      title: Row(
                        children: [
                          Text(course.code, style: const TextStyle(color: AppColors.gold, fontWeight: FontWeight.bold, fontSize: 13)),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              course.title,
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
                          Text('${course.lecturer} • ${course.credits} Credits', style: const TextStyle(color: AppColors.muted, fontSize: 11.5)),
                          if (course.prerequisite != null) ...[
                            const SizedBox(height: 3),
                            InkWell(
                              onTap: () => _showPrerequisiteDetails(course),
                              child: Row(
                                children: [
                                  const Icon(Icons.info_outline, size: 12, color: AppColors.gold),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      'Prereq: ${course.prerequisite!}',
                                      style: const TextStyle(color: AppColors.gold, fontSize: 10.5, decoration: TextDecoration.underline),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(color: badgeColor, borderRadius: BorderRadius.circular(6)),
                        child: Text(
                          statusLabel,
                          style: TextStyle(
                            color: isSelected ? AppColors.navyDeep : Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            // 4. Bottom Submission Footer
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: AppColors.navyDeep,
                border: Border(top: BorderSide(color: AppColors.border, width: 0.8)),
              ),
              child: SafeArea(
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '${_selectedCourseCodes.length} New Courses Selected',
                            style: const TextStyle(color: AppColors.onNavy, fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                          Text(
                            'Total enrolled: $_totalSelectedCredits Credits',
                            style: const TextStyle(color: AppColors.muted, fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.gold,
                        foregroundColor: AppColors.navyDeep,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: (_selectedCourseCodes.isEmpty || _isSubmitting)
                          ? null
                          : _showConfirmRegistrationDialog,
                      child: _isSubmitting
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.navyDeep),
                            )
                          : const Text(
                              'Submit Registration',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
