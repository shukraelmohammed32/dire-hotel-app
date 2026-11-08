import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mobile/core/network/api_client.dart';
import 'package:mobile/core/network/api_exception.dart';
import 'package:mobile/core/services/customer_session.dart';
import '../../domain/dining_reservation.dart';

class DiningReservationsController extends ChangeNotifier {
  DiningReservationsController({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  final ApiClient _apiClient;
  Timer? _pollTimer;

  bool _isLoading = false;
  String? _errorMessage;
  List<DiningReservation> _reservations = [];
  DateTime? _lastRefreshed;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<DiningReservation> get reservations => _reservations;
  DateTime? get lastRefreshed => _lastRefreshed;

  List<DiningReservation> get pendingReservations =>
      _reservations.where((r) => r.status == 'PENDING').toList();

  List<DiningReservation> get confirmedReservations =>
      _reservations.where((r) => r.status == 'CONFIRMED').toList();

  List<DiningReservation> get pastReservations =>
      _reservations.where((r) => r.status == 'COMPLETED' || r.status == 'CANCELLED').toList();

  void startPolling({int intervalSeconds = 30}) {
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(Duration(seconds: intervalSeconds), (_) {
      if (CustomerSession.instance.hasIdentity) {
        loadReservations();
      }
    });
  }

  void stopPolling() {
    _pollTimer?.cancel();
    _pollTimer = null;
  }

  Future<void> loadReservations({String? phone}) async {
    final targetPhone = phone ?? CustomerSession.instance.phone;
    if (targetPhone == null || targetPhone.trim().isEmpty) {
      _reservations = [];
      _errorMessage = null;
      notifyListeners();
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final fetched = await _apiClient.getCustomerDiningReservations(phone: targetPhone);
      _reservations = fetched;
      _errorMessage = null;
      _lastRefreshed = DateTime.now();
    } on AuthorizationException catch (e) {
      _errorMessage = e.message;
      _reservations = [];
    } on NetworkException catch (e) {
      _errorMessage = e.message;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('ApiException: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> onReservationCreated({String? phone}) async {
    await loadReservations(phone: phone);
  }

  @override
  void dispose() {
    stopPolling();
    super.dispose();
  }
}