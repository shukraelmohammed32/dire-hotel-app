import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../shell/presentation/app_shell.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 36, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.apartment_rounded,
                      color: AppColors.burgundy, size: 25),
                  const SizedBox(width: 9),
                  Text(
                    'RAS HOTEL',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: AppColors.burgundy,
                          letterSpacing: 2,
                        ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () => _openHome(context),
                    child: const Text('Skip'),
                  ),
                ],
              ),
              const SizedBox(height: 34),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(32),
                  child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.deepBurgundy, AppColors.wine],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: Image.asset(
                          'assets/images/hero_architecture.png',
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned.fill(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.black.withValues(alpha: .18),
                                Colors.black.withValues(alpha: .72),
                              ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        top: -30,
                        right: -26,
                        child: _circle(160, Colors.white.withValues(alpha: .08)),
                      ),
                      Positioned(
                        bottom: 42,
                        left: -50,
                        child: _circle(130, Colors.black.withValues(alpha: .08)),
                      ),
                      Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 142,
                              height: 142,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: .12),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.hotel_rounded,
                                color: Colors.white,
                                size: 74,
                              ),
                            ),
                            const SizedBox(height: 24),
                            const Text(
                              'Your stay,\nthoughtfully made.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 34,
                                fontWeight: FontWeight.w700,
                                fontFamily: 'serif',
                                height: 1.08,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Discover a calm, comfortable base\nfor every Dire Dawa moment.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: .78),
                                fontSize: 15,
                                height: 1.45,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                ),
              ),
              const SizedBox(height: 28),
              Row(
                children: [
                  Container(
                    width: 24,
                    height: 5,
                    decoration: BoxDecoration(
                      color: AppColors.burgundy,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  const SizedBox(width: 6),
                  ...List.generate(
                    2,
                    (_) => Padding(
                      padding: const EdgeInsets.only(left: 6),
                      child: Container(
                        width: 6,
                        height: 5,
                        decoration: BoxDecoration(
                          color: AppColors.border,
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: FilledButton(
                  onPressed: () => _openHome(context),
                  child: const Text('Explore Ras Hotel'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Widget _circle(double size, Color color) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      );

  void _openHome(BuildContext context) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(builder: (_) => const AppShell()),
    );
  }
}
