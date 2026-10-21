import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_colors.dart';
import 'dashboard_data.dart';

class Course {
  final String name;
  final String duration;
  final String tuition;

  const Course({
    required this.name,
    required this.duration,
    required this.tuition,
  });
}

class Program {
  final String title;
  final List<Course> courses;

  const Program({required this.title, required this.courses});
}

final List<Program> programs = [
  const Program(
    title: 'Certification Programs',
    courses: [
      Course(
        name: 'Data Science',
        duration: '9 Months',
        tuition: '350,000 FRS',
      ),
      Course(name: 'DevOps', duration: '9 Months', tuition: '350,000 FRS'),
      Course(
        name: 'Industrial Web Design',
        duration: '6 Months',
        tuition: '300,000 FRS',
      ),
      Course(
        name: 'Digital Marketing and SEO',
        duration: '6 Months',
        tuition: '350,000 FRS',
      ),
    ],
  ),
  const Program(
    title: 'Engineering & Technology — HND (2 Years)',
    courses: [
      Course(
        name: 'Software Engineering',
        duration: '2 Years',
        tuition: '250,000 FRS',
      ),
      Course(
        name: 'Web and Graphics Design',
        duration: '2 Years',
        tuition: '250,000 FRS',
      ),
      Course(
        name: 'Digital Marketing and E-Commerce',
        duration: '2 Years',
        tuition: '250,000 FRS',
      ),
      Course(
        name: 'Network and Maintenance',
        duration: '2 Years',
        tuition: '250,000 FRS',
      ),
    ],
  ),
  const Program(
    title: 'Engineering & Technology — ND (1 Year)',
    courses: [
      Course(
        name: 'Computer Engineering',
        duration: '1 Year',
        tuition: '150,000 FRS',
      ),
      Course(name: 'ICT', duration: '1 Year', tuition: '150,000 FRS'),
      Course(name: 'Web Design', duration: '1 Year', tuition: '150,000 FRS'),
      Course(
        name: 'Graphics Design and Printing',
        duration: '1 Year',
        tuition: '150,000 FRS',
      ),
      Course(
        name: 'Basic Computer',
        duration: '1 Year',
        tuition: '150,000 FRS',
      ),
      Course(
        name: 'Office Automation Secretaryship',
        duration: '1 Year',
        tuition: '150,000 FRS',
      ),
      Course(
        name: 'Computerized Accounting',
        duration: '1 Year',
        tuition: '150,000 FRS',
      ),
    ],
  ),
  const Program(
    title: 'Business & Management — HND (2 Years)',
    courses: [
      Course(name: 'Accounting', duration: '2 Years', tuition: '250,000 FRS'),
      Course(name: 'Management', duration: '2 Years', tuition: '250,000 FRS'),
      Course(name: 'Marketing', duration: '2 Years', tuition: '250,000 FRS'),
      Course(
        name: 'Digital Marketing',
        duration: '2 Years',
        tuition: '250,000 FRS',
      ),
      Course(
        name: 'Human Resource Management',
        duration: '2 Years',
        tuition: '250,000 FRS',
      ),
    ],
  ),
];

class HomePage extends StatefulWidget {
  const HomePage({
    super.key,
    this.authToken = '',
    this.repository,
    this.onSignOut,
  });

  final String authToken;
  final DashboardRepository? repository;
  final Future<void> Function()? onSignOut;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<DashboardData> _dashboardFuture;

  // Student mobile 4-tab index: 0: Home, 1: Academics, 2: Fees, 3: Results
  int _studentTabIndex = 0;

  // Academics filter state
  int _academicsFilterIndex = 0; // 0: All (6), 1: Core (4), 2: Electives (2)
  String _academicsSearchQuery = '';

  // Registration selection state
  final Set<String> _selectedCourseCodes = {'SWE201', 'SWE203', 'CEF205'};

  // Faculty mobile 4-tab index: 0: Home, 1: Courses, 2: Attendance, 3: Grades
  int _facultyTabIndex = 0;

  // Faculty Grades state
  int _facultyGradesFilterIndex = 0; // 0: All Students (42), 1: Missing CA (1), 2: Missing Exam (1)
  String _facultyGradesSearchQuery = '';

  // Faculty interactive grade entries: matricule -> custom exam score
  final Map<String, double?> _customExamScores = {};

  // Faculty interactive attendance entries: matricule -> 'present' | 'late' | 'absent'
  final Map<String, String> _attendanceMap = {};

  // Lecturer Attendance Course-Level Authorization
  String _selectedAttendanceCourseCode = 'SWE201';

  // Admin & Super Admin 4-tab index: 0: Overview, 1: Directory, 2: Finance (FCFA), 3: Timetable
  int _adminTabIndex = 0;
  String _adminDirectorySearchQuery = '';
  int _adminDirectoryLevelFilter = 0; // 0: All, 1: Level 100, 2: Level 200, 3: Level 300, 4: Level 400

  // Bursary Verification Console (Matching uploaded screenshot 04fcd5d0)
  bool _showBursaryVerificationScreen = false;
  int _bursaryFilterIndex = 0; // 0: Urgent Audit (5), 1: All Pending (14), 2: Flagged (2)
  bool _clarisseCleared = false;
  final Set<String> _clearedBursarySlips = {};

  // Universal User Settings Preferences
  String _appLanguage = 'English (Cameroon)';
  bool _highContrastHciMode = false;
  bool _notificationsCaAlerts = true;
  bool _notificationsFeeAlerts = true;
  bool _notificationsTimetableAlerts = true;

  DashboardRepository get _repository =>
      widget.repository ?? const DemoDashboardRepository();

  @override
  void initState() {
    super.initState();
    _loadDashboard();
  }

  void _loadDashboard() {
    _dashboardFuture = _repository.fetchDashboard(authToken: widget.authToken);
  }

  void _retry() {
    setState(_loadDashboard);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DashboardData>(
      future: _dashboardFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            backgroundColor: AppColors.navy,
            body: Center(
              child: CircularProgressIndicator(color: AppColors.gold),
            ),
          );
        }
        if (snapshot.hasError || !snapshot.hasData) {
          return Scaffold(
            backgroundColor: AppColors.navy,
            body: _DashboardLoadError(onRetry: _retry),
          );
        }

        final data = snapshot.data!;

        // Strict Role-Based Access Control (RBAC):
        // Users can ONLY access what their authenticated database role permits!
        final role = data.role;

        // 1. Student Portal (Academic standing, Course Registration, Fees FCFA, Results Slip)
        if (role == DashboardRole.student) {
          return _buildStudentPortalScaffold(data);
        }

        // 2. Faculty / Lecturer Portal (Assigned Courses, Attendance Register, Grade Entry CA/Exam)
        if (role == DashboardRole.teacher) {
          return _buildFacultyPortalScaffold(data);
        }

