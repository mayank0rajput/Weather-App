import 'package:shared_preferences/shared_preferences.dart';

class CityPreferences {
  static const _keyCityName = 'city_name';
  static const _keyLatitude = 'latitude';
  static const _keyLongitude = 'longitude';

  static Future<void> saveCity(String cityName, String latitude, String longitude) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyCityName, cityName);
    await prefs.setString(_keyLatitude, latitude);
    await prefs.setString(_keyLongitude, longitude);
  }

  static Future<Map<String, dynamic>?> getCity() async {
    final prefs = await SharedPreferences.getInstance();
    final cityName = prefs.getString(_keyCityName);
    final latitude = prefs.getString(_keyLatitude);
    final longitude = prefs.getString(_keyLongitude);

    if (cityName != null && latitude != null && longitude != null) {
      return {
        'cityName': cityName,
        'latitude': latitude,
        'longitude': longitude,
      };
    }
    return null;
  }

  static Future<void> clearCity() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyCityName);
    await prefs.remove(_keyLatitude);
    await prefs.remove(_keyLongitude);
  }
}
