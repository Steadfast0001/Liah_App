import 'package:flutter/material.dart';

import 'app_colors.dart';

class StudentFeesPage extends StatefulWidget {
  const StudentFeesPage({super.key});

  @override
  State<StudentFeesPage> createState() => _StudentFeesPageState();
}

class _StudentFeesPageState extends State<StudentFeesPage> {
  // Semester breakdown data
  final String _currentSemester = '2026/2027 Semester 1';

  // Specific rule: Separate charges, verified payments, pending verification, and outstanding balance
  final int _semesterCharges = 350000; // 350,000 XAF (Tuition + Registration + Tech)
  final int _verifiedPayments = 250000; // 250,000 XAF (Verified by Bursary)
  final int _pendingVerificationPayments = 50000; // 50,000 XAF (Under review - NEVER counted as verified)

  int get _outstandingBalance => _semesterCharges - _verifiedPayments; // 100,000 XAF outstanding

  final List<Map<String, dynamic>> _chargesList = [
    {
      'title': 'Tuition Fee (First Installment)',
      'semester': '2026/2027 Semester 1',
      'amountXaf': 250000,
      'status': 'Charged',
      'date': '01 Sep 2026',
    },
    {
      'title': 'Academic Course Registration Fee',
      'semester': '2026/2027 Semester 1',
      'amountXaf': 50000,
      'status': 'Charged',
      'date': '01 Sep 2026',
    },
    {
      'title': 'Technology & Computing Laboratory Levy',
      'semester': '2026/2027 Semester 1',
      'amountXaf': 50000,
      'status': 'Charged',
      'date': '01 Sep 2026',
    },
  ];

  final List<Map<String, dynamic>> _paymentTransactions = [
    {
      'reference': 'LIAH-PAY-2026-0914',
      'semester': '2026/2027 Semester 1',
      'provider': 'MTN Mobile Money (*126#)',
      'amountXaf': 150000,
      'isVerified': true,
      'statusLabel': 'Verified & Audited',
      'date': '05 Sep 2026',
      'bursarNote': 'Cleared by Bursary (Slip #TX99120)',
    },
    {
      'reference': 'LIAH-PAY-2026-1002',
      'semester': '2026/2027 Semester 1',
      'provider': 'Orange Money (*150#)',
      'amountXaf': 100000,
      'isVerified': true,
      'statusLabel': 'Verified & Audited',
      'date': '02 Oct 2026',
      'bursarNote': 'Cleared by Bursary (Slip #TX99441)',
    },
    {
      'reference': 'LIAH-PAY-2026-1021',
      'semester': '2026/2027 Semester 1',
      'provider': 'Afriland First Bank (Teller Deposit)',
      'amountXaf': 50000,
      'isVerified': false, // SPECIFIC RULE: Never display a pending receipt as a verified payment
      'statusLabel': 'Pending Bursary Verification',
      'date': '21 Oct 2026',
      'bursarNote': 'Bank teller slip submitted; pending Bursary bank reconciliation.',
    },
  ];

  // Specific rule: Do not use a single global paid flag to decide whether all historical results are accessible.
  // Each semester has its own financial standing / clearance!
  final Map<String, bool> _semesterResultsAccessMap = {
    '2025/2026 Semester 1': true, // Cleared 100%
    '2025/2026 Semester 2': true, // Cleared 100%
    '2026/2027 Semester 1': true, // Cleared 71.4% (Exceeds 70% threshold for semester CA/Exam results access)
    '2026/2027 Semester 2': false, // Not yet started
  };

