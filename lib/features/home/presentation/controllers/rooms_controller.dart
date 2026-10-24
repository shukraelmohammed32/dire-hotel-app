import 'package:flutter/material.dart';

import '../../data/room_repository.dart';
import '../../domain/availability.dart';
import '../../domain/room.dart';

class RoomsController extends ChangeNotifier {
  RoomsController({RoomRepository? repository})
      : _repository = repository ?? ApiRoomRepository();

  final RoomRepository _repository;

  bool _isLoading = false;
  String? _errorMessage;
  List<Room> _rooms = [];

  String _selectedCategory = 'All';
  DateTimeRange? _selectedDates;
  int _guestsCount = 2;

  bool _isCheckingAvailability = false;
  String? _availabilityError;
  AvailabilityResult? _availabilityResult;

  // Getters
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<Room> get rooms => _rooms;
  String get selectedCategory => _selectedCategory;
  DateTimeRange? get selectedDates => _selectedDates;
  int get guestsCount => _guestsCount;
  bool get isCheckingAvailability => _isCheckingAvailability;
  String? get availabilityError => _availabilityError;
  AvailabilityResult? get availabilityResult => _availabilityResult;

  List<Room> get filteredRooms {
    if (_selectedCategory == 'All') return _rooms;
    return _rooms.where((r) {
      final t = r.type.toLowerCase();
      final cat = _selectedCategory.toLowerCase();
      if (cat == 'standard') return t.contains('standard');
      if (cat == 'superior') return t.contains('superior') || t.contains('king');
      if (cat == 'family') return t.contains('family');
      return t.contains(cat);
    }).toList();
  }

  List<Room> get featuredRooms {
    final featured = _rooms.where((r) => r.isFeatured).toList();
    if (featured.isNotEmpty) return featured;
    return _rooms.take(4).toList();
  }

  Future<void> loadRooms({bool refresh = false}) async {
    if (_isLoading && !refresh) return;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final fetched = await _repository.getRooms();
      _rooms = fetched;
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('ApiException: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setCategory(String category) {
    if (_selectedCategory == category) return;
    _selectedCategory = category;
    notifyListeners();
  }

  void setDates(DateTimeRange? dates) {
    _selectedDates = dates;
    _availabilityResult = null;
    _availabilityError = null;
    notifyListeners();
  }

  void setGuests(int guests) {
    _guestsCount = guests;
    notifyListeners();
  }

  Future<void> checkAvailability(DateTimeRange dates, {String? roomType}) async {
    _selectedDates = dates;
    _isCheckingAvailability = true;
    _availabilityError = null;
    notifyListeners();

    try {
      final result = await _repository.checkAvailability(
        checkIn: dates.start,
        checkOut: dates.end,
        roomType: roomType,
        guests: _guestsCount,
      );
      _availabilityResult = result;
      _availabilityError = null;
    } catch (e) {
      _availabilityError = e.toString().replaceFirst('ApiException: ', '');
      _availabilityResult = null;
    } finally {
      _isCheckingAvailability = false;
      notifyListeners();
    }
  }

  void clearAvailability() {
    _selectedDates = null;
    _availabilityResult = null;
    _availabilityError = null;
    notifyListeners();
  }
}
