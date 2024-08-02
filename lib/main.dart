import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:weather_app/models/weather_data.dart';
import 'package:weather_app/pages/home_page.dart';

void main() async{
  // await dotenv.load();
  await Hive.initFlutter();
  Hive.registerAdapter(weatherdataAdapter());
  await Hive.openBox<weather_data>('weatherdata');
  runApp(MainApp());
}

class MainApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomePage(),
    );
  }
}
