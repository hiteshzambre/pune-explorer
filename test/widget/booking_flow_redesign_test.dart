import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pune_explorer/core/constants/app_constants.dart';
import 'package:pune_explorer/core/enums/app_enums.dart';
import 'package:pune_explorer/data/models/booking.dart';
import 'package:pune_explorer/data/models/tour_customization.dart';
import 'package:pune_explorer/features/booking/presentation/booking_screen.dart';
import 'package:pune_explorer/features/booking/presentation/booking_confirmation_screen.dart';
import 'package:pune_explorer/features/booking/presentation/widgets/booking_stepper.dart';
import 'package:pune_explorer/features/booking/presentation/widgets/customize_addons_view.dart';
import 'package:pune_explorer/features/booking/presentation/widgets/traveler_details_view.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  Widget buildAppWithScope({required Widget child, List<Booking>? customBookings}) {
    final now = DateTime.now();
    final defaultBooking = Booking(
      id: 'BK-TEST-1001',
      orderId: 'PE-2026-999888',
      tourId: 'PNE-DAR-01',
      tourTitle: 'Classic Pune Darshan',
      customerName: 'Rahul Patil',
      customerEmail: 'rahul.patil@example.com',
      customerPhone: '+91 98220 12345',
      travelDate: now.add(const Duration(days: 2)).toIso8601String(),
      passengers: const [
        Passenger(fullName: 'Rahul Patil', age: 28, gender: 'Male', seatNumber: 'A1'),
        Passenger(fullName: 'Sneha Patil', age: 26, gender: 'Female', seatNumber: 'A2'),
      ],
      basePrice: 1198.0,
      seatExtraPrice: 100.0,
      discountAmount: 100.0,
      gstAmount: 64.9,
      platformFee: 29.0,
      totalAmount: 1391.9,
      pickupPoint: 'Swargate Bus Terminal, Pune',
      selectedSeats: const ['A1', 'A2'],
      customization: const TourCustomization(transportMode: 'AC Coach (Included)'),
      status: BookingStatus.underVerification,
      paymentStatus: PaymentStatus.underVerification,
      transactionId: '425619842011',
      verificationHash: 'PE-BK-TEST-1001-VERIFIED',
      createdAt: now.toIso8601String(),
    );

    final bookings = customBookings ?? [defaultBooking];
    SharedPreferences.setMockInitialValues({
      AppConstants.keyBookings: jsonEncode(bookings.map((b) => b.toJson()).toList()),
    });

    return ProviderScope(
      child: MaterialApp(
        theme: ThemeData(useMaterial3: true),
        home: child,
      ),
    );
  }

  group('🎯 Premium Tour Booking UI Redesign Tests', () {
    testWidgets('Screen 1 (Tour Details): renders hero metadata, tabs, and booking summary card', (tester) async {
      tester.view.physicalSize = const Size(1280, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        buildAppWithScope(
          child: const BookingScreen(tourId: 'pkg_darshan_royal', initialStep: 0),
        ),
      );
      await tester.pumpAndSettle();

      // Screen 1 Hero Elements
      expect(find.text('Official Pune Darshan'), findsWidgets);
      expect(find.text('First-time Pune'), findsWidgets);
      expect(find.text('Classic Pune Darshan'), findsWidgets);
      expect(find.text('Overview'), findsOneWidget);
      expect(find.text('Itinerary'), findsOneWidget);
      expect(find.text('Inclusions'), findsOneWidget);
      expect(find.text('Reviews'), findsOneWidget);
      expect(find.text('FAQs'), findsOneWidget);

      // Sticky Booking Card
      expect(find.text('Continue to Booking →'), findsOneWidget);
      expect(find.text('Best Price Guaranteed'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('Screen 2 (Customize & Add-ons): renders stepper, tour summary, and add-on options', (tester) async {
      tester.view.physicalSize = const Size(1280, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        buildAppWithScope(
          child: const BookingScreen(tourId: 'pkg_darshan_royal', initialStep: 1),
        ),
      );
      await tester.pumpAndSettle();

      // Stepper verification
      expect(find.byType(BookingStepper), findsOneWidget);
      expect(find.text('Customize'), findsWidgets);
      expect(find.text('Traveler Details'), findsWidgets);

      // Section titles
      expect(find.textContaining('Tour Customizer & Add-ons'), findsOneWidget);
      expect(find.textContaining('Transport Upgrade'), findsOneWidget);
      expect(find.textContaining('Authentic Puneri Dining'), findsOneWidget);
      expect(find.textContaining('Stay / Overnight Tier'), findsOneWidget);

      // Next CTA
      expect(find.text('Continue to Traveler Details →'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('Screen 3 (Traveler Details): renders contact form, seat selector card, and fare summary', (tester) async {
      tester.view.physicalSize = const Size(1280, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        buildAppWithScope(
          child: const BookingScreen(tourId: 'pkg_darshan_royal', initialStep: 2),
        ),
      );
      await tester.pumpAndSettle();

      // Primary Contact Fields
      expect(find.text('Primary Contact & Travelers'), findsOneWidget);
      expect(find.text('Full Name'), findsWidgets);
      expect(find.textContaining('Email Address'), findsOneWidget);
      expect(find.textContaining('Mobile Phone'), findsOneWidget);

      // Boarding Terminal & Seat selection
      expect(find.text('Pune Boarding Terminal'), findsOneWidget);
      expect(find.text('Bus Seat Preference'), findsOneWidget);

      // Fare summary
      expect(find.text('Fare & Payment Summary'), findsOneWidget);
      expect(find.textContaining('Proceed to Pay by UPI QR'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('Step Navigation: advances from Tour Details to Customize to Traveler Details', (tester) async {
      tester.view.physicalSize = const Size(1280, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        buildAppWithScope(
          child: const BookingScreen(tourId: 'pkg_darshan_royal', initialStep: 0),
        ),
      );
      await tester.pumpAndSettle();

      // Tap Continue to Booking
      final continueBtn = find.text('Continue to Booking →');
      await tester.ensureVisible(continueBtn);
      await tester.tap(continueBtn);
      await tester.pumpAndSettle();

      // Should now be on Step 1: Customize & Add-ons
      expect(find.byType(CustomizeAddonsView), findsOneWidget);
      expect(find.textContaining('Tour Customizer & Add-ons'), findsOneWidget);

      // Tap Continue to Traveler Details
      final continueDetailsBtn = find.text('Continue to Traveler Details →');
      await tester.ensureVisible(continueDetailsBtn);
      await tester.tap(continueDetailsBtn);
      await tester.pumpAndSettle();

      // Should now be on Step 2: Traveler Details
      expect(find.byType(TravelerDetailsView), findsOneWidget);
      expect(find.text('Primary Contact & Travelers'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('Screen 6: BookingConfirmationScreen renders Under Verification pending state cleanly', (tester) async {
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        buildAppWithScope(
          child: const BookingConfirmationScreen(bookingId: 'BK-TEST-1001'),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Payment Submitted'), findsOneWidget);
      expect(find.text('PE-2026-999888'), findsOneWidget);
      expect(find.text('425619842011'), findsOneWidget);
      expect(find.text('Under Verification'), findsOneWidget);
      expect(find.textContaining('do NOT pay again'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('Screen 7: BookingConfirmationScreen renders Confirmed ticket state cleanly', (tester) async {
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final confirmedBooking = Booking(
        id: 'BK-CONFIRMED-01',
        orderId: 'PE-2026-112233',
        tourId: 'PNE-DAR-01',
        tourTitle: 'Classic Pune Darshan',
        customerName: 'Rahul Patil',
        customerEmail: 'rahul.patil@example.com',
        customerPhone: '+91 98220 12345',
        travelDate: DateTime.now().add(const Duration(days: 1)).toIso8601String(),
        passengers: const [
          Passenger(fullName: 'Rahul Patil', age: 28, gender: 'Male', seatNumber: 'A1'),
          Passenger(fullName: 'Sneha Patil', age: 26, gender: 'Female', seatNumber: 'A2'),
        ],
        basePrice: 1198.0,
        seatExtraPrice: 0.0,
        discountAmount: 0.0,
        gstAmount: 59.9,
        platformFee: 29.0,
        totalAmount: 1286.9,
        pickupPoint: 'Swargate Bus Terminal, Pune',
        selectedSeats: const ['A1', 'A2'],
        status: BookingStatus.confirmed,
        paymentStatus: PaymentStatus.paid,
        transactionId: '425619842011',
        verificationHash: 'PE-BK-CONFIRMED-01-PASS',
        createdAt: DateTime.now().toIso8601String(),
      );

      await tester.pumpWidget(
        buildAppWithScope(
          customBookings: [confirmedBooking],
          child: const BookingConfirmationScreen(bookingId: 'BK-CONFIRMED-01'),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Booking Confirmed!'), findsOneWidget);
      expect(find.text('PE-2026-112233'), findsOneWidget);
      expect(find.text('Confirmed'), findsOneWidget);
      expect(find.text('Download Ticket'), findsOneWidget);
      expect(find.text('View My Bookings'), findsOneWidget);
      expect(find.text('Explore Pune'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('Responsive Audit: Narrow mobile 320x600 renders cleanly without RenderFlex overflow', (tester) async {
      tester.view.physicalSize = const Size(320, 600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        buildAppWithScope(
          child: const BookingScreen(tourId: 'pkg_darshan_royal', initialStep: 1),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('Tour Customizer & Add-ons'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
