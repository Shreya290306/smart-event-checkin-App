import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:intl/intl.dart';
import '../providers/app_state.dart';

class LogsScreen extends ConsumerStatefulWidget {
  const LogsScreen({super.key});

  @override
  ConsumerState<LogsScreen> createState() => _LogsScreenState();
}

class _LogsScreenState extends ConsumerState<LogsScreen> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final participants = ref.watch(activeEventParticipantsProvider);
    
    final filtered = participants.where((p) {
      final query = _searchQuery.toLowerCase();
      final idMatch = p.id.toLowerCase().contains(query);
      final nameMatch = p.name?.toLowerCase().contains(query) ?? false;
      return idMatch || nameMatch;
    }).toList();

    // Sort by check-in time descending
    filtered.sort((a, b) => b.checkInTime.compareTo(a.checkInTime));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Check-in Logs'),
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft),
          onPressed: () => context.pop(),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              onChanged: (value) => setState(() => _searchQuery = value),
              decoration: InputDecoration(
                hintText: 'Search by ID or Name...',
                prefixIcon: const Icon(LucideIcons.search),
                filled: true,
                fillColor: Theme.of(context).cardColor,
              ),
            ),
          ),
          Expanded(
            child: filtered.isEmpty
                ? const Center(child: Text('No participants found.'))
                : ListView.builder(
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final p = filtered[index];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Theme.of(context).primaryColor.withOpacity(0.2),
                          child: const Icon(LucideIcons.checkCircle2, color: Colors.greenAccent),
                        ),
                        title: Text(p.name?.isNotEmpty == true ? p.name! : 'ID: ${p.id}', 
                            style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(p.name?.isNotEmpty == true ? 'ID: ${p.id}' : 'Manual/QR Entry'),
                        trailing: Text(
                          DateFormat('hh:mm a').format(p.checkInTime),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
