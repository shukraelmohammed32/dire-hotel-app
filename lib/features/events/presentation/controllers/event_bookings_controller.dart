import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mobile/core/network/api_client.dart';
import 'package:mobile/core/network/api_exception.dart';
import 'package:mobile/core/services/customer_session.dart';
import '../../domain/event_booking.dart';

class EventBookingsController extends ChangeNotifier {
  EventBookingsController({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  final ApiClient _apiClient;
  Timer? _pollTimer;

  bool _isLoading = false;
  String? _errorMessage;
  List<EventBooking> _bookings = [];
  DateTime? _lastRefreshed;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<EventBooking> get bookings => _bookings;
  DateTime? get lastRefreshed => _lastRefreshed;

  List<EventBooking> get pendingBookings =>
      _bookings.where((b) => b.status == 'PENDING').toList();

  List<EventBooking> get confirmedBookings =>
      _bookings.where((b) => b.status == 'CONFIRMED').toList();

  List<EventBooking> get pastBookings =>
      _bookings.where((b) => b.status == 'COMPLETED' || b.status == 'CANCELLED').toList();

  void startPolling({int intervalSeconds = 30}) {
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(Duration(seconds: intervalSeconds), (_) {
      if (CustomerSession.instance.hasIdentity) {
        loadBookings();
      }
    });
  }

  void stopPolling() {
    _pollTimer?.cancel();
    _pollTimer = null;
  }

  Future<void> loadBookings({String? phone}) async {
    final targetPhone = phone ?? CustomerSession.instance.phone;
    if (targetPhone == null || targetPhone.trim().isEmpty) {
      _bookings = [];
      _errorMessage = null;
      notifyListeners();
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final fetched = await _apiClient.getCustomerEventBookings(phone: targetPhone);
      _bookings = fetched;
      _errorMessage = null;
      _lastRefreshed = DateTime.now();
    } on AuthorizationException catch (e) {
      _errorMessage = e.message;
      _bookings = [];
    } on NetworkException catch (e) {
      _errorMessage = e.message;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('ApiException: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> onBookingCreated({String? phone}) async {
    await loadBookings(phone: phone);
  }

  @override
  void dispose() {
    stopPolling();
    super.dispose();
  }
}