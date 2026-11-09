import 'package:flutter/material.dart';

import '../../../core/theme/app_design_system.dart';
import '../../../core/theme/rs_components.dart';
import '../../shell/presentation/app_shell.dart';

class OnboardingScreenV2 extends StatelessWidget {
  const OnboardingScreenV2({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(RSSpacing.xl, RSSpacing.xxxl, RSSpacing.xl, RSSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Top bar ──────────────────────────────────────────────
              RSAnimatedSlide(
                begin: const Offset(0, -30),
                child: Row(
                  children: [
                    RSAnimatedFade(
                      child: Container(
                        padding: const EdgeInsets.all(RSSpacing.md),
                        decoration: BoxDecoration(
                          color: RSColors.rose100,
                          borderRadius: BorderRadius.circular(RSSpacing.radiusLg),
                        ),
                        child: const Icon(
                          Icons.apartment_rounded,
                          color: RSColors.burgundy,
                          size: RSIconSizes.lg,
                        ),
                      ),
                    ),
                    const SizedBox(width: RSSpacing.md),
                    RSAnimatedFade(
                      delay: const Duration(milliseconds: 100),
                      child: Text(
                        'RAS HOTEL',
                        style: RSTypography.labelLarge.copyWith(
                          color: RSColors.burgundy,
                          letterSpacing: 2,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const Spacer(),
                    RSAnimatedFade(
                      delay: const Duration(milliseconds: 200),
                      child: TextButton(
                        onPressed: () => _openHome(context),
                        child: Text(
                          'Skip',
                          style: RSTypography.labelLarge.copyWith(
                            color: RSColors.muted,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: RSSpacing.xxxl),

              // ── Hero Section ─────────────────────────────────────────
              Expanded(
                child: RSAnimatedSlide(
                  delay: const Duration(milliseconds: 200),
                  begin: const Offset(0, 40),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(RSSpacing.radiusXxxl),
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [RSColors.deepBurgundy, RSColors.wine],
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
                                    Colors.black.withValues(alpha: 0.15),
                                    Colors.black.withValues(alpha: 0.7),
                                  ],
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                ),
                              ),
                            ),
                          ),
                          // Decorative circles
                          Positioned(
                            top: -40,
                            right: -35,
                            child: _circle(180, Colors.white.withValues(alpha: 0.06)),
                          ),
                          Positioned(
                            bottom: 50,
                            left: -60,
                            child: _circle(150, Colors.black.withValues(alpha: 0.06)),
                          ),
                          // Content
                          Center(
                            child: Padding(
                              padding: const EdgeInsets.all(RSSpacing.xxxl),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  RSAnimatedScale(
                                    delay: const Duration(milliseconds: 300),
                                    child: Container(
                                      width: 160,
                                      height: 160,
                                      decoration: BoxDecoration(
                                        color: Colors.white.withValues(alpha: 0.12),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.hotel_rounded,
                                        color: Colors.white,
                                        size: 80,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: RSSpacing.xxl),
                                  RSAnimatedFade(
                                    delay: const Duration(milliseconds: 400),
                                    child: Text(
                                      'Your stay,\nthoughtfully made.',
                                      textAlign: TextAlign.center,
                                      style: RSTypography.displaySmall.copyWith(
                                        color: Colors.white,
                                        fontSize: 36,
                                        height: 1.08,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: RSSpacing.md),
                                  RSAnimatedFade(
                                    delay: const Duration(milliseconds: 500),
                                    child: Text(
                                      'Discover a calm, comfortable base\nfor every Dire Dawa moment.',
                                      textAlign: TextAlign.center,
                                      style: RSTypography.bodyLarge.copyWith(
                                        color: Colors.white.withValues(alpha: 0.8),
                                        height: 1.5,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: RSSpacing.xxxl),

              // ── Page Indicator ──────────────────────────────────────
              RSAnimatedFade(
                delay: const Duration(milliseconds: 600),
                child: Row(
                  children: [
                    Container(
                      width: 28,
                      height: 6,
                      decoration: BoxDecoration(
                        color: RSColors.burgundy,
                        borderRadius: BorderRadius.circular(RSSpacing.radiusFull),
                      ),
                    ),
                    const SizedBox(width: RSSpacing.sm),
                    ...List.generate(
                      2,
                      (_) => Padding(
                        padding: const EdgeInsets.only(left: RSSpacing.sm),
                        child: Container(
                          width: 8,
                          height: 6,
                          decoration: BoxDecoration(
                            color: RSColors.border,
                            borderRadius: BorderRadius.circular(RSSpacing.radiusFull),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: RSSpacing.xxxl),

              // ── CTA Button ──────────────────────────────────────────
              RSAnimatedSlide(
                delay: const Duration(milliseconds: 700),
                begin: const Offset(0, 30),
                child: RSButton(
                  label: 'Explore Ras Hotel',
                  icon: const Icon(Icons.arrow_forward_rounded),
                  style: RSButtonStyle.primary,
                  size: RSButtonSize.large,
                  fullWidth: true,
                  onPressed: () => _openHome(context),
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