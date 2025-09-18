import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:taskflow/weather/logic/weather_cubit.dart';

class WeatherWidget extends StatefulWidget {
  const WeatherWidget({super.key});

  @override
  State<WeatherWidget> createState() => _WeatherWidgetState();
}

class _WeatherWidgetState extends State<WeatherWidget> {
  final TextEditingController _apiKeyController = TextEditingController();

  @override
  void dispose() {
    _apiKeyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WeatherCubit, WeatherState>(
      builder: (context, state) {
        if (state.apiKey == null || state.apiKey!.isEmpty) {
          return _buildApiKeyInput(context);
        }
        if (state is WeatherLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is WeatherLoaded) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blueAccent.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.network(state.conditionIconUrl, width: 40, height: 40),
                const SizedBox(width: 12),
                Text(
                  '${state.tempC.toStringAsFixed(0)}°C w ${state.locationName}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          );
        }
        if (state is WeatherError) {
          final isLocationServiceError = state.message.contains('Usługi lokalizacji są wyłączone');
          final isLocationPermissionError = state.message.contains('Odmówiono uprawnień');
          final isApiKeyMissingError = state.message.contains('Proszę podać klucz API WeatherAPI.');

          if (isApiKeyMissingError) {
            return _buildApiKeyInput(context, errorMessage: state.message);
          }

          if (isLocationServiceError || isLocationPermissionError) {
            String errorMessage;
            if (Platform.isMacOS) {
              errorMessage =
                  'Aby wyświetlić pogodę, zezwól na dostęp do lokalizacji w Ustawieniach Systemowych > Prywatność i ochrona > Usługi lokalizacji.';
            } else {
              errorMessage = isLocationServiceError
                  ? 'Aby wyświetlić pogodę, włącz usługi lokalizacji.'
                  : 'Aplikacja wymaga uprawnień do lokalizacji, aby wyświetlić pogodę.';
            }

            return Container(
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.errorContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Text(
                    errorMessage,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onErrorContainer,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextButton(
                        onPressed: () => Geolocator.openLocationSettings(),
                        style: TextButton.styleFrom(
                          foregroundColor:
                              Theme.of(context).colorScheme.onErrorContainer,
                        ),
                        child: const Text('Otwórz ustawienia'),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () =>
                            context.read<WeatherCubit>().fetchWeather(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).colorScheme.error,
                          foregroundColor:
                              Theme.of(context).colorScheme.onError,
                        ),
                        child: const Text('Spróbuj ponownie'),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Błąd pogody: ${state.message}',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.red.shade800),
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildApiKeyInput(BuildContext context, {String? errorMessage}) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            errorMessage ?? 'Proszę podać swój klucz API WeatherAPI, aby wyświetlić pogodę.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _apiKeyController,
            decoration: InputDecoration(
              labelText: 'Klucz API WeatherAPI',
              border: const OutlineInputBorder(),
              errorText: errorMessage != null ? '' : null, // Show error border if there's an error
            ),
            onSubmitted: (value) {
              if (value.isNotEmpty) {
                context.read<WeatherCubit>().setApiKey(value);
              }
            },
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: () {
              if (_apiKeyController.text.isNotEmpty) {
                context.read<WeatherCubit>().setApiKey(_apiKeyController.text);
              }
            },
            child: const Text('Zapisz klucz i pobierz pogodę'),
          ),
        ],
      ),
    );
  }
}
