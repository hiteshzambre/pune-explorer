import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pune_explorer/core/constants/app_constants.dart';
import 'package:pune_explorer/core/enums/app_enums.dart';
import 'package:pune_explorer/data/models/payment_order.dart';
import 'package:pune_explorer/features/payment/presentation/qr_payment_screen.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  Widget createTestWidget({required String orderId, List<PaymentOrder>? customOrders}) {
    final now = DateTime.now();
    final defaultOrder = PaymentOrder(
      id: 'ord_test_01',
      orderId: 'PE-2026-654321',
      bookingId: 'PUNE-TEST-99',
      userId: 'testuser@example.com',
      packageId: 'PNE-DAR-01',
      packageName: 'Classic Pune Darshan',
      amount: 648.0,
      currency: 'INR',
      paymentMethod: 'upi_qr',
      merchantUpiId: 'pay.puneexplorer@upi',
      merchantName: 'PuneExplorer Tours & Travels',
      upiUri: 'upi://pay?pa=pay.puneexplorer@upi&pn=PuneExplorer&am=648.00&cu=INR&tn=PE-2026-654321&tr=PE-2026-654321',
      status: PaymentStatus.pendingPayment,
      createdAt: now,
      updatedAt: now,
      expiresAt: now.add(const Duration(minutes: 10)),
    );

    final orders = customOrders ?? [defaultOrder];
    SharedPreferences.setMockInitialValues({
      AppConstants.keyPayments: jsonEncode(orders.map((o) => o.toJson()).toList()),
    });

    return ProviderScope(
      child: MaterialApp(
        home: QRPaymentScreen(orderId: orderId),
      ),
    );
  }

  group('QRPaymentScreen Widget Tests', () {
    testWidgets('Renders package title, amount, QR code, and countdown timer', (tester) async {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(createTestWidget(orderId: 'PE-2026-654321'));
      await tester.pump();

      expect(find.text('Pay by UPI QR'), findsOneWidget);
      expect(find.text('Classic Pune Darshan'), findsOneWidget);
      expect(find.text('₹648'), findsWidgets);
      expect(find.byType(QrImageView), findsOneWidget);
      expect(find.text('UPI QR Payment'), findsOneWidget);
      expect(find.text('Submit Payment Details'), findsOneWidget);
    });

    testWidgets('Shows validation error when submitting empty or invalid UTR', (tester) async {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(createTestWidget(orderId: 'PE-2026-654321'));
      await tester.pump();

      // Tap submit with empty field
      await tester.tap(find.text('Submit Payment Details'));
      await tester.pumpAndSettle();

      expect(find.text('Please enter the transaction reference / UTR number from your UPI app.'), findsOneWidget);

      // Enter short invalid value
      await tester.enterText(find.byType(TextField), '1234');
      await tester.tap(find.text('Submit Payment Details'));
      await tester.pumpAndSettle();

      expect(find.text('Transaction ID must be at least 8 characters (typically 12 digits).'), findsOneWidget);
    });

    testWidgets('Submitting valid UTR transitions UI to Payment Verification Pending with double payment guard', (tester) async {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(createTestWidget(orderId: 'PE-2026-654321'));
      await tester.pump();

      // Enter valid 12-digit UTR
      await tester.enterText(find.byType(TextField), '425619842011');
      await tester.tap(find.text('Submit Payment Details'));
      await tester.pumpAndSettle();

      // Must switch to Under Verification view
      expect(find.text('Payment Verification Pending'), findsOneWidget);
      expect(find.text('425619842011'), findsOneWidget);
      expect(find.text('Under Verification'), findsOneWidget);

      // Double payment guard: QR code must NOT be visible anymore
      expect(find.byType(QrImageView), findsNothing);
      expect(find.textContaining('do NOT pay again'), findsOneWidget);
    });

    testWidgets('Renders cleanly on narrow 320x600 screen without RenderFlex overflow', (tester) async {
      tester.view.physicalSize = const Size(320, 600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(createTestWidget(orderId: 'PE-2026-654321'));
      await tester.pump();

      expect(find.text('Pay by UPI QR'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
