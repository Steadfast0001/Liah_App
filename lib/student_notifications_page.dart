import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'course_registration_page.dart';
import 'student_announcements_page.dart';
import 'student_fees_page.dart';
import 'student_results_page.dart';
import 'student_timetable_page.dart';

class StudentNotificationsPage extends StatefulWidget {
  const StudentNotificationsPage({super.key});

  @override
  State<StudentNotificationsPage> createState() => _StudentNotificationsPageState();
}

class _StudentNotificationsPageState extends State<StudentNotificationsPage> {
  final List<Map<String, dynamic>> _notifications = [
    {
      'id': 'notif-1',
      'title': 'Course Registration Deadline Approaching',
      'message': 'Course registration for First Semester closes in 3 days. Please finalize your enrollment.',
      'timestamp': '2 hours ago',
      'isRead': false,
      'destination': 'registration',
      'icon': Icons.app_registration,
    },
    {
      'id': 'notif-2',
      'title': 'Bursary Payment Slip Verified',
      'message': 'Your Mobile Money tuition payment of 100,000 XAF (Ref: LIAH-PAY-2026-1002) has been audited and approved.',
      'timestamp': 'Yesterday at 14:32',
      'isRead': false,
      'destination': 'fees',
      'icon': Icons.verified,
    },
    {
      'id': 'notif-3',
      'title': 'Timetable Schedule Notice',
      'message': 'Lectures for SWE201 on Thursday will take place in Amphi 250 instead of Lab 3.',
      'timestamp': '2 days ago',
      'isRead': true,
      'destination': 'timetable',
      'icon': Icons.calendar_month,
    },
    {
      'id': 'notif-4',
      'title': 'Continuous Assessment (CA) Marks Published',
      'message': 'CA marks for SWE203 have been uploaded by Engr. Divine Mbella. Check your score sheet.',
      'timestamp': '4 days ago',
      'isRead': true,
      'destination': 'results',
      'icon': Icons.assessment,
    },
    {
      'id': 'notif-5',
      'title': 'Official Notice: Inter-University Sports',
      'message': 'Tryouts for university sports teams have commenced. Review guidelines on the board.',
      'timestamp': '1 week ago',
      'isRead': true,
      'destination': 'announcements',
      'icon': Icons.campaign,
    },
  ];

  void _markAllAsRead() {
    setState(() {
      for (final n in _notifications) {
        n['isRead'] = true;
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('All notifications marked as read.'),
        backgroundColor: Color(0xFF0F5132),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _openDestination(Map<String, dynamic> notif) {
    setState(() => notif['isRead'] = true);

    final dest = notif['destination'] as String;
    Widget targetPage;
    switch (dest) {
      case 'registration':
        targetPage = const CourseRegistrationPage();
        break;
      case 'fees':
        targetPage = const StudentFeesPage();
        break;
      case 'timetable':
        targetPage = const StudentTimetablePage();
        break;
      case 'results':
        targetPage = const StudentResultsPage();
        break;
      case 'announcements':
      default:
        targetPage = const StudentAnnouncementsPage();
        break;
    }

    Navigator.push(context, MaterialPageRoute(builder: (_) => targetPage));
  }

  @override
  Widget build(BuildContext context) {
    final unreadCount = _notifications.where((n) => !n['isRead']).length;

    return Scaffold(
      backgroundColor: AppColors.navy,
      appBar: AppBar(
        backgroundColor: AppColors.navy,
        elevation: 0,
        title: const Text('Notifications', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
        actions: [
          if (unreadCount > 0)
            TextButton(
              onPressed: _markAllAsRead,
              child: const Text('Mark All Read', style: TextStyle(color: AppColors.gold, fontSize: 12, fontWeight: FontWeight.bold)),
            ),
        ],
      ),
      body: SafeArea(
        child: _notifications.isEmpty
            ? const Center(
                child: Text('You have no notifications at this time.', style: TextStyle(color: AppColors.muted)),
              )
            : ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                itemCount: _notifications.length,
                itemBuilder: (context, i) {
                  final notif = _notifications[i];
                  final isRead = notif['isRead'] as bool;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isRead ? AppColors.border : AppColors.gold.withValues(alpha: 0.6),
                        width: isRead ? 0.8 : 1.2,
                      ),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.navy,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          notif['icon'] as IconData,
                          color: isRead ? AppColors.muted : AppColors.gold,
                          size: 20,
                        ),
                      ),
                      title: Row(
                        children: [
                          if (!isRead)
                            Container(
                              width: 6,
                              height: 6,
                              margin: const EdgeInsets.only(right: 6),
                              decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.gold),
                            ),
                          Expanded(
                            child: Text(
                              notif['title'],
                              style: TextStyle(
                                color: AppColors.onNavy,
                                fontWeight: isRead ? FontWeight.w600 : FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 3),
                          Text(notif['message'], style: const TextStyle(color: AppColors.muted, fontSize: 11.5)),
                          const SizedBox(height: 4),
                          Text(notif['timestamp'], style: const TextStyle(color: AppColors.gold, fontSize: 10, fontWeight: FontWeight.w600)),
                        ],
                      ),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 12, color: AppColors.muted),
                      onTap: () => _openDestination(notif),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
