import 'package:hive/hive.dart';

part 'weather_data.g.dart';

@HiveType(typeId: 0)
class weather_data extends HiveObject {
  @HiveField(0)
  late String dayOfWeek;

  @HiveField(1)
  late double minTemp;

  @HiveField(2)
  late double maxTemp;
}