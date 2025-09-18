import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taskflow/notifications/notification_service.dart';
import 'package:taskflow/stats/logic/stats_cubit.dart';
import 'package:taskflow/tasks/data/database.dart';
import 'package:taskflow/tasks/data/task_repository.dart';
import 'package:taskflow/tasks/logic/tasks_cubit.dart';
import 'package:taskflow/weather/logic/weather_cubit.dart';
import 'package:taskflow/weather/weather_service.dart';
import 'package:taskflow/weather/api_key_service.dart';
import 'package:taskflow/main_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final notificationService = NotificationService();
  await notificationService.initialize();

  final database = AppDatabase();

  final repository = TaskRepository(
    database: database,
    notificationService: notificationService,
  );

  final apiKeyService = ApiKeyService();
  final weatherService = WeatherService(); // WeatherService no longer needs apiKey in constructor

  runApp(
    RepositoryProvider.value(
      value: repository,
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => TasksCubit(
              repository: context.read<TaskRepository>(),
            ),
          ),
          BlocProvider(
            create: (context) => StatsCubit(
              repository: context.read<TaskRepository>(),
            ),
          ),
          BlocProvider(
            create: (context) => WeatherCubit(weatherService, apiKeyService)
              ..fetchWeather(),
          ),
        ],
        child: const MyApp(),
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TaskFlow',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      home: const MainScreen(),
    );
  }
}