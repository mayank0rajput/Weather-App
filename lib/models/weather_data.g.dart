// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'weather_data.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class weatherdataAdapter extends TypeAdapter<weather_data> {
  @override
  final int typeId = 0;

  @override
  weather_data read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return weather_data()
      ..dayOfWeek = fields[0] as String
      ..minTemp = fields[1] as double
      ..maxTemp = fields[2] as double;
  }

  @override
  void write(BinaryWriter writer, weather_data obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.dayOfWeek)
      ..writeByte(1)
      ..write(obj.minTemp)
      ..writeByte(2)
      ..write(obj.maxTemp);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is weatherdataAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
