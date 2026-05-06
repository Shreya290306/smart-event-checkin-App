// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'participant_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ParticipantModelAdapter extends TypeAdapter<ParticipantModel> {
  @override
  final int typeId = 1;

  @override
  ParticipantModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ParticipantModel(
      id: fields[0] as String,
      name: fields[1] as String?,
      eventId: fields[2] as String,
      checkInTime: fields[3] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, ParticipantModel obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.eventId)
      ..writeByte(3)
      ..write(obj.checkInTime);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ParticipantModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
