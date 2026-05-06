import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../screens/dashboard_screen.dart';
import '../screens/event_setup_screen.dart';
import '../screens/checkin_screen.dart';
import '../screens/logs_screen.dart';
import '../screens/auth_screen.dart';
import '../screens/student_dashboard_screen.dart';
import '../screens/main_layout.dart';
import '../providers/app_state.dart';
import '../models/user_model.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final rootNavigatorKey = GlobalKey<NavigatorState>();
  final shellNavigatorKey = GlobalKey<NavigatorState>();

  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: '/auth',
    redirect: (context, state) {
      final user = ref.read(currentUserProvider);
      final isAuthRoute = state.uri.toString() == '/auth';

      if (user == null) {
        return isAuthRoute ? null : '/auth';
      }

      if (isAuthRoute) {
        return user.role == UserRole.admin ? '/' : '/student';
      }

      if (user.role == UserRole.student && state.uri.toString() != '/student') {
        return '/student';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/auth',
        builder: (context, state) => const AuthScreen(),
      ),
      GoRoute(
        path: '/student',
        builder: (context, state) => const StudentDashboardScreen(),
      ),
      ShellRoute(
        navigatorKey: shellNavigatorKey,
        builder: (context, state, child) => MainLayout(child: child),
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => const EventSetupScreen(),
          ),
          GoRoute(
            path: '/dashboard',
            builder: (context, state) => const DashboardScreen(),
          ),
          GoRoute(
            path: '/checkin',
            builder: (context, state) => const CheckinScreen(),
          ),
          GoRoute(
            path: '/logs',
            builder: (context, state) => const LogsScreen(),
          ),
        ],
      ),
    ],
  );
});
