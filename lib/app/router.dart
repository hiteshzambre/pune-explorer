import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../core/responsive/adaptive_scaffold.dart';
import '../features/home/presentation/home_screen.dart';
import '../features/explore/presentation/explore_screen.dart';
import '../features/darshan/presentation/pune_darshan_screen.dart';
import '../features/heritage_walks/presentation/heritage_walks_screen.dart';
import '../features/heritage_walks/presentation/heritage_walk_detail_screen.dart';
import '../features/budget/presentation/budget_calculator_screen.dart';
import '../features/destination/presentation/destination_detail_screen.dart';
import '../features/destination/presentation/destination_booking_screen.dart';
import '../features/booking/presentation/booking_screen.dart';
import '../features/booking/presentation/booking_confirmation_screen.dart';
import '../features/booking/presentation/digital_ticket_screen.dart';
import '../features/payment/presentation/qr_payment_screen.dart';
import '../features/payment/presentation/payment_receipt_screen.dart';
import '../features/favorites/presentation/favorites_screen.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants/app_constants.dart';
import '../core/constants/admin_constants.dart';
import '../core/supabase/supabase_config.dart';
import '../features/profile/presentation/profile_screen.dart';
import '../features/profile/presentation/my_bookings_screen.dart';
import '../features/authentication/presentation/auth_screen.dart';
import '../features/admin/presentation/admin_screen.dart';
import '../features/admin/presentation/shell/admin_layout_shell.dart';
import '../features/admin/presentation/screens/admin_dashboard_screen.dart';
import '../features/admin/presentation/screens/admin_home_cms_screen.dart';
import '../features/admin/presentation/screens/admin_destinations_screen.dart';
import '../features/admin/presentation/screens/admin_tours_screen.dart';
import '../features/admin/presentation/screens/admin_darshan_screen.dart';
import '../features/admin/presentation/screens/admin_heritage_walks_screen.dart';
import '../features/admin/presentation/screens/admin_categories_screen.dart';
import '../features/admin/presentation/screens/admin_media_library_screen.dart';
import '../features/admin/presentation/screens/admin_bookings_screen.dart';
import '../features/admin/presentation/screens/admin_payments_screen.dart';
import '../features/admin/presentation/screens/admin_users_screen.dart';
import '../features/admin/presentation/screens/admin_reviews_screen.dart';
import '../features/admin/presentation/screens/admin_faqs_screen.dart';
import '../features/admin/presentation/screens/admin_notifications_screen.dart';
import '../features/admin/presentation/screens/admin_seo_settings_screen.dart';
import '../features/admin/presentation/screens/admin_audit_logs_screen.dart';
import '../features/admin/presentation/screens/admin_analytics_screen.dart';
import '../features/admin/presentation/screens/admin_coupons_screen.dart';
import '../features/admin/presentation/screens/admin_content_preview_screen.dart';
import '../features/admin/presentation/screens/admin_scheduled_content_screen.dart';
import '../features/admin/presentation/screens/admin_support_screen.dart';
import '../features/admin/presentation/screens/admin_refunds_screen.dart';
import '../features/admin/presentation/screens/admin_system_health_screen.dart';
import '../features/admin/presentation/screens/admin_import_export_screen.dart';
import '../features/admin/presentation/screens/admin_personalization_screen.dart';
import '../features/admin/presentation/screens/admin_global_settings_screen.dart';
import '../features/itinerary/presentation/itinerary_planner_screen.dart';
import '../features/itinerary/presentation/itinerary_detail_screen.dart';
import '../features/journey/presentation/journey_mode_screen.dart';
import '../features/legal/presentation/privacy_policy_screen.dart';
import '../features/legal/presentation/terms_and_conditions_screen.dart';
import '../features/legal/presentation/cancellation_refund_screen.dart';
import '../features/legal/presentation/help_support_screen.dart';
import '../features/legal/presentation/about_screen.dart';
import '../features/legal/presentation/delete_account_screen.dart';

