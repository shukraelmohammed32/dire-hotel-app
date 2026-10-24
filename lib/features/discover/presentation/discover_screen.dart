import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../home/data/demo_rooms.dart';
import '../../home/presentation/room_detail_screen.dart';

class DiscoverScreen extends StatefulWidget {
  const DiscoverScreen({super.key});

  @override
  State<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends State<DiscoverScreen> {
  DateTime? _checkIn;
  DateTime? _checkOut;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(24, 22, 24, 30),
        children: [
          Text(
            'Discover',
            style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  fontFamily: 'serif',
                  fontSize: 36,
                ),
          ),
          const SizedBox(height: 6),
          Text(
            'Search rooms with your preferred travel dates.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              children: [
                _DateCell(
                  icon: Icons.login_rounded,
                  title: 'Check-in',
                  value: _checkIn == null
                      ? 'Select date'
                      : '${_checkIn!.day}/${_checkIn!.month}/${_checkIn!.year}',
                  onTap: () => _pickDate(isCheckIn: true),
                ),
                const SizedBox(height: 10),
                _DateCell(
                  icon: Icons.logout_rounded,
                  title: 'Check-out',
                  value: _checkOut == null
                      ? 'Select date'
                      : '${_checkOut!.day}/${_checkOut!.month}/${_checkOut!.year}',
                  onTap: () => _pickDate(isCheckIn: false),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text('Recommended rooms', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          ...DemoRooms.rooms.map(
            (room) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(builder: (_) => RoomDetailScreen(room: room)),
                ),
                child: Container(
                  height: 170,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    image: DecorationImage(
                      image: AssetImage(room.imageAssetPath),
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withValues(alpha: .02),
                          Colors.black.withValues(alpha: .62),
                        ],
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Spacer(),
                          Text(
                            room.name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 18,
                            ),
                          ),
                          Text(
                            room.description,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: .88),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickDate({required bool isCheckIn}) async {
    final now = DateTime.now();
    final selected = await showDatePicker(
      context: context,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
      initialDate: now.add(Duration(days: isCheckIn ? 1 : 2)),
    );
    if (selected == null) {
      return;
    }
    setState(() {
      if (isCheckIn) {
        _checkIn = selected;
      } else {
        _checkOut = selected;
      }
    });
  }
}

class _DateCell extends StatelessWidget {
  const _DateCell({
    required this.icon,
    required this.title,
    required this.value,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        side: const BorderSide(color: AppColors.border),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        padding: const EdgeInsets.all(14),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.burgundy, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.bodyMedium),
                const SizedBox(height: 2),
                Text(value, style: Theme.of(context).textTheme.titleMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
