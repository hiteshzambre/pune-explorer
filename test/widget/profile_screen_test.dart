import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pune_explorer/core/providers/app_providers.dart';
import 'package:pune_explorer/data/models/user_profile.dart';
import 'package:pune_explorer/data/models/cms_models.dart';
import 'package:pune_explorer/data/repositories/auth_repository.dart';
import 'package:pune_explorer/features/profile/presentation/profile_screen.dart';

class MockAuthRepository implements AuthRepository {
  UserProfile _user;

  MockAuthRepository([UserProfile? initialUser])
      : _user = initialUser ??
            const UserProfile(
              id: 'test_user_1',
              email: 'hitesh@puneexplorer.in',
              name: 'Hitesh Punekar',
              phone: '+91 98220 12345',
              isGuest: false,
              isAdmin: false,
            );

  @override
  Future<UserProfile?> getCurrentUser() async => _user;

  @override
  Future<UserProfile> signInWithEmail(String email, String password) async => _user;

  @override
  Future<UserProfile> registerWithEmail(String name, String email, String password, String phone) async {
    _user = UserProfile(id: 'usr_new', email: email, name: name, phone: phone, isGuest: false, isAdmin: false);
    return _user;
  }

  @override
  Future<UserProfile> signInAsGuest() async {
    _user = UserProfile.guest();
    return _user;
  }

  @override
  Future<UserProfile> signInAsAdmin(String email, String password, String pin) async {
    _user = UserProfile.admin();
    return _user;
  }

  @override
  Future<void> signOut() async {
    _user = UserProfile.guest();
  }

  @override
  Future<List<UserProfile>> getAllUsers() async => [_user];

  @override
  Future<void> updateUser(UserProfile user) async => _user = user;

  @override
  Future<void> toggleUserSuspension(String userId, bool isSuspended) async {}

  @override
  Future<List<AdminAccount>> getAdminAccounts() async => const [];

  @override
  Future<void> saveAdminAccount(AdminAccount account) async {}

  @override
  Future<void> deleteAdminAccount(String id) async {}
}

