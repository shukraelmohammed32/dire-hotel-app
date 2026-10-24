import 'package:flutter/material.dart';
import 'package:mobile/core/network/api_client.dart';
import 'package:mobile/core/network/api_exception.dart';
import 'package:mobile/core/services/customer_session.dart';
import '../../domain/booking.dart';

class BookingsController extends ChangeNotifier {
  BookingsController({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  final ApiClient _apiClient;

  bool _isLoading = false;
  String? _errorMessage;
  List<Booking> _bookings = [];

  bool _isCancelling = false;
  String? _cancelError;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<Booking> get bookings => _bookings;
  bool get isCancelling => _isCancelling;
  String? get cancelError => _cancelError;

  List<Booking> get activeBookings =>
      _bookings.where((b) => b.isActive).toList();

  List<Booking> get pastBookings =>
      _bookings.where((b) => b.isCompleted).toList();

  List<Booking> get cancelledBookings =>
      _bookings.where((b) => b.isCancelled).toList();

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
      final fetched = await _apiClient.getCustomerBookings(phone: targetPhone);
      _bookings = fetched;
      _errorMessage = null;
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

  Future<bool> cancelBooking({
    required String confirmationNo,
    required String phone,
    String? reason,
  }) async {
    _isCancelling = true;
    _cancelError = null;
    notifyListeners();

    try {
      final success = await _apiClient.cancelBooking(
        confirmationNo: confirmationNo,
        phone: phone,
        reason: reason,
      );

      if (success) {
        await loadBookings(phone: phone);
        return true;
      } else {
        _cancelError = 'Cancellation request was declined.';
        return false;
      }
    } on AuthorizationException catch (e) {
      _cancelError = e.message;
      return false;
    } catch (e) {
      _cancelError = e.toString().replaceFirst('ApiException: ', '');
      return false;
    } finally {
      _isCancelling = false;
      notifyListeners();
    }
  }
}
