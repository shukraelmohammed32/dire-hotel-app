import 'package:flutter/material.dart';

import '../../../core/network/api_config.dart';
import '../../../core/presentation/info_placeholder_screen.dart';
import '../../../core/services/customer_session.dart';
import '../../../core/theme/app_theme.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    // Re-render whenever the session changes
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
                _buildIdentityCard(context, session, hasSession),
                const SizedBox(height: 28),

                // ── Menu tiles ──────────────────────────────────────────
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

                const Divider(height: 36),

                // ── API connection panel ─────────────────────────────────
                _buildApiPanel(context),
                const SizedBox(height: 28),

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

  // ── Guest identity card ────────────────────────────────────────────────
  Widget _buildIdentityCard(
    BuildContext context,
    CustomerSession session,
    bool hasSession,
  ) {
    return Container(
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
                    style: const TextStyle(color: AppColors.muted, fontSize: 13),
                  ),
                  if (session.email != null && session.email!.isNotEmpty)
                    Text(
                      session.email!,
                      style: const TextStyle(
                          color: AppColors.muted, fontSize: 13),
                    ),
                ] else
                  const Text(
                    'Enter your phone in Bookings to sign in',
                    style: TextStyle(color: AppColors.muted, fontSize: 13),
                  ),
              ],
            ),
          ),
          if (hasSession)
            IconButton(
              icon: const Icon(Icons.logout_rounded, color: AppColors.muted),
              tooltip: 'Clear session',
              onPressed: () {
                session.clear();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Session cleared.'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                }
              },
            ),
        ],
      ),
    );
  }

  // ── API panel ──────────────────────────────────────────────────────────
  Widget _buildApiPanel(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.cloud_outlined,
                color: AppColors.gold, size: 20),
            const SizedBox(width: 8),
            Text(
              'API Connection',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _infoRow(
                icon: Icons.link_rounded,
                label: 'Active URL',
                value: ApiConfig.baseUrl,
              ),
              const SizedBox(height: 6),
              _infoRow(
                icon: Icons.timer_outlined,
                label: 'Timeout',
                value: '${ApiConfig.timeout.inSeconds}s',
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => _showUrlEditor(context),
            icon: const Icon(Icons.edit_outlined, size: 18),
            label: const Text('Override API URL (dev/prod switch)'),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppColors.border),
              foregroundColor: AppColors.ink,
            ),
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'For emulator: http://10.0.2.2:3000\n'
          'For LAN device: http://192.168.x.x:3000',
          style: TextStyle(color: AppColors.muted, fontSize: 11),
        ),
      ],
    );
  }

  Widget _infoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: AppColors.burgundy),
        const SizedBox(width: 8),
        Text('$label: ',
            style: const TextStyle(
                color: AppColors.muted, fontSize: 12)),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              color: AppColors.ink,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  void _showUrlEditor(BuildContext context) {
    final controller =
        TextEditingController(text: ApiConfig.baseUrl);
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Override API URL'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Change the backend server URL. Resets to default on next app start unless set via --dart-define.',
              style: TextStyle(color: AppColors.muted, fontSize: 13),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: controller,
              keyboardType: TextInputType.url,
              autocorrect: false,
              decoration: const InputDecoration(
                labelText: 'Base URL',
                hintText: 'http://10.0.2.2:3000',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              ApiConfig.resetToDefault();
              Navigator.of(ctx).pop();
              setState(() {});
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Reset to default: ${ApiConfig.baseUrl}'),
                ),
              );
            },
            child: const Text('Reset to default'),
          ),
          FilledButton(
            onPressed: () {
              final newUrl = controller.text.trim();
              if (newUrl.isNotEmpty) {
                ApiConfig.setBaseUrl(newUrl);
              }
              Navigator.of(ctx).pop();
              setState(() {});
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('API URL set to: ${ApiConfig.baseUrl}'),
                ),
              );
            },
            child: const Text('Apply'),
          ),
        ],
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
