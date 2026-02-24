import 'package:weather/weather.dart';
import 'package:weather_app/const.dart'; 

class WeatherService {

  final WeatherFactory _wf = WeatherFactory(OPENWEATHER_API_KEY, language: Language.PORTUGUESE);


  Future<Weather?> getCityWeather(String cityName) async {
    try {

      Weather weather = await _wf.currentWeatherByCityName(cityName);
      return weather;
    } catch (e) {

      print("Erro na API: $e");
      return null; 
    }
  }
}