        // 3. Admin & Super Admin Portal (Directory, Finance Ledger FCFA, Timetable, Security)
        return _buildAdminPortalScaffold(data);
      },
    );
  }

  // ---------------------------------------------------------------------------
  // STUDENT 4-TAB PORTAL SCAFFOLD
  // ---------------------------------------------------------------------------

  Widget _buildStudentPortalScaffold(DashboardData data) {
    const tabSectionNames = [
      'ACADEMIC OVERVIEW',
      'COURSE REGISTRATION',
      'FEES CLEARANCE (FCFA)',
      'RESULTS & GPA'
    ];
    final currentSection = tabSectionNames[_studentTabIndex];
    final isDesktop = MediaQuery.sizeOf(context).width >= 850;

    if (isDesktop) {
      return Scaffold(
        backgroundColor: AppColors.navy,
        body: Row(
          children: [
            _buildDesktopSidebar(
              role: DashboardRole.student,
              data: data,
              selectedIndex: _studentTabIndex,
              onSelect: (idx) => setState(() => _studentTabIndex = idx),
            ),
            Expanded(
              child: Column(
                children: [
                  _buildDesktopTopBar(
                    data: data,
                    sectionName: currentSection,
                    roleLabel: 'Student • Level 200 (Year 2)',
                  ),
                  Expanded(
                    child: Center(
                      child: Container(
                        constraints: const BoxConstraints(maxWidth: 1150),
                        child: IndexedStack(
                          index: _studentTabIndex,
                          children: [
                            _buildStudentHomeTab(data),
                            _buildStudentAcademicsTab(data),
                            _buildStudentFeesTab(data),
                            _buildStudentResultsTab(data),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.navy,
      drawer: _buildMobileDrawer(
        role: DashboardRole.student,
        data: data,
        selectedIndex: _studentTabIndex,
        onSelect: (idx) {
          Navigator.pop(context);
          setState(() => _studentTabIndex = idx);
        },
      ),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(64),
        child: _buildStudentTopBar(data, currentSection),
      ),
      body: SafeArea(
        child: IndexedStack(
          index: _studentTabIndex,
          children: [
            _buildStudentHomeTab(data),
            _buildStudentAcademicsTab(data),
            _buildStudentFeesTab(data),
            _buildStudentResultsTab(data),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AppColors.navyDeep,
          border: Border(top: BorderSide(color: AppColors.border, width: 0.8)),
        ),
        child: BottomNavigationBar(
          backgroundColor: AppColors.navyDeep,
          selectedItemColor: AppColors.gold,
          unselectedItemColor: AppColors.muted,
          currentIndex: _studentTabIndex,
          type: BottomNavigationBarType.fixed,
          selectedFontSize: 11,
          unselectedFontSize: 11,
          elevation: 0,
          onTap: (index) => setState(() => _studentTabIndex = index),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.school_outlined),
              activeIcon: Icon(Icons.school),
              label: 'Academics',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.account_balance_wallet_outlined),
              activeIcon: Icon(Icons.account_balance_wallet),
              label: 'Fees',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.insights_outlined),
              activeIcon: Icon(Icons.insights),
              label: 'Results',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStudentTopBar(DashboardData data, String currentSection) {
    return Container(
      color: AppColors.navyDeep,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            Builder(
              builder: (ctx) => IconButton(
                icon: const Icon(Icons.menu_rounded, color: AppColors.onNavy, size: 24),
                tooltip: 'Navigation Menu',
                onPressed: () => Scaffold.of(ctx).openDrawer(),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
              ),
            ),
            const SizedBox(width: 6),
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.gold.withValues(alpha: 0.5),
                  width: 1.5,
                ),
              ),
              child: ClipOval(
                child: Image.asset(
                  'assets/images/logo.png',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => const Icon(
                    Icons.school,
                    color: AppColors.gold,
                    size: 20,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'FAH ACADEMY • CAMEROON',
                    style: TextStyle(
                      color: AppColors.onNavy,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.6,
                    ),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    '2026/2027 • S1 • LEVEL 200 (YEAR 2)',
                    style: const TextStyle(
                      color: AppColors.gold,
                      fontSize: 9.5,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.4,
                    ),
                  ),
                ],
              ),
            ),
            Stack(
              clipBehavior: Clip.none,
              children: [
                IconButton(
                  icon: const Icon(
                    Icons.notifications_outlined,
                    color: AppColors.onNavy,
                    size: 22,
                  ),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Notice: Continuous assessment schedule released for Level 200.'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                ),
                Positioned(
                  top: 6,
                  right: 6,
                  child: Container(
                    width: 7,
                    height: 7,
                    decoration: const BoxDecoration(
                      color: AppColors.gold,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 8),
            PopupMenuButton<String>(
              tooltip: 'Student Account & Profile',
              color: AppColors.surface,
              onSelected: (val) {
                if (val == 'signout') {
                  _handleSignOut();
                } else if (val == 'handbook') {
                  _showAcademicRegulationsModal(context);
                } else if (val == 'settings') {
                  _showSettingsModal(context, data);
                }
              },
              itemBuilder: (ctx) => [
                PopupMenuItem(
                  enabled: false,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        data.displayName,
                        style: const TextStyle(
                          color: AppColors.onNavy,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Matricule: ${data.userId}',
                        style: const TextStyle(
                          color: AppColors.gold,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'B.Sc Software Eng • Level 200 (Year 2)',
                        style: TextStyle(
                          color: AppColors.muted,
                          fontSize: 10.5,
                        ),
                      ),
                    ],
                  ),
                ),
                const PopupMenuDivider(),
                const PopupMenuItem(
                  value: 'settings',
                  child: Row(
                    children: [
                      Icon(Icons.settings_outlined, color: AppColors.gold, size: 18),
                      SizedBox(width: 8),
                      Text('Settings & Security', style: TextStyle(color: AppColors.onNavy, fontSize: 13)),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'handbook',
                  child: Row(
                    children: [
                      Icon(Icons.menu_book_outlined, color: AppColors.gold, size: 18),
                      SizedBox(width: 8),
                      Text('Senate Academic Rules', style: TextStyle(color: AppColors.onNavy, fontSize: 13)),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'signout',
                  child: Row(
                    children: [
                      Icon(Icons.logout, color: Color(0xFFF87171), size: 18),
                      SizedBox(width: 8),
                      Text('Sign out', style: TextStyle(color: Color(0xFFF87171), fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ],
              child: CircleAvatar(
                radius: 17,
                backgroundColor: AppColors.surfaceRaised,
                child: Text(
                  data.displayName.isNotEmpty
                      ? data.displayName.substring(0, 1).toUpperCase()
                      : 'S',
                  style: const TextStyle(
                    color: AppColors.gold,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // RESPONSIVE SIDEBAR & DRAWER MENUS (HCI Regulations & Navigation)
  // ---------------------------------------------------------------------------

  Widget _buildDesktopSidebar({
    required DashboardRole role,
    required DashboardData data,
    required int selectedIndex,
    required ValueChanged<int> onSelect,
  }) {
    final roleTitle = role == DashboardRole.student
        ? 'Student • Level 200 (Year 2)'
        : (role == DashboardRole.teacher
            ? 'Senior Lecturer • Faculty'
            : (role == DashboardRole.superAdmin ? 'Super Administrator' : 'Administrator'));

    final menuItems = role == DashboardRole.student
        ? [
            (Icons.dashboard_outlined, 'Academic Overview', 0),
            (Icons.school_outlined, 'Course Registration', 1),
            (Icons.account_balance_wallet_outlined, 'Fees Clearance (FCFA)', 2),
            (Icons.insights_outlined, 'Official Results & GPA', 3),
          ]
        : (role == DashboardRole.teacher
            ? [
                (Icons.grid_view_rounded, 'Faculty Dashboard', 0),
                (Icons.menu_book_outlined, 'Teaching Modules', 1),
                (Icons.fact_check_outlined, 'Attendance Register', 2),
                (Icons.trending_up_rounded, 'Grade Entry (CA & Exam)', 3),
              ]
            : [
                (Icons.dashboard_outlined, 'Operations Overview', 0),
                (Icons.people_alt_outlined, 'Student Directory', 1),
                (Icons.payments_outlined, 'Fee Ledger (FCFA)', 2),
                (Icons.calendar_month_outlined, 'Timetable & Venues', 3),
              ]);

    return Container(
      width: 250,
      color: AppColors.navyDeep,
      child: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: AppColors.border, width: 0.8)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.gold, width: 1.5),
                        ),
                        child: ClipOval(
                          child: Image.asset(
                            'assets/images/logo.png',
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => const Icon(Icons.school, color: AppColors.gold),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'FAH ACADEMY',
                            style: TextStyle(
                              color: AppColors.onNavy,
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.6,
                            ),
                          ),
                          Text(
                            'UNIVERSITY SMS • CAMEROON',
                            style: TextStyle(
                              color: AppColors.gold,
                              fontSize: 8.5,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.6,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF13204D),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.border.withValues(alpha: 0.6)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          data.displayName,
                          style: const TextStyle(
                            color: AppColors.onNavy,
                            fontSize: 12.5,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          roleTitle,
                          style: const TextStyle(color: AppColors.gold, fontSize: 10, fontWeight: FontWeight.w600),
                        ),
                        Text(
                          'Matricule: ${data.userId}',
                          style: const TextStyle(color: AppColors.muted, fontSize: 9.5),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                children: [
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    child: Text(
                      'MAIN NAVIGATION',
                      style: TextStyle(color: AppColors.muted, fontSize: 9.5, fontWeight: FontWeight.bold, letterSpacing: 0.8),
                    ),
                  ),
                  const SizedBox(height: 4),
                  ...menuItems.map((item) {
                    final isSelected = selectedIndex == item.$3;
                    return Container(
                      margin: const EdgeInsets.only(bottom: 6),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.gold.withValues(alpha: 0.15) : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                        border: isSelected
                            ? Border.all(color: AppColors.gold.withValues(alpha: 0.6))
                            : null,
                      ),
                      child: ListTile(
                        leading: Icon(item.$1, color: isSelected ? AppColors.gold : AppColors.muted, size: 19),
                        title: Text(
                          item.$2,
                          style: TextStyle(
                            color: isSelected ? AppColors.gold : AppColors.onNavy,
                            fontSize: 12.5,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                          ),
                        ),
                        dense: true,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        onTap: () => onSelect(item.$3),
                      ),
                    );
                  }),
                  const Divider(color: AppColors.border, height: 24),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    child: Text(
                      'ACADEMIC RESOURCES',
                      style: TextStyle(color: AppColors.muted, fontSize: 9.5, fontWeight: FontWeight.bold, letterSpacing: 0.8),
                    ),
                  ),
                  ListTile(
                    leading: const Icon(Icons.calendar_month_outlined, color: AppColors.muted, size: 19),
                    title: const Text('Semester Timetable', style: TextStyle(color: AppColors.onNavy, fontSize: 12.5)),
                    dense: true,
                    onTap: _showTimetableModal,
                  ),
                  ListTile(
                    leading: const Icon(Icons.menu_book_outlined, color: AppColors.muted, size: 19),
                    title: const Text('Senate Regulations', style: TextStyle(color: AppColors.onNavy, fontSize: 12.5)),
                    dense: true,
                    onTap: () => _showAcademicRegulationsModal(context),
                  ),
                  ListTile(
                    leading: const Icon(Icons.settings_outlined, color: AppColors.muted, size: 19),
                    title: const Text('Settings & Security', style: TextStyle(color: AppColors.onNavy, fontSize: 12.5)),
                    dense: true,
                    onTap: () => _showSettingsModal(context, data),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: AppColors.border, width: 0.8)),
              ),
              child: ListTile(
                leading: const Icon(Icons.logout, color: Color(0xFFF87171), size: 19),
                title: const Text(
                  'Sign Out',
                  style: TextStyle(color: Color(0xFFF87171), fontWeight: FontWeight.bold, fontSize: 12.5),
                ),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                tileColor: const Color(0xFF13204D),
                dense: true,
                onTap: _handleSignOut,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMobileDrawer({
    required DashboardRole role,
    required DashboardData data,
    required int selectedIndex,
    required ValueChanged<int> onSelect,
  }) {
    final roleTitle = role == DashboardRole.student
        ? 'Student • Level 200 (Year 2)'
        : (role == DashboardRole.teacher
            ? 'Senior Lecturer • Faculty'
            : (role == DashboardRole.superAdmin ? 'Super Administrator' : 'Administrator'));

    final menuItems = role == DashboardRole.student
        ? [
            (Icons.dashboard_outlined, 'Academic Overview', 0),
            (Icons.school_outlined, 'Course Registration', 1),
            (Icons.account_balance_wallet_outlined, 'Fees Clearance (FCFA)', 2),
            (Icons.insights_outlined, 'Official Results & GPA', 3),
          ]
        : (role == DashboardRole.teacher
            ? [
                (Icons.grid_view_rounded, 'Faculty Dashboard', 0),
                (Icons.menu_book_outlined, 'Assigned Courses', 1),
                (Icons.fact_check_outlined, 'Attendance Register', 2),
                (Icons.trending_up_rounded, 'Grade Entry (CA & Exam)', 3),
              ]
            : [
                (Icons.dashboard_outlined, 'Operations Overview', 0),
                (Icons.people_alt_outlined, 'Student Directory', 1),
                (Icons.payments_outlined, 'Fee Ledger (FCFA)', 2),
                (Icons.calendar_month_outlined, 'Timetable & Venues', 3),
              ]);

    return Drawer(
      backgroundColor: AppColors.navyDeep,
      child: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: const BoxDecoration(
                color: Color(0xFF13204D),
                border: Border(bottom: BorderSide(color: AppColors.border, width: 0.8)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.gold, width: 1.5),
                    ),
                    child: ClipOval(
                      child: Image.asset(
                        'assets/images/logo.png',
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => const Icon(Icons.school, color: AppColors.gold),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'FAH ACADEMY',
                          style: TextStyle(
                            color: AppColors.onNavy,
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.6,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          roleTitle,
                          style: const TextStyle(color: AppColors.gold, fontSize: 10.5, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'Matricule: ${data.userId}',
                          style: const TextStyle(color: AppColors.muted, fontSize: 10),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                children: [
                  ...menuItems.map((item) {
                    final isSelected = selectedIndex == item.$3;
                    return Container(
                      margin: const EdgeInsets.only(bottom: 6),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.gold.withValues(alpha: 0.15) : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                        border: isSelected
                            ? Border.all(color: AppColors.gold.withValues(alpha: 0.5))
                            : null,
                      ),
                      child: ListTile(
                        leading: Icon(item.$1, color: isSelected ? AppColors.gold : AppColors.muted, size: 20),
                        title: Text(
                          item.$2,
                          style: TextStyle(
                            color: isSelected ? AppColors.gold : AppColors.onNavy,
                            fontSize: 13,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                          ),
                        ),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        dense: true,
                        onTap: () => onSelect(item.$3),
                      ),
                    );
                  }),
                  const Divider(color: AppColors.border, height: 24),
                  ListTile(
                    leading: const Icon(Icons.calendar_month_outlined, color: AppColors.muted, size: 20),
                    title: const Text('Semester Timetable', style: TextStyle(color: AppColors.onNavy, fontSize: 13)),
                    dense: true,
                    onTap: () {
                      Navigator.pop(context);
                      _showTimetableModal();
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.menu_book_outlined, color: AppColors.muted, size: 20),
                    title: const Text('Academic Regulations', style: TextStyle(color: AppColors.onNavy, fontSize: 13)),
                    dense: true,
                    onTap: () {
                      Navigator.pop(context);
                      _showAcademicRegulationsModal(context);
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.settings_outlined, color: AppColors.muted, size: 20),
                    title: const Text('Settings & Security', style: TextStyle(color: AppColors.onNavy, fontSize: 13)),
                    dense: true,
                    onTap: () {
                      Navigator.pop(context);
                      _showSettingsModal(context, data);
                    },
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: AppColors.border, width: 0.8)),
              ),
              child: ListTile(
                leading: const Icon(Icons.logout, color: Color(0xFFF87171), size: 20),
                title: const Text(
                  'Sign Out',
                  style: TextStyle(color: Color(0xFFF87171), fontWeight: FontWeight.bold, fontSize: 13),
                ),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                tileColor: const Color(0xFF13204D),
                dense: true,
                onTap: _handleSignOut,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDesktopTopBar({
    required DashboardData data,
    required String sectionName,
    required String roleLabel,
  }) {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: const BoxDecoration(
        color: AppColors.navyDeep,
        border: Border(bottom: BorderSide(color: AppColors.border, width: 0.8)),
      ),
      child: Row(
        children: [
          Text(
            sectionName,
            style: const TextStyle(
              color: AppColors.onNavy,
              fontSize: 14,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.6,
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: AppColors.gold.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: AppColors.gold.withValues(alpha: 0.4)),
            ),
            child: const Text(
              '2026/2027 • SEMESTER 1 (CURRENT)',
              style: TextStyle(
                color: AppColors.gold,
                fontSize: 10,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.4,
              ),
            ),
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.notifications_none_rounded, color: AppColors.onNavy, size: 20),
            tooltip: 'University Notices',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Notice: Academic board continuous assessment moderation active.'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF13204D),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.border.withValues(alpha: 0.6)),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 12,
                  backgroundColor: AppColors.gold,
                  child: Text(
                    data.displayName.isNotEmpty ? data.displayName[0].toUpperCase() : 'U',
                    style: const TextStyle(color: AppColors.navyDeep, fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  data.displayName,
                  style: const TextStyle(color: AppColors.onNavy, fontSize: 12, fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 6),
                Text(
                  '(${data.userId})',
                  style: const TextStyle(color: AppColors.gold, fontSize: 11),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showAcademicRegulationsModal(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.navyDeep,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.gavel_outlined, color: AppColors.gold, size: 22),
            SizedBox(width: 8),
            Text(
              'Cameroon Academic Regulations',
              style: TextStyle(color: AppColors.onNavy, fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Fah Academy — Faculty of Engineering & Technology\n'
                'Harmonized Higher Education Senate Standards (MINESUP, Cameroon)',
                style: TextStyle(color: AppColors.gold, fontSize: 11, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 12),
              Text(
                '1. Assessment Breakdown:\n'
                '   • Continuous Assessment (CA): 30% (Tests, Lab Practical / TP, Assignments).\n'
                '   • Terminal Examination: 70% (Normal Session Examination / Session Normale).\n'
                '   • A minimum of 75% class attendance is mandatory to sit for terminal examinations.\n\n'
                '2. Grading Scale (4.0 GP):\n'
                '   • 80% - 100%: Grade A (4.00 GP) — Excellent\n'
                '   • 70% - 79%: Grade B+ (3.50 GP) — Very Good\n'
                '   • 60% - 69%: Grade B (3.00 GP) — Good\n'
                '   • 55% - 59%: Grade C+ (2.50 GP) — Fair\n'
                '   • 50% - 54%: Grade C (2.00 GP) — Pass\n'
                '   • Below 50%: Grade F (0.00 GP) — Resit Required (Session de Rattrapage).\n\n'
                '3. Tuition & Financial Clearance:\n'
                '   • Complete fee clearance in FCFA is required before obtaining the Examination Clearance Slip.\n'
                '   • Bank deposits through UBA Cameroon, Afriland First Bank, or authorized MTN MoMo/Orange Money.',
                style: TextStyle(color: AppColors.muted, fontSize: 12, height: 1.45),
              ),
            ],
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.gold,
              foregroundColor: AppColors.navyDeep,
            ),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // UNIVERSAL USER SETTINGS & SECURITY MODAL (All Roles)
  // ---------------------------------------------------------------------------

  void _showSettingsModal(BuildContext context, DashboardData data) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.navyDeep,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            final isDesktop = MediaQuery.sizeOf(ctx).width >= 700;
            return Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.sizeOf(ctx).height * 0.88,
                maxWidth: isDesktop ? 650 : double.infinity,
              ),
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              child: ListView(
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.border,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.settings, color: AppColors.gold, size: 22),
                          SizedBox(width: 10),
                          Text(
                            'Settings & Preferences',
                            style: TextStyle(
                              color: AppColors.onNavy,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: AppColors.muted),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // User Profile Snapshot
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 24,
                          backgroundColor: AppColors.surfaceRaised,
                          child: Text(
                            data.displayName.isNotEmpty
                                ? data.displayName.substring(0, 1).toUpperCase()
                                : 'U',
                            style: const TextStyle(
                              color: AppColors.gold,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                data.displayName,
                                style: const TextStyle(
                                  color: AppColors.onNavy,
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'ID: ${data.userId} • ${_getRoleDisplayName(data.role)}',
                                style: const TextStyle(
                                  color: AppColors.gold,
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${data.displayName.toLowerCase().replaceAll(' ', '.')}@fahacademy.cm',
                                style: const TextStyle(
                                  color: AppColors.muted,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Section 1: Security & Credentials
                  const Text(
                    'SECURITY & AUTHENTICATION',
                    style: TextStyle(
                      color: AppColors.gold,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 10),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.lock_reset, color: AppColors.onNavy),
                    title: const Text(
                      'Change Password',
                      style: TextStyle(color: AppColors.onNavy, fontSize: 14),
                    ),
                    subtitle: const Text(
                      'Update your secure account password',
                      style: TextStyle(color: AppColors.muted, fontSize: 11),
                    ),
                    trailing: const Icon(Icons.chevron_right, color: AppColors.muted),
                    onTap: () {
                      _showChangePasswordDialog(ctx);
                    },
                  ),
                  const Divider(color: AppColors.border, height: 1),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    secondary: const Icon(Icons.security, color: AppColors.onNavy),
                    title: const Text(
                      'Two-Factor Authentication (2FA)',
                      style: TextStyle(color: AppColors.onNavy, fontSize: 14),
                    ),
                    subtitle: const Text(
                      'Require SMS or Authenticator verification on login',
                      style: TextStyle(color: AppColors.muted, fontSize: 11),
                    ),
                    activeColor: AppColors.gold,
                    value: true,
                    onChanged: (val) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            val
                                ? 'Two-Factor Authentication activated.'
                                : 'Two-Factor Authentication deactivated.',
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 20),

                  // Section 2: Localization & HCI Accessibility
                  const Text(
                    'LOCALIZATION & HCI ACCESSIBILITY',
                    style: TextStyle(
                      color: AppColors.gold,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'System Language (Bilingual Cameroon)',
                          style: TextStyle(
                            color: AppColors.onNavy,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: ChoiceChip(
                                label: const Center(child: Text('English (Cameroon)')),
                                selected: _appLanguage == 'English (Cameroon)',
                                selectedColor: AppColors.gold,
                                labelStyle: TextStyle(
                                  color: _appLanguage == 'English (Cameroon)'
                                      ? AppColors.navyDeep
                                      : AppColors.onNavy,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 11.5,
                                ),
                                onSelected: (sel) {
                                  if (sel) {
                                    setState(() => _appLanguage = 'English (Cameroon)');
                                    setModalState(() {});
                                  }
                                },
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: ChoiceChip(
                                label: const Center(child: Text('Français (Cameroun)')),
                                selected: _appLanguage == 'Français (Cameroun)',
                                selectedColor: AppColors.gold,
                                labelStyle: TextStyle(
                                  color: _appLanguage == 'Français (Cameroun)'
                                      ? AppColors.navyDeep
                                      : AppColors.onNavy,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 11.5,
                                ),
                                onSelected: (sel) {
                                  if (sel) {
                                    setState(() => _appLanguage = 'Français (Cameroun)');
                                    setModalState(() {});
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    secondary: const Icon(Icons.contrast, color: AppColors.onNavy),
                    title: const Text(
                      'HCI High-Contrast Mode',
                      style: TextStyle(color: AppColors.onNavy, fontSize: 14),
                    ),
                    subtitle: const Text(
                      'Enhanced contrast for high-sunlight or low-vision readability',
                      style: TextStyle(color: AppColors.muted, fontSize: 11),
                    ),
                    activeColor: AppColors.gold,
                    value: _highContrastHciMode,
                    onChanged: (val) {
                      setState(() => _highContrastHciMode = val);
                      setModalState(() {});
                    },
                  ),
                  const SizedBox(height: 20),

                  // Section 3: Notification Toggles
                  const Text(
                    'NOTIFICATION PREFERENCES',
                    style: TextStyle(
                      color: AppColors.gold,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 10),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Continuous Assessment (CA) & Exam Alerts',
                        style: TextStyle(color: AppColors.onNavy, fontSize: 13.5)),
                    subtitle: const Text('Instant alerts when CA or terminal exam marks are published',
                        style: TextStyle(color: AppColors.muted, fontSize: 11)),
                    activeColor: AppColors.gold,
                    value: _notificationsCaAlerts,
                    onChanged: (val) {
                      setState(() => _notificationsCaAlerts = val);
                      setModalState(() {});
                    },
                  ),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Bursary & Fee Clearance Alerts',
                        style: TextStyle(color: AppColors.onNavy, fontSize: 13.5)),
                    subtitle: const Text('Notifications when bank slips (UBA/Afriland) are verified',
                        style: TextStyle(color: AppColors.muted, fontSize: 11)),
                    activeColor: AppColors.gold,
                    value: _notificationsFeeAlerts,
                    onChanged: (val) {
                      setState(() => _notificationsFeeAlerts = val);
                      setModalState(() {});
                    },
                  ),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Lecture Timetable & Hall Allocations',
                        style: TextStyle(color: AppColors.onNavy, fontSize: 13.5)),
                    subtitle: const Text('Updates on schedule changes or lecture hall shifts',
                        style: TextStyle(color: AppColors.muted, fontSize: 11)),
                    activeColor: AppColors.gold,
                    value: _notificationsTimetableAlerts,
                    onChanged: (val) {
                      setState(() => _notificationsTimetableAlerts = val);
                      setModalState(() {});
                    },
                  ),
                  const SizedBox(height: 20),

                  // Institutional Compliance Info
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.navy,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'MINESUP Institutional Compliance',
                          style: TextStyle(
                            color: AppColors.gold,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Accreditation: Republic of Cameroon Ministry of Higher Education • Harmonized Senate Framework 2026/2027.',
                          style: TextStyle(color: AppColors.muted, fontSize: 10, height: 1.4),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Sign Out
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFFF87171),
                        side: const BorderSide(color: Color(0xFFF87171)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () {
                        Navigator.pop(ctx);
                        _handleSignOut();
                      },
                      icon: const Icon(Icons.logout, size: 18),
                      label: const Text(
                        'Sign Out of Account',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showChangePasswordDialog(BuildContext parentContext) {
    final currentPwController = TextEditingController();
    final newPwController = TextEditingController();
    final confirmPwController = TextEditingController();

    showDialog(
      context: parentContext,
      builder: (dlgCtx) => AlertDialog(
        backgroundColor: AppColors.navyDeep,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: const Row(
          children: [
            Icon(Icons.lock_outline, color: AppColors.gold),
            SizedBox(width: 8),
            Text('Change Password', style: TextStyle(color: AppColors.onNavy, fontSize: 16)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: currentPwController,
              obscureText: true,
              style: const TextStyle(color: AppColors.onNavy, fontSize: 13),
              decoration: const InputDecoration(
                labelText: 'Current Password',
                labelStyle: TextStyle(color: AppColors.muted, fontSize: 12),
                enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.border)),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: newPwController,
              obscureText: true,
              style: const TextStyle(color: AppColors.onNavy, fontSize: 13),
              decoration: const InputDecoration(
                labelText: 'New Password',
                labelStyle: TextStyle(color: AppColors.muted, fontSize: 12),
                enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.border)),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: confirmPwController,
              obscureText: true,
              style: const TextStyle(color: AppColors.onNavy, fontSize: 13),
              decoration: const InputDecoration(
                labelText: 'Confirm New Password',
                labelStyle: TextStyle(color: AppColors.muted, fontSize: 12),
                enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.border)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dlgCtx),
            child: const Text('Cancel', style: TextStyle(color: AppColors.muted)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.gold,
              foregroundColor: AppColors.navyDeep,
            ),
            onPressed: () {
              Navigator.pop(dlgCtx);
              ScaffoldMessenger.of(parentContext).showSnackBar(
                const SnackBar(
                  content: Text('✓ Password successfully updated and encrypted.'),
                  backgroundColor: AppColors.surfaceRaised,
                ),
              );
            },
            child: const Text('Update Password'),
          ),
        ],
      ),
    );
  }

  String _getRoleDisplayName(DashboardRole role) => role.label;

  // ---------------------------------------------------------------------------
  // OFFICIAL PDF DOCUMENT GENERATION & EXPORT (Cameroon Higher Education Standard)
  // ---------------------------------------------------------------------------

  void _downloadDocumentAsPdf({
    required BuildContext context,
    required String title,
    required String fileName,
    required String rawText,
  }) {
    Clipboard.setData(ClipboardData(text: rawText));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.picture_as_pdf, color: AppColors.gold, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                '✓ $title ($fileName) downloaded & official text copied to clipboard.',
                style: const TextStyle(fontSize: 12),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF13204D),
        duration: const Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // 1. Official Results Slip PDF Modal
  void _showResultsPdfModal(BuildContext context, DashboardData data) {
    final docText = '''
================================================================================
REPUBLIC OF CAMEROON                             REPUBLIQUE DU CAMEROUN
Peace - Work - Fatherland                         Paix - Travail - Patrie
MINISTRY OF HIGHER EDUCATION                     MINISTERE DE L'ENSEIGNEMENT SUPERIEUR
--------------------------------------------------------------------------------
                     FAH ACADEMY - FACULTY OF ENGINEERING
                 ACADEMIC TRANSCRIPT & STATEMENT OF RESULTS
================================================================================
Student Name:       Clarisse M. Fong
Matricule / ID:     FAH-2024-SW0482
Degree / Program:   B.Eng Software Engineering
Academic Year:      2026/2027 • Semester 2
Class Level:        Level 200 (Year 2)
--------------------------------------------------------------------------------
COURSE CODE | COURSE TITLE                       | CR | CA/30 | EX/70 | TOT | GR | GP
--------------------------------------------------------------------------------
SWE201      | Advanced Data Structures           | 4  | 28.5  | 62.0  | 90.5| A  | 4.00
SWE203      | Object-Oriented Software Design    | 3  | 27.0  | 59.0  | 86.0| A  | 4.00
CEF205      | Digital Logic & Microprocessors    | 4  | 24.0  | 52.0  | 76.0| B+ | 3.50
ICT207      | Computer Networks & Architecture   | 3  | 26.0  | 55.0  | 81.0| A  | 4.00
--------------------------------------------------------------------------------
SEMESTER GPA:       3.82 / 4.00
CUMULATIVE CGPA:    3.75 / 4.00
EARNED CREDITS:     21 / 21 S2 Units
ACADEMIC STANDING:  FIRST CLASS HONOURS (HONOUR ROLL)
PENDING RESITS:     0
--------------------------------------------------------------------------------
AUTHENTICATION SEAL: MINESUP-CMR-2026-FONG-9921
DEAN OF FACULTY:     Prof. E. T. Tamba (Ph.D)
REGISTRAR:           Dr. Beatrice M. Ngu
ISSUED DATE:         October 2026
================================================================================
''';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.navyDeep,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.sizeOf(ctx).height * 0.92,
            maxWidth: 750,
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.picture_as_pdf, color: AppColors.gold, size: 22),
                      SizedBox(width: 8),
                      Text(
                        'Official Result Slip (MINESUP Standard)',
                        style: TextStyle(
                          color: AppColors.onNavy,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: AppColors.muted),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Expanded(
                child: SingleChildScrollView(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0C1536),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.gold.withValues(alpha: 0.6)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Official Letterhead
                        Center(
                          child: Column(
                            children: [
                              const Text(
                                'REPUBLIC OF CAMEROON • REPUBLIQUE DU CAMEROUN\nPeace - Work - Fatherland • Paix - Travail - Patrie\nMINISTRY OF HIGHER EDUCATION (MINESUP)',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: AppColors.muted,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  height: 1.4,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                                decoration: BoxDecoration(
                                  color: AppColors.gold.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(color: AppColors.gold),
                                ),
                                child: const Text(
                                  'FAH ACADEMY • STATEMENT OF SEMESTER RESULTS',
                                  style: TextStyle(
                                    color: AppColors.gold,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Divider(color: AppColors.border),
                        const SizedBox(height: 8),

                        // Student Info Grid
                        const Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('STUDENT NAME', style: TextStyle(color: AppColors.muted, fontSize: 9.5)),
                                Text('Clarisse M. Fong', style: TextStyle(color: AppColors.onNavy, fontWeight: FontWeight.bold, fontSize: 13)),
                                SizedBox(height: 6),
                                Text('DEGREE PROGRAM', style: TextStyle(color: AppColors.muted, fontSize: 9.5)),
                                Text('B.Eng Software Engineering', style: TextStyle(color: AppColors.onNavy, fontWeight: FontWeight.bold, fontSize: 12)),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text('MATRICULE NO', style: TextStyle(color: AppColors.muted, fontSize: 9.5)),
                                Text('FAH-2024-SW0482', style: TextStyle(color: AppColors.gold, fontWeight: FontWeight.bold, fontSize: 13)),
                                SizedBox(height: 6),
                                Text('ACADEMIC YEAR & SEMESTER', style: TextStyle(color: AppColors.muted, fontSize: 9.5)),
                                Text('2026/2027 • Level 200 • Sem 2', style: TextStyle(color: AppColors.onNavy, fontWeight: FontWeight.bold, fontSize: 12)),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        const Divider(color: AppColors.border),
                        const SizedBox(height: 8),

                        // Course Marks Table
                        const Text('COURSE PERFORMANCE (CA: 30% • EXAM: 70%)',
                            style: TextStyle(color: AppColors.gold, fontSize: 10.5, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        _buildPdfResultRow('SWE201', 'Advanced Data Structures', '4 Cr', '28.5', '62.0', '90.5', 'A', '4.00'),
                        _buildPdfResultRow('SWE203', 'Object-Oriented Software Design', '3 Cr', '27.0', '59.0', '86.0', 'A', '4.00'),
                        _buildPdfResultRow('CEF205', 'Digital Logic & Microprocessors', '4 Cr', '24.0', '52.0', '76.0', 'B+', '3.50'),
                        _buildPdfResultRow('ICT207', 'Computer Networks & Arch.', '3 Cr', '26.0', '55.0', '81.0', 'A', '4.00'),

                        const SizedBox(height: 14),
                        const Divider(color: AppColors.border),
                        const SizedBox(height: 8),

                        // Summary Statistics
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFF13204D),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Column(
                                children: [
                                  Text('SEMESTER GPA', style: TextStyle(color: AppColors.muted, fontSize: 10)),
                                  SizedBox(height: 2),
                                  Text('3.82 / 4.00', style: TextStyle(color: AppColors.gold, fontWeight: FontWeight.bold, fontSize: 16)),
                                ],
                              ),
                              Column(
                                children: [
                                  Text('CUMULATIVE CGPA', style: TextStyle(color: AppColors.muted, fontSize: 10)),
                                  SizedBox(height: 2),
                                  Text('3.75 / 4.00', style: TextStyle(color: AppColors.onNavy, fontWeight: FontWeight.bold, fontSize: 16)),
                                ],
                              ),
                              Column(
                                children: [
                                  Text('ACADEMIC STANDING', style: TextStyle(color: AppColors.muted, fontSize: 10)),
                                  SizedBox(height: 2),
                                  Text('1st Class Honours', style: TextStyle(color: Color(0xFF4ADE80), fontWeight: FontWeight.bold, fontSize: 13)),
                                ],
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 16),
                        // Signatures & Official Stamp
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: AppColors.gold, width: 1.5),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: const Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('SENATE AUTHENTICATION', style: TextStyle(color: AppColors.gold, fontSize: 9, fontWeight: FontWeight.bold)),
                                      Text('SEAL: MINESUP-CMR-2026-FONG', style: TextStyle(color: AppColors.muted, fontSize: 8)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text('Prof. E. T. Tamba (Ph.D)', style: TextStyle(color: AppColors.onNavy, fontWeight: FontWeight.bold, fontSize: 11)),
                                Text('Dean, Faculty of Engineering', style: TextStyle(color: AppColors.muted, fontSize: 9.5)),
                                SizedBox(height: 2),
                                Text('Dr. Beatrice M. Ngu', style: TextStyle(color: AppColors.onNavy, fontWeight: FontWeight.bold, fontSize: 11)),
                                Text('Registrar / Academic Affairs', style: TextStyle(color: AppColors.muted, fontSize: 9.5)),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.gold,
                        foregroundColor: AppColors.navyDeep,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: () {
                        _downloadDocumentAsPdf(
                          context: context,
                          title: 'Official Result Slip',
                          fileName: 'MINESUP_Result_Slip_FAH2024SW0482.pdf',
                          rawText: docText,
                        );
                      },
                      icon: const Icon(Icons.download, size: 18),
                      label: const Text('Download PDF Document', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.onNavy,
                      side: const BorderSide(color: AppColors.border),
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text('Close'),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPdfResultRow(String code, String title, String cr, String ca, String exam, String total, String grade, String gp) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF13204D),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 60,
            child: Text(code, style: const TextStyle(color: AppColors.gold, fontWeight: FontWeight.bold, fontSize: 11)),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, overflow: TextOverflow.ellipsis, style: const TextStyle(color: AppColors.onNavy, fontSize: 11)),
                Text('$cr • CA: $ca/30 • Exam: $exam/70', style: const TextStyle(color: AppColors.muted, fontSize: 9.5)),
              ],
            ),
          ),
          Text(total, style: const TextStyle(color: AppColors.onNavy, fontWeight: FontWeight.bold, fontSize: 12)),
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.navyDeep,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: AppColors.gold.withValues(alpha: 0.5)),
            ),
            child: Text(grade, style: const TextStyle(color: AppColors.gold, fontWeight: FontWeight.bold, fontSize: 10.5)),
          ),
        ],
      ),
    );
  }

  // 2. Official Timetable PDF Modal
  void _showTimetablePdfModal(BuildContext context) {
    const timetableText = '''
================================================================================
FAH ACADEMY • CAMEROON
FACULTY OF ENGINEERING & COMPUTING • LEVEL 200 (YEAR 2)
MASTER LECTURE & VENUE TIMETABLE • SEMESTER 2 • 2026/2027
================================================================================
MONDAY:
  • 10:00 - 12:00 | SWE201: Advanced Data Structures   | Hall B-104 | Dr. Raymond Vance
  • 14:00 - 16:00 | SWE203: Object-Oriented Design     | Lab 3      | Dr. Raymond Vance

TUESDAY:
  • 08:00 - 10:00 | ICT207: Computer Networks & Arch.  | Hall A-102 | Prof. Samuel E. Mbella
  • 11:00 - 13:00 | MAT205: Linear Algebra & Calculus  | Amphithéâtre 1 | Dr. Paul F. Tiku

WEDNESDAY:
  • 08:00 - 10:00 | CEF205: Digital Logic & Microproc. | Hall A-201 | Dr. Beatrice M. Ngu
  • 14:00 - 17:00 | SWE201: Algorithmic Lab Practical  | Software Lab 2 | Engr. K. Fong

THURSDAY:
  • 10:00 - 12:00 | SWE207: Software Testing & QA      | Computer Lab 1 | Dr. Raymond Vance
  • 14:00 - 16:00 | CEF205: Hardware Architecture TP   | Electronics Lab | Dr. Beatrice M. Ngu

FRIDAY:
  • 14:00 - 16:00 | GES201: Bilingual English/French   | Room 108   | Mme. A. Ngozi
--------------------------------------------------------------------------------
AUTHORIZED BY: Timetable & Venue Allocation Senate Committee
ISSUED: October 2026 • Valid for Academic Term 2026/2027
================================================================================
''';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.navyDeep,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.sizeOf(ctx).height * 0.90,
            maxWidth: 750,
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.calendar_month, color: AppColors.gold, size: 22),
                      SizedBox(width: 8),
                      Text(
                        'Master Lecture Timetable (Official PDF)',
                        style: TextStyle(color: AppColors.onNavy, fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: AppColors.muted),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Expanded(
                child: SingleChildScrollView(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0C1536),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Center(
                          child: Text(
                            'FAH ACADEMY • LEVEL 200 (YEAR 2) TIMETABLE\nFaculty of Engineering & Computing • Semester 2',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: AppColors.gold, fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                        ),
                        const SizedBox(height: 14),
                        const Divider(color: AppColors.border),
                        const SizedBox(height: 8),

                        _buildTimetableDayBlock('Monday', [
                          ('SWE201: Advanced Data Structures', '10:00 - 12:00', 'Hall B-104', 'Dr. Raymond Vance'),
                          ('SWE203: Object-Oriented Software Design', '14:00 - 16:00', 'Software Lab 3', 'Dr. Raymond Vance'),
                        ]),
                        _buildTimetableDayBlock('Tuesday', [
                          ('ICT207: Computer Networks & Telecom', '08:00 - 10:00', 'Hall A-102', 'Prof. Samuel E. Mbella'),
                          ('MAT205: Linear Algebra & Matrices', '11:00 - 13:00', 'Amphi 1', 'Dr. Paul F. Tiku'),
                        ]),
                        _buildTimetableDayBlock('Wednesday', [
                          ('CEF205: Digital Logic & Microprocessors', '08:00 - 10:00', 'Hall A-201', 'Dr. Beatrice M. Ngu'),
                          ('SWE201: Practical Lab Session', '14:00 - 17:00', 'Software Lab 2', 'Engr. K. Fong'),
                        ]),
                        _buildTimetableDayBlock('Thursday', [
                          ('SWE207: Software Testing & QA', '10:00 - 12:00', 'Lab 1', 'Dr. Raymond Vance'),
                        ]),
                        _buildTimetableDayBlock('Friday', [
                          ('GES201: Bilingual Professional English/French', '14:00 - 16:00', 'Room 108', 'Mme. A. Ngozi'),
                        ]),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.gold,
                        foregroundColor: AppColors.navyDeep,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: () {
                        _downloadDocumentAsPdf(
                          context: context,
                          title: 'Master Lecture Timetable',
                          fileName: 'FAH_Academy_L200_Timetable_S2.pdf',
                          rawText: timetableText,
                        );
                      },
                      icon: const Icon(Icons.download, size: 18),
                      label: const Text('Download Timetable (PDF)', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.onNavy,
                      side: const BorderSide(color: AppColors.border),
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text('Close'),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTimetableDayBlock(String day, List<(String, String, String, String)> slots) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(day.toUpperCase(), style: const TextStyle(color: AppColors.gold, fontSize: 11, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          ...slots.map((s) => Container(
            margin: const EdgeInsets.only(bottom: 6),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF13204D),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.navyDeep,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(s.$2, style: const TextStyle(color: AppColors.gold, fontSize: 10, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(s.$1, style: const TextStyle(color: AppColors.onNavy, fontSize: 11.5, fontWeight: FontWeight.w600)),
                      Text('${s.$3} • ${s.$4}', style: const TextStyle(color: AppColors.muted, fontSize: 10)),
                    ],
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  // 3. Official Fee Clearance & Treasury Receipt PDF Modal
  void _showFeeReceiptPdfModal(BuildContext context, DashboardData data) {
    const feeReceiptText = '''
================================================================================
FAH ACADEMY BURSARY & TREASURY BOARD
OFFICIAL TUITION PAYMENT RECEIPT & CLEARANCE SLIP (FCFA)
ACADEMIC YEAR 2026/2027 • FIRST & SECOND SEMESTERS
================================================================================
STUDENT DETAILS:
  • Name:             Clarisse M. Fong
  • Matricule / ID:   FAH-2024-SW0482
  • Department:       Software Engineering
  • Academic Level:   Level 200 (Year 2)

FEE INVOICE & PAYMENT LEDGER:
  • Total Annual Tuition:    650,000 FCFA
  • Total Amount Cleared:    450,000 FCFA (69.2% Cleared)
  • Remaining Balance:       200,000 FCFA

TRANSACTION DETAILS:
  1. Oct 16, 2026: 250,000 FCFA • UBA Cameroon Deposit (Slip: UBA-CM-2026-99452)
  2. Oct 18, 2026: 200,000 FCFA • Afriland First Bank Deposit (Slip: AFB-DLA-44109)

EXAMINATION CLEARANCE STATUS:
  [ ✓ GRANTED ] ELIGIBLE TO SIT FOR TERMINAL SEMESTER EXAMINATIONS
  (Institutional 60% Clearance Threshold Met)

BURSAR AUTHENTICATION SEAL: BA01-FE22-BA
OFFICER IN CHARGE:          Dr. Beatrice M. Ngu (Treasury Comptroller)
DATE OF ISSUANCE:           October 2026
================================================================================
''';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.navyDeep,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.sizeOf(ctx).height * 0.90,
            maxWidth: 750,
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.receipt_long, color: AppColors.gold, size: 22),
                      SizedBox(width: 8),
                      Text(
                        'Bursary Clearance Receipt (Official PDF)',
                        style: TextStyle(color: AppColors.onNavy, fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: AppColors.muted),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Expanded(
                child: SingleChildScrollView(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0C1536),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Center(
                          child: Text(
                            'FAH ACADEMY • BURSARY AUDIT DESK\nOFFICIAL TUITION PAYMENT RECEIPT & CLEARANCE',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: AppColors.gold, fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Divider(color: AppColors.border),
                        const SizedBox(height: 8),

                        const Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('STUDENT: Clarisse M. Fong', style: TextStyle(color: AppColors.onNavy, fontWeight: FontWeight.bold, fontSize: 12)),
                            Text('MAT: FAH-2024-SW0482', style: TextStyle(color: AppColors.gold, fontWeight: FontWeight.bold, fontSize: 12)),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Ledger summary
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFF13204D),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Column(
                                children: [
                                  Text('TOTAL INVOICED', style: TextStyle(color: AppColors.muted, fontSize: 10)),
                                  SizedBox(height: 2),
                                  Text('650,000 FCFA', style: TextStyle(color: AppColors.onNavy, fontWeight: FontWeight.bold, fontSize: 14)),
                                ],
                              ),
                              Column(
                                children: [
                                  Text('TOTAL SETTLED', style: TextStyle(color: AppColors.muted, fontSize: 10)),
                                  SizedBox(height: 2),
                                  Text('450,000 FCFA', style: TextStyle(color: Color(0xFF4ADE80), fontWeight: FontWeight.bold, fontSize: 14)),
                                ],
                              ),
                              Column(
                                children: [
                                  Text('BALANCE', style: TextStyle(color: AppColors.muted, fontSize: 10)),
                                  SizedBox(height: 2),
                                  Text('200,000 FCFA', style: TextStyle(color: AppColors.gold, fontWeight: FontWeight.bold, fontSize: 14)),
                                ],
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 14),
                        const Text('VALIDATED BANK DEPOSITS', style: TextStyle(color: AppColors.gold, fontSize: 10.5, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 6),
                        _buildFeeDepositItem('UBA Cameroon Deposit', '250,000 FCFA', 'Slip: UBA-CM-2026-99452 • Oct 16, 2026', 'Verified'),
                        _buildFeeDepositItem('Afriland First Bank Wire', '200,000 FCFA', 'Slip: AFB-DLA-44109 • Oct 18, 2026', 'Verified'),

                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: const Color(0xFF152A20),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: const Color(0xFF4ADE80).withValues(alpha: 0.5)),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.check_circle, color: Color(0xFF4ADE80), size: 18),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'EXAMINATION ELIGIBILITY: APPROVED\nStudent has exceeded the institutional 60% minimum fee threshold for Terminal Examination clearance.',
                                  style: TextStyle(color: Color(0xFF4ADE80), fontSize: 10.5, fontWeight: FontWeight.w600, height: 1.3),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 14),
                        const Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('BURSAR SEAL: BA01-FE22-BA', style: TextStyle(color: AppColors.gold, fontSize: 10, fontWeight: FontWeight.bold)),
                            Text('Dr. Beatrice M. Ngu • Bursary Desk', style: TextStyle(color: AppColors.muted, fontSize: 10)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.gold,
                        foregroundColor: AppColors.navyDeep,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: () {
                        _downloadDocumentAsPdf(
                          context: context,
                          title: 'Bursary Clearance Receipt',
                          fileName: 'FAH_Bursary_Clearance_FAH2024SW0482.pdf',
                          rawText: feeReceiptText,
                        );
                      },
                      icon: const Icon(Icons.download, size: 18),
                      label: const Text('Download Official Receipt (PDF)', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.onNavy,
                      side: const BorderSide(color: AppColors.border),
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text('Close'),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFeeDepositItem(String title, String amount, String sub, String status) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF13204D),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(color: AppColors.onNavy, fontSize: 11, fontWeight: FontWeight.bold)),
              Text(sub, style: const TextStyle(color: AppColors.muted, fontSize: 9.5)),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(amount, style: const TextStyle(color: AppColors.gold, fontSize: 11.5, fontWeight: FontWeight.bold)),
              Text(status, style: const TextStyle(color: Color(0xFF4ADE80), fontSize: 9.5, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }

  // 4. Form 74 Course Registration PDF Modal
  void _showCourseRegistrationPdfModal(BuildContext context, DashboardData data) {
    const regText = '''
================================================================================
FAH ACADEMY • REPUBLIC OF CAMEROON
FORM 74: SEMESTER COURSE REGISTRATION & EXAMINATION CARD
ACADEMIC YEAR 2026/2027 • SEMESTER 2
================================================================================
STUDENT NAME: Clarisse M. Fong
MATRICULE:    FAH-2024-SW0482
PROGRAM:      B.Eng Software Engineering (Level 200 / Year 2)
TOTAL LOAD:   21 Credit Units
--------------------------------------------------------------------------------
REGISTERED COURSES:
  1. SWE201: Advanced Data Structures (4 Credits) • Lecturer: Dr. Raymond Vance
  2. SWE203: Object-Oriented Software Design (3 Credits) • Lecturer: Dr. Raymond Vance
  3. CEF205: Digital Logic & Microprocessors (4 Credits) • Lecturer: Dr. Beatrice M. Ngu
  4. ICT207: Computer Networks & Protocols (3 Credits) • Lecturer: Prof. Samuel E. Mbella
  5. SWE207: Software Testing & QA (4 Credits) • Lecturer: Dr. Raymond Vance
  6. GES201: Professional Communication (3 Credits) • Lecturer: Mme. A. Ngozi
--------------------------------------------------------------------------------
STUDENT SIGNATURE:     [ Validated Digitally ]
ACADEMIC ADVISOR:      Dr. Raymond Vance
HEAD OF DEPARTMENT:    Prof. E. T. Tamba
REGISTRAR APPROVAL:    MINESUP-REG-74-VALIDATED
================================================================================
''';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.navyDeep,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(ctx).height * 0.88,
          maxWidth: 700,
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(Icons.assignment_turned_in, color: AppColors.gold, size: 22),
                    SizedBox(width: 8),
                    Text('Form 74 Course Registration Slip', style: TextStyle(color: AppColors.onNavy, fontSize: 16, fontWeight: FontWeight.bold)),
                  ],
                ),
                IconButton(icon: const Icon(Icons.close, color: AppColors.muted), onPressed: () => Navigator.pop(ctx)),
              ],
            ),
            const SizedBox(height: 12),
            Expanded(
              child: SingleChildScrollView(
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0C1536),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: const Text(
                    regText,
                    style: TextStyle(color: AppColors.muted, fontFamily: 'monospace', fontSize: 11, height: 1.4),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.gold,
                foregroundColor: AppColors.navyDeep,
                minimumSize: const Size(double.infinity, 44),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () {
                _downloadDocumentAsPdf(
                  context: context,
                  title: 'Form 74 Course Registration Slip',
                  fileName: 'FAH_Form74_Course_Registration.pdf',
                  rawText: regText,
                );
              },
              icon: const Icon(Icons.download, size: 18),
              label: const Text('Download Form 74 (PDF)', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  // 5. Faculty Grade Broadsheet PDF Modal
  void _showGradeBroadsheetPdfModal(BuildContext context, String courseCode) {
    const broadsheetText = '''
================================================================================
FAH ACADEMY • SENATE EXAMINATION BOARD
OFFICIAL GRADE BROADSHEET • CONTINUOUS ASSESSMENT & TERMINAL EXAMINATION
================================================================================
COURSE:     SWE201 - Advanced Data Structures (4 Credit Units)
LECTURER:   Dr. Raymond Vance (Staff ID: FAH-FAC-014)
SEMESTER:   2026/2027 Semester 2 • Class: Level 200 (Cohort A)
--------------------------------------------------------------------------------
MATRICULE       | STUDENT NAME         | CA /30 | EX /70 | TOTAL | GRADE | STATUS
--------------------------------------------------------------------------------
FAH-2026-SV0482 | Brenda N. Tabi       | 28.5   | 62.0   | 90.5  | A     | PASSED
FAH-2026-SV0419 | Emmanuel K. Che      | 26.0   | 58.0   | 84.0  | A     | PASSED
FAH-2026-SV0390 | Divine F. Ayuk       | 24.5   | 51.5   | 76.0  | B+    | PASSED
FAH-2026-SV0532 | Marcelle O. Ndong    | 12.0   | 24.0   | 36.0  | F     | RESIT
FAH-2026-SV0441 | Boris T. Enow        | 22.0   | 48.0   | 70.0  | B+    | PASSED
--------------------------------------------------------------------------------
SENATE COMPLIANCE: 80% Pass Rate • 1 Flagged Resit • Harmonized 4.0 GP Scale
SUBMITTED BY:      Dr. Raymond Vance (Designated Lecturer)
SEAL CODE:         SENATE-SWE201-2026-VANCE
================================================================================
''';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.navyDeep,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(ctx).height * 0.88,
          maxWidth: 700,
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(Icons.assessment, color: AppColors.gold, size: 22),
                    SizedBox(width: 8),
                    Text('Senate Grade Broadsheet (SWE201)', style: TextStyle(color: AppColors.onNavy, fontSize: 16, fontWeight: FontWeight.bold)),
                  ],
                ),
                IconButton(icon: const Icon(Icons.close, color: AppColors.muted), onPressed: () => Navigator.pop(ctx)),
              ],
            ),
            const SizedBox(height: 12),
            Expanded(
              child: SingleChildScrollView(
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0C1536),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: const Text(
                    broadsheetText,
                    style: TextStyle(color: AppColors.muted, fontFamily: 'monospace', fontSize: 11, height: 1.4),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.gold,
                foregroundColor: AppColors.navyDeep,
                minimumSize: const Size(double.infinity, 44),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () {
                _downloadDocumentAsPdf(
                  context: context,
                  title: 'Senate Grade Broadsheet',
                  fileName: 'Senate_Broadsheet_SWE201.pdf',
                  rawText: broadsheetText,
                );
              },
              icon: const Icon(Icons.download, size: 18),
              label: const Text('Download Broadsheet (PDF)', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // TAB 1: HOME / DASHBOARD (Matching Image 5)
  // ---------------------------------------------------------------------------

  Widget _buildStudentHomeTab(DashboardData data) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      children: [
        // Welcome Card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'STUDENT PORTAL • L200',
                      style: TextStyle(
                        color: AppColors.gold,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.6,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Welcome back, ${data.displayName.split(' ').first}',
                      style: const TextStyle(
                        color: AppColors.onNavy,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'Software Engineering • Level 200',
                      style: TextStyle(color: AppColors.muted, fontSize: 12),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.navyDeep,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'ID: ${data.userId}',
                            style: const TextStyle(
                              color: AppColors.muted,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.navyDeep,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.circle, color: AppColors.gold, size: 6),
                              SizedBox(width: 4),
                              Text(
                                '2026/2027 S1',
                                style: TextStyle(
                                  color: AppColors.onNavy,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.successBackground.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.green.shade600),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.check, size: 11, color: Colors.green.shade400),
                              const SizedBox(width: 4),
                              Text(
                                'REGISTRATION: OPEN',
                                style: TextStyle(
                                  color: Colors.green.shade300,
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.goldTint,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: AppColors.gold),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.warning_amber_rounded, size: 11, color: AppColors.gold),
                              SizedBox(width: 4),
                              Text(
                                'FEES: 75% SETTLED',
                                style: TextStyle(
                                  color: AppColors.gold,
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Stack(
                children: [
                  Container(
                    width: 58,
                    height: 58,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: AppColors.navyDeep,
                      border: Border.all(color: AppColors.gold, width: 1.5),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.asset(
                        'assets/images/logo.png',
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => const Icon(
                          Icons.person,
                          color: AppColors.gold,
                          size: 32,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: -2,
                    right: -2,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(
                        color: AppColors.navyDeep,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.verified,
                        color: AppColors.gold,
                        size: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),

        // Academic Standing Card
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Row(
              children: [
                Icon(Icons.analytics_outlined, color: AppColors.gold, size: 16),
                SizedBox(width: 6),
                Text(
                  'Academic Standing',
                  style: TextStyle(
                    color: AppColors.onNavy,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            GestureDetector(
              onTap: () => setState(() => _studentTabIndex = 3),
              child: const Text(
                'Honors List',
                style: TextStyle(
                  color: AppColors.gold,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
                    const Row(
                      children: [
                        Text(
                          'TERM GPA',
                          style: TextStyle(color: AppColors.muted, fontSize: 9),
                        ),
                        SizedBox(width: 4),
                        Icon(Icons.star, color: AppColors.gold, size: 11),
                      ],
                    ),
                    const SizedBox(height: 2),
                    RichText(
                      text: const TextSpan(
                        text: '3.82',
                        style: TextStyle(
                          color: AppColors.gold,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                        children: [
                          TextSpan(
                            text: ' / 4.00',
                            style: TextStyle(color: AppColors.muted, fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'CGPA 3.75',
                      style: TextStyle(color: AppColors.muted, fontSize: 10),
                    ),
                  ],
                ),
              ),
              Container(width: 1, height: 40, color: AppColors.border),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Text(
                          'CREDITS',
                          style: TextStyle(color: AppColors.muted, fontSize: 9),
                        ),
                        SizedBox(width: 4),
                        Icon(Icons.menu_book, color: AppColors.muted, size: 11),
                      ],
                    ),
                    const SizedBox(height: 2),
                    RichText(
                      text: const TextSpan(
                        text: '18',
                        style: TextStyle(
                          color: AppColors.onNavy,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                        children: [
                          TextSpan(
                            text: '/21',
                            style: TextStyle(color: AppColors.muted, fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 4),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: const LinearProgressIndicator(
                        value: 18 / 21,
                        backgroundColor: AppColors.navyDeep,
                        valueColor: AlwaysStoppedAnimation(AppColors.gold),
                        minHeight: 4,
                      ),
                    ),
                  ],
                ),
              ),
              Container(width: 1, height: 40, color: AppColors.border),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Text(
                          'ENROLLED',
                          style: TextStyle(color: AppColors.muted, fontSize: 9),
                        ),
                        SizedBox(width: 4),
                        Icon(Icons.article_outlined, color: AppColors.muted, size: 11),
                      ],
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      '6',
                      style: TextStyle(
                        color: AppColors.onNavy,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      '• Active S1',
                      style: TextStyle(color: AppColors.gold, fontSize: 10),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),

        // Quick Access
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [
            Text(
              'Quick Access',
              style: TextStyle(
                color: AppColors.onNavy,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              '4 shortcuts',
              style: TextStyle(color: AppColors.muted, fontSize: 11),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _buildQuickActionCard(
                icon: Icons.edit_note,
                title: 'Register',
                subtitle: 'Courses',
                badgeText: '3d left',
                isHighlight: true,
                onTap: () => setState(() => _studentTabIndex = 1),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildQuickActionCard(
                icon: Icons.calendar_today_outlined,
                title: 'Timetable',
                subtitle: 'Week 08',
                hasArrow: true,
                onTap: () => _showTimetableModal(),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _buildQuickActionCard(
                icon: Icons.account_balance_wallet_outlined,
                title: 'Pay Fees',
                subtitle: 'Balance 25%',
                hasArrow: true,
                onTap: () => setState(() => _studentTabIndex = 2),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildQuickActionCard(
                icon: Icons.grade_outlined,
                title: 'Results',
                subtitle: 'Transcripts',
                hasArrow: true,
                onTap: () => setState(() => _studentTabIndex = 3),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),

        // Today's Schedule
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Text(
                  "Today's Schedule",
                  style: TextStyle(
                    color: AppColors.onNavy,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceRaised,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text(
                    '2 Remaining',
                    style: TextStyle(color: AppColors.muted, fontSize: 9),
                  ),
                ),
              ],
            ),
            const Text(
              'Full Agenda',
              style: TextStyle(color: AppColors.gold, fontSize: 11),
            ),
          ],
        ),
        const SizedBox(height: 10),

        // Schedule Card 1
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.gold,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  'IN 45 MINS • Lecture',
                  style: TextStyle(
                    color: AppColors.navyDeep,
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Advanced Data Structures',
                style: TextStyle(
                  color: AppColors.onNavy,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 2),
              const Text(
                'SW201 • 3 Credit Units',
                style: TextStyle(color: AppColors.muted, fontSize: 11),
              ),
              const SizedBox(height: 10),
              const Row(
                children: [
                  Icon(Icons.schedule, color: AppColors.gold, size: 13),
                  SizedBox(width: 4),
                  Text(
                    '10:00 AM – 12:00 PM',
                    style: TextStyle(color: AppColors.onNavy, fontSize: 11),
                  ),
                  SizedBox(width: 14),
                  Icon(Icons.location_on_outlined, color: AppColors.gold, size: 13),
                  SizedBox(width: 4),
                  Text(
                    'Hall B-104',
                    style: TextStyle(color: AppColors.onNavy, fontSize: 11),
                  ),
                ],
              ),
              const Divider(color: AppColors.border, height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Row(
                    children: [
                      CircleAvatar(
                        radius: 11,
                        backgroundColor: AppColors.navyDeep,
                        child: Text(
                          'RV',
                          style: TextStyle(color: AppColors.gold, fontSize: 9),
                        ),
                      ),
                      SizedBox(width: 6),
                      Text(
                        'Dr. Raymond Vance',
                        style: TextStyle(color: AppColors.muted, fontSize: 11),
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Downloading course materials...')),
                      );
                    },
                    child: const Row(
                      children: [
                        Text(
                          'Materials',
                          style: TextStyle(color: AppColors.gold, fontSize: 11),
                        ),
                        SizedBox(width: 3),
                        Icon(Icons.arrow_forward, color: AppColors.gold, size: 12),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),

        // Schedule Card 2
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.surfaceRaised,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  'THIS AFTERNOON • Practical Lab',
                  style: TextStyle(
                    color: AppColors.muted,
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Database Management Systems',
                style: TextStyle(
                  color: AppColors.onNavy,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 2),
              const Text(
                'SW203 • Lab Session',
                style: TextStyle(color: AppColors.muted, fontSize: 11),
              ),
              const SizedBox(height: 10),
              const Row(
                children: [
                  Icon(Icons.schedule, color: AppColors.gold, size: 13),
                  SizedBox(width: 4),
                  Text(
                    '02:00 PM – 04:00 PM',
                    style: TextStyle(color: AppColors.onNavy, fontSize: 11),
                  ),
                  SizedBox(width: 14),
                  Icon(Icons.business_outlined, color: AppColors.gold, size: 13),
                  SizedBox(width: 4),
                  Text(
                    'Lab 3 (Engineering Block)',
                    style: TextStyle(color: AppColors.onNavy, fontSize: 11),
                  ),
                ],
              ),
              const Divider(color: AppColors.border, height: 20),
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 11,
                        backgroundColor: AppColors.navyDeep,
                        child: Text(
                          'CK',
                          style: TextStyle(color: AppColors.gold, fontSize: 9),
                        ),
                      ),
                      SizedBox(width: 6),
                      Text(
                        'Prof. Cynthia K.',
                        style: TextStyle(color: AppColors.muted, fontSize: 11),
                      ),
                    ],
                  ),
                  Text(
                    'Seat assigned: L3-18',
                    style: TextStyle(color: AppColors.gold, fontSize: 10),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Official Notices
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [
            Row(
              children: [
                Icon(Icons.campaign_outlined, color: AppColors.gold, size: 16),
                SizedBox(width: 6),
                Text(
                  'Official Notices',
                  style: TextStyle(
                    color: AppColors.onNavy,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            Text(
              'View All (4)',
              style: TextStyle(color: AppColors.gold, fontSize: 11),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                      color: AppColors.navyDeep,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.notifications_active_outlined,
                      color: AppColors.gold,
                      size: 14,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'ACADEMIC SECRETARIAT • 2h ago',
                      style: TextStyle(
                        color: AppColors.gold,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                'Continuous Assessment Schedule Released',
                style: TextStyle(
                  color: AppColors.onNavy,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'The Mid-Semester CA timetables for Level 200 Faculty of Computing and Information...',
                style: TextStyle(color: AppColors.muted, fontSize: 11),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.navyDeep,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.picture_as_pdf, color: Colors.redAccent, size: 20),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'CA_Schedule_S1_2026.pdf',
                            style: TextStyle(
                              color: AppColors.onNavy,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            '1.4 MB • Official Document',
                            style: TextStyle(color: AppColors.muted, fontSize: 9),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.download, color: AppColors.gold, size: 18),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Downloading CA_Schedule_S1_2026.pdf...')),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // Dean's Honor Target
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: AppColors.navyDeep,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.military_tech, color: AppColors.gold, size: 20),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "DEAN'S HONOR TARGET",
                      style: TextStyle(
                        color: AppColors.gold,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Maintain ≥3.80 this term for academic scholarship grant.',
                      style: TextStyle(color: AppColors.muted, fontSize: 11),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildQuickActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    String? badgeText,
    bool isHighlight = false,
    bool hasArrow = false,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isHighlight ? AppColors.gold : AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isHighlight ? AppColors.gold : AppColors.border,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isHighlight ? AppColors.navyDeep : AppColors.gold,
              size: 22,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          title,
                          style: TextStyle(
                            color: isHighlight ? AppColors.navyDeep : AppColors.onNavy,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (badgeText != null) ...[
                        const SizedBox(width: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 4,
                            vertical: 1,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.red.shade900,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            badgeText,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 8,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: isHighlight
                          ? AppColors.navyDeep.withValues(alpha: 0.8)
                          : AppColors.muted,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
            if (hasArrow)
              const Icon(
                Icons.chevron_right,
                color: AppColors.muted,
                size: 16,
              ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // TAB 2: ACADEMICS / COURSE REGISTRATION (Matching Image 1)
  // ---------------------------------------------------------------------------

  Widget _buildStudentAcademicsTab(DashboardData data) {
    final allCourses = [
      const _StudentCourseModel(
        code: 'SW201',
        credits: 3,
        type: 'CORE',
        title: 'Advanced Data Structures',
        instructor: 'Dr. Raymond Vance',
        prereq: 'Prereq: SW101 (Passed)',
      ),
      const _StudentCourseModel(
        code: 'SW203',
        credits: 3,
        type: 'CORE',
        title: 'Database Management Systems',
        instructor: 'Prof. Cynthia K.',
        prereq: 'Prerequisite: None',
      ),
      const _StudentCourseModel(
        code: 'SW205',
        credits: 3,
        type: 'CORE',
        title: 'Web Application Engineering',
        instructor: 'Eng. Michael T.',
        prereq: 'Prereq: SW102 (Passed)',
      ),
      const _StudentCourseModel(
        code: 'SW207',
        credits: 3,
        type: 'ELECTIVE',
        title: 'Computer Networks & Security',
        instructor: 'Dr. Sarah O.',
        prereq: 'Prereq: SW105 (Passed)',
      ),
      const _StudentCourseModel(
        code: 'SW209',
        credits: 3,
        type: 'CORE',
        title: 'Systems Architecture',
        instructor: 'Dept. Chair Panel',
        prereq: 'Prereq SW108 missing',
        isLocked: true,
        lockReason: 'Prereq SW108 missing',
      ),
      const _StudentCourseModel(
        code: 'SW211',
        credits: 3,
        type: 'ELECTIVE',
        title: 'Mobile App Dev (Flutter)',
        instructor: 'Eng. David M.',
        prereq: 'Prerequisite: None',
      ),
    ];

    final filteredCourses = allCourses.where((c) {
      if (_academicsFilterIndex == 1 && c.type != 'CORE') return false;
      if (_academicsFilterIndex == 2 && c.type != 'ELECTIVE') return false;
      if (_academicsSearchQuery.isNotEmpty) {
        final q = _academicsSearchQuery.toLowerCase();
        return c.code.toLowerCase().contains(q) ||
            c.title.toLowerCase().contains(q) ||
            c.instructor.toLowerCase().contains(q);
      }
      return true;
    }).toList();

    int totalSelectedCredits = 0;
    for (final c in allCourses) {
      if (_selectedCourseCodes.contains(c.code)) {
        totalSelectedCredits += c.credits;
      }
    }

    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            children: [
              // Registration Window Banner
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: AppColors.navyDeep,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.timer_outlined,
                        color: AppColors.gold,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'REGISTRATION WINDOW',
                            style: TextStyle(
                              color: AppColors.muted,
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Closes in: 3d 14h 22m',
                            style: TextStyle(
                              color: AppColors.onNavy,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceRaised,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        'REGULAR S1',
                        style: TextStyle(
                          color: AppColors.gold,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // Academic Workload Card
              Container(
                padding: const EdgeInsets.all(14),
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
                        const Text(
                          'ACADEMIC WORKLOAD',
                          style: TextStyle(
                            color: AppColors.muted,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.successBackground.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.green.shade600),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.check_circle_outline,
                                color: Colors.green.shade400,
                                size: 12,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Charge Cleared',
                                style: TextStyle(
                                  color: Colors.green.shade300,
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    RichText(
                      text: TextSpan(
                        text: '$totalSelectedCredits',
                        style: const TextStyle(
                          color: AppColors.onNavy,
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                        ),
                        children: const [
                          TextSpan(
                            text: ' / 21 Max Credits',
                            style: TextStyle(
                              color: AppColors.muted,
                              fontSize: 14,
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: totalSelectedCredits / 21,
                        backgroundColor: AppColors.navyDeep,
                        valueColor: const AlwaysStoppedAnimation(AppColors.gold),
                        minHeight: 6,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Min: 12 Units (Full-time)',
                          style: TextStyle(color: AppColors.muted, fontSize: 10),
                        ),
                        Text(
                          '${21 - totalSelectedCredits} units available',
                          style: const TextStyle(
                            color: AppColors.muted,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // Search Bar
              TextField(
                onChanged: (val) => setState(() => _academicsSearchQuery = val),
                style: const TextStyle(color: AppColors.onNavy, fontSize: 13),
                decoration: InputDecoration(
                  hintText: 'Search course code or title...',
                  hintStyle: const TextStyle(color: AppColors.muted, fontSize: 13),
                  prefixIcon: const Icon(
                    Icons.search,
                    color: AppColors.muted,
                    size: 18,
                  ),
                  filled: true,
                  fillColor: AppColors.surface,
                  contentPadding: const EdgeInsets.symmetric(vertical: 10),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Filter Chips
              Row(
                children: [
                  _buildFilterChip('All Courses (6)', 0),
                  const SizedBox(width: 8),
                  _buildFilterChip('Core Required (4)', 1),
                  const SizedBox(width: 8),
                  _buildFilterChip('Electives (2)', 2),
                ],
              ),
              const SizedBox(height: 14),

              // Course Cards List
              ...filteredCourses.map((c) => _buildCourseCard(c)),
              const SizedBox(height: 40),
            ],
          ),
        ),

        // Bottom Sticky Confirmation Bar
        Container(
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            color: AppColors.navyDeep,
            border: Border(top: BorderSide(color: AppColors.border, width: 0.8)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.check_box_outlined,
                        color: AppColors.gold,
                        size: 18,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${_selectedCourseCodes.length} Courses • $totalSelectedCredits Credits',
                        style: const TextStyle(
                          color: AppColors.onNavy,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const Text(
                    'Max Allowed: 21',
                    style: TextStyle(color: AppColors.muted, fontSize: 11),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.gold,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Registration for ${_selectedCourseCodes.length} courses submitted for institutional validation.',
                        ),
                        backgroundColor: AppColors.successBackground,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Confirm & Submit Registration',
                        style: TextStyle(
                          color: AppColors.navyDeep,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      SizedBox(width: 6),
                      Icon(
                        Icons.arrow_forward,
                        color: AppColors.navyDeep,
                        size: 16,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.gold,
                    side: const BorderSide(color: AppColors.gold),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () => _showCourseRegistrationPdfModal(context, data),
                  icon: const Icon(Icons.picture_as_pdf, size: 16),
                  label: const Text('Download Course Registration Slip (Form 74 PDF)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Submissions require institutional server validation',
                style: TextStyle(color: AppColors.muted, fontSize: 10),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChip(String label, int index) {
    final selected = _academicsFilterIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _academicsFilterIndex = index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? AppColors.gold : AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? AppColors.gold : AppColors.border,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? AppColors.navyDeep : AppColors.onNavy,
            fontSize: 11,
            fontWeight: selected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildCourseCard(_StudentCourseModel c) {
    final isSelected = _selectedCourseCodes.contains(c.code);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected ? AppColors.gold : AppColors.border,
          width: isSelected ? 1.5 : 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${c.code} • ${c.credits} Credit Units',
                style: const TextStyle(
                  color: AppColors.gold,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.navyDeep,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  c.type,
                  style: const TextStyle(
                    color: AppColors.muted,
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            c.title,
            style: const TextStyle(
              color: AppColors.onNavy,
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.person_outline, color: AppColors.muted, size: 13),
              const SizedBox(width: 4),
              Text(
                c.instructor,
                style: const TextStyle(color: AppColors.muted, fontSize: 11),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (c.isLocked)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.red.shade900.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: Colors.red.shade700),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.error_outline, size: 11, color: Colors.red.shade300),
                      const SizedBox(width: 4),
                      Text(
                        c.lockReason ?? 'Prerequisite missing',
                        style: TextStyle(
                          color: Colors.red.shade300,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                )
              else
                Row(
                  children: [
                    Icon(
                      c.prereq.contains('None')
                          ? Icons.check
                          : Icons.alt_route,
                      color: AppColors.muted,
                      size: 13,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      c.prereq,
                      style: const TextStyle(color: AppColors.muted, fontSize: 11),
                    ),
                  ],
                ),
              if (c.isLocked)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.navyDeep,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.lock_outline, color: AppColors.muted, size: 14),
                      SizedBox(width: 4),
                      Text(
                        'Locked',
                        style: TextStyle(color: AppColors.muted, fontSize: 11),
                      ),
                    ],
                  ),
                )
              else if (isSelected)
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.gold,
                    foregroundColor: AppColors.navyDeep,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                  ),
                  onPressed: () {
                    setState(() => _selectedCourseCodes.remove(c.code));
                  },
                  icon: const Icon(Icons.check, size: 14),
                  label: const Text(
                    'Selected',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                )
              else
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.onNavy,
                    backgroundColor: AppColors.navyDeep,
                    side: const BorderSide(color: AppColors.border),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () {
                    setState(() => _selectedCourseCodes.add(c.code));
                  },
                  icon: const Icon(Icons.add, size: 14, color: AppColors.gold),
                  label: const Text(
                    'Add Course',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // TAB 3: FEES / FINANCIAL CLEARANCE PORTAL (Matching Image 4)
  // ---------------------------------------------------------------------------

  Widget _buildStudentFeesTab(DashboardData data) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      children: [
        // Top Banner
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: AppColors.navyDeep,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.account_balance,
                  color: AppColors.gold,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text(
                          'FINANCIAL CLEARANCE PORTAL',
                          style: TextStyle(
                            color: AppColors.onNavy,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceRaised,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'Active Term',
                            style: TextStyle(
                              color: AppColors.gold,
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'Tuition accounts are reconciled daily against UBA & Afriland institutional ledgers.',
                      style: TextStyle(color: AppColors.muted, fontSize: 10),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // Billing Period Dropdown
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.border),
          ),
          child: const Row(
            children: [
              Icon(Icons.calendar_month, color: AppColors.gold, size: 18),
              SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'BILLING PERIOD',
                      style: TextStyle(color: AppColors.muted, fontSize: 8),
                    ),
                    Text(
                      '2026/2027 Semester 1 (Current)',
                      style: TextStyle(
                        color: AppColors.onNavy,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.keyboard_arrow_down, color: AppColors.muted, size: 20),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // Outstanding Balance Card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'OUTSTANDING BALANCE',
                    style: TextStyle(
                      color: AppColors.muted,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.red.shade900.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.red.shade700),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.error_outline, size: 11, color: Colors.red.shade300),
                        const SizedBox(width: 4),
                        Text(
                          'Action Required',
                          style: TextStyle(
                            color: Colors.red.shade300,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              RichText(
                text: const TextSpan(
                  text: '200,000 ',
                  style: TextStyle(
                    color: AppColors.gold,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                  children: [
                    TextSpan(
                      text: 'FCFA',
                      style: TextStyle(
                        color: AppColors.onNavy,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: const LinearProgressIndicator(
                  value: 450000 / 650000,
                  backgroundColor: AppColors.navyDeep,
                  valueColor: AlwaysStoppedAnimation(AppColors.gold),
                  minHeight: 6,
                ),
              ),
              const SizedBox(height: 6),
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Settled: 450,000 FCFA',
                    style: TextStyle(color: AppColors.muted, fontSize: 10),
                  ),
                  Text(
                    '69% Cleared',
                    style: TextStyle(
                      color: AppColors.gold,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const Divider(color: AppColors.border, height: 24),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.navyDeep,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'TOTAL INVOICED',
                            style: TextStyle(color: AppColors.muted, fontSize: 8),
                          ),
                          SizedBox(height: 2),
                          Text(
                            '650,000 FCFA',
                            style: TextStyle(
                              color: AppColors.onNavy,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.navyDeep,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'TOTAL PAID',
                            style: TextStyle(color: AppColors.muted, fontSize: 8),
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              const Text(
                                '450,000 FCFA',
                                style: TextStyle(
                                  color: AppColors.onNavy,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Icon(
                                Icons.check_circle,
                                color: Colors.green.shade400,
                                size: 12,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.navyDeep,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.shield_outlined, color: AppColors.gold, size: 14),
                        SizedBox(width: 6),
                        Text(
                          'Platform Charge: 25,000 FCFA',
                          style: TextStyle(color: AppColors.muted, fontSize: 11),
                        ),
                      ],
                    ),
                    Text(
                      'Paid',
                      style: TextStyle(
                        color: Colors.greenAccent,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Installment Milestones
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Installment Milestones •',
              style: TextStyle(
                color: AppColors.onNavy,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'S1 Clearance Schedule',
              style: TextStyle(color: AppColors.muted, fontSize: 11),
            ),
          ],
        ),
        const SizedBox(height: 10),

        _buildMilestoneCard(
          number: '1',
          title: 'Semester Course Registration',
          dueDate: 'Due Sep 15, 2026 • Full academic portal access granted',
          amount: '250,000 FCFA',
          badgeText: 'Paid & Verified',
          isPaid: true,
        ),
        const SizedBox(height: 10),

        _buildMilestoneCard(
          number: '2',
          title: 'Mid-term CA & Lab Access',
          dueDate: 'Due Nov 10, 2026 • Continuous assessments evaluated',
          amount: '200,000 FCFA',
          badgeText: 'Paid & Verified',
          isPaid: true,
        ),
        const SizedBox(height: 10),

        _buildMilestoneCard(
          number: '3',
          title: 'Final Exam & Results Publication',
          dueDate: 'Due Jan 15, 2027',
          amount: '200,000 FCFA',
          badgeText: 'Due in 18 days',
          isActionRequired: true,
          alertText: 'Blocks S1 Official Transcript & Exam Hall Slip',
        ),
        const SizedBox(height: 20),

        // Bank Deposit Directives
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Bank Deposit Directives',
              style: TextStyle(
                color: AppColors.onNavy,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.surfaceRaised,
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                'Offline Process',
                style: TextStyle(color: AppColors.muted, fontSize: 9),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        const Text(
          'Fah Academy accepts direct transfers and teller deposits via our accredited banking partners. Use student matricule as transaction reference.',
          style: TextStyle(color: AppColors.muted, fontSize: 11),
        ),
        const SizedBox(height: 10),

        Row(
          children: [
            Expanded(
              child: _buildBankCard(
                bankName: 'UBA Cameroon',
                accountNumber: '10033 05200 120409',
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildBankCard(
                bankName: 'Afriland First',
                accountNumber: '00014 01290 884712',
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.gold,
            foregroundColor: AppColors.navyDeep,
            padding: const EdgeInsets.symmetric(vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Upload receipt form opened.')),
            );
          },
          icon: const Icon(Icons.receipt_long, size: 18),
          label: const Text(
            'Submit Bank Receipt Proof',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          ),
        ),
        const SizedBox(height: 8),

        OutlinedButton.icon(
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.onNavy,
            backgroundColor: AppColors.surface,
            side: const BorderSide(color: AppColors.border),
            padding: const EdgeInsets.symmetric(vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          onPressed: () {
            _showFeeReceiptPdfModal(context, data);
          },
          icon: const Icon(Icons.download, size: 18, color: AppColors.gold),
          label: const Text(
            'Download Official Statement (PDF)',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          ),
        ),
        const SizedBox(height: 20),

        // Verification Audit Log
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Verification Audit Log (3)',
              style: TextStyle(
                color: AppColors.onNavy,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            Row(
              children: [
                Text('Filter', style: TextStyle(color: AppColors.muted, fontSize: 11)),
                SizedBox(width: 4),
                Icon(Icons.filter_list, color: AppColors.gold, size: 14),
              ],
            ),
          ],
        ),
        const SizedBox(height: 10),

        _buildAuditLogCard(
          ref: 'Ref #UB-9940182',
          dateDesc: 'Submitted Yesterday • Deposit Slip',
          amount: '100,000 FCFA',
          status: 'Under Admin Review',
          statusColor: AppColors.gold,
          note: 'Awaiting Bursar validation. Does not clear active dues yet.',
          icon: Icons.receipt_outlined,
        ),
        const SizedBox(height: 8),

        _buildAuditLogCard(
          ref: 'Ref #UB-8829401',
          dateDesc: 'Oct 28, 2026 • UBA Wire Transfer',
          amount: '200,000 FCFA',
          status: 'Verified',
          statusColor: Colors.greenAccent,
          auditor: 'Audited by Bursar: A. Mbarga',
          icon: Icons.check_circle_outline,
        ),
        const SizedBox(height: 8),

        _buildAuditLogCard(
          ref: 'Ref #AF-3910284',
          dateDesc: 'Sep 12, 2026 • Afriland First Teller',
          amount: '250,000 FCFA',
          status: 'Verified',
          statusColor: Colors.greenAccent,
          auditor: 'Audited by Bursar Office',
          icon: Icons.check_circle_outline,
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildMilestoneCard({
    required String number,
    required String title,
    required String dueDate,
    required String amount,
    required String badgeText,
    bool isPaid = false,
    bool isActionRequired = false,
    String? alertText,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isActionRequired ? AppColors.gold : AppColors.border,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: isActionRequired ? AppColors.gold : AppColors.navyDeep,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isPaid ? Icons.check : Icons.lock_outline,
                  color: isActionRequired ? AppColors.navyDeep : AppColors.gold,
                  size: 14,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'MILESTONE $number • ${isPaid ? "CLEARANCE UNLOCKED" : "ACTION REQUIRED"}',
                      style: TextStyle(
                        color: isActionRequired ? AppColors.gold : AppColors.muted,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      title,
                      style: const TextStyle(
                        color: AppColors.onNavy,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      dueDate,
                      style: const TextStyle(color: AppColors.muted, fontSize: 10),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    amount,
                    style: const TextStyle(
                      color: AppColors.onNavy,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: isPaid
                          ? AppColors.successBackground.withValues(alpha: 0.2)
                          : AppColors.goldTint,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      badgeText,
                      style: TextStyle(
                        color: isPaid ? Colors.greenAccent : AppColors.gold,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          if (alertText != null) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.red.shade900.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: Colors.red.shade800),
              ),
              child: Row(
                children: [
                  Icon(Icons.warning_amber_rounded, size: 12, color: Colors.red.shade300),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      alertText,
                      style: TextStyle(color: Colors.red.shade200, fontSize: 10),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBankCard({
    required String bankName,
    required String accountNumber,
  }) {
    return Container(
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
              Expanded(
                child: Text(
                  bankName,
                  style: const TextStyle(
                    color: AppColors.onNavy,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              GestureDetector(
                onTap: () {
                  Clipboard.setData(ClipboardData(text: accountNumber));
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('$bankName account copied to clipboard'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                child: const Icon(Icons.copy, color: AppColors.gold, size: 14),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            accountNumber,
            style: const TextStyle(
              color: AppColors.muted,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAuditLogCard({
    required String ref,
    required String dateDesc,
    required String amount,
    required String status,
    required Color statusColor,
    String? note,
    String? auditor,
    required IconData icon,
  }) {
    return Container(
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
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: const BoxDecoration(
                  color: AppColors.navyDeep,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: AppColors.gold, size: 14),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      ref,
                      style: const TextStyle(
                        color: AppColors.onNavy,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      dateDesc,
                      style: const TextStyle(color: AppColors.muted, fontSize: 10),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    amount,
                    style: const TextStyle(
                      color: AppColors.onNavy,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      status,
                      style: TextStyle(
                        color: statusColor,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          if (note != null) ...[
            const Divider(color: AppColors.border, height: 16),
            Text(
              note,
              style: const TextStyle(
                color: AppColors.muted,
                fontSize: 10,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
          if (auditor != null) ...[
            const Divider(color: AppColors.border, height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.verified, color: AppColors.gold, size: 12),
                    const SizedBox(width: 4),
                    Text(
                      auditor,
                      style: const TextStyle(color: AppColors.muted, fontSize: 10),
                    ),
                  ],
                ),
                const Row(
                  children: [
                    Text(
                      'Proof',
                      style: TextStyle(color: AppColors.gold, fontSize: 10),
                    ),
                    SizedBox(width: 2),
                    Icon(Icons.open_in_new, color: AppColors.gold, size: 11),
                  ],
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // TAB 4: RESULTS / GRADE SHEET (Matching Images 2 & 3)
  // ---------------------------------------------------------------------------

  Widget _buildStudentResultsTab(DashboardData data) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      children: [
        // Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ACADEMIC RECORD',
                  style: TextStyle(
                    color: AppColors.gold,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.6,
                  ),
                ),
                SizedBox(height: 2),
                Row(
                  children: [
                    Text(
                      'Grade Sheet',
                      style: TextStyle(
                        color: AppColors.onNavy,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(width: 4),
                    Icon(Icons.verified, color: AppColors.gold, size: 16),
                  ],
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.border),
              ),
              child: const Row(
                children: [
                  Icon(Icons.calendar_today_outlined, size: 12, color: AppColors.gold),
                  SizedBox(width: 6),
                  Text(
                    '2025/26 - S2',
                    style: TextStyle(
                      color: AppColors.onNavy,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(width: 4),
                  Icon(Icons.keyboard_arrow_down, size: 14, color: AppColors.muted),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Status Card
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.successBackground.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.check, color: Colors.green.shade400, size: 14),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Approved & Published',
                      style: TextStyle(
                        color: Colors.greenAccent,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Certified by Super Admin Registry',
                      style: TextStyle(color: AppColors.muted, fontSize: 10),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.navyDeep,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'SEALED',
                  style: TextStyle(
                    color: AppColors.gold,
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // 2x2 Metric Grid
        Row(
          children: [
            Expanded(
              child: _buildResultMetricTile(
                title: 'SEMESTER GPA',
                badgeText: 'GRADE A',
                value: '3.82',
                denom: ' / 4.00',
                subText: '📈 +0.07 vs Prev Sem',
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildResultMetricTile(
                title: 'CUMULATIVE CGPA',
                icon: Icons.military_tech_outlined,
                value: '3.75',
                denom: ' / 4.00',
                subText: '1st Class Honours',
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _buildResultMetricTile(
                title: 'EARNED CREDITS',
                icon: Icons.verified_outlined,
                value: '21',
                denom: ' / 21 S2 Units',
                hasProgressBar: true,
                progress: 1.0,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildResultMetricTile(
                title: 'RESIT STATUS',
                icon: Icons.check_circle_outline,
                value: '0 Pending',
                subText: '1 Cleared Audit',
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),

        // Download Result Slip PDF
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.gold,
            foregroundColor: AppColors.navyDeep,
            padding: const EdgeInsets.symmetric(vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          onPressed: () {
            _showResultsPdfModal(context, data);
          },
          icon: const Icon(Icons.picture_as_pdf, size: 18),
          label: const Text(
            'Download Official Result Slip (PDF)',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          ),
        ),
        const SizedBox(height: 8),

        const Center(
          child: Text(
            'SCALE STANDARD:  CA: 30% • Final Exam: 70%',
            style: TextStyle(
              color: AppColors.muted,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 18),

        // Course Performance Breakdown
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Course Performance Breakdown',
              style: TextStyle(
                color: AppColors.onNavy,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              '4 Enrolled Units',
              style: TextStyle(color: AppColors.muted, fontSize: 11),
            ),
          ],
        ),
        const SizedBox(height: 10),

        _buildPerformanceCard(
          code: 'SW102',
          credits: '4 CREDITS',
          title: 'Object-Oriented Programming (Java)',
          grade: 'A',
          gp: 'GP 4.00',
          ca: '26.5',
          exam: '61.0',
          total: '87.5%',
          tag: 'Passed with Distinction',
        ),
        const SizedBox(height: 10),

        _buildPerformanceCard(
          code: 'SW104',
          credits: '3 CREDITS',
          title: 'Computer Architecture & Assembly',
          grade: 'B+',
          gp: 'GP 3.50',
          ca: '22.0',
          exam: '52.0',
          total: '74.0%',
          tag: 'Passed',
        ),
        const SizedBox(height: 10),

        _buildPerformanceCard(
          code: 'MA102',
          credits: '3 CREDITS',
          title: 'Discrete Mathematics for Computing',
          grade: 'A-',
          gp: 'GP 3.75',
          ca: '25.0',
          exam: '58.5',
          total: '83.5%',
          tag: 'Passed',
        ),
        const SizedBox(height: 10),

        // Unit 4 (Resit history)
        Container(
          padding: const EdgeInsets.all(14),
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
                  const Row(
                    children: [
                      CircleAvatar(
                        radius: 14,
                        backgroundColor: AppColors.navyDeep,
                        child: Text(
                          'SW',
                          style: TextStyle(color: AppColors.gold, fontSize: 10),
                        ),
                      ),
                      SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                'SW106 • 3 CREDITS',
                                style: TextStyle(color: AppColors.gold, fontSize: 10),
                              ),
                              SizedBox(width: 4),
                              Icon(Icons.sync, color: AppColors.muted, size: 12),
                            ],
                          ),
                          Text(
                            'Operating Systems Fundamentals',
                            style: TextStyle(
                              color: AppColors.onNavy,
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceRaised,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Column(
                      children: [
                        Text(
                          'B',
                          style: TextStyle(
                            color: AppColors.onNavy,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'GP 3.00',
                          style: TextStyle(color: AppColors.muted, fontSize: 9),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Attempt 1
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.navyDeep,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceRaised,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        '1',
                        style: TextStyle(color: AppColors.muted, fontSize: 9),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Main Exam (June 2026)',
                            style: TextStyle(color: AppColors.onNavy, fontSize: 10),
                          ),
                          Text(
                            'CA: 18.0 • Exam: 24.0 (42.0%)',
                            style: TextStyle(color: AppColors.muted, fontSize: 9),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.red.shade900.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'Grade F (Resit)',
                        style: TextStyle(
                          color: Colors.red.shade300,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 6),
              // Attempt 2
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.navyDeep,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.gold,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        '2',
                        style: TextStyle(
                          color: AppColors.navyDeep,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Resit Session (Sep 2026)',
                            style: TextStyle(color: AppColors.onNavy, fontSize: 10),
                          ),
                          Text(
                            'CA Retained: 18.0 • Resit Exam: 54.0',
                            style: TextStyle(color: AppColors.muted, fontSize: 9),
                          ),
                        ],
                      ),
                    ),
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '72.0%',
                          style: TextStyle(
                            color: AppColors.onNavy,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Grade B',
                          style: TextStyle(color: AppColors.gold, fontSize: 9),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.successBackground.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.green.shade600),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.refresh, size: 11, color: Colors.green.shade400),
                        const SizedBox(width: 4),
                        Text(
                          'Cleared via Supplementary Exam',
                          style: TextStyle(
                            color: Colors.green.shade300,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Text(
                    'Attempt 1 preserved',
                    style: TextStyle(
                      color: AppColors.muted,
                      fontSize: 9,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Results Policy & Clearance Card
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.shield_outlined, color: AppColors.gold, size: 16),
                  SizedBox(width: 8),
                  Text(
                    'RESULTS POLICY & CLEARANCE',
                    style: TextStyle(
                      color: AppColors.gold,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                'All financial milestones and tuition fee obligations for Semester 2 were completely verified by the Bursary Department on June 20, 2026. This official record has been encrypted, digitally countersigned by the Registrar, and constitutes a legally valid Fah Academy academic statement.',
                style: TextStyle(color: AppColors.muted, fontSize: 10, height: 1.4),
              ),
              const Divider(color: AppColors.border, height: 20),
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Reference: FAH-2026-S2-77491-REG',
                    style: TextStyle(color: AppColors.muted, fontSize: 9),
                  ),
                  Row(
                    children: [
                      Icon(Icons.circle, color: Colors.greenAccent, size: 6),
                      SizedBox(width: 4),
                      Text(
                        'Status: Unconditional Release',
                        style: TextStyle(
                          color: Colors.greenAccent,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildResultMetricTile({
    required String title,
    String? badgeText,
    IconData? icon,
    required String value,
    String? denom,
    String? subText,
    bool hasProgressBar = false,
    double progress = 0.0,
  }) {
    return Container(
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
              Text(
                title,
                style: const TextStyle(color: AppColors.muted, fontSize: 9),
              ),
              if (badgeText != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                  decoration: BoxDecoration(
                    color: AppColors.gold,
                    borderRadius: BorderRadius.circular(3),
                  ),
                  child: Text(
                    badgeText,
                    style: const TextStyle(
                      color: AppColors.navyDeep,
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              if (icon != null)
                Icon(icon, color: AppColors.gold, size: 14),
            ],
          ),
          const SizedBox(height: 4),
          RichText(
            text: TextSpan(
              text: value,
              style: const TextStyle(
                color: AppColors.gold,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
              children: [
                if (denom != null)
                  TextSpan(
                    text: denom,
                    style: const TextStyle(
                      color: AppColors.muted,
                      fontSize: 11,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
              ],
            ),
          ),
          if (hasProgressBar) ...[
            const SizedBox(height: 4),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: AppColors.navyDeep,
                valueColor: const AlwaysStoppedAnimation(AppColors.gold),
                minHeight: 4,
              ),
            ),
          ],
          if (subText != null) ...[
            const SizedBox(height: 4),
            Text(
              subText,
              style: const TextStyle(color: AppColors.muted, fontSize: 9),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPerformanceCard({
    required String code,
    required String credits,
    required String title,
    required String grade,
    required String gp,
    required String ca,
    required String exam,
    required String total,
    required String tag,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
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
              Row(
                children: [
                  CircleAvatar(
                    radius: 14,
                    backgroundColor: AppColors.navyDeep,
                    child: Text(
                      code.substring(0, 2),
                      style: const TextStyle(color: AppColors.gold, fontSize: 10),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$code • $credits',
                        style: const TextStyle(color: AppColors.gold, fontSize: 10),
                      ),
                      Text(
                        title,
                        style: const TextStyle(
                          color: AppColors.onNavy,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.gold,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    Text(
                      grade,
                      style: const TextStyle(
                        color: AppColors.navyDeep,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      gp,
                      style: const TextStyle(
                        color: AppColors.navyDeep,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.navyDeep,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    const Text('CA (30)', style: TextStyle(color: AppColors.muted, fontSize: 9)),
                    const SizedBox(height: 2),
                    Text(
                      ca,
                      style: const TextStyle(
                        color: AppColors.onNavy,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Container(width: 1, height: 24, color: AppColors.border),
                Column(
                  children: [
                    const Text('EXAM (70)', style: TextStyle(color: AppColors.muted, fontSize: 9)),
                    const SizedBox(height: 2),
                    Text(
                      exam,
                      style: const TextStyle(
                        color: AppColors.onNavy,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Container(width: 1, height: 24, color: AppColors.border),
                Column(
                  children: [
                    const Text('TOTAL MARK', style: TextStyle(color: AppColors.muted, fontSize: 9)),
                    const SizedBox(height: 2),
                    Text(
                      total,
                      style: const TextStyle(
                        color: AppColors.gold,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.successBackground.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.green.shade600),
                ),
                child: Row(
                  children: [
                    Icon(Icons.check, size: 11, color: Colors.green.shade400),
                    const SizedBox(width: 4),
                    Text(
                      tag,
                      style: TextStyle(
                        color: Colors.green.shade300,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const Row(
                children: [
                  Text(
                    'View Assessment Details',
                    style: TextStyle(color: AppColors.gold, fontSize: 10),
                  ),
                  SizedBox(width: 2),
                  Icon(Icons.chevron_right, color: AppColors.gold, size: 13),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showTimetableModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.navyDeep,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Week 08 Timetable',
                  style: TextStyle(
                    color: AppColors.onNavy,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: AppColors.muted),
                  onPressed: () => Navigator.pop(ctx),
                ),
              ],
            ),
            const SizedBox(height: 10),
            const Text(
              'Monday: SW201 (10:00 - 12:00) • Hall B-104\n'
              'Monday: SW203 (14:00 - 16:00) • Lab 3\n'
              'Wednesday: SW205 (08:00 - 10:00) • Hall A-201\n'
              'Thursday: SW207 (10:00 - 12:00) • Lab 1\n'
              'Friday: SW211 (14:00 - 16:00) • Room 108',
              style: TextStyle(color: AppColors.muted, height: 1.5),
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.gold,
                  foregroundColor: AppColors.navyDeep,
                  padding: const EdgeInsets.symmetric(vertical: 11),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: () {
                  Navigator.pop(ctx);
                  _showTimetablePdfModal(context);
                },
                icon: const Icon(Icons.download, size: 18),
                label: const Text('Download Timetable (Official PDF)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              ),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // FACULTY / LECTURER 4-TAB PORTAL SCAFFOLD (Matching Uploaded Screenshots)
  // ---------------------------------------------------------------------------

  Widget _buildFacultyPortalScaffold(DashboardData data) {
    const tabSectionNames = [
      'FACULTY DASHBOARD',
      'TEACHING MODULES',
      'ATTENDANCE REGISTER',
      'GRADE ENTRY (CA & EXAM)'
    ];
    final currentSection = tabSectionNames[_facultyTabIndex];
    final isDesktop = MediaQuery.sizeOf(context).width >= 850;

    if (isDesktop) {
      return Scaffold(
        backgroundColor: AppColors.navy,
        body: Row(
          children: [
            _buildDesktopSidebar(
              role: DashboardRole.teacher,
              data: data,
              selectedIndex: _facultyTabIndex,
              onSelect: (idx) => setState(() => _facultyTabIndex = idx),
            ),
            Expanded(
              child: Column(
                children: [
                  _buildDesktopTopBar(
                    data: data,
                    sectionName: currentSection,
                    roleLabel: 'Senior Lecturer • Faculty of Computing',
                  ),
                  Expanded(
                    child: Center(
                      child: Container(
                        constraints: const BoxConstraints(maxWidth: 1150),
                        child: IndexedStack(
                          index: _facultyTabIndex,
                          children: [
                            _buildFacultyHomeTab(data),
                            _buildFacultyCoursesTab(data),
                            _buildFacultyAttendanceTab(data),
                            _buildFacultyGradesTab(data),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.navy,
      drawer: _buildMobileDrawer(
        role: DashboardRole.teacher,
        data: data,
        selectedIndex: _facultyTabIndex,
        onSelect: (idx) {
          Navigator.pop(context);
          setState(() => _facultyTabIndex = idx);
        },
      ),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(64),
        child: _buildFacultyTopBar(data, currentSection),
      ),
      body: SafeArea(
        child: IndexedStack(
          index: _facultyTabIndex,
          children: [
            _buildFacultyHomeTab(data),
            _buildFacultyCoursesTab(data),
            _buildFacultyAttendanceTab(data),
            _buildFacultyGradesTab(data),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AppColors.navyDeep,
          border: Border(top: BorderSide(color: AppColors.border, width: 0.8)),
        ),
        child: BottomNavigationBar(
          backgroundColor: AppColors.navyDeep,
          selectedItemColor: AppColors.gold,
          unselectedItemColor: AppColors.muted,
          currentIndex: _facultyTabIndex,
          type: BottomNavigationBarType.fixed,
          selectedFontSize: 11,
          unselectedFontSize: 11,
          elevation: 0,
          onTap: (index) => setState(() => _facultyTabIndex = index),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.grid_view_rounded),
              activeIcon: Icon(Icons.grid_view_rounded),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.menu_book_outlined),
              activeIcon: Icon(Icons.menu_book),
              label: 'Courses',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.fact_check_outlined),
              activeIcon: Icon(Icons.fact_check),
              label: 'Attendance',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.trending_up_rounded),
              activeIcon: Icon(Icons.trending_up_rounded),
              label: 'Grades',
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // FACULTY TOP BAR
  // ---------------------------------------------------------------------------

  Widget _buildFacultyTopBar(DashboardData data, String currentSection) {
    final facultyName = data.displayName.isNotEmpty && data.displayName != 'User'
        ? data.displayName
        : 'Dr. Raymond Vance';
    final facultyId = data.userId.isNotEmpty && data.userId != 'LC-2026-001'
        ? data.userId
        : 'FAH/FAC/014';

    return Container(
      color: AppColors.navyDeep,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            Builder(
              builder: (ctx) => IconButton(
                icon: const Icon(Icons.menu_rounded, color: AppColors.onNavy, size: 24),
                tooltip: 'Navigation Menu',
                onPressed: () => Scaffold.of(ctx).openDrawer(),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
              ),
            ),
            const SizedBox(width: 6),
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.gold.withValues(alpha: 0.5),
                  width: 1.5,
                ),
              ),
              child: ClipOval(
                child: Image.asset(
                  'assets/images/logo.png',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => const Icon(
                    Icons.school,
                    color: AppColors.gold,
                    size: 20,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      const Text(
                        'FAH ACADEMY',
                        style: TextStyle(
                          color: AppColors.onNavy,
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.4,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                        decoration: BoxDecoration(
                          color: AppColors.gold.withValues(alpha: 0.18),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                            color: AppColors.gold.withValues(alpha: 0.5),
                            width: 0.8,
                          ),
                        ),
                        child: const Text(
                          'FACULTY',
                          style: TextStyle(
                            color: AppColors.gold,
                            fontSize: 8.5,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 1),
                  const Text(
                    '2026/2027 • S1 • STAFF PORTAL',
                    style: TextStyle(
                      color: AppColors.muted,
                      fontSize: 9.5,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
            ),
            Stack(
              clipBehavior: Clip.none,
              children: [
                IconButton(
                  icon: const Icon(
                    Icons.notifications_none_rounded,
                    color: AppColors.onNavy,
                    size: 22,
                  ),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Faculty Notice: Continuous assessment deadline approaching for SWE201.'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                ),
                Positioned(
                  top: 6,
                  right: 6,
                  child: Container(
                    width: 7,
                    height: 7,
                    decoration: const BoxDecoration(
                      color: Color(0xFFF97316),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 8),
            PopupMenuButton<String>(
              tooltip: 'Faculty Profile & Regulations',
              color: AppColors.surface,
              onSelected: (val) {
                if (val == 'signout') {
                  _handleSignOut();
                } else if (val == 'handbook') {
                  _showAcademicRegulationsModal(context);
                } else if (val == 'settings') {
                  _showSettingsModal(context, data);
                }
              },
              itemBuilder: (ctx) => [
                PopupMenuItem(
                  enabled: false,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        facultyName,
                        style: const TextStyle(
                          color: AppColors.onNavy,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Matricule: $facultyId',
                        style: const TextStyle(
                          color: AppColors.gold,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'Dept. of Software Engineering & ICT',
                        style: TextStyle(
                          color: AppColors.muted,
                          fontSize: 10.5,
                        ),
                      ),
                    ],
                  ),
                ),
                const PopupMenuDivider(),
                const PopupMenuItem(
                  value: 'settings',
                  child: Row(
                    children: [
                      Icon(Icons.settings_outlined, color: AppColors.gold, size: 18),
                      SizedBox(width: 8),
                      Text('Settings & Preferences', style: TextStyle(color: AppColors.onNavy, fontSize: 13)),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'handbook',
                  child: Row(
                    children: [
                      Icon(Icons.menu_book_outlined, color: AppColors.gold, size: 18),
                      SizedBox(width: 8),
                      Text('Senate Grading Norms', style: TextStyle(color: AppColors.onNavy, fontSize: 13)),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'signout',
                  child: Row(
                    children: [
                      Icon(Icons.logout, color: Color(0xFFF87171), size: 18),
                      SizedBox(width: 8),
                      Text('Sign out', style: TextStyle(color: Color(0xFFF87171), fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ],
              child: CircleAvatar(
                radius: 17,
                backgroundColor: AppColors.surfaceRaised,
                child: Text(
                  facultyName.isNotEmpty ? facultyName[0].toUpperCase() : 'L',
                  style: const TextStyle(
                    color: AppColors.gold,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // TAB 0: FACULTY HOME (Matching Screenshot 1)
  // ---------------------------------------------------------------------------

  Widget _buildFacultyHomeTab(DashboardData data) {
    final facultyName = data.displayName.isNotEmpty && data.displayName != 'User'
        ? data.displayName
        : 'Dr. Raymond Vance';
    final facultyId = data.userId.isNotEmpty && data.userId != 'LC-2026-001'
        ? data.userId
        : 'FAH-FAC-014';

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 80),
      children: [
        // 1. Welcome Card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF13204D),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border.withValues(alpha: 0.7)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 7,
                    height: 7,
                    decoration: const BoxDecoration(
                      color: AppColors.gold,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Text(
                    'FACULTY • SENIOR LECTURER',
                    style: TextStyle(
                      color: AppColors.gold,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.6,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Welcome back,',
                          style: TextStyle(
                            color: AppColors.onNavy,
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          facultyName,
                          style: const TextStyle(
                            color: AppColors.gold,
                            fontSize: 21,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.3,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Dept. of Computer Science & Software Engineering',
                          style: TextStyle(
                            color: AppColors.muted,
                            fontSize: 11,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
                              decoration: BoxDecoration(
                                color: const Color(0xFF0C1536),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: AppColors.border.withValues(alpha: 0.6)),
                              ),
                              child: Text(
                                facultyId,
                                style: const TextStyle(
                                  color: AppColors.onNavy,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
                              decoration: BoxDecoration(
                                color: const Color(0xFF0C1536),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: AppColors.border.withValues(alpha: 0.6)),
                              ),
                              child: const Text(
                                '2026/2027 S1',
                                style: TextStyle(
                                  color: AppColors.gold,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 54,
                    height: 54,
                    decoration: BoxDecoration(
                      color: const Color(0xFF0C1536),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.gold.withValues(alpha: 0.5), width: 1.5),
                    ),
                    child: const ClipRRect(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      child: Center(
                        child: Icon(
                          Icons.person_pin,
                          color: AppColors.gold,
                          size: 34,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // 3 Mini stat cards
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0B1433),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
                      ),
                      child: const Column(
                        children: [
                          Text(
                            '4',
                            style: TextStyle(
                              color: AppColors.gold,
                              fontSize: 19,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Assigned\nCourses',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: AppColors.muted, fontSize: 10, height: 1.2),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0B1433),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
                      ),
                      child: const Column(
                        children: [
                          Text(
                            '2',
                            style: TextStyle(
                              color: AppColors.gold,
                              fontSize: 19,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Classes\nToday',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: AppColors.muted, fontSize: 10, height: 1.2),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0B1433),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
                      ),
                      child: const Column(
                        children: [
                          Text(
                            '1',
                            style: TextStyle(
                              color: AppColors.gold,
                              fontSize: 19,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Grade\nReview',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: AppColors.muted, fontSize: 10, height: 1.2),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // 2. OPERATIONS SUMMARY
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'OPERATIONS SUMMARY',
              style: TextStyle(
                color: AppColors.onNavy,
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.8,
              ),
            ),
            Row(
              children: [
                const Text(
                  'Live Sync',
                  style: TextStyle(
                    color: AppColors.gold,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 3),
                Icon(Icons.bolt, color: AppColors.gold, size: 14),
              ],
            ),
          ],
        ),
        const SizedBox(height: 10),

        // 2x2 Operations Summary Grid
        Row(
          children: [
            Expanded(
              child: _buildOperationCard(
                title: 'Active Students',
                icon: Icons.groups_outlined,
                mainValue: '142',
                subText: 'Enrolled Scholars',
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildOperationCard(
                title: "Today's Classes",
                icon: Icons.access_time_rounded,
                mainValue: '2',
                subText: '4 Contact Hours',
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _buildOperationCard(
                title: 'Attendance Rate',
                icon: Icons.fact_check_outlined,
                mainValue: '94.2%',
                subText: '↗ +1.8% vs last wk',
                isSuccessTrend: true,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildOperationCard(
                title: 'Submissions',
                icon: null,
                tag: 'Due',
                mainValue: '1 Due',
                subText: '4 days remaining',
              ),
            ),
          ],
        ),

        const SizedBox(height: 20),

        // 3. ACTION REQUIRED Card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF13204D),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: AppColors.gold.withValues(alpha: 0.7),
              width: 1.2,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: AppColors.gold,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.warning_amber_rounded,
                        color: AppColors.navyDeep,
                        size: 20,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'ACTION REQUIRED',
                              style: TextStyle(
                                color: AppColors.gold,
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.5,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFF0C1536),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: AppColors.border.withValues(alpha: 0.6)),
                              ),
                              child: const Text(
                                'Deadline: Oct 24',
                                style: TextStyle(
                                  color: AppColors.muted,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'SW101 • Intro to Programming (...)',
                          style: TextStyle(
                            color: AppColors.onNavy,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                'CA (30%) & Exam (70%) marks ready for Faculty Board review. 42 entered, 2 draft marks unverified.',
                style: TextStyle(
                  color: AppColors.muted,
                  fontSize: 11.5,
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => setState(() => _facultyTabIndex = 3),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.gold,
                    foregroundColor: AppColors.navyDeep,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Resume Grade Entry',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                      SizedBox(width: 6),
                      Icon(Icons.arrow_forward, size: 16),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // 4. FACULTY SHORTCUTS
        const Text(
          'FACULTY SHORTCUTS',
          style: TextStyle(
            color: AppColors.onNavy,
            fontSize: 12,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _buildFacultyShortcutTile(
                icon: Icons.tune,
                title: 'Mark Attend...',
                subtitle: 'Fast check-in',
                onTap: () => setState(() => _facultyTabIndex = 2),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildFacultyShortcutTile(
                icon: Icons.edit_note_rounded,
                title: 'Grades •',
                subtitle: 'SW101 Open',
                hasDot: true,
                onTap: () => setState(() => _facultyTabIndex = 3),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _buildFacultyShortcutTile(
                icon: Icons.calendar_view_week_rounded,
                title: 'Timetable',
                subtitle: 'Week 7 Schedule',
                onTap: () => _showFacultyTimetableModal(context),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildFacultyShortcutTile(
                icon: Icons.badge_outlined,
                title: 'Class Rosters',
                subtitle: '4 Cohorts',
                onTap: () => _showFacultyRosterModal(context, 'Class Rosters — 4 Cohorts'),
              ),
            ),
          ],
        ),

        const SizedBox(height: 20),

        // 5. TODAY'S SCHEDULE
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Text(
                  "TODAY'S SCHEDULE",
                  style: TextStyle(
                    color: AppColors.onNavy,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(width: 5),
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: AppColors.gold,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),
            const Text(
              'Tuesday, Oct 20',
              style: TextStyle(color: AppColors.muted, fontSize: 11),
            ),
          ],
        ),
        const SizedBox(height: 10),

        // Schedule Item 1 (Highlighted/Active)
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFF13204D),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.gold, width: 1.3),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.gold,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'IN 30 MINS',
                          style: TextStyle(
                            color: AppColors.navyDeep,
                            fontSize: 9.5,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        '10:00 AM – 12:00 PM',
                        style: TextStyle(
                          color: AppColors.onNavy,
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const Icon(Icons.sensors, color: AppColors.gold, size: 18),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                'SW201 • Advanced Data Structures',
                style: TextStyle(
                  color: AppColors.onNavy,
                  fontSize: 14.5,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              const Row(
                children: [
                  Icon(Icons.location_on_outlined, color: AppColors.gold, size: 13),
                  SizedBox(width: 4),
                  Text('Hall B-104 (Campus A)', style: TextStyle(color: AppColors.muted, fontSize: 11)),
                  Text('  •  ', style: TextStyle(color: AppColors.muted)),
                  Icon(Icons.school_outlined, color: AppColors.gold, size: 13),
                  SizedBox(width: 4),
                  Text('SEL200 (Cohort A) • 38', style: TextStyle(color: AppColors.muted, fontSize: 11)),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => setState(() => _facultyTabIndex = 2),
                      icon: const Icon(Icons.checklist, size: 15),
                      label: const Text('Take Attendance', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.gold,
                        foregroundColor: AppColors.navyDeep,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _showFacultyRosterModal(context, 'SW201 Roster (SEL200)'),
                      icon: const Icon(Icons.people_outline, size: 15, color: AppColors.onNavy),
                      label: const Text('View Roster', style: TextStyle(color: AppColors.onNavy, fontSize: 11.5)),
                      style: OutlinedButton.styleFrom(
                        backgroundColor: const Color(0xFF0C1536),
                        side: BorderSide(color: AppColors.border.withValues(alpha: 0.6)),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 10),

        // Schedule Item 2 (Upcoming)
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFF13204D),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border.withValues(alpha: 0.6)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E2D5E),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'Upcoming',
                          style: TextStyle(
                            color: AppColors.muted,
                            fontSize: 9.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        '02:00 PM – 04:00 PM',
                        style: TextStyle(
                          color: AppColors.onNavy,
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const Icon(Icons.slideshow_outlined, color: AppColors.muted, size: 18),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                'SW101 • Intro to Programming Lab',
                style: TextStyle(
                  color: AppColors.onNavy,
                  fontSize: 14.5,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              const Row(
                children: [
                  Icon(Icons.laptop_chromebook, color: AppColors.gold, size: 13),
                  SizedBox(width: 4),
                  Text('Lab 3 (Engineering Block)', style: TextStyle(color: AppColors.muted, fontSize: 11)),
                  Text('  •  ', style: TextStyle(color: AppColors.muted)),
                  Icon(Icons.school_outlined, color: AppColors.gold, size: 13),
                  SizedBox(width: 4),
                  Text('CS L100 • 42 Students', style: TextStyle(color: AppColors.muted, fontSize: 11)),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => setState(() => _facultyTabIndex = 2),
                      icon: const Icon(Icons.checklist, size: 15, color: AppColors.onNavy),
                      label: const Text('Take Attendance', style: TextStyle(color: AppColors.onNavy, fontSize: 11.5)),
                      style: OutlinedButton.styleFrom(
                        backgroundColor: const Color(0xFF0C1536),
                        side: BorderSide(color: AppColors.border.withValues(alpha: 0.6)),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Lab 3 Materials: Module 4 worksheets loaded.'),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                      icon: const Icon(Icons.folder_outlined, size: 15, color: AppColors.onNavy),
                      label: const Text('Lab Materials', style: TextStyle(color: AppColors.onNavy, fontSize: 11.5)),
                      style: OutlinedButton.styleFrom(
                        backgroundColor: const Color(0xFF0C1536),
                        side: BorderSide(color: AppColors.border.withValues(alpha: 0.6)),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // 6. FACULTY BULLETINS
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'FACULTY BULLETINS',
              style: TextStyle(
                color: AppColors.onNavy,
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.8,
              ),
            ),
            GestureDetector(
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('All 8 faculty bulletins loaded.'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              child: const Text(
                'View All',
                style: TextStyle(
                  color: AppColors.gold,
                  fontSize: 11.5,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),

        // Bulletin 1
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF13204D),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: const Color(0xFF0C1536),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.shield_outlined, color: AppColors.gold, size: 18),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Office of the Registrar', style: TextStyle(color: AppColors.muted, fontSize: 10)),
                        Text('2h ago', style: TextStyle(color: AppColors.muted, fontSize: 10)),
                      ],
                    ),
                    SizedBox(height: 3),
                    Text(
                      'Semester 1 Exam Script Archival Policy',
                      style: TextStyle(color: AppColors.onNavy, fontSize: 12.5, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Physical and digital moderation sheets must be..',
                      style: TextStyle(color: AppColors.muted, fontSize: 11),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 8),

        // Bulletin 2
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF13204D),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: const Color(0xFF0C1536),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.account_balance_outlined, color: AppColors.gold, size: 18),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Department Chair', style: TextStyle(color: AppColors.muted, fontSize: 10)),
                        Text('Yesterday', style: TextStyle(color: AppColors.muted, fontSize: 10)),
                      ],
                    ),
                    SizedBox(height: 3),
                    Text(
                      'Mid-Term Continuous Assessment Mod...',
                      style: TextStyle(color: AppColors.onNavy, fontSize: 12.5, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Cross-grading sessions for computing units...',
                      style: TextStyle(color: AppColors.muted, fontSize: 11),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // TAB 3: FACULTY GRADES (Matching Screenshot 2)
  // ---------------------------------------------------------------------------

  Widget _buildFacultyGradesTab(DashboardData data) {
    // Generate list of 5 students based on Screenshot 2
    final divineExam = _customExamScores['FAH-2026-SV0390'];
    final divineHasExam = divineExam != null;
    final divineTotal = divineHasExam ? (18.0 + divineExam) : null;
    final divineGrade = divineHasExam ? (divineTotal! >= 80 ? 'A' : (divineTotal >= 70 ? 'B+' : 'C')) : null;
    final divinePoints = divineHasExam ? (divineTotal! >= 80 ? 4.00 : (divineTotal >= 70 ? 3.50 : 2.50)) : null;

    final List<_FacultyStudentGradeModel> allStudents = [
      const _FacultyStudentGradeModel(
        initials: 'BN',
        name: 'Brenda N. Tabi',
        matricule: 'FAH-2026-SV0482',
        status: 'PASSED',
        caScore: 24.5,
        examScore: 56.0,
        total: 80.5,
        grade: 'A',
        points: 4.00,
        trailingIcon: Icons.military_tech_outlined,
      ),
      const _FacultyStudentGradeModel(
        initials: 'EK',
        name: 'Emmanuel K. Che',
        matricule: 'FAH-2026-SV0419',
        status: 'PASSED',
        caScore: 21.0,
        examScore: 49.0,
        total: 70.0,
        grade: 'B+',
        points: 3.50,
        trailingIcon: Icons.thumb_up_alt_outlined,
      ),
      _FacultyStudentGradeModel(
        initials: 'DA',
        name: 'Divine F. Ayuk',
        matricule: 'FAH-2026-SV0390',
        status: divineHasExam ? 'PASSED' : 'INCOMPLETE',
        caScore: 18.0,
        examScore: divineExam,
        total: divineTotal,
        grade: divineGrade,
        points: divinePoints,
        warningMessage: divineHasExam ? null : 'Exam mark missing. Calculation suspended.',
        trailingAction: divineHasExam ? null : 'Action Needed',
        trailingIcon: divineHasExam ? Icons.thumb_up_alt_outlined : null,
      ),
      const _FacultyStudentGradeModel(
        initials: 'MN',
        name: 'Marcelle O. Ndong',
        matricule: 'FAH-2026-SV0532',
        status: 'RESIT REQUIRED',
        caScore: 12.0,
        examScore: 24.0,
        total: 36.0,
        grade: 'F',
        points: 0.00,
        trailingAction: 'SUB-THRESHOLD',
      ),
      const _FacultyStudentGradeModel(
        initials: 'BE',
        name: 'Boris T. Enow',
        matricule: 'FAH-2026-SV0441',
        status: 'DISTINCTION',
        caScore: 26.0,
        examScore: 59.5,
        total: 85.5,
        grade: 'A',
        points: 4.00,
        trailingIcon: Icons.emoji_events_outlined,
      ),
    ];

    // Filter by query and chips
    final filtered = allStudents.where((s) {
      if (_facultyGradesFilterIndex == 1) {
        // Missing CA
        if (s.caScore >= 15) return false;
      } else if (_facultyGradesFilterIndex == 2) {
        // Missing Exam
        if (s.examScore != null) return false;
      }

      if (_facultyGradesSearchQuery.trim().isNotEmpty) {
        final q = _facultyGradesSearchQuery.trim().toLowerCase();
        return s.name.toLowerCase().contains(q) || s.matricule.toLowerCase().contains(q);
      }
      return true;
    }).toList();

    return Stack(
      children: [
        ListView(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 120),
          children: [
            // 1. Assessment Header Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF13204D),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border.withValues(alpha: 0.7)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              color: AppColors.gold,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Text(
                            'STATUS: DRAFT (IN PROGRESS)',
                            style: TextStyle(
                              color: AppColors.gold,
                              fontSize: 9.5,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                      const Row(
                        children: [
                          Icon(Icons.edit_outlined, color: AppColors.muted, size: 13),
                          SizedBox(width: 4),
                          Text(
                            'Autosaved 14:32',
                            style: TextStyle(color: AppColors.muted, fontSize: 10.5),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'SW101 • Introduction to Programming',
                    style: TextStyle(
                      color: AppColors.onNavy,
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 3),
                  const Text(
                    'Semester 1 • Academic Year 2026/2027 • Software Eng L100',
                    style: TextStyle(color: AppColors.muted, fontSize: 11),
                  ),
                  const SizedBox(height: 14),

                  // Breakdown Info Container
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0C1536),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.hourglass_top, color: AppColors.gold, size: 14),
                            SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                'CA: 30% (Max 30) | Exam: 70% (Max 70)',
                                style: TextStyle(
                                  color: AppColors.onNavy,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            Text(
                              'Scale: 4.0 GP',
                              style: TextStyle(
                                color: AppColors.gold,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 5),
                        const Text(
                          'Formula: Total = CA + Exam. Validated against senate grading policy.',
                          style: TextStyle(color: AppColors.muted, fontSize: 10),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Progress', style: TextStyle(color: AppColors.muted, fontSize: 10.5)),
                            Text(
                              divineHasExam ? '41 / 42 Graded (98%)' : '40 / 42 Graded (95%)',
                              style: const TextStyle(
                                color: AppColors.gold,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 5),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(3),
                          child: LinearProgressIndicator(
                            value: divineHasExam ? 0.98 : 0.95,
                            backgroundColor: const Color(0xFF1E2D5E),
                            valueColor: const AlwaysStoppedAnimation(AppColors.gold),
                            minHeight: 5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            // 2. Search Bar
            Container(
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFF13204D),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.border.withValues(alpha: 0.6)),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: [
                  const Icon(Icons.search, color: AppColors.muted, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      style: const TextStyle(color: AppColors.onNavy, fontSize: 12.5),
                      decoration: const InputDecoration(
                        hintText: 'Search student name or matricule...',
                        hintStyle: TextStyle(color: AppColors.muted, fontSize: 12),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                      onChanged: (val) => setState(() => _facultyGradesSearchQuery = val),
                    ),
                  ),
                  if (_facultyGradesSearchQuery.isNotEmpty)
                    GestureDetector(
                      onTap: () => setState(() => _facultyGradesSearchQuery = ''),
                      child: const Icon(Icons.close, color: AppColors.muted, size: 16),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // 3. Filter Chips
            Row(
              children: [
                _buildFacultyGradeFilterChip('All Students  42', 0),
                const SizedBox(width: 8),
                _buildFacultyGradeFilterChip('Missing CA  1', 1),
                const SizedBox(width: 8),
                _buildFacultyGradeFilterChip('Missing Exam  1', 2),
              ],
            ),

            const SizedBox(height: 14),

            // 4. Student Grade Cards
            ...filtered.map((student) => _buildFacultyStudentCard(student)),

            const SizedBox(height: 14),

            // 5. Institutional Workflow Note Card
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFF13204D),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
              ),
              child: const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.hub_outlined, color: AppColors.gold, size: 20),
                  SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Institutional Workflow Note',
                          style: TextStyle(
                            color: AppColors.onNavy,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Submitting transfers this grade sheet to the Faculty Head and Admin Examination Board for formal review. You can still save drafts before final dispatch.',
                          style: TextStyle(
                            color: AppColors.muted,
                            fontSize: 11,
                            height: 1.35,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),

        // Sticky Bottom Action Bar
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: Container(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
            decoration: BoxDecoration(
              color: const Color(0xFF0B1433),
              border: Border(top: BorderSide(color: AppColors.border.withValues(alpha: 0.8), width: 1)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.5),
                  blurRadius: 10,
                  offset: const Offset(0, -3),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: AppColors.gold,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      divineHasExam
                          ? '1 entry requires attention before Admin dispatch'
                          : '2 entries require attention before Admin dispatch',
                      style: const TextStyle(
                        color: AppColors.gold,
                        fontSize: 10.5,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _showGradeBroadsheetPdfModal(context, 'SWE201'),
                        icon: const Icon(Icons.picture_as_pdf, size: 14, color: AppColors.gold),
                        label: const Text('PDF Slip', style: TextStyle(color: AppColors.gold, fontSize: 11.5, fontWeight: FontWeight.bold)),
                        style: OutlinedButton.styleFrom(
                          backgroundColor: const Color(0xFF13204D),
                          side: const BorderSide(color: AppColors.gold),
                          padding: const EdgeInsets.symmetric(vertical: 11),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _showGradeValidationReport(context, divineHasExam),
                        icon: const Icon(Icons.tune, size: 14, color: AppColors.onNavy),
                        label: const Text('Validate', style: TextStyle(color: AppColors.onNavy, fontSize: 12)),
                        style: OutlinedButton.styleFrom(
                          backgroundColor: const Color(0xFF13204D),
                          side: BorderSide(color: AppColors.border.withValues(alpha: 0.6)),
                          padding: const EdgeInsets.symmetric(vertical: 11),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton.icon(
                        onPressed: () => _showGradeSubmissionModal(context),
                        icon: const Icon(Icons.arrow_forward, size: 14),
                        label: const Text('Submit →', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.gold,
                          foregroundColor: AppColors.navyDeep,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 11),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // TAB 1: FACULTY COURSES
  // ---------------------------------------------------------------------------

  Widget _buildFacultyCoursesTab(DashboardData data) {
    final courses = [
      {
        'code': 'SW101',
        'title': 'Introduction to Programming',
        'level': 'Software Eng L100',
        'students': 42,
        'contact': '4 Contact Hrs/Wk',
        'progress': 0.85,
        'syllabus': 'Week 8 of 12 (Control Structures & Arrays)',
      },
      {
        'code': 'SW201',
        'title': 'Advanced Data Structures',
        'level': 'Software Eng L200',
        'students': 38,
        'contact': '4 Contact Hrs/Wk',
        'progress': 0.65,
        'syllabus': 'Week 6 of 12 (Binary Trees & Hash Tables)',
      },
      {
        'code': 'SW305',
        'title': 'Software Architecture & Design',
        'level': 'Software Eng L300',
        'students': 29,
        'contact': '3 Contact Hrs/Wk',
        'progress': 0.70,
        'syllabus': 'Week 7 of 12 (Microservices & Event-Driven)',
      },
      {
        'code': 'CS102',
        'title': 'Discrete Mathematics for Computing',
        'level': 'CS L100',
        'students': 45,
        'contact': '3 Contact Hrs/Wk',
        'progress': 0.90,
        'syllabus': 'Week 9 of 12 (Graph Theory & Logic)',
      },
    ];

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 80),
      children: [
        const Text(
          'ASSIGNED TEACHING MODULES',
          style: TextStyle(
            color: AppColors.onNavy,
            fontSize: 12,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 10),
        ...courses.map(
          (c) => Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFF13204D),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border.withValues(alpha: 0.6)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                      decoration: BoxDecoration(
                        color: AppColors.gold.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(5),
                        border: Border.all(color: AppColors.gold.withValues(alpha: 0.5)),
                      ),
                      child: Text(
                        c['code'] as String,
                        style: const TextStyle(
                          color: AppColors.gold,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Text(
                      '${c['students']} Students Enrolled',
                      style: const TextStyle(color: AppColors.muted, fontSize: 11),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  c['title'] as String,
                  style: const TextStyle(
                    color: AppColors.onNavy,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${c['level']}  •  ${c['contact']}',
                  style: const TextStyle(color: AppColors.muted, fontSize: 11),
                ),
                const SizedBox(height: 10),
                Text(
                  'Syllabus Coverage: ${c['syllabus']}',
                  style: const TextStyle(color: AppColors.onNavy, fontSize: 10.5),
                ),
                const SizedBox(height: 5),
                ClipRRect(
                  borderRadius: BorderRadius.circular(3),
                  child: LinearProgressIndicator(
                    value: c['progress'] as double,
                    backgroundColor: const Color(0xFF0C1536),
                    valueColor: const AlwaysStoppedAnimation(AppColors.gold),
                    minHeight: 5,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => setState(() => _facultyTabIndex = 3),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.gold,
                          foregroundColor: AppColors.navyDeep,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 9),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: const Text('Enter Grades', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => setState(() => _facultyTabIndex = 2),
                        style: OutlinedButton.styleFrom(
                          backgroundColor: const Color(0xFF0C1536),
                          side: BorderSide(color: AppColors.border.withValues(alpha: 0.6)),
                          padding: const EdgeInsets.symmetric(vertical: 9),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: const Text('Attendance', style: TextStyle(color: AppColors.onNavy, fontSize: 11.5)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // TAB 2: FACULTY ATTENDANCE
  // ---------------------------------------------------------------------------

  Widget _buildFacultyAttendanceTab(DashboardData data) {
    final students = [
      {'name': 'Brenda N. Tabi', 'mat': 'FAH-2026-SV0482', 'default': 'present'},
      {'name': 'Emmanuel K. Che', 'mat': 'FAH-2026-SV0419', 'default': 'present'},
      {'name': 'Divine F. Ayuk', 'mat': 'FAH-2026-SV0390', 'default': 'late'},
      {'name': 'Marcelle O. Ndong', 'mat': 'FAH-2026-SV0532', 'default': 'absent'},
      {'name': 'Boris T. Enow', 'mat': 'FAH-2026-SV0441', 'default': 'present'},
    ];

    // Lecturer Course-Level Authorization Check:
    // Only designated lecturer (Dr. Raymond Vance) assigned to SWE201 / SWE101 can mark attendance!
    final isAssigned = _selectedAttendanceCourseCode == 'SWE201' || _selectedAttendanceCourseCode == 'SWE101';
    final courseInstructor = (_selectedAttendanceCourseCode == 'SWE201' || _selectedAttendanceCourseCode == 'SWE101')
        ? 'Dr. Raymond Vance (You)'
        : (_selectedAttendanceCourseCode == 'CEF205'
            ? 'Dr. Beatrice M. Ngu (Staff ID: FAH-FAC-008)'
            : 'Prof. Samuel E. Mbella (Staff ID: FAH-FAC-003)');

    final courseTitle = _selectedAttendanceCourseCode == 'SWE201'
        ? 'Advanced Data Structures'
        : (_selectedAttendanceCourseCode == 'SWE101'
            ? 'Intro to Programming & Algorithms'
            : (_selectedAttendanceCourseCode == 'CEF205'
                ? 'Digital Logic & Microprocessors'
                : 'Computer Networks & Protocols'));

    final courseVenue = _selectedAttendanceCourseCode == 'SWE201'
        ? 'Hall B-104 • Campus A'
        : (_selectedAttendanceCourseCode == 'SWE101'
            ? 'Amphithéâtre 2 • Campus B'
            : (_selectedAttendanceCourseCode == 'CEF205'
                ? 'Hall A-201 • Tech Block'
                : 'Lab 1 • Networking Center'));

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 80),
      children: [
        // Course Selector Header (Role Authorization Selector)
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF13204D),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'SELECT TEACHING MODULE',
                    style: TextStyle(
                      color: AppColors.gold,
                      fontSize: 10.5,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.6,
                    ),
                  ),
                  Text(
                    'Senate Authorization Rule',
                    style: TextStyle(color: AppColors.muted, fontSize: 10),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildAttendanceCourseChip('SWE201 (Assigned)', 'SWE201', true),
                    const SizedBox(width: 8),
                    _buildAttendanceCourseChip('SWE101 (Assigned)', 'SWE101', true),
                    const SizedBox(width: 8),
                    _buildAttendanceCourseChip('CEF205 (Dr. Ngu)', 'CEF205', false),
                    const SizedBox(width: 8),
                    _buildAttendanceCourseChip('ICT207 (Prof. Mbella)', 'ICT207', false),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),

        // Instructor Authorization Warning if not assigned to this course
        if (!isAssigned) ...[
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFF261517),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFF87171), width: 1.2),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.lock, color: Color(0xFFF87171), size: 22),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '🔒 READ-ONLY AUDIT MODE: ${_selectedAttendanceCourseCode.toUpperCase()}',
                        style: const TextStyle(
                          color: Color(0xFFF87171),
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        'You are NOT the assigned lecturer for this course. Under Cameroon MINESUP & Senate Regulations, only $courseInstructor is authorized to register and seal attendance.',
                        style: const TextStyle(color: AppColors.muted, fontSize: 11, height: 1.35),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
        ],

        // Live Check-in Session Header
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFF13204D),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isAssigned ? AppColors.gold : AppColors.border,
              width: isAssigned ? 1.2 : 1.0,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                    decoration: BoxDecoration(
                      color: isAssigned ? AppColors.gold : AppColors.surface,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      isAssigned ? 'ACTIVE SESSION • WRITE ACCESS' : 'AUDIT SESSION • LOCKED',
                      style: TextStyle(
                        color: isAssigned ? AppColors.navyDeep : AppColors.muted,
                        fontSize: 9.5,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  Text(courseVenue, style: const TextStyle(color: AppColors.muted, fontSize: 11)),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                '$_selectedAttendanceCourseCode • $courseTitle',
                style: const TextStyle(
                  color: AppColors.onNavy,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                'Instructor: $courseInstructor • 38 Students Enrolled',
                style: const TextStyle(color: AppColors.muted, fontSize: 11),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0C1536),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Column(
                        children: [
                          Text('35', style: TextStyle(color: Color(0xFF4ADE80), fontWeight: FontWeight.bold, fontSize: 16)),
                          Text('Present', style: TextStyle(color: AppColors.muted, fontSize: 9.5)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0C1536),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Column(
                        children: [
                          Text('2', style: TextStyle(color: AppColors.gold, fontWeight: FontWeight.bold, fontSize: 16)),
                          Text('Late', style: TextStyle(color: AppColors.muted, fontSize: 9.5)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0C1536),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Column(
                        children: [
                          Text('1', style: TextStyle(color: Color(0xFFF87171), fontWeight: FontWeight.bold, fontSize: 16)),
                          Text('Absent', style: TextStyle(color: AppColors.muted, fontSize: 9.5)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'ROSTER FAST CHECK-IN',
              style: TextStyle(
                color: AppColors.onNavy,
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.8,
              ),
            ),
            GestureDetector(
              onTap: () {
                if (!isAssigned) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('🔒 Access Denied: Only $courseInstructor can mark attendance for $_selectedAttendanceCourseCode.'),
                      backgroundColor: const Color(0xFF261517),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                  return;
                }
                setState(() {
                  for (final s in students) {
                    _attendanceMap[s['mat'] as String] = 'present';
                  }
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('All students marked Present for active session.'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              child: Text(
                'Mark All Present',
                style: TextStyle(
                  color: isAssigned ? AppColors.gold : AppColors.muted,
                  fontSize: 11.5,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 10),

        ...students.map((st) {
          final mat = st['mat'] as String;
          final status = _attendanceMap[mat] ?? st['default'] as String;

          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF13204D),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        st['name'] as String,
                        style: const TextStyle(
                          color: AppColors.onNavy,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        mat,
                        style: const TextStyle(color: AppColors.muted, fontSize: 10.5),
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    _buildAttendanceToggleButton(
                      label: 'P',
                      isActive: status == 'present',
                      activeColor: const Color(0xFF4ADE80),
                      onTap: () {
                        if (!isAssigned) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('🔒 Unauthorized: Only $courseInstructor can modify $_selectedAttendanceCourseCode attendance.'),
                              backgroundColor: const Color(0xFF261517),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                          return;
                        }
                        setState(() => _attendanceMap[mat] = 'present');
                      },
                    ),
                    const SizedBox(width: 4),
                    _buildAttendanceToggleButton(
                      label: 'L',
                      isActive: status == 'late',
                      activeColor: AppColors.gold,
                      onTap: () {
                        if (!isAssigned) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('🔒 Unauthorized: Only $courseInstructor can modify $_selectedAttendanceCourseCode attendance.'),
                              backgroundColor: const Color(0xFF261517),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                          return;
                        }
                        setState(() => _attendanceMap[mat] = 'late');
                      },
                    ),
                    const SizedBox(width: 4),
                    _buildAttendanceToggleButton(
                      label: 'A',
                      isActive: status == 'absent',
                      activeColor: const Color(0xFFF87171),
                      onTap: () {
                        if (!isAssigned) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('🔒 Unauthorized: Only $courseInstructor can modify $_selectedAttendanceCourseCode attendance.'),
                              backgroundColor: const Color(0xFF261517),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                          return;
                        }
                        setState(() => _attendanceMap[mat] = 'absent');
                      },
                    ),
                  ],
                ),
              ],
            ),
          );
        }),

        const SizedBox(height: 12),

        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: isAssigned
                ? () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('✓ Attendance successfully synchronized for $_selectedAttendanceCourseCode.'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                : () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('🔒 Action Restricted: Only assigned instructor $courseInstructor can submit attendance.'),
                        backgroundColor: const Color(0xFF261517),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor: isAssigned ? AppColors.gold : AppColors.surface,
              foregroundColor: isAssigned ? AppColors.navyDeep : AppColors.muted,
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: Text(
              isAssigned ? 'Save & Synchronize Attendance' : '🔒 Read-Only (Restricted to $courseInstructor)',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: isAssigned ? 13 : 11.5),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAttendanceCourseChip(String label, String code, bool isAssigned) {
    final selected = _selectedAttendanceCourseCode == code;
    return GestureDetector(
      onTap: () => setState(() => _selectedAttendanceCourseCode = code),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: selected
              ? (isAssigned ? AppColors.gold : const Color(0xFFF87171))
              : AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected
                ? (isAssigned ? AppColors.gold : const Color(0xFFF87171))
                : AppColors.border,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!isAssigned) ...[
              Icon(Icons.lock, size: 12, color: selected ? Colors.white : AppColors.muted),
              const SizedBox(width: 4),
            ],
            Text(
              label,
              style: TextStyle(
                color: selected
                    ? (isAssigned ? AppColors.navyDeep : Colors.white)
                    : AppColors.onNavy,
                fontSize: 11,
                fontWeight: selected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // FACULTY HELPERS & SUB-WIDGETS
  // ---------------------------------------------------------------------------

  Widget _buildOperationCard({
    required String title,
    IconData? icon,
    String? tag,
    required String mainValue,
    required String subText,
    bool isSuccessTrend = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF13204D),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(color: AppColors.muted, fontSize: 11),
              ),
              if (icon != null)
                Icon(icon, color: AppColors.muted, size: 16),
              if (tag != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE11D48).withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: const Color(0xFFE11D48).withValues(alpha: 0.6)),
                  ),
                  child: Text(
                    tag,
                    style: const TextStyle(
                      color: Color(0xFFFB7185),
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            mainValue,
            style: const TextStyle(
              color: AppColors.onNavy,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subText,
            style: TextStyle(
              color: isSuccessTrend ? const Color(0xFF4ADE80) : AppColors.muted,
              fontSize: 10.5,
              fontWeight: isSuccessTrend ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFacultyShortcutTile({
    required IconData icon,
    required String title,
    required String subtitle,
    bool hasDot = false,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF13204D),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border.withValues(alpha: 0.6)),
        ),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: const Color(0xFF0C1536),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: AppColors.gold, size: 18),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          title,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AppColors.onNavy,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      if (hasDot) ...[
                        const SizedBox(width: 3),
                        Container(
                          width: 5,
                          height: 5,
                          decoration: const BoxDecoration(
                            color: Color(0xFFF97316),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 1),
                  Text(
                    subtitle,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: AppColors.muted, fontSize: 10),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFacultyGradeFilterChip(String label, int index) {
    final isSelected = _facultyGradesFilterIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _facultyGradesFilterIndex = index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.gold : const Color(0xFF13204D),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.gold : AppColors.border.withValues(alpha: 0.6),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? AppColors.navyDeep : AppColors.onNavy,
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildFacultyStudentCard(_FacultyStudentGradeModel s) {
    Color badgeBg;
    Color badgeText;
    switch (s.status) {
      case 'PASSED':
        badgeBg = const Color(0xFF152A20);
        badgeText = const Color(0xFF4ADE80);
        break;
      case 'INCOMPLETE':
        badgeBg = const Color(0xFF33200D);
        badgeText = const Color(0xFFFBBF24);
        break;
      case 'RESIT REQUIRED':
        badgeBg = const Color(0xFF331114);
        badgeText = const Color(0xFFF87171);
        break;
      case 'DISTINCTION':
        badgeBg = const Color(0xFF2D2305);
        badgeText = AppColors.gold;
        break;
      default:
        badgeBg = const Color(0xFF0C1536);
        badgeText = AppColors.muted;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF13204D),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row 1: Avatar, Name, Matricule, Badge
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: const Color(0xFF0C1536),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    s.initials,
                    style: const TextStyle(
                      color: AppColors.gold,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      s.name,
                      style: const TextStyle(
                        color: AppColors.onNavy,
                        fontSize: 13.5,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      s.matricule,
                      style: const TextStyle(color: AppColors.muted, fontSize: 10.5),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: badgeBg,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  s.status,
                  style: TextStyle(
                    color: badgeText,
                    fontSize: 9.5,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.4,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Row 2: CA Score & Exam Score
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0C1536),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('CA Score', style: TextStyle(color: AppColors.muted, fontSize: 9.5)),
                          const SizedBox(height: 2),
                          Text(
                            s.caScore.toStringAsFixed(1),
                            style: TextStyle(
                              color: s.caScore < 15 ? const Color(0xFFF87171) : AppColors.onNavy,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          const Text('/30  ', style: TextStyle(color: AppColors.muted, fontSize: 10)),
                          Icon(
                            s.caScore < 15 ? Icons.error_outline : Icons.check_circle_outline,
                            color: s.caScore < 15 ? const Color(0xFFF87171) : const Color(0xFF4ADE80),
                            size: 14,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: GestureDetector(
                  onTap: () => _showExamScoreEditDialog(context, s.name, s.matricule),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0C1536),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: s.examScore == null
                            ? const Color(0xFFFBBF24).withValues(alpha: 0.7)
                            : AppColors.border.withValues(alpha: 0.5),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              s.examScore == null ? 'Exam Score *' : 'Exam Score',
                              style: const TextStyle(color: AppColors.muted, fontSize: 9.5),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              s.examScore != null ? s.examScore!.toStringAsFixed(1) : '0–70',
                              style: TextStyle(
                                color: s.examScore != null
                                    ? (s.examScore! < 35 ? const Color(0xFFF87171) : AppColors.onNavy)
                                    : const Color(0xFFFBBF24),
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            const Text('/70  ', style: TextStyle(color: AppColors.muted, fontSize: 10)),
                            if (s.examScore == null)
                              const Icon(Icons.warning_amber_rounded, color: Color(0xFFFBBF24), size: 14)
                            else if (s.examScore! < 35)
                              const Icon(Icons.error_outline, color: Color(0xFFF87171), size: 14)
                            else
                              const Icon(Icons.check_circle_outline, color: Color(0xFF4ADE80), size: 14),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),

          // Optional warning banner (e.g. for missing exam)
          if (s.warningMessage != null) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF261908),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: const Color(0xFFFBBF24).withValues(alpha: 0.4)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.warning_amber_rounded, color: Color(0xFFFBBF24), size: 13),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      s.warningMessage!,
                      style: const TextStyle(color: Color(0xFFFBBF24), fontSize: 10, fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 10),

          // Row 3: Total, Grade, Points & Trailing icon/action
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  RichText(
                    text: TextSpan(
                      text: 'Total ',
                      style: const TextStyle(color: AppColors.muted, fontSize: 11),
                      children: [
                        TextSpan(
                          text: s.total != null ? '${s.total!.toStringAsFixed(1)}%' : '--',
                          style: TextStyle(
                            color: s.total != null && s.total! < 50 ? const Color(0xFFF87171) : AppColors.onNavy,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 14),
                  RichText(
                    text: TextSpan(
                      text: 'Grade ',
                      style: const TextStyle(color: AppColors.muted, fontSize: 11),
                      children: [
                        TextSpan(
                          text: s.grade ?? '--',
                          style: TextStyle(
                            color: s.grade == 'F' ? const Color(0xFFF87171) : AppColors.gold,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 14),
                  RichText(
                    text: TextSpan(
                      text: 'Points ',
                      style: const TextStyle(color: AppColors.muted, fontSize: 11),
                      children: [
                        TextSpan(
                          text: s.points != null ? s.points!.toStringAsFixed(2) : '--',
                          style: const TextStyle(color: AppColors.onNavy, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (s.trailingIcon != null)
                Icon(s.trailingIcon, color: AppColors.gold, size: 18),
              if (s.trailingAction != null)
                Text(
                  s.trailingAction!,
                  style: TextStyle(
                    color: s.trailingAction == 'SUB-THRESHOLD' ? const Color(0xFFF87171) : const Color(0xFFFBBF24),
                    fontSize: 10.5,
                    fontWeight: FontWeight.bold,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAttendanceToggleButton({
    required String label,
    required bool isActive,
    required Color activeColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: isActive ? activeColor.withValues(alpha: 0.2) : const Color(0xFF0C1536),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: isActive ? activeColor : AppColors.border.withValues(alpha: 0.5),
            width: isActive ? 1.4 : 1,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: isActive ? activeColor : AppColors.muted,
              fontWeight: FontWeight.bold,
              fontSize: 11.5,
            ),
          ),
        ),
      ),
    );
  }

  void _showExamScoreEditDialog(BuildContext context, String studentName, String matricule) {
    final controller = TextEditingController(
      text: _customExamScores[matricule]?.toStringAsFixed(1) ?? '52.0',
    );

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.navyDeep,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Enter Exam Score ($studentName)',
          style: const TextStyle(color: AppColors.onNavy, fontSize: 15, fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Input final examination marks (out of 70). Formula Total = CA (18.0) + Exam.',
              style: TextStyle(color: AppColors.muted, fontSize: 12),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: controller,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              style: const TextStyle(color: AppColors.onNavy, fontWeight: FontWeight.bold),
              decoration: InputDecoration(
                filled: true,
                fillColor: const Color(0xFF13204D),
                labelText: 'Exam Score / 70',
                labelStyle: const TextStyle(color: AppColors.gold),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: AppColors.muted)),
          ),
          ElevatedButton(
            onPressed: () {
              final parsed = double.tryParse(controller.text.trim());
              if (parsed != null && parsed >= 0 && parsed <= 70) {
                setState(() => _customExamScores[matricule] = parsed);
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('✓ Updated Exam mark for $studentName to ${parsed.toStringAsFixed(1)}/70.'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.gold,
              foregroundColor: AppColors.navyDeep,
            ),
            child: const Text('Save Score'),
          ),
        ],
      ),
    );
  }

  void _showFacultyTimetableModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.navyDeep,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Faculty Timetable — Week 7',
                  style: TextStyle(color: AppColors.onNavy, fontSize: 16, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: AppColors.muted),
                  onPressed: () => Navigator.pop(ctx),
                ),
              ],
            ),
            const SizedBox(height: 10),
            const Text(
              '• Tuesday: SW201 (10:00 - 12:00) • Hall B-104 (Campus A)\n'
              '• Tuesday: SW101 Lab (14:00 - 16:00) • Lab 3 (Engineering Block)\n'
              '• Thursday: SW101 Theory (08:00 - 10:00) • Amphitheatre 2\n'
              '• Friday: SW201 Tutorial (11:00 - 13:00) • Hall B-104\n'
              '• Friday: CS102 (15:00 - 17:00) • Computing Lab 1',
              style: TextStyle(color: AppColors.muted, height: 1.6),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _showFacultyRosterModal(BuildContext context, String title) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.navyDeep,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: const TextStyle(color: AppColors.onNavy, fontSize: 16, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: AppColors.muted),
                  onPressed: () => Navigator.pop(ctx),
                ),
              ],
            ),
            const SizedBox(height: 10),
            const Text(
              '• Cohort SEL200 (Software Eng Level 200) — 38 Students\n'
              '• Cohort CS L100 (Computer Science Level 100) — 42 Students\n'
              '• Cohort SEL300 (Software Architecture) — 29 Students\n'
              '• Cohort CS L100B (Discrete Math) — 45 Students',
              style: TextStyle(color: AppColors.muted, height: 1.6),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _showGradeValidationReport(BuildContext context, bool divineHasExam) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.navyDeep,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Grade Sheet Validation Report',
                  style: TextStyle(color: AppColors.onNavy, fontSize: 16, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: AppColors.muted),
                  onPressed: () => Navigator.pop(ctx),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              divineHasExam
                  ? '✓ 41 entries meet Senate grading criteria (CA 30% + Exam 70%).\n'
                    '! 1 student flagged for Resit (Marcelle O. Ndong - Score: 36.0%).\n'
                    'Status: Ready for Examination Board submission.'
                  : '✓ 40 entries meet Senate grading criteria (CA 30% + Exam 70%).\n'
                    '⚠ 1 student has missing Exam score (Divine F. Ayuk).\n'
                    '! 1 student flagged for Resit (Marcelle O. Ndong - Score: 36.0%).\n'
                    'Status: Please enter Divine\'s Exam score to complete dispatch.',
              style: const TextStyle(color: AppColors.muted, height: 1.6),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _showGradeSubmissionModal(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.navyDeep,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Submit Grades for Faculty Board Review',
          style: TextStyle(color: AppColors.onNavy, fontSize: 16, fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'This will seal the SW101 Continuous Assessment (30%) and Exam (70%) grade sheets and dispatch them to the Examination Board and Department Chair.\n\nAre you sure you want to proceed?',
          style: TextStyle(color: AppColors.muted, fontSize: 12.5, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: AppColors.muted)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('✓ Grade sheet SW101 successfully submitted for Faculty Board review!'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.gold,
              foregroundColor: AppColors.navyDeep,
            ),
            child: const Text('Confirm & Dispatch'),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // ADMIN & SUPER ADMIN 4-TAB PORTAL SCAFFOLD (Desktop + Mobile Responsive)
  // ---------------------------------------------------------------------------

  Widget _buildAdminPortalScaffold(DashboardData data) {
    const tabSectionNames = [
      'OPERATIONS OVERVIEW',
      'STUDENT DIRECTORY',
      'FEE LEDGER (FCFA)',
      'TIMETABLE & VENUES',
    ];
    final currentSection = tabSectionNames[_adminTabIndex];
    final isDesktop = MediaQuery.sizeOf(context).width >= 850;

    if (isDesktop) {
      return Scaffold(
        backgroundColor: AppColors.navy,
        body: Row(
          children: [
            _buildDesktopSidebar(
              role: data.role,
              data: data,
              selectedIndex: _adminTabIndex,
              onSelect: (idx) => setState(() => _adminTabIndex = idx),
            ),
            Expanded(
              child: Column(
                children: [
                  _buildDesktopTopBar(
                    data: data,
                    sectionName: currentSection,
                    roleLabel: data.role == DashboardRole.superAdmin
                        ? 'Super Administrator • University SMS'
                        : 'Administrator • Registry & Admissions',
                  ),
                  Expanded(
                    child: Center(
                      child: Container(
                        constraints: const BoxConstraints(maxWidth: 1150),
                        child: IndexedStack(
                          index: _adminTabIndex,
                          children: [
                            _buildAdminOverviewTab(data),
                            _buildAdminDirectoryTab(data),
                            _buildAdminFinanceTab(data),
                            _buildAdminTimetableTab(data),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.navy,
      drawer: _buildMobileDrawer(
        role: data.role,
        data: data,
        selectedIndex: _adminTabIndex,
        onSelect: (idx) {
          Navigator.pop(context);
          setState(() => _adminTabIndex = idx);
        },
      ),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(64),
        child: _buildAdminPortalTopBar(data, currentSection),
      ),
      body: SafeArea(
        child: IndexedStack(
          index: _adminTabIndex,
          children: [
            _buildAdminOverviewTab(data),
            _buildAdminDirectoryTab(data),
            _buildAdminFinanceTab(data),
            _buildAdminTimetableTab(data),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AppColors.navyDeep,
          border: Border(top: BorderSide(color: AppColors.border, width: 0.8)),
        ),
        child: BottomNavigationBar(
          backgroundColor: AppColors.navyDeep,
          selectedItemColor: AppColors.gold,
          unselectedItemColor: AppColors.muted,
          currentIndex: _adminTabIndex,
          type: BottomNavigationBarType.fixed,
          selectedFontSize: 11,
          unselectedFontSize: 11,
          elevation: 0,
          onTap: (index) => setState(() => _adminTabIndex = index),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard_outlined),
              activeIcon: Icon(Icons.dashboard),
              label: 'Overview',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.people_alt_outlined),
              activeIcon: Icon(Icons.people_alt),
              label: 'Directory',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.payments_outlined),
              activeIcon: Icon(Icons.payments),
              label: 'Finance',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.calendar_month_outlined),
              activeIcon: Icon(Icons.calendar_month),
              label: 'Timetable',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdminPortalTopBar(DashboardData data, String currentSection) {
    final roleName = data.role == DashboardRole.superAdmin
        ? 'SUPER ADMIN'
        : 'ADMINISTRATOR';

    return Container(
      color: AppColors.navyDeep,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            Builder(
              builder: (ctx) => IconButton(
                icon: const Icon(Icons.menu_rounded, color: AppColors.onNavy, size: 24),
                tooltip: 'Navigation Menu',
                onPressed: () => Scaffold.of(ctx).openDrawer(),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
              ),
            ),
            const SizedBox(width: 6),
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.gold.withValues(alpha: 0.5),
                  width: 1.5,
                ),
              ),
              child: ClipOval(
                child: Image.asset(
                  'assets/images/logo.png',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => const Icon(
                    Icons.school,
                    color: AppColors.gold,
                    size: 20,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      const Text(
                        'FAH ACADEMY',
                        style: TextStyle(
                          color: AppColors.onNavy,
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.4,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                        decoration: BoxDecoration(
                          color: AppColors.gold.withValues(alpha: 0.18),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                            color: AppColors.gold.withValues(alpha: 0.5),
                            width: 0.8,
                          ),
                        ),
                        child: Text(
                          roleName,
                          style: const TextStyle(
                            color: AppColors.gold,
                            fontSize: 8.5,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 1),
                  const Text(
                    '2026/2027 • S1 • REGISTRY',
                    style: TextStyle(
                      color: AppColors.muted,
                      fontSize: 9.5,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.notifications_outlined, color: AppColors.onNavy, size: 22),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Notice: 4 tuition payments pending verification via MTN MoMo & UBA.'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
            ),
            const SizedBox(width: 8),
            PopupMenuButton<String>(
              tooltip: 'Administrator Account',
              color: AppColors.surface,
              onSelected: (val) {
                if (val == 'signout') {
                  _handleSignOut();
                } else if (val == 'handbook') {
                  _showAcademicRegulationsModal(context);
                } else if (val == 'settings') {
                  _showSettingsModal(context, data);
                }
              },
              itemBuilder: (ctx) => [
                PopupMenuItem(
                  enabled: false,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        data.displayName,
                        style: const TextStyle(
                          color: AppColors.onNavy,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Matricule: ${data.userId}',
                        style: const TextStyle(
                          color: AppColors.gold,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        data.role == DashboardRole.superAdmin
                            ? 'Super Administrator • Full System Control'
                            : 'University Administrator • Registry',
                        style: const TextStyle(
                          color: AppColors.muted,
                          fontSize: 10.5,
                        ),
                      ),
                    ],
                  ),
                ),
                const PopupMenuDivider(),
                const PopupMenuItem(
                  value: 'settings',
                  child: Row(
                    children: [
                      Icon(Icons.settings_outlined, color: AppColors.gold, size: 18),
                      SizedBox(width: 8),
                      Text('Settings & Preferences', style: TextStyle(color: AppColors.onNavy, fontSize: 13)),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'handbook',
                  child: Row(
                    children: [
                      Icon(Icons.menu_book_outlined, color: AppColors.gold, size: 18),
                      SizedBox(width: 8),
                      Text('Senate Academic Rules', style: TextStyle(color: AppColors.onNavy, fontSize: 13)),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'signout',
                  child: Row(
                    children: [
                      Icon(Icons.logout, color: Color(0xFFF87171), size: 18),
                      SizedBox(width: 8),
                      Text('Sign out', style: TextStyle(color: Color(0xFFF87171), fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ],
              child: CircleAvatar(
                radius: 17,
                backgroundColor: AppColors.surfaceRaised,
                child: Text(
                  data.displayName.isNotEmpty
                      ? data.displayName.substring(0, 1).toUpperCase()
                      : 'A',
                  style: const TextStyle(
                    color: AppColors.gold,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // TAB 1: OPERATIONS OVERVIEW (Admin & Super Admin)
  // ---------------------------------------------------------------------------

  Widget _buildAdminOverviewTab(DashboardData data) {
    final isSuper = data.role == DashboardRole.superAdmin;

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      children: [
        // Welcome Card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF13204D), Color(0xFF1B2F6E)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.gold.withValues(alpha: 0.35)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Welcome, ${data.displayName}',
                          style: const TextStyle(
                            color: AppColors.onNavy,
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          isSuper
                              ? 'FAH ACADEMY SUPER ADMIN CONSOLE • 2026/2027'
                              : 'REGISTRY & ACADEMIC OPERATIONS • 2026/2027',
                          style: const TextStyle(
                            color: AppColors.gold,
                            fontSize: 10.5,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: AppColors.gold.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.gold.withValues(alpha: 0.5)),
                    ),
                    child: Text(
                      'STATUS: ONLINE',
                      style: const TextStyle(
                        color: AppColors.gold,
                        fontSize: 9.5,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Text(
                'Cameroon Higher Education Standard (MINESUP Compliant) • 4-Year Credit System (LMD). Continuous Assessment accounts for 30% and Terminal Examinations for 70%.',
                style: TextStyle(
                  color: AppColors.muted,
                  fontSize: 11.5,
                  height: 1.45,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // KPI Summary Metrics
        const Text(
          'INSTITUTIONAL METRICS',
          style: TextStyle(
            color: AppColors.muted,
            fontSize: 11,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 10),

        LayoutBuilder(
          builder: (context, constraints) {
            final cardWidth = constraints.maxWidth > 500
                ? (constraints.maxWidth - 36) / 4
                : (constraints.maxWidth - 12) / 2;

            return Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _buildAdminMetricCard(
                  icon: Icons.school_rounded,
                  label: 'Total Enrolment',
                  value: '1,280',
                  subtext: '4 cohorts (L100-L400)',
                  width: cardWidth,
                ),
                _buildAdminMetricCard(
                  icon: Icons.payments_rounded,
                  label: 'Tuition Collected',
                  value: '553.2M',
                  subtext: '86.4% clearance rate',
                  width: cardWidth,
                  valueColor: const Color(0xFF4ADE80),
                ),
                _buildAdminMetricCard(
                  icon: Icons.badge_rounded,
                  label: 'Active Lecturers',
                  value: '48',
                  subtext: 'Computing & Eng.',
                  width: cardWidth,
                ),
                _buildAdminMetricCard(
                  icon: Icons.menu_book_rounded,
                  label: 'Accredited Modules',
                  value: '64',
                  subtext: 'Semester 1 2026/27',
                  width: cardWidth,
                ),
              ],
            );
          },
        ),

        const SizedBox(height: 24),

        // Quick Operations Grid
        const Text(
          'QUICK ADMINISTRATIVE WORKFLOWS',
          style: TextStyle(
            color: AppColors.muted,
            fontSize: 11,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 10),

        LayoutBuilder(
          builder: (context, constraints) {
            final cardWidth = constraints.maxWidth > 500
                ? (constraints.maxWidth - 24) / 3
                : constraints.maxWidth;

            return Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _buildAdminActionCard(
                  icon: Icons.how_to_reg_outlined,
                  title: 'Admissions & Enrolment',
                  description: 'Review pending applications and assign Cameroonian matricules.',
                  onTap: () {
                    setState(() => _adminTabIndex = 1);
                  },
                  width: cardWidth,
                ),
                _buildAdminActionCard(
                  icon: Icons.fact_check_outlined,
                  title: 'Grade Broadsheets (CA 30% / Exam 70%)',
                  description: 'Audit faculty mark sheets and validate Senate pass thresholds.',
                  onTap: () => _showSenateBroadsheetDialog(context),
                  width: cardWidth,
                ),
                _buildAdminActionCard(
                  icon: Icons.verified_user_outlined,
                  title: 'Verify MoMo & Bank Deposits',
                  description: 'Audit MTN MoMo, Orange Money, UBA & Afriland bank slips.',
                  onTap: () {
                    setState(() => _adminTabIndex = 2);
                  },
                  width: cardWidth,
                ),
                _buildAdminActionCard(
                  icon: Icons.calendar_month_outlined,
                  title: 'Timetable & Hall Scheduling',
                  description: 'Manage amphitheatre capacities, lab allocations and exam shifts.',
                  onTap: () {
                    setState(() => _adminTabIndex = 3);
                  },
                  width: cardWidth,
                ),
                _buildAdminActionCard(
                  icon: Icons.published_with_changes_outlined,
                  title: 'Session de Rattrapage',
                  description: 'Generate list of candidates registered for Resit Examinations.',
                  onTap: () => _showResitSessionDialog(context),
                  width: cardWidth,
                ),
                if (isSuper)
                  _buildAdminActionCard(
                    icon: Icons.admin_panel_settings_outlined,
                    title: 'System Security & RBAC',
                    description: 'Audit user roles, active tokens, and permission privileges.',
                    onTap: () => _showSystemSecurityDialog(context),
                    width: cardWidth,
                  ),
              ],
            );
          },
        ),

        const SizedBox(height: 24),

        // System Notices
        const Text(
          'SENATE & CAMPUS NOTICES',
          style: TextStyle(
            color: AppColors.muted,
            fontSize: 11,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 10),

        _buildAdminNoticeCard(
          title: 'Continuous Assessment (CA 30%) Deadline',
          date: 'Nov 14, 2026',
          detail: 'All course instructors must submit CA marks before the terminal exam board.',
          isUrgent: true,
        ),
        _buildAdminNoticeCard(
          title: 'Tuition Fee 2nd Installment Notice',
          date: 'Nov 20, 2026',
          detail: 'Remind Level 100 & 200 students to complete fee clearance via MTN MoMo, Orange Money, or UBA.',
          isUrgent: false,
        ),
        _buildAdminNoticeCard(
          title: 'Amphitheatre 1 Audio-Visual Renovation',
          date: 'Oct 28, 2026',
          detail: 'Amphi 1 will be reserved for maintenance on Saturday from 08:00 to 14:00.',
          isUrgent: false,
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildAdminMetricCard({
    required IconData icon,
    required String label,
    required String value,
    required String subtext,
    required double width,
    Color? valueColor,
  }) {
    return Container(
      width: width,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF13204D),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: const TextStyle(color: AppColors.muted, fontSize: 11, fontWeight: FontWeight.w600),
              ),
              Icon(icon, color: AppColors.gold, size: 18),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: valueColor ?? AppColors.onNavy,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtext,
            style: const TextStyle(color: AppColors.muted, fontSize: 10),
          ),
        ],
      ),
    );
  }

  Widget _buildAdminActionCard({
    required IconData icon,
    required String title,
    required String description,
    required VoidCallback onTap,
    required double width,
  }) {
    return Material(
      color: const Color(0xFF13204D),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: width,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border.withValues(alpha: 0.6)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: AppColors.gold.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(icon, color: AppColors.gold, size: 18),
                  ),
                  const Spacer(),
                  const Icon(Icons.arrow_forward_ios_rounded, color: AppColors.muted, size: 13),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                title,
                style: const TextStyle(
                  color: AppColors.onNavy,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: const TextStyle(
                  color: AppColors.muted,
                  fontSize: 11,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAdminNoticeCard({
    required String title,
    required String date,
    required String detail,
    required bool isUrgent,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF13204D),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isUrgent ? const Color(0xFFF87171).withValues(alpha: 0.5) : AppColors.border.withValues(alpha: 0.5),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            isUrgent ? Icons.error_outline_rounded : Icons.info_outline_rounded,
            color: isUrgent ? const Color(0xFFF87171) : AppColors.gold,
            size: 18,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          color: AppColors.onNavy,
                          fontSize: 12.5,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Text(
                      date,
                      style: const TextStyle(color: AppColors.muted, fontSize: 10),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  detail,
                  style: const TextStyle(color: AppColors.muted, fontSize: 11, height: 1.35),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // TAB 2: STUDENT DIRECTORY (Admin & Super Admin)
  // ---------------------------------------------------------------------------

  Widget _buildAdminDirectoryTab(DashboardData data) {
    final levels = [
      'All Levels',
      'Level 100 (Year 1)',
      'Level 200 (Year 2)',
      'Level 300 (Year 3)',
      'Level 400 (Year 4)',
    ];

    final students = [
      const _AdminStudentRecord(
        name: 'Marcelle O. Ndong',
        matricule: 'FAH/24/SWE/0891',
        level: 'Level 200 (Year 2)',
        program: 'B.Sc Software Engineering',
        feeStatus: 'Cleared',
        feePaid: 500000,
        feeTotal: 500000,
        gpa: 3.78,
        standing: 'Distinction',
      ),
      const _AdminStudentRecord(
        name: 'Divine F. Ayuk',
        matricule: 'FAH/24/SWE/0482',
        level: 'Level 200 (Year 2)',
        program: 'B.Sc Software Engineering',
        feeStatus: 'Installment 1 Cleared',
        feePaid: 300000,
        feeTotal: 500000,
        gpa: 3.24,
        standing: 'Good Standing',
      ),
      const _AdminStudentRecord(
        name: 'Bryan K. Tabe',
        matricule: 'FAH/24/CEF/0122',
        level: 'Level 100 (Year 1)',
        program: 'B.Eng Computer Engineering',
        feeStatus: 'Cleared',
        feePaid: 450000,
        feeTotal: 450000,
        gpa: 3.65,
        standing: 'Distinction',
      ),
      const _AdminStudentRecord(
        name: 'Brenda N. Fomukong',
        matricule: 'FAH/24/ICT/0319',
        level: 'Level 300 (Year 3)',
        program: 'B.Sc Information Systems',
        feeStatus: 'Cleared',
        feePaid: 500000,
        feeTotal: 500000,
        gpa: 3.91,
        standing: 'First Class Honors',
      ),
      const _AdminStudentRecord(
        name: 'Kelly C. Enow',
        matricule: 'FAH/24/SWE/0712',
        level: 'Level 200 (Year 2)',
        program: 'B.Sc Software Engineering',
        feeStatus: 'Cleared',
        feePaid: 500000,
        feeTotal: 500000,
        gpa: 3.15,
        standing: 'Good Standing',
      ),
      const _AdminStudentRecord(
        name: 'Samuel T. Mbarga',
        matricule: 'FAH/24/ICT/0401',
        level: 'Level 100 (Year 1)',
        program: 'B.Sc ICT Fundamentals',
        feeStatus: 'Unpaid',
        feePaid: 0,
        feeTotal: 450000,
        gpa: 2.95,
        standing: 'Probationary',
      ),
      const _AdminStudentRecord(
        name: 'Christelle M. Bih',
        matricule: 'FAH/24/CEF/0204',
        level: 'Level 200 (Year 2)',
        program: 'B.Eng Computer Engineering',
        feeStatus: 'Cleared',
        feePaid: 500000,
        feeTotal: 500000,
        gpa: 3.82,
        standing: 'Distinction',
      ),
      const _AdminStudentRecord(
        name: 'Alain P. Kamga',
        matricule: 'FAH/24/SWE/0914',
        level: 'Level 400 (Year 4)',
        program: 'B.Sc Software Engineering',
        feeStatus: 'Cleared',
        feePaid: 550000,
        feeTotal: 550000,
        gpa: 3.72,
        standing: 'Distinction',
      ),
    ];

    final filteredStudents = students.where((s) {
      if (_adminDirectoryLevelFilter > 0) {
        final expectedLevel = levels[_adminDirectoryLevelFilter];
        if (s.level != expectedLevel) return false;
      }
      if (_adminDirectorySearchQuery.trim().isNotEmpty) {
        final query = _adminDirectorySearchQuery.toLowerCase();
        final matchName = s.name.toLowerCase().contains(query);
        final matchMatricule = s.matricule.toLowerCase().contains(query);
        final matchProg = s.program.toLowerCase().contains(query);
        if (!matchName && !matchMatricule && !matchProg) return false;
      }
      return true;
    }).toList();

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      children: [
        // Title & Search
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Student Directory',
                  style: TextStyle(
                    color: AppColors.onNavy,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  '${filteredStudents.length} of ${students.length} students displayed',
                  style: const TextStyle(color: AppColors.muted, fontSize: 11),
                ),
              ],
            ),
            ElevatedButton.icon(
              onPressed: () => _showAddStudentModal(context),
              icon: const Icon(Icons.person_add_alt_1, size: 16),
              label: const Text('Add Student'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.gold,
                foregroundColor: AppColors.navyDeep,
                textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
            ),
          ],
        ),

        const SizedBox(height: 14),

        // Search Input
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFF13204D),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.border.withValues(alpha: 0.6)),
          ),
          child: TextField(
            style: const TextStyle(color: AppColors.onNavy, fontSize: 13),
            decoration: InputDecoration(
              hintText: 'Search by student name or matricule (e.g. FAH/24/SWE/0891)...',
              hintStyle: const TextStyle(color: AppColors.muted, fontSize: 12),
              prefixIcon: const Icon(Icons.search, color: AppColors.gold, size: 20),
              suffixIcon: _adminDirectorySearchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, color: AppColors.muted, size: 16),
                      onPressed: () => setState(() => _adminDirectorySearchQuery = ''),
                    )
                  : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
            ),
            onChanged: (val) => setState(() => _adminDirectorySearchQuery = val),
          ),
        ),

        const SizedBox(height: 12),

        // Level Filter Chips
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: List.generate(levels.length, (idx) {
              final isSelected = _adminDirectoryLevelFilter == idx;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(levels[idx]),
                  selected: isSelected,
                  selectedColor: AppColors.gold,
                  backgroundColor: const Color(0xFF13204D),
                  labelStyle: TextStyle(
                    color: isSelected ? AppColors.navyDeep : AppColors.onNavy,
                    fontSize: 11,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  ),
                  side: BorderSide(
                    color: isSelected ? AppColors.gold : AppColors.border.withValues(alpha: 0.6),
                  ),
                  onSelected: (_) => setState(() => _adminDirectoryLevelFilter = idx),
                ),
              );
            }),
          ),
        ),

        const SizedBox(height: 16),

        // Student Cards
        ...filteredStudents.map((s) => _buildAdminStudentTile(context, s)),

        if (filteredStudents.isEmpty)
          Container(
            padding: const EdgeInsets.all(24),
            alignment: Alignment.center,
            child: const Text(
              'No students found matching your search query.',
              style: TextStyle(color: AppColors.muted, fontSize: 13),
            ),
          ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildAdminStudentTile(BuildContext context, _AdminStudentRecord s) {
    Color badgeBg;
    Color badgeText;

    if (s.feeStatus == 'Cleared') {
      badgeBg = const Color(0xFF152A20);
      badgeText = const Color(0xFF4ADE80);
    } else if (s.feeStatus == 'Unpaid') {
      badgeBg = const Color(0xFF331114);
      badgeText = const Color(0xFFF87171);
    } else {
      badgeBg = const Color(0xFF33200D);
      badgeText = const Color(0xFFFBBF24);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF13204D),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 17,
                backgroundColor: AppColors.surfaceRaised,
                child: Text(
                  s.name.substring(0, 1),
                  style: const TextStyle(
                    color: AppColors.gold,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      s.name,
                      style: const TextStyle(
                        color: AppColors.onNavy,
                        fontSize: 13.5,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      '${s.matricule} • ${s.level}',
                      style: const TextStyle(color: AppColors.gold, fontSize: 10.5, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: badgeBg,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  s.feeStatus.toUpperCase(),
                  style: TextStyle(
                    color: badgeText,
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                s.program,
                style: const TextStyle(color: AppColors.muted, fontSize: 11),
              ),
              RichText(
                text: TextSpan(
                  text: 'GPA: ',
                  style: const TextStyle(color: AppColors.muted, fontSize: 11),
                  children: [
                    TextSpan(
                      text: s.gpa.toStringAsFixed(2),
                      style: const TextStyle(
                        color: AppColors.onNavy,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextSpan(
                      text: ' (${s.standing})',
                      style: const TextStyle(color: AppColors.gold, fontSize: 10.5),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Divider(color: AppColors.border, height: 1),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Tuition: ${s.feePaid.toStringAsFixed(0)} / ${s.feeTotal.toStringAsFixed(0)} FCFA',
                style: const TextStyle(color: AppColors.muted, fontSize: 10.5),
              ),
              TextButton(
                onPressed: () => _showStudentDetailsModal(context, s),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.gold,
                  padding: EdgeInsets.zero,
                  minimumSize: const Size(60, 24),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text('View Record →', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // BURSARY AUDIT DESK: BANK RECEIPT VERIFICATION CONSOLE
  // Pixel-perfect implementation of screen 04fcd5d0 (media_1792579066517)
  // ---------------------------------------------------------------------------

  Widget _buildBursaryVerificationView(DashboardData data) {
    final pendingCount = _clarisseCleared ? 13 : 14;
    final totalPendingAmount = _clarisseCleared ? '3,200,000' : '3,450,000';
    final clearedTodayCount = _clarisseCleared ? 29 : 28;
    final clearedTodayAmount = _clarisseCleared ? '7,050,000' : '6,800,000';

    return Stack(
      children: [
        ListView(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 100),
          children: [
            // Top Navigation & Identity Bar
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                InkWell(
                  onTap: () => setState(() => _showBursaryVerificationScreen = false),
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF13204D),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.arrow_back_ios_new, size: 12, color: AppColors.gold),
                        SizedBox(width: 6),
                        Text(
                          'Treasury Operations',
                          style: TextStyle(
                            color: AppColors.gold,
                            fontSize: 11.5,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.gold.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: AppColors.gold),
                      ),
                      child: const Text(
                        'AB-12',
                        style: TextStyle(
                          color: AppColors.gold,
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'FAH ACADEMY BURSARY',
                      style: TextStyle(
                        color: AppColors.onNavy,
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.6,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Stack(
                      children: [
                        const CircleAvatar(
                          radius: 15,
                          backgroundColor: AppColors.surfaceRaised,
                          child: Text(
                            'B',
                            style: TextStyle(
                              color: AppColors.gold,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: Color(0xFF4ADE80),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 6),
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Dr. Beatrice M. Ngu',
                          style: TextStyle(
                            color: AppColors.onNavy,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Treasury Comptroller',
                          style: TextStyle(
                            color: AppColors.muted,
                            fontSize: 9.5,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Subheader Banner
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF13204D),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Bank Receipt Verification',
                        style: TextStyle(
                          color: AppColors.onNavy,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 3),
                      const Text(
                        'Bursary Audit Desk • Academic Term 2026/2027 S1',
                        style: TextStyle(color: AppColors.muted, fontSize: 11),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: AppColors.gold.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.gold),
                    ),
                    child: Text(
                      '$pendingCount PENDING SLIPS • $totalPendingAmount XAF Total',
                      style: const TextStyle(
                        color: AppColors.gold,
                        fontSize: 10.5,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // 2x2 Metric Cards Grid
            Row(
              children: [
                Expanded(
                  child: _buildBursaryMetricCard(
                    title: 'PENDING INFLOW',
                    value: '$pendingCount Slips • $totalPendingAmount XAF',
                    subText: 'Awaiting Treasury Validation',
                    icon: Icons.hourglass_top,
                    accentColor: AppColors.gold,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildBursaryMetricCard(
                    title: 'BANK DISTRIBUTION',
                    value: 'UBA: 9 • 2.1M / AFB: 5 • 1.35M',
                    subText: '9 UBA Teller Slips, 5 Afriland',
                    icon: Icons.account_balance,
                    accentColor: const Color(0xFF38BDF8),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _buildBursaryMetricCard(
                    title: 'API BANK FEED',
                    value: '11 Synced • 55.2% Match',
                    subText: 'Live Core-Banking Hook Active',
                    icon: Icons.sync_alt,
                    accentColor: const Color(0xFF4ADE80),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildBursaryMetricCard(
                    title: 'CLEARED TODAY',
                    value: '$clearedTodayCount Slips • $clearedTodayAmount XAF',
                    subText: '+12.4% vs Yesterday',
                    icon: Icons.verified,
                    accentColor: const Color(0xFF4ADE80),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Filter Tabs & Search
            Row(
              children: [
                _buildBursaryFilterChip('Urgent Audit (5)', 0),
                const SizedBox(width: 8),
                _buildBursaryFilterChip('All Pending ($pendingCount)', 1),
                const SizedBox(width: 8),
                _buildBursaryFilterChip('Flagged (2)', 2),
              ],
            ),
            const SizedBox(height: 12),

            // Search Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFF0C1536),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.border),
              ),
              child: const Row(
                children: [
                  Icon(Icons.search, color: AppColors.muted, size: 18),
                  SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      style: TextStyle(color: AppColors.onNavy, fontSize: 12),
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Student matricule, teller ID, slip #...',
                        hintStyle: TextStyle(color: AppColors.muted, fontSize: 11.5),
                      ),
                    ),
                  ),
                  Icon(Icons.tune, color: AppColors.gold, size: 16),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // SECTION: PRIORITY VERIFICATION CARD (Slip 1 of 14)
            if (!_clarisseCleared) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF13204D),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.gold, width: 1.4),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFFEF4444),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text(
                                'URGENT AUDIT #1',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 9,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'SLIP 1 OF 14',
                              style: TextStyle(
                                color: AppColors.gold,
                                fontSize: 10.5,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEF4444).withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: const Color(0xFFEF4444)),
                          ),
                          child: const Text(
                            'Exam Hold Active',
                            style: TextStyle(
                              color: Color(0xFFF87171),
                              fontSize: 9.5,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Clarisse M. Fong',
                              style: TextStyle(
                                color: AppColors.onNavy,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 2),
                            const Text(
                              'FAH-2024-SW0467 • B.Eng S.W. (Level 200)',
                              style: TextStyle(color: AppColors.muted, fontSize: 11),
                            ),
                          ],
                        ),
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '250,000 XAF',
                              style: TextStyle(
                                color: AppColors.gold,
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            Text(
                              'UBA - Commercial Ave Branch',
                              style: TextStyle(color: AppColors.muted, fontSize: 10),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Physical Slip OCR Scan Preview Box
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0C1536),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Row(
                                children: [
                                  Icon(Icons.document_scanner, color: AppColors.gold, size: 14),
                                  SizedBox(width: 6),
                                  Text(
                                    'PHYSICAL SLIP OCR SCAN',
                                    style: TextStyle(
                                      color: AppColors.gold,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF152A20),
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(color: const Color(0xFF4ADE80)),
                                ),
                                child: const Text(
                                  'VALIDATED',
                                  style: TextStyle(
                                    color: Color(0xFF4ADE80),
                                    fontSize: 8.5,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Slip No: UBA-CM-2026-99452 • Date: 18-OCT-2026\n'
                            'Cashier ID: 8821 • Stamp: TELLER STAMP #44 (Bamenda Commercial Ave)\n'
                            'Depositor: Clarisse M. Fong • Account: 10033 05200 120409',
                            style: TextStyle(color: AppColors.muted, fontSize: 10.5, height: 1.4),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Live-Core Treasury Auto-Match
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0C1536),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.check_circle, color: Color(0xFF4ADE80), size: 14),
                              SizedBox(width: 6),
                              Text(
                                '100% Core-Banking Match (Ref: UBA-99452)',
                                style: TextStyle(
                                  color: Color(0xFF4ADE80),
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          const Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Student Fee Ledger Standing:',
                                style: TextStyle(color: AppColors.muted, fontSize: 10),
                              ),
                              Text(
                                '32% → 100% Complete Clearance',
                                style: TextStyle(
                                  color: AppColors.gold,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(3),
                            child: const LinearProgressIndicator(
                              value: 1.0,
                              backgroundColor: AppColors.surface,
                              valueColor: AlwaysStoppedAnimation(Color(0xFF4ADE80)),
                              minHeight: 5,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 14),

                    // Action Buttons (Flag / Reject vs Verify & Clear)
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFFF87171),
                              side: const BorderSide(color: Color(0xFFF87171)),
                              padding: const EdgeInsets.symmetric(vertical: 11),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Slip flagged for manual review with UBA branch auditor.'),
                                  backgroundColor: Color(0xFF261517),
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            },
                            child: const Text('Flag / Reject', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          flex: 2,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.gold,
                              foregroundColor: AppColors.navyDeep,
                              padding: const EdgeInsets.symmetric(vertical: 11),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            onPressed: () {
                              setState(() {
                                _clarisseCleared = true;
                              });
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('✓ Deposit UBA-CM-2026-99452 verified. Clarisse M. Fong exam hold released!'),
                                  backgroundColor: Color(0xFF152A20),
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            },
                            icon: const Icon(Icons.check, size: 16),
                            label: const Text('Verify & Clear (250,000 XAF)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ] else ...[
              // Cleared state banner for Clarisse
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFF152A20),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF4ADE80)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle, color: Color(0xFF4ADE80), size: 24),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '✓ VERIFIED & CLEARED: Clarisse M. Fong (250,000 XAF)',
                            style: TextStyle(
                              color: Color(0xFF4ADE80),
                              fontWeight: FontWeight.bold,
                              fontSize: 12.5,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Treasury seal BA01-FE22-BA applied. Exam clearance slip dispatched to Student Portal.',
                            style: TextStyle(color: AppColors.muted, fontSize: 10.5),
                          ),
                        ],
                      ),
                    ),
                    TextButton(
                      onPressed: () => setState(() => _clarisseCleared = false),
                      child: const Text('Undo', style: TextStyle(color: AppColors.gold, fontSize: 11)),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 20),

            // SECTION: SECONDARY QUEUE ITEMS
            const Text(
              'PENDING VERIFICATION QUEUE (4 REMAINING)',
              style: TextStyle(
                color: AppColors.gold,
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.8,
              ),
            ),
            const SizedBox(height: 10),

            _buildQueueItem(
              studentName: 'Boris T. Enow',
              matricule: 'FAH-2024-SW0441 • Level 200',
              amount: '150,000 XAF',
              bankName: 'UBA Buea Branch',
              slipId: 'UBA-44812',
              actionLabel: 'Quick Verify',
              isWarning: false,
            ),
            _buildQueueItem(
              studentName: 'Cynthia K. Mbah',
              matricule: 'FAH-2024-CE0119 • Level 300',
              amount: '200,000 XAF',
              bankName: 'Afriland First Bank',
              slipId: 'AFB-90114',
              actionLabel: 'Quick Verify',
              isWarning: false,
            ),
            _buildQueueItem(
              studentName: 'Marcelle O. Ndong',
              matricule: 'FAH-2024-SW0532 • Level 200',
              amount: '120,000 XAF',
              bankName: 'Orange Money Cameroun',
              slipId: 'OM-77120',
              warningMessage: 'Amount Mismatch (Invoiced: 150,000 XAF)',
              actionLabel: 'Audit Slip',
              isWarning: true,
            ),
            _buildQueueItem(
              studentName: 'Divine F. Ayuk',
              matricule: 'FAH-2024-SW0390 • Level 200',
              amount: '75,000 XAF',
              bankName: 'MTN Cameroon MoMo',
              slipId: 'MOMO-55219',
              actionLabel: 'Quick Verify',
              isWarning: false,
            ),

            const SizedBox(height: 20),

            // Footer Compliance Notice
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF0C1536),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.border),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'MINESUP Audit Regulations 2026 • Section 44 Bursary Compliance',
                    style: TextStyle(color: AppColors.muted, fontSize: 9.5),
                  ),
                  Text(
                    'Bursar Seal: BA01-FE22-BA',
                    style: TextStyle(color: AppColors.gold, fontSize: 9.5, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ],
        ),

        // Floating Bottom Action Bar
        Positioned(
          left: 16,
          right: 16,
          bottom: 16,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFF0C1536),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.gold, width: 1.2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.5),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(Icons.bolt, color: AppColors.gold, size: 18),
                    SizedBox(width: 8),
                    Text(
                      '8 Auto-Matched | 2,300,000 XAF Ready',
                      style: TextStyle(
                        color: AppColors.onNavy,
                        fontWeight: FontWeight.bold,
                        fontSize: 12.5,
                      ),
                    ),
                  ],
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.gold,
                    foregroundColor: AppColors.navyDeep,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('✓ 8 auto-matched bank slips batch-signed and sealed by Treasury.'),
                        backgroundColor: Color(0xFF152A20),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  child: const Text('Batch Sign (8)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBursaryMetricCard({
    required String title,
    required String value,
    required String subText,
    required IconData icon,
    required Color accentColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF13204D),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.7)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(color: AppColors.muted, fontSize: 9.5, fontWeight: FontWeight.bold)),
              Icon(icon, color: accentColor, size: 14),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.onNavy,
              fontSize: 12.5,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),
          Text(subText, style: TextStyle(color: accentColor, fontSize: 9.5)),
        ],
      ),
    );
  }

  Widget _buildBursaryFilterChip(String label, int index) {
    final selected = _bursaryFilterIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _bursaryFilterIndex = index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? AppColors.gold : const Color(0xFF13204D),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? AppColors.gold : AppColors.border,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? AppColors.navyDeep : AppColors.onNavy,
            fontSize: 11,
            fontWeight: selected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildQueueItem({
    required String studentName,
    required String matricule,
    required String amount,
    required String bankName,
    required String slipId,
    required String actionLabel,
    required bool isWarning,
    String? warningMessage,
  }) {
    final isCleared = _clearedBursarySlips.contains(slipId);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF13204D),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isWarning
              ? const Color(0xFFEF4444).withValues(alpha: 0.7)
              : AppColors.border.withValues(alpha: 0.5),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      studentName,
                      style: const TextStyle(
                        color: AppColors.onNavy,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (isWarning) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEF4444).withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(3),
                        ),
                        child: const Text('Mismatch', style: TextStyle(color: Color(0xFFF87171), fontSize: 8.5, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  '$matricule • $bankName ($slipId)',
                  style: const TextStyle(color: AppColors.muted, fontSize: 10),
                ),
                if (warningMessage != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    '⚠ $warningMessage',
                    style: const TextStyle(color: Color(0xFFFBBF24), fontSize: 9.5, fontWeight: FontWeight.w600),
                  ),
                ],
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                amount,
                style: const TextStyle(
                  color: AppColors.gold,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              isCleared
                  ? const Text('✓ Cleared', style: TextStyle(color: Color(0xFF4ADE80), fontSize: 11, fontWeight: FontWeight.bold))
                  : OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: isWarning ? const Color(0xFFFBBF24) : AppColors.gold,
                        side: BorderSide(color: isWarning ? const Color(0xFFFBBF24) : AppColors.gold),
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        minimumSize: const Size(60, 24),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                      ),
                      onPressed: () {
                        setState(() {
                          _clearedBursarySlips.add(slipId);
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('✓ $studentName ($amount) verified.'),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                      child: Text(actionLabel, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                    ),
            ],
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // TAB 3: TUITION & FINANCE LEDGER (FCFA) (Admin & Super Admin)
  // ---------------------------------------------------------------------------

  Widget _buildAdminFinanceTab(DashboardData data) {
    if (_showBursaryVerificationScreen) {
      return _buildBursaryVerificationView(data);
    }

    final transactions = [
      const _AdminTransactionRecord(
        txId: 'CM-MOMO-892144',
        date: 'Oct 19, 2026',
        studentName: 'Marcelle O. Ndong',
        matricule: 'FAH/24/SWE/0891',
        channel: 'MTN Cameroon MoMo',
        amount: 250000,
        status: 'Verified & Cleared',
      ),
      const _AdminTransactionRecord(
        txId: 'OM-DLA-338192',
        date: 'Oct 18, 2026',
        studentName: 'Divine F. Ayuk',
        matricule: 'FAH/24/SWE/0482',
        channel: 'Orange Money Cameroun',
        amount: 300000,
        status: 'Verified & Cleared',
      ),
      const _AdminTransactionRecord(
        txId: 'UBA-YDE-049182',
        date: 'Oct 16, 2026',
        studentName: 'Bryan K. Tabe',
        matricule: 'FAH/24/CEF/0122',
        channel: 'UBA Cameroon Deposit',
        amount: 450000,
        status: 'Verified & Cleared',
      ),
      const _AdminTransactionRecord(
        txId: 'AFB-6629104',
        date: 'Oct 15, 2026',
        studentName: 'Brenda N. Fomukong',
        matricule: 'FAH/24/ICT/0319',
        channel: 'Afriland First Bank Wire',
        amount: 500000,
        status: 'Verified & Cleared',
      ),
      const _AdminTransactionRecord(
        txId: 'CM-MOMO-901452',
        date: 'Oct 20, 2026',
        studentName: 'Christelle M. Bih',
        matricule: 'FAH/24/CEF/0204',
        channel: 'MTN Cameroon MoMo',
        amount: 250000,
        status: 'Pending Clearance',
      ),
      const _AdminTransactionRecord(
        txId: 'OM-BUEA-11029',
        date: 'Oct 20, 2026',
        studentName: 'Kelly C. Enow',
        matricule: 'FAH/24/SWE/0712',
        channel: 'Orange Money Cameroun',
        amount: 200000,
        status: 'Pending Clearance',
      ),
    ];

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tuition & Fee Ledger',
                  style: TextStyle(
                    color: AppColors.onNavy,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  'Cameroon Currency (FCFA) • Academic Year 2026/2027',
                  style: TextStyle(color: AppColors.gold, fontSize: 11, fontWeight: FontWeight.w600),
                ),
              ],
            ),
            ElevatedButton.icon(
              onPressed: () => _showAuditReportDownloadDialog(context),
              icon: const Icon(Icons.download_rounded, size: 16),
              label: const Text('Export Ledger'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.gold,
                foregroundColor: AppColors.navyDeep,
                textStyle: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              ),
            ),
          ],
        ),

        // Bursary Audit Desk Banner (Entry point to Screen 04fcd5d0)
        Container(
          margin: const EdgeInsets.only(top: 14, bottom: 4),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFF13204D),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.gold, width: 1.2),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.gold.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.verified_outlined, color: AppColors.gold, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _clarisseCleared
                          ? 'Bursary Audit Desk • 13 Slips Pending'
                          : 'Bursary Audit Desk • 14 Slips Pending',
                      style: const TextStyle(
                        color: AppColors.onNavy,
                        fontWeight: FontWeight.bold,
                        fontSize: 13.5,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _clarisseCleared
                          ? '3,200,000 XAF awaiting teller validation • 29 Slips Cleared Today'
                          : '3,450,000 XAF awaiting teller validation (UBA & Afriland)',
                      style: const TextStyle(color: AppColors.muted, fontSize: 11),
                    ),
                  ],
                ),
              ),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.gold,
                  foregroundColor: AppColors.navyDeep,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: () => setState(() => _showBursaryVerificationScreen = true),
                icon: const Icon(Icons.open_in_new, size: 14),
                label: const Text('Open Desk', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Summary Card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF13204D),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border.withValues(alpha: 0.6)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('TOTAL TUITION EXPECTED', style: TextStyle(color: AppColors.muted, fontSize: 10.5, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              const Text('640,000,000 FCFA', style: TextStyle(color: AppColors.onNavy, fontSize: 24, fontWeight: FontWeight.w800)),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: const LinearProgressIndicator(
                  value: 0.864,
                  minHeight: 8,
                  backgroundColor: AppColors.surface,
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4ADE80)),
                ),
              ),
              const SizedBox(height: 10),
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Collected: 553,200,000 FCFA (86.4%)', style: TextStyle(color: Color(0xFF4ADE80), fontSize: 11, fontWeight: FontWeight.bold)),
                  Text('Outstanding: 86,800,000 FCFA', style: TextStyle(color: Color(0xFFFBBF24), fontSize: 11, fontWeight: FontWeight.w600)),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // Channels Breakdown
        const Text(
          'PAYMENT GATEWAYS IN CAMEROON',
          style: TextStyle(color: AppColors.muted, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.8),
        ),
        const SizedBox(height: 10),

        Row(
          children: [
            Expanded(
              child: _buildGatewayBox('MTN MoMo', '198.4M FCFA', Icons.phone_android, const Color(0xFFFBBF24)),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildGatewayBox('Orange Money', '162.1M FCFA', Icons.smartphone, const Color(0xFFF97316)),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _buildGatewayBox('UBA Cameroon', '120.5M FCFA', Icons.account_balance, const Color(0xFFEF4444)),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildGatewayBox('Afriland Bank', '72.2M FCFA', Icons.account_balance_wallet, const Color(0xFF3B82F6)),
            ),
          ],
        ),

        const SizedBox(height: 24),

        // Transaction Ledger
        const Text(
          'RECENT CLEARANCE TRANSACTIONS',
          style: TextStyle(color: AppColors.muted, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.8),
        ),
        const SizedBox(height: 10),

        ...transactions.map((tx) => _buildTransactionCard(tx)),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildGatewayBox(String name, String amount, IconData icon, Color iconColor) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF13204D),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(color: AppColors.onNavy, fontSize: 11, fontWeight: FontWeight.bold)),
                Text(amount, style: const TextStyle(color: AppColors.muted, fontSize: 10)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionCard(_AdminTransactionRecord tx) {
    final isCleared = tx.status.contains('Verified');
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF13204D),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: isCleared ? const Color(0xFF152A20) : const Color(0xFF33200D),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              isCleared ? Icons.check_circle_outline : Icons.pending_actions_outlined,
              color: isCleared ? const Color(0xFF4ADE80) : const Color(0xFFFBBF24),
              size: 18,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      tx.studentName,
                      style: const TextStyle(color: AppColors.onNavy, fontSize: 12.5, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '${tx.amount.toStringAsFixed(0)} FCFA',
                      style: const TextStyle(color: AppColors.gold, fontSize: 12.5, fontWeight: FontWeight.w800),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${tx.channel} • ${tx.txId}',
                      style: const TextStyle(color: AppColors.muted, fontSize: 10),
                    ),
                    Text(
                      tx.date,
                      style: const TextStyle(color: AppColors.muted, fontSize: 10),
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

  // ---------------------------------------------------------------------------
  // TAB 4: TIMETABLE & VENUES (Admin & Super Admin)
  // ---------------------------------------------------------------------------

  Widget _buildAdminTimetableTab(DashboardData data) {
    final venues = [
      ('Amphitheatre 1', 'Main Academic Complex', 'Capacity: 350 seats', Icons.corporate_fare),
      ('Amphitheatre 2', 'Science & Tech Wing', 'Capacity: 250 seats', Icons.school),
      ('Hall B-104', 'Engineering Complex', 'Capacity: 120 seats', Icons.meeting_room),
      ('Computing Lab 1', 'ICT Innovation Centre', '60 Workstations', Icons.computer),
    ];

    final schedule = [
      ('Monday 08:00 - 10:00', 'SWE101 - Introduction to Programming', 'Amphitheatre 1', 'Level 100 (Year 1)'),
      ('Monday 10:30 - 12:30', 'SWE201 - Data Structures & Algorithms', 'Hall B-104', 'Level 200 (Year 2)'),
      ('Tuesday 08:00 - 10:00', 'SWE203 - Object Oriented Design', 'Computing Lab 1', 'Level 200 (Year 2)'),
      ('Tuesday 14:00 - 16:00', 'CEF205 - Computer Architecture', 'Amphitheatre 2', 'Level 200 (Year 2)'),
      ('Wednesday 09:00 - 11:00', 'MAT201 - Discrete Mathematics', 'Amphitheatre 1', 'Level 200 (Year 2)'),
      ('Thursday 10:00 - 12:00', 'ICT207 - Web Technologies & APIs', 'Computing Lab 1', 'Level 200 (Year 2)'),
      ('Friday 08:00 - 10:00', 'LAW204 - Cyber Law & Professional Ethics', 'Amphitheatre 2', 'Level 200 (Year 2)'),
    ];

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      children: [
        const Text(
          'Timetable & Campus Venues',
          style: TextStyle(
            color: AppColors.onNavy,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
        const Text(
          'Lecture Hall Allocations & Examination Shifts • Semester 1',
          style: TextStyle(color: AppColors.gold, fontSize: 11, fontWeight: FontWeight.w600),
        ),

        const SizedBox(height: 16),

        const Text(
          'CAMPUS VENUE ALLOCATION',
          style: TextStyle(color: AppColors.muted, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.8),
        ),
        const SizedBox(height: 10),

        LayoutBuilder(
          builder: (context, constraints) {
            final cardWidth = constraints.maxWidth > 500
                ? (constraints.maxWidth - 12) / 2
                : constraints.maxWidth;

            return Wrap(
              spacing: 12,
              runSpacing: 10,
              children: venues.map((v) {
                return Container(
                  width: cardWidth,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF13204D),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: AppColors.gold.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(v.$4, color: AppColors.gold, size: 18),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(v.$1, style: const TextStyle(color: AppColors.onNavy, fontSize: 12.5, fontWeight: FontWeight.bold)),
                            Text('${v.$2} • ${v.$3}', style: const TextStyle(color: AppColors.muted, fontSize: 10)),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            );
          },
        ),

        const SizedBox(height: 24),

        const Text(
          'SEMESTER 1 MASTER LECTURE SCHEDULE',
          style: TextStyle(color: AppColors.muted, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.8),
        ),
        const SizedBox(height: 10),

        ...schedule.map((s) {
          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF13204D),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.schedule, color: AppColors.gold, size: 18),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        s.$2,
                        style: const TextStyle(color: AppColors.onNavy, fontSize: 13, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 3),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('${s.$1} • ${s.$3}', style: const TextStyle(color: AppColors.muted, fontSize: 11)),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                            decoration: BoxDecoration(
                              color: AppColors.gold.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              s.$4,
                              style: const TextStyle(color: AppColors.gold, fontSize: 9.5, fontWeight: FontWeight.bold),
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
        }),
        const SizedBox(height: 20),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // ADMIN INTERACTIVE MODALS & DIALOGS
  // ---------------------------------------------------------------------------

  void _showSenateBroadsheetDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.navyDeep,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Senate Examination Broadsheet Audit',
          style: TextStyle(color: AppColors.onNavy, fontSize: 16, fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'All Level 100 & Level 200 courses are computed using the Cameroon Senate standard:\n\n'
          '• Continuous Assessment (CA): 30 Marks\n'
          '• Terminal Examination: 70 Marks\n'
          '• Minimum Pass Threshold: 50.0% (Grade C, GPA 2.00)\n'
          '• Scores below 40.0% are scheduled for Session de Rattrapage (Resit).\n\n'
          'Status: 98.4% of Continuous Assessment sheets are uploaded by faculty.',
          style: TextStyle(color: AppColors.muted, fontSize: 12.5, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close', style: TextStyle(color: AppColors.gold)),
          ),
        ],
      ),
    );
  }

  void _showResitSessionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.navyDeep,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Session de Rattrapage (Resit Schedule)',
          style: TextStyle(color: AppColors.onNavy, fontSize: 16, fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'The Catch-up / Resit session is scheduled for February 2027 following the first semester examinations board.\n\n'
          'Students with marks between 35.0% and 49.9% are eligible to resit eligible course units at 5,000 FCFA per credit value.',
          style: TextStyle(color: AppColors.muted, fontSize: 12.5, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Dismiss', style: TextStyle(color: AppColors.gold)),
          ),
        ],
      ),
    );
  }

  void _showSystemSecurityDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.navyDeep,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Super Admin Security Audit',
          style: TextStyle(color: AppColors.onNavy, fontSize: 16, fontWeight: FontWeight.bold),
        ),
        content: const Text(
          '✓ Database Row-Level Security (RLS) is Active.\n'
          '✓ Role-Based Access Control (RBAC) enforced on server.\n'
          '✓ Zero backdoor role switches permitted.\n'
          '✓ HTTPS TLS 1.3 encrypted session tokens.',
          style: TextStyle(color: AppColors.muted, fontSize: 12.5, height: 1.6),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Done', style: TextStyle(color: AppColors.gold)),
          ),
        ],
      ),
    );
  }

  void _showAddStudentModal(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.navyDeep,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Enrol New Student',
          style: TextStyle(color: AppColors.onNavy, fontSize: 16, fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'To enrol a student and assign an official matricule (e.g. FAH/24/SWE/xxxx), register the applicant through the official Cameroon admissions portal or run the database migration script.',
          style: TextStyle(color: AppColors.muted, fontSize: 12.5, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('OK', style: TextStyle(color: AppColors.gold)),
          ),
        ],
      ),
    );
  }

  void _showStudentDetailsModal(BuildContext context, _AdminStudentRecord s) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.navyDeep,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  s.name,
                  style: const TextStyle(color: AppColors.onNavy, fontSize: 17, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: AppColors.muted),
                  onPressed: () => Navigator.pop(ctx),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              '${s.matricule} • ${s.level} • ${s.program}',
              style: const TextStyle(color: AppColors.gold, fontSize: 11.5, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 14),
            Text(
              '• Cumulative GPA: ${s.gpa.toStringAsFixed(2)} / 4.00 (${s.standing})\n'
              '• Fee Status: ${s.feeStatus} (${s.feePaid.toStringAsFixed(0)} / ${s.feeTotal.toStringAsFixed(0)} FCFA)\n'
              '• Enrolled Modules: SWE201, SWE203, CEF205, ICT207, MAT201, ENG202\n'
              '• Campus: Cameroon Main Campus (Yaoundé / Douala)',
              style: const TextStyle(color: AppColors.muted, fontSize: 12.5, height: 1.6),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _showAuditReportDownloadDialog(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('✓ Official 2026/2027 Tuition Ledger exported successfully (FCFA).'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _handleSignOut() async {
    final onSignOut = widget.onSignOut;
    if (onSignOut == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sign out is not available yet.')),
      );
      return;
    }
    await onSignOut();
  }
}

// ---------------------------------------------------------------------------
// HELPER MODELS & SUPPORTING WIDGETS
// ---------------------------------------------------------------------------

class _AdminStudentRecord {
  final String name;
  final String matricule;
  final String level;
  final String program;
  final String feeStatus;
  final double feePaid;
  final double feeTotal;
  final double gpa;
  final String standing;

  const _AdminStudentRecord({
    required this.name,
    required this.matricule,
    required this.level,
    required this.program,
    required this.feeStatus,
    required this.feePaid,
    required this.feeTotal,
    required this.gpa,
    required this.standing,
  });
}

class _AdminTransactionRecord {
  final String txId;
  final String date;
  final String studentName;
  final String matricule;
  final String channel;
  final double amount;
  final String status;

  const _AdminTransactionRecord({
    required this.txId,
    required this.date,
    required this.studentName,
    required this.matricule,
    required this.channel,
    required this.amount,
    required this.status,
  });
}

class _StudentCourseModel {
  final String code;
  final int credits;
  final String type;
  final String title;
  final String instructor;
  final String prereq;
  final bool isLocked;
  final String? lockReason;

  const _StudentCourseModel({
    required this.code,
    required this.credits,
    required this.type,
    required this.title,
    required this.instructor,
    required this.prereq,
    this.isLocked = false,
    this.lockReason,
  });
}

class _FacultyStudentGradeModel {
  final String initials;
  final String name;
  final String matricule;
  final String status;
  final double caScore;
  final double? examScore;
  final double? total;
  final String? grade;
  final double? points;
  final String? trailingAction;
  final IconData? trailingIcon;
  final String? warningMessage;

  const _FacultyStudentGradeModel({
    required this.initials,
    required this.name,
    required this.matricule,
    required this.status,
    required this.caScore,
    this.examScore,
    this.total,
    this.grade,
    this.points,
    this.trailingAction,
    this.trailingIcon,
    this.warningMessage,
  });
}

class _DashboardLoadError extends StatelessWidget {

  const _DashboardLoadError({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48, color: AppColors.gold),
            const SizedBox(height: 16),
            const Text(
              'Unable to load dashboard',
              style: TextStyle(
                color: AppColors.onNavy,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Check your connection and try again.',
              style: TextStyle(color: AppColors.muted),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.gold,
                foregroundColor: AppColors.navyDeep,
              ),
              onPressed: onRetry,
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
