import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/supabase_provider.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/entities/auth_session.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/repositories/auth_repository.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(ref.watch(supabaseClientProvider));
});

final authSessionProvider = StreamProvider<AuthSession?>((ref) {
  return ref.watch(authRepositoryProvider).watchSession();
});

final currentUserProfileProvider = FutureProvider<UserProfile?>((ref) async {
  final session = await ref.watch(authSessionProvider.future);
  if (session == null) {
    final current = await ref.watch(authRepositoryProvider).currentSession();
    if (current == null) return null;
  }
  return ref.watch(authRepositoryProvider).fetchCurrentUserProfile();
});
