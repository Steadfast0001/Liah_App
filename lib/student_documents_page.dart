import 'package:flutter/material.dart';

import 'app_colors.dart';

class StudentDocumentsPage extends StatefulWidget {
  const StudentDocumentsPage({super.key});

  @override
  State<StudentDocumentsPage> createState() => _StudentDocumentsPageState();
}

class _StudentDocumentsPageState extends State<StudentDocumentsPage> {
  final List<Map<String, dynamic>> _documents = [
    {
      'title': 'Official University Admission Letter',
      'category': 'Admissions',
      'date': '15 Oct 2024',
      'reference': 'LIAH/ADM/2024/0482',
      'status': 'Available for Download',
      'isAuthorized': true,
      'fileSize': '420 KB',
    },
    {
      'title': '2025/2026 Semester 2 Official Result Sheet',
      'category': 'Academic Results',
      'date': '10 Jul 2026',
      'reference': 'LIAH/RES/25-26/S2/0482',
      'status': 'Available for Download',
      'isAuthorized': true,
      'fileSize': '580 KB',
    },
    {
      'title': '2025/2026 Semester 1 Official Result Sheet',
      'category': 'Academic Results',
      'date': '20 Feb 2026',
      'reference': 'LIAH/RES/25-26/S1/0482',
      'status': 'Available for Download',
      'isAuthorized': true,
      'fileSize': '540 KB',
    },
    {
      'title': 'Certificate of Student Status & Enrollment',
      'category': 'Registry & Visa',
      'date': '05 Sep 2026',
      'reference': 'LIAH/CERT/2026/0119',
      'status': 'Available for Download',
      'isAuthorized': true,
      'fileSize': '310 KB',
    },
    {
      'title': 'Official Academic Transcript (Level 100 - Level 200)',
      'category': 'Registry Records',
      'date': 'Requested 18 Oct 2026',
      'reference': 'LIAH/TRQ/2026/0991',
      'status': 'Processing by Dean of Faculty',
      'isAuthorized': false,
      'fileSize': 'Pending Stamp',
    },
  ];

  void _showRequestDocumentModal() {
    final typeController = TextEditingController(text: 'Official Academic Transcript');
    final purposeController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: AppColors.surface,
          title: const Row(
            children: [
              Icon(Icons.post_add, color: AppColors.gold),
              SizedBox(width: 8),
              Text('Request Official Document', style: TextStyle(color: AppColors.onNavy, fontSize: 16, fontWeight: FontWeight.bold)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Document Type:', style: TextStyle(color: AppColors.muted, fontSize: 11)),
              const SizedBox(height: 4),
              TextField(
                controller: typeController,
                style: const TextStyle(color: AppColors.onNavy, fontSize: 13),
                decoration: const InputDecoration(filled: true, fillColor: AppColors.navy),
              ),
              const SizedBox(height: 12),
              const Text('Purpose / Destination (e.g. Visa, Internship, Scholarship):', style: TextStyle(color: AppColors.muted, fontSize: 11)),
              const SizedBox(height: 4),
              TextField(
                controller: purposeController,
                style: const TextStyle(color: AppColors.onNavy, fontSize: 13),
                decoration: const InputDecoration(
                  hintText: 'e.g. Master admission, MINESUP fellowship',
                  filled: true,
                  fillColor: AppColors.navy,
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
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.gold),
              onPressed: () {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Document request submitted to Central Registry! Tracking Ref: LIAH/TRQ/2026/1042'),
                    backgroundColor: Color(0xFF0F5132),
                  ),
                );
              },
              child: const Text('Submit Request', style: TextStyle(color: AppColors.navyDeep, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  void _handleDownload(Map<String, dynamic> doc) {
    if (!doc['isAuthorized']) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Document "${doc['title']}" is currently ${doc['status']}.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Downloading "${doc['title']}" (${doc['fileSize']})...'),
        backgroundColor: const Color(0xFF0F5132),
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
        title: const Text('Official Documents & Records', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_to_photos_outlined, color: AppColors.gold),
            tooltip: 'Request Document',
            onPressed: _showRequestDocumentModal,
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header Request Banner
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.verified, color: AppColors.gold, size: 28),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Digital Document Verification', style: TextStyle(color: AppColors.onNavy, fontWeight: FontWeight.bold, fontSize: 13)),
                          SizedBox(height: 2),
                          Text('All documents carry certified MINESUP QR codes and university seal.', style: TextStyle(color: AppColors.muted, fontSize: 11)),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.gold,
                        foregroundColor: AppColors.navyDeep,
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      onPressed: _showRequestDocumentModal,
                      child: const Text('Request New', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              const Text('CERTIFIED UNIVERSITY DOCUMENTS', style: TextStyle(color: AppColors.muted, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.6)),
              const SizedBox(height: 8),

              ListView.builder(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: _documents.length,
                itemBuilder: (context, i) {
                  final doc = _documents[i];
                  final isAuth = doc['isAuthorized'] as bool;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.navy,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: isAuth ? AppColors.gold : AppColors.border),
                        ),
                        child: Icon(
                          isAuth ? Icons.picture_as_pdf : Icons.pending_actions,
                          color: isAuth ? AppColors.gold : Colors.orange,
                          size: 22,
                        ),
                      ),
                      title: Text(
                        doc['title'],
                        style: const TextStyle(color: AppColors.onNavy, fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 3),
                          Text('Ref: ${doc['reference']} • ${doc['category']}', style: const TextStyle(color: AppColors.muted, fontSize: 11)),
                          const SizedBox(height: 2),
                          Text(
                            doc['status'],
                            style: TextStyle(
                              color: isAuth ? const Color(0xFF34D399) : Colors.orange,
                              fontSize: 10.5,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      trailing: IconButton(
                        icon: Icon(
                          isAuth ? Icons.download : Icons.info_outline,
                          color: isAuth ? AppColors.gold : AppColors.muted,
                        ),
                        onPressed: () => _handleDownload(doc),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
