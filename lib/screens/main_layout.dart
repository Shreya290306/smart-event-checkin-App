import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/app_state.dart';

class MainLayout extends ConsumerWidget {
  final Widget child;

  const MainLayout({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final location = GoRouterState.of(context).uri.toString();

    int currentIndex = 0;
    if (location.startsWith('/checkin')) {
      currentIndex = 1;
    } else if (location.startsWith('/dashboard')) {
      currentIndex = 2;
    } else if (location.startsWith('/logs')) {
      currentIndex = 3;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Smart Event Check-in'),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.logOut),
            onPressed: () {
              ref.read(currentUserProvider.notifier).state = null;
              context.go('/auth');
            },
          )
        ],
      ),
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (index) {
          switch (index) {
            case 0:
              context.go('/');
              break;
            case 1:
              context.go('/checkin');
              break;
            case 2:
              context.go('/dashboard');
              break;
            case 3:
              context.go('/logs');
              break;
          }
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Theme.of(context).primaryColor,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(LucideIcons.settings), label: 'Setup'),
          BottomNavigationBarItem(icon: Icon(LucideIcons.scanLine), label: 'Check-in'),
          BottomNavigationBarItem(icon: Icon(LucideIcons.layoutDashboard), label: 'Dashboard'),
          BottomNavigationBarItem(icon: Icon(LucideIcons.fileText), label: 'Logs'),
        ],
      ),
    );
  }
}
