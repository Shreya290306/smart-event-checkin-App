import 'package:hive/hive.dart';

part 'event_model.g.dart';

@HiveType(typeId: 0)
class EventModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  DateTime date;

  @HiveField(3)
  int maxCapacity;

  EventModel({
    required this.id,
    required this.name,
    required this.date,
    required this.maxCapacity,
  });
}
