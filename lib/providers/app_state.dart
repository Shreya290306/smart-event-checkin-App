import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/event_model.dart';
import '../models/participant_model.dart';
import 'db_provider.dart';
import 'package:uuid/uuid.dart';

// Provides the ID of the currently active event
final currentEventIdProvider = StateProvider<String?>((ref) => null);

// Provides the current active event model
final currentEventProvider = Provider<EventModel?>((ref) {
  final id = ref.watch(currentEventIdProvider);
  if (id == null) return null;
  final db = ref.watch(dbProvider);
  return db.getEvent(id);
});

// Provides the list of all events
final eventsListProvider = Provider<List<EventModel>>((ref) {
  // This could be made reactive if we used ValueListenableBuilder or Stream with Hive,
  // but for simplicity, we'll expose a notifier.
  return ref.watch(dbProvider).getAllEvents();
});

// A StateNotifier to handle event creation and trigger rebuilds
class EventsNotifier extends StateNotifier<List<EventModel>> {
  final DatabaseService db;

  EventsNotifier(this.db) : super(db.getAllEvents());

  Future<void> addEvent(String name, DateTime date, int maxCapacity) async {
    final newEvent = EventModel(
      id: const Uuid().v4(),
      name: name,
      date: date,
      maxCapacity: maxCapacity,
    );
    await db.saveEvent(newEvent);
    state = db.getAllEvents();
  }
}

final eventsNotifierProvider = StateNotifierProvider<EventsNotifier, List<EventModel>>((ref) {
  return EventsNotifier(ref.watch(dbProvider));
});


// A StateNotifier to handle check-ins and trigger rebuilds for a specific event
class CheckinNotifier extends StateNotifier<List<ParticipantModel>> {
  final DatabaseService db;
  final String eventId;

  CheckinNotifier(this.db, this.eventId) : super(db.getParticipantsForEvent(eventId));

  Future<String> checkInUser(String participantId, {String? name}) async {
    // 1. Validate if user is already checked in
    final existing = state.where((p) => p.id == participantId).toList();
    if (existing.isNotEmpty) {
      return "ERROR: User already checked in.";
    }

    // 2. Validate capacity
    final event = db.getEvent(eventId);
    if (event == null) return "ERROR: Event not found.";
    
    if (state.length >= event.maxCapacity) {
      return "ERROR: Event is at full capacity.";
    }

    // 3. Perform check-in
    final participant = ParticipantModel(
      id: participantId,
      name: name,
      eventId: eventId,
      checkInTime: DateTime.now(),
    );

    await db.saveParticipant(participant);
    state = db.getParticipantsForEvent(eventId);
    return "SUCCESS";
  }

  void refresh() {
    state = db.getParticipantsForEvent(eventId);
  }
}

// Provider for participants of the current event
final currentEventParticipantsProvider = StateNotifierProvider<CheckinNotifier, List<ParticipantModel>>((ref) {
  final eventId = ref.watch(currentEventIdProvider);
  if (eventId == null) {
    return CheckinNotifier(ref.watch(dbProvider), '');
  }
  return CheckinNotifier(ref.watch(dbProvider), eventId);
});

// Dashboard stats provider
final dashboardStatsProvider = Provider<Map<String, dynamic>>((ref) {
  final event = ref.watch(currentEventProvider);
  final participants = ref.watch(currentEventParticipantsProvider);
  
  if (event == null) return {};

  final checkedIn = participants.length;
  final remaining = event.maxCapacity - checkedIn;
  final percentFull = checkedIn / event.maxCapacity;
  
  String status = "Safe";
  if (percentFull >= 1.0) {
    status = "Full";
  } else if (percentFull > 0.75) {
    status = "Moderate";
  }

  return {
    "totalCapacity": event.maxCapacity,
    "checkedIn": checkedIn,
    "remaining": remaining,
    "percentFull": percentFull,
    "status": status,
  };
});
