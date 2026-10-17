import '../models/auth_session.dart';
import '../models/user_profile.dart';

abstract class AuthRepository {
  Stream<AuthSession?> watchSession();

  Future<AuthSession?> currentSession();

  Future<UserProfile?> fetchCurrentUserProfile();

  Future<void> signInWithPassword({
    required String email,
    required String password,
  });

  Future<void> signOut();

  Future<void> sendPasswordReset(String email);
}
