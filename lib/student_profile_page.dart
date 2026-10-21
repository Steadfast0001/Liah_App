import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'reset_password_page.dart';

class StudentProfilePage extends StatefulWidget {
  const StudentProfilePage({
    super.key,
    this.studentName = 'Martin Ngono',
    this.matricule = 'LIAH-2024-SW0482',
    this.email = 'student@liah.com',
    this.program = 'B.Eng. Software Engineering',
    this.level = 'Level 200 (Year 2)',
    this.cohort = 'Cohort 2024/2025',
    this.enrollmentStatus = 'Active / Registered',
  });

  final String studentName;
  final String matricule;
  final String email;
  final String program;
  final String level;
  final String cohort;
  final String enrollmentStatus;

  @override
  State<StudentProfilePage> createState() => _StudentProfilePageState();
}

class _StudentProfilePageState extends State<StudentProfilePage> {
  // Permitted editable fields
  late String _phone;
  late String _personalEmail;
  late String _address;

  // Guardian details
  final String _guardianName = 'Mme. Therese Ngono';
  final String _guardianRelation = 'Mother / Primary Sponsor';
  final String _guardianPhone = '+237 677 89 01 23';
  final String _guardianEmail = 'therese.ngono@gmail.com';

  @override
  void initState() {
    super.initState();
    _phone = '+237 699 12 34 56';
    _personalEmail = 'martin.ngono@gmail.com';
    _address = 'Biyem-Assi, Yaoundé, Cameroon';
  }

