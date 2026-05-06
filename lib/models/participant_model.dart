import 'package:hive/hive.dart';

part 'participant_model.g.dart';

@HiveType(typeId: 1)
class ParticipantModel extends HiveObject {
  @HiveField(0)
  String id; // QR code or manual ID

  @HiveField(1)
  String? name;

  @HiveField(2)
  String eventId;

  @HiveField(3)
  DateTime checkInTime;

  ParticipantModel({
    required this.id,
    this.name,
    required this.eventId,
    required this.checkInTime,
  });
}
