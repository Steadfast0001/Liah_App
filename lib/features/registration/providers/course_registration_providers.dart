import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/supabase_provider.dart';
import '../services/course_registration_repository_impl.dart';
import '../models/course_registration_entities.dart';
import '../services/course_registration_repository.dart';

final courseRegistrationRepositoryProvider =
    Provider<CourseRegistrationRepository>((ref) {
  return CourseRegistrationRepositoryImpl(
    ref.watch(supabaseClientProvider),
    ref.watch(edgeFunctionClientProvider),
  );
});

final currentSemesterProvider = FutureProvider<SemesterInfo?>((ref) async {
  return ref.watch(courseRegistrationRepositoryProvider).getCurrentSemester();
});

final semesterAccessProvider =
    FutureProvider.family<SemesterAccess, String>((ref, semesterId) async {
  return ref
      .watch(courseRegistrationRepositoryProvider)
      .getSemesterAccess(semesterId);
});

final courseOfferingsProvider =
    FutureProvider.family<List<CourseOfferingItem>, String>((ref, semesterId) async {
  return ref
      .watch(courseRegistrationRepositoryProvider)
      .fetchOfferings(semesterId);
});
