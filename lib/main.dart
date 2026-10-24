import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';
import 'features/onboarding/presentation/onboarding_screen.dart';
import 'features/splash/presentation/splash_screen.dart';

void main() {
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
