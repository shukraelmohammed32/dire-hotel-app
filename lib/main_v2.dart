import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'core/network/api_config.dart';
import 'core/theme/app_theme_v2.dart';
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

  runApp(const RasHotelAppV2());
}

class RasHotelAppV2 extends StatefulWidget {
  const RasHotelAppV2({super.key});

  static void setLocale(BuildContext context, Locale locale) {
    _RasHotelAppV2State? state = context.findAncestorStateOfType<_RasHotelAppV2State>();
    state?.setLocale(locale);
  }

  @override
  State<RasHotelAppV2> createState() => _RasHotelAppV2State();
}

class _RasHotelAppV2State extends State<RasHotelAppV2> {
  Locale _locale = const Locale('en');

  void setLocale(Locale locale) {
    setState(() => _locale = locale);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ras Hotel',
      debugShowCheckedModeBanner: false,
      theme: RSTheme.light,
      darkTheme: RSTheme.dark,
      themeMode: ThemeMode.light,
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