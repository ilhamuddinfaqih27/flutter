import 'dart:convert';
import 'package:http/http.dart' as http;

class WeatherService {
  final String apiKey = "98108a3a2d97a754769daf61ad158913";
  final String city = "Bandung";
  
  Future<Map<String, dynamic>> getCurrentWeather() async {
    final url = Uri.parse(
      "https://api.openweathermap.org/data/2.5/weather?q=$city&units=metric&appid=$apiKey"
    );

    final res = await http.get(url);
    return jsonDecode(res.body);
  }

  Future<List> getForecast() async {
    final url = Uri.parse(
      "https://api.openweathermap.org/data/2.5/forecast?q=$city&units=metric&appid=$apiKey"
    );

    final res = await http.get(url);
    final data = jsonDecode(res.body);
    return data["list"]; 
  }

  Future<bool> willRainSoon() async {
    final forecast = await getForecast();

    
    for (int i = 0; i < 2; i++) {
      final f = forecast[i];
      final weather = f["weather"][0]["main"].toLowerCase();
      if (weather.contains("rain")) {
        return true;
      }
    }
    return false;
  }
}
