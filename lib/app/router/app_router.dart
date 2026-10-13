import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/authentication/presentation/screens/forgot_password_screen.dart';
import '../../features/authentication/presentation/screens/login_screen.dart';
import '../../features/authentication/presentation/screens/reset_password_confirmation_screen.dart';
import '../../features/authentication/presentation/screens/splash_screen.dart';
import '../../features/course_registration/presentation/screens/course_registration_screen.dart';
import '../../features/dashboard/presentation/screens/role_dashboard_screen.dart';
import '../../features/students/presentation/screens/create_student_screen.dart';
import '../../features/students/presentation/screens/student_list_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: SplashScreen.routePath,
    routes: [
      GoRoute(
        path: SplashScreen.routePath,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: LoginScreen.routePath,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: ForgotPasswordScreen.routePath,
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: ResetPasswordConfirmationScreen.routePath,
        builder: (context, state) => ResetPasswordConfirmationScreen(
          email: state.uri.queryParameters['email'],
        ),
      ),
      GoRoute(
        path: RoleDashboardScreen.routePath,
        builder: (context, state) => const RoleDashboardScreen(),
      ),
      GoRoute(
        path: StudentListScreen.routePath,
        builder: (context, state) => const StudentListScreen(),
      ),
      GoRoute(
        path: CreateStudentScreen.routePath,
        builder: (context, state) => const CreateStudentScreen(),
      ),
      GoRoute(
        path: CourseRegistrationScreen.routePath,
        builder: (context, state) => const CourseRegistrationScreen(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(child: Text(state.error?.toString() ?? 'Unknown error')),
    ),
  );
});
