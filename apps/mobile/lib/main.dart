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

class NavKey {
  static final navKey = GlobalKey<NavigatorState>();
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Load environment variables
    await dotenv.load(fileName: ".env");
    
    if (kDebugMode) {
      print('Environment variables loaded successfully');
    }

    // Initialize Firebase
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    
    if (kDebugMode) {
      print('Firebase initialized successfully');
    }

    // Activate Firebase App Check
    await FirebaseAppCheck.instance.activate(
      androidProvider: kDebugMode
          ? AndroidProvider.debug
          : AndroidProvider.playIntegrity,
    );
    
    if (kDebugMode) {
      print('Firebase App Check activated');
    }
  } catch (e, stackTrace) {
    if (kDebugMode) {
      print('Firebase initialization error: $e');
      print('Stack trace: $stackTrace');
    }
    
    // Show error to user and exit
    runApp(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.red,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Firebase Initialization Failed',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    e.toString(),
                    style: const TextStyle(fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Please check:\n'
                    '• Your internet connection\n'
                    '• Firebase configuration in .env file\n'
                    '• google-services.json file',
                    style: TextStyle(fontSize: 12),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
    return; // Exit early if Firebase fails to initialize
  }

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
      navigatorKey: NavKey.navKey,
      title: 'Flutter-CEA-System',
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
