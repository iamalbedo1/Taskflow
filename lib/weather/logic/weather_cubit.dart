import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:taskflow/weather/weather_service.dart';
import 'package:taskflow/weather/api_key_service.dart';

// Definicja możliwych stanów dla pogody
abstract class WeatherState extends Equatable {
  const WeatherState();
  @override
  List<Object> get props => [];
}

class WeatherInitial extends WeatherState {}
class WeatherLoading extends WeatherState {}
class WeatherApiKeyRequired extends WeatherState {}

class WeatherLoaded extends WeatherState {
  final String locationName;
  final double tempC;
  final String conditionIconUrl;

  const WeatherLoaded({
    required this.locationName,
    required this.tempC,
    required this.conditionIconUrl,
  });

  @override
  List<Object> get props => [locationName, tempC, conditionIconUrl];
}
class WeatherError extends WeatherState {
  final String message;
  const WeatherError(this.message);
  @override
  List<Object> get props => [message];
}

class WeatherCubit extends Cubit<WeatherState> {
  final WeatherService _weatherService;
  final ApiKeyService _apiKeyService;

  WeatherCubit(this._weatherService, this._apiKeyService) : super(WeatherInitial());

  Future<void> fetchWeather() async {
    emit(WeatherLoading());
    try {
      final weatherData = await _weatherService.fetchWeather();
      final locationName = weatherData['location']['name'];
      final tempC = weatherData['current']['temp_c'];
      final conditionIconUrl = 'http:${weatherData['current']['condition']['icon']}';

      emit(WeatherLoaded(
        locationName: locationName,
        tempC: tempC,
        conditionIconUrl: conditionIconUrl,
      ));
    } catch (e) {
      if (e.toString().contains('API key not found')) {
        emit(WeatherApiKeyRequired());
      } else {
        emit(WeatherError(e.toString()));
      }
    }
  }

  Future<void> setApiKey(String apiKey) async {
    await _apiKeyService.saveApiKey(apiKey);
    fetchWeather();
  }
}