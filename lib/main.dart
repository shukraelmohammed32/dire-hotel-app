import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'core/network/api_config.dart';
import 'core/theme/app_theme.dart';
import 'features/onboarding/presentation/onboarding_screen.dart';
import 'features/splash/presentation/splash_screen.dart';
import 'l10n/app_localizations.dart';

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

class RasHotelApp extends StatefulWidget {
  const RasHotelApp({super.key});

  static void setLocale(BuildContext context, Locale locale) {
    _RasHotelAppState? state = context.findAncestorStateOfType<_RasHotelAppState>();
    state?.setLocale(locale);
  }

  @override
  State<RasHotelApp> createState() => _RasHotelAppState();
}

class _RasHotelAppState extends State<RasHotelApp> {
  Locale _locale = const Locale('en');

  void setLocale(Locale locale) {
    setState(() => _locale = locale);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ras Hotel',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      locale: _locale,
      supportedLocales: const [
        Locale('en', ''), // English
        Locale('am', ''), // Amharic
      ],
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: SplashScreen(
        nextScreen: const OnboardingScreen(),
      ),
    );
  }
}
