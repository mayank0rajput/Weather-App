import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:intl/intl.dart';
import 'package:weather_app/models/Weather.dart';
import 'package:weather_app/network/apiclient.dart';
import 'package:weather_app/shared_prefs/helper.dart';

import '../models/WeatherData.dart';
import '../models/weather_data.dart';

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Box<weather_data>? weatherBox;
  ApiClient apiclient = new ApiClient();
  String cityName = 'Hyderabad'; //city name
  String latitude = '17.360589';
  String longitude = '78.4740613';
  double currTemp = 0; // current temperature
  double maxTemp = 30; // today max temperature
  double minTemp = 2; // today min temperature
  String weatherMain = '';

  bool isloading = true;

  late Weather currCity;
  double kelvinToCelsius(double kelvin){
    return kelvin - 273.15;
  }

  Future<void> fetchData() async {
    setState(() {
      isloading = true;
    });
    // Simulate fetching data from API
    final response = await apiclient.get5day(latitude, longitude);
    List<dynamic> data = json.decode(response)['list'];

    // Clear existing data
    await weatherBox!.clear();

    // Add fetched data to Hive box
    for (var i = 0; i < data.length; i=i+8) {
      var item = data[i];
      DateTime dateTime = DateTime.parse(item['dt_txt']);
      String dayOfWeek = DateFormat('EEEE').format(dateTime);
      double minTemp = item['main']['temp_min'];
      double maxTemp = item['main']['temp_max'];

      weather_data weatherData = weather_data()
        ..dayOfWeek = dayOfWeek
        ..minTemp = minTemp
        ..maxTemp = maxTemp;

      await weatherBox!.put(i, weatherData);
    }
    setState(() {
      isloading = false;
    });
  }


  Future<void> loadWeather() async {
    currCity = await apiclient.getCurrWeather(latitude, longitude);
    if (currCity.temp != null){
      String nonNull = currCity.temp!;
      currTemp = double.parse(nonNull);
    }
    if (currCity.temp_min != null){
      String nonNull = currCity.temp_min!;
      minTemp = double.parse(nonNull);
    }
    if (currCity.temp_max != null){
      String nonNull = currCity.temp_max!;
      maxTemp = double.parse(nonNull);
    }
    weatherMain = currCity.weather!;
    setState(() {});
  }

  Future<void> loadCityData() async {
    Map<String, dynamic>? cityInfo = await CityPreferences.getCity();
    if (cityInfo != null) {
      setState(() {
        cityName = cityInfo['cityName'];
        latitude = cityInfo['latitude'];
        longitude = cityInfo['longitude'];
      });
    }

  }

  void saveCityData(String name, String lat, String lon) async {
    await CityPreferences.saveCity(name, lat, lon);
    loadCityData(); // Refresh the UI with the saved information
  }

  @override
  void initState() {
    loadCityData();
    loadWeather();
    super.initState();
    weatherBox = Hive.box('weatherdata');
    fetchData();
  }
  @override
  Widget build(BuildContext context) {

    Size size = Size(400, 900);
    var brightness = MediaQuery.of(context).platformBrightness;
    bool isDarkMode = brightness == Brightness.dark;

    Widget heading = Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Align(
          child: Text(
            'Weather Forecast App',
            style: GoogleFonts.questrial(
              color: isDarkMode ? Colors.white : const Color(0xff1D1617),
              fontSize: size.height * 0.02,
            ),
          ),
        ),
      ],
    );

    TextEditingController _controller = TextEditingController();

    void _searchCity() async {
      List<String> cityData = await apiclient.getCity(_controller.text);
      setState(() {
        cityName = cityData[0];
        saveCityData(cityData[0], cityData[1], cityData[2]);
        loadWeather();
        fetchData();
      });
    }

    return Scaffold(
      body: Center(
        child: Container(
          height: size.height,
          width: size.height,
          decoration: BoxDecoration(
            color: isDarkMode ? Colors.black : Colors.white,
          ),
          child: SafeArea(
            child: Stack(
              children: [
                SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(
                          vertical: size.height * 0.01,
                          horizontal: size.width * 0.05,
                        ),
                        child: heading,
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        child: Form(
                          child: Row(children: [
                            Expanded(
                              // width: size.width * 0.75,
                              child: TextField(
                                controller: _controller,
                                cursorColor: Colors.redAccent,
                                style: TextStyle(
                                  color: isDarkMode
                                      ? Colors.white
                                      : Colors.black
                                ),
                                decoration: InputDecoration(
                                  labelText: "Search",
                                  labelStyle:
                                      TextStyle(color: Colors.redAccent),
                                  focusedBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(
                                          color: isDarkMode
                                              ? Colors.white
                                              : Colors.black54)),
                                  enabledBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(
                                          color: isDarkMode
                                              ? Colors.white.withOpacity(0.5)
                                              : Colors.black.withOpacity(0.5))),
                                ),
                              ),
                            ),
                            ElevatedButton(
                              onPressed: _searchCity,
                              child: Icon(Icons.search,color: Colors.redAccent,),
                            )
                          ]),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                          top: size.height * 0.03,
                        ),
                        child: Align(
                          child: Text(
                            '${cityName}',
                            style: GoogleFonts.questrial(
                              color: isDarkMode ? Colors.white : Colors.black,
                              fontSize: size.height * 0.06,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ), //just padding
                      Padding(
                        padding: EdgeInsets.only(
                          top: size.height * 0.005,
                        ),
                        child: Align(
                          child: Text(
                            'Today', //day
                            style: GoogleFonts.questrial(
                              color:
                                  isDarkMode ? Colors.white54 : Colors.black54,
                              fontSize: size.height * 0.035,
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                          top: size.height * 0.003,
                        ),
                        child: Align(
                          child: Text(
                            '${kelvinToCelsius(currTemp).toStringAsFixed(2)}˚C', //curent temperature
                            style: GoogleFonts.questrial(
                              color: currTemp <= 0
                                  ? Colors.blue
                                  : currTemp > 0 && currTemp <= 15
                                      ? Colors.indigo
                                      : currTemp > 15 && currTemp < 30
                                          ? Colors.deepPurple
                                          : Colors.pink,
                              fontSize: size.height * 0.10,
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: size.width * 0.25, vertical: 0),
                        child: Divider(
                          color: isDarkMode ? Colors.white : Colors.black,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                          top: size.height * 0.0005,
                        ),
                        child: Align(
                          child: Text(
                            '$weatherMain', // weather
                            style: GoogleFonts.questrial(
                              color:
                                  isDarkMode ? Colors.white54 : Colors.black54,
                              fontSize: size.height * 0.03,
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                          top: size.height * 0.03,
                          bottom: size.height * 0.01,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '${kelvinToCelsius(minTemp).toStringAsFixed(2)}˚C', // min temperature
                              style: GoogleFonts.questrial(
                                color: minTemp <= 0
                                    ? Colors.blue
                                    : minTemp > 0 && minTemp <= 15
                                        ? Colors.indigo
                                        : minTemp > 15 && minTemp < 30
                                            ? Colors.deepPurple
                                            : Colors.pink,
                                fontSize: size.height * 0.03,
                              ),
                            ),
                            Text(
                              '/',
                              style: GoogleFonts.questrial(
                                color: isDarkMode
                                    ? Colors.white54
                                    : Colors.black54,
                                fontSize: size.height * 0.03,
                              ),
                            ),
                            Text(
                              '${kelvinToCelsius(maxTemp).toStringAsFixed(2)}˚C', //max temperature
                              style: GoogleFonts.questrial(
                                color: maxTemp <= 0
                                    ? Colors.blue
                                    : maxTemp > 0 && maxTemp <= 15
                                        ? Colors.indigo
                                        : maxTemp > 15 && maxTemp < 30
                                            ? Colors.deepPurple
                                            : Colors.pink,
                                fontSize: size.height * 0.03,
                              ),
                            ),
                          ],
                        ),
                      ),

                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: size.width * 0.05,
                          vertical: size.height * 0.02,
                        ),
                        child: isloading ?
                        Center(child: CircularProgressIndicator(),) :
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: const BorderRadius.all(
                              Radius.circular(10),
                            ),
                            color: Colors.white.withOpacity(0.05),
                          ),
                          child: Column(
                            children: [
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Padding(
                                  padding: EdgeInsets.only(
                                    top: size.height * 0.02,
                                    left: size.width * 0.03,
                                  ),
                                  child: Text(
                                    '5-day forecast',
                                    style: GoogleFonts.questrial(
                                      color: isDarkMode
                                          ? Colors.white
                                          : Colors.black,
                                      fontSize: size.height * 0.025,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              Divider(
                                color: isDarkMode ? Colors.white : Colors.black,
                              ),
                              Padding(
                                padding: EdgeInsets.all(size.width * 0.005),
                                child: ValueListenableBuilder(
                                  valueListenable: weatherBox!.listenable(),
                                    builder: (context, Box<weather_data> box, _) {
                                      if (box.values.isEmpty) {
                                        return Center(child: Text('No data available'));
                                      } else {
                                        return Column(
                                          children: [
                                            buildSevenDayForecast(
                                                box.getAt(0)!.dayOfWeek,
                                                box.getAt(0)!.minTemp,
                                                box.getAt(0)!.maxTemp,
                                                FontAwesomeIcons.cloudRain,
                                                size,
                                                isDarkMode
                                            ),
                                            buildSevenDayForecast(
                                                box.getAt(1)!.dayOfWeek,
                                                box.getAt(1)!.minTemp,
                                                box.getAt(1)!.maxTemp,
                                                FontAwesomeIcons.cloudRain,
                                                size,
                                                isDarkMode
                                            ),
                                            buildSevenDayForecast(
                                                box.getAt(2)!.dayOfWeek,
                                                box.getAt(2)!.minTemp,
                                                box.getAt(2)!.maxTemp,
                                                FontAwesomeIcons.cloudRain,
                                                size,
                                                isDarkMode
                                            ),
                                            buildSevenDayForecast(
                                                box.getAt(3)!.dayOfWeek,
                                                box.getAt(3)!.minTemp,
                                                box.getAt(3)!.maxTemp,
                                                FontAwesomeIcons.cloudRain,
                                                size,
                                                isDarkMode
                                            ),
                                            buildSevenDayForecast(
                                                box.getAt(4)!.dayOfWeek,
                                                box.getAt(4)!.minTemp,
                                                box.getAt(4)!.maxTemp,
                                                FontAwesomeIcons.cloudRain,
                                                size,
                                                isDarkMode
                                            ),
                                          ],
                                        );
                                      }
                                    }

                                )
                              )
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildSevenDayForecast(String time, double minTemp, double maxTemp,
      IconData weatherIcon, size, bool isDarkMode) {
    return Padding(
      padding: EdgeInsets.all(
        size.height * 0.005,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: size.width * 0.02,
                ),
                child: Text(
                  time,
                  style: GoogleFonts.questrial(
                    color: isDarkMode ? Colors.white : Colors.black,
                    fontSize: size.height * 0.025,
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: size.width * 0.25,
                ),
                child: FaIcon(
                  weatherIcon,
                  color: isDarkMode ? Colors.white : Colors.black,
                  size: size.height * 0.03,
                ),
              ),
              Align(
                child: Padding(
                  padding: EdgeInsets.only(
                    left: size.width * 0.15,
                  ),
                  child: Text(
                    '${kelvinToCelsius(minTemp).toStringAsFixed(2)}˚C',
                    style: GoogleFonts.questrial(
                      color: isDarkMode ? Colors.white38 : Colors.black38,
                      fontSize: size.height * 0.025,
                    ),
                  ),
                ),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: size.width * 0.05,
                  ),
                  child: Text(
                    '${kelvinToCelsius(maxTemp).toStringAsFixed(2)}˚C',
                    style: GoogleFonts.questrial(
                      color: isDarkMode ? Colors.white : Colors.black,
                      fontSize: size.height * 0.025,
                    ),
                  ),
                ),
              ),
            ],
          ),
          Divider(
            color: isDarkMode ? Colors.white : Colors.black,
          ),
        ],
      ),
    );
  }
}
