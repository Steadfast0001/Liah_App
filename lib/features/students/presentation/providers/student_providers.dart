import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/supabase_provider.dart';
import '../../data/repositories/student_repository_impl.dart';
import '../../domain/entities/student_entities.dart';
import '../../domain/repositories/student_repository.dart';

final studentRepositoryProvider = Provider<StudentRepository>((ref) {
  return StudentRepositoryImpl(
    ref.watch(supabaseClientProvider),
    ref.watch(edgeFunctionClientProvider),
  );
});

final studentSearchQueryProvider = StateProvider<String>((ref) => '');

final studentsListProvider = FutureProvider<List<StudentRecord>>((ref) async {
  final query = ref.watch(studentSearchQueryProvider);
  return ref.watch(studentRepositoryProvider).fetchStudents(searchQuery: query);
});

final programsListProvider = FutureProvider<List<ProgramOption>>((ref) async {
  return ref.watch(studentRepositoryProvider).fetchPrograms();
});

final cohortsByProgramProvider =
    FutureProvider.family<List<CohortOption>, String?>((ref, programId) async {
  return ref
      .watch(studentRepositoryProvider)
      .fetchCohorts(programId: programId);
});
