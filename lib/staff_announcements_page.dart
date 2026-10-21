import 'package:flutter/material.dart';
import 'package:liah_app/app_colors.dart';

class StaffNoticeItem {
  final String id;
  final String title;
  final String content;
  final String date;
  final String author;
  final String target; // 'Faculty Wide' | 'SWE201' | 'CEF205'
  final bool isPriority;
  final String? attachmentName;

  const StaffNoticeItem({
    required this.id,
    required this.title,
    required this.content,
    required this.date,
    required this.author,
    required this.target,
    this.isPriority = false,
    this.attachmentName,
  });
}

/// Staff Announcements Page (Section 5 — Lecturer / Staff Pages)
/// UI content: Relevant notices and course communication.
/// Required interactions: Read notices and create permitted announcements if authorized.
class StaffAnnouncementsPage extends StatefulWidget {
  final bool isAuthorizedToPost;

  const StaffAnnouncementsPage({
    super.key,
    this.isAuthorizedToPost = true,
  });

  @override
  State<StaffAnnouncementsPage> createState() => _StaffAnnouncementsPageState();
}

class _StaffAnnouncementsPageState extends State<StaffAnnouncementsPage> {
  String _selectedFilter = 'All'; // 'All' | 'Faculty Circulars' | 'My Course Broadcasts'

  final List<StaffNoticeItem> _notices = [
    const StaffNoticeItem(
      id: 'NTC-001',
      title: 'Senate Grade Moderation Deadline (2026/2027 S1)',
      content:
          'All First Semester Continuous Assessment (30%) sheets must be submitted through the portal by Friday 25 November at 17:00. Late submissions will require written justification to the Vice-Chancellor.',
      date: '20 Oct 2026',
      author: 'Academic Registrar & Senate Office',
      target: 'Faculty Wide',
      isPriority: true,
      attachmentName: 'Senate_Circular_Grading_S1_2026.pdf',
    ),
    const StaffNoticeItem(
      id: 'NTC-002',
      title: 'SWE201: Continuous Assessment Assignment 1 Published',
      content:
          'Assignment 1 on Big-O Complexity and Linked Lists has been uploaded to the course workspace. Deadline for submission is 30 Oct 2026 at 23:59.',
      date: '18 Oct 2026',
      author: 'Engr. Divine Mbella (You)',
      target: 'SWE201',
      isPriority: false,
      attachmentName: 'SWE201_Assignment_1_Rubric.pdf',
    ),
    const StaffNoticeItem(
      id: 'NTC-003',
      title: 'Faculty Board Meeting & Research Colloquium',
      content:
          'The monthly Department of Computer Science Board Meeting is scheduled for Thursday 29 October at 15:00 in Conference Room B. Agenda: Curriculum review and industry partnership with CamTel.',
      date: '15 Oct 2026',
      author: 'Head of Department (Prof. Fonkeng)',
      target: 'Faculty Wide',
      isPriority: false,
    ),
  ];

