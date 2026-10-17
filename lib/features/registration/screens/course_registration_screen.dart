import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/errors/app_exception.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/error_state.dart';
import '../../../core/widgets/section_header.dart';
import '../../../core/widgets/status_chip.dart';
import '../models/course_registration_entities.dart';
import '../providers/course_registration_providers.dart';

class CourseRegistrationScreen extends ConsumerStatefulWidget {
  const CourseRegistrationScreen({
    super.key,
    this.embedded = false,
  });

  static const routePath = '/course-registration';

  final bool embedded;

  @override
  ConsumerState<CourseRegistrationScreen> createState() =>
      _CourseRegistrationScreenState();
}

class _CourseRegistrationScreenState
    extends ConsumerState<CourseRegistrationScreen> {
  String? _busyOfferingId;

  Future<void> _toggleRegistration(
    CourseOfferingItem item,
    String semesterId,
  ) async {
    setState(() => _busyOfferingId = item.offeringId);
    final repo = ref.read(courseRegistrationRepositoryProvider);
    try {
      if (item.isRegistered) {
        await repo.dropCourse(
          courseOfferingId: item.offeringId,
          semesterId: semesterId,
        );
      } else {
        await repo.registerCourse(
          courseOfferingId: item.offeringId,
          semesterId: semesterId,
        );
      }
      ref.invalidate(courseOfferingsProvider(semesterId));
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            item.isRegistered
                ? 'Dropped ${item.courseCode}'
                : 'Registered for ${item.courseCode}',
          ),
        ),
      );
    } on AppException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Theme.of(context).colorScheme.error,
          content: Text(e.message),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _busyOfferingId = null);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final semesterAsync = ref.watch(currentSemesterProvider);

    final body = semesterAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => ErrorState(
        message: 'Failed to load current semester: $err',
        onRetry: () => ref.invalidate(currentSemesterProvider),
      ),
      data: (semester) {
        if (semester == null) {
          return const EmptyState(
            icon: Icons.calendar_today_outlined,
            title: 'No active semester configured',
            subtitle: 'Please ask an administrator to activate a semester.',
          );
        }

        final accessAsync = ref.watch(semesterAccessProvider(semester.id));
        final offeringsAsync = ref.watch(courseOfferingsProvider(semester.id));

        return offeringsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, _) => ErrorState(
            message: 'Error loading course offerings: $err',
            onRetry: () => ref.invalidate(courseOfferingsProvider(semester.id)),
          ),
          data: (offerings) {
            final registeredItems =
                offerings.where((o) => o.isRegistered).toList();
            final registeredCredits = registeredItems.fold<int>(
              0,
              (sum, item) => sum + item.creditUnits,
            );
            final access = accessAsync.valueOrNull;
            final canRegister = access?.canRegister ?? true;
            final feeStatus = access?.feeStatus ?? 'cleared';
            final accessMessages = access?.messages ?? const <String>[];

            return RefreshIndicator(
              onRefresh: () async {
                ref.invalidate(courseOfferingsProvider(semester.id));
                ref.invalidate(semesterAccessProvider(semester.id));
                await ref.read(courseOfferingsProvider(semester.id).future);
              },
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  AppCard(
                    backgroundColor: AppColors.primary,
                    borderColor: AppColors.primaryLight,
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.calendar_month_outlined,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                semester.label,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            StatusChip(status: feeStatus),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            _StatBadge(
                              label: 'Registered Courses',
                              value: '${registeredItems.length}',
                            ),
                            const SizedBox(width: 12),
                            _StatBadge(
                              label: 'Total Credits',
                              value: '$registeredCredits CU',
                            ),
                          ],
                        ),
                        if (accessMessages.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          for (final msg in accessMessages)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 4),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.info_outline,
                                    size: 16,
                                    color: Colors.white70,
                                  ),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      msg,
                                      style: const TextStyle(
                                        color: Colors.white70,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  SectionHeader(
                    title: 'Eligible Course Offerings (${offerings.length})',
                    subtitle: 'Add or drop courses for ${semester.label}',
                  ),
                  const SizedBox(height: 6),
                  if (offerings.isEmpty)
                    const EmptyState(
                      icon: Icons.menu_book_outlined,
                      title: 'No course offerings published',
                      subtitle: 'Offerings for this semester will appear here.',
                    )
                  else
                    for (final item in offerings) ...[
                      AppCard(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Wrap(
                                    spacing: 8,
                                    runSpacing: 4,
                                    crossAxisAlignment:
                                        WrapCrossAlignment.center,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 3,
                                        ),
                                        decoration: BoxDecoration(
                                          color: AppColors.primaryContainer,
                                          borderRadius:
                                              BorderRadius.circular(6),
                                          border: Border.all(
                                            color: AppColors.primaryLight,
                                          ),
                                        ),
                                        child: Text(
                                          item.courseCode,
                                          style: const TextStyle(
                                            color: AppColors.primary,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                      Text(
                                        '${item.creditUnits} Credits',
                                        style: const TextStyle(
                                          color: AppColors.textSecondary,
                                          fontSize: 12,
                                        ),
                                      ),
                                      if (item.level != null)
                                        Text(
                                          '• Level ${item.level}',
                                          style: const TextStyle(
                                            color: AppColors.textSecondary,
                                            fontSize: 12,
                                          ),
                                        ),
                                      if (item.registrationStatus != null)
                                        StatusChip(
                                          status: item.registrationStatus!,
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    item.courseTitle,
                                    style: const TextStyle(
                                      color: AppColors.textPrimary,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            _busyOfferingId == item.offeringId
                                ? const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: AppColors.primary,
                                    ),
                                  )
                                : item.isRegistered
                                    ? OutlinedButton(
                                        style: OutlinedButton.styleFrom(
                                          foregroundColor: AppColors.error,
                                          side: const BorderSide(
                                            color: AppColors.error,
                                          ),
                                        ),
                                        onPressed: canRegister
                                            ? () => _toggleRegistration(
                                                  item,
                                                  semester.id,
                                                )
                                            : null,
                                        child: const Text('Drop'),
                                      )
                                    : FilledButton(
                                        onPressed: (canRegister &&
                                                item.isOpenForRegistration)
                                            ? () => _toggleRegistration(
                                                  item,
                                                  semester.id,
                                                )
                                            : null,
                                        child: const Text('Register'),
                                      ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                    ],
                ],
              ),
            );
          },
        );
      },
    );

    if (widget.embedded) return body;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Course Registration'),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: () {
              ref.invalidate(currentSemesterProvider);
              final sem = semesterAsync.valueOrNull;
              if (sem != null) {
                ref.invalidate(courseOfferingsProvider(sem.id));
                ref.invalidate(semesterAccessProvider(sem.id));
              }
            },
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: body,
    );
  }
}

class _StatBadge extends StatelessWidget {
  const _StatBadge({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.primaryContainer,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.primaryLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 11),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
