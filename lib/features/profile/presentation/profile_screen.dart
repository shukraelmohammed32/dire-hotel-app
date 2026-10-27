import 'package:flutter/material.dart';

import '../../../core/presentation/info_placeholder_screen.dart';
import '../../../core/services/customer_session.dart';
import '../../../core/theme/app_theme.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: CustomerSession.instance,
      builder: (context, _) {
        final session = CustomerSession.instance;
        final hasSession = session.hasIdentity;

        return SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Profile',
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                        fontFamily: 'serif',
                        fontSize: 32,
                      ),
                ),
                const SizedBox(height: 20),

                // ── Guest identity card ──────────────────────────────────
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.blush,
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 58,
                        height: 58,
                        decoration: BoxDecoration(
                          color: AppColors.burgundy,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: const Icon(Icons.person_outline_rounded,
                            color: Colors.white, size: 30),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              hasSession
                                  ? (session.name?.isNotEmpty == true
                                      ? session.name!
                                      : 'Returning Guest')
                                  : 'Guest',
                              style: const TextStyle(
                                color: AppColors.ink,
                                fontWeight: FontWeight.w700,
                                fontSize: 17,
                              ),
                            ),
                            const SizedBox(height: 3),
                            if (hasSession) ...[
                              Text(
                                session.phone ?? '',
                                style: const TextStyle(
                                    color: AppColors.muted, fontSize: 13),
                              ),
                              if (session.email?.isNotEmpty == true)
                                Text(
                                  session.email!,
                                  style: const TextStyle(
                                      color: AppColors.muted, fontSize: 13),
                                ),
                            ] else
                              const Text(
                                'Enter your phone in Bookings to sign in',
                                style: TextStyle(
                                    color: AppColors.muted, fontSize: 13),
                              ),
                          ],
                        ),
                      ),
                      if (hasSession)
                        IconButton(
                          icon: const Icon(Icons.logout_rounded,
                              color: AppColors.muted),
                          tooltip: 'Sign out',
                          onPressed: () {
                            CustomerSession.instance.clear();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Signed out.'),
                                duration: Duration(seconds: 2),
                              ),
                            );
                          },
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),

                // ── Menu tiles ───────────────────────────────────────────
                _Tile(
                  icon: Icons.bookmark_border_rounded,
                  label: 'Saved rooms',
                  onTap: () => _open(context,
                      title: 'Saved rooms',
                      message: 'Saved rooms will appear here in a future update.',
                      icon: Icons.bookmark_border_rounded),
                ),
                _Tile(
                  icon: Icons.help_outline_rounded,
                  label: 'Help & support',
                  onTap: () => _open(context,
                      title: 'Help & support',
                      message:
                          'For assistance please call +251 46 211 0000 or visit the front desk.',
                      icon: Icons.help_outline_rounded),
                ),
                _Tile(
                  icon: Icons.settings_outlined,
                  label: 'Preferences',
                  onTap: () => _open(context,
                      title: 'Preferences',
                      message: 'Preference controls are coming soon.',
                      icon: Icons.settings_outlined),
                ),

                const SizedBox(height: 36),
                Center(
                  child: Text(
                    'Ras Hotel • Dire Dawa, Ethiopia',
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(color: AppColors.muted),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _open(BuildContext context,
      {required String title,
      required String message,
      required IconData icon}) {
    Navigator.of(context).push(MaterialPageRoute<void>(
      builder: (_) =>
          InfoPlaceholderScreen(title: title, message: message, icon: icon),
    ));
  }
}

class _Tile extends StatelessWidget {
  const _Tile(
      {required this.icon, required this.label, required this.onTap});
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 3),
      leading: Icon(icon, color: AppColors.burgundy),
      title: Text(label, style: Theme.of(context).textTheme.titleMedium),
      trailing:
          const Icon(Icons.chevron_right_rounded, color: AppColors.muted),
      onTap: onTap,
    );
  }
}
