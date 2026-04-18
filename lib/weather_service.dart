import 'dart:convert';
import 'package:http/http.dart' as http;

class WeatherService {
  static const String _apiKey = 'ff9a4f579a20a53fe98ffa300ef9538e';
  static const String _baseUrl = 'https://api.openweathermap.org/data/2.5';

  static Future<Map<String, dynamic>> getWeather(double lat, double lon) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/weather?lat=$lat&lon=$lon&appid=$_apiKey&units=metric&lang=ar'),
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'temp': data['main']['temp'].round(),
          'description': data['weather'][0]['description'],
          'icon': _getWeatherIcon(data['weather'][0]['main']),
          'humidity': data['main']['humidity'],
          'wind': data['wind']['speed'],
          'city': data['name'],
        };
      }
    } catch (e) {
      print('Weather error: $e');
    }
    return {
      'temp': 38,
      'description': 'صافٍ',
      'icon': '🌤️',
      'humidity': 20,
      'wind': 15,
      'city': 'الرياض',
    };
  }

  static String _getWeatherIcon(String main) {
    switch (main) {
      case 'Clear': return '☀️';
      case 'Clouds': return '☁️';
      case 'Rain': return '🌧️';
      case 'Thunderstorm': return '⛈️';
      case 'Drizzle': return '🌦️';
      case 'Snow': return '❄️';
      case 'Dust':
      case 'Sand':
      case 'Haze': return '🌫️';
      case 'Fog': return '🌁';
      default: return '🌤️';
    }
  }
}