class PaymentCheckout {
  const PaymentCheckout({
    required this.paymentId,
    required this.reference,
    required this.amount,
    required this.currency,
    required this.status,
    required this.checkoutUrl,
  });

  final String paymentId;
  final String reference;
  final String amount;
  final String currency;
  final String status;
  final String checkoutUrl;

  factory PaymentCheckout.fromJson(Map<String, dynamic> json) => PaymentCheckout(
        paymentId: (json['paymentId'] ?? '').toString(),
        reference: (json['reference'] ?? '').toString(),
        amount: (json['amount'] ?? '0.00').toString(),
        currency: (json['currency'] ?? 'ETB').toString(),
        status: (json['status'] ?? 'PROCESSING').toString(),
        checkoutUrl: (json['checkoutUrl'] ?? '').toString(),
      );
}

class PaymentVerification {
  const PaymentVerification({
    required this.status,
    this.invoiceStatus,
  });

  final String status;
  final String? invoiceStatus;

  bool get isSuccess => status == 'SUCCESS';
  bool get isTerminal => const {'SUCCESS', 'FAILED', 'CANCELLED', 'EXPIRED', 'REFUNDED'}.contains(status);

  factory PaymentVerification.fromJson(Map<String, dynamic> json) => PaymentVerification(
        status: (json['status'] ?? 'PROCESSING').toString(),
        invoiceStatus: json['invoiceStatus']?.toString(),
      );
}
