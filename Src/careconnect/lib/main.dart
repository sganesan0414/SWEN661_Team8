import 'package:careconnect/screens/login_screen.dart';
import 'package:careconnect/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'services/notification_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await NotificationService().initialize();
  } catch (_) {
    // Notifications unavailable (e.g. emulator / missing permission) — continue anyway.
  }
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CareConnect',
      theme: AppTheme.theme,
      home: const LoginScreen(),
      // WCAG 2.1 SC 1.4.4: Resize text — support up to 200% without loss of content
      builder: (context, child) {
        final media = MediaQuery.of(context);
        return MediaQuery(
          data: media.copyWith(
            textScaler: media.textScaler.clamp(
              minScaleFactor: 1.0,
              maxScaleFactor: 2.0,
            ),
          ),
          child: child!,
        );
      },
    );
  }
}