Widget _buildTestApp({
  MockAuthRepository? repo,
  Size? size,
  double textScaleFactor = 1.0,
}) {
  final authRepo = repo ?? MockAuthRepository();
  return ProviderScope(
    overrides: [
      authRepositoryProvider.overrideWithValue(authRepo),
    ],
    child: MaterialApp(
      home: MediaQuery(
        data: MediaQueryData(
          size: size ?? const Size(390, 844),
          textScaler: TextScaler.linear(textScaleFactor),
        ),
        child: const ProfileScreen(),
      ),
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('👑 ProfileScreen Redesign & Responsive Tests', () {
    testWidgets('renders cleanly on small mobile (320x600) without RenderFlex overflow', (tester) async {
      tester.view.physicalSize = const Size(320, 600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(_buildTestApp(size: const Size(320, 600)));
      await tester.pumpAndSettle();

      expect(find.text('My Profile & Dashboard'), findsOneWidget);
      expect(find.text('Level 3: Fort Conqueror'), findsOneWidget);
      expect(find.text('Hitesh Punekar'), findsWidgets);
      expect(tester.takeException(), isNull);
    });

    testWidgets('renders on standard phone (390x844) with complete sections', (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(_buildTestApp(size: const Size(390, 844)));
      await tester.pumpAndSettle();

      expect(find.text('My Profile & Dashboard'), findsOneWidget);
      expect(find.text('Puneri Rewards Wallet'), findsOneWidget);
      expect(find.text('₹450'), findsOneWidget);
      expect(find.text('1,250 Coins Ready'), findsOneWidget);
      expect(find.text('Fort Master'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('renders on tablet/desktop (1280x800) in constrained card layout', (tester) async {
      tester.view.physicalSize = const Size(1280, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(_buildTestApp(size: const Size(1280, 800)));
      await tester.pumpAndSettle();

      expect(find.text('My Profile & Dashboard'), findsOneWidget);
      expect(find.text('My Travel Preferences'), findsOneWidget);
      expect(find.text('APP PREFERENCES'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('renders with 1.25x accessibility scaling on 360x720 without overflow', (tester) async {
      tester.view.physicalSize = const Size(360, 720);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(_buildTestApp(
        size: const Size(360, 720),
        textScaleFactor: 1.25,
      ));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });

    testWidgets('displays Punekar heritage badges properly', (tester) async {
      tester.view.physicalSize = const Size(412, 915);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(_buildTestApp(size: const Size(412, 915)));
      await tester.pumpAndSettle();

      expect(find.text('Fort Master'), findsOneWidget);
      expect(find.text('Darshan VIP'), findsOneWidget);
      expect(find.text('Ghat Rider'), findsOneWidget);
      expect(find.text('Food Explorer'), findsOneWidget);
    });

    testWidgets('tapping "Redeem Coins" displays active coupons voucher sheet', (tester) async {
      tester.view.physicalSize = const Size(412, 915);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(_buildTestApp(size: const Size(412, 915)));
      await tester.pumpAndSettle();

      final redeemBtn = find.text('Redeem Coins for Voucher');
      expect(redeemBtn, findsOneWidget);
      await tester.tap(redeemBtn);
      await tester.pumpAndSettle();

      expect(find.text('Active Explorer Coupons & Vouchers'), findsOneWidget);
      expect(find.text('DARSHAN50'), findsOneWidget);
      expect(find.text('TREK15'), findsOneWidget);
      expect(find.text('PUNE2026'), findsOneWidget);
    });

    testWidgets('tapping "Refer & Earn" displays referral code dialog', (tester) async {
      tester.view.physicalSize = const Size(412, 915);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(_buildTestApp(size: const Size(412, 915)));
      await tester.pumpAndSettle();

      final referBtn = find.text('Refer & Earn ₹100');
      expect(referBtn, findsOneWidget);
      await tester.tap(referBtn);
      await tester.pumpAndSettle();

      expect(find.text('Refer a Friend & Earn ₹100'), findsOneWidget);
      expect(find.text('PUNERIKAR-99'), findsOneWidget);
    });

    testWidgets('travel preference chips can be selected interactively', (tester) async {
      tester.view.physicalSize = const Size(412, 915);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(_buildTestApp(size: const Size(412, 915)));
      await tester.pumpAndSettle();

      // Scroll down to preferences section using drag
      await tester.drag(find.byType(SingleChildScrollView), const Offset(0, -600));
      await tester.pumpAndSettle();

      expect(find.text('Aisle Seat'), findsOneWidget);
      await tester.tap(find.text('Aisle Seat'), warnIfMissed: false);
      await tester.pumpAndSettle();

      await tester.drag(find.byType(SingleChildScrollView), const Offset(0, -100));
      await tester.pumpAndSettle();

      expect(find.text('Pure Vegetarian'), findsOneWidget);
      await tester.tap(find.text('Pure Vegetarian'), warnIfMissed: false);
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });

    testWidgets('edit profile updates user name reactively', (tester) async {
      tester.view.physicalSize = const Size(412, 915);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(_buildTestApp(size: const Size(412, 915)));
      await tester.pumpAndSettle();

      final editBtn = find.text('Edit Profile');
      expect(editBtn, findsOneWidget);
      await tester.tap(editBtn);
      await tester.pumpAndSettle();

      expect(find.text('Edit Profile Details'), findsOneWidget);

      final nameField = find.widgetWithText(TextField, 'Full Name');
      expect(nameField, findsOneWidget);

      await tester.enterText(nameField, 'Shivaji Raje');
      await tester.pumpAndSettle();

      await tester.tap(find.text('Save Profile Changes'));
      await tester.pumpAndSettle();

      expect(find.text('Shivaji Raje'), findsWidgets);
      expect(tester.takeException(), isNull);
    });

    testWidgets('displays safety and helpline numbers', (tester) async {
      tester.view.physicalSize = const Size(412, 915);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(_buildTestApp(size: const Size(412, 915)));
      await tester.pumpAndSettle();

      await tester.drag(find.byType(SingleChildScrollView), const Offset(0, -500));
      await tester.pumpAndSettle();

      expect(find.text('24x7 Tourist Safety & Helpline'), findsOneWidget);
      expect(find.text('Police 112'), findsOneWidget);
      expect(find.text('Medical 108'), findsOneWidget);
      expect(find.text('MTDC 1800-229930'), findsOneWidget);
    });

    testWidgets('displays Promotions & Exclusive Offers section with coupon codes and copy action', (tester) async {
      tester.view.physicalSize = const Size(412, 915);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(_buildTestApp(size: const Size(412, 915)));
      await tester.pumpAndSettle();

      // Scroll down so Promotions section is fully in viewport
      await tester.drag(find.byType(SingleChildScrollView), const Offset(0, -480));
      await tester.pumpAndSettle();

      expect(find.text('Promotions & Exclusive Offers'), findsOneWidget);
      expect(find.text('4 Active Deals'), findsOneWidget);
      expect(find.text('PUNEPASS20'), findsOneWidget);

      // Verify category filter chip interaction
      final groupChip = find.text('Group Specials');
      expect(groupChip, findsOneWidget);
      await tester.tap(groupChip);
      await tester.pumpAndSettle();

      expect(find.text('GROUPSAVE15'), findsOneWidget);

      // Reset to All Offers
      await tester.tap(find.text('All Offers'));
      await tester.pumpAndSettle();

      // Scroll slightly so coupon card action buttons are centered
      await tester.drag(find.byType(SingleChildScrollView), const Offset(0, -100));
      await tester.pumpAndSettle();

      // Test Copy Code
      final copyBtn = find.text('Copy').first;
      expect(copyBtn, findsOneWidget);
      await tester.tap(copyBtn);
      await tester.pumpAndSettle();

      expect(find.text('Copied!'), findsOneWidget);
      expect(find.textContaining('copied! Apply at checkout.'), findsOneWidget);

      // Advance clock past reset timer
      await tester.pump(const Duration(seconds: 4));
      expect(tester.takeException(), isNull);
    });
  });
}
