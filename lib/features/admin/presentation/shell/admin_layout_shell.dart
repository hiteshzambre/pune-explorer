import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/admin_permissions.dart';
import '../../../../core/providers/app_providers.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../data/models/admin_personalization.dart';
import '../theme/admin_theme.dart';
import '../widgets/admin_global_search_dialog.dart';

class AdminNavEntry {
  final String title;
  final String route;
  final IconData icon;
  final String requiredPermission;
  final String? badge;

  const AdminNavEntry({
    required this.title,
    required this.route,
    required this.icon,
    required this.requiredPermission,
    this.badge,
  });
}

class AdminNavGroup {
  final String groupName;
  final List<AdminNavEntry> items;

  const AdminNavGroup({required this.groupName, required this.items});
}

class AdminLayoutShell extends ConsumerStatefulWidget {
  final Widget child;
  final String currentPath;

  const AdminLayoutShell({
    super.key,
    required this.child,
    required this.currentPath,
  });

  @override
  ConsumerState<AdminLayoutShell> createState() => _AdminLayoutShellState();
}

class _AdminLayoutShellState extends ConsumerState<AdminLayoutShell> {
  bool _isSidebarCollapsed = false;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(adminSessionProvider);
    final personalization = ref.watch(adminPersonalizationProvider);
    final pendingOrders = ref.watch(pendingPaymentVerificationsProvider);
    final isDark = personalization.themeMode == 'dark';
    final adminThemeData = isDark ? AppTheme.darkTheme : AppTheme.lightTheme;

    final navGroups = _buildNavigationGroups(pendingOrders.length);
    final isDesktop = MediaQuery.of(context).size.width >= 1024;
    final isTablet = MediaQuery.of(context).size.width >= 768 && !isDesktop;

    final sidebarBgColor = isDark ? AdminTheme.sidebarBg : AdminTheme.sidebarBgLight;

