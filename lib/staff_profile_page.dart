import 'package:flutter/material.dart';
import 'package:liah_app/app_colors.dart';

/// Staff Profile Page (Section 5 — Lecturer / Staff Pages)
/// UI content: Staff details, department, employment status and assigned courses.
/// Required interactions: Edit permitted contact fields and manage session settings.
class StaffProfilePage extends StatefulWidget {
  final String staffName;
  final String staffId;
  final String department;
  final VoidCallback? onSignOut;

  const StaffProfilePage({
    super.key,
    this.staffName = 'Engr. Divine Mbella',
    this.staffId = 'LIAH-FAC-2019-012',
    this.department = 'Computer Science & Software Engineering',
    this.onSignOut,
  });

  @override
  State<StaffProfilePage> createState() => _StaffProfilePageState();
}

class _StaffProfilePageState extends State<StaffProfilePage> {
  // Permitted editable contact fields
  String _phone = '+237 677 889 900';
  String _officeLocation = 'Faculty Block C • Office 204';
  String _officeHours = 'Tuesdays & Thursdays (14:00 - 16:00)';

  // Settings & Preferences (all users must have settings)
  bool _highContrastHciMode = false;
  bool _caAlerts = true;
  bool _attendanceReminders = true;
  String _language = 'English (Cameroon)';

  void _showEditContactModal() {
    final phoneCtrl = TextEditingController(text: _phone);
    final officeCtrl = TextEditingController(text: _officeLocation);
    final hoursCtrl = TextEditingController(text: _officeHours);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Edit Contact & Office Details',
                style: TextStyle(color: AppColors.onNavy, fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              const Text(
                'Note: Department, rank, and employment status can only be modified by Human Resources.',
                style: TextStyle(color: AppColors.muted, fontSize: 11),
              ),
              const SizedBox(height: 14),
              const Text('Phone Number', style: TextStyle(color: AppColors.muted, fontSize: 11)),
              const SizedBox(height: 4),
              TextField(
                controller: phoneCtrl,
                style: const TextStyle(color: AppColors.onNavy, fontSize: 13),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: AppColors.navy,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
                ),
              ),
              const SizedBox(height: 10),
              const Text('Office Location', style: TextStyle(color: AppColors.muted, fontSize: 11)),
              const SizedBox(height: 4),
              TextField(
                controller: officeCtrl,
                style: const TextStyle(color: AppColors.onNavy, fontSize: 13),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: AppColors.navy,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
                ),
              ),
              const SizedBox(height: 10),
              const Text('Consultation Hours', style: TextStyle(color: AppColors.muted, fontSize: 11)),
              const SizedBox(height: 4),
              TextField(
                controller: hoursCtrl,
                style: const TextStyle(color: AppColors.onNavy, fontSize: 13),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: AppColors.navy,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
                ),
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.gold,
                    foregroundColor: AppColors.navyDeep,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  onPressed: () {
                    setState(() {
                      _phone = phoneCtrl.text.trim();
                      _officeLocation = officeCtrl.text.trim();
                      _officeHours = hoursCtrl.text.trim();
                    });
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        backgroundColor: Color(0xFF0F5132),
                        content: Text('Contact and office hours updated successfully.'),
                      ),
                    );
                  },
                  child: const Text('Save Changes', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _confirmSignOut() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text('Confirm Sign Out', style: TextStyle(color: AppColors.onNavy, fontWeight: FontWeight.bold)),
        content: const Text(
          'Are you sure you want to sign out of the Liah Academy Lecturer Portal?',
          style: TextStyle(color: AppColors.onNavy, fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: AppColors.muted)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(ctx);
              if (widget.onSignOut != null) {
                widget.onSignOut!();
              }
            },
            child: const Text('Sign Out', style: TextStyle(fontWeight: FontWeight.bold)),
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
        backgroundColor: AppColors.navyDeep,
        elevation: 0,
        title: const Text(
          'Faculty Profile & Settings',
          style: TextStyle(color: AppColors.onNavy, fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Staff Bio Header Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border, width: 0.8),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: AppColors.gold,
                    child: Text(
                      widget.staffName.substring(0, 1),
                      style: const TextStyle(color: AppColors.navyDeep, fontSize: 26, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.staffName,
                          style: const TextStyle(color: AppColors.onNavy, fontSize: 17, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'STAFF ID: ${widget.staffId}',
                          style: const TextStyle(color: AppColors.gold, fontSize: 12, fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          'Senior Lecturer • Faculty of Computing',
                          style: TextStyle(color: AppColors.muted, fontSize: 11.5),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 2. Official Institutional Details (Locked)
            const Text(
              'INSTITUTIONAL EMPLOYMENT DETAILS (LOCKED)',
              style: TextStyle(color: AppColors.gold, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.5),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.border, width: 0.8),
              ),
              child: Column(
                children: [
                  _buildDetailRow(Icons.account_balance, 'Department', widget.department),
                  const Divider(color: AppColors.border, height: 16),
                  _buildDetailRow(Icons.badge, 'Employment Status', 'Permanent Full-Time Faculty (Active)'),
                  const Divider(color: AppColors.border, height: 16),
                  _buildDetailRow(Icons.school, 'Rank & Specialization', 'Senior Lecturer • Software Systems'),
                  const Divider(color: AppColors.border, height: 16),
                  _buildDetailRow(Icons.date_range, 'Appointment Date', '01 September 2019'),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 3. Assigned Courses Portfolio
            const Text(
              'ASSIGNED TEACHING PORTFOLIO (3 COURSES)',
              style: TextStyle(color: AppColors.gold, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.5),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.border, width: 0.8),
              ),
              child: const Column(
                children: [
                  _CoursePortfolioRow(code: 'SWE201', title: 'Data Structures & Algorithms', students: '42 Students'),
                  Divider(color: AppColors.border, height: 14),
                  _CoursePortfolioRow(code: 'CEF205', title: 'Computer Architecture & Assembly', students: '38 Students'),
                  Divider(color: AppColors.border, height: 14),
                  _CoursePortfolioRow(code: 'SWE203', title: 'Object-Oriented Programming (Java)', students: '36 Students'),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 4. Contact Details (Permitted to Edit)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'CONTACT & OFFICE DETAILS (EDITABLE)',
                  style: TextStyle(color: AppColors.gold, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                ),
                TextButton(
                  onPressed: _showEditContactModal,
                  child: const Text('Edit', style: TextStyle(color: AppColors.gold, fontSize: 12, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.border, width: 0.8),
              ),
              child: Column(
                children: [
                  _buildDetailRow(Icons.phone, 'Phone Number', _phone),
                  const Divider(color: AppColors.border, height: 16),
                  _buildDetailRow(Icons.email, 'Official Email', 'd.mbella@liah.edu.cm'),
                  const Divider(color: AppColors.border, height: 16),
                  _buildDetailRow(Icons.location_on, 'Office Location', _officeLocation),
                  const Divider(color: AppColors.border, height: 16),
                  _buildDetailRow(Icons.access_time, 'Consultation Hours', _officeHours),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 5. Settings & Session Preferences
            const Text(
              'PORTAL SETTINGS & PREFERENCES',
              style: TextStyle(color: AppColors.gold, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.5),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.border, width: 0.8),
              ),
              child: Column(
                children: [
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('High Contrast HCI Mode', style: TextStyle(color: AppColors.onNavy, fontSize: 13)),
                    subtitle: const Text('Enhanced contrast compliant with Cameroon university ergonomics', style: TextStyle(color: AppColors.muted, fontSize: 11)),
                    value: _highContrastHciMode,
                    activeThumbColor: AppColors.gold,
                    onChanged: (val) => setState(() => _highContrastHciMode = val),
                  ),
                  const Divider(color: AppColors.border, height: 14),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Grade Moderation Deadline Reminders', style: TextStyle(color: AppColors.onNavy, fontSize: 13)),
                    subtitle: const Text('Push alerts for Senate continuous assessment deadlines', style: TextStyle(color: AppColors.muted, fontSize: 11)),
                    value: _caAlerts,
                    activeThumbColor: AppColors.gold,
                    onChanged: (val) => setState(() => _caAlerts = val),
                  ),
                  const Divider(color: AppColors.border, height: 14),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Unlogged Attendance Notifications', style: TextStyle(color: AppColors.onNavy, fontSize: 13)),
                    subtitle: const Text('Alerts when completed lectures have unsubmitted registers', style: TextStyle(color: AppColors.muted, fontSize: 11)),
                    value: _attendanceReminders,
                    activeThumbColor: AppColors.gold,
                    onChanged: (val) => setState(() => _attendanceReminders = val),
                  ),
                  const Divider(color: AppColors.border, height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Portal Language', style: TextStyle(color: AppColors.onNavy, fontSize: 13)),
                      DropdownButton<String>(
                        value: _language,
                        dropdownColor: AppColors.surface,
                        underline: const SizedBox.shrink(),
                        style: const TextStyle(color: AppColors.gold, fontWeight: FontWeight.bold, fontSize: 12),
                        items: const [
                          DropdownMenuItem(value: 'English (Cameroon)', child: Text('English (Cameroon)')),
                          DropdownMenuItem(value: 'Français (Cameroun)', child: Text('Français (Cameroun)')),
                        ],
                        onChanged: (val) {
                          if (val != null) setState(() => _language = val);
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // 6. Sign Out Button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                icon: const Icon(Icons.logout, color: Color(0xFFEF4444), size: 18),
                label: const Text('SIGN OUT OF PORTAL', style: TextStyle(color: Color(0xFFEF4444), fontWeight: FontWeight.bold)),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFFEF4444)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: _confirmSignOut,
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: AppColors.gold),
        const SizedBox(width: 10),
        SizedBox(
          width: 130,
          child: Text(label, style: const TextStyle(color: AppColors.muted, fontSize: 12)),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(color: AppColors.onNavy, fontSize: 12.5, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}

class _CoursePortfolioRow extends StatelessWidget {
  final String code;
  final String title;
  final String students;

  const _CoursePortfolioRow({
    required this.code,
    required this.title,
    required this.students,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.navy,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: AppColors.gold),
              ),
              child: Text(code, style: const TextStyle(color: AppColors.gold, fontWeight: FontWeight.bold, fontSize: 11)),
            ),
            const SizedBox(width: 8),
            Text(title, style: const TextStyle(color: AppColors.onNavy, fontSize: 12, fontWeight: FontWeight.w600)),
          ],
        ),
        Text(students, style: const TextStyle(color: AppColors.muted, fontSize: 11)),
      ],
    );
  }
}
