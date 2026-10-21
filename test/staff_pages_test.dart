import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:liah_app/assessment_setup_page.dart';
import 'package:liah_app/attendance_register_page.dart';
import 'package:liah_app/dashboard_data.dart';
import 'package:liah_app/grade_entry_page.dart';
import 'package:liah_app/grade_submission_detail_page.dart';
import 'package:liah_app/resit_management_page.dart';
import 'package:liah_app/staff_announcements_page.dart';
import 'package:liah_app/staff_class_list_page.dart';
import 'package:liah_app/staff_course_detail_page.dart';
import 'package:liah_app/staff_courses_page.dart';
import 'package:liah_app/staff_dashboard_page.dart';
import 'package:liah_app/staff_profile_page.dart';
import 'package:liah_app/staff_timetable_page.dart';

void main() {
  setUp(() {
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  group('5. Lecturer / Staff Pages Tests', () {
    // -------------------------------------------------------------------------
    // 1. staff_dashboard_page.dart
    // -------------------------------------------------------------------------
    testWidgets('StaffDashboardPage renders greeting, assigned courses, next class, and tasks',
        (tester) async {
      tester.view.physicalSize = const Size(1280, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      const demoData = DashboardData(
        role: DashboardRole.teacher,
        displayName: 'Engr. Divine Mbella',
        userId: 'LIAH-FAC-2019-012',
        metrics: [],
        notifications: [],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StaffDashboardPage(data: demoData),
          ),
        ),
      );

      // Greeting, Role & ID
      expect(find.textContaining('Divine Mbella'), findsWidgets);
      expect(find.textContaining('LIAH-FAC-2019-012'), findsOneWidget);
      expect(find.textContaining('Senior Lecturer'), findsWidgets);

      // Summary indicators
      expect(find.text('ASSIGNED COURSES'), findsOneWidget);
      expect(find.text('3 Active'), findsOneWidget);
      expect(find.text('ATTENDANCE AUDIT'), findsOneWidget);
      expect(find.text('GRADE SHEETS'), findsOneWidget);

      // Next Class Card
      expect(find.text('NEXT UPCOMING LECTURE'), findsOneWidget);
      expect(find.textContaining('SWE201'), findsWidgets);
      expect(find.text('Take Attendance Now'), findsOneWidget);

      // Pending Tasks
      expect(find.text('PENDING TEACHING & ASSESSMENT TASKS'), findsOneWidget);
      expect(find.textContaining('CEF205 Lab 03'), findsOneWidget);
      expect(find.textContaining('Submit CA Continuous Assessment: SWE201'), findsOneWidget);

      // Quick Actions
      expect(find.text('FACULTY QUICK ACTIONS'), findsOneWidget);
      expect(find.text('My Courses'), findsOneWidget);
      expect(find.text('Attendance'), findsOneWidget);
      expect(find.text('Grade Entry'), findsOneWidget);
      expect(find.text('Resits'), findsOneWidget);
      expect(find.text('Timetable'), findsOneWidget);
      expect(find.text('Notices'), findsOneWidget);
    });

    // -------------------------------------------------------------------------
    // 2. staff_courses_page.dart
    // -------------------------------------------------------------------------
    testWidgets('StaffCoursesPage renders assigned courses, search, and details navigation',
        (tester) async {
      tester.view.physicalSize = const Size(1280, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        const MaterialApp(
          home: StaffCoursesPage(),
        ),
      );

      expect(find.text('My Assigned Courses'), findsOneWidget);
      expect(find.text('SWE201'), findsWidgets);
      expect(find.text('CEF205'), findsWidgets);
      expect(find.text('SWE203'), findsWidgets);
      expect(find.textContaining('42 Students Enrolled'), findsOneWidget);

      // Search functionality
      await tester.enterText(find.byType(TextField), 'CEF205');
      await tester.pumpAndSettle();

      expect(find.text('CEF205'), findsWidgets);
      expect(find.text('SWE201'), findsNothing);
    });

    // -------------------------------------------------------------------------
    // 3. staff_course_detail_page.dart
    // -------------------------------------------------------------------------
    testWidgets('StaffCourseDetailPage displays overview, class list, assessments, and documents',
        (tester) async {
      tester.view.physicalSize = const Size(1280, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        const MaterialApp(
          home: StaffCourseDetailPage(),
        ),
      );

      expect(find.text('SWE201 Details'), findsOneWidget);
      expect(find.text('LECTURE & LAB SCHEDULE'), findsOneWidget);
      expect(find.text('COURSE DESCRIPTION & SYLLABUS'), findsOneWidget);

      // Switch to Class List tab
      await tester.tap(find.text('Class List'));
      await tester.pumpAndSettle();

      expect(find.text('42 Registered Students'), findsOneWidget);
      expect(find.text('Open Full Class List'), findsOneWidget);
      expect(find.textContaining('Martin Ngono'), findsWidgets);

      // Switch to Assessments tab
      await tester.tap(find.text('Assessments'));
      await tester.pumpAndSettle();

      expect(find.text('Configured Assessments'), findsOneWidget);
      expect(find.text('Continuous Assessment (CA)'), findsOneWidget);
      expect(find.text('Final Examination'), findsOneWidget);
      expect(find.text('Configure Weights'), findsOneWidget);
    });

    // -------------------------------------------------------------------------
    // 4. staff_class_list_page.dart
    // -------------------------------------------------------------------------
    testWidgets('StaffClassListPage lists authorized students and opens student profile',
        (tester) async {
      tester.view.physicalSize = const Size(1280, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        const MaterialApp(
          home: StaffClassListPage(),
        ),
      );

      expect(find.text('SWE201 Class List'), findsOneWidget);
      expect(find.textContaining('Authorized Students Enrolled'), findsOneWidget);
      expect(find.text('Martin Ngono'), findsOneWidget);
      expect(find.textContaining('LIAH-2024-SW0482'), findsOneWidget);

      // Open student profile modal
      await tester.tap(find.text('Martin Ngono'));
      await tester.pumpAndSettle();

      expect(find.textContaining('Emergency Phone'), findsOneWidget);
      expect(find.text('Close Profile'), findsOneWidget);

      await tester.tap(find.text('Close Profile'));
      await tester.pumpAndSettle();
    });

    // -------------------------------------------------------------------------
    // 5. attendance_register_page.dart
    // -------------------------------------------------------------------------
    testWidgets('AttendanceRegisterPage enforces course authorization and marks attendance',
        (tester) async {
      tester.view.physicalSize = const Size(1280, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        const MaterialApp(
          home: AttendanceRegisterPage(initialCourseCode: 'SWE201'),
        ),
      );

      expect(find.text('Attendance Register'), findsOneWidget);
      expect(find.text('Martin Ngono'), findsOneWidget);
      expect(find.text('Save Attendance Register'), findsOneWidget);

      // Mark All Present
      await tester.tap(find.text('All Present'));
      await tester.pumpAndSettle();

      // Save Register
      await tester.tap(find.text('Save Attendance Register'));
      await tester.pump(const Duration(milliseconds: 800));
      await tester.pumpAndSettle();

      expect(find.textContaining('saved and audited with registry'), findsOneWidget);

      // Test authorization lock on unassigned course
      await tester.tap(find.text('SWE201 (Assigned)'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('MAT201 (Unassigned)').last);
      await tester.pumpAndSettle();

      expect(find.textContaining('Authorization Locked: Only lecturers assigned'), findsOneWidget);
    });

    // -------------------------------------------------------------------------
    // 6. assessment_setup_page.dart
    // -------------------------------------------------------------------------
    testWidgets('AssessmentSetupPage validates CA 30% and Final Exam 70% distribution',
        (tester) async {
      tester.view.physicalSize = const Size(1280, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        const MaterialApp(
          home: AssessmentSetupPage(courseCode: 'SWE201'),
        ),
      );

      expect(find.text('SWE201 Assessment Setup'), findsOneWidget);
      expect(find.textContaining('MINESUP & Liah Academy Assessment Weights'), findsOneWidget);
      expect(find.text('Valid Distribution (100%)'), findsOneWidget);
      expect(find.text('CA Total: 30% / 30%'), findsOneWidget);
      expect(find.text('Final Exam: 70% / 70%'), findsOneWidget);

      // Save valid setup
      await tester.tap(find.text('Save Assessment Configuration'));
      await tester.pump(const Duration(milliseconds: 700));
      await tester.pumpAndSettle();

      expect(find.textContaining('validated and saved successfully'), findsOneWidget);
    });

    // -------------------------------------------------------------------------
    // 7. grade_entry_page.dart
    // -------------------------------------------------------------------------
    testWidgets(
        'GradeEntryPage enforces assessment scales, shows inline errors, prevents repeated submit, and displays disclaimer',
        (tester) async {
      tester.view.physicalSize = const Size(1280, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        const MaterialApp(
          home: GradeEntryPage(initialCourseCode: 'SWE201'),
        ),
      );

      expect(find.textContaining('Grade Entry • SWE201'), findsOneWidget);
      expect(find.text('Draft'), findsOneWidget);
      expect(find.textContaining('Lecturer Policy: Result publication is strictly reserved for the Academic Senate'), findsOneWidget);

      // Scale limits shown
      expect(find.textContaining('/ 30'), findsWidgets);
      expect(find.textContaining('/ 70'), findsWidgets);

      // Authoritative grade calculation preview
      expect(find.text('80.5 / 100'), findsOneWidget); // Martin Ngono (24.5 + 56.0)
      expect(find.text('A'), findsWidgets);

      // Enter invalid CA mark exceeding 30
      final caFields = find.byType(TextField);
      await tester.enterText(caFields.at(1), '35.0'); // Martin's CA field is at(1) [at(0) is search]
      await tester.pumpAndSettle();

      expect(find.text('Must be between 0 and 30'), findsOneWidget);

      // Correct it back
      await tester.enterText(caFields.at(1), '25.0');
      await tester.pumpAndSettle();

      expect(find.text('Must be between 0 and 30'), findsNothing);

      // Submit grade sheet confirmation
      await tester.tap(find.text('Submit to HOD'));
      await tester.pumpAndSettle();

      expect(find.text('Confirm Grade Sheet Submission'), findsOneWidget);
      expect(find.text('Confirm & Submit to HOD'), findsOneWidget);

      await tester.tap(find.text('Confirm & Submit to HOD'));
      await tester.pump(const Duration(milliseconds: 1000));
      await tester.pumpAndSettle();

      expect(find.text('Submitted to HOD'), findsOneWidget);
    });

    // -------------------------------------------------------------------------
    // 8. grade_submission_detail_page.dart
    // -------------------------------------------------------------------------
    testWidgets('GradeSubmissionDetailPage displays submission status and HOD feedback',
        (tester) async {
      tester.view.physicalSize = const Size(1280, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        const MaterialApp(
          home: GradeSubmissionDetailPage(
            courseCode: 'SWE201',
            submissionStatus: 'Returned with Corrections',
          ),
        ),
      );

      expect(find.text('SWE201 Grade Submission Record'), findsOneWidget);
      expect(find.text('Returned with Corrections'), findsOneWidget);
      expect(find.text('Action Required: Returned by HOD'), findsOneWidget);
      expect(find.textContaining('HOD Remarks (Prof. Fonkeng)'), findsOneWidget);
      expect(find.text('Revise & Correct Grade Sheet'), findsOneWidget);
    });

    // -------------------------------------------------------------------------
    // 9. resit_management_page.dart
    // -------------------------------------------------------------------------
    testWidgets('ResitManagementPage preserves normal failed attempt and inputs separate resit marks',
        (tester) async {
      tester.view.physicalSize = const Size(1280, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        const MaterialApp(
          home: ResitManagementPage(initialCourseCode: 'SWE201'),
        ),
      );

      expect(find.text('Resit (Rattrapage) Management'), findsOneWidget);
      expect(find.textContaining('Liah Academic Regulation: Resit scores do NOT erase'), findsOneWidget);

      // Preserves normal failed attempt
      expect(find.text('Original: F (Normal Session)'), findsWidgets);
      expect(find.text('SEPARATE RESIT EXAM (MAX 70)'), findsWidgets);

      // Authoritative new calculated standing
      expect(find.textContaining('56.0 / 100 (Grade C+)'), findsWidgets);

      // Submit Resit Sheet
      await tester.tap(find.text('Submit Resit Grade Sheet to Senate'));
      await tester.pumpAndSettle();

      expect(find.text('Confirm Resit (Rattrapage) Submission'), findsOneWidget);
      await tester.tap(find.text('Confirm Submission'));
      await tester.pump(const Duration(milliseconds: 900));
      await tester.pumpAndSettle();

      expect(find.textContaining('submitted successfully to Senate'), findsOneWidget);
    });

    // -------------------------------------------------------------------------
    // 10. staff_timetable_page.dart
    // -------------------------------------------------------------------------
    testWidgets('StaffTimetablePage toggles views and displays teaching sessions',
        (tester) async {
      tester.view.physicalSize = const Size(1280, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        const MaterialApp(
          home: StaffTimetablePage(),
        ),
      );

      expect(find.text('Teaching Timetable'), findsOneWidget);
      expect(find.textContaining('Current Teaching Week'), findsOneWidget);
      expect(find.text('Monday'), findsOneWidget);
      expect(find.text('SWE201'), findsOneWidget);

      // Toggle to week view
      await tester.tap(find.byIcon(Icons.view_week_outlined));
      await tester.pumpAndSettle();

      expect(find.text('Friday'), findsWidgets);
    });

    // -------------------------------------------------------------------------
    // 11. staff_announcements_page.dart
    // -------------------------------------------------------------------------
    testWidgets('StaffAnnouncementsPage displays notices and broadcasts announcement',
        (tester) async {
      tester.view.physicalSize = const Size(1280, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        const MaterialApp(
          home: StaffAnnouncementsPage(),
        ),
      );

      expect(find.text('Faculty Notices & Announcements'), findsOneWidget);
      expect(find.textContaining('Senate Grade Moderation Deadline'), findsOneWidget);
      expect(find.text('New Notice'), findsOneWidget);

      // Open broadcast modal
      await tester.tap(find.text('New Notice'));
      await tester.pumpAndSettle();

      expect(find.text('Broadcast Course Announcement'), findsOneWidget);
      expect(find.text('Broadcast Now'), findsOneWidget);

      await tester.enterText(find.byType(TextField).at(0), 'Special Lab Session');
      await tester.enterText(find.byType(TextField).at(1), 'Please bring your laptops to Amphi 250.');
      await tester.pumpAndSettle();

      await tester.tap(find.text('Broadcast Now'));
      await tester.pumpAndSettle();

      expect(find.text('Special Lab Session'), findsOneWidget);
    });

    // -------------------------------------------------------------------------
    // 12. staff_profile_page.dart
    // -------------------------------------------------------------------------
    testWidgets('StaffProfilePage displays locked details, settings, and sign-out confirmation',
        (tester) async {
      tester.view.physicalSize = const Size(1280, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      bool signedOut = false;

      await tester.pumpWidget(
        MaterialApp(
          home: StaffProfilePage(
            staffName: 'Engr. Divine Mbella',
            staffId: 'LIAH-FAC-2019-012',
            onSignOut: () => signedOut = true,
          ),
        ),
      );

      expect(find.text('Faculty Profile & Settings'), findsOneWidget);
      expect(find.text('Engr. Divine Mbella'), findsOneWidget);
      expect(find.text('STAFF ID: LIAH-FAC-2019-012'), findsOneWidget);
      expect(find.text('INSTITUTIONAL EMPLOYMENT DETAILS (LOCKED)'), findsOneWidget);
      expect(find.text('High Contrast HCI Mode'), findsOneWidget);
      expect(find.text('SIGN OUT OF PORTAL'), findsOneWidget);

      // Open edit contact details
      await tester.tap(find.text('Edit'));
      await tester.pumpAndSettle();

      expect(find.text('Edit Contact & Office Details'), findsOneWidget);
      expect(find.text('Save Changes'), findsOneWidget);

      await tester.tap(find.text('Save Changes'));
      await tester.pumpAndSettle();

      expect(find.text('Contact and office hours updated successfully.'), findsOneWidget);

      // Sign out
      await tester.tap(find.text('SIGN OUT OF PORTAL'));
      await tester.pumpAndSettle();

      expect(find.text('Confirm Sign Out'), findsOneWidget);
      await tester.tap(find.text('Sign Out'));
      await tester.pumpAndSettle();

      expect(signedOut, isTrue);
    });
  });
}