    return Theme(
      data: adminThemeData,
      child: CallbackShortcuts(
        bindings: {
          const SingleActivator(LogicalKeyboardKey.keyK, control: true): () =>
              AdminGlobalSearchDialog.show(context),
          const SingleActivator(LogicalKeyboardKey.keyK, meta: true): () =>
              AdminGlobalSearchDialog.show(context),
        },
        child: Focus(
          autofocus: true,
          child: Scaffold(
            key: _scaffoldKey,
            backgroundColor: isDark ? AdminTheme.scaffoldBgDark : AdminTheme.scaffoldBg,
            drawer: isDesktop ? null : Drawer(
              backgroundColor: sidebarBgColor,
              child: _buildSidebarContent(context, session, navGroups, isDark: isDark, isMobileDrawer: true),
            ),
            body: Row(
              children: [
                // Desktop or Tablet Sidebar
                if (isDesktop || isTablet)
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: _isSidebarCollapsed && isTablet
                        ? AdminTheme.sidebarCollapsedWidth
                        : AdminTheme.sidebarExpandedWidth,
                    decoration: BoxDecoration(
                      color: sidebarBgColor,
                      border: Border(
                        right: BorderSide(
                          color: isDark ? AdminTheme.sidebarBorder : AdminTheme.sidebarBorderLight,
                          width: 1,
                        ),
                      ),
                    ),
                    child: _buildSidebarContent(
                      context,
                      session,
                      navGroups,
                      isDark: isDark,
                      isCollapsed: _isSidebarCollapsed && isTablet,
                    ),
                  ),

                // Main Content Area
                Expanded(
                  child: Column(
                    children: [
                      // Top App Header
                      _buildTopHeader(context, session, isDesktop, isTablet, pendingOrders.length, isDark, personalization),

                      // Page Body
                      Expanded(child: widget.child),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTopHeader(
    BuildContext context,
    AdminSessionState session,
    bool isDesktop,
    bool isTablet,
    int pendingPaymentsCount,
    bool isDark,
    AdminPersonalization personalization,
  ) {
    return Container(
      height: AdminTheme.topHeaderHeight,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : Colors.white,
        border: Border(
          bottom: BorderSide(
            color: isDark ? AdminTheme.cardBorderDark : AdminTheme.cardBorder,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // Drawer Trigger for Mobile
          if (!isDesktop && !isTablet)
            IconButton(
              icon: const Icon(Icons.menu_rounded),
              onPressed: () => _scaffoldKey.currentState?.openDrawer(),
            ),

          // Collapse Trigger for Tablet
          if (isTablet)
            IconButton(
              icon: Icon(_isSidebarCollapsed ? Icons.menu_open_rounded : Icons.menu_rounded),
              onPressed: () => setState(() => _isSidebarCollapsed = !_isSidebarCollapsed),
            ),

          // Search Pill (Ctrl + K)
          Expanded(
            child: Align(
              alignment: Alignment.centerLeft,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: InkWell(
                  onTap: () => AdminGlobalSearchDialog.show(context),
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    height: 38,
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.search_rounded,
                          size: 18,
                          color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Search anything... (Ctrl + K)',
                            style: TextStyle(
                              fontSize: 12.5,
                              color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF334155) : Colors.white,
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(
                              color: isDark ? const Color(0xFF475569) : const Color(0xFFCBD5E1),
                            ),
                          ),
                          child: const Text('⌘K', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(width: 16),

          // Live App shortcut
          TextButton.icon(
            style: TextButton.styleFrom(
              foregroundColor: AdminTheme.emerald,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            ),
            onPressed: () => context.go('/home'),
            icon: const Icon(Icons.open_in_new_rounded, size: 15),
            label: const Text('Live App', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12.5)),
          ),

          const SizedBox(width: 10),

          // Notifications bell
          Stack(
            clipBehavior: Clip.none,
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_none_rounded, size: 20),
                onPressed: () => context.go('/admin/notifications'),
              ),
              if (pendingPaymentsCount > 0)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(color: AdminTheme.rose, shape: BoxShape.circle),
                    constraints: const BoxConstraints(minWidth: 8, minHeight: 8),
                  ),
                ),
            ],
          ),

          const SizedBox(width: 6),

          // Theme Toggle Button (Light / Dark)
          IconButton(
            tooltip: isDark ? 'Switch to Light Theme' : 'Switch to Dark Theme',
            icon: Icon(
              isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
              size: 20,
              color: isDark ? const Color(0xFFFBBF24) : const Color(0xFF64748B),
            ),
            onPressed: () {
              final newMode = isDark ? 'light' : 'dark';
              ref.read(adminPersonalizationProvider.notifier).updateSettings(
                personalization.copyWith(themeMode: newMode),
              );
            },
          ),

          const SizedBox(width: 10),

          // User Profile Card & Role Switcher
          InkWell(
            onTap: () => _showRoleSwitcherDialog(context, session),
            borderRadius: BorderRadius.circular(10),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: AdminTheme.emerald.withValues(alpha: 0.2),
                    child: const Text('A', style: TextStyle(color: AdminTheme.emerald, fontWeight: FontWeight.bold, fontSize: 13)),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        session.email.isNotEmpty ? session.email.split('@').first : 'Admin',
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: isDark ? Colors.white : AdminTheme.textPrimary,
                        ),
                      ),
                      Text(
                        session.role.isNotEmpty ? session.role : 'Super Admin',
                        style: const TextStyle(fontSize: 10.5, color: AdminTheme.emerald, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                  const SizedBox(width: 4),
                  const Icon(Icons.keyboard_arrow_down_rounded, size: 16, color: Colors.grey),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebarContent(
    BuildContext context,
    AdminSessionState session,
    List<AdminNavGroup> navGroups, {
    bool isMobileDrawer = false,
    bool isCollapsed = false,
    bool isDark = false,
  }) {
    final activeRole = AdminRole.fromString(session.role);

    return Column(
      children: [
        // Brand Header
        Container(
          height: AdminTheme.topHeaderHeight,
          padding: const EdgeInsets.symmetric(horizontal: 18),
          alignment: Alignment.centerLeft,
          decoration: BoxDecoration(
            color: isDark ? AdminTheme.sidebarBg : AdminTheme.sidebarBgLight,
            border: Border(bottom: BorderSide(color: isDark ? AdminTheme.sidebarBorder : AdminTheme.sidebarBorderLight, width: 1)),
          ),
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AdminTheme.emerald,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Center(
                  child: Text('✳', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                ),
              ),
              if (!isCollapsed) ...[
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'PuneExplorer',
                        style: TextStyle(
                          color: isDark ? Colors.white : AdminTheme.textPrimary,
                          fontWeight: FontWeight.w900,
                          fontSize: 15,
                          letterSpacing: -0.2,
                        ),
                      ),
                      Text(
                        'Enterprise CMS Hub',
                        style: TextStyle(
                          color: isDark ? const Color(0xFF6EE7B7) : AdminTheme.emeraldDark,
                          fontSize: 10.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),

        // Navigation Items
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
            children: navGroups.map((group) {
              final visibleItems = group.items.where((item) {
                return AdminPermissions.hasPermission(activeRole, item.requiredPermission);
              }).toList();

              if (visibleItems.isEmpty) return const SizedBox.shrink();

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!isCollapsed)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(12, 16, 12, 8),
                      child: Text(
                        group.groupName,
                        style: TextStyle(
                          color: isDark ? AdminTheme.sidebarTextGroup : AdminTheme.sidebarTextGroupLight,
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ),
                  ...visibleItems.map((item) {
                    final isSelected = widget.currentPath == item.route ||
                        (item.route != '/admin/dashboard' && widget.currentPath.startsWith(item.route));

                    return Container(
                      margin: const EdgeInsets.symmetric(vertical: 2),
                      child: Tooltip(
                        message: isCollapsed ? item.title : '',
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () {
                              if (isMobileDrawer) Navigator.of(context).pop();
                              context.go(item.route);
                            },
                            borderRadius: BorderRadius.circular(8),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 150),
                              padding: EdgeInsets.symmetric(
                                horizontal: isCollapsed ? 12 : 12,
                                vertical: 9,
                              ),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? (isDark ? AdminTheme.sidebarItemActive : AdminTheme.sidebarItemActiveLight)
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    item.icon,
                                    size: 18,
                                    color: isSelected
                                        ? (isDark ? Colors.white : AdminTheme.sidebarTextActiveLight)
                                        : (isDark ? AdminTheme.sidebarTextInactive : AdminTheme.sidebarTextInactiveLight),
                                  ),
                                  if (!isCollapsed) ...[
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        item.title,
                                        style: TextStyle(
                                          color: isSelected
                                              ? (isDark ? Colors.white : AdminTheme.sidebarTextActiveLight)
                                              : (isDark ? AdminTheme.sidebarTextInactive : const Color(0xFF334155)),
                                          fontSize: 12.5,
                                          fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    if (item.badge != null)
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: isSelected ? (isDark ? Colors.white.withValues(alpha: 0.25) : AdminTheme.emerald) : AdminTheme.saffron,
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: Text(
                                          item.badge!,
                                          style: TextStyle(
                                            color: isSelected ? (isDark ? Colors.white : Colors.white) : Colors.black,
                                            fontSize: 10,
                                            fontWeight: FontWeight.w900,
                                          ),
                                        ),
                                      ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ],
              );
            }).toList(),
          ),
        ),

        // Bottom User Profile Bar
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isDark ? AdminTheme.sidebarSurface : AdminTheme.sidebarSurfaceLight,
            border: Border(top: BorderSide(color: isDark ? AdminTheme.sidebarBorder : AdminTheme.sidebarBorderLight, width: 1)),
          ),
          child: isCollapsed
              ? IconButton(
                  icon: Icon(Icons.logout_rounded, color: isDark ? Colors.white70 : const Color(0xFF64748B), size: 18),
                  onPressed: () => _handleLogout(context),
                )
              : Row(
                  children: [
                    CircleAvatar(
                      radius: 16,
                      backgroundColor: AdminTheme.emerald,
                      child: Text(
                        session.email.isNotEmpty ? session.email.substring(0, 1).toUpperCase() : 'A',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            session.email.isNotEmpty ? session.email.split('@').first : 'Admin',
                            style: TextStyle(
                              color: isDark ? Colors.white : AdminTheme.textPrimary,
                              fontSize: 12.5,
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            session.role.isNotEmpty ? session.role : 'Super Admin',
                            style: TextStyle(
                              color: isDark ? const Color(0xFF6EE7B7) : AdminTheme.emeraldDark,
                              fontSize: 10.5,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.logout_rounded, color: isDark ? Colors.white70 : const Color(0xFF64748B), size: 18),
                      tooltip: 'Sign Out',
                      onPressed: () => _handleLogout(context),
                    ),
                  ],
                ),
        ),
      ],
    );
  }

  List<AdminNavGroup> _buildNavigationGroups(int pendingPaymentsCount) {
    return [
      const AdminNavGroup(
        groupName: 'COMMAND CENTER',
        items: [
          AdminNavEntry(
            title: 'Overview Dashboard',
            route: '/admin/dashboard',
            icon: Icons.dashboard_customize_rounded,
            requiredPermission: AdminPermissions.auditView,
          ),
          AdminNavEntry(
            title: 'Analytics & Reports',
            route: '/admin/analytics',
            icon: Icons.analytics_rounded,
            requiredPermission: AdminPermissions.auditView,
          ),
        ],
      ),
      const AdminNavGroup(
        groupName: 'CONTENT MANAGEMENT',
        items: [
          AdminNavEntry(
            title: 'Homepage CMS',
            route: '/admin/home-cms',
            icon: Icons.view_quilt_rounded,
            requiredPermission: AdminPermissions.contentView,
          ),
          AdminNavEntry(
            title: 'Destinations & Places',
            route: '/admin/destinations',
            icon: Icons.castle_rounded,
            requiredPermission: AdminPermissions.contentView,
          ),
          AdminNavEntry(
            title: 'Tour Packages',
            route: '/admin/tours',
            icon: Icons.tour_rounded,
            requiredPermission: AdminPermissions.tourView,
          ),
          AdminNavEntry(
            title: 'Pune Darshan Circuits',
            route: '/admin/darshan',
            icon: Icons.directions_bus_filled_rounded,
            requiredPermission: AdminPermissions.tourView,
          ),
          AdminNavEntry(
            title: 'Heritage Walks',
            route: '/admin/heritage-walks',
            icon: Icons.directions_walk_rounded,
            requiredPermission: AdminPermissions.contentView,
          ),
          AdminNavEntry(
            title: 'Categories & Tags',
            route: '/admin/categories',
            icon: Icons.category_rounded,
            requiredPermission: AdminPermissions.contentView,
          ),
          AdminNavEntry(
            title: 'Media Assets Library',
            route: '/admin/media',
            icon: Icons.perm_media_rounded,
            requiredPermission: AdminPermissions.mediaView,
          ),
          AdminNavEntry(
            title: 'Content Preview',
            route: '/admin/content-preview',
            icon: Icons.preview_rounded,
            requiredPermission: AdminPermissions.contentView,
          ),
          AdminNavEntry(
            title: 'Scheduled Content',
            route: '/admin/scheduled-content',
            icon: Icons.schedule_rounded,
            requiredPermission: AdminPermissions.contentView,
          ),
        ],
      ),
      AdminNavGroup(
        groupName: 'OPERATIONS',
        items: [
          const AdminNavEntry(
            title: 'Bookings Operations',
            route: '/admin/bookings',
            icon: Icons.confirmation_number_rounded,
            requiredPermission: AdminPermissions.bookingView,
          ),
          AdminNavEntry(
            title: 'Payments & UTR Verification',
            route: '/admin/payments',
            icon: Icons.verified_user_rounded,
            requiredPermission: AdminPermissions.paymentView,
            badge: pendingPaymentsCount > 0 ? '$pendingPaymentsCount' : null,
          ),
          const AdminNavEntry(
            title: 'Refunds & Cancellations',
            route: '/admin/refunds',
            icon: Icons.currency_rupee_rounded,
            requiredPermission: AdminPermissions.bookingCancel,
          ),
          const AdminNavEntry(
            title: 'Coupons & Promotions',
            route: '/admin/coupons',
            icon: Icons.local_offer_rounded,
            requiredPermission: AdminPermissions.contentView,
          ),
        ],
      ),
      const AdminNavGroup(
        groupName: 'CUSTOMERS',
        items: [
          AdminNavEntry(
            title: 'User Management',
            route: '/admin/users',
            icon: Icons.people_alt_rounded,
            requiredPermission: AdminPermissions.userView,
          ),
          AdminNavEntry(
            title: 'Review Moderation',
            route: '/admin/reviews',
            icon: Icons.rate_review_rounded,
            requiredPermission: AdminPermissions.reviewView,
          ),
          AdminNavEntry(
            title: 'Customer Support',
            route: '/admin/support',
            icon: Icons.support_agent_rounded,
            requiredPermission: AdminPermissions.userView,
          ),
        ],
      ),
      const AdminNavGroup(
        groupName: 'COMMUNICATION',
        items: [
          AdminNavEntry(
            title: 'Notification Center',
            route: '/admin/notifications',
            icon: Icons.campaign_rounded,
            requiredPermission: AdminPermissions.settingsView,
          ),
          AdminNavEntry(
            title: 'Help FAQs',
            route: '/admin/faqs',
            icon: Icons.quiz_rounded,
            requiredPermission: AdminPermissions.contentView,
          ),
        ],
      ),
      const AdminNavGroup(
        groupName: 'SYSTEM',
        items: [
          AdminNavEntry(
            title: 'System Health',
            route: '/admin/system-health',
            icon: Icons.health_and_safety_rounded,
            requiredPermission: AdminPermissions.auditView,
          ),
          AdminNavEntry(
            title: 'Import / Export',
            route: '/admin/import-export',
            icon: Icons.import_export_rounded,
            requiredPermission: AdminPermissions.adminManage,
          ),
          AdminNavEntry(
            title: 'Admin Personalization',
            route: '/admin/personalization',
            icon: Icons.palette_rounded,
            requiredPermission: AdminPermissions.settingsView,
          ),
          AdminNavEntry(
            title: 'Global Settings',
            route: '/admin/settings',
            icon: Icons.settings_rounded,
            requiredPermission: AdminPermissions.settingsView,
          ),
          AdminNavEntry(
            title: 'SEO & Brand Settings',
            route: '/admin/seo',
            icon: Icons.tune_rounded,
            requiredPermission: AdminPermissions.settingsView,
          ),
          AdminNavEntry(
            title: 'Audit Logs & Security',
            route: '/admin/audit-logs',
            icon: Icons.security_update_good_rounded,
            requiredPermission: AdminPermissions.auditView,
          ),
        ],
      ),
    ];
  }

  void _showRoleSwitcherDialog(BuildContext context, AdminSessionState session) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AdminTheme.emerald.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.admin_panel_settings_rounded, color: AdminTheme.emerald, size: 22),
            ),
            const SizedBox(width: 12),
            const Text(
              'Switch Active Admin Role',
              style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w800),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Active Administrator: ${session.email.isNotEmpty ? session.email : "Super Admin"}',
              style: const TextStyle(color: Colors.grey, fontSize: 13),
            ),
            const SizedBox(height: 16),
            ...AdminRole.values.map((role) {
              final isCurrent = session.role == role.label;
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: isCurrent ? AdminTheme.emerald.withValues(alpha: 0.15) : const Color(0xFF0F172A),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isCurrent ? AdminTheme.emerald : const Color(0xFF334155),
                  ),
                ),
                child: ListTile(
                  dense: true,
                  title: Text(
                    role.label,
                    style: TextStyle(
                      color: isCurrent ? AdminTheme.emerald : Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 13.5,
                    ),
                  ),
                  subtitle: Text(
                    role.description,
                    style: TextStyle(color: Colors.grey.shade400, fontSize: 11.5),
                  ),
                  trailing: isCurrent
                      ? const Icon(Icons.check_circle_rounded, color: AdminTheme.emerald, size: 20)
                      : null,
                  onTap: () {
                    ref.read(adminSessionProvider.notifier).switchRole(role);
                    Navigator.of(ctx).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Switched role to: ${role.label}'),
                        backgroundColor: AdminTheme.emerald,
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  },
                ),
              );
            }),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
        ],
      ),
    );
  }

  Future<void> _handleLogout(BuildContext context) async {
    await ref.read(adminSessionProvider.notifier).logout();
    if (context.mounted) {
      context.go('/admin/login');
    }
  }
}
