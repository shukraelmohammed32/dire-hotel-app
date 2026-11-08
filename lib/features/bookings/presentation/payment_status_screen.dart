import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:mobile/core/network/api_client.dart';
import 'package:mobile/core/network/api_exception.dart';
import 'package:mobile/core/services/customer_session.dart';
import 'package:mobile/core/theme/app_theme.dart';
import 'package:mobile/core/utils/price_formatter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../domain/booking.dart';
import '../domain/payment.dart';

class PaymentStatusScreen extends StatefulWidget {
  const PaymentStatusScreen({required this.booking, super.key, this.apiClient});

  final Booking booking;
  final ApiClient? apiClient;

  @override
  State<PaymentStatusScreen> createState() => _PaymentStatusScreenState();
}

class _PaymentStatusScreenState extends State<PaymentStatusScreen>
    with WidgetsBindingObserver {
  late final ApiClient _apiClient;
  Timer? _pollTimer;
  String? _accessToken;
  PaymentCheckout? _checkout;
  PaymentVerification? _verification;
  String? _error;
  bool _starting = true;
  bool _checking = false;
  bool _retryAvailable = true;

  bool get _canRetry => _verification != null &&
      const {'FAILED', 'CANCELLED', 'EXPIRED'}.contains(_verification!.status);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _apiClient = widget.apiClient ?? ApiClient();
    unawaited(_startPayment());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _pollTimer?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && _checkout != null) {
      unawaited(_verifyPayment());
    }
  }

  String _newIdempotencyKey() {
    final random = Random.secure();
    final bytes = List<int>.generate(18, (_) => random.nextInt(256));
    return '${DateTime.now().microsecondsSinceEpoch}_${bytes.map((byte) => byte.toRadixString(16).padLeft(2, '0')).join()}';
  }

  Future<void> _startPayment() async {
    if (widget.booking.invoiceId == null || widget.booking.invoiceId!.isEmpty) {
      setState(() {
        _error = 'There is no invoice attached to this booking yet.';
        _starting = false;
        _retryAvailable = false;
      });
      return;
    }
    final token = widget.booking.paymentAccessToken ??
        await CustomerSession.instance.getPaymentAccessToken(widget.booking.confirmationNo);
    if (token == null || token.isEmpty) {
      setState(() {
        _error = 'For your security, this device cannot access the payment for this booking. Contact the hotel team.';
        _starting = false;
        _retryAvailable = false;
      });
      return;
    }
    _accessToken = token;

    setState(() {
      _starting = true;
      _error = null;
      _verification = null;
      _checkout = null;
    });
    try {
      final checkout = await _apiClient.initializePayment(
        invoiceId: widget.booking.invoiceId!,
        paymentAccessToken: token,
        idempotencyKey: _newIdempotencyKey(),
      );
      final uri = Uri.tryParse(checkout.checkoutUrl);
      if (uri == null || uri.scheme != 'https' || uri.host != 'checkout.chapa.co') {
        throw const ApiException('The payment provider returned an invalid checkout link.');
      }
      if (!mounted) return;
      setState(() {
        _checkout = checkout;
        _starting = false;
      });
      final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!opened && mounted) {
        setState(() => _error = 'Could not open the secure checkout. Tap “Open checkout” to try again.');
      }
      _startPolling();
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = _userMessage(error);
        _starting = false;
      });
    }
  }

  String _userMessage(Object error) {
    if (error is ApiException) return error.message;
    return 'Payment service is unavailable right now. Please try again later.';
  }

  void _startPolling() {
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(const Duration(seconds: 7), (_) {
      unawaited(_verifyPayment());
    });
  }

  Future<void> _verifyPayment() async {
    final checkout = _checkout;
    final token = _accessToken;
    if (_checking || checkout == null || token == null) return;
    _checking = true;
    try {
      final verification = await _apiClient.verifyPayment(
        reference: checkout.reference,
        paymentAccessToken: token,
      );
      if (!mounted) return;
      setState(() {
        _verification = verification;
        _error = null;
      });
      if (verification.isTerminal) _pollTimer?.cancel();
    } catch (error) {
      if (mounted) setState(() => _error = _userMessage(error));
    } finally {
      _checking = false;
    }
  }

  Future<void> _openCheckout() async {
    final raw = _checkout?.checkoutUrl;
    final uri = raw == null ? null : Uri.tryParse(raw);
    if (uri == null || uri.scheme != 'https' || uri.host != 'checkout.chapa.co') return;
    final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!opened && mounted) setState(() => _error = 'Could not open the secure checkout.');
  }

  @override
  Widget build(BuildContext context) {
    final isPaid = _verification?.isSuccess ?? false;
    final status = _verification?.status ?? _checkout?.status ?? 'PENDING';
    final statusColor = isPaid
        ? const Color(0xFF2E7D32)
        : _canRetry
            ? Colors.red.shade700
            : AppColors.gold;
    final amount = _checkout?.amount ?? widget.booking.totalEtb.toStringAsFixed(2);

    return Scaffold(
      appBar: AppBar(title: const Text('Secure payment')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(22),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      isPaid ? Icons.verified_rounded : _canRetry ? Icons.error_outline_rounded : Icons.lock_outline_rounded,
                      color: statusColor,
                      size: 34,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      isPaid ? 'Payment confirmed' : _canRetry ? 'Payment not completed' : 'Complete your payment',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      isPaid
                          ? 'Chapa verified the payment. Your hotel invoice has been updated.'
                          : _canRetry
                              ? 'No successful payment was recorded. You may safely retry.'
                              : 'Checkout is hosted by Chapa. The app will show success only after the hotel server verifies it.',
                    ),
                    const SizedBox(height: 22),
                    _detail('Booking', widget.booking.confirmationNo),
                    if (widget.booking.invoiceNo != null) _detail('Invoice', widget.booking.invoiceNo!),
                    _detail('Amount', '${formatEtb((double.tryParse(amount) ?? widget.booking.totalEtb).round())} ETB'),
                    _detail('Status', status.replaceAll('_', ' '), valueColor: statusColor),
                    if (_checkout?.reference case final reference?) _detail('Payment reference', reference),
                  ],
                ),
              ),
            ),
            if (_starting) ...[
              const SizedBox(height: 18),
              const Center(child: CircularProgressIndicator()),
              const SizedBox(height: 8),
              const Center(child: Text('Preparing secure checkout…')),
            ],
            if (_error != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(14)),
                child: Text(_error!, style: TextStyle(color: Colors.red.shade900)),
              ),
            ],
            const SizedBox(height: 20),
            if (_checkout != null && !isPaid && !_canRetry)
              FilledButton.icon(
                onPressed: _openCheckout,
                icon: const Icon(Icons.open_in_new_rounded),
                label: const Text('Open secure checkout'),
              ),
            if (_checkout != null && !isPaid)
              OutlinedButton.icon(
                onPressed: _checking ? null : _verifyPayment,
                icon: _checking
                    ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.refresh_rounded),
                label: const Text('Check payment status'),
              ),
            if (_canRetry || (_checkout == null && !_starting && _retryAvailable))
              FilledButton.icon(
                onPressed: _starting ? null : _startPayment,
                icon: const Icon(Icons.replay_rounded),
                label: Text(_canRetry ? 'Retry payment' : 'Try again'),
              ),
          ],
        ),
      ),
    );
  }

  Widget _detail(String label, String value, {Color? valueColor}) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(width: 112, child: Text(label, style: const TextStyle(color: AppColors.muted))),
            Expanded(child: Text(value, textAlign: TextAlign.right, style: TextStyle(color: valueColor ?? AppColors.ink, fontWeight: FontWeight.w600))),
          ],
        ),
      );
}