  void _showPaymentInstructionsModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.payment, color: AppColors.gold),
                      SizedBox(width: 8),
                      Text('Official Cameroon Payment Channels', style: TextStyle(color: AppColors.onNavy, fontSize: 16, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    'Always quote your Student Matricule (LIAH-2024-SW0482) as the payment reference or narration.',
                    style: TextStyle(color: AppColors.muted, fontSize: 12, height: 1.4),
                  ),
                  const SizedBox(height: 16),
                  _buildPaymentChannelTile(
                    'MTN Mobile Money (MoMo)',
                    'Dial *126# • Merchant Code: 670 11 22 33 (Liah Academy)',
                    Icons.phone_android,
                  ),
                  const SizedBox(height: 10),
                  _buildPaymentChannelTile(
                    'Orange Money (OM)',
                    'Dial *150# • Merchant Code: 690 44 55 66 (Liah Academy SMS)',
                    Icons.phone_iphone,
                  ),
                  const SizedBox(height: 10),
                  _buildPaymentChannelTile(
                    'Afriland First Bank (Branch Teller)',
                    'Account: 10005 00012 34567890123 45 • Liah University Yaoundé',
                    Icons.account_balance,
                  ),
                  const SizedBox(height: 10),
                  _buildPaymentChannelTile(
                    'UBA Cameroon (United Bank for Africa)',
                    'Account: 10033 05200 01234567890 12 • Liah Academy Buea',
                    Icons.account_balance,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.gold, minimumSize: const Size.fromHeight(42)),
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text('Close Instructions', style: TextStyle(color: AppColors.navyDeep, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPaymentChannelTile(String title, String details, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.navy,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.gold, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: AppColors.onNavy, fontWeight: FontWeight.bold, fontSize: 13)),
                const SizedBox(height: 3),
                Text(details, style: const TextStyle(color: AppColors.muted, fontSize: 11.5, height: 1.3)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showReceiptModal(Map<String, dynamic> tx) {
    showDialog(
      context: context,
      builder: (ctx) {
        final isVerified = tx['isVerified'] as bool;
        return AlertDialog(
          backgroundColor: AppColors.surface,
          title: Row(
            children: [
              Icon(
                isVerified ? Icons.receipt_long : Icons.hourglass_top,
                color: isVerified ? const Color(0xFF34D399) : Colors.orange,
              ),
              const SizedBox(width: 8),
              Text(
                isVerified ? 'Official Payment Receipt' : 'Pending Payment Slip',
                style: const TextStyle(color: AppColors.onNavy, fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildReceiptRow('Transaction Ref', tx['reference']),
              const SizedBox(height: 6),
              _buildReceiptRow('Applicable Semester', tx['semester']),
              const SizedBox(height: 6),
              _buildReceiptRow('Channel / Provider', tx['provider']),
              const SizedBox(height: 6),
              _buildReceiptRow('Amount Paid', '${tx['amountXaf']} XAF'),
              const SizedBox(height: 6),
              _buildReceiptRow('Transaction Date', tx['date']),
              const SizedBox(height: 6),
              _buildReceiptRow('Status', tx['statusLabel']),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: AppColors.navy, borderRadius: BorderRadius.circular(6)),
                child: Text(tx['bursarNote'], style: const TextStyle(color: AppColors.muted, fontSize: 11)),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Close', style: TextStyle(color: AppColors.muted)),
            ),
            if (isVerified)
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.gold),
                onPressed: () {
                  Navigator.pop(ctx);
                  _downloadStatement();
                },
                icon: const Icon(Icons.download, size: 16, color: AppColors.navyDeep),
                label: const Text('Download PDF', style: TextStyle(color: AppColors.navyDeep, fontWeight: FontWeight.bold)),
              ),
          ],
        );
      },
    );
  }

  Widget _buildReceiptRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: AppColors.muted, fontSize: 11)),
        Text(value, style: const TextStyle(color: AppColors.onNavy, fontWeight: FontWeight.bold, fontSize: 12)),
      ],
    );
  }

  void _downloadStatement() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Downloading official Account Statement (PDF) for 2026/2027...'),
        backgroundColor: Color(0xFF0F5132),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final paidPercent = (_verifiedPayments / _semesterCharges * 100).toInt();

    return Scaffold(
      backgroundColor: AppColors.navy,
      appBar: AppBar(
        backgroundColor: AppColors.navy,
        elevation: 0,
        title: const Text('Tuition & Fees Clearance', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
        actions: [
          IconButton(
            icon: const Icon(Icons.file_download_outlined, color: AppColors.gold),
            tooltip: 'Download Statement (PDF)',
            onPressed: _downloadStatement,
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Overall Financial Balance Card
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF13204D), Color(0xFF0C132B)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.gold.withValues(alpha: 0.6)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'OUTSTANDING BALANCE',
                          style: TextStyle(color: AppColors.muted, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.8),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.goldTint,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(_currentSemester, style: const TextStyle(color: AppColors.gold, fontWeight: FontWeight.bold, fontSize: 11)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '$_outstandingBalance XAF',
                      style: const TextStyle(color: AppColors.gold, fontSize: 28, fontWeight: FontWeight.w900),
                    ),
                    const SizedBox(height: 14),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: _verifiedPayments / _semesterCharges,
                        backgroundColor: AppColors.navy,
                        valueColor: const AlwaysStoppedAnimation<Color>(AppColors.gold),
                        minHeight: 6,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Paid: $_verifiedPayments XAF ($paidPercent%)', style: const TextStyle(color: Color(0xFF34D399), fontSize: 11, fontWeight: FontWeight.bold)),
                        Text('Total: $_semesterCharges XAF', style: const TextStyle(color: AppColors.muted, fontSize: 11)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // 2. Action Buttons: Make Payment / View Channels
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.gold,
                        foregroundColor: AppColors.navyDeep,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: _showPaymentInstructionsModal,
                      icon: const Icon(Icons.add_card, size: 16),
                      label: const Text('Pay Fees (XAF)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.onNavy,
                        side: const BorderSide(color: AppColors.border),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: _downloadStatement,
                      icon: const Icon(Icons.receipt_outlined, size: 16, color: AppColors.gold),
                      label: const Text('Statement', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // 3. Installment Milestones & Access Requirements
              const Text('EXAMINATION & REGISTRATION ACCESS MILESTONES', style: TextStyle(color: AppColors.muted, fontSize: 10.5, fontWeight: FontWeight.bold, letterSpacing: 0.6)),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  children: [
                    _buildMilestoneRow('Phase 1: Course Registration Clearance (50%)', true, '175,000 XAF Required • Met'),
                    const Divider(color: AppColors.border, height: 16),
                    _buildMilestoneRow('Phase 2: CA & Exam Slip Access Clearance (70%)', true, '245,000 XAF Required • Met ($paidPercent% Paid)'),
                    const Divider(color: AppColors.border, height: 16),
                    _buildMilestoneRow('Phase 3: Final Transcript & Graduation Clearance (100%)', false, '350,000 XAF Required • 100,000 XAF Remaining'),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // 4. Charges Breakdown by Semester
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('SEMESTER CHARGES', style: TextStyle(color: AppColors.onNavy, fontSize: 13, fontWeight: FontWeight.bold)),
                  Text('Total: $_semesterCharges XAF', style: const TextStyle(color: AppColors.gold, fontSize: 12, fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 8),
              ..._chargesList.map((c) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(c['title'], style: const TextStyle(color: AppColors.onNavy, fontWeight: FontWeight.bold, fontSize: 12.5)),
                            const SizedBox(height: 2),
                            Text('${c['semester']} • ${c['date']}', style: const TextStyle(color: AppColors.muted, fontSize: 11)),
                          ],
                        ),
                      ),
                      Text('${c['amountXaf']} XAF', style: const TextStyle(color: AppColors.onNavy, fontWeight: FontWeight.w700, fontSize: 13)),
                    ],
                  ),
                );
              }),
              const SizedBox(height: 20),

              // 5. Payment History (Separated Verified vs Pending)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('PAYMENT & TRANSACTION HISTORY', style: TextStyle(color: AppColors.onNavy, fontSize: 13, fontWeight: FontWeight.bold)),
                  if (_pendingVerificationPayments > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFF3B2F0F),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text('$_pendingVerificationPayments XAF Pending', style: const TextStyle(color: Colors.orange, fontSize: 10, fontWeight: FontWeight.bold)),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              ..._paymentTransactions.map((tx) {
                final isVerified = tx['isVerified'] as bool;
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isVerified ? AppColors.border : Colors.orange.withValues(alpha: 0.5),
                    ),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    leading: Icon(
                      isVerified ? Icons.check_circle : Icons.pending,
                      color: isVerified ? const Color(0xFF34D399) : Colors.orange,
                    ),
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(tx['provider'], style: const TextStyle(color: AppColors.onNavy, fontWeight: FontWeight.bold, fontSize: 13)),
                        Text('${tx['amountXaf']} XAF', style: TextStyle(color: isVerified ? const Color(0xFF34D399) : Colors.orange, fontWeight: FontWeight.bold, fontSize: 13)),
                      ],
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 2),
                        Text('${tx['semester']} • ${tx['date']}', style: const TextStyle(color: AppColors.muted, fontSize: 11)),
                        const SizedBox(height: 2),
                        Text(tx['statusLabel'], style: TextStyle(color: isVerified ? const Color(0xFF34D399) : Colors.orange, fontSize: 10.5, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 13, color: AppColors.muted),
                    onTap: () => _showReceiptModal(tx),
                  ),
                );
              }),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMilestoneRow(String title, bool isCleared, String details) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          isCleared ? Icons.check_circle : Icons.radio_button_unchecked,
          size: 16,
          color: isCleared ? const Color(0xFF34D399) : AppColors.muted,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: isCleared ? AppColors.onNavy : AppColors.muted,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 2),
              Text(details, style: const TextStyle(color: AppColors.muted, fontSize: 10.5)),
            ],
          ),
        ),
      ],
    );
  }
}
