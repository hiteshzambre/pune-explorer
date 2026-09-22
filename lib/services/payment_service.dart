class PaymentResult {
  final bool isSuccess;
  final String? paymentId;
  final String? orderId;
  final String? errorMessage;
  final DateTime timestamp;

  const PaymentResult({
    required this.isSuccess,
    this.paymentId,
    this.orderId,
    this.errorMessage,
    required this.timestamp,
  });
}

abstract class PaymentService {
  Future<PaymentResult> processPayment({
    required String bookingId,
    required double amountINR,
    required String customerName,
    required String customerEmail,
    required String customerPhone,
    required String tourTitle,
  });
}

class MockPaymentService implements PaymentService {
  @override
  Future<PaymentResult> processPayment({
    required String bookingId,
    required double amountINR,
    required String customerName,
    required String customerEmail,
    required String customerPhone,
    required String tourTitle,
  }) async {
    // Simulate real gateway network handshake
    await Future.delayed(const Duration(milliseconds: 1200));

    final paymentId = 'pay_${DateTime.now().millisecondsSinceEpoch.toRadixString(36).toUpperCase()}';
    final orderId = 'order_$bookingId';

    return PaymentResult(
      isSuccess: true,
      paymentId: paymentId,
      orderId: orderId,
      timestamp: DateTime.now(),
    );
  }
}

/// Helper Engine for UPI QR validation and formatting
class UpiPaymentEngine {
  static const String defaultMerchantUpiId = 'pay.puneexplorer@upi';
  static const String defaultMerchantName = 'PuneExplorer Tours & Travels';

  /// Validates a user-entered transaction reference / UTR.
  /// Returns null if valid, or a descriptive error message.
  static String? validateUtr(String? raw) {
    if (raw == null || raw.trim().isEmpty) {
      return 'Please enter the transaction reference / UTR number from your UPI app.';
    }

    final trimmed = raw.trim();

    if (trimmed.length < 8) {
      return 'Transaction ID must be at least 8 characters (typically 12 digits).';
    }

    if (trimmed.length > 24) {
      return 'Transaction ID cannot exceed 24 characters.';
    }

    // Must be alphanumeric
    if (!RegExp(r'^[a-zA-Z0-9_-]+$').hasMatch(trimmed)) {
      return 'Transaction ID should only contain letters, numbers, or hyphens.';
    }

    // Reject trivial repetitive characters (e.g. 00000000, 11111111)
    if (RegExp(r'^(.)\1+$').hasMatch(trimmed)) {
      return 'Please enter a valid, non-trivial transaction reference number.';
    }

    // Reject common dummy test strings unless explicitly in sandbox
    final lower = trimmed.toLowerCase();
    if (lower == '12345678' || lower == '123456789012' || lower == 'testtest' || lower == 'abcdefgh') {
      return 'Please enter your actual UPI transaction reference number.';
    }

    return null;
  }

  /// Builds a standard UPI deep-link string: upi://pay?pa=...&pn=...&am=...
  static String buildUpiUri({
    required String payeeUpiId,
    required String payeeName,
    required double amount,
    required String orderId,
    String? note,
  }) {
    final encName = Uri.encodeComponent(payeeName);
    final encNote = Uri.encodeComponent(note ?? 'PuneExplorer Order $orderId');
    final formattedAmount = amount.toStringAsFixed(2);
    return 'upi://pay?pa=$payeeUpiId&pn=$encName&am=$formattedAmount&cu=INR&tn=$encNote&tr=$orderId';
  }

  /// Sandbox test code support for automated or manual QA:
  static bool isSandboxVerifyCode(String utr) => utr.trim().toUpperCase() == 'TEST-VERIFY-1234';
  static bool isSandboxFailCode(String utr) => utr.trim().toUpperCase() == 'TEST-FAIL-1234';
}
