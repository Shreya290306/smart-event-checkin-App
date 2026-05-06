import 'package:go_router/go_router.dart';
import '../screens/dashboard_screen.dart';
import '../screens/event_setup_screen.dart';
import '../screens/checkin_screen.dart';
import '../screens/logs_screen.dart';

class AppRouter {
  static final router = GoRouter(
    initialLocation: '/',
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
  );
}
