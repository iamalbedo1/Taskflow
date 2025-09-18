import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:taskflow/weather/api_key_service.dart';

class WeatherService {
  final ApiKeyService _apiKeyService = ApiKeyService();
  final String _baseUrl = 'https://api.weatherapi.com/v1/current.json';

  Future<Map<String, dynamic>> fetchWeather() async {
    try {
      final apiKey = await _apiKeyService.getApiKey();
      if (apiKey == null || apiKey.isEmpty) {
        throw Exception('API key not found. Please set it first.');
      }

      Position position = await _determinePosition();

      final url = '$_baseUrl?key=$apiKey&q=${position.latitude},${position.longitude}';
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Nie udało się załadować danych o pogodzie (kod: ${response.statusCode})');
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Usługi lokalizacji są wyłączone.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Odmówiono uprawnień do lokalizacji.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Uprawnienia do lokalizacji są trwale odrzucone, nie możemy ich zażądać.');
    }

    return await Geolocator.getCurrentPosition();
  }
}
