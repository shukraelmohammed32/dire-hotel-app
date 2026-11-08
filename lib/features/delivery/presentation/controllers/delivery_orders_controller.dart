import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mobile/core/network/api_client.dart';
import 'package:mobile/core/network/api_exception.dart';
import 'package:mobile/core/services/customer_session.dart';
import '../../domain/delivery_order.dart';

class DeliveryOrdersController extends ChangeNotifier {
  DeliveryOrdersController({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  final ApiClient _apiClient;
  Timer? _pollTimer;

  bool _isLoading = false;
  String? _errorMessage;
  List<DeliveryOrder> _orders = [];
  DateTime? _lastRefreshed;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<DeliveryOrder> get orders => _orders;
  DateTime? get lastRefreshed => _lastRefreshed;

  List<DeliveryOrder> get pendingOrders =>
      _orders.where((o) => o.status == 'PENDING').toList();

  List<DeliveryOrder> get confirmedOrders =>
      _orders.where((o) => o.status == 'CONFIRMED' || o.status == 'PREPARING' || o.status == 'OUT_FOR_DELIVERY').toList();

  List<DeliveryOrder> get pastOrders =>
      _orders.where((o) => o.status == 'DELIVERED' || o.status == 'CANCELLED').toList();

  void startPolling({int intervalSeconds = 30}) {
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(Duration(seconds: intervalSeconds), (_) {
      if (CustomerSession.instance.hasIdentity) {
        loadOrders();
      }
    });
  }

  void stopPolling() {
    _pollTimer?.cancel();
    _pollTimer = null;
  }

  Future<void> loadOrders({String? phone}) async {
    final targetPhone = phone ?? CustomerSession.instance.phone;
    if (targetPhone == null || targetPhone.trim().isEmpty) {
      _orders = [];
      _errorMessage = null;
      notifyListeners();
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final fetched = await _apiClient.getCustomerDeliveryOrders(phone: targetPhone);
      _orders = fetched;
      _errorMessage = null;
      _lastRefreshed = DateTime.now();
    } on AuthorizationException catch (e) {
      _errorMessage = e.message;
      _orders = [];
    } on NetworkException catch (e) {
      _errorMessage = e.message;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('ApiException: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> onOrderCreated({String? phone}) async {
    await loadOrders(phone: phone);
  }

  @override
  void dispose() {
    stopPolling();
    super.dispose();
  }
}