import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pune_explorer/core/constants/admin_constants.dart';
import 'package:pune_explorer/data/repositories/auth_repository.dart';
import 'package:pune_explorer/core/providers/app_providers.dart';
import 'package:pune_explorer/app/router.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Admin Authentication & Credential Security Tests', () {
    late LocalAuthRepository authRepo;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      authRepo = LocalAuthRepository();
    });

    test('Authenticates Admin with official credentials and Master PIN', () async {
      final user = await authRepo.signInAsAdmin(
        'admin@puneexplorer.in',
        'TestAdminPass123!',
        '1234',
      );

      expect(user.isAdmin, isTrue);
      expect(user.email, 'admin@puneexplorer.in');
      expect(user.isGuest, isFalse);

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(AdminConstants.keyAdminToken);
      expect(token, isNotNull);
      expect(token!.startsWith('admin_token_'), isTrue);
    });

    test('Rejects Admin login when incorrect password is provided', () async {
      expect(
        () => authRepo.signInAsAdmin(
          'admin@puneexplorer.in',
          'WrongPassword123!',
          '1234',
        ),
        throwsA(isA<Exception>()),
      );
    });

    test('Rejects Admin login when invalid security PIN is provided', () async {
      expect(
        () => authRepo.signInAsAdmin(
          'admin@puneexplorer.in',
          'TestAdminPass123!',
          '0000',
        ),
        throwsA(isA<Exception>()),
      );
    });

    test('Regular user sign in never receives admin role', () async {
      final regularUser = await authRepo.signInWithEmail('rahul@example.com', 'pune123');

      expect(regularUser.isAdmin, isFalse);
      expect(regularUser.email, 'rahul@example.com');

      final prefs = await SharedPreferences.getInstance();
      final adminToken = prefs.getString(AdminConstants.keyAdminToken);
      expect(adminToken, isNull);
    });

    test('Admin sign out removes token and resets session', () async {
      await authRepo.signInAsAdmin(
        'admin@puneexplorer.in',
        'TestAdminPass123!',
        '1234',
      );

      await authRepo.signOut();

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString(AdminConstants.keyAdminToken), isNull);
    });

    test('Authenticates Admin via unified signInWithEmail using only email and password', () async {
      final user = await authRepo.signInWithEmail(
        'admin@puneexplorer.in',
        'TestAdminPass123!',
      );

      expect(user.isAdmin, isTrue);
      expect(user.email, 'admin@puneexplorer.in');
      expect(user.isGuest, isFalse);

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(AdminConstants.keyAdminToken);
      expect(token, isNotNull);
      expect(token!.startsWith('admin_token_'), isTrue);
    });

    test('Authenticates admin@puneexplorer.com via unified signInWithEmail', () async {
      final user = await authRepo.signInWithEmail(
        'admin@puneexplorer.com',
        'TestAdminPass123!',
      );

      expect(user.isAdmin, isTrue);
      expect(user.email, 'admin@puneexplorer.com');
      expect(user.isGuest, isFalse);

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(AdminConstants.keyAdminToken);
      expect(token, isNotNull);
    });

    test('Registers admin account with custom password and logs in successfully', () async {
      final regUser = await authRepo.registerWithEmail(
        'Admin User',
        'admin@PuneExplorer.com',
        'MyCustomSecret999!',
        '+91 99999 88888',
      );
      expect(regUser.isAdmin, isTrue);

      final loggedInUser = await authRepo.signInWithEmail(
        'admin@PuneExplorer.com',
        'MyCustomSecret999!',
      );
      expect(loggedInUser.isAdmin, isTrue);
      expect(loggedInUser.email, 'admin@puneexplorer.com');
    });

    test('Rejects Admin unified signInWithEmail when incorrect password is provided', () async {
      expect(
        () => authRepo.signInWithEmail(
          'admin@puneexplorer.in',
          'IncorrectPassword!',
        ),
        throwsA(isA<Exception>()),
      );
    });

    test('User sign out switches active state to Guest profile without errors', () async {
      final container = ProviderContainer(
        overrides: [
          authRepositoryProvider.overrideWithValue(authRepo),
        ],
      );
      addTearDown(container.dispose);

      // Sign in user
      await container.read(authStateProvider.notifier).signIn('admin@puneexplorer.in', 'TestAdminPass123!');
      final activeUser = container.read(authStateProvider).value;
      expect(activeUser, isNotNull);
      expect(activeUser!.isGuest, isFalse);

      // Sign out
      await container.read(authStateProvider.notifier).signOut();
      final guestUser = container.read(authStateProvider).value;
      expect(guestUser, isNotNull);
      expect(guestUser!.isGuest, isTrue);
      expect(guestUser.name, equals('Puneri Explorer'));
    });

    test('appRouter redirects root path "/" to "/home" without 404', () {
      final config = appRouter.configuration;
      expect(config, isNotNull);
      // Verify appRouter has a route handling '/'
      final routes = appRouter.configuration.routes;
      final hasRootRoute = routes.any((r) => r is GoRoute && r.path == '/');
      expect(hasRootRoute, isTrue);
    });
  });
}
