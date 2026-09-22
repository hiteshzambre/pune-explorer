import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pune_explorer/features/legal/presentation/privacy_policy_screen.dart';
import 'package:pune_explorer/features/legal/presentation/terms_and_conditions_screen.dart';
import 'package:pune_explorer/features/legal/presentation/cancellation_refund_screen.dart';
import 'package:pune_explorer/features/legal/presentation/help_support_screen.dart';
import 'package:pune_explorer/features/legal/presentation/about_screen.dart';
import 'package:pune_explorer/features/legal/presentation/delete_account_screen.dart';

void main() {
  group('Legal & Support Screens Rendering Tests', () {
    testWidgets('PrivacyPolicyScreen renders data protection categories and sections', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: PrivacyPolicyScreen(),
        ),
      );

      expect(find.text('Privacy Policy'), findsWidgets);
      expect(find.text('1. Introduction & Our Commitment'), findsOneWidget);
      expect(find.text('2. Information We Collect'), findsOneWidget);
    });

    testWidgets('TermsAndConditionsScreen renders heritage conservation and pass rules', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: TermsAndConditionsScreen(),
        ),
      );

      expect(find.text('Terms & Conditions'), findsWidgets);
      expect(find.text('2. Heritage Conservation Code'), findsOneWidget);
    });

    testWidgets('CancellationRefundScreen renders 90%/50% refund tiers accurately', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: CancellationRefundScreen(),
        ),
      );

      expect(find.text('Cancellation & Refund Policy'), findsWidgets);
      expect(find.text('1. Standard Cancellation Tiers'), findsOneWidget);
    });

    testWidgets('HelpSupportScreen renders search input and FAQs accordion', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: HelpSupportScreen(),
        ),
      );

      expect(find.text('Help & Support Center'), findsOneWidget);
      expect(find.text('FREQUENTLY ASKED QUESTIONS'), findsOneWidget);
      expect(find.text('How do I download my digital boarding pass?'), findsOneWidget);
    });

    testWidgets('AboutScreen renders heritage mission and platform release info', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: AboutScreen(),
        ),
      );

      expect(find.text('About PuneExplorer'), findsWidgets);
      expect(find.text('Our Puneri Mission'), findsOneWidget);
    });

    testWidgets('DeleteAccountScreen renders permanent warning and confirmation controls', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: DeleteAccountScreen(),
          ),
        ),
      );

      expect(find.text('Account & Data Deletion'), findsOneWidget);
      expect(find.text('Permanent Account Deletion'), findsOneWidget);
    });
  });
}
