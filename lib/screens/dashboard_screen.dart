import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/app_state.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final event = ref.watch(currentEventProvider);
    final stats = ref.watch(dashboardStatsProvider);

    if (event == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Dashboard')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('No event selected.'),
              ElevatedButton(
                onPressed: () => context.go('/'),
                child: const Text('Go to Setup'),
              )
            ],
          ),
        ),
      );
    }

    final double percentFull = stats['percentFull'] ?? 0.0;
    final String status = stats['status'] ?? 'Safe';
    
    Color statusColor = Colors.greenAccent;
    if (status == 'Full') statusColor = Colors.redAccent;
    else if (status == 'Moderate') statusColor = Colors.orangeAccent;

    return Scaffold(
      appBar: AppBar(
        title: Text(event.name),
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft),
          onPressed: () => context.go('/'),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Capacity Indicator
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  children: [
                    Text('Live Capacity', style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 32),
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 200,
                          height: 200,
                          child: TweenAnimationBuilder<double>(
                            tween: Tween<double>(begin: 0, end: percentFull),
                            duration: const Duration(seconds: 1),
                            builder: (context, value, _) => CircularProgressIndicator(
                              value: value,
                              strokeWidth: 16,
                              backgroundColor: Colors.white10,
                              color: statusColor,
                              strokeCap: StrokeCap.round,
                            ),
                          ),
                        ),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '${stats['checkedIn']} / ${stats['totalCapacity']}',
                              style: Theme.of(context).textTheme.displaySmall,
                            ),
                            Text(
                              status.toUpperCase(),
                              style: TextStyle(
                                color: statusColor,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 2,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStatItem(context, 'Checked In', '${stats['checkedIn']}'),
                        _buildStatItem(context, 'Remaining', '${stats['remaining']}'),
                      ],
                    )
                  ],
                ),
              ),
            ).animate().fadeIn().scale(),
            
            const SizedBox(height: 32),
            
            // Actions
            Row(
              children: [
                Expanded(
                  child: _buildActionCard(
                    context,
                    title: 'Check-in',
                    icon: LucideIcons.qrCode,
                    color: Theme.of(context).primaryColor,
                    onTap: () => context.push('/checkin'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildActionCard(
                    context,
                    title: 'Logs',
                    icon: LucideIcons.list,
                    color: Theme.of(context).colorScheme.secondary,
                    onTap: () => context.push('/logs'),
                  ),
                ),
              ],
            ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.2),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(BuildContext context, String label, String value) {
    return Column(
      children: [
        Text(value, style: Theme.of(context).textTheme.titleLarge),
        Text(label, style: Theme.of(context).textTheme.bodyMedium),
      ],
    );
  }

  Widget _buildActionCard(BuildContext context, {required String title, required IconData icon, required Color color, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 24),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.5)),
        ),
        child: Column(
          children: [
            Icon(icon, size: 48, color: color),
            const SizedBox(height: 12),
            Text(title, style: Theme.of(context).textTheme.titleMedium),
          ],
        ),
      ),
    );
  }
}