  void _showCreateAnnouncementDialog() {
    final titleCtrl = TextEditingController();
    final messageCtrl = TextEditingController();
    String selectedCourse = 'SWE201';
    bool highPriority = false;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (dialogCtx, setDialogState) {
            return AlertDialog(
              backgroundColor: AppColors.surface,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              title: const Text(
                'Broadcast Course Announcement',
                style: TextStyle(color: AppColors.onNavy, fontWeight: FontWeight.bold, fontSize: 15),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Target Course', style: TextStyle(color: AppColors.muted, fontSize: 11)),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                        color: AppColors.navy,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: DropdownButton<String>(
                        value: selectedCourse,
                        isExpanded: true,
                        dropdownColor: AppColors.surface,
                        underline: const SizedBox.shrink(),
                        style: const TextStyle(color: AppColors.gold, fontWeight: FontWeight.bold, fontSize: 12),
                        items: const [
                          DropdownMenuItem(value: 'SWE201', child: Text('SWE201: Data Structures')),
                          DropdownMenuItem(value: 'CEF205', child: Text('CEF205: Computer Architecture')),
                          DropdownMenuItem(value: 'SWE203', child: Text('SWE203: OOP Java')),
                        ],
                        onChanged: (val) {
                          if (val != null) setDialogState(() => selectedCourse = val);
                        },
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text('Announcement Title', style: TextStyle(color: AppColors.muted, fontSize: 11)),
                    const SizedBox(height: 4),
                    TextField(
                      controller: titleCtrl,
                      style: const TextStyle(color: AppColors.onNavy, fontSize: 13),
                      decoration: InputDecoration(
                        hintText: 'e.g. Lab Session Rescheduled',
                        hintStyle: const TextStyle(color: AppColors.muted, fontSize: 12),
                        filled: true,
                        fillColor: AppColors.navy,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text('Message Body', style: TextStyle(color: AppColors.muted, fontSize: 11)),
                    const SizedBox(height: 4),
                    TextField(
                      controller: messageCtrl,
                      maxLines: 4,
                      style: const TextStyle(color: AppColors.onNavy, fontSize: 13),
                      decoration: InputDecoration(
                        hintText: 'Enter broadcast instructions for students...',
                        hintStyle: const TextStyle(color: AppColors.muted, fontSize: 12),
                        filled: true,
                        fillColor: AppColors.navy,
                        contentPadding: const EdgeInsets.all(10),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Checkbox(
                          activeColor: AppColors.gold,
                          checkColor: AppColors.navyDeep,
                          value: highPriority,
                          onChanged: (val) => setDialogState(() => highPriority = val ?? false),
                        ),
                        const Text('Mark as High Priority Alert', style: TextStyle(color: AppColors.onNavy, fontSize: 12)),
                      ],
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
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.gold,
                    foregroundColor: AppColors.navyDeep,
                  ),
                  onPressed: () {
                    final t = titleCtrl.text.trim();
                    final m = messageCtrl.text.trim();
                    if (t.isEmpty || m.isEmpty) return;

                    setState(() {
                      _notices.insert(
                        0,
                        StaffNoticeItem(
                          id: 'NTC-00${_notices.length + 1}',
                          title: t,
                          content: m,
                          date: 'Just now',
                          author: 'Engr. Divine Mbella (You)',
                          target: selectedCourse,
                          isPriority: highPriority,
                        ),
                      );
                    });
                    Navigator.pop(ctx);

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        backgroundColor: const Color(0xFF0F5132),
                        content: Text('Announcement broadcasted to $selectedCourse students.'),
                      ),
                    );
                  },
                  child: const Text('Broadcast Now', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showNoticeDetailModal(StaffNoticeItem notice) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: notice.isPriority ? const Color(0xFF5E1717) : AppColors.navy,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: notice.isPriority ? const Color(0xFFF87171) : AppColors.gold),
                    ),
                    child: Text(
                      notice.target,
                      style: TextStyle(
                        color: notice.isPriority ? const Color(0xFFF87171) : AppColors.gold,
                        fontSize: 10.5,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Text(notice.date, style: const TextStyle(color: AppColors.muted, fontSize: 11)),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                notice.title,
                style: const TextStyle(color: AppColors.onNavy, fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text('Issued by: ${notice.author}', style: const TextStyle(color: AppColors.gold, fontSize: 11.5)),
              const Divider(color: AppColors.border, height: 20),
              Text(
                notice.content,
                style: const TextStyle(color: AppColors.onNavy, fontSize: 13, height: 1.45),
              ),
              if (notice.attachmentName != null) ...[
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.navy,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.picture_as_pdf, color: AppColors.gold, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          notice.attachmentName!,
                          style: const TextStyle(color: AppColors.gold, fontSize: 12, fontWeight: FontWeight.w600),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.download, color: AppColors.gold, size: 18),
                        onPressed: () {
                          Navigator.pop(ctx);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Downloading ${notice.attachmentName}...')),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _notices.where((n) {
      if (_selectedFilter == 'Faculty Circulars') return n.target == 'Faculty Wide';
      if (_selectedFilter == 'My Course Broadcasts') return n.target != 'Faculty Wide';
      return true;
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.navy,
      appBar: AppBar(
        backgroundColor: AppColors.navyDeep,
        elevation: 0,
        title: const Text(
          'Faculty Notices & Announcements',
          style: TextStyle(color: AppColors.onNavy, fontSize: 16, fontWeight: FontWeight.bold),
        ),
        actions: [
          if (widget.isAuthorizedToPost)
            IconButton(
              icon: const Icon(Icons.campaign, color: AppColors.gold),
              tooltip: 'Broadcast Announcement',
              onPressed: _showCreateAnnouncementDialog,
            ),
        ],
      ),
      body: Column(
        children: [
          // Filter Tabs
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            color: AppColors.surface,
            child: Row(
              children: [
                _buildFilterChip('All'),
                const SizedBox(width: 8),
                _buildFilterChip('Faculty Circulars'),
                const SizedBox(width: 8),
                _buildFilterChip('My Course Broadcasts'),
              ],
            ),
          ),

          // Notices List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: filtered.length,
              itemBuilder: (context, i) {
                final notice = filtered[i];
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: notice.isPriority ? const Color(0xFFEF4444) : AppColors.border,
                      width: notice.isPriority ? 1.2 : 0.8,
                    ),
                  ),
                  child: ListTile(
                    onTap: () => _showNoticeDetailModal(notice),
                    contentPadding: const EdgeInsets.all(12),
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.navy,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(notice.target, style: const TextStyle(color: AppColors.gold, fontSize: 10, fontWeight: FontWeight.bold)),
                        ),
                        Text(notice.date, style: const TextStyle(color: AppColors.muted, fontSize: 10.5)),
                      ],
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 6),
                        Text(
                          notice.title,
                          style: const TextStyle(color: AppColors.onNavy, fontSize: 13.5, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          notice.content,
                          style: const TextStyle(color: AppColors.muted, fontSize: 11.5),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (notice.attachmentName != null) ...[
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              const Icon(Icons.attachment, size: 12, color: AppColors.gold),
                              const SizedBox(width: 4),
                              Text(notice.attachmentName!, style: const TextStyle(color: AppColors.gold, fontSize: 10.5)),
                            ],
                          ),
                        ],
                      ],
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 12, color: AppColors.muted),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: widget.isAuthorizedToPost
          ? FloatingActionButton.extended(
              backgroundColor: AppColors.gold,
              foregroundColor: AppColors.navyDeep,
              icon: const Icon(Icons.add_comment),
              label: const Text('New Notice', style: TextStyle(fontWeight: FontWeight.bold)),
              onPressed: _showCreateAnnouncementDialog,
            )
          : null,
    );
  }

  Widget _buildFilterChip(String label) {
    final isSelected = _selectedFilter == label;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      selectedColor: AppColors.gold,
      backgroundColor: AppColors.navy,
      labelStyle: TextStyle(
        color: isSelected ? AppColors.navyDeep : AppColors.muted,
        fontWeight: FontWeight.bold,
        fontSize: 11,
      ),
      onSelected: (val) {
        if (val) setState(() => _selectedFilter = label);
      },
    );
  }
}
