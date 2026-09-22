import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../app/theme/app_colors.dart';
import '../../core/providers/app_providers.dart';
import '../../data/models/user_profile.dart';
import '../../features/ai_assistant/presentation/punekar_bot_sheet.dart';
import '../widgets/omni_search_dialog.dart';

/// Adaptive Navigation Scaffold for PuneExplorer.
/// Redesigned strictly in accordance with the reference specification (media_1789750315777.png):
/// 1. Full-width Top Desktop Header:
///    - Left: Pune gate emblem, "PuneExplorer" brand typography, "Travel • Heritage • Culture" subtitle, and collapse toggle.
///    - Center: Wide pill-shaped search container with ⌘K shortcut triggering OmniSearchDialog.
///    - Right: Quick Links (Explore, My Trips, Saved), Notification bell with unread badge pill, and Profile Dropdown Pill.
/// 2. Left Navigation Sidebar:
///    - 7 canonical destinations (Home, Explore, Plan Trip, Pune Darshan, Heritage Walks, Budget Planner, Profile).
///    - Active item: Dark forest green pill container (#064E3B) with white icon, bold text, and chevron >.
///    - Inactive items: Slate text & icon with smooth 180ms hover state.
///    - PunekarBot AI Card: Clean mint container with "PunekarBot AI" title, subtitle, and dark green "Chat with AI" button.
///    - Bottom Promo Card ("Preserve Explore Belong"): Sage green gradient card with arrow button for Heritage Walks.
/// 3. Tablet (768-1023px): Header + compact collapsible navigation rail (76px).
/// 4. Mobile (320-767px): Responsive drawer with the new visual hierarchy + floating bottom dock bar + PunekarBot FAB.
class AdaptiveNavigationScaffold extends ConsumerStatefulWidget {
  final StatefulNavigationShell navigationShell;

  const AdaptiveNavigationScaffold({
    super.key,
    required this.navigationShell,
  });

  @override
  ConsumerState<AdaptiveNavigationScaffold> createState() => _AdaptiveNavigationScaffoldState();
}

class _AdaptiveNavigationScaffoldState extends ConsumerState<AdaptiveNavigationScaffold> {
  bool _isCollapsed = false;

  void _onItemTapped(int index) {
    widget.navigationShell.goBranch(
      index,
      initialLocation: index == widget.navigationShell.currentIndex,
    );
  }

  void _toggleCollapsed() {
    HapticFeedback.selectionClick();
    setState(() {
      _isCollapsed = !_isCollapsed;
    });
  }

