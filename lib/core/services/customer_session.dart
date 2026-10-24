import 'package:flutter/foundation.dart';

/// Lightweight in-memory session manager for hotel guests.
class CustomerSession extends ChangeNotifier {
  CustomerSession._();
  static final CustomerSession instance = CustomerSession._();

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
    notifyListeners();
  }
}
