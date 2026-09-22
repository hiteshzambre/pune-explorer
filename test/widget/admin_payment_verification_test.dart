import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pune_explorer/core/constants/admin_constants.dart';
import 'package:pune_explorer/core/constants/app_constants.dart';
import 'package:pune_explorer/core/enums/app_enums.dart';
import 'package:pune_explorer/data/models/payment_order.dart';
import 'package:pune_explorer/features/admin/presentation/admin_screen.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({
      AdminConstants.keyAdminToken: 'valid_test_token',
    });
  });

  Widget createAdminTestWidget({List<PaymentOrder>? customOrders}) {
    final now = DateTime.now();
    final defaultOrders = [
      PaymentOrder(
        id: 'ord_admin_01',
        orderId: 'PE-2026-888999',
        bookingId: 'PUNE-ADMIN-01',
        userId: 'rahul.patil@example.com',
        packageId: 'pkg_darshan',
        packageName: 'Royal Pune Darshan Tour',
        amount: 648.0,
        currency: 'INR',
        paymentMethod: 'upi_qr',
        merchantUpiId: 'pay.puneexplorer@upi',
        merchantName: 'PuneExplorer',
        upiUri: 'upi://pay?pa=pay.puneexplorer@upi&am=648.00',
        transactionId: '425619842011',
        status: PaymentStatus.underVerification,
        createdAt: now,
        updatedAt: now,
        expiresAt: now.add(const Duration(minutes: 10)),
      ),
    ];

    final orders = customOrders ?? defaultOrders;
    SharedPreferences.setMockInitialValues({
      AdminConstants.keyAdminToken: 'valid_test_token',
      AppConstants.keyPayments: jsonEncode(orders.map((o) => o.toJson()).toList()),
    });

    return const ProviderScope(
      child: MaterialApp(
        home: AdminScreen(),
      ),
    );
  }

  group('Admin Payment Verification Console Tests', () {
    testWidgets('Displays Payments & Bookings tab and lists pending verification claims', (tester) async {
      tester.view.physicalSize = const Size(1000, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(createAdminTestWidget());
      await tester.pumpAndSettle();

      // Tap the Payments & Bookings tab (Tab index 3)
      await tester.tap(find.text('Payments & Bookings'));
      await tester.pumpAndSettle();

      // Check order details are displayed
      expect(find.text('PE-2026-888999'), findsOneWidget);
      expect(find.text('Royal Pune Darshan Tour'), findsWidgets);
      expect(find.text('₹648'), findsWidgets);
      expect(find.text('425619842011'), findsOneWidget);
      expect(find.text('UNDER VERIFICATION'), findsOneWidget);
      expect(find.text('Verify Payment'), findsOneWidget);
      expect(find.text('Reject'), findsOneWidget);
      expect(find.text('Request Info'), findsOneWidget);
    });

    testWidgets('Tapping Verify Payment confirms order and updates status to PAID', (tester) async {
      tester.view.physicalSize = const Size(1000, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(createAdminTestWidget());
      await tester.pumpAndSettle();

      // Tap Payments & Bookings tab
      await tester.tap(find.text('Payments & Bookings'));
      await tester.pumpAndSettle();

      // Tap Verify Payment button
      await tester.tap(find.text('Verify Payment'));
      await tester.pumpAndSettle();

      // Status should update to PAID (VERIFIED)
      expect(find.text('PAID (VERIFIED)'), findsOneWidget);
      expect(find.text('View Receipt'), findsOneWidget);
    });

    testWidgets('Tapping Reject opens rejection reason dialog', (tester) async {
      tester.view.physicalSize = const Size(1000, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(createAdminTestWidget());
      await tester.pumpAndSettle();

      // Tap Payments & Bookings tab
      await tester.tap(find.text('Payments & Bookings'));
      await tester.pumpAndSettle();

      // Tap Reject button
      await tester.tap(find.text('Reject'));
      await tester.pumpAndSettle();

      expect(find.textContaining('Reject Payment Claim'), findsOneWidget);
      expect(find.text('Reason for Rejection:'), findsOneWidget);
      expect(find.text('Confirm Rejection'), findsOneWidget);
    });
  });
}
