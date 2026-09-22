import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pune_explorer/data/models/destination.dart';
import 'package:pune_explorer/core/enums/app_enums.dart';
import 'package:pune_explorer/core/widgets/custom_button.dart';
import 'package:pune_explorer/features/destination/presentation/destination_booking_screen.dart';

void main() {
  group('🎟️ Destination Booking Functionality Widget Tests', () {
    testWidgets('renders destination booking form with destination info, pass types, and fare breakdown', (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: DestinationBookingScreen(destinationId: 'dest_1'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Destination summary card
      expect(find.text('Shaniwar Wada'), findsWidgets);
      expect(find.text('Forts & Historical'), findsOneWidget);

      // Section Titles
      expect(find.text('1. Choose Visit Pass Type'), findsOneWidget);
      expect(find.text('Standard Entry Pass'), findsOneWidget);
      expect(find.text('Guided Heritage Walk'), findsOneWidget);
      expect(find.text('VIP Explorer Experience'), findsOneWidget);

      // Date and Slot Pickers
      expect(find.text('2. Visit Date & Slot'), findsOneWidget);
      expect(find.text('Today'), findsOneWidget);
      expect(find.text('Tomorrow'), findsOneWidget);

      // Visitors Stepper
      expect(find.text('3. Visitors'), findsOneWidget);
      expect(find.text('Indian Adults (12+ yrs)'), findsOneWidget);
      expect(find.text('Children / Students'), findsOneWidget);
      expect(find.text('International Tourists'), findsOneWidget);

      // Fare Breakdown
      expect(find.text('Fare Breakdown'), findsOneWidget);
      expect(find.text('Grand Total'), findsOneWidget);
      expect(find.text('Platform Convenience Fee'), findsOneWidget);
      expect(find.text('Free (₹0)'), findsOneWidget);

      // Submit Button
      expect(find.byType(CustomButton), findsWidgets);
      expect(find.text('Pay ₹26 & Generate Pass'), findsOneWidget);
    });

    testWidgets('adjusting visitor count and pass type dynamically updates fare breakdown', (tester) async {
      tester.view.physicalSize = const Size(500, 1000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: DestinationBookingScreen(destinationId: 'dest_1'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Initial state: 1 adult * ₹25 = ₹25 + 5% GST (₹1) = ₹26
      expect(find.text('₹26'), findsWidgets);

      // Switch to Guided Heritage Walk (+₹199/pax)
      await tester.tap(find.text('Guided Heritage Walk'));
      await tester.pumpAndSettle();

      // Fare breakdown should reflect Package Upgrade
      expect(find.text('Package Upgrade'), findsOneWidget);
      expect(find.text('₹199'), findsWidgets);

      // Total: (25 + 199) = 224 + 5% GST (11.2) = 235
      expect(find.text('₹235'), findsWidgets);
    });

    testWidgets('coupon code discount applies properly', (tester) async {
      tester.view.physicalSize = const Size(500, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: DestinationBookingScreen(destinationId: 'dest_1'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Enter coupon PUNEPASS20
      final couponField = find.widgetWithText(TextField, 'Try PUNEPASS20');
      expect(couponField, findsOneWidget);
      await tester.enterText(couponField, 'PUNEPASS20');
      await tester.pumpAndSettle();

      // Tap Apply
      await tester.tap(find.text('Apply'));
      await tester.pumpAndSettle();

      // Success message
      expect(find.text('20% Pune Heritage discount applied!'), findsOneWidget);
      expect(find.text('Coupon Discount'), findsOneWidget);
    });

    testWidgets('free monument entry pass renders free entry confirmation button', (tester) async {
      tester.view.physicalSize = const Size(500, 1000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      // Create a test destination with 0 entry fee
      const freeDest = Destination(
        id: 'dest_free_temple',
        name: 'Dagdusheth Halwai Ganpati',
        city: 'Pune',
        state: 'Pune Region',
        category: DestinationCategory.spiritual,
        description: 'Iconic temple in heart of Pune',
        longDescription: 'Sacred heritage temple visited by millions.',
        images: ['https://images.unsplash.com/photo-1599661046289-e31897846e41?w=600'],
        rating: 4.9,
        reviewCount: 1200,
        latitude: 18.5167,
        longitude: 73.8562,
        entryFeeIndian: 0.0,
        entryFeeForeign: 0.0,
        bestTime: 'All year',
        openingHours: '06:00 AM - 10:30 PM',
        recommendedDuration: '1 hour',
        famousFor: 'Sacred Ganpati idol and rich history',
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: DestinationBookingContent(
                destination: freeDest,
                isModal: false,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Free Entry Pass'), findsOneWidget);
      expect(find.text('Confirm Free Pass for Dagdusheth Halwai Ganpati'), findsOneWidget);
    });
  });
}
