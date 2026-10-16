import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/utils/date_format.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/error_state.dart';
import '../../../../core/widgets/matricule_badge.dart';
import '../../../../core/widgets/status_chip.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../providers/student_providers.dart';
import 'create_student_screen.dart';

class StudentListScreen extends ConsumerWidget {
  const StudentListScreen({
    super.key,
    this.embedded = false,
  });

  static const routePath = '/students';

  final bool embedded;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final studentsAsync = ref.watch(studentsListProvider);
    final profile = ref.watch(currentUserProfileProvider).valueOrNull;
    final canCreate = profile?.canManageStudents ?? true;

    final content = Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: TextField(
            onChanged: (value) {
              ref.read(studentSearchQueryProvider.notifier).state = value;
            },
            decoration: const InputDecoration(
              hintText: 'Search by name, matricule, email, or program...',
              prefixIcon: Icon(Icons.search),
            ),
          ),
        ),
        Expanded(
          child: studentsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, _) => ErrorState(
              message: err.toString(),
              onRetry: () => ref.invalidate(studentsListProvider),
            ),
            data: (students) {
              if (students.isEmpty) {
                return EmptyState(
                  icon: Icons.people_outline,
                  title: 'No students found',
                  subtitle:
                      'Use the "Create Student" button to enroll a new student via the admin Edge Function.',
                  actionLabel: canCreate ? 'Create Student' : null,
                  onAction: canCreate
                      ? () => context.push(CreateStudentScreen.routePath)
                      : null,
                );
              }

              return RefreshIndicator(
                onRefresh: () async {
                  ref.invalidate(studentsListProvider);
                  await ref.read(studentsListProvider.future);
                },
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
                  itemCount: students.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final s = students[index];
                    return AppCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  s.fullName,
                                  style: const TextStyle(
                                    color: AppColors.onNavy,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              StatusChip(status: s.status),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 10,
                            runSpacing: 6,
                            children: [
                              MatriculeBadge(matricule: s.matricule),
                              _MetaPill(
                                icon: Icons.school_outlined,
                                text: '${s.programCode} • ${s.programName}',
                              ),
                              if (s.cohortLabel != null)
                                _MetaPill(
                                  icon: Icons.groups_outlined,
                                  text: s.cohortLabel!,
                                ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              const Icon(
                                Icons.email_outlined,
                                size: 15,
                                color: AppColors.muted,
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  s.email,
                                  style: const TextStyle(
                                    color: AppColors.muted,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                              Text(
                                'Admitted ${AppDateFormat.shortDate(s.admissionDate)}',
                                style: const TextStyle(
                                  color: AppColors.muted,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ),
      ],
    );

    if (embedded) {
      return Scaffold(
        backgroundColor: Colors.transparent,
        floatingActionButton: canCreate
            ? FloatingActionButton.extended(
                backgroundColor: AppColors.gold,
                foregroundColor: AppColors.navyDeep,
                onPressed: () => context.push(CreateStudentScreen.routePath),
                icon: const Icon(Icons.person_add_alt_1),
                label: const Text('Create Student'),
              )
            : null,
        body: content,
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Management'),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: () => ref.invalidate(studentsListProvider),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      floatingActionButton: canCreate
          ? FloatingActionButton.extended(
              backgroundColor: AppColors.gold,
              foregroundColor: AppColors.navyDeep,
              onPressed: () => context.push(CreateStudentScreen.routePath),
              icon: const Icon(Icons.person_add_alt_1),
              label: const Text('Create Student'),
            )
          : null,
      body: content,
    );
  }
}

class _MetaPill extends StatelessWidget {
  const _MetaPill({
    required this.icon,
    required this.text,
  });

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.surfaceRaised,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.muted),
          const SizedBox(width: 4),
          Text(
            text,
            style: const TextStyle(
              color: AppColors.onNavy,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