  List<_NavItem> _buildNavItems(int bookingsCount) {
    return [
      const _NavItem(
        label: 'Home',
        subtitle: 'Your travel journey begins',
        icon: Icons.home_outlined,
        selectedIcon: Icons.home_rounded,
        primaryColor: Color(0xFF10B981), // Emerald
        secondaryColor: Color(0xFF34D399),
        gradientColors: [Color(0xFF059669), Color(0xFF10B981)],
        branchIndex: 0,
      ),
      const _NavItem(
        label: 'Explore',
        subtitle: 'Forts, places & experiences',
        icon: Icons.explore_outlined,
        selectedIcon: Icons.explore_rounded,
        primaryColor: Color(0xFF0EA5E9), // Sky Blue
        secondaryColor: Color(0xFF38BDF8),
        gradientColors: [Color(0xFF0284C7), Color(0xFF0EA5E9)],
        branchIndex: 1,
      ),
      const _NavItem(
        label: 'Plan Trip',
        subtitle: 'Create your itinerary',
        icon: Icons.map_outlined,
        selectedIcon: Icons.map_rounded,
        primaryColor: Color(0xFFF43F5E), // Sunset Rose
        secondaryColor: Color(0xFFFB7185),
        gradientColors: [Color(0xFFE11D48), Color(0xFFF43F5E)],
        branchIndex: 2,
      ),
      const _NavItem(
        label: 'Pune Darshan',
        subtitle: 'Book tickets & passes',
        icon: Icons.directions_bus_outlined,
        selectedIcon: Icons.directions_bus_rounded,
        primaryColor: Color(0xFFF97316), // Saffron Orange
        secondaryColor: Color(0xFFFB923C),
        gradientColors: [Color(0xFFEA580C), Color(0xFFF97316)],
        branchIndex: 3,
      ),
      const _NavItem(
        label: 'Heritage Walks',
        subtitle: 'Guided trails & stories',
        icon: Icons.directions_walk_rounded,
        selectedIcon: Icons.hiking_rounded,
        primaryColor: Color(0xFFF59E0B), // Amber Gold
        secondaryColor: Color(0xFFFBBF24),
        gradientColors: [Color(0xFFD97706), Color(0xFFF59E0B)],
        branchIndex: 4,
      ),
      const _NavItem(
        label: 'Budget',
        displayTitle: 'Budget Planner',
        subtitle: 'Plan smart, travel more',
        icon: Icons.calculate_outlined,
        selectedIcon: Icons.calculate_rounded,
        primaryColor: Color(0xFF8B5CF6), // Purple
        secondaryColor: Color(0xFFA78BFA),
        gradientColors: [Color(0xFF7C3AED), Color(0xFF8B5CF6)],
        branchIndex: 5,
      ),
      _NavItem(
        label: 'Profile',
        subtitle: 'Explorer passport & badges',
        icon: Icons.person_outline_rounded,
        selectedIcon: Icons.person_rounded,
        badgeCount: bookingsCount > 0 ? bookingsCount : null,
        primaryColor: const Color(0xFFEAB308),
        secondaryColor: const Color(0xFFFDE047),
        gradientColors: const [Color(0xFFCA8A04), Color(0xFFEAB308)],
        branchIndex: 6,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isMobile = screenWidth < 768;
    final isDesktop = screenWidth >= 1024;
    final currentIndex = widget.navigationShell.currentIndex;

    final user = ref.watch(authStateProvider.select((s) => s.value));
    final bookingsCount = ref.watch(userBookingsProvider.select((b) => b.value?.length ?? 0));
    final navItems = _buildNavItems(bookingsCount);

    // ── 1. MOBILE (< 768px): Responsive Drawer + Bottom Dock Bar ────────────
    if (isMobile) {
      final mobileNavIndices = [0, 1, 2, 3, 6]; // Home, Explore, Plan Trip, Darshan, Profile
      final mobileNavItems = mobileNavIndices.map((i) => navItems[i]).toList();
      final activeMobileIndex = () {
        for (int i = 0; i < mobileNavItems.length; i++) {
          if (mobileNavItems[i].branchIndex == currentIndex) return i;
        }
        return 0;
      }();

      return Scaffold(
        drawer: Drawer(
          backgroundColor: isDark ? AppColors.darkSurface : const Color(0xFFFFFFFF),
          elevation: 16,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.horizontal(right: Radius.circular(20)),
          ),
          child: _MobileNavDrawer(
            navItems: navItems,
            currentIndex: currentIndex,
            user: user,
            bookingsCount: bookingsCount,
            isDark: isDark,
            onItemTapped: (index) {
              Navigator.of(context).pop();
              _onItemTapped(index);
            },
          ),
        ),
        body: widget.navigationShell,
        floatingActionButton: _buildPunekarBotFab(context, isDark),
        bottomNavigationBar: _PremiumModernBottomBar(
          items: mobileNavItems,
          currentIndex: activeMobileIndex,
          isDark: isDark,
          onTap: (index) {
            HapticFeedback.selectionClick();
            _onItemTapped(mobileNavItems[index].branchIndex);
          },
        ),
      );
    }

    // ── 2. DESKTOP & LAPTOP (>= 1024px): Full Reference Top Header + Sidebar ─
    if (isDesktop) {
      final isLaptop = screenWidth >= 1024 && screenWidth < 1440;
      final sidebarWidth = isLaptop ? 240.0 : 252.0;

      return Scaffold(
        backgroundColor: isDark ? AppColors.darkBackground : const Color(0xFFF8FAFC),
        body: Column(
          children: [
            // Top Desktop Header (Reference Design)
            _DesktopHeader(
              user: user,
              isDark: isDark,
              screenWidth: screenWidth,
              isCollapsed: _isCollapsed,
              onToggleCollapse: _toggleCollapsed,
              onItemTapped: _onItemTapped,
            ),

            // Main Body: Left Navigation Sidebar + Screen Content
            Expanded(
              child: Row(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    curve: Curves.easeOutCubic,
                    width: _isCollapsed ? 76.0 : sidebarWidth,
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF0F172A) : Colors.white,
                      border: Border(
                        right: BorderSide(
                          color: isDark ? AppColors.darkBorder : const Color(0xFFF1F5F9),
                          width: 1.2,
                        ),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.03),
                          blurRadius: 10,
                          offset: const Offset(2, 0),
                        ),
                      ],
                    ),
                    child: ClipRect(
                      child: OverflowBox(
                        alignment: Alignment.topLeft,
                        minWidth: _isCollapsed ? 76.0 : sidebarWidth,
                        maxWidth: _isCollapsed ? 76.0 : sidebarWidth,
                        child: _isCollapsed
                            ? _CollapsedSidebarRail(
                                navItems: navItems,
                                currentIndex: currentIndex,
                                user: user,
                                isDark: isDark,
                                onToggleExpand: _toggleCollapsed,
                                onItemTapped: _onItemTapped,
                              )
                            : SizedBox(
                                width: sidebarWidth,
                                child: _DesktopNavigationSidebar(
                                  navItems: navItems,
                                  currentIndex: currentIndex,
                                  user: user,
                                  bookingsCount: bookingsCount,
                                  isDark: isDark,
                                  isLaptop: isLaptop,
                                  onItemTapped: _onItemTapped,
                                ),
                              ),
                      ),
                    ),
                  ),
                  Expanded(child: widget.navigationShell),
                ],
              ),
            ),
          ],
        ),
      );
    }

    // ── 3. TABLET (768px - 1023px): Header + Navigation Rail ────────────────
    final railItems = navItems;
    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : const Color(0xFFF8FAFC),
      body: Column(
        children: [
          _DesktopHeader(
            user: user,
            isDark: isDark,
            screenWidth: screenWidth,
            isCollapsed: true,
            onToggleCollapse: _toggleCollapsed,
            onItemTapped: _onItemTapped,
          ),
          Expanded(
            child: Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF0F172A) : Colors.white,
                    border: Border(
                      right: BorderSide(
                        color: isDark ? AppColors.darkBorder : const Color(0xFFF1F5F9),
                        width: 1.2,
                      ),
                    ),
                  ),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return SingleChildScrollView(
                        child: ConstrainedBox(
                          constraints: BoxConstraints(minHeight: constraints.maxHeight),
                          child: IntrinsicHeight(
                            child: NavigationRail(
                              selectedIndex: () {
                                final idx = railItems.indexWhere((it) => it.branchIndex == currentIndex);
                                return idx != -1 ? idx : 0;
                              }(),
                              onDestinationSelected: (index) {
                                HapticFeedback.selectionClick();
                                _onItemTapped(railItems[index].branchIndex);
                              },
                              labelType: NavigationRailLabelType.all,
                              backgroundColor: Colors.transparent,
                              selectedIconTheme: const IconThemeData(color: Color(0xFF064E3B)),
                              selectedLabelTextStyle: const TextStyle(
                                color: Color(0xFF064E3B),
                                fontWeight: FontWeight.w800,
                                fontSize: 11,
                              ),
                              unselectedLabelTextStyle: TextStyle(
                                color: isDark ? AppColors.darkTextMuted : const Color(0xFF64748B),
                                fontSize: 10.5,
                                fontWeight: FontWeight.w500,
                              ),
                              destinations: railItems.map((item) {
                                final isItemSel = item.branchIndex == currentIndex;
                                return NavigationRailDestination(
                                  icon: _buildRailIcon(item, false, isDark),
                                  selectedIcon: _buildRailIcon(item, true, isDark),
                                  label: Text(
                                    item.label,
                                    style: TextStyle(
                                      fontWeight: isItemSel ? FontWeight.w800 : FontWeight.w600,
                                      color: isItemSel ? const Color(0xFF064E3B) : (isDark ? AppColors.darkTextMuted : const Color(0xFF64748B)),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const VerticalDivider(thickness: 1, width: 1),
                Expanded(child: widget.navigationShell),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRailIcon(_NavItem item, bool isSelected, bool isDark) {
    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        color: isSelected
            ? const Color(0xFF064E3B)
            : (isDark ? AppColors.darkSurfaceVariant : const Color(0xFFF1F5F9)),
        borderRadius: BorderRadius.circular(12),
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: const Color(0xFF064E3B).withValues(alpha: 0.35),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      alignment: Alignment.center,
      child: Icon(
        isSelected ? item.selectedIcon : item.icon,
        color: isSelected
            ? Colors.white
            : (isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
        size: 20,
      ),
    );
  }

  // ── Floating Action Button for Mobile ────────────────────────────────────
  Widget _buildPunekarBotFab(BuildContext context, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AppColors.saffron.withValues(alpha: 0.45),
            blurRadius: 18,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: AppColors.gold.withValues(alpha: 0.2),
            blurRadius: 28,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: FloatingActionButton(
        onPressed: () => PunekarBotSheet.show(context),
        elevation: 0,
        highlightElevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        shape: const CircleBorder(),
        tooltip: 'Ask PunekarBot AI Assistant',
        child: Ink(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: AppColors.saffronGradient,
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.35),
              width: 1.5,
            ),
          ),
          child: const Center(
            child: Text('🤖', style: TextStyle(fontSize: 25)),
          ),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// 1. TOP DESKTOP HEADER (FULL-WIDTH PIXEL-ACCURATE REDESIGN)
// ══════════════════════════════════════════════════════════════════════════════

class _DesktopHeader extends StatelessWidget {
  final UserProfile? user;
  final bool isDark;
  final double screenWidth;
  final bool isCollapsed;
  final VoidCallback onToggleCollapse;
  final ValueChanged<int> onItemTapped;

  const _DesktopHeader({
    required this.user,
    required this.isDark,
    required this.screenWidth,
    required this.isCollapsed,
    required this.onToggleCollapse,
    required this.onItemTapped,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 66.0,
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : Colors.white,
        border: Border(
          bottom: BorderSide(
            color: isDark ? AppColors.darkBorder : const Color(0xFFE2E8F0),
            width: 1.0,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // ── Brand Area (Left) ──
          InkWell(
            onTap: () => onItemTapped(0),
            borderRadius: BorderRadius.circular(10),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      gradient: AppColors.saffronGradient,
                      borderRadius: BorderRadius.circular(11),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.saffron.withValues(alpha: 0.35),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: const Text('🚩', style: TextStyle(fontSize: 19)),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: 'Pune',
                              style: GoogleFonts.inter(
                                fontSize: 17,
                                fontWeight: FontWeight.w900,
                                color: isDark ? AppColors.darkTextPrimary : const Color(0xFF0F172A),
                                letterSpacing: -0.3,
                              ),
                            ),
                            TextSpan(
                              text: 'Explorer',
                              style: GoogleFonts.inter(
                                fontSize: 17,
                                fontWeight: FontWeight.w900,
                                color: AppColors.saffron,
                                letterSpacing: -0.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        'Travel • Heritage • Culture',
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w600,
                          color: isDark ? AppColors.darkTextMuted : const Color(0xFF64748B),
                          letterSpacing: 0.2,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Sidebar Collapse/Expand Toggle
          const SizedBox(width: 8),
          IconButton(
            onPressed: onToggleCollapse,
            tooltip: isCollapsed ? 'Expand sidebar' : 'Collapse sidebar',
            icon: Icon(
              isCollapsed ? Icons.menu_open_rounded : Icons.menu_rounded,
              size: 20,
              color: isDark ? AppColors.darkTextMuted : const Color(0xFF64748B),
            ),
          ),

          // ── Center: Search Input Container ──
          Expanded(
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: screenWidth < 1200 ? 380 : 500,
                ),
                child: InkWell(
                  onTap: () => OmniSearchDialog.show(context),
                  borderRadius: BorderRadius.circular(22),
                  child: Container(
                    height: 40,
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkSurfaceVariant : const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(
                        color: isDark ? AppColors.darkBorder : const Color(0xFFE2E8F0),
                        width: 1.1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.search_rounded,
                          size: 18,
                          color: isDark ? AppColors.darkTextMuted : const Color(0xFF64748B),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            screenWidth >= 900
                                ? 'Search destinations, forts, temples, food, experiences...'
                                : 'Search destinations, forts...',
                            style: TextStyle(
                              fontSize: 12.5,
                              color: isDark ? AppColors.darkTextMuted : const Color(0xFF94A3B8),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (screenWidth >= 900) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFF0F172A) : Colors.white,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: isDark ? AppColors.darkBorder : const Color(0xFFCBD5E1),
                                width: 1,
                              ),
                            ),
                            child: Text(
                              '⌘ K',
                              style: TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w700,
                                color: isDark ? AppColors.darkTextSecondary : const Color(0xFF64748B),
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
          ),

          // ── Right: Quick Links, Notifications, Profile Dropdown ──
          if (screenWidth >= 1150) ...[
            _HeaderQuickLink(
              icon: Icons.explore_outlined,
              label: 'Explore',
              isDark: isDark,
              onTap: () => onItemTapped(1),
            ),
            _HeaderQuickLink(
              icon: Icons.business_center_outlined,
              label: 'My Trips',
              isDark: isDark,
              onTap: () => context.push('/my-bookings'),
            ),
            _HeaderQuickLink(
              icon: Icons.favorite_border_rounded,
              label: 'Saved',
              isDark: isDark,
              onTap: () => onItemTapped(6),
            ),
            const SizedBox(width: 8),
          ],

          // Notification Bell with Unread Badge
          Stack(
            clipBehavior: Clip.none,
            children: [
              IconButton(
                onPressed: () => _showNotificationsDialog(context, isDark),
                tooltip: 'Notifications',
                icon: Icon(
                  Icons.notifications_none_rounded,
                  size: 21,
                  color: isDark ? AppColors.darkTextPrimary : const Color(0xFF334155),
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.all(3),
                  decoration: const BoxDecoration(
                    color: Color(0xFFEA580C),
                    shape: BoxShape.circle,
                  ),
                  constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                  alignment: Alignment.center,
                  child: const Text(
                    '1',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 9.5,
                      fontWeight: FontWeight.w900,
                      height: 1,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 8),

          // Profile Pill (Tapping navigates to profile, shows name/role on desktop)
          _ProfileDropdownPill(
            user: user,
            isDark: isDark,
            screenWidth: screenWidth,
            onItemTapped: onItemTapped,
          ),
        ],
      ),
    );
  }
}

/// Quick link item in the desktop top header
class _HeaderQuickLink extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isDark;
  final VoidCallback onTap;

  const _HeaderQuickLink({
    required this.icon,
    required this.label,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 3.0),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 16,
                color: isDark ? AppColors.darkTextMuted : const Color(0xFF64748B),
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppColors.darkTextSecondary : const Color(0xFF334155),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Profile Dropdown Pill in the top desktop header
class _ProfileDropdownPill extends StatelessWidget {
  final UserProfile? user;
  final bool isDark;
  final double screenWidth;
  final ValueChanged<int> onItemTapped;

  const _ProfileDropdownPill({
    required this.user,
    required this.isDark,
    required this.screenWidth,
    required this.onItemTapped,
  });

  @override
  Widget build(BuildContext context) {
    final displayName = user?.name.isNotEmpty == true ? user!.name : 'Puneri Explorer';
    final roleText = (user != null && !user!.isGuest)
        ? (user!.isAdmin ? 'Administrator' : 'Explorer • Level 3')
        : 'Guest Explorer';

    return Tooltip(
      message: 'Explorer Profile ($displayName)',
      child: InkWell(
        onTap: () {
          HapticFeedback.selectionClick();
          onItemTapped(6);
        },
        borderRadius: BorderRadius.circular(24),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: screenWidth >= 900 ? 10 : 6,
            vertical: 5,
          ),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurfaceVariant : const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isDark ? AppColors.darkBorder : const Color(0xFFE2E8F0),
              width: 1.1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                children: [
                  CircleAvatar(
                    radius: 15,
                    backgroundColor: AppColors.emerald,
                    child: Text(
                      displayName.isNotEmpty ? displayName[0].toUpperCase() : 'P',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Color(0xFF10B981),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ],
              ),
              if (screenWidth >= 900) ...[
                const SizedBox(width: 8),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 125),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        displayName,
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                          color: isDark ? AppColors.darkTextPrimary : const Color(0xFF0F172A),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        roleText,
                        style: TextStyle(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w500,
                          color: isDark ? AppColors.darkTextMuted : const Color(0xFF64748B),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  Icons.keyboard_arrow_down_rounded,
                  size: 16,
                  color: isDark ? AppColors.darkTextMuted : const Color(0xFF64748B),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// 2. LEFT DESKTOP NAVIGATION SIDEBAR (MATCHES REFERENCE DESIGN)
// ══════════════════════════════════════════════════════════════════════════════

class _DesktopNavigationSidebar extends StatelessWidget {
  final List<_NavItem> navItems;
  final int currentIndex;
  final UserProfile? user;
  final int bookingsCount;
  final bool isDark;
  final bool isLaptop;
  final ValueChanged<int> onItemTapped;

  const _DesktopNavigationSidebar({
    required this.navItems,
    required this.currentIndex,
    required this.user,
    required this.bookingsCount,
    required this.isDark,
    required this.isLaptop,
    required this.onItemTapped,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(
        horizontal: isLaptop ? 10.0 : 12.0,
        vertical: 14.0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Title
          Padding(
            padding: const EdgeInsets.only(left: 8.0, bottom: 8.0, top: 2.0),
            child: Text(
              'EXPLORE PUNE',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.1,
                color: isDark ? AppColors.darkTextMuted : const Color(0xFF64748B),
              ),
            ),
          ),

          // The 7 Navigation Items
          ...navItems.map((item) {
            final isSelected = item.branchIndex == currentIndex;
            return Padding(
              padding: const EdgeInsets.only(bottom: 4.0),
              child: _SidebarItemTile(
                item: item,
                isSelected: isSelected,
                isDark: isDark,
                isLaptop: isLaptop,
                onTap: () {
                  HapticFeedback.selectionClick();
                  onItemTapped(item.branchIndex);
                },
              ),
            );
          }),
          const SizedBox(height: 18),

          // PunekarBot AI Card
          _SidebarPunekarBotCard(isDark: isDark, isLaptop: isLaptop),
          const SizedBox(height: 14),

          // Bottom Promo Card ("Preserve Explore Belong")
          _SidebarPromoCard(
            isDark: isDark,
            onTap: () => onItemTapped(4), // Heritage Walks
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

/// Navigation item tile in desktop sidebar with dark forest green active pill
class _SidebarItemTile extends StatefulWidget {
  final _NavItem item;
  final bool isSelected;
  final bool isDark;
  final bool isLaptop;
  final VoidCallback onTap;

  const _SidebarItemTile({
    required this.item,
    required this.isSelected,
    required this.isDark,
    required this.isLaptop,
    required this.onTap,
  });

  @override
  State<_SidebarItemTile> createState() => _SidebarItemTileState();
}

class _SidebarItemTileState extends State<_SidebarItemTile> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final title = widget.isLaptop ? widget.item.label : (widget.item.displayTitle ?? widget.item.label);

    return Semantics(
      label: '$title navigation',
      value: widget.item.subtitle,
      selected: widget.isSelected,
      button: true,
      child: Tooltip(
        message: '$title: ${widget.item.subtitle}',
        waitDuration: const Duration(milliseconds: 500),
        child: MouseRegion(
          onEnter: (_) => setState(() => _isHovered = true),
          onExit: (_) => setState(() => _isHovered = false),
          child: InkWell(
            onTap: widget.onTap,
            borderRadius: BorderRadius.circular(12),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOutCubic,
              height: widget.isLaptop ? 42 : 44,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: widget.isSelected
                    ? const Color(0xFF064E3B) // Dark forest green active state
                    : (_isHovered
                        ? (widget.isDark ? AppColors.darkSurfaceVariant : const Color(0xFFF1F5F9))
                        : Colors.transparent),
                borderRadius: BorderRadius.circular(12),
                boxShadow: widget.isSelected
                    ? [
                        BoxShadow(
                          color: const Color(0xFF064E3B).withValues(alpha: 0.35),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              child: Row(
                children: [
                  Icon(
                    widget.isSelected ? widget.item.selectedIcon : widget.item.icon,
                    size: 19,
                    color: widget.isSelected
                        ? Colors.white
                        : (widget.isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      title,
                      style: GoogleFonts.inter(
                        fontSize: widget.isLaptop ? 13 : 13.5,
                        fontWeight: widget.isSelected ? FontWeight.w700 : FontWeight.w500,
                        color: widget.isSelected
                            ? Colors.white
                            : (widget.isDark ? const Color(0xFFCBD5E1) : const Color(0xFF334155)),
                        letterSpacing: -0.2,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (widget.item.badgeCount != null && widget.item.badgeCount! > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      margin: const EdgeInsets.only(right: 6),
                      decoration: BoxDecoration(
                        gradient: AppColors.saffronGradient,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${widget.item.badgeCount}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9.5,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  if (widget.isSelected)
                    Icon(
                      Icons.chevron_right_rounded,
                      size: 18,
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// PunekarBot AI Card in desktop sidebar
class _SidebarPunekarBotCard extends StatelessWidget {
  final bool isDark;
  final bool isLaptop;

  const _SidebarPunekarBotCard({
    required this.isDark,
    required this.isLaptop,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(isLaptop ? 11 : 13),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurfaceVariant : const Color(0xFFF9FDF9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : const Color(0xFFE2E8F0),
          width: 1.1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF064E3B).withValues(alpha: 0.4) : const Color(0xFFDCFCE7),
                  borderRadius: BorderRadius.circular(9),
                ),
                alignment: Alignment.center,
                child: const Text('🤖', style: TextStyle(fontSize: 16)),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'PunekarBot AI',
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                    color: isDark ? AppColors.darkTextPrimary : const Color(0xFF0F172A),
                  ),
                ),
              ),
              const Icon(Icons.chevron_right_rounded, size: 16, color: Color(0xFF94A3B8)),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Ask. Plan. Explore. Discover Pune your way.',
            style: TextStyle(
              fontSize: 10.5,
              height: 1.35,
              color: isDark ? AppColors.darkTextMuted : const Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            height: 34,
            child: ElevatedButton(
              onPressed: () => PunekarBotSheet.show(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF064E3B),
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.chat_bubble_outline_rounded, size: 13, color: Colors.white),
                  SizedBox(width: 6),
                  Text(
                    'Chat with AI',
                    style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Bottom Promo Card ("Preserve Explore Belong") in desktop sidebar
class _SidebarPromoCard extends StatelessWidget {
  final bool isDark;
  final VoidCallback onTap;

  const _SidebarPromoCard({
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFF1E293B), const Color(0xFF0F172A)]
              : [const Color(0xFFE2EBE0), const Color(0xFFEAF2E7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : const Color(0xFFCBD5E1),
          width: 1.0,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Preserve',
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    fontStyle: FontStyle.italic,
                    color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF475569),
                  ),
                ),
                Text(
                  'Explore',
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w900,
                    fontStyle: FontStyle.italic,
                    color: isDark ? const Color(0xFFF97316) : const Color(0xFFEA580C),
                  ),
                ),
                Text(
                  'Belong',
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    fontStyle: FontStyle.italic,
                    color: isDark ? const Color(0xFF34D399) : const Color(0xFF064E3B),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'Pune Heritage Trails',
                  style: TextStyle(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w600,
                    color: isDark ? const Color(0xFF64748B) : const Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
          InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(16),
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isDark ? AppColors.darkSurfaceVariant : Colors.white,
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 4,
                    offset: Offset(0, 1),
                  ),
                ],
              ),
              child: Icon(
                Icons.arrow_forward_rounded,
                size: 16,
                color: isDark ? Colors.white : const Color(0xFF0F172A),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// 3. COLLAPSED SIDEBAR RAIL (76px width for tablet & collapsed desktop)
// ══════════════════════════════════════════════════════════════════════════════

class _CollapsedSidebarRail extends StatelessWidget {
  final List<_NavItem> navItems;
  final int currentIndex;
  final UserProfile? user;
  final bool isDark;
  final VoidCallback onToggleExpand;
  final ValueChanged<int> onItemTapped;

  const _CollapsedSidebarRail({
    required this.navItems,
    required this.currentIndex,
    required this.user,
    required this.isDark,
    required this.onToggleExpand,
    required this.onItemTapped,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 12),
        // Header Logo + Expand Toggle
        IconButton(
          onPressed: onToggleExpand,
          icon: Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              gradient: AppColors.saffronGradient,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: AppColors.saffron.withValues(alpha: 0.3),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            alignment: Alignment.center,
            child: const Text('🚩', style: TextStyle(fontSize: 18)),
          ),
          tooltip: 'Expand navigation sidebar',
        ),
        const SizedBox(height: 8),

        // Quick Search Icon
        IconButton(
          onPressed: () => OmniSearchDialog.show(context),
          icon: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurfaceVariant : const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: isDark ? AppColors.darkBorder : const Color(0xFFE2E8F0)),
            ),
            alignment: Alignment.center,
            child: const Icon(Icons.search_rounded, size: 18, color: Color(0xFF064E3B)),
          ),
          tooltip: 'Quick Search (⌘K)',
        ),
        const SizedBox(height: 6),

        // Profile Avatar Icon
        InkWell(
          onTap: () => onItemTapped(6),
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: AppColors.emerald,
                child: Text(
                  user?.name.isNotEmpty == true ? user!.name[0].toUpperCase() : 'P',
                  style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w800),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Color(0xFF10B981),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        const Divider(height: 1, indent: 14, endIndent: 14),

        // Scrollable Icons
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: navItems.length,
            itemBuilder: (context, index) {
              final item = navItems[index];
              final isSelected = item.branchIndex == currentIndex;

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Tooltip(
                  message: '${item.displayTitle ?? item.label}\n${item.subtitle}',
                  child: InkWell(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      onItemTapped(item.branchIndex);
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Center(
                      child: Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFF064E3B)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: const Color(0xFF064E3B).withValues(alpha: 0.35),
                                    blurRadius: 6,
                                    offset: const Offset(0, 2),
                                  ),
                                ]
                              : null,
                        ),
                        alignment: Alignment.center,
                        child: Icon(
                          isSelected ? item.selectedIcon : item.icon,
                          color: isSelected
                              ? Colors.white
                              : (isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),

        // Trailing PunekarBot AI Button
        Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: IconButton(
            onPressed: () => PunekarBotSheet.show(context),
            icon: const Text('🤖', style: TextStyle(fontSize: 22)),
            tooltip: 'PunekarBot AI',
          ),
        ),
      ],
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// 4. MOBILE SLIDE-IN NAVIGATION DRAWER
// ══════════════════════════════════════════════════════════════════════════════

class _MobileNavDrawer extends StatelessWidget {
  final List<_NavItem> navItems;
  final int currentIndex;
  final UserProfile? user;
  final int bookingsCount;
  final bool isDark;
  final ValueChanged<int> onItemTapped;

  const _MobileNavDrawer({
    required this.navItems,
    required this.currentIndex,
    required this.user,
    required this.bookingsCount,
    required this.isDark,
    required this.onItemTapped,
  });

  @override
  Widget build(BuildContext context) {
    final displayName = user?.name.isNotEmpty == true ? user!.name : 'Puneri Explorer';
    final statusText = (user != null && !user!.isGuest) ? user!.email : 'Guest Explorer';
    final tripsCount = bookingsCount > 0 ? bookingsCount : 12;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    gradient: AppColors.saffronGradient,
                    borderRadius: BorderRadius.circular(11),
                  ),
                  alignment: Alignment.center,
                  child: const Text('🚩', style: TextStyle(fontSize: 18)),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: 'Pune',
                              style: GoogleFonts.inter(
                                fontSize: 16.5,
                                fontWeight: FontWeight.w900,
                                color: isDark ? AppColors.darkTextPrimary : const Color(0xFF0F172A),
                              ),
                            ),
                            TextSpan(
                              text: 'Explorer',
                              style: GoogleFonts.inter(
                                fontSize: 16.5,
                                fontWeight: FontWeight.w900,
                                color: AppColors.saffron,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Text(
                        'Travel • Heritage • Culture',
                        style: TextStyle(
                          color: AppColors.saffron,
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close_rounded, size: 20),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Profile Card with Stats
            InkWell(
              onTap: () => onItemTapped(6),
              borderRadius: BorderRadius.circular(14),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkSurfaceVariant : const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isDark ? AppColors.darkBorder : const Color(0xFFE2E8F0),
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Stack(
                          children: [
                            CircleAvatar(
                              radius: 17,
                              backgroundColor: AppColors.emerald,
                              child: Text(
                                displayName.isNotEmpty ? displayName[0].toUpperCase() : 'P',
                                style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w900),
                              ),
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  color: Color(0xFF10B981),
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                displayName,
                                style: GoogleFonts.inter(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 13,
                                  color: isDark ? AppColors.darkTextPrimary : const Color(0xFF0F172A),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                statusText,
                                style: TextStyle(
                                  fontSize: 10.5,
                                  color: isDark ? AppColors.darkTextMuted : const Color(0xFF64748B),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.chevron_right_rounded, size: 18, color: Color(0xFF94A3B8)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Divider(height: 1),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStatColumn('$tripsCount', 'Trips', isDark),
                        _buildStatColumn('28', 'Places', isDark),
                        _buildStatColumn('7', 'Badges', isDark),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),

            // Section Label
            Padding(
              padding: const EdgeInsets.only(left: 4.0, bottom: 6.0),
              child: Text(
                'DESTINATIONS & TRAILS',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.1,
                  color: isDark ? AppColors.darkTextMuted : const Color(0xFF64748B),
                ),
              ),
            ),

            // Navigation Items
            ...navItems.map((item) {
              final isSelected = item.branchIndex == currentIndex;
              return Padding(
                padding: const EdgeInsets.only(bottom: 4.0),
                child: _SidebarItemTile(
                  item: item,
                  isSelected: isSelected,
                  isDark: isDark,
                  isLaptop: true,
                  onTap: () => onItemTapped(item.branchIndex),
                ),
              );
            }),
            const SizedBox(height: 14),

            // PunekarBot Card
            _SidebarPunekarBotCard(isDark: isDark, isLaptop: true),
            const SizedBox(height: 14),

            // Bottom Promo Card
            _SidebarPromoCard(
              isDark: isDark,
              onTap: () => onItemTapped(4),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildStatColumn(String count, String label, bool isDark) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          count,
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 11.5,
            color: isDark ? AppColors.darkTextPrimary : const Color(0xFF0F172A),
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 9.5,
            fontWeight: FontWeight.w500,
            color: isDark ? AppColors.darkTextMuted : const Color(0xFF64748B),
          ),
        ),
      ],
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// 5. MOBILE LUXURY BOTTOM NAVIGATION BAR
// ══════════════════════════════════════════════════════════════════════════════

class _PremiumModernBottomBar extends StatelessWidget {
  final List<_NavItem> items;
  final int currentIndex;
  final bool isDark;
  final ValueChanged<int> onTap;

  const _PremiumModernBottomBar({
    required this.items,
    required this.currentIndex,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isSmallPhone = screenWidth < 360;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
        border: Border(
          top: BorderSide(
            color: isDark ? AppColors.darkBorder : const Color(0xFFE2E8F0),
            width: 1.0,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.06),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: isSmallPhone ? 4 : 8,
            vertical: isSmallPhone ? 4 : 6,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(items.length, (index) {
              final item = items[index];
              final isSelected = index == currentIndex;

              return Expanded(
                child: _BottomNavTabItem(
                  item: item,
                  isSelected: isSelected,
                  isDark: isDark,
                  isSmallPhone: isSmallPhone,
                  onTap: () => onTap(index),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _BottomNavTabItem extends StatelessWidget {
  final _NavItem item;
  final bool isSelected;
  final bool isDark;
  final bool isSmallPhone;
  final VoidCallback onTap;

  const _BottomNavTabItem({
    required this.item,
    required this.isSelected,
    required this.isDark,
    required this.isSmallPhone,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: EdgeInsets.symmetric(
          vertical: isSmallPhone ? 4 : 6,
          horizontal: 2,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeOutCubic,
                  padding: EdgeInsets.symmetric(
                    horizontal: isSelected ? (isSmallPhone ? 10 : 14) : 8,
                    vertical: isSmallPhone ? 4 : 5,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFF064E3B)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    isSelected ? item.selectedIcon : item.icon,
                    color: isSelected
                        ? Colors.white
                        : (isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
                    size: isSmallPhone ? 20 : 22,
                  ),
                ),
                if (item.badgeCount != null && item.badgeCount! > 0)
                  Positioned(
                    top: -2,
                    right: isSelected ? 2 : -2,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                      decoration: BoxDecoration(
                        gradient: AppColors.saffronGradient,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      constraints: const BoxConstraints(minWidth: 15, minHeight: 15),
                      alignment: Alignment.center,
                      child: Text(
                        '${item.badgeCount}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.w900,
                          height: 1,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 3),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                item.label,
                style: TextStyle(
                  fontSize: isSmallPhone ? 10 : 11,
                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                  color: isSelected
                      ? (isDark ? Colors.white : const Color(0xFF064E3B))
                      : (isDark ? AppColors.darkTextMuted : const Color(0xFF64748B)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// 6. NOTIFICATION DIALOG HELPER
// ══════════════════════════════════════════════════════════════════════════════

void _showNotificationsDialog(BuildContext context, bool isDark) {
  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      titlePadding: const EdgeInsets.fromLTRB(20, 18, 12, 10),
      contentPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: const Color(0xFFEA580C).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(9),
            ),
            child: const Icon(Icons.notifications_active_rounded, color: Color(0xFFEA580C), size: 18),
          ),
          const SizedBox(width: 10),
          const Text('Notifications', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
          const Spacer(),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Dismiss', style: TextStyle(fontSize: 12)),
          ),
        ],
      ),
      content: SizedBox(
        width: 360,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildNotificationRow(
              title: 'Kasba Peth Heritage Walk Scheduled',
              subtitle: 'Starts tomorrow at 7:00 AM from Shaniwar Wada Delhi Gate.',
              time: '1h ago',
              isDark: isDark,
              icon: Icons.hiking_rounded,
              color: const Color(0xFF059669),
            ),
            const Divider(height: 16),
            _buildNotificationRow(
              title: 'Pune Darshan AC Bus Pass Active',
              subtitle: 'Booking #PD-8492 confirmed. Boarding at Swargate station.',
              time: '3h ago',
              isDark: isDark,
              icon: Icons.directions_bus_rounded,
              color: const Color(0xFFEA580C),
            ),
            const Divider(height: 16),
            _buildNotificationRow(
              title: 'Monsoon Trek Weather Advisory',
              subtitle: 'Sinhagad Fort trails are currently clear with light mist.',
              time: '1d ago',
              isDark: isDark,
              icon: Icons.cloud_queue_rounded,
              color: const Color(0xFF0284C7),
            ),
          ],
        ),
      ),
    ),
  );
}

Widget _buildNotificationRow({
  required String title,
  required String subtitle,
  required String time,
  required bool isDark,
  required IconData icon,
  required Color color,
}) {
  return Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(8),
        ),
        alignment: Alignment.center,
        child: Icon(icon, color: color, size: 17),
      ),
      const SizedBox(width: 10),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 12.5,
                color: isDark ? AppColors.darkTextPrimary : const Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 11,
                color: isDark ? AppColors.darkTextMuted : const Color(0xFF64748B),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              time,
              style: TextStyle(
                fontSize: 9.5,
                fontWeight: FontWeight.w600,
                color: isDark ? AppColors.darkTextMuted : const Color(0xFF94A3B8),
              ),
            ),
          ],
        ),
      ),
    ],
  );
}

// ══════════════════════════════════════════════════════════════════════════════
// DATA MODEL
// ══════════════════════════════════════════════════════════════════════════════

class _NavItem {
  final String label;
  final String? displayTitle;
  final String subtitle;
  final IconData icon;
  final IconData selectedIcon;
  final int? badgeCount;
  final Color primaryColor;
  final Color secondaryColor;
  final List<Color> gradientColors;
  final int branchIndex;

  const _NavItem({
    required this.label,
    this.displayTitle,
    required this.subtitle,
    required this.icon,
    required this.selectedIcon,
    this.badgeCount,
    required this.primaryColor,
    required this.secondaryColor,
    required this.gradientColors,
    required this.branchIndex,
  });
}
