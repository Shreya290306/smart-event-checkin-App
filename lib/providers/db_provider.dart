import 'dart:convert';
import 'package:http/http.dart' as http;
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
  
  final String _dbUrl = "https://smart-event-checking-app-default-rtdb.asia-southeast1.firebasedatabase.app";

  Future<void> init() async {
    Hive.registerAdapter(EventModelAdapter());
    Hive.registerAdapter(ParticipantModelAdapter());

    eventBox = await Hive.openBox<EventModel>('events');
    participantBox = await Hive.openBox<ParticipantModel>('participants');
  }

  // Events
  Future<void> saveEvent(EventModel event) async {
    // Save locally
    await eventBox.put(event.id, event);
    
    // Sync to Firebase (Background)
    try {
      await http.put(
        Uri.parse('$_dbUrl/events/${event.id}.json'),
        body: jsonEncode({
          'id': event.id,
          'name': event.name,
          'date': event.date.toIso8601String(),
          'maxCapacity': event.maxCapacity,
        }),
      );
    } catch (e) {
      print('Firebase sync event failed: $e');
    }
  }

  EventModel? getEvent(String id) {
    return eventBox.get(id);
  }

  List<EventModel> getAllEvents() {
    return eventBox.values.toList();
  }

  // Participants
  Future<void> saveParticipant(ParticipantModel participant) async {
    // Save locally
    await participantBox.put(participant.id, participant);
    
    // Sync to Firebase (Background)
    try {
      await http.put(
        Uri.parse('$_dbUrl/events/${participant.eventId}/participants/${participant.id}.json'),
        body: jsonEncode({
          'id': participant.id,
          'name': participant.name,
          'eventId': participant.eventId,
          'checkInTime': participant.checkInTime.toIso8601String(),
        }),
      );
    } catch (e) {
      print('Firebase sync participant failed: $e');
    }
  }

  ParticipantModel? getParticipant(String id) {
    return participantBox.get(id);
  }

  List<ParticipantModel> getParticipantsForEvent(String eventId) {
    return participantBox.values.where((p) => p.eventId == eventId).toList();
  }
}
