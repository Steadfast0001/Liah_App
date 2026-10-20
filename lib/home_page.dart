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
  _SidebarDestination _selectedDestination = _SidebarDestination.dashboard;
  bool _isSidebarCollapsed = false;

  // Student mobile 4-tab index: 0: Home, 1: Academics, 2: Fees, 3: Results
  int _studentTabIndex = 0;

  // Academics filter state
  int _academicsFilterIndex = 0; // 0: All (6), 1: Core (4), 2: Electives (2)
  String _academicsSearchQuery = '';

  // Registration selection state
  final Set<String> _selectedCourseCodes = {'SW201', 'SW203', 'SW205'};

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

        // Student Portal Mobile Experience (Matching uploaded designs)
        if (data.role == DashboardRole.student) {
          return _buildStudentPortalScaffold(data);
        }

        // Admin & Lecturer Experience
        final isWide = MediaQuery.sizeOf(context).width >= 760;
        return Scaffold(
          backgroundColor: AppColors.navy,
          drawer: Drawer(
            width: _isSidebarCollapsed ? 72 : 144,
            backgroundColor: AppColors.navyDeep,
            child: SafeArea(child: _buildSidebar()),
          ),
          body: Row(
            children: [
              if (isWide)
                SizedBox(
                  width: _isSidebarCollapsed ? 72 : 144,
                  child: _buildSidebar(),
                ),
              Expanded(child: _buildAdminContent(data, isWide: isWide)),
            ],
          ),
        );
      },
    );
  }

  // ---------------------------------------------------------------------------
  // STUDENT 4-TAB PORTAL SCAFFOLD
  // ---------------------------------------------------------------------------

  Widget _buildStudentPortalScaffold(DashboardData data) {
    const tabSectionNames = ['DASHBOARD', 'ACADEMICS', 'FEES', 'RESULTS'];
    final currentSection = tabSectionNames[_studentTabIndex];

    return Scaffold(
      backgroundColor: AppColors.navy,
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
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
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'FAH ACADEMY',
                    style: TextStyle(
                      color: AppColors.onNavy,
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    '2026/2027 • S1 • $currentSection',
                    style: const TextStyle(
                      color: AppColors.gold,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
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
                        content: Text('No unread urgent notifications.'),
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
                    width: 8,
                    height: 8,
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
              tooltip: 'Profile Menu',
              color: AppColors.surface,
              onSelected: (val) {
                if (val == 'signout') {
                  _handleSignOut();
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
                        data.userId,
                        style: const TextStyle(
                          color: AppColors.muted,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                const PopupMenuDivider(),
                const PopupMenuItem(
                  value: 'signout',
                  child: Row(
                    children: [
                      Icon(Icons.logout, color: AppColors.gold, size: 18),
                      SizedBox(width: 8),
                      Text('Sign out', style: TextStyle(color: AppColors.gold)),
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
                      text: 'XAF',
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
                    'Settled: 450,000 XAF',
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
                            '650,000 XAF',
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
                                '450,000 XAF',
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
                          'Platform Charge: 25,000 XAF',
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
          amount: '250,000 XAF',
          badgeText: 'Paid & Verified',
          isPaid: true,
        ),
        const SizedBox(height: 10),

        _buildMilestoneCard(
          number: '2',
          title: 'Mid-term CA & Lab Access',
          dueDate: 'Due Nov 10, 2026 • Continuous assessments evaluated',
          amount: '200,000 XAF',
          badgeText: 'Paid & Verified',
          isPaid: true,
        ),
        const SizedBox(height: 10),

        _buildMilestoneCard(
          number: '3',
          title: 'Final Exam & Results Publication',
          dueDate: 'Due Jan 15, 2027',
          amount: '200,000 XAF',
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
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Downloading Official Statement PDF...')),
            );
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
          amount: '100,000 XAF',
          status: 'Under Admin Review',
          statusColor: AppColors.gold,
          note: 'Awaiting Bursar validation. Does not clear active dues yet.',
          icon: Icons.receipt_outlined,
        ),
        const SizedBox(height: 8),

        _buildAuditLogCard(
          ref: 'Ref #UB-8829401',
          dateDesc: 'Oct 28, 2026 • UBA Wire Transfer',
          amount: '200,000 XAF',
          status: 'Verified',
          statusColor: Colors.greenAccent,
          auditor: 'Audited by Bursar: A. Mbarga',
          icon: Icons.check_circle_outline,
        ),
        const SizedBox(height: 8),

        _buildAuditLogCard(
          ref: 'Ref #AF-3910284',
          dateDesc: 'Sep 12, 2026 • Afriland First Teller',
          amount: '250,000 XAF',
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
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Downloading Official Result Slip (PDF)...')),
            );
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
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // ADMIN & LECTURER VIEW
  // ---------------------------------------------------------------------------

  Widget _buildAdminContent(DashboardData data, {required bool isWide}) {
    return Column(
      children: [
        _AdminTopBar(
          displayName: data.displayName,
          userId: data.userId,
          showMenu: !isWide,
          onMenuTap: () => Scaffold.of(context).openDrawer(),
        ),
        Expanded(child: _buildAdminDashboard(data)),
      ],
    );
  }

  Widget _buildAdminDashboard(DashboardData data) {
    final actions = _actionsFor(data.role);
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          'Good day, ${data.displayName}',
          style: const TextStyle(
            color: AppColors.onNavy,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '${data.role.label} dashboard',
          style: const TextStyle(color: AppColors.muted, fontSize: 14),
        ),
        const SizedBox(height: 24),
        const _SectionHeading('Quick Actions'),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: actions.length,
          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 220,
            crossAxisSpacing: 12,
            mainAxisSpacing: 10,
            mainAxisExtent: 72,
          ),
          itemBuilder: (context, index) {
            final action = actions[index];
            return _DashboardActionTile(
              action: action,
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('${action.title} selected.')),
                );
              },
            );
          },
        ),
        const SizedBox(height: 24),
        const _SectionHeading('System Metrics'),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: data.metrics
              .map(
                (metric) => SizedBox(
                  width: 160,
                  child: _MetricTile(metric: metric),
                ),
              )
              .toList(),
        ),
        const SizedBox(height: 24),
        const _SectionHeading('System Notices'),
        const SizedBox(height: 8),
        ...data.notifications.map(
          (notification) => _NotificationRow(notification: notification),
        ),
      ],
    );
  }

  Widget _buildSidebar() {
    return _DashboardSidebar(
      selectedDestination: _selectedDestination,
      isCollapsed: _isSidebarCollapsed,
      onDestinationSelected: (destination) {
        setState(() => _selectedDestination = destination);
      },
      onToggleCollapsed: () {
        setState(() => _isSidebarCollapsed = !_isSidebarCollapsed);
      },
      onSignOut: _handleSignOut,
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

class _AdminTopBar extends StatelessWidget {
  const _AdminTopBar({
    required this.displayName,
    required this.userId,
    required this.showMenu,
    required this.onMenuTap,
  });

  final String displayName;
  final String userId;
  final bool showMenu;
  final VoidCallback onMenuTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      color: AppColors.navyDeep,
      child: Row(
        children: [
          if (showMenu) ...[
            IconButton(
              icon: const Icon(Icons.menu, color: AppColors.onNavy),
              onPressed: onMenuTap,
            ),
            const SizedBox(width: 8),
          ],
          const Text(
            'LIAH ACADEMY SMS',
            style: TextStyle(
              color: AppColors.onNavy,
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          Text(
            displayName,
            style: const TextStyle(
              color: AppColors.onNavy,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 8),
          CircleAvatar(
            radius: 14,
            backgroundColor: AppColors.surface,
            child: Text(
              displayName.isNotEmpty ? displayName[0].toUpperCase() : 'A',
              style: const TextStyle(color: AppColors.gold, fontSize: 11),
            ),
          ),
        ],
      ),
    );
  }
}

enum _SidebarDestination {
  dashboard('Dashboard', Icons.dashboard_outlined),
  registration('Registration', Icons.assignment_outlined),
  courses('Courses', Icons.menu_book_outlined),
  results('Results', Icons.bar_chart_outlined),
  finance('Finance', Icons.account_balance_wallet_outlined),
  timetable('Timetable', Icons.calendar_month_outlined),
  attendance('Attendance', Icons.fact_check_outlined),
  settings('Settings', Icons.settings_outlined);

  const _SidebarDestination(this.label, this.icon);

  final String label;
  final IconData icon;
}

class _DashboardSidebar extends StatelessWidget {
  const _DashboardSidebar({
    required this.selectedDestination,
    required this.isCollapsed,
    required this.onDestinationSelected,
    required this.onToggleCollapsed,
    required this.onSignOut,
  });

  final _SidebarDestination selectedDestination;
  final bool isCollapsed;
  final ValueChanged<_SidebarDestination> onDestinationSelected;
  final VoidCallback onToggleCollapsed;
  final Future<void> Function() onSignOut;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.navyDeep,
      child: Column(
        children: [
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              mainAxisAlignment: isCollapsed
                  ? MainAxisAlignment.center
                  : MainAxisAlignment.start,
              children: [
                Image.asset('assets/images/logo.png', width: 28, height: 28),
                if (!isCollapsed) ...[
                  const SizedBox(width: 8),
                  const Text(
                    'LIAH',
                    style: TextStyle(
                      color: AppColors.onNavy,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),
          ..._SidebarDestination.values.map(
            (d) => _SidebarItem(
              destination: d,
              selected: selectedDestination == d,
              isCollapsed: isCollapsed,
              onTap: () => onDestinationSelected(d),
            ),
          ),
          const Spacer(),
          _SidebarFooterAction(
            icon: Icons.logout,
            label: 'Sign out',
            isCollapsed: isCollapsed,
            color: AppColors.gold,
            onTap: onSignOut,
          ),
          _SidebarFooterAction(
            icon: isCollapsed ? Icons.chevron_right : Icons.chevron_left,
            label: isCollapsed ? 'Expand' : 'Collapse',
            isCollapsed: isCollapsed,
            onTap: onToggleCollapsed,
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _SidebarItem extends StatelessWidget {
  const _SidebarItem({
    required this.destination,
    required this.selected,
    required this.isCollapsed,
    required this.onTap,
  });

  final _SidebarDestination destination;
  final bool selected;
  final bool isCollapsed;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: isCollapsed ? 0 : 10,
            vertical: 8,
          ),
          decoration: BoxDecoration(
            color: selected ? AppColors.surfaceRaised : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Row(
            mainAxisAlignment: isCollapsed
                ? MainAxisAlignment.center
                : MainAxisAlignment.start,
            children: [
              Icon(
                destination.icon,
                color: selected ? AppColors.gold : AppColors.muted,
                size: 18,
              ),
              if (!isCollapsed) ...[
                const SizedBox(width: 8),
                Text(
                  destination.label,
                  style: TextStyle(
                    color: selected ? AppColors.onNavy : AppColors.muted,
                    fontSize: 12,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _SidebarFooterAction extends StatelessWidget {
  const _SidebarFooterAction({
    required this.icon,
    required this.label,
    required this.isCollapsed,
    required this.onTap,
    this.color = AppColors.muted,
  });

  final IconData icon;
  final String label;
  final bool isCollapsed;
  final VoidCallback onTap;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: isCollapsed ? 0 : 10,
            vertical: 8,
          ),
          child: Row(
            mainAxisAlignment: isCollapsed
                ? MainAxisAlignment.center
                : MainAxisAlignment.start,
            children: [
              Icon(icon, color: color, size: 16),
              if (!isCollapsed) ...[
                const SizedBox(width: 8),
                Text(label, style: TextStyle(color: color, fontSize: 11)),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _DashboardAction {
  final String title;
  final String description;
  final IconData icon;

  const _DashboardAction(this.title, this.description, this.icon);
}

List<_DashboardAction> _actionsFor(DashboardRole role) => switch (role) {
  DashboardRole.student => const [],
  DashboardRole.teacher => const [
    _DashboardAction(
      'View Assigned Courses',
      'Open your teaching schedule',
      Icons.menu_book_outlined,
    ),
    _DashboardAction(
      'Upload Grades',
      'Submit student assessment results',
      Icons.grade_outlined,
    ),
    _DashboardAction(
      'Manage Attendance',
      'Update class attendance',
      Icons.fact_check_outlined,
    ),
    _DashboardAction(
      'Message Students',
      'Communicate with your classes',
      Icons.forum_outlined,
    ),
  ],
  DashboardRole.admin => const [
    _DashboardAction(
      'Approve Admissions',
      'Review pending applications',
      Icons.how_to_reg_outlined,
    ),
    _DashboardAction(
      'Verify Payments',
      'Review pending transactions',
      Icons.verified_outlined,
    ),
    _DashboardAction(
      'Manage Programs',
      'Create and update programs',
      Icons.menu_book_outlined,
    ),
    _DashboardAction(
      'Generate Reports',
      'Review academy performance',
      Icons.summarize_outlined,
    ),
    _DashboardAction(
      'Send Announcements',
      'Share updates with the academy',
      Icons.campaign_outlined,
    ),
  ],
  DashboardRole.superAdmin => const [
    _DashboardAction(
      'System Configuration',
      'Manage institution settings & roles',
      Icons.settings_suggest_outlined,
    ),
    _DashboardAction(
      'Manage Admins',
      'Create and manage admin accounts',
      Icons.admin_panel_settings_outlined,
    ),
    _DashboardAction(
      'Configure Fees',
      'Set tuition and payment structures',
      Icons.price_change_outlined,
    ),
    _DashboardAction(
      'Publish Final Results',
      'Approve and publish school grades',
      Icons.published_with_changes_outlined,
    ),
    _DashboardAction(
      'Audit Logs',
      'View system-wide security actions',
      Icons.receipt_long_outlined,
    ),
  ],
  DashboardRole.parent => const [
    _DashboardAction(
      'Monitor Student Progress',
      'Review grades and attendance',
      Icons.insights_outlined,
    ),
    _DashboardAction(
      'Fee Reminders',
      'Review upcoming payment dates',
      Icons.notifications_active_outlined,
    ),
  ],
};

class _SectionHeading extends StatelessWidget {
  const _SectionHeading(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        color: AppColors.onNavy,
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

class _MetricTile extends StatelessWidget {
  const _MetricTile({required this.metric});

  final DashboardMetric metric;

  @override
  Widget build(BuildContext context) {
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
          Icon(metric.icon, color: AppColors.gold, size: 20),
          const SizedBox(height: 8),
          Text(
            metric.value,
            style: const TextStyle(
              color: AppColors.onNavy,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            metric.label,
            style: const TextStyle(color: AppColors.muted, fontSize: 11),
          ),
        ],
      ),
    );
  }
}

class _DashboardActionTile extends StatelessWidget {
  const _DashboardActionTile({
    required this.action,
    required this.onTap,
  });

  final _DashboardAction action;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          child: Row(
            children: [
              Icon(action.icon, color: AppColors.gold, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  action.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.onNavy,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NotificationRow extends StatelessWidget {
  const _NotificationRow({required this.notification});

  final DashboardNotification notification;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.info_outline,
            color: AppColors.gold,
            size: 16,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  notification.title,
                  style: const TextStyle(
                    color: AppColors.onNavy,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  notification.message,
                  style: const TextStyle(color: AppColors.muted, fontSize: 11),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
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