  void _showEditPermittedFieldsDialog() {
    final phoneController = TextEditingController(text: _phone);
    final personalEmailController = TextEditingController(text: _personalEmail);
    final addressController = TextEditingController(text: _address);

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: AppColors.surface,
          title: const Row(
            children: [
              Icon(Icons.edit_note_rounded, color: AppColors.gold),
              SizedBox(width: 8),
              Text(
                'Edit Contact Details',
                style: TextStyle(color: AppColors.onNavy, fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Note: Academic details, name, and official matricule can only be changed by the Central Admissions Office.',
                  style: TextStyle(color: AppColors.muted, fontSize: 11, height: 1.3),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: phoneController,
                  style: const TextStyle(color: AppColors.onNavy),
                  decoration: const InputDecoration(
                    labelText: 'Phone Number',
                    labelStyle: TextStyle(color: AppColors.muted),
                    filled: true,
                    fillColor: AppColors.navy,
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: personalEmailController,
                  style: const TextStyle(color: AppColors.onNavy),
                  decoration: const InputDecoration(
                    labelText: 'Personal Email',
                    labelStyle: TextStyle(color: AppColors.muted),
                    filled: true,
                    fillColor: AppColors.navy,
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: addressController,
                  style: const TextStyle(color: AppColors.onNavy),
                  decoration: const InputDecoration(
                    labelText: 'Residential Address',
                    labelStyle: TextStyle(color: AppColors.muted),
                    filled: true,
                    fillColor: AppColors.navy,
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel', style: TextStyle(color: AppColors.muted)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.gold),
              onPressed: () {
                setState(() {
                  _phone = phoneController.text.trim();
                  _personalEmail = personalEmailController.text.trim();
                  _address = addressController.text.trim();
                });
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Contact details updated successfully'),
                    backgroundColor: Color(0xFF0F5132),
                  ),
                );
              },
              child: const Text('Save Changes', style: TextStyle(color: AppColors.navyDeep, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  void _showPasswordOptions() {
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
              const Row(
                children: [
                  Icon(Icons.security, color: AppColors.gold),
                  SizedBox(width: 8),
                  Text('Password & Security Options', style: TextStyle(color: AppColors.onNavy, fontSize: 16, fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 12),
              const Text(
                'Protect your student portal account. Choose an option below:',
                style: TextStyle(color: AppColors.muted, fontSize: 12),
              ),
              const SizedBox(height: 16),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.lock_reset, color: AppColors.gold),
                title: const Text('Change Password', style: TextStyle(color: AppColors.onNavy)),
                subtitle: const Text('Update your active portal password', style: TextStyle(color: AppColors.muted, fontSize: 11)),
                onTap: () {
                  Navigator.pop(ctx);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ResetPasswordPage(initialSessionValid: true),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showSupportOptions() {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: AppColors.surface,
          title: const Row(
            children: [
              Icon(Icons.support_agent, color: AppColors.gold),
              SizedBox(width: 8),
              Text('Academic & IT Support', style: TextStyle(color: AppColors.onNavy, fontSize: 16, fontWeight: FontWeight.bold)),
            ],
          ),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Academic Advisor: Dr. Paul F. Tiku', style: TextStyle(color: AppColors.onNavy, fontWeight: FontWeight.bold)),
              Text('Email: p.tiku@liah.edu.cm', style: TextStyle(color: AppColors.muted, fontSize: 12)),
              Text('Office: Department of Software Engineering, Amphi 2B', style: TextStyle(color: AppColors.muted, fontSize: 12)),
              SizedBox(height: 14),
              Text('Registrar Admissions Desk:', style: TextStyle(color: AppColors.onNavy, fontWeight: FontWeight.bold)),
              Text('Email: registry@liah.edu.cm • Hotline: +237 222 34 56 78', style: TextStyle(color: AppColors.muted, fontSize: 12)),
              SizedBox(height: 14),
              Text('Campus IT Helpdesk:', style: TextStyle(color: AppColors.onNavy, fontWeight: FontWeight.bold)),
              Text('support@liah.edu.cm • WhatsApp: +237 670 00 00 01', style: TextStyle(color: AppColors.muted, fontSize: 12)),
            ],
          ),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.gold),
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Close', style: TextStyle(color: AppColors.navyDeep, fontWeight: FontWeight.bold)),
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
        title: const Text('Student Profile', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit, color: AppColors.gold),
            tooltip: 'Edit Contact Details',
            onPressed: _showEditPermittedFieldsDialog,
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Profile Avatar & Primary Identification
              Center(
                child: Column(
                  children: [
                    Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.gold, width: 2.5),
                        color: AppColors.navyDeep,
                      ),
                      child: ClipOval(
                        child: Image.asset(
                          'assets/images/logo.png',
                          fit: BoxFit.cover,
                          errorBuilder: (ctx, err, stack) => Center(
                            child: Text(
                              widget.studentName.isNotEmpty ? widget.studentName[0] : 'S',
                              style: const TextStyle(color: AppColors.gold, fontSize: 36, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      widget.studentName,
                      style: const TextStyle(color: AppColors.onNavy, fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: AppColors.gold.withValues(alpha: 0.6)),
                      ),
                      child: Text(
                        'MATRICULE: ${widget.matricule}',
                        style: const TextStyle(color: AppColors.gold, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 0.8),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // 2. Academic Enrollment Section (Read-Only)
              _buildSectionHeader('ACADEMIC ENROLLMENT DETAILS (LOCKED)'),
              const SizedBox(height: 8),
              _buildInfoContainer([
                _buildInfoRow('Degree Program', widget.program, Icons.school_outlined),
                _buildInfoRow('Academic Level', widget.level, Icons.layers_outlined),
                _buildInfoRow('Intake Cohort', widget.cohort, Icons.group_outlined),
                _buildInfoRow('Enrollment Status', widget.enrollmentStatus, Icons.verified_user_outlined, isSuccess: true),
                _buildInfoRow('Official Institutional Email', widget.email, Icons.mark_email_read_outlined),
              ]),
              const SizedBox(height: 20),

              // 3. Contact Details (Permitted to Edit)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildSectionHeader('CONTACT DETAILS (PERMITTED TO EDIT)'),
                  InkWell(
                    onTap: _showEditPermittedFieldsDialog,
                    child: const Text('Edit', style: TextStyle(color: AppColors.gold, fontSize: 12, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              _buildInfoContainer([
                _buildInfoRow('Mobile Phone', _phone, Icons.phone_android_outlined),
                _buildInfoRow('Personal Email', _personalEmail, Icons.email_outlined),
                _buildInfoRow('Residential Address', _address, Icons.home_outlined),
              ]),
              const SizedBox(height: 20),

              // 4. Guardian / Sponsor Information
              _buildSectionHeader('GUARDIAN & SPONSOR INFORMATION'),
              const SizedBox(height: 8),
              _buildInfoContainer([
                _buildInfoRow('Guardian Name', _guardianName, Icons.person_outline),
                _buildInfoRow('Relationship', _guardianRelation, Icons.family_restroom_outlined),
                _buildInfoRow('Guardian Phone', _guardianPhone, Icons.phone_outlined),
                _buildInfoRow('Guardian Email', _guardianEmail, Icons.mail_outline),
              ]),
              const SizedBox(height: 24),

              // 5. Account Security & Support Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.gold,
                        side: const BorderSide(color: AppColors.gold),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: _showPasswordOptions,
                      icon: const Icon(Icons.lock_outline, size: 16),
                      label: const Text('Password', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.surface,
                        foregroundColor: AppColors.onNavy,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: _showSupportOptions,
                      icon: const Icon(Icons.support_agent, size: 16, color: AppColors.gold),
                      label: const Text('Support Desk', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
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

  Widget _buildInfoContainer(List<Widget> rows) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: List.generate(rows.length, (i) {
          return Column(
            children: [
              rows[i],
              if (i < rows.length - 1)
                const Divider(height: 1, thickness: 0.6, color: AppColors.border),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon, {bool isSuccess = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          Icon(icon, size: 18, color: isSuccess ? const Color(0xFF34D399) : AppColors.gold),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(color: AppColors.muted, fontSize: 11)),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    color: isSuccess ? const Color(0xFF34D399) : AppColors.onNavy,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
