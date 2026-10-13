import 'package:equatable/equatable.dart';

class AuthSession extends Equatable {
  const AuthSession({
    required this.userId,
    required this.email,
  });

  final String userId;
  final String email;

  @override
  List<Object?> get props => [userId, email];
}
