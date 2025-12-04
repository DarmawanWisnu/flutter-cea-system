import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fountaine/features/add_kit/add_kit_screen.dart';
import 'package:fountaine/features/auth/login_screen.dart';
import 'package:fountaine/features/auth/register_screen.dart';
import 'package:fountaine/features/auth/verify_screen.dart';
import 'package:fountaine/features/auth/forgot_password_screen.dart';
import 'package:fountaine/features/history/history_screen.dart';
import 'package:fountaine/features/home/home_screen.dart';
import 'package:fountaine/features/monitor/monitor_screen.dart';
import 'package:fountaine/features/settings/settings_screen.dart';
import 'package:fountaine/features/profile/profile_screen.dart';
import 'package:fountaine/features/notifications/notification_screen.dart';
import 'package:fountaine/providers/provider/auth_provider.dart';
import 'package:fountaine/models/nav_args.dart';

/// AUTH GATE
class AuthGate extends ConsumerWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    return authState.when(
      data: (user) {
        if (user == null) return const LoginScreen();
        if (!user.emailVerified) return const VerifyScreen();
        return const HomeScreen();
      },
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) =>
          Scaffold(body: Center(child: Text('Terjadi kesalahan: $e'))),
    );
  }
}

/// ROUTE DEFINITIONS
class Routes {
  static const splash = '/';
  static const login = '/login';
  static const register = '/register';
  static const verify = '/verify';
  static const home = '/home';
  static const monitor = '/monitor';
  static const history = '/history';
  static const addKit = '/addkit';
  static const settings = '/settings';
  static const forgotPassword = '/forgot_password';
  static const profile = '/profile';
  static const notifications = '/notifications';

  static final routes = <String, WidgetBuilder>{
    splash: (_) => const AuthGate(),
    login: (_) => const LoginScreen(),
    register: (_) => const RegisterScreen(),
    verify: (_) => const VerifyScreen(),
    home: (_) => const HomeScreen(),
    notifications: (_) => const NotificationScreen(),
    addKit: (_) => const AddKitScreen(),
    settings: (_) => const SettingsScreen(),
    forgotPassword: (_) => const ForgotPasswordScreen(),
    profile: (_) => const ProfileScreen(),
  };
}

/// ON GENERATE ROUTE
Route<dynamic>? onGenerateRoute(RouteSettings settings) {
  switch (settings.name) {
    // MONITOR SCREEN
    case Routes.monitor:
      final args = settings.arguments as Map?;
      final kitId = args?['kitId'] as String?;

      return MaterialPageRoute(
        builder: (_) => MonitorScreen(selectedKit: kitId),
        settings: settings,
      );

    // HISTORY SCREEN
    case Routes.history:
      final args = settings.arguments;
      String? kitId;
      DateTime? target;

      if (args is HistoryRouteArgs) {
        kitId = args.kitId;
        target = args.targetTime;
      } else if (args is Map) {
        kitId = args['kitId'] as String?;
        target = args['targetTime'] as DateTime?;
      }

      return MaterialPageRoute(
        builder: (_) => HistoryScreen(kitId: kitId, targetTime: target),
        settings: settings,
      );

    // DEFAULT ROUTING
    default:
      final builder = Routes.routes[settings.name];
      if (builder != null) {
        return MaterialPageRoute(builder: builder, settings: settings);
      }

      return MaterialPageRoute(
        builder: (_) =>
            const Scaffold(body: Center(child: Text('Route tidak dikenal'))),
        settings: settings,
      );
  }
}
