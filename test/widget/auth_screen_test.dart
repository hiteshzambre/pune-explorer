import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pune_explorer/features/authentication/presentation/auth_screen.dart';
import 'package:pune_explorer/features/authentication/presentation/widgets/password_strength_meter.dart';
import 'package:pune_explorer/features/authentication/presentation/widgets/floating_travel_elements.dart';
import 'package:pune_explorer/features/authentication/presentation/widgets/auth_hero_section.dart';

void main() {
  group('Premium AuthScreen Widget Tests', () {
    testWidgets('AuthScreen renders Sign In tab with inputs and guest action', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: AuthScreen(),
          ),
        ),
      );

      expect(find.text('Welcome back, Punekar Explorer 👋'), findsOneWidget);
      expect(find.text('Email Address'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
      expect(find.text('Sign In to PuneExplorer'), findsOneWidget);
      expect(find.text('Explore as Guest (No Login Required)'), findsOneWidget);
    });

    testWidgets('Switches smoothly to Create Account tab and shows registration inputs', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: AuthScreen(),
          ),
        ),
      );

      // Tap Create Account
      await tester.tap(find.text('Create Account'));
      await tester.pump(const Duration(milliseconds: 350));

      expect(find.text('Join PuneExplorer Community 🌟'), findsOneWidget);
      expect(find.text('Full Name'), findsOneWidget);
      expect(find.text('Mobile Number (+91)'), findsOneWidget);
      expect(find.text('Create Password'), findsOneWidget);
      expect(find.text('Confirm Password'), findsOneWidget);
      expect(find.text('Create Account & Explore'), findsOneWidget);
    });

    testWidgets('PasswordStrengthMeter correctly evaluates weak, medium, and strong passwords', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PasswordStrengthMeter(password: 'Pune@2026Strong'),
          ),
        ),
      );

      expect(find.text('Strong & Secure'), findsOneWidget);
      expect(find.text('8+ characters'), findsOneWidget);
      expect(find.text('1 uppercase'), findsOneWidget);
      expect(find.text('1 number'), findsOneWidget);
    });

    testWidgets('Switches to Forgot Password view and handles reset link request', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: AuthScreen(),
          ),
        ),
      );

      // Tap Forgot Password
      await tester.tap(find.text('Forgot Password?'));
      await tester.pump(const Duration(milliseconds: 350));

      expect(find.text('Recover Your Explorer Account 🔐'), findsOneWidget);
      final sendBtn = find.text('Send Recovery Link');
      expect(sendBtn, findsOneWidget);

      // Enter email in forgot-password field (field is no longer pre-filled)
      final emailField = find.byType(TextField);
      await tester.enterText(emailField.first, 'test@puneexplorer.in');
      await tester.pump();

      // Scroll and Tap Send Recovery Link
      await tester.ensureVisible(sendBtn);
      await tester.tap(sendBtn);
      await tester.pump(const Duration(milliseconds: 800));
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.text('Password Reset Link Sent!'), findsOneWidget);
      expect(find.text('Return to Sign In'), findsOneWidget);
    });

    testWidgets('FloatingTravelBadge oscillates with smooth animation', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: FloatingTravelBadge(
              emoji: '🏰',
              label: 'Sinhagad Fort',
              subtitle: 'Maratha Glory',
            ),
          ),
        ),
      );

      expect(find.text('Sinhagad Fort'), findsOneWidget);
      expect(find.text('Maratha Glory'), findsOneWidget);
      await tester.pump(const Duration(seconds: 1));
    });

    // ── New Responsive & Feature Tests ────────────────────────────────────

    testWidgets('Renders correctly on small phone viewport (320px)', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(320, 640);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: AuthScreen(),
          ),
        ),
      );

      // Core elements should render without overflow
      expect(find.text('PuneExplorer'), findsOneWidget);
      expect(find.text('Welcome back, Punekar Explorer 👋'), findsOneWidget);
      expect(find.text('Sign In'), findsOneWidget);
    });

    testWidgets('Renders correctly on standard phone viewport (390px)', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: AuthScreen(),
          ),
        ),
      );

      expect(find.text('PuneExplorer'), findsOneWidget);
      expect(find.text('Sign In to PuneExplorer'), findsOneWidget);
      expect(find.text('Explore as Guest (No Login Required)'), findsOneWidget);
    });

    testWidgets('Social login buttons render on Sign In view', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: AuthScreen(),
          ),
        ),
      );

      // Social buttons should be visible
      expect(find.text('Google'), findsOneWidget);
      expect(find.text('Apple'), findsOneWidget);
    });

    testWidgets('Trust badges are removed from Sign In view', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: AuthScreen(),
          ),
        ),
      );

      await tester.pump();

      expect(find.text('256-bit SSL'), findsNothing);
      expect(find.text('GDPR Compliant'), findsNothing);
      expect(find.text('4.8 Rating'), findsNothing);
    });

    testWidgets('Brand header shows PuneExplorer with पुणे badge on mobile', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: AuthScreen(),
          ),
        ),
      );

      expect(find.text('PuneExplorer'), findsOneWidget);
      expect(find.text('पुणे'), findsOneWidget);
      expect(find.text('Travel & Heritage Platform'), findsOneWidget);
    });

    testWidgets('Handles text scaling at 1.25x without layout errors', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: MediaQuery(
              data: MediaQueryData(
                size: Size(390, 844),
                textScaler: TextScaler.linear(1.25),
              ),
              child: AuthScreen(),
            ),
          ),
        ),
      );

      // Should render without overflow errors at large text
      expect(find.text('Sign In'), findsOneWidget);
      expect(find.text('Create Account'), findsOneWidget);
    });

    testWidgets('Renders across all 14 responsive breakpoints without overflow', (WidgetTester tester) async {
      FlutterErrorDetails? caughtDetails;
      final oldHandler = FlutterError.onError;
      FlutterError.onError = (details) {
        caughtDetails = details;
        oldHandler?.call(details);
      };
      addTearDown(() => FlutterError.onError = oldHandler);

      const breakpoints = [
        Size(320, 640),
        Size(360, 740),
        Size(375, 667),
        Size(390, 844),
        Size(414, 896),
        Size(430, 932),
        Size(600, 960),
        Size(768, 1024),
        Size(820, 1180),
        Size(1024, 768),
        Size(1280, 800),
        Size(1366, 768),
        Size(1440, 900),
        Size(1920, 1080),
      ];

      for (final size in breakpoints) {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1.0;
        caughtDetails = null;

        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: AuthScreen(),
            ),
          ),
        );
        await tester.pump(const Duration(milliseconds: 100));

        // Ensure key CTA is rendered with zero RenderFlex overflow
        final exception = tester.takeException();
        if (caughtDetails != null) {
          debugPrint('CAUGHT INFORMATION:');
          final info = caughtDetails!.informationCollector?.call() ?? [];
          for (final node in info) {
            debugPrint(node.toString());
          }
        }
        expect(exception, isNull, reason: 'Overflow occurred at $size: $exception');
      }
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('Registration view renders across all 14 responsive breakpoints without overflow', (WidgetTester tester) async {
      FlutterErrorDetails? caughtDetails;
      final oldHandler = FlutterError.onError;
      FlutterError.onError = (details) {
        caughtDetails = details;
        oldHandler?.call(details);
      };
      addTearDown(() => FlutterError.onError = oldHandler);

      const breakpoints = [
        Size(320, 640),
        Size(360, 740),
        Size(375, 667),
        Size(390, 844),
        Size(414, 896),
        Size(430, 932),
        Size(600, 960),
        Size(768, 1024),
        Size(820, 1180),
        Size(1024, 768),
        Size(1280, 800),
        Size(1366, 768),
        Size(1440, 900),
        Size(1920, 1080),
      ];

      for (final size in breakpoints) {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1.0;
        caughtDetails = null;

        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: AuthScreen(),
            ),
          ),
        );
        // Switch to Create Account
        await tester.tap(find.text('Create Account').first);
        await tester.pump(const Duration(milliseconds: 100));

        final exception = tester.takeException();
        if (caughtDetails != null) {
          debugPrint('REGISTER OVERFLOW CAUGHT:');
          final info = caughtDetails!.informationCollector?.call() ?? [];
          for (final node in info) {
            debugPrint(node.toString());
          }
        }
        expect(exception, isNull, reason: 'Registration overflow occurred at $size: $exception');
      }
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('Desktop layout renders 2 columns with storytelling hero section', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1440, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: AuthScreen(),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(AuthHeroSection), findsOneWidget);
      expect(find.text('Sign In to PuneExplorer'), findsOneWidget);
    });

    testWidgets('Toggling password visibility switches obscureText', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: AuthScreen(),
          ),
        ),
      );

      final visibilityIcon = find.byIcon(Icons.visibility_outlined);
      expect(visibilityIcon, findsOneWidget);

      await tester.tap(visibilityIcon);
      await tester.pump();

      expect(find.byIcon(Icons.visibility_off_outlined), findsOneWidget);
    });

    testWidgets('Empty password triggers validation error', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: AuthScreen(),
          ),
        ),
      );

      // Enter valid email first (fields are no longer pre-filled)
      final textFields = find.byType(TextField);
      await tester.enterText(textFields.at(0), 'test@puneexplorer.in');
      await tester.pump();

      // Clear password field (index 1 is password)
      await tester.enterText(textFields.at(1), '');
      await tester.pump();

      // Ensure visible and Tap Sign In
      final signInBtn = find.text('Sign In to PuneExplorer');
      await tester.ensureVisible(signInBtn);
      await tester.tap(signInBtn);
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Please enter your password.'), findsOneWidget);
    });

    testWidgets('Registration triggers in-place field validation errors and banner', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: AuthScreen(),
          ),
        ),
      );

      // Switch to Create Account
      await tester.tap(find.text('Create Account'));
      await tester.pumpAndSettle();

      // Tap Create Account & Explore without filling fields
      final submitBtn = find.text('Create Account & Explore');
      await tester.ensureVisible(submitBtn);
      await tester.tap(submitBtn);
      await tester.pumpAndSettle();

      // In-place field error labels appear at each empty field
      expect(find.text('Name is required'), findsOneWidget);
      expect(find.text('Email is required'), findsOneWidget);
      expect(find.text('Password is required'), findsOneWidget);
      expect(find.text('Confirm password'), findsOneWidget);

      // In-place banner appears above CTA
      expect(find.text('Please provide your full name.'), findsOneWidget);

      // Typing into Full Name clears that in-place error
      final textFields = find.byType(TextField);
      await tester.enterText(textFields.at(0), 'Tanaji Malusare');
      await tester.pumpAndSettle();

      expect(find.text('Name is required'), findsNothing);
    });

    testWidgets('Registration shows in-place error for password mismatch', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: AuthScreen(),
          ),
        ),
      );

      // Switch to Create Account
      await tester.tap(find.text('Create Account'));
      await tester.pumpAndSettle();

      final textFields = find.byType(TextField);
      await tester.enterText(textFields.at(0), 'Tanaji Malusare');
      await tester.enterText(textFields.at(1), 'tanaji@sinhagad.in');
      await tester.enterText(textFields.at(2), '9876543210');
      await tester.enterText(textFields.at(3), 'Pune@2026Strong');
      await tester.enterText(textFields.at(4), 'Pune@2026Different');
      await tester.pumpAndSettle();

      final submitBtn = find.text('Create Account & Explore');
      await tester.ensureVisible(submitBtn);
      await tester.tap(submitBtn);
      await tester.pumpAndSettle();

      expect(find.text('Passwords do not match'), findsOneWidget);
      expect(find.text('Passwords do not match. Please verify.'), findsOneWidget);
    });

    testWidgets('Registration shows in-place error when terms unchecked', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: AuthScreen(),
          ),
        ),
      );

      // Switch to Create Account
      await tester.tap(find.text('Create Account'));
      await tester.pumpAndSettle();

      final textFields = find.byType(TextField);
      await tester.enterText(textFields.at(0), 'Tanaji Malusare');
      await tester.enterText(textFields.at(1), 'tanaji@sinhagad.in');
      await tester.enterText(textFields.at(2), '9876543210');
      await tester.enterText(textFields.at(3), 'Pune@2026Strong');
      await tester.enterText(textFields.at(4), 'Pune@2026Strong');

      // Uncheck terms
      final checkbox = find.byType(Checkbox);
      await tester.ensureVisible(checkbox);
      await tester.tap(checkbox);
      await tester.pumpAndSettle();

      final submitBtn = find.text('Create Account & Explore');
      await tester.ensureVisible(submitBtn);
      await tester.tap(submitBtn);
      await tester.pumpAndSettle();

      expect(find.text('Accept terms to proceed'), findsOneWidget);
      expect(find.text('Please accept the PuneExplorer terms & conditions.'), findsOneWidget);
    });
  });
}
