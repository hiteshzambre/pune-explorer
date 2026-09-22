import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/providers/app_providers.dart';
import '../../../../core/widgets/omni_search_dialog.dart';
import '../../../ai_assistant/presentation/punekar_bot_sheet.dart';

/// Premium, production-grade PuneExplorer Travel Footer matching the reference design.
/// Features a panoramic Sahyadri hillfort hero visual, desktop 4-column navigation,
/// tablet 2x2 grid, mobile expandable touch-friendly accordions, 3 utility cards
/// (Newsletter, 24x7 Support, Socials), copyright legal bar, and closing brand statement strip.
class HomeFooter extends ConsumerStatefulWidget {
  const HomeFooter({super.key});

  @override
  ConsumerState<HomeFooter> createState() => _HomeFooterState();
}

class _HomeFooterState extends ConsumerState<HomeFooter> {
  final TextEditingController _emailController = TextEditingController();
  final Set<int> _expandedAccordions = <int>{};
  bool _isSubscribed = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _toggleAccordion(int index) {
    HapticFeedback.selectionClick();
    setState(() {
      if (_expandedAccordions.contains(index)) {
        _expandedAccordions.remove(index);
      } else {
        _expandedAccordions.add(index);
      }
    });
  }

  void _handleSubscribe() {
    final email = _emailController.text.trim();
    if (email.isEmpty || !email.contains('@') || !email.contains('.')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.white, size: 18),
              SizedBox(width: 8),
              Text('Please enter a valid email address'),
            ],
          ),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    HapticFeedback.mediumImpact();
    setState(() {
      _isSubscribed = true;
    });
    _emailController.clear();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Text('✨ Welcome aboard! Travel stories & offers sent to $email'),
          ],
        ),
        backgroundColor: AppColors.emerald,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _callHelpline(String phone, BuildContext context) async {
    HapticFeedback.lightImpact();
    final clean = phone.replaceAll(' ', '').replaceAll('-', '');
    final uri = Uri.parse('tel:$clean');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('📞 24x7 Tourist Support Hotline: $phone'),
            backgroundColor: AppColors.emerald,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _launchUrl(String url) async {
    HapticFeedback.lightImpact();
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Opening $url'),
            backgroundColor: AppColors.emerald,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _showAboutDialog(BuildContext context) {
    HapticFeedback.lightImpact();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: AppColors.emeraldGradient,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text('🚩', style: TextStyle(fontSize: 20)),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'About PuneExplorer',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'PuneExplorer is Maharashtra\'s premier digital platform dedicated to uncovering the historic hillforts, sacred shrines, scenic ghats, and rich cultural legacy of Pune and the Sahyadri mountains.',
                style: TextStyle(fontSize: 13.5, height: 1.45),
              ),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.emerald.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.emerald.withValues(alpha: 0.25)),
                ),
                child: const Row(
                  children: [
                    Text('🏛️', style: TextStyle(fontSize: 22)),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'पुणे दर्शन आणि सह्याद्री वारसा — Verified routes, certified historian guides, and digital passes.',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.emerald),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Version 2.4.0 (2026 Production Release) • Made with passion for Punekars & global travelers.',
                style: TextStyle(fontSize: 11, color: Colors.grey),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Close', style: TextStyle(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  void _navigateTo(String? route, VoidCallback? onTap) {
    HapticFeedback.selectionClick();
    if (onTap != null) {
      onTap();
    } else if (route != null) {
      if (route.startsWith('/explore') ||
          route.startsWith('/darshan') ||
          route.startsWith('/routes') ||
          route.startsWith('/walks') ||
          route.startsWith('/budget') ||
          route.startsWith('/itinerary') ||
          route.startsWith('/profile')) {
        context.go(route);
      } else {
        context.push(route);
      }
    }
  }

  List<_FooterNavCategory> _buildCategories() {
    return [
      const _FooterNavCategory(
        title: 'DISCOVER PUNE',
        icon: Icons.temple_hindu_outlined,
        links: [
          _FooterNavLink(label: 'Landmarks & Forts', route: '/explore'),
          _FooterNavLink(label: 'Pune Darshan Tours', route: '/darshan'),
          _FooterNavLink(label: 'Heritage Walks', route: '/walks'),
          _FooterNavLink(label: 'Nature & Lakes', route: '/explore'),
          _FooterNavLink(label: 'Temples & Spiritual', route: '/explore'),
          _FooterNavLink(label: 'Food & Culture', route: '/explore'),
          _FooterNavLink(label: 'Events & Experiences', route: '/explore'),
        ],
      ),
      const _FooterNavCategory(
        title: 'PLAN & BOOK',
        icon: Icons.menu_book_outlined,
        links: [
          _FooterNavLink(label: 'Itinerary Planner', route: '/itinerary'),
          _FooterNavLink(label: 'Tour Packages', route: '/darshan'),
          _FooterNavLink(label: 'AC Bus Tours (Darshan)', route: '/darshan'),
          _FooterNavLink(label: 'Group Bookings', route: '/darshan'),
          _FooterNavLink(label: 'Custom Itineraries', route: '/itinerary'),
          _FooterNavLink(label: 'Travel Guides', route: '/about'),
          _FooterNavLink(label: 'Seasonal Plans', route: '/itinerary'),
        ],
      ),
      _FooterNavCategory(
        title: 'TRAVEL TOOLS',
        icon: Icons.construction_outlined,
        links: [
          const _FooterNavLink(label: 'Budget Calculator', route: '/budget'),
          const _FooterNavLink(label: 'My Bookings & Passes', route: '/my-bookings'),
          _FooterNavLink(
            label: 'Omni Search',
            onTap: () => OmniSearchDialog.show(context),
          ),
          _FooterNavLink(
            label: 'PunekarBot AI',
            badge: 'New',
            onTap: () => PunekarBotSheet.show(context),
          ),
          const _FooterNavLink(label: 'Saved Landmarks', route: '/favorites'),
          const _FooterNavLink(label: 'Travel Tips', route: '/help'),
          const _FooterNavLink(label: 'Maps & Routes', route: '/walks'),
        ],
      ),
      const _FooterNavCategory(
        title: 'SUPPORT & LEGAL',
        icon: Icons.security_outlined,
        links: [
          _FooterNavLink(label: 'Help & FAQs', route: '/help'),
          _FooterNavLink(label: 'Privacy Policy', route: '/privacy-policy'),
          _FooterNavLink(label: 'Terms & Conditions', route: '/terms-and-conditions'),
          _FooterNavLink(label: 'Cancellation & Refund', route: '/cancellation-refund'),
          _FooterNavLink(label: 'About PuneExplorer', route: '/about'),
          _FooterNavLink(label: 'Contact Us', route: '/contact-support'),
          _FooterNavLink(label: 'Staff Portal', route: '/admin/login'),
        ],
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final branding = ref.watch(brandingConfigProvider);
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width >= 900;
    final isTablet = width >= 600 && width < 900;
    final isMobile = width < 600;

    return Container(
      width: double.infinity,
      color: const Color(0xFF06251B),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. Top Travel Visual Hero Banner
          _buildHeroBanner(context, branding.siteName, isDesktop, isTablet, isMobile),

          // 2. Main Navigation Area (4 columns desktop, 2x2 tablet, accordions mobile)
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isDesktop ? 48 : (isTablet ? 32 : 18),
              vertical: isDesktop ? 36 : 24,
            ),
            child: isMobile
                ? _buildMobileAccordions()
                : (isTablet ? _buildTabletNavGrid() : _buildDesktopNavGrid()),
          ),

          // 3. Utility Cards (Stay in the Loop, 24x7 Support, Socials)
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isDesktop ? 48 : (isTablet ? 32 : 18),
            ),
            child: _buildUtilityCards(isDesktop, isTablet, isMobile),
          ),

          const SizedBox(height: 32),

          // 4. Bottom Legal Bar
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isDesktop ? 48 : (isTablet ? 32 : 18),
            ),
            child: _buildBottomLegalBar(isDesktop, isMobile),
          ),

          const SizedBox(height: 20),

          // 5. Brand Closing Strip ("More Than a Destination / A Deeper Connection")
          _buildClosingStrip(isDesktop, isMobile),
        ],
      ),
    );
  }

  // ── 1. Top Travel Visual Hero Banner ──────────────────────────────────────
  Widget _buildHeroBanner(
    BuildContext context,
    String siteName,
    bool isDesktop,
    bool isTablet,
    bool isMobile,
  ) {
    final bannerName = siteName.isNotEmpty ? siteName : 'PuneExplorer';

    return Container(
      width: double.infinity,
      constraints: BoxConstraints(
        minHeight: isDesktop ? 270 : (isTablet ? 240 : 210),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Background panoramic artwork
          Positioned.fill(
            child: Image.asset(
              'assets/images/puneexplorer_footer_hero.webp',
              fit: BoxFit.cover,
              alignment: isMobile ? const Alignment(0.65, 0.0) : Alignment.center,
              errorBuilder: (context, error, stackTrace) {
                return Image.asset(
                  'assets/images/puneexplorer_footer_hero.jpg',
                  fit: BoxFit.cover,
                  alignment: isMobile ? const Alignment(0.65, 0.0) : Alignment.center,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFF0F3A2C), Color(0xFF06251B)],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),

          // Bottom gradient overlay to blend smoothly into the footer background
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.05),
                    Colors.black.withValues(alpha: 0.15),
                    const Color(0xFF06251B).withValues(alpha: 0.65),
                    const Color(0xFF06251B),
                  ],
                  stops: const [0.0, 0.4, 0.75, 1.0],
                ),
              ),
            ),
          ),

          // Content overlay
          Padding(
            padding: EdgeInsets.fromLTRB(
              isDesktop ? 48 : (isTablet ? 32 : 18),
              isDesktop ? 28 : 20,
              isDesktop ? 48 : (isTablet ? 32 : 18),
              18,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Top Row: Brand Header + Cursive Quote
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Brand Badge & Taglines
                    Flexible(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: isMobile ? 38 : 46,
                                height: isMobile ? 38 : 46,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF059669),
                                  borderRadius: BorderRadius.circular(isMobile ? 10 : 13),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.2),
                                      blurRadius: 8,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  '🚩',
                                  style: TextStyle(fontSize: isMobile ? 20 : 24),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Flexible(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      bannerName,
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: isMobile ? 18 : 22,
                                        fontWeight: FontWeight.w900,
                                        color: const Color(0xFF0F221B),
                                        letterSpacing: -0.3,
                                      ),
                                    ),
                                    Text(
                                      'Travel & Heritage',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: isMobile ? 11 : 13,
                                        fontWeight: FontWeight.w800,
                                        color: const Color(0xFFEA580C),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Discover Pune. Explore its stories.',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: isMobile ? 11.5 : 13,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF1E3A2F),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Cursive "Explore - Pune Beyond Boundaries" (Desktop & Tablet)
                    if (!isMobile)
                      Padding(
                        padding: const EdgeInsets.only(right: 80, top: 4),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Explore\n- Pune Beyond\nBoundaries',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.caveat(
                                fontSize: isDesktop ? 30 : 24,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF163E2E),
                                height: 0.95,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Container(
                              width: 85,
                              height: 2.5,
                              decoration: BoxDecoration(
                                color: const Color(0xFFEA580C).withValues(alpha: 0.8),
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),

                const SizedBox(height: 24),

                // Center/Bottom Tagline Pill
                Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Location Pill: 📍 Forts • Culture • Nature • Food • People
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: isMobile ? 12 : 18,
                            vertical: isMobile ? 6 : 8,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF06251B).withValues(alpha: 0.75),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: const Color(0xFFF59E0B).withValues(alpha: 0.35),
                              width: 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.25),
                                blurRadius: 10,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.location_on_rounded,
                                color: Color(0xFFF59E0B),
                                size: 15,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Forts  •  Culture  •  Nature  •  Food  •  People',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.plusJakartaSans(
                                  color: const Color(0xFFFDFDFD),
                                  fontSize: isMobile ? 10.5 : 12.5,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.2,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'A city of heritage, a lifetime of experiences.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: isMobile ? 11 : 12.5,
                          color: const Color(0xFFBBD0C7),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── 2. Desktop Navigation Grid (4 columns) ────────────────────────────────
  Widget _buildDesktopNavGrid() {
    final categories = _buildCategories();

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: categories.map((cat) {
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.only(right: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Category Header
                Row(
                  children: [
                    Icon(cat.icon, color: const Color(0xFFF59E0B), size: 18),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        cat.title,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.8,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Category Links
                ...cat.links.map((link) => _buildNavLink(link)),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  // ── 2b. Tablet Navigation Grid (2x2 grid) ─────────────────────────────────
  Widget _buildTabletNavGrid() {
    final categories = _buildCategories();

    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: _buildNavColumn(categories[0])),
            const SizedBox(width: 24),
            Expanded(child: _buildNavColumn(categories[1])),
          ],
        ),
        const SizedBox(height: 24),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: _buildNavColumn(categories[2])),
            const SizedBox(width: 24),
            Expanded(child: _buildNavColumn(categories[3])),
          ],
        ),
      ],
    );
  }

  Widget _buildNavColumn(_FooterNavCategory cat) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(cat.icon, color: const Color(0xFFF59E0B), size: 18),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                cat.title,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.8,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...cat.links.map((link) => _buildNavLink(link)),
      ],
    );
  }

  // ── 2c. Mobile Expandable Accordions ──────────────────────────────────────
  Widget _buildMobileAccordions() {
    final categories = _buildCategories();

    return Column(
      children: List.generate(categories.length, (index) {
        final cat = categories[index];
        final isExpanded = _expandedAccordions.contains(index);

        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            color: const Color(0xFF0C3426),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: const Color(0xFF164E38),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              InkWell(
                onTap: () => _toggleAccordion(index),
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  child: Row(
                    children: [
                      Icon(cat.icon, color: const Color(0xFFF59E0B), size: 18),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          cat.title,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      AnimatedRotation(
                        turns: isExpanded ? 0.5 : 0.0,
                        duration: const Duration(milliseconds: 220),
                        curve: Curves.easeInOut,
                        child: const Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: Color(0xFF9CA3AF),
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (isExpanded)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Divider(color: Color(0xFF164E38), height: 1),
                      const SizedBox(height: 10),
                      ...cat.links.map((link) => _buildNavLink(link, isMobile: true)),
                    ],
                  ),
                ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildNavLink(_FooterNavLink link, {bool isMobile = false}) {
    return InkWell(
      onTap: () => _navigateTo(link.route, link.onTap),
      borderRadius: BorderRadius.circular(6),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: isMobile ? 8.0 : 6.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Text(
                link.label,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: isMobile ? 13 : 13.5,
                  color: const Color(0xFFC8DBD3),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            if (link.badge != null) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFEA580C),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  link.badge!,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ── 3. Utility Cards (Stay in Loop, 24x7 Support, Follow Us) ──────────────
  Widget _buildUtilityCards(bool isDesktop, bool isTablet, bool isMobile) {
    if (isDesktop) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(flex: 12, child: _buildNewsletterCard(isMobile: false)),
          const SizedBox(width: 16),
          Expanded(flex: 11, child: _buildSupportCard(isMobile: false)),
          const SizedBox(width: 16),
          Expanded(flex: 10, child: _buildSocialCard()),
        ],
      );
    }

    if (isTablet) {
      return Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _buildNewsletterCard(isMobile: false)),
              const SizedBox(width: 16),
              Expanded(child: _buildSupportCard(isMobile: false)),
            ],
          ),
          const SizedBox(height: 16),
          _buildSocialCard(),
        ],
      );
    }

    // Mobile: Vertically Stacked
    return Column(
      children: [
        _buildNewsletterCard(isMobile: true),
        const SizedBox(height: 14),
        _buildSupportCard(isMobile: true),
        const SizedBox(height: 14),
        _buildSocialCard(),
      ],
    );
  }

  // ── 3a. Stay in the Loop Card ─────────────────────────────────────────────
  Widget _buildNewsletterCard({required bool isMobile}) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF0C3426),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF164E38), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: const Color(0xFFF59E0B).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.mail_outline_rounded, color: Color(0xFFF59E0B), size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Stay in the Loop',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Get travel stories, new tours & exclusive offers straight to your inbox.',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11.5,
                        color: const Color(0xFF8FA99E),
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Email Input & Subscribe Button Form
          if (_isSubscribed)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFF059669).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: const Color(0xFF059669)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.check_circle_rounded, color: Color(0xFF10B981), size: 16),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Subscribed to Pune travel updates!',
                      style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            )
          else
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(26),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.15),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const SizedBox(width: 14),
                  Expanded(
                    child: TextField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.done,
                      onSubmitted: (_) => _handleSubscribe(),
                      style: const TextStyle(
                        color: Color(0xFF0F172A),
                        fontSize: 12.5,
                        fontWeight: FontWeight.w500,
                      ),
                      decoration: const InputDecoration(
                        hintText: 'Enter your email',
                        hintStyle: TextStyle(
                          color: Color(0xFF94A3B8),
                          fontSize: 12.5,
                        ),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(vertical: 10),
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: _handleSubscribe,
                    borderRadius: BorderRadius.circular(26),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEA580C),
                        borderRadius: BorderRadius.circular(26),
                      ),
                      child: Text(
                        'Subscribe',
                        style: GoogleFonts.plusJakartaSans(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  // ── 3b. 24x7 Tourist Support Card ─────────────────────────────────────────
  Widget _buildSupportCard({required bool isMobile}) {
    final branding = ref.watch(brandingConfigProvider);
    final phone = branding.contactPhone.isNotEmpty ? branding.contactPhone : '+91 20 2612 0000';

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF0C3426),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF164E38), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: const Color(0xFFF59E0B).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.headset_mic_outlined, color: Color(0xFFF59E0B), size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '24x7 Tourist Support',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '24x7 Tourist Support Hotline',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF10B981),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'We\'re here to help you explore Pune',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11.5,
                        color: const Color(0xFF8FA99E),
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Call button
          InkWell(
            onTap: () => _callHelpline(phone, context),
            borderRadius: BorderRadius.circular(26),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
              decoration: BoxDecoration(
                color: const Color(0xFF0F766E),
                borderRadius: BorderRadius.circular(26),
                border: Border.all(
                  color: const Color(0xFF14B8A6).withValues(alpha: 0.3),
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF0F766E).withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.call_rounded, color: Colors.white, size: 15),
                    const SizedBox(width: 8),
                    Text(
                      phone,
                      style: GoogleFonts.plusJakartaSans(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── 3c. Follow Our Journey Card ───────────────────────────────────────────
  Widget _buildSocialCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF0C3426),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF164E38), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Follow Our Journey',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            'Travel reels, photos and updates',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11.5,
              color: const Color(0xFF8FA99E),
            ),
          ),
          const SizedBox(height: 14),

          // Social icons row
          Wrap(
            spacing: 10,
            runSpacing: 8,
            children: [
              // 1. Instagram
              _buildSocialIcon(
                iconWidget: const Icon(Icons.camera_alt_outlined, color: Colors.white, size: 16),
                gradient: const LinearGradient(
                  colors: [Color(0xFF833AB4), Color(0xFFFD1D1D), Color(0xFFFCB045)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                url: 'https://www.instagram.com',
                tooltip: 'Instagram',
              ),
              const SizedBox(width: 10),

              // 2. YouTube
              _buildSocialIcon(
                iconWidget: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 18),
                color: const Color(0xFFFF0000),
                url: 'https://www.youtube.com',
                tooltip: 'YouTube',
              ),
              const SizedBox(width: 10),

              // 3. Facebook
              _buildSocialIcon(
                iconWidget: const Text(
                  'f',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    fontFamily: 'serif',
                  ),
                ),
                color: const Color(0xFF1877F2),
                url: 'https://www.facebook.com',
                tooltip: 'Facebook',
              ),
              const SizedBox(width: 10),

              // 4. X (Twitter)
              _buildSocialIcon(
                iconWidget: const Text(
                  '𝕏',
                  style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w900),
                ),
                color: const Color(0xFF000000),
                url: 'https://x.com',
                tooltip: 'X (Twitter)',
              ),
              const SizedBox(width: 10),

              // 5. LinkedIn
              _buildSocialIcon(
                iconWidget: const Text(
                  'in',
                  style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w900),
                ),
                color: const Color(0xFF0A66C2),
                url: 'https://www.linkedin.com',
                tooltip: 'LinkedIn',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSocialIcon({
    required Widget iconWidget,
    Color? color,
    Gradient? gradient,
    required String url,
    required String tooltip,
  }) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: () => _launchUrl(url),
        borderRadius: BorderRadius.circular(20),
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: color,
            gradient: gradient,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          alignment: Alignment.center,
          child: iconWidget,
        ),
      ),
    );
  }

  // ── 4. Bottom Legal Bar ───────────────────────────────────────────────────
  Widget _buildBottomLegalBar(bool isDesktop, bool isMobile) {
    final currentYear = DateTime.now().year;

    if (isDesktop) {
      return Wrap(
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 16,
        runSpacing: 10,
        children: [
          // Left: Copyright
          Text(
            '© $currentYear PuneExplorer. All rights reserved.',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              color: const Color(0xFF8FA99E),
              fontWeight: FontWeight.w500,
            ),
          ),

          // Center: Crafted with flag & heart
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('🚩', style: TextStyle(fontSize: 13)),
              const SizedBox(width: 4),
              Text(
                'Crafted with ❤️ for Pune & Sahyadri Heritage',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  color: const Color(0xFF8FA99E),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),

          // Right: Legal & Version
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildLegalLink('Sitemap', '/explore'),
              _buildLegalSeparator(),
              _buildLegalLink('Cookies', '/privacy-policy'),
              _buildLegalSeparator(),
              _buildLegalLink('Accessibility', '/help'),
              const SizedBox(width: 14),
              InkWell(
                onTap: () => _showAboutDialog(context),
                borderRadius: BorderRadius.circular(4),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  child: Text(
                    'v2.4.0',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF8FA99E),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      );
    }

    // Mobile Legal Bar
    return Column(
      children: [
        Text(
          '© $currentYear PuneExplorer. All rights reserved.',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 11.5,
            color: const Color(0xFF8FA99E),
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 6),
        Wrap(
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 4,
          runSpacing: 4,
          children: [
            _buildLegalLink('Sitemap', '/explore'),
            _buildLegalSeparator(),
            _buildLegalLink('Cookies', '/privacy-policy'),
            _buildLegalSeparator(),
            _buildLegalLink('Accessibility', '/help'),
            const SizedBox(width: 8),
            InkWell(
              onTap: () => _showAboutDialog(context),
              child: Text(
                'v2.4.0',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF8FA99E),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLegalLink(String label, String route) {
    return InkWell(
      onTap: () => _navigateTo(route, null),
      child: Text(
        label,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 11.5,
          color: const Color(0xFF8FA99E),
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildLegalSeparator() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 8),
      child: Text(
        '|',
        style: TextStyle(color: Color(0xFF335C4C), fontSize: 11),
      ),
    );
  }

  // ── 5. Brand Closing Strip ────────────────────────────────────────────────
  Widget _buildClosingStrip(bool isDesktop, bool isMobile) {
    final textContent = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            'More Than a Destination',
            style: GoogleFonts.caveat(
              fontSize: isMobile ? 18 : 22,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1B4D36),
              height: 1.1,
            ),
          ),
        ),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            'A Deeper Connection',
            style: GoogleFonts.caveat(
              fontSize: isMobile ? 21 : 25,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF1B4D36),
              height: 1.1,
            ),
          ),
        ),
      ],
    );

    return Container(
      width: double.infinity,
      color: const Color(0xFFF4F7F4),
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 48 : 16,
        vertical: 14,
      ),
      child: isMobile
          ? Center(child: textContent)
          : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: Container(
                    height: 1.2,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.transparent, Color(0xFF1B4D36)],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 24),
                Flexible(child: textContent),
                const SizedBox(width: 24),
                Expanded(
                  child: Container(
                    height: 1.2,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF1B4D36), Colors.transparent],
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

class _FooterNavCategory {
  final String title;
  final IconData icon;
  final List<_FooterNavLink> links;

  const _FooterNavCategory({
    required this.title,
    required this.icon,
    required this.links,
  });
}

class _FooterNavLink {
  final String label;
  final String? route;
  final VoidCallback? onTap;
  final String? badge;

  const _FooterNavLink({
    required this.label,
    this.route,
    this.onTap,
    this.badge,
  });
}
