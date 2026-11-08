import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Lightweight in-memory session manager for hotel guests.
class CustomerSession extends ChangeNotifier {
  CustomerSession._();
  static final CustomerSession instance = CustomerSession._();
  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage();
  static const String _paymentTokenPrefix = 'ras_payment_access_';
  final Map<String, String> _paymentTokens = {};

  String? _phone;
  String? _name;
  String? _email;

  String? get phone => _phone;
  String? get name => _name;
  String? get email => _email;

  bool get hasIdentity => _phone != null && _phone!.trim().isNotEmpty;

  void setCustomer({
    required String phone,
    String? name,
    String? email,
  }) {
    _phone = phone.trim();
    if (name != null) _name = name.trim();
    if (email != null) _email = email.trim();
    notifyListeners();
  }

  void clear() {
    _phone = null;
    _name = null;
    _email = null;
    _paymentTokens.clear();
    unawaited(_clearStoredPaymentTokens());
    notifyListeners();
  }

  Future<void> savePaymentAccessToken(String confirmationNo, String token) async {
    if (confirmationNo.isEmpty || token.isEmpty) return;
    _paymentTokens[confirmationNo] = token;
    try {
      await _secureStorage.write(key: '$_paymentTokenPrefix$confirmationNo', value: token);
    } catch (_) {
      // Keep this session usable if platform secure storage is unavailable.
    }
  }

  Future<String?> getPaymentAccessToken(String confirmationNo) async {
    final cached = _paymentTokens[confirmationNo];
    if (cached != null) return cached;
    try {
      final token = await _secureStorage.read(key: '$_paymentTokenPrefix$confirmationNo');
      if (token != null) _paymentTokens[confirmationNo] = token;
      return token;
    } catch (_) {
      return null;
    }
  }

  Future<void> _clearStoredPaymentTokens() async {
    try {
      final entries = await _secureStorage.readAll();
      for (final key in entries.keys.where((key) => key.startsWith(_paymentTokenPrefix))) {
        await _secureStorage.delete(key: key);
      }
    } catch (_) {
      // Do not block sign-out when secure storage is unavailable.
    }
  }
}
