import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'reset_password_page.dart';
import 'sign_in_page.dart';

class StudentSettingsPage extends StatefulWidget {
  const StudentSettingsPage({
    super.key,
    this.onSignOut,
  });

  final VoidCallback? onSignOut;

  @override
  State<StudentSettingsPage> createState() => _StudentSettingsPageState();
}

class _StudentSettingsPageState extends State<StudentSettingsPage> {
  bool _highContrastHciMode = false;
  bool _notificationsExamAlerts = true;
  bool _notificationsFeeAlerts = true;
  bool _notificationsTimetableAlerts = true;
  String _selectedLanguage = 'English (Cameroon)';

  void _confirmSignOut() {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: AppColors.surface,
          title: const Row(
            children: [
              Icon(Icons.logout, color: Color(0xFFF87171)),
              SizedBox(width: 8),
              Text('Confirm Sign Out', style: TextStyle(color: AppColors.onNavy, fontSize: 16, fontWeight: FontWeight.bold)),
            ],
          ),
          content: const Text(
            'Are you sure you want to end your active portal session?',
            style: TextStyle(color: AppColors.muted, fontSize: 13),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel', style: TextStyle(color: AppColors.muted)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFDC2626),
              ),
              onPressed: () {
                Navigator.pop(ctx);
                if (widget.onSignOut != null) {
                  widget.onSignOut!();
                } else {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const SignInPage()),
                    (_) => false,
                  );
                }
              },
              child: const Text('Sign Out', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.navy,
      appBar: AppBar(
        backgroundColor: AppColors.navy,
        elevation: 0,
        title: const Text('Settings & Preferences', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Accessibility & Appearance
              _buildSectionHeader('APPEARANCE & ACCESSIBILITY'),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  children: [
                    SwitchListTile(
                      activeColor: AppColors.gold,
                      title: const Text('High Contrast HCI Mode', style: TextStyle(color: AppColors.onNavy, fontSize: 13, fontWeight: FontWeight.w600)),
                      subtitle: const Text('Enhance visual contrast for campus outdoor lighting', style: TextStyle(color: AppColors.muted, fontSize: 11)),
                      value: _highContrastHciMode,
                      onChanged: (val) {
                        setState(() => _highContrastHciMode = val);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('High Contrast Mode: ${val ? "Enabled" : "Disabled"}'),
                            backgroundColor: const Color(0xFF0F5132),
                            duration: const Duration(seconds: 1),
                          ),
                        );
                      },
                    ),
                    const Divider(color: AppColors.border, height: 1),
                    ListTile(
                      leading: const Icon(Icons.language, color: AppColors.gold, size: 20),
                      title: const Text('Portal Language', style: TextStyle(color: AppColors.onNavy, fontSize: 13, fontWeight: FontWeight.w600)),
                      subtitle: Text(_selectedLanguage, style: const TextStyle(color: AppColors.muted, fontSize: 11)),
                      trailing: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedLanguage,
                          dropdownColor: AppColors.surface,
                          style: const TextStyle(color: AppColors.gold, fontSize: 12, fontWeight: FontWeight.bold),
                          items: const [
                            DropdownMenuItem(value: 'English (Cameroon)', child: Text('English (Cameroon)')),
                            DropdownMenuItem(value: 'Français (Cameroun)', child: Text('Français (Cameroun)')),
                          ],
                          onChanged: (val) {
                            if (val != null) setState(() => _selectedLanguage = val);
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // 2. Notification Preferences
              _buildSectionHeader('NOTIFICATION PREFERENCES'),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  children: [
                    SwitchListTile(
                      activeColor: AppColors.gold,
                      title: const Text('Continuous Assessment & Exam Alerts', style: TextStyle(color: AppColors.onNavy, fontSize: 13, fontWeight: FontWeight.w600)),
                      subtitle: const Text('Notify when CA marks or timetables are posted', style: TextStyle(color: AppColors.muted, fontSize: 11)),
                      value: _notificationsExamAlerts,
                      onChanged: (val) => setState(() => _notificationsExamAlerts = val),
                    ),
                    const Divider(color: AppColors.border, height: 1),
                    SwitchListTile(
                      activeColor: AppColors.gold,
                      title: const Text('Tuition & Fee Milestone Reminders', style: TextStyle(color: AppColors.onNavy, fontSize: 13, fontWeight: FontWeight.w600)),
                      subtitle: const Text('Reminders for installment clearance deadlines', style: TextStyle(color: AppColors.muted, fontSize: 11)),
                      value: _notificationsFeeAlerts,
                      onChanged: (val) => setState(() => _notificationsFeeAlerts = val),
                    ),
                    const Divider(color: AppColors.border, height: 1),
                    SwitchListTile(
                      activeColor: AppColors.gold,
                      title: const Text('Schedule & Venue Change Notices', style: TextStyle(color: AppColors.onNavy, fontSize: 13, fontWeight: FontWeight.w600)),
                      subtitle: const Text('Real-time alerts when lectures change room', style: TextStyle(color: AppColors.muted, fontSize: 11)),
                      value: _notificationsTimetableAlerts,
                      onChanged: (val) => setState(() => _notificationsTimetableAlerts = val),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // 3. Security & Account
              _buildSectionHeader('SECURITY & SESSION'),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.lock_reset, color: AppColors.gold, size: 20),
                      title: const Text('Change Password', style: TextStyle(color: AppColors.onNavy, fontSize: 13, fontWeight: FontWeight.w600)),
                      subtitle: const Text('Update your portal password', style: TextStyle(color: AppColors.muted, fontSize: 11)),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 13, color: AppColors.muted),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const ResetPasswordPage(initialSessionValid: true)),
                        );
                      },
                    ),
                    const Divider(color: AppColors.border, height: 1),
                    ListTile(
                      leading: const Icon(Icons.devices, color: AppColors.gold, size: 20),
                      title: const Text('Active Session', style: TextStyle(color: AppColors.onNavy, fontSize: 13, fontWeight: FontWeight.w600)),
                      subtitle: const Text('Liah Academy Verified Portal Session (Token Active)', style: TextStyle(color: AppColors.muted, fontSize: 11)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              // 4. Sign Out Button
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2A1515),
                  foregroundColor: const Color(0xFFF87171),
                  side: const BorderSide(color: Color(0xFFF87171)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: _confirmSignOut,
                icon: const Icon(Icons.logout, size: 18),
                label: const Text('SIGN OUT OF PORTAL', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 0.5)),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(color: AppColors.muted, fontSize: 10.5, fontWeight: FontWeight.bold, letterSpacing: 0.6),
    );
  }
}
