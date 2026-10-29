import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'core/network/api_config.dart';
import 'core/theme/app_theme.dart';
import 'features/onboarding/presentation/onboarding_screen.dart';
import 'features/splash/presentation/splash_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Log active API base URL so it's visible in the debug console when starting.
  if (kDebugMode) {
    debugPrint('╔══════════════════════════════════════════════════════');
    debugPrint('║  Ras Hotel API → ${ApiConfig.baseUrl}');
    debugPrint('║  Emulator:    --dart-define=API_BASE_URL=http://10.0.2.2:3000');
    debugPrint('║  Real device: --dart-define=API_BASE_URL=http://10.188.80.52:3000');
    debugPrint('╚══════════════════════════════════════════════════════');
  }

  runApp(const RasHotelApp());
}

class RasHotelApp extends StatelessWidget {
  const RasHotelApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ras Hotel',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const SplashScreen(
        nextScreen: OnboardingScreen(),
      ),
    );
  }
}
