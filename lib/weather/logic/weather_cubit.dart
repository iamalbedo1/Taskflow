import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:taskflow/weather/weather_service.dart';

// Definicja możliwych stanów dla pogody
abstract class WeatherState extends Equatable {
  final String? apiKey;
  const WeatherState({this.apiKey});
  @override
  List<Object> get props => [apiKey ?? ''];
}

class WeatherInitial extends WeatherState {
  const WeatherInitial({super.apiKey});
}
class WeatherLoading extends WeatherState {
  const WeatherLoading({super.apiKey});
}
class WeatherLoaded extends WeatherState {
  final String locationName;
  final double tempC;
  final String conditionIconUrl;

  const WeatherLoaded({
    required this.locationName,
    required this.tempC,
    required this.conditionIconUrl,
    super.apiKey,
  });

  @override
  List<Object> get props => [locationName, tempC, conditionIconUrl, apiKey ?? ''];
}
class WeatherError extends WeatherState {
  final String message;
  const WeatherError(this.message, {super.apiKey});
  @override
  List<Object> get props => [message, apiKey ?? ''];
}

class WeatherCubit extends Cubit<WeatherState> {
  final WeatherService Function(String apiKey) _weatherServiceFactory;
  WeatherService? _weatherService;

  WeatherCubit(this._weatherServiceFactory) : super(const WeatherInitial());

  void setApiKey(String apiKey) {
    _weatherService = _weatherServiceFactory(apiKey);
    emit(WeatherInitial(apiKey: apiKey));
    fetchWeather();
  }

  Future<void> fetchWeather() async {
    if (_weatherService == null || state.apiKey == null) {
      emit(const WeatherError('Proszę podać klucz API WeatherAPI.', apiKey: null));
      return;
    }

    emit(WeatherLoading(apiKey: state.apiKey));
    try {
      final weatherData = await _weatherService!.fetchWeather();
      final locationName = weatherData['location']['name'];
      final tempC = weatherData['current']['temp_c'];
      final conditionIconUrl = 'http:${weatherData['current']['condition']['icon']}';

      emit(WeatherLoaded(
        locationName: locationName,
        tempC: tempC,
        conditionIconUrl: conditionIconUrl,
        apiKey: state.apiKey,
      ));
    } catch (e) {
      emit(WeatherError(e.toString(), apiKey: state.apiKey));
    }
  }
}