import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:weather_app/models/Weather.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
class ApiClient {
  static var urlWeatherApi = 'api.openweathermap.org';
  static String apiKey = '0ec3c8d860087803ca6a4206f543f5aa';

  // ApiClient() : apiKey = dotenv.env['API_KEY'] ?? '';

  Future<List<String>> getCity(String q) async {
    var lat;
    var lon;
    var cname;
    var url = Uri.https(urlWeatherApi, 'geo/1.0/direct',
        {'appid': apiKey, 'limit': '5', 'q': q});

    var response = await http.get(url);
    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      var city = data[0];
      cname = city['name'];
      lat = city['lat'];
      lon = city['lon'];
    }
    List<String> cord = [cname.toString(), lat.toString(), lon.toString()];
    return cord;
  }

  Future<Weather> getCurrWeather(String lat, String lon) async {
    Weather city = new Weather();
    var url = Uri.https(urlWeatherApi, 'data/2.5/weather',
        {'appid': apiKey, 'lat': lat, 'lon': lon});
    var response = await http.get(url);
    if (response.statusCode == 200) {
      // print("data ${response.body}");
      Map<String, dynamic> decode = jsonDecode(response.body);
      city.weather = decode['weather'][0]['main'];
      city.temp = decode['main']['temp'].toString();
      city.feels_like = decode['main']['feels_like'].toString();
      city.temp_min = decode['main']['temp_min'].toString();
      city.temp_max = decode['main']['temp_max'].toString();
      city.pressure = decode['main']['pressure'].toString();
      city.humidity = decode['main']['humidity'].toString();
      city.sea_level = decode['main']['sea_level'].toString();
      city.grnd_level = decode['main']['grnd_level'].toString();
      return city;
    }
    return city;
  }

  Future<String> get5day(String lat, String lon) async {
    late String finalRes;
    var url = Uri.https(urlWeatherApi, 'data/2.5/forecast',
        {'appid': apiKey, 'lat': lat, 'lon': lon});
    var response = await http.get(url);
    if (response.statusCode == 200) {
      finalRes = response.body;
    }
    return finalRes;
  }
}
