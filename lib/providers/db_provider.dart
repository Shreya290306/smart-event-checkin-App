import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/event_model.dart';
import '../models/participant_model.dart';

final dbProvider = Provider<DatabaseService>((ref) {
  return DatabaseService();
});

class DatabaseService {
  late Box<EventModel> eventBox;
  late Box<ParticipantModel> participantBox;

  Future<void> init() async {
    Hive.registerAdapter(EventModelAdapter());
    Hive.registerAdapter(ParticipantModelAdapter());

    eventBox = await Hive.openBox<EventModel>('events');
    participantBox = await Hive.openBox<ParticipantModel>('participants');
  }

  // Events
  Future<void> saveEvent(EventModel event) async {
    await eventBox.put(event.id, event);
  }

  EventModel? getEvent(String id) {
    return eventBox.get(id);
  }

  List<EventModel> getAllEvents() {
    return eventBox.values.toList();
  }

  // Participants
  Future<void> saveParticipant(ParticipantModel participant) async {
    await participantBox.put(participant.id, participant);
  }

  ParticipantModel? getParticipant(String id) {
    return participantBox.get(id);
  }

  List<ParticipantModel> getParticipantsForEvent(String eventId) {
    return participantBox.values.where((p) => p.eventId == eventId).toList();
  }
}
