import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:liah_app/course_registration_page.dart';
import 'package:liah_app/dashboard_data.dart';
import 'package:liah_app/student_academics_page.dart';
import 'package:liah_app/student_announcements_page.dart';
import 'package:liah_app/student_attendance_page.dart';
import 'package:liah_app/student_dashboard_page.dart';
import 'package:liah_app/student_documents_page.dart';
import 'package:liah_app/student_fees_page.dart';
import 'package:liah_app/student_notifications_page.dart';
import 'package:liah_app/student_profile_page.dart';
import 'package:liah_app/student_results_page.dart';
import 'package:liah_app/student_settings_page.dart';
import 'package:liah_app/student_timetable_page.dart';

void main() {
  setUp(() {
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  group('4. Student Dashboard and Pages Tests', () {
    setUp(() {
      // Set larger viewport to avoid ListView.builder virtualization clipping
    });

    // -------------------------------------------------------------------------
    // 1. student_dashboard_page.dart
    // -------------------------------------------------------------------------
    testWidgets('StudentDashboardPage renders all required UI elements and actions',
        (tester) async {
      tester.view.physicalSize = const Size(1280, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      const demoData = DashboardData(
        role: DashboardRole.student,
        displayName: 'Martin Ngono',
        userId: 'LIAH-2024-SW0482',
        metrics: [],
        notifications: [],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StudentDashboardPage(data: demoData),
          ),
        ),
      );

      // Greeting, Matricule, Program
      expect(find.textContaining('Martin'), findsWidgets);
      expect(find.text('LIAH-2024-SW0482'), findsOneWidget);
      expect(find.textContaining('B.Eng Software Engineering'), findsOneWidget);

      // Academic Summary & GPA
      expect(find.text('ACADEMIC SUMMARY'), findsOneWidget);
      expect(find.text('3.68'), findsOneWidget);

      // Status Banners
      expect(find.text('Registration'), findsWidgets);
      expect(find.text('Fee Clearance'), findsOneWidget);

      // Next Class Card
      expect(find.text('NEXT UPCOMING CLASS'), findsOneWidget);
      expect(find.textContaining('SWE201'), findsWidgets);

      // Quick Actions
      expect(find.text('Registration'), findsWidgets);
      expect(find.text('Timetable'), findsWidgets);
      expect(find.text('Attendance'), findsOneWidget);
      expect(find.text('Fees (XAF)'), findsOneWidget);
      expect(find.text('Results & GPA'), findsOneWidget);
      expect(find.text('Documents'), findsOneWidget);

      // Announcements Preview
      expect(find.text('ACADEMIC ANNOUNCEMENTS'), findsOneWidget);
      expect(find.textContaining('Continuous Assessment'), findsWidgets);
    });

    // -------------------------------------------------------------------------
    // 2. student_profile_page.dart
    // -------------------------------------------------------------------------
    testWidgets('StudentProfilePage renders profile, locked details, and edit dialog',
        (tester) async {
      tester.view.physicalSize = const Size(1280, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        const MaterialApp(
          home: StudentProfilePage(),
        ),
      );

      expect(find.text('Martin Ngono'), findsOneWidget);
      expect(find.text('MATRICULE: LIAH-2024-SW0482'), findsOneWidget);
      expect(find.text('ACADEMIC ENROLLMENT DETAILS (LOCKED)'), findsOneWidget);
      expect(find.text('CONTACT DETAILS (PERMITTED TO EDIT)'), findsOneWidget);
      expect(find.text('GUARDIAN & SPONSOR INFORMATION'), findsOneWidget);

      // Open Edit Contact Details
      await tester.tap(find.text('Edit'));
      await tester.pumpAndSettle();

      expect(find.text('Edit Contact Details'), findsOneWidget);
      expect(find.text('Phone Number'), findsOneWidget);

      // Save Changes
      await tester.tap(find.text('Save Changes'));
      await tester.pumpAndSettle();

      expect(find.text('Contact details updated successfully'), findsOneWidget);
    });

    // -------------------------------------------------------------------------
    // 3. student_academics_page.dart
    // -------------------------------------------------------------------------
    testWidgets('StudentAcademicsPage renders semester tabs, courses, and credits',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: StudentAcademicsPage(),
        ),
      );

      expect(find.text('Academics & Courses'), findsOneWidget);
      expect(find.text('First Semester'), findsOneWidget);
      expect(find.text('Second Semester'), findsOneWidget);
      expect(find.text('6 Registered Courses'), findsOneWidget);
      expect(find.text('24 Total Credits'), findsOneWidget);
      expect(find.textContaining('SWE201'), findsWidgets);

      // Switch semester tab
      await tester.tap(find.text('Second Semester'));
      await tester.pumpAndSettle();

      expect(find.text('5 Registered Courses'), findsOneWidget);
      expect(find.textContaining('SWE202'), findsWidgets);
    });

    // -------------------------------------------------------------------------
    // 4. course_registration_page.dart
    // -------------------------------------------------------------------------
    testWidgets(
        'CourseRegistrationPage displays deadline, state distinctions, credit calculation, and confirmation dialog',
        (tester) async {
      tester.view.physicalSize = const Size(1280, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        const MaterialApp(
          home: CourseRegistrationPage(),
        ),
      );

      // 1. Visible deadline
      expect(find.textContaining('Deadline: 15 November 2026'), findsOneWidget);

      // 2. Clear state distinctions
      expect(find.text('Registered'), findsWidgets);
      expect(find.text('Selected'), findsWidgets);
      expect(find.text('Prerequisite Blocked'), findsOneWidget);
      expect(find.text('Closed'), findsOneWidget);

      // 3. Total Credits Display
      expect(find.textContaining('/ 30 Credit Units'), findsOneWidget);

      // 4. Inspect Prerequisite details modal
      await tester.tap(find.textContaining('Prereq: SWE201'));
      await tester.pumpAndSettle();

      expect(find.text('Prerequisite Requirement'), findsOneWidget);
      expect(find.text('Understood'), findsOneWidget);
      await tester.tap(find.text('Understood'));
      await tester.pumpAndSettle();

      // 5. Submit Course Registration Confirmation Dialog
      expect(find.text('Submit Registration'), findsOneWidget);
      await tester.tap(find.text('Submit Registration'));
      await tester.pumpAndSettle();

      expect(find.text('Confirm Course Registration'), findsOneWidget);
      expect(find.text('Confirm & Submit'), findsOneWidget);

      await tester.tap(find.text('Confirm & Submit'));
      await tester.pump(const Duration(milliseconds: 900));
      await tester.pumpAndSettle();

      expect(find.textContaining('validated with registry'), findsOneWidget);
    });

    // -------------------------------------------------------------------------
    // 5. student_timetable_page.dart
    // -------------------------------------------------------------------------
    testWidgets('StudentTimetablePage toggles views and displays schedules',
        (tester) async {
      tester.view.physicalSize = const Size(1280, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        const MaterialApp(
          home: StudentTimetablePage(),
        ),
      );

      expect(find.text('Timetable & Schedule'), findsOneWidget);
      expect(find.textContaining('Current Week'), findsOneWidget);
      expect(find.text('Monday'), findsOneWidget);
      expect(find.text('Tuesday'), findsOneWidget);
      expect(find.textContaining('Schedule Notice:'), findsOneWidget);

      // Toggle to week view
      await tester.tap(find.byIcon(Icons.view_week_outlined));
      await tester.pumpAndSettle();

      expect(find.text('Friday'), findsWidgets);
    });

    // -------------------------------------------------------------------------
    // 6. student_attendance_page.dart
    // -------------------------------------------------------------------------
    testWidgets('StudentAttendancePage displays MINESUP 75% rule and session records',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: StudentAttendancePage(),
        ),
      );

      expect(find.text('Attendance Records'), findsOneWidget);
      expect(find.textContaining('MINESUP Regulation: Minimum 75%'), findsOneWidget);
      expect(find.text('COURSE ATTENDANCE RATIOS'), findsOneWidget);
      expect(find.text('LOGGED SESSIONS'), findsOneWidget);
      expect(find.text('SWE201'), findsWidgets);
    });

    // -------------------------------------------------------------------------
    // 7. student_fees_page.dart
    // -------------------------------------------------------------------------
    testWidgets('StudentFeesPage formats XAF, separates verified vs pending, and shows milestones',
        (tester) async {
      tester.view.physicalSize = const Size(1280, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        const MaterialApp(
          home: StudentFeesPage(),
        ),
      );

      // Consistent XAF formatting
      expect(find.text('100000 XAF'), findsWidgets); // Outstanding balance & payment items
      expect(find.textContaining('XAF'), findsWidgets);

      // Milestones
      expect(find.textContaining('EXAMINATION & REGISTRATION ACCESS MILESTONES'), findsOneWidget);
      expect(find.textContaining('Phase 1: Course Registration'), findsOneWidget);
      expect(find.textContaining('Phase 2: CA & Exam Slip Access'), findsOneWidget);

      // Verified vs Pending Separation
      expect(find.text('Verified & Audited'), findsNWidgets(2));
      expect(find.text('Pending Bursary Verification'), findsOneWidget);
      expect(find.textContaining('50000 XAF Pending'), findsOneWidget);

      // Open Payment Channels
      await tester.tap(find.text('Pay Fees (XAF)'));
      await tester.pumpAndSettle();

      expect(find.text('Official Cameroon Payment Channels'), findsOneWidget);
      expect(find.textContaining('MTN Mobile Money'), findsWidgets);
      expect(find.textContaining('Orange Money'), findsWidgets);
      expect(find.textContaining('Afriland First Bank'), findsWidgets);
    });

    // -------------------------------------------------------------------------
    // 8. student_results_page.dart
    // -------------------------------------------------------------------------
    testWidgets(
        'StudentResultsPage distinguishes published/unpublished states and displays separate resit attempts',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: StudentResultsPage(),
        ),
      );

      // Published Semester: 2025/2026 Semester 2
      expect(find.text('3.68'), findsOneWidget); // Actual GPA
      expect(find.text('OFFICIAL COURSE SCORES'), findsOneWidget);

      // Failed attempt and separate resit attempt
      expect(find.textContaining('Normal Session (Initial Attempt)'), findsOneWidget);
      expect(find.textContaining('Rattrapage / Resit Attempt'), findsOneWidget);

      // Switch to unpublished semester: 2026/2027 Semester 1
      await tester.tap(find.text('2025/2026 Semester 2').last);
      await tester.pumpAndSettle();

      await tester.tap(find.text('2026/2027 Semester 1').last);
      await tester.pumpAndSettle();

      // Does NOT fabricate GPA
      expect(find.text('— (Pending)'), findsOneWidget);
      expect(find.text('Results Under Senate Moderation'), findsOneWidget);
    });

    // -------------------------------------------------------------------------
    // 9. student_documents_page.dart
    // -------------------------------------------------------------------------
    testWidgets('StudentDocumentsPage lists official documents and supports request modal',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: StudentDocumentsPage(),
        ),
      );

      expect(find.text('Official Documents & Records'), findsOneWidget);
      expect(find.text('Official University Admission Letter'), findsOneWidget);
      expect(find.textContaining('Certificate of Student Status'), findsOneWidget);

      // Open request modal
      await tester.tap(find.text('Request New'));
      await tester.pumpAndSettle();

      expect(find.text('Request Official Document'), findsOneWidget);
      expect(find.text('Submit Request'), findsOneWidget);
    });

    // -------------------------------------------------------------------------
    // 10. student_announcements_page.dart
    // -------------------------------------------------------------------------
    testWidgets('StudentAnnouncementsPage displays notices with attachments',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: StudentAnnouncementsPage(),
        ),
      );

      expect(find.text('Announcements Board'), findsOneWidget);
      expect(find.textContaining('Continuous Assessment'), findsWidgets);
      expect(find.textContaining('Bursary Second Installment'), findsWidgets);
      expect(find.text('PDF Attached'), findsWidgets);
    });

    // -------------------------------------------------------------------------
    // 11. student_notifications_page.dart
    // -------------------------------------------------------------------------
    testWidgets('StudentNotificationsPage supports marking read and viewing alerts',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: StudentNotificationsPage(),
        ),
      );

      expect(find.text('Notifications'), findsOneWidget);
      expect(find.text('Mark All Read'), findsOneWidget);
      expect(find.textContaining('Registration Deadline'), findsOneWidget);

      await tester.tap(find.text('Mark All Read'));
      await tester.pumpAndSettle();

      expect(find.text('All notifications marked as read.'), findsOneWidget);
    });

    // -------------------------------------------------------------------------
    // 12. student_settings_page.dart
    // -------------------------------------------------------------------------
    testWidgets('StudentSettingsPage toggles preferences and supports sign-out confirmation',
        (tester) async {
      tester.view.physicalSize = const Size(1280, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      bool signedOut = false;

      await tester.pumpWidget(
        MaterialApp(
          home: StudentSettingsPage(
            onSignOut: () => signedOut = true,
          ),
        ),
      );

      expect(find.text('Settings & Preferences'), findsOneWidget);
      expect(find.text('High Contrast HCI Mode'), findsOneWidget);
      expect(find.text('Portal Language'), findsOneWidget);
      expect(find.text('SIGN OUT OF PORTAL'), findsOneWidget);

      // Tap Sign out
      await tester.tap(find.text('SIGN OUT OF PORTAL'));
      await tester.pumpAndSettle();

      expect(find.text('Confirm Sign Out'), findsOneWidget);
      await tester.tap(find.text('Sign Out'));
      await tester.pumpAndSettle();

      expect(signedOut, isTrue);
    });
  });
}
