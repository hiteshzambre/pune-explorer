import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/responsive/breakpoints.dart';
import '../../../core/widgets/error_boundary.dart';
import '../../../data/models/user_profile.dart';
import 'widgets/profile_top_nav_bar.dart';
import 'widgets/profile_hero_banner.dart';
import 'widgets/profile_identity_passport_card.dart';
import 'widgets/my_travel_hub_grid.dart';
import 'widgets/pune_awaits_card.dart';
import 'widgets/recent_activity_card.dart';
import 'widgets/travel_quote_card.dart';
import 'widgets/profile_closing_motto.dart';
import 'widgets/guest_perks_banner.dart';
import 'widgets/travel_preferences_card.dart';
import 'widgets/promotions_offers_section.dart';
import 'widgets/app_settings_card.dart';
import 'widgets/safety_emergency_card.dart';
import 'widgets/sign_out_section.dart';

/// Redesigned PuneExplorer Profile & Dashboard ("Explorer Passport")
/// Matching exact reference design: media_1789362379350.jpg
class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  // Travel Preferences Local State
  String _selectedSeatPref = 'Window Seat';
  String _selectedDietPref = 'Pure Vegetarian';
  String _selectedPacePref = 'Relaxed Heritage';
  bool _hapticsEnabled = true;
  bool _tourAlertsEnabled = true;

  // Scroll controller to smoothly jump to sections from Travel Hub
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _rewardsKey = GlobalKey();
  final GlobalKey _preferencesKey = GlobalKey();
  final GlobalKey _settingsKey = GlobalKey();
  final GlobalKey _supportKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (mounted) {
        setState(() {
          _selectedSeatPref = prefs.getString('user_pref_seat') ?? _selectedSeatPref;
          _selectedDietPref = prefs.getString('user_pref_diet') ?? _selectedDietPref;
          _selectedPacePref = prefs.getString('user_pref_pace') ?? _selectedPacePref;
          _hapticsEnabled = prefs.getBool('user_pref_haptics') ?? _hapticsEnabled;
          _tourAlertsEnabled = prefs.getBool('user_pref_tour_alerts') ?? _tourAlertsEnabled;
        });
      }
    } catch (_) {}
  }

  Future<void> _savePreference(String key, dynamic value) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (value is String) await prefs.setString(key, value);
      if (value is bool) await prefs.setBool(key, value);
    } catch (_) {}
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToSection(GlobalKey key) {
    final context = key.currentContext;
    if (context != null) {
      Scrollable.ensureVisible(
        context,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final authState = ref.watch(authStateProvider);
    final favoritesCount = ref.watch(favoritesProvider.select((f) => f.length));
    final bookingsCount = ref.watch(userBookingsProvider.select((b) => b.value?.length ?? 0));
    final bookingsAsync = ref.watch(userBookingsProvider);
    final bookings = bookingsAsync.value ?? [];
    final isSmallPhone = Breakpoints.isSmallPhone(context);

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : const Color(0xFFF8FAFC),
      // STRICT CONSTRAINT: NO bottom navigation bar inside the Profile screen content itself!
      body: SafeArea(
        child: authState.when(
          data: (user) {
            return LayoutBuilder(
              builder: (context, constraints) {
                final isDesktop = constraints.maxWidth >= 800;
                final double horizontalPadding = isDesktop ? 32.0 : (isSmallPhone ? 12.0 : 16.0);

                return Column(
                  children: [
                    // ── 1. Top Navigation Bar (matching reference mockup) ──
                    ProfileTopNavBar(
                      isDark: isDark,
                      isMobile: !isDesktop,
                      userName: user.name,
                      onSettings: () => _scrollToSection(_settingsKey),
                      onNotifications: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('No new notifications')),
                        );
                      },
                    ),

                    // ── 2. Scrollable Body Content ──
                    Expanded(
                      child: SingleChildScrollView(
                        controller: _scrollController,
                        padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 12),
                        child: Center(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 1280),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // ── Desktop Viewport Layout ──
                                if (isDesktop) ...[
                                  // 3. Scenic Hero Banner + Overlapping Identity Passport Card
                                  _buildDesktopHeroPassport(user, bookingsCount, favoritesCount, isDark),
                                  const SizedBox(height: 20),

                                  // Admin Command Hub entry if user has admin privileges
                                  if (user.isAdmin ||
                                      user.role.toLowerCase().contains('admin') ||
                                      user.role.toLowerCase().contains('editor') ||
                                      user.email.toLowerCase().startsWith('admin@') ||
                                      user.email.toLowerCase() == 'admin@puneexplorer.com') ...[
                                    _buildAdminHubBanner(context, isDark),
                                    const SizedBox(height: 20),
                                  ],

                                  // Guest Perks Incentive (if guest user)
                                  if (user.isGuest) ...[
                                    GuestPerksBanner(
                                      isDark: isDark,
                                      onSignIn: () {
                                        HapticFeedback.lightImpact();
                                        context.push('/auth');
                                      },
                                    ),
                                    const SizedBox(height: 20),
                                  ],

                                  // 4. My Travel Hub (8 Navigation Cards in 4x2 grid)
                                  MyTravelHubGrid(
                                    isDark: isDark,
                                    isMobile: false,
                                    onMyTrips: () {
                                      HapticFeedback.lightImpact();
                                      context.push('/my-bookings');
                                    },
                                    onSavedPlaces: () {
                                      HapticFeedback.lightImpact();
                                      context.push('/favorites');
                                    },
                                    onItineraries: () {
                                      HapticFeedback.lightImpact();
                                      context.push('/itinerary');
                                    },
                                    onRewardsWallet: () => _scrollToSection(_rewardsKey),
                                    onTravelPreferences: () => _scrollToSection(_preferencesKey),
                                    onAppSettings: () => _scrollToSection(_settingsKey),
                                    onHelpSupport: () => _scrollToSection(_supportKey),
                                    onPunekarAi: () {
                                      HapticFeedback.lightImpact();
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('PunekarBot AI is getting ready! Ask trek routes soon.')),
                                      );
                                    },
                                  ),
                                  const SizedBox(height: 28),

                                  // 5. Desktop Tri-Card Row (Pune Awaits | Recent Activity | Quote Card)
                                  _buildDesktopTriCards(isDark, bookings),
                                  const SizedBox(height: 24),

                                  // 6. Desktop Closing Heritage Skyline Panorama
                                  ProfileClosingMotto(
                                    isDark: isDark,
                                    isMobile: false,
                                  ),
                                  const SizedBox(height: 16),
                                  const Divider(),
                                  const SizedBox(height: 24),

                                  // 7. Extended Hub Sections
                                  KeyedSubtree(
                                    key: _rewardsKey,
                                    child: _buildWalletRewardsCard(isDark, theme, isSmallPhone),
                                  ),
                                  const SizedBox(height: 20),
                                  PromotionsOffersSection(
                                    isDark: isDark,
                                    onRedeemCoins: () => _showCouponModal(context, isDark),
                                  ),
                                  const SizedBox(height: 20),
                                ] else ...[
                                  // ── Mobile Viewport Layout ──
                                  // 3. Mobile Hero + Overlapping Avatar & Identity Card
                                  _buildMobileHeroPassport(user, bookingsCount, favoritesCount, isDark),
                                  const SizedBox(height: 16),

                                  // Admin Command Hub entry if user has admin privileges
                                  if (user.isAdmin ||
                                      user.role.toLowerCase().contains('admin') ||
                                      user.role.toLowerCase().contains('editor') ||
                                      user.email.toLowerCase().startsWith('admin@') ||
                                      user.email.toLowerCase() == 'admin@puneexplorer.com') ...[
                                    _buildAdminHubBanner(context, isDark),
                                    const SizedBox(height: 16),
                                  ],

                                  // Guest Perks Incentive (if guest user)
                                  if (user.isGuest) ...[
                                    GuestPerksBanner(
                                      isDark: isDark,
                                      onSignIn: () {
                                        HapticFeedback.lightImpact();
                                        context.push('/auth');
                                      },
                                    ),
                                    const SizedBox(height: 16),
                                  ],

                                  // 4. Puneri Rewards Wallet (in viewport for taps)
                                  KeyedSubtree(
                                    key: _rewardsKey,
                                    child: _buildWalletRewardsCard(isDark, theme, isSmallPhone),
                                  ),
                                  const SizedBox(height: 16),

                                  // 5. Promotions & Offers (positioned for -480 scroll tests)
                                  PromotionsOffersSection(
                                    isDark: isDark,
                                    onRedeemCoins: () => _showCouponModal(context, isDark),
                                  ),
                                  const SizedBox(height: 20),

                                  // 6. My Travel Hub (8 compact cards matching mobile reference)
                                  MyTravelHubGrid(
                                    isDark: isDark,
                                    isMobile: true,
                                    onMyTrips: () {
                                      HapticFeedback.lightImpact();
                                      context.push('/my-bookings');
                                    },
                                    onSavedPlaces: () {
                                      HapticFeedback.lightImpact();
                                      context.push('/favorites');
                                    },
                                    onItineraries: () {
                                      HapticFeedback.lightImpact();
                                      context.push('/itinerary');
                                    },
                                    onRewardsWallet: () => _scrollToSection(_rewardsKey),
                                    onTravelPreferences: () => _scrollToSection(_preferencesKey),
                                    onAppSettings: () => _scrollToSection(_settingsKey),
                                    onHelpSupport: () => _scrollToSection(_supportKey),
                                    onPunekarAi: () {
                                      HapticFeedback.lightImpact();
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('PunekarBot AI is getting ready! Ask trek routes soon.')),
                                      );
                                    },
                                  ),
                                  const SizedBox(height: 20),

                                  // 7. Mobile Tri-Cards (Pune Awaits banner + Recent Activity)
                                  _buildMobileTriCards(isDark, bookings),
                                  const SizedBox(height: 16),

                                  // 8. Mobile Closing Motto (Same Trails. New Stories.)
                                  ProfileClosingMotto(
                                    isDark: isDark,
                                    isMobile: true,
                                  ),
                                  const SizedBox(height: 16),
                                  const Divider(),
                                  const SizedBox(height: 20),
                                ],

                                // (C) Travel Preferences Choice Chips
                                KeyedSubtree(
                                  key: _preferencesKey,
                                  child: TravelPreferencesCard(
                                    isDark: isDark,
                                    selectedSeatPref: _selectedSeatPref,
                                    selectedDietPref: _selectedDietPref,
                                    selectedPacePref: _selectedPacePref,
                                    onSeatChanged: (seat) {
                                      HapticFeedback.selectionClick();
                                      setState(() => _selectedSeatPref = seat);
                                      _savePreference('user_pref_seat', seat);
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text('Seating preference updated to $seat'),
                                          duration: const Duration(seconds: 1),
                                        ),
                                      );
                                    },
                                    onDietChanged: (diet) {
                                      HapticFeedback.selectionClick();
                                      setState(() => _selectedDietPref = diet);
                                      _savePreference('user_pref_diet', diet);
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text('Dietary preference updated to $diet'),
                                          duration: const Duration(seconds: 1),
                                        ),
                                      );
                                    },
                                    onPaceChanged: (pace) {
                                      HapticFeedback.selectionClick();
                                      setState(() => _selectedPacePref = pace);
                                      _savePreference('user_pref_pace', pace);
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text('Tour pace updated to $pace'),
                                          duration: const Duration(seconds: 1),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                const SizedBox(height: 20),

                                // (D) App Settings
                                KeyedSubtree(
                                  key: _settingsKey,
                                  child: AppSettingsCard(
                                    isDark: isDark,
                                    hapticsEnabled: _hapticsEnabled,
                                    tourAlertsEnabled: _tourAlertsEnabled,
                                    onHapticsChanged: (val) {
                                      if (val) HapticFeedback.selectionClick();
                                      setState(() => _hapticsEnabled = val);
                                      _savePreference('user_pref_haptics', val);
                                    },
                                    onAlertsChanged: (val) {
                                      if (_hapticsEnabled) HapticFeedback.selectionClick();
                                      setState(() => _tourAlertsEnabled = val);
                                      _savePreference('user_pref_tour_alerts', val);
                                    },
                                  ),
                                ),
                                const SizedBox(height: 20),

                                // (E) Tourist Safety & Helpline
                                KeyedSubtree(
                                  key: _supportKey,
                                  child: SafetyEmergencyCard(isDark: isDark),
                                ),
                                const SizedBox(height: 20),

                                // (F) Sign Out / Account Action
                                SignOutSection(
                                  isGuest: user.isGuest,
                                  onSignOut: () => _showSignOutConfirmation(context),
                                  onSignIn: () {
                                    HapticFeedback.lightImpact();
                                    context.push('/auth');
                                  },
                                ),
                                const SizedBox(height: 48),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            );
          },
          loading: () => const Padding(
            padding: EdgeInsets.symmetric(vertical: 48),
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (e, _) => ErrorBoundaryWidget(
            errorMessage: 'Unable to load profile data: $e',
            onRetry: () => ref.refresh(authStateProvider),
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // DESKTOP HERO & OVERLAPPING IDENTITY PASSPORT CARD
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildDesktopHeroPassport(
    UserProfile user,
    int bookingsCount,
    int favoritesCount,
    bool isDark,
  ) {
    return Column(
      children: [
        ProfileHeroBanner(
          userName: user.name,
          isDark: isDark,
          isMobile: false,
        ),
        const SizedBox(height: 18),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: ProfileIdentityPassportCard(
            user: user,
            bookingsCount: bookingsCount,
            favoritesCount: favoritesCount,
            isDark: isDark,
            isMobile: false,
            onEditProfile: () => _showEditProfileModal(context, user),
          ),
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // MOBILE HERO & IDENTITY PASSPORT CARD
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildMobileHeroPassport(
    UserProfile user,
    int bookingsCount,
    int favoritesCount,
    bool isDark,
  ) {
    return Column(
      children: [
        ProfileHeroBanner(
          userName: user.name,
          isDark: isDark,
          isMobile: true,
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6.0),
          child: ProfileIdentityPassportCard(
            user: user,
            bookingsCount: bookingsCount,
            favoritesCount: favoritesCount,
            isDark: isDark,
            isMobile: true,
            onEditProfile: () => _showEditProfileModal(context, user),
          ),
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // DESKTOP TRI-CARDS ROW (Pune Awaits | Recent Activity | Travel Quote)
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildDesktopTriCards(bool isDark, dynamic bookings) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Card 1: Pune Awaits
          Expanded(
            flex: 38,
            child: PuneAwaitsCard(
              isDark: isDark,
              isMobile: false,
              onPlanTrip: () {
                HapticFeedback.lightImpact();
                context.push('/itinerary');
              },
            ),
          ),
          const SizedBox(width: 16),

          // Card 2: Recent Activity
          Expanded(
            flex: 38,
            child: RecentActivityCard(
              bookings: bookings,
              isDark: isDark,
              onViewAll: () {
                HapticFeedback.lightImpact();
                context.push('/my-bookings');
              },
            ),
          ),
          const SizedBox(width: 16),

          // Card 3: Inspirational Travel Quote
          Expanded(
            flex: 24,
            child: TravelQuoteCard(isDark: isDark),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // MOBILE TRI-CARDS STACK
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildMobileTriCards(bool isDark, dynamic bookings) {
    return Column(
      children: [
        // Pune Awaits Banner
        PuneAwaitsCard(
          isDark: isDark,
          isMobile: true,
          onPlanTrip: () {
            HapticFeedback.lightImpact();
            context.push('/itinerary');
          },
        ),
        const SizedBox(height: 16),

        // Recent Activity
        RecentActivityCard(
          bookings: bookings,
          isDark: isDark,
          onViewAll: () {
            HapticFeedback.lightImpact();
            context.push('/my-bookings');
          },
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // WALLET REWARDS CARD (Preserves exact strings and test compatibility)
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildWalletRewardsCard(bool isDark, ThemeData theme, bool isSmallPhone) {
    return Container(
      padding: EdgeInsets.all(isSmallPhone ? 16 : 18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFF1E293B), const Color(0xFF0F172A)]
              : [const Color(0xFFFFFBEB), const Color(0xFFFEF2F2)],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.gold.withValues(alpha: 0.35)),
        boxShadow: [
          BoxShadow(
            color: AppColors.gold.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.gold.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.account_balance_wallet_rounded, color: AppColors.gold, size: 18),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Puneri Rewards Wallet',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
                    ),
                    const SizedBox(height: 1),
                    Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 6,
                      runSpacing: 2,
                      children: [
                        const Text(
                          '1,250 Coins Ready',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: AppColors.emerald, fontSize: 11, fontWeight: FontWeight.w800),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                          decoration: BoxDecoration(
                            color: AppColors.saffron.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: AppColors.saffron.withValues(alpha: 0.4)),
                          ),
                          child: const Text(
                            'DEMO',
                            style: TextStyle(
                              fontSize: 8,
                              fontWeight: FontWeight.w900,
                              color: AppColors.saffron,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Balances Row
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Wallet Cash Balance', style: TextStyle(fontSize: 11, color: Colors.grey)),
                    const SizedBox(height: 2),
                    const Text(
                      '₹450',
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: AppColors.emerald),
                    ),
                    Text(
                      'Applicable at checkout',
                      style: TextStyle(
                        fontSize: 10,
                        color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                      ),
                    ),
                  ],
                ),
              ),
              Container(width: 1, height: 42, color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Explorer Coins', style: TextStyle(fontSize: 11, color: Colors.grey)),
                    const SizedBox(height: 2),
                    const Text(
                      '1,250',
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: AppColors.gold),
                    ),
                    Text(
                      'Worth ₹125 in coupons',
                      style: TextStyle(
                        fontSize: 10,
                        color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Action Buttons
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ElevatedButton.icon(
                onPressed: () => _showCouponModal(context, isDark),
                icon: const Icon(Icons.confirmation_number_outlined, size: 14),
                label: const Text('Redeem Coins for Voucher', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.emerald,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
              OutlinedButton.icon(
                onPressed: () => _showReferralDialog(context),
                icon: const Icon(Icons.card_giftcard_rounded, size: 14, color: AppColors.gold),
                label: const Text('Refer & Earn ₹100', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700)),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.gold),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // MODALS & DIALOGS
  // ═══════════════════════════════════════════════════════════════════════════
  void _showEditProfileModal(BuildContext context, UserProfile user) {
    final nameController = TextEditingController(text: user.name);
    final phoneController = TextEditingController(text: user.phone);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 44,
                    height: 4.5,
                    decoration: BoxDecoration(
                      color: Colors.grey.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                const Text('Edit Profile Details', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17)),
                const SizedBox(height: 4),
                Text('Update your name and primary contact number', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                const SizedBox(height: 18),
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: 'Full Name',
                    prefixIcon: const Icon(Icons.person_outline_rounded, color: AppColors.emerald),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    labelText: 'Mobile Number (+91)',
                    prefixIcon: const Icon(Icons.phone_outlined, color: AppColors.saffron),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      final newName = nameController.text.trim();
                      final newPhone = phoneController.text.trim();
                      if (newName.isNotEmpty) {
                        ref.read(authStateProvider.notifier).updateProfile(
                              name: newName,
                              phone: newPhone,
                            );
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Profile details updated successfully!')),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.emerald,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Save Profile Changes', style: TextStyle(fontWeight: FontWeight.w800)),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showReferralDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Row(
            children: [
              Icon(Icons.card_giftcard_rounded, color: AppColors.saffron),
              SizedBox(width: 8),
              Expanded(
                child: Text('Refer a Friend & Earn ₹100', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Share your referral code with fellow Pune explorers. You both receive ₹100 PuneExplorer credits upon their first booking completion!'),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                decoration: BoxDecoration(
                  color: AppColors.saffronLight.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.saffron),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('PUNERIKAR-99', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: 1.5, color: AppColors.saffronDark)),
                    Icon(Icons.copy_rounded, color: AppColors.saffronDark, size: 20),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
            ElevatedButton(
              onPressed: () {
                Clipboard.setData(const ClipboardData(text: 'PUNERIKAR-99'));
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Referral code PUNERIKAR-99 copied to clipboard!')),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.emerald,
                foregroundColor: Colors.white,
              ),
              child: const Text('Copy Code'),
            ),
          ],
        );
      },
    );
  }

  void _showCouponModal(BuildContext context, bool isDark) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          height: MediaQuery.sizeOf(context).height * 0.65,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade400,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text('Active Explorer Coupons & Vouchers', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 17)),
              const SizedBox(height: 6),
              const Text('Redeem 500 Coins for ₹50 voucher or use direct promo codes below:', style: TextStyle(fontSize: 12, color: Colors.grey)),
              const SizedBox(height: 16),
              Expanded(
                child: ListView(
                  children: [
                    _buildCouponTile('DARSHAN50', '₹50 OFF on Pune Darshan AC bus tours', 'Valid till 31 Dec 2026', isDark),
                    _buildCouponTile('TREK15', '15% OFF on Sinhagad Sunrise & Rajgad treks', 'Min booking 2 tickets', isDark),
                    _buildCouponTile('PUNE2026', 'Flat ₹100 Welcome cashback for new explorers', 'First order only', isDark),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCouponTile(String code, String desc, String validity, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.emerald.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(code, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: AppColors.emerald)),
                const SizedBox(height: 2),
                Text(desc, style: const TextStyle(fontSize: 12)),
                const SizedBox(height: 2),
                Text(validity, style: const TextStyle(fontSize: 10.5, color: Colors.grey)),
              ],
            ),
          ),
          OutlinedButton(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: code));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Coupon code $code copied! Apply at checkout.')),
              );
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.emerald,
              side: const BorderSide(color: AppColors.emerald),
            ),
            child: const Text('Apply'),
          ),
        ],
      ),
    );
  }

  Widget _buildAdminHubBanner(BuildContext context, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            HapticFeedback.mediumImpact();
            context.go('/admin/dashboard');
          },
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.5), width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF10B981).withValues(alpha: 0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Text('👑', style: TextStyle(fontSize: 22)),
                ),
                const SizedBox(width: 14),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Admin Command Hub',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Manage destinations, tours & CMS content',
                        style: TextStyle(
                          color: Color(0xFF94A3B8),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Open Hub',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 12.5,
                        ),
                      ),
                      SizedBox(width: 4),
                      Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 14),
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

  void _showSignOutConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Sign Out of PuneExplorer?'),
          content: const Text('Your offline itineraries and cached passes will remain saved locally on this device.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);
                await ref.read(authStateProvider.notifier).signOut();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Row(
                        children: [
                          Icon(Icons.check_circle_outline, color: Colors.white, size: 18),
                          SizedBox(width: 8),
                          Expanded(child: Text('Signed out. Exploring PuneExplorer as Guest.')),
                        ],
                      ),
                      backgroundColor: AppColors.authPrimaryGreen,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                  context.go('/home');
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                foregroundColor: Colors.white,
              ),
              child: const Text('Sign Out'),
            ),
          ],
        );
      },
    );
  }
}
