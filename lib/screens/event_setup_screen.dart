import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/app_state.dart';

class EventSetupScreen extends ConsumerStatefulWidget {
  const EventSetupScreen({super.key});

  @override
  ConsumerState<EventSetupScreen> createState() => _EventSetupScreenState();
}

class _EventSetupScreenState extends ConsumerState<EventSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _capacityController = TextEditingController();

  void _createEvent() async {
    if (_formKey.currentState!.validate()) {
      final name = _nameController.text;
      final capacity = int.parse(_capacityController.text);
      
      await ref.read(eventsNotifierProvider.notifier).addEvent(name, DateTime.now(), capacity);
      
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Event created successfully!')),
      );
      _nameController.clear();
      _capacityController.clear();
    }
  }

  void _selectEvent(String eventId) {
    ref.read(currentEventIdProvider.notifier).state = eventId;
    context.go('/dashboard');
  }

  @override
  Widget build(BuildContext context) {
    final events = ref.watch(eventsNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Smart Check-in'),
        centerTitle: false,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth > 800;
          
          Widget createForm = Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Create New Event', style: Theme.of(context).textTheme.displaySmall),
                const SizedBox(height: 24),
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'Event Name',
                          prefixIcon: Icon(LucideIcons.calendar),
                        ),
                        validator: (value) => value!.isEmpty ? 'Required' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _capacityController,
                        decoration: const InputDecoration(
                          labelText: 'Maximum Capacity',
                          prefixIcon: Icon(LucideIcons.users),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) return 'Required';
                          if (int.tryParse(value) == null) return 'Must be a number';
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _createEvent,
                          icon: const Icon(LucideIcons.plus),
                          label: const Text('Create Event'),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ).animate().fadeIn().slideY(begin: 0.1),
          );

          Widget eventList = Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Select Existing Event', style: Theme.of(context).textTheme.displaySmall),
                const SizedBox(height: 24),
                events.isEmpty
                    ? const Center(child: Text('No events found. Create one!'))
                    : ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: events.length,
                        itemBuilder: (context, index) {
                          final event = events[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: ListTile(
                              title: Text(event.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                              subtitle: Text('Capacity: ${event.maxCapacity}'),
                              trailing: const Icon(LucideIcons.chevronRight),
                              onTap: () => _selectEvent(event.id),
                            ),
                          ).animate().fadeIn(delay: Duration(milliseconds: index * 50)).slideX();
                        },
                      ),
              ],
            ),
          );

          if (isWide) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: createForm),
                const VerticalDivider(width: 1),
                Expanded(child: SingleChildScrollView(child: eventList)),
              ],
            );
          } else {
            return SingleChildScrollView(
              child: Column(
                children: [
                  createForm,
                  const Divider(height: 1),
                  eventList,
                ],
              ),
            );
          }
        },
      ),
    );
  }
}
