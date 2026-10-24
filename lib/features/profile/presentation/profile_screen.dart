import 'package:flutter/material.dart';

import '../../../core/presentation/info_placeholder_screen.dart';
import '../../../core/theme/app_theme.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Profile', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 26),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.blush,
                borderRadius: BorderRadius.circular(22),
              ),
              child: const Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: AppColors.burgundy,
                    child: Icon(Icons.person_outline_rounded,
                        color: Colors.white, size: 30),
                  ),
                  SizedBox(width: 15),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Guest profile',
                          style: TextStyle(
                              color: AppColors.ink,
                              fontWeight: FontWeight.w700,
                              fontSize: 17)),
                      SizedBox(height: 4),
                      Text('Sign in to manage your stays',
                          style: TextStyle(color: AppColors.muted, fontSize: 13)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            _PlaceholderTile(
              icon: Icons.bookmark_border_rounded,
              label: 'Saved rooms',
              onTap: () => _openPlaceholder(
                context,
                title: 'Saved rooms',
                message:
                    'Saved rooms will appear here once account sync is available.',
                icon: Icons.bookmark_border_rounded,
              ),
            ),
            _PlaceholderTile(
              icon: Icons.help_outline_rounded,
              label: 'Help & support',
              onTap: () => _openPlaceholder(
                context,
                title: 'Help & support',
                message:
                    'Support channels will be connected in a future release.',
                icon: Icons.help_outline_rounded,
              ),
            ),
            _PlaceholderTile(
              icon: Icons.settings_outlined,
              label: 'Preferences',
              onTap: () => _openPlaceholder(
                context,
                title: 'Preferences',
                message:
                    'Preference controls are planned and not yet connected.',
                icon: Icons.settings_outlined,
              ),
            ),
            const Spacer(),
            Center(
              child: Text(
                'Ras Hotel • UI prototype',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
            const SizedBox(height: 28),
          ],
        ),
      ),
    );
  }

  void _openPlaceholder(
    BuildContext context, {
    required String title,
    required String message,
    required IconData icon,
  }) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => InfoPlaceholderScreen(
          title: title,
          message: message,
          icon: icon,
        ),
      ),
    );
  }
}

class _PlaceholderTile extends StatelessWidget {
  const _PlaceholderTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 3),
      leading: Icon(icon, color: AppColors.burgundy),
      title: Text(label, style: Theme.of(context).textTheme.titleMedium),
      trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.muted),
      onTap: onTap,
    );
  }
}