Future<String?> _adminAuthGuard(BuildContext context, GoRouterState state) async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString(AdminConstants.keyAdminToken);
  if (token != null && token.isNotEmpty) {
    return null;
  }

  // 1. Check active local/app user authentication
  final rawUser = prefs.getString(AppConstants.keyUserAuth);
  if (rawUser != null && rawUser.isNotEmpty) {
    try {
      final userMap = jsonDecode(rawUser) as Map<String, dynamic>;
      final email = (userMap['email'] as String? ?? '').toLowerCase();
      final role = (userMap['role'] as String? ?? '').toLowerCase();
      final isAdmin = userMap['isAdmin'] == true ||
          email.startsWith('admin@') ||
          email == 'admin@puneexplorer.com' ||
          email == 'admin@puneexplorer.in' ||
          role.contains('admin') ||
          role.contains('editor') ||
          role.contains('support');

      if (isAdmin) {
        final newToken = 'admin_usr_${DateTime.now().millisecondsSinceEpoch}';
        await prefs.setString(AdminConstants.keyAdminToken, newToken);
        await prefs.setString(AdminConstants.keyAdminEmail, email);
        await prefs.setString(AdminConstants.keyAdminRole, AdminConstants.roleSuperAdmin);
        return null;
      }
    } catch (_) {}
  }

  // 2. Fallback: check if active Supabase session belongs to an admin
  final sbUser = SupabaseConfig.client?.auth.currentUser;
  if (sbUser != null) {
    final email = (sbUser.email ?? '').toLowerCase();
    if (email.startsWith('admin@') || email == 'admin@puneexplorer.com' || email == 'admin@puneexplorer.in') {
      final newToken = 'admin_sb_${sbUser.id}';
      await prefs.setString(AdminConstants.keyAdminToken, newToken);
      await prefs.setString(AdminConstants.keyAdminEmail, sbUser.email ?? '');
      await prefs.setString(AdminConstants.keyAdminRole, AdminConstants.roleSuperAdmin);
      return null;
    }

    try {
      final profile = await SupabaseConfig.client
          ?.from(SupabaseConfig.tableProfiles)
          .select('role')
          .eq('id', sbUser.id)
          .maybeSingle();
      final role = profile?['role']?.toString().toLowerCase() ?? '';
      if (role.contains('admin') || role.contains('editor') || role.contains('support')) {
        final newToken = 'admin_sb_${sbUser.id}';
        await prefs.setString(AdminConstants.keyAdminToken, newToken);
        await prefs.setString(AdminConstants.keyAdminEmail, sbUser.email ?? '');
        await prefs.setString(
          AdminConstants.keyAdminRole,
          role.contains('super') ? AdminConstants.roleSuperAdmin : role,
        );
        return null;
      }
    } catch (_) {}
  }

  return '/auth?from=/admin';
}

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');

final appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/home',
  redirect: (context, state) {
    if (state.matchedLocation == '/' || state.uri.path == '/' || state.uri.path.isEmpty) {
      return '/home';
    }
    return null;
  },
  // R1: 404/Error route handler — shows a proper error page for unknown routes
  errorBuilder: (context, state) => Scaffold(
    appBar: AppBar(title: const Text('Page Not Found')),
    body: Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.explore_off_rounded, size: 80, color: Color(0xFF94A3B8)),
            const SizedBox(height: 24),
            const Text(
              '404 — Page Not Found',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 12),
            Text(
              'The path "${state.uri}" does not exist in PuneExplorer.',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, color: Color(0xFF64748B)),
            ),
            const SizedBox(height: 28),
            ElevatedButton.icon(
              onPressed: () => GoRouter.of(context).go('/home'),
              icon: const Icon(Icons.home_rounded, size: 18),
              label: const Text('Go to Home'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF059669),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      ),
    ),
  ),
  routes: [
    // Adaptive Shell Navigation (Mobile BottomNav, Tablet Rail, Desktop Sidebar)
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return AdaptiveNavigationScaffold(navigationShell: navigationShell);
      },
      branches: [
        // 0. Home
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/home',
              builder: (context, state) => const HomeScreen(),
            ),
          ],
        ),

        // 1. Explore
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/explore',
              builder: (context, state) => const ExploreScreen(),
            ),
          ],
        ),

        // 2. Plan Trip (Itinerary Planner)
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/itinerary',
              builder: (context, state) => const ItineraryPlannerScreen(),
            ),
          ],
        ),

        // 3. Pune Darshan
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/darshan',
              builder: (context, state) => const PuneDarshanScreen(),
            ),
          ],
        ),

        // 4. Heritage Walks of Pune (single canonical route)
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/walks',
              builder: (context, state) => const HeritageWalksScreen(),
            ),
          ],
        ),

        // 5. Budget Calculator
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/budget',
              builder: (context, state) => const BudgetCalculatorScreen(),
            ),
          ],
        ),

        // 6. Profile & Settings
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/profile',
              builder: (context, state) => const ProfileScreen(),
            ),
          ],
        ),
      ],
    ),

    // Root path alias redirects to /home
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/',
      redirect: (context, state) => '/home',
    ),

    // R4/P4: /plan alias redirects to /itinerary (fixes dead link from profile)
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/plan',
      redirect: (context, state) => '/itinerary',
    ),

    // R3: /routes alias redirects to /walks (single canonical route)
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/routes',
      redirect: (context, state) => '/walks',
    ),

    // Sub-screens & Direct Routes
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/destination/:id',
      builder: (context, state) {
        final id = state.pathParameters['id'] ?? 'dest_1';
        return DestinationDetailScreen(destinationId: id);
      },
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/destination/:id/book',
      builder: (context, state) {
        final id = state.pathParameters['id'] ?? 'dest_1';
        return DestinationBookingScreen(destinationId: id);
      },
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/booking/:tourId',
      builder: (context, state) {
        final tourId = state.pathParameters['tourId'] ?? 'PNE-DAR-01';
        return BookingScreen(tourId: tourId);
      },
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/booking-confirmation/:bookingId',
      builder: (context, state) {
        final bookingId = state.pathParameters['bookingId'] ?? '';
        return BookingConfirmationScreen(bookingId: bookingId);
      },
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/digital-ticket/:bookingId',
      builder: (context, state) {
        final bookingId = state.pathParameters['bookingId'] ?? '';
        return DigitalTicketScreen(bookingId: bookingId);
      },
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/payment/qr/:orderId',
      builder: (context, state) {
        final orderId = state.pathParameters['orderId'] ?? '';
        return QRPaymentScreen(orderId: orderId);
      },
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/payment/receipt/:orderId',
      builder: (context, state) {
        final orderId = state.pathParameters['orderId'] ?? '';
        return PaymentReceiptScreen(orderId: orderId);
      },
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/walk/:id',
      builder: (context, state) {
        final id = state.pathParameters['id'] ?? 'PNE-WAL-01';
        return HeritageWalkDetailScreen(walkId: id);
      },
    ),
    // R3: /route/:id alias redirects to canonical /walk/:id
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/route/:id',
      redirect: (context, state) => '/walk/${state.pathParameters['id']}',
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/favorites',
      builder: (context, state) => const FavoritesScreen(),
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/my-bookings',
      builder: (context, state) => const MyBookingsScreen(),
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/auth',
      builder: (context, state) {
        final from = state.uri.queryParameters['from'] ?? state.uri.queryParameters['redirect'];
        final redirectPath = (from == '/admin') ? '/admin/dashboard' : from;
        return AuthScreen(redirectPath: redirectPath);
      },
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/itinerary/:id',
      builder: (context, state) {
        final id = state.pathParameters['id'] ?? 'itin_weekend_heritage';
        return ItineraryDetailScreen(planId: id);
      },
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/journey/:bookingId',
      builder: (context, state) {
        final bookingId = state.pathParameters['bookingId'] ?? '';
        return JourneyModeScreen(bookingId: bookingId);
      },
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/admin/login',
      redirect: (context, state) => '/auth?from=/admin',
    ),
    ShellRoute(
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state, child) => AdminLayoutShell(
        currentPath: state.matchedLocation,
        child: child,
      ),
      routes: [
        GoRoute(
          path: '/admin',
          redirect: (context, state) async {
            final check = await _adminAuthGuard(context, state);
            if (check != null) return check;
            return '/admin/dashboard';
          },
        ),
        GoRoute(
          path: '/admin/dashboard',
          redirect: _adminAuthGuard,
          builder: (context, state) => const AdminDashboardScreen(),
        ),
        GoRoute(
          path: '/admin/home-cms',
          redirect: _adminAuthGuard,
          builder: (context, state) => const AdminHomeCmsScreen(),
        ),
        GoRoute(
          path: '/admin/destinations',
          redirect: _adminAuthGuard,
          builder: (context, state) => const AdminDestinationsScreen(),
        ),
        GoRoute(
          path: '/admin/tours',
          redirect: _adminAuthGuard,
          builder: (context, state) => const AdminToursScreen(),
        ),
        GoRoute(
          path: '/admin/darshan',
          redirect: _adminAuthGuard,
          builder: (context, state) => const AdminDarshanScreen(),
        ),
        GoRoute(
          path: '/admin/heritage-walks',
          redirect: _adminAuthGuard,
          builder: (context, state) => const AdminHeritageWalksScreen(),
        ),
        GoRoute(
          path: '/admin/categories',
          redirect: _adminAuthGuard,
          builder: (context, state) => const AdminCategoriesScreen(),
        ),
        GoRoute(
          path: '/admin/media',
          redirect: _adminAuthGuard,
          builder: (context, state) => const AdminMediaLibraryScreen(),
        ),
        GoRoute(
          path: '/admin/bookings',
          redirect: _adminAuthGuard,
          builder: (context, state) => const AdminBookingsScreen(),
        ),
        GoRoute(
          path: '/admin/payments',
          redirect: _adminAuthGuard,
          builder: (context, state) => const AdminPaymentsScreen(),
        ),
        GoRoute(
          path: '/admin/users',
          redirect: _adminAuthGuard,
          builder: (context, state) => const AdminUsersScreen(),
        ),
        GoRoute(
          path: '/admin/reviews',
          redirect: _adminAuthGuard,
          builder: (context, state) => const AdminReviewsScreen(),
        ),
        GoRoute(
          path: '/admin/faqs',
          redirect: _adminAuthGuard,
          builder: (context, state) => const AdminFaqsScreen(),
        ),
        GoRoute(
          path: '/admin/notifications',
          redirect: _adminAuthGuard,
          builder: (context, state) => const AdminNotificationsScreen(),
        ),
        GoRoute(
          path: '/admin/seo',
          redirect: _adminAuthGuard,
          builder: (context, state) => const AdminSeoSettingsScreen(),
        ),
        GoRoute(
          path: '/admin/audit-logs',
          redirect: _adminAuthGuard,
          builder: (context, state) => const AdminAuditLogsScreen(),
        ),
        GoRoute(
          path: '/admin/analytics',
          redirect: _adminAuthGuard,
          builder: (context, state) => const AdminAnalyticsScreen(),
        ),
        GoRoute(
          path: '/admin/coupons',
          redirect: _adminAuthGuard,
          builder: (context, state) => const AdminCouponsScreen(),
        ),
        GoRoute(
          path: '/admin/content-preview',
          redirect: _adminAuthGuard,
          builder: (context, state) => const AdminContentPreviewScreen(),
        ),
        GoRoute(
          path: '/admin/scheduled-content',
          redirect: _adminAuthGuard,
          builder: (context, state) => const AdminScheduledContentScreen(),
        ),
        GoRoute(
          path: '/admin/support',
          redirect: _adminAuthGuard,
          builder: (context, state) => const AdminSupportScreen(),
        ),
        GoRoute(
          path: '/admin/refunds',
          redirect: _adminAuthGuard,
          builder: (context, state) => const AdminRefundsScreen(),
        ),
        GoRoute(
          path: '/admin/system-health',
          redirect: _adminAuthGuard,
          builder: (context, state) => const AdminSystemHealthScreen(),
        ),
        GoRoute(
          path: '/admin/import-export',
          redirect: _adminAuthGuard,
          builder: (context, state) => const AdminImportExportScreen(),
        ),
        GoRoute(
          path: '/admin/personalization',
          redirect: _adminAuthGuard,
          builder: (context, state) => const AdminPersonalizationScreen(),
        ),
        GoRoute(
          path: '/admin/settings',
          redirect: _adminAuthGuard,
          builder: (context, state) => const AdminGlobalSettingsScreen(),
        ),
        GoRoute(
          path: '/admin/console',
          redirect: _adminAuthGuard,
          builder: (context, state) => const AdminScreen(),
        ),
      ],
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/privacy-policy',
      builder: (context, state) => const PrivacyPolicyScreen(),
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/terms-and-conditions',
      builder: (context, state) => const TermsAndConditionsScreen(),
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/cancellation-refund',
      builder: (context, state) => const CancellationRefundScreen(),
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/help',
      builder: (context, state) => const HelpSupportScreen(),
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/contact-support',
      builder: (context, state) => const HelpSupportScreen(),
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/about',
      builder: (context, state) => const AboutScreen(),
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/delete-account',
      builder: (context, state) => const DeleteAccountScreen(),
    ),
  ],
);
