import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:fountaine/firebase_options.dart';
import 'package:fountaine/app/routes.dart';
import 'package:fountaine/providers/provider/api_provider.dart';
import 'package:fountaine/services/api_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await FirebaseAppCheck.instance.activate(
    androidProvider: kDebugMode
        ? AndroidProvider.debug
        : AndroidProvider.playIntegrity,
  );

  runApp(
    ProviderScope(
      overrides: [
        // Override base ApiService
        apiServiceProvider.overrideWithValue(
          ApiService(
            baseUrl:
                dotenv.env['API_BASE_URL'] ??
                'http://10.0.2.2:8000', // default emulator
          ),
        ),
        // Override telemetry ApiService
        apiServiceProvider.overrideWithValue(
          ApiService(
            baseUrl: dotenv.env['API_BASE_URL'] ?? 'http://10.0.2.2:8000',
          ),
        ),
      ],
      child: const FountaineApp(),
    ),
  );
}

class FountaineApp extends StatelessWidget {
  const FountaineApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fountaine',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF65FFF0),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      initialRoute: Routes.monitor,
      // home: const AuthGate(),
      routes: Routes.routes,
      onGenerateRoute: onGenerateRoute,
    );
  }
}
