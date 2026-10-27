import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/price_formatter.dart';
import '../domain/room.dart';
import 'controllers/rooms_controller.dart';
import 'room_detail_screen.dart';

class RoomListScreen extends StatefulWidget {
  const RoomListScreen({
    super.key,
    this.initialRooms,
    this.initialController,
  });

  final List<Room>? initialRooms;
  final RoomsController? initialController;

  @override
  State<RoomListScreen> createState() => _RoomListScreenState();
}

class _RoomListScreenState extends State<RoomListScreen> {
  late final RoomsController _controller;
  String _selectedFilter = 'All';

  static const _filters = ['All', 'Standard', 'Superior', 'Family'];

  @override
  void initState() {
    super.initState();
    _controller = widget.initialController ?? RoomsController();
    if (widget.initialRooms == null && _controller.rooms.isEmpty) {
      _controller.loadRooms();
    }
  }

  List<Room> _getDisplayedRooms() {
    final base = widget.initialRooms ?? _controller.rooms;
    if (_selectedFilter == 'All') return base;
    return base.where((r) {
      final t = r.type.toLowerCase();
      final cat = _selectedFilter.toLowerCase();
      if (cat == 'standard') return t.contains('standard');
      if (cat == 'superior') return t.contains('superior') || t.contains('king');
      if (cat == 'family') return t.contains('family');
      return t.contains(cat);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _controller,
      builder: (context, _) {
        final rooms = _getDisplayedRooms();
        final isLoading = _controller.isLoading && rooms.isEmpty;
        final error = _controller.errorMessage;

        return Scaffold(
          appBar: AppBar(
            title: Text(widget.initialRooms != null ? 'Available rooms' : 'All rooms'),
          ),
          body: Column(
            children: [
              _buildFilterChips(),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () => _controller.loadRooms(refresh: true),
                  color: AppColors.burgundy,
                  child: _buildBody(isLoading, error, rooms),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFilterChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        children: _filters.map((filter) {
          final isSelected = _selectedFilter == filter;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(filter),
              selected: isSelected,
              selectedColor: AppColors.blush,
              labelStyle: TextStyle(
                color: isSelected ? AppColors.burgundy : AppColors.ink,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              ),
              side: BorderSide(
                color: isSelected ? AppColors.burgundy : AppColors.border,
              ),
              onSelected: (selected) {
                if (selected) {
                  setState(() => _selectedFilter = filter);
                }
              },
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildBody(bool isLoading, String? error, List<Room> rooms) {
    if (isLoading) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: AppColors.burgundy),
            SizedBox(height: 14),
            Text('Loading rooms…', style: TextStyle(color: AppColors.muted)),
          ],
        ),
      );
    }

    if (error != null && rooms.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline_rounded, size: 48, color: AppColors.burgundy),
              const SizedBox(height: 12),
              const Text(
                'Unable to load rooms',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              Text(
                error,
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.muted),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () => _controller.loadRooms(refresh: true),
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Try again'),
              ),
            ],
          ),
        ),
      );
    }

    if (rooms.isEmpty) {
      return ListView(
        children: const [
          SizedBox(height: 100),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.hotel_outlined, size: 48, color: AppColors.muted),
                SizedBox(height: 12),
                Text(
                  'No rooms match your filter',
                  style: TextStyle(fontSize: 16, color: AppColors.muted, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ],
      );
    }

    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 26),
      itemCount: rooms.length,
      separatorBuilder: (_, _) => const SizedBox(height: 14),
      itemBuilder: (context, index) {
        final room = rooms[index];
        return _RoomListTile(
          room: room,
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute<void>(builder: (_) => RoomDetailScreen(room: room)),
          ),
        );
      },
    );
  }
}

class _RoomListTile extends StatelessWidget {
  const _RoomListTile({required this.room, required this.onTap});

  final Room room;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.horizontal(left: Radius.circular(20)),
              child: Image.asset(
                room.imageAssetPath,
                width: 112,
                height: 112,
                fit: BoxFit.cover,
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            room.name,
                            style: Theme.of(context).textTheme.titleMedium,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: room.isAvailable ? const Color(0xFFE8F5E9) : const Color(0xFFFFEBEE),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            room.status,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: room.isAvailable ? const Color(0xFF2E7D32) : const Color(0xFFC62828),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      room.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text(
                          '${formatEtb(room.pricePerNight)} ETB',
                          style: const TextStyle(
                            color: AppColors.burgundy,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        const Text(' / night', style: TextStyle(color: AppColors.muted, fontSize: 12)),
                        const Spacer(),
                        Text(
                          'Floor ${room.floor}',
                          style: const TextStyle(color: AppColors.muted, fontSize: 12),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(right: 12),
              child: Icon(Icons.chevron_right_rounded, color: AppColors.muted),
            ),
          ],
        ),
      ),
    );
  }
}
