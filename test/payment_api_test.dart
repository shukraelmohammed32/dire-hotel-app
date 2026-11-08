import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mobile/core/network/api_client.dart';
import 'package:mobile/core/network/api_config.dart';

void main() {
  setUp(() => ApiConfig.setBaseUrl('https://hotel.example'));

  test('initializes hosted checkout with capability auth and no client amount', () async {
    final client = ApiClient(client: MockClient((request) async {
      expect(request.method, 'POST');
      expect(request.url.path, '/api/payments/initialize');
      expect(request.headers['authorization'], 'Bearer booking-capability');
      final body = jsonDecode(request.body) as Map<String, dynamic>;
      expect(body, {'invoiceId': 'invoice-1', 'idempotencyKey': 'request-123'});
      return http.Response(jsonEncode({
        'ok': true,
        'payment': {
          'paymentId': 'attempt-1',
          'reference': 'RAS1234567890123AABBCCDDEEFF001122334455',
          'amount': '1250.00',
          'currency': 'ETB',
          'status': 'PROCESSING',
          'checkoutUrl': 'https://checkout.chapa.co/checkout/payment/1',
        },
      }), 201, headers: {'content-type': 'application/json'});
    }));

    final checkout = await client.initializePayment(
      invoiceId: 'invoice-1',
      paymentAccessToken: 'booking-capability',
      idempotencyKey: 'request-123',
    );

    expect(checkout.amount, '1250.00');
    expect(checkout.currency, 'ETB');
    expect(checkout.checkoutUrl, startsWith('https://checkout.chapa.co/'));
  });

  test('returns only backend-verified status from payment verification', () async {
    final client = ApiClient(client: MockClient((request) async {
      expect(request.method, 'GET');
      expect(request.url.path, '/api/payments/RAS-ref/verify');
      expect(request.headers['authorization'], 'Bearer booking-capability');
      return http.Response(jsonEncode({
        'ok': true,
        'payment': {'status': 'SUCCESS', 'invoiceStatus': 'PAID'},
      }), 200, headers: {'content-type': 'application/json'});
    }));

    final status = await client.verifyPayment(
      reference: 'RAS-ref',
      paymentAccessToken: 'booking-capability',
    );

    expect(status.isSuccess, isTrue);
    expect(status.isTerminal, isTrue);
    expect(status.invoiceStatus, 'PAID');
  });

  test('does not treat a processing response as successful or terminal', () async {
    final client = ApiClient(client: MockClient((request) async => http.Response(
          jsonEncode({'ok': true, 'payment': {'status': 'PROCESSING'}}),
          200,
          headers: {'content-type': 'application/json'},
        )));

    final status = await client.verifyPayment(reference: 'RAS-ref', paymentAccessToken: 'capability');

    expect(status.isSuccess, isFalse);
    expect(status.isTerminal, isFalse);
  });
}
