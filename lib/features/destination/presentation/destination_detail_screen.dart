import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../app/theme/app_colors.dart';
import '../../../data/models/destination.dart';
import '../../../data/models/review.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/responsive/breakpoints.dart';
import '../../../core/responsive/responsive_builder.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/error_boundary.dart';
import '../../../core/widgets/app_network_image.dart';
import '../../../core/widgets/omni_search_dialog.dart';
import 'widgets/destination_3d_decorations.dart';
import 'destination_booking_screen.dart';

class DestinationDetailScreen extends ConsumerStatefulWidget {
  final String destinationId;

  const DestinationDetailScreen({super.key, required this.destinationId});

  @override
  ConsumerState<DestinationDetailScreen> createState() =>
      _DestinationDetailScreenState();
}

class _DestinationDetailScreenState
    extends ConsumerState<DestinationDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedImageIndex = 0;
  bool _isDescriptionExpanded = false;

  String _getDestinationQuote(Destination dest) {
    final lower = dest.name.toLowerCase();
    if (lower.contains('dagdusheth') || lower.contains('ganpati')) {
      return '“Faith, culture and community come together here, making it the heart of Pune.”';
    } else if (lower.contains('shaniwar')) {
      return '“The historic stone walls still echo the unmatched valour and governance of the Peshwas.”';
    } else if (lower.contains('sinhagad')) {
      return '“The fortress of the lion, where freedom was etched into the rugged Sahyadri cliffs.”';
    } else if (lower.contains('aga khan')) {
      return '“Serene Italian arches where history paused and India’s freedom spirit echoed.”';
    }
    return '“A timeless heritage landmark celebrating Pune’s enduring spirit, culture, and pride.”';
  }

  String _getDestinationQuoteAttribution(Destination dest) {
    final lower = dest.name.toLowerCase();
    if (lower.contains('dagdusheth') || lower.contains('ganpati')) {
      return '— Ramesh Joshi, Budhwar Peth Resident (Punekar since 1974)';
    } else if (lower.contains('shaniwar')) {
      return '— Historian Dr. Mohan Shinde, Deccan Gymkhana';
    } else if (lower.contains('sinhagad')) {
      return '— Sahyadri Trekker & Pune Hikers Guild';
    } else if (lower.contains('aga khan')) {
      return '— Heritage Guide & Cultural Historian, Pune';
    }
    return '— Verified Punekar Explorer & Reviewer';
  }

  List<Map<String, String>> _getDestinationHighlights(Destination dest) {
    final lower = dest.name.toLowerCase();
    if (lower.contains('dagdusheth') || lower.contains('ganpati')) {
      return [
        {
          'title': 'Peshwa History',
          'desc': 'Lokmanya Tilak inspired the public Sarvajanik Ganeshotsav here',
          'icon': '👑',
        },
        {
          'title': 'Dilli Darwaza',
          'desc': 'Magnificent 7.5-ft golden deity adorned with precious gems',
          'icon': '🚪',
        },
        {
          'title': 'Sound & Light Show',
          'desc': 'Soulful 6:30 AM devotional chanting and sacred aarti experience',
          'icon': '✨',
        },
        {
          'title': 'Maratha Architecture',
          'desc': 'Intricate silver filigree ceiling & festive replica mandaps',
          'icon': '🏛️',
        },
      ];
    } else if (lower.contains('shaniwar')) {
      return [
        {
          'title': 'Peshwa History',
          'desc': 'Legacy of the Marathas & administrative prowess',
          'icon': '👑',
        },
        {
          'title': 'Dilli Darwaza',
          'desc': 'Iconic entrance with 72 elephant spikes',
          'icon': '🚪',
        },
        {
          'title': 'Sound & Light Show',
          'desc': 'A mesmerizing evening storytelling experience',
          'icon': '✨',
        },
        {
          'title': 'Maratha Architecture',
          'desc': 'Blend of teakwood craft, stone, and bastions',
          'icon': '🏛️',
        },
      ];
    } else {
      final parts = dest.famousFor.split(',').map((s) => s.trim()).toList();
      return [
        {
          'title': parts.isNotEmpty ? parts[0] : 'Historical Heritage',
          'desc': 'Cherished monument deeply woven into Pune cultural roots',
          'icon': '👑',
        },
        {
          'title': parts.length > 1 ? parts[1] : 'Scenic Architecture',
          'desc': 'Unique architectural craftsmanship and timeless Sahyadri vista',
          'icon': '🏛️',
        },
        {
          'title': parts.length > 2 ? parts[2] : 'Cultural Experience',
          'desc': 'Authentic local tradition, storytelling and atmosphere',
          'icon': '✨',
        },
        {
          'title': parts.length > 3 ? parts[3] : 'Scenic Panoramas',
          'desc': 'Captivating photography spots and historic viewpoints',
          'icon': '🌄',
        },
      ];
    }
  }

  List<AttractionItem> _getNearbyAttractions(Destination dest) {
    if (dest.attractions.length >= 4) {
      return dest.attractions.take(4).toList();
    }
    final list = List<AttractionItem>.from(dest.attractions);
    final fallbacks = [
      const AttractionItem(
        name: 'Appa Balwant Chowk (ABC)',
        description: 'Historic book street and stationery bazaar',
        distance: '0.4 km',
        travelTime: '5 min walk',
        rating: 4.4,
        image: 'https://images.unsplash.com/photo-1524492412937-b28074a5d7da?q=80&w=600',
      ),
      const AttractionItem(
        name: 'Shaniwar Wada',
        description: 'Iconic 18th-century Peshwa palace fort',
        distance: '1.8 km',
        travelTime: '10 min drive',
        rating: 4.8,
        image: 'https://images.unsplash.com/photo-1599661046289-e31897846e41?q=80&w=600',
      ),
      const AttractionItem(
        name: 'Tulshibaug Market',
        description: 'Historic bustling traditional shopping bazaar',
        distance: '0.6 km',
        travelTime: '7 min walk',
        rating: 4.5,
        image: 'https://images.unsplash.com/photo-1601050690597-df0568f70950?q=80&w=600',
      ),
      const AttractionItem(
        name: 'Sarasbaug',
        description: 'Tranquil Ganpati temple complex and gardens',
        distance: '2.3 km',
        travelTime: '12 min drive',
        rating: 4.7,
        image: 'https://images.unsplash.com/photo-1626621341517-bbf3d9990a23?q=80&w=600',
      ),
    ];
    for (final fb in fallbacks) {
      if (list.length >= 4) break;
      if (!list.any((a) => a.name.toLowerCase() == fb.name.toLowerCase()) &&
          fb.name.toLowerCase() != dest.name.toLowerCase()) {
        list.add(fb);
      }
    }
    return list;
  }

  List<String> _getGalleryImages(Destination dest, List<String> imagesList) {
    final list = List<String>.from(imagesList);
    final defaults = [
      'https://images.unsplash.com/photo-1563379091339-03246963d96c?q=80&w=1200&auto=format&fit=crop',
      'https://images.unsplash.com/photo-1599661046289-e31897846e41?q=80&w=1200&auto=format&fit=crop',
      'https://images.unsplash.com/photo-1601050690597-df0568f70950?q=80&w=1200&auto=format&fit=crop',
      'https://images.unsplash.com/photo-1544735716-392fe2489ffa?q=80&w=1200&auto=format&fit=crop',
    ];
    for (final def in defaults) {
      if (list.length >= 4) break;
      if (!list.contains(def)) list.add(def);
    }
    return list;
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 7, vsync: this);
    _tabController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _safeGo(BuildContext context, String path) {
    try {
      context.go(path);
    } catch (e) {
      // Graceful fallback for non-injected GoRouter environments
      debugPrint('Navigation failed for path "$path": $e');
    }
  }

  void _showAddReviewDialog(BuildContext context, String destId) {
    showDialog(
      context: context,
      builder: (ctx) =>
          _AddReviewDialogWidget(destinationId: destId, ref: ref),
    );
  }

  void _openLightbox(BuildContext context, List<String> images, int initialIdx,
      String title) {
    showDialog(
      context: context,
      builder: (ctx) => DestinationLightboxDialog(
        images: images,
        initialIndex: initialIdx,
        title: title,
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final destinationsAsync = ref.watch(destinationsAsyncProvider);
    final isFav = ref.watch(favoritesProvider.select((favs) => favs.contains(widget.destinationId)));
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isDesktopOrTablet = screenWidth >= 768;

    return destinationsAsync.when(
      data: (destinations) {
        final destination = destinations
            .where((d) => d.id == widget.destinationId)
            .firstOrNull;
        if (destination == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Destination')),
            body: const ErrorBoundaryWidget(
              errorMessage: 'Destination not found. It may have been removed.',
            ),
          );
        }

        return Scaffold(
          backgroundColor: isDark ? const Color(0xFF090D16) : AppColors.creamBg,
          body: isDesktopOrTablet
              ? _buildDesktopLayout(
                  destination, theme, isDark, isFav, screenWidth)
              : _buildMobileLayout(
                  destination, theme, isDark, isFav, screenWidth),
          bottomNavigationBar: isDesktopOrTablet
              ? null
              : _buildMobileBottomDock(destination, isDark, context),
        );
      },
      loading: () => const Scaffold(
        backgroundColor: AppColors.deepForest,
        body: Center(
          child: CircularProgressIndicator(color: AppColors.goldAccent),
        ),
      ),
      error: (e, _) => Scaffold(
        body: ErrorBoundaryWidget(errorMessage: e.toString()),
      ),
    );
  }

  // ===========================================================================
  // ── DESKTOP WEB LAYOUT (Width >= 768px) ────────────────────────────────────
  // ===========================================================================
  Widget _buildDesktopLayout(
    Destination destination,
    ThemeData theme,
    bool isDark,
    bool isFav,
    double screenWidth,
  ) {
    final imagesList = destination.images.isNotEmpty
        ? destination.images
        : [destination.primaryImage];

    return CustomScrollView(
      slivers: [
        // 1. Desktop Top Navigation Bar (Dark Forest Green)
        SliverToBoxAdapter(
          child: _buildDesktopNavbar(context, isFav),
        ),

        // 2. Cinematic Desktop Hero Section
        SliverToBoxAdapter(
          child: _buildDesktopHeroSection(
              destination, isDark, isFav, imagesList, screenWidth),
        ),

        // 3. Floating Quick Info Matrix Card (Clean non-overlapping placement)
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.only(top: 20, bottom: 8),
            child: MaxWidthWrapper(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: _buildFloatingQuickInfoCard(destination, isDark, isFav),
            ),
          ),
        ),

        // 4. Desktop Tabs Navigation
        SliverToBoxAdapter(
          child: MaxWidthWrapper(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDestinationTabsBar(isDark),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),

        // 5. Desktop Two-Column Split (67% Left Content / 33% Right Sidebar)
        SliverToBoxAdapter(
          child: MaxWidthWrapper(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left Column (67%)
                Expanded(
                  flex: 67,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Active Tab Content View
                      _buildActiveTabContent(
                          destination, theme, isDark, imagesList),
                      const SizedBox(height: 48),
                    ],
                  ),
                ),
                const SizedBox(width: 32),

                // Right Sidebar (33%)
                Expanded(
                  flex: 33,
                  child: Column(
                    children: [
                      // Context-aware sidebar cards
                      ..._buildDesktopSidebarCards(destination, isDark),
                      const SizedBox(height: 48),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ── Desktop Contextual Sidebar Cards ──────────────────────────────────────
  List<Widget> _buildDesktopSidebarCards(Destination dest, bool isDark) {
    switch (_tabController.index) {
      case 1: // Map View active on left -> show Weather, CTA & Tips on right
        return [
          _buildLiveWeatherSidebarCard(dest, isDark),
          const SizedBox(height: 20),
          _buildPremiumHeritageCtaCard(dest, isDark),
          const SizedBox(height: 20),
          _buildPunekarTipsSidebarCard(dest, isDark),
        ];
      case 2: // Weather active on left -> show Location Map, CTA & Tips on right
        return [
          _buildLocationSidebarCard(dest, isDark),
          const SizedBox(height: 20),
          _buildPremiumHeritageCtaCard(dest, isDark),
          const SizedBox(height: 20),
          _buildPunekarTipsSidebarCard(dest, isDark),
        ];
      case 0: // Overview active on left
      default:
        return [
          _buildLocationSidebarCard(dest, isDark),
          const SizedBox(height: 20),
          _buildLiveWeatherSidebarCard(dest, isDark),
          const SizedBox(height: 20),
          _buildPremiumHeritageCtaCard(dest, isDark),
          const SizedBox(height: 20),
          _buildPunekarTipsSidebarCard(dest, isDark),
        ];
    }
  }

  // ── Desktop Navbar ─────────────────────────────────────────────────────────
  Widget _buildDesktopNavbar(BuildContext context, bool isFav) {
    return Container(
      height: 72,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: const BoxDecoration(
        gradient: AppColors.forestNavbarGradient,
        boxShadow: [
          BoxShadow(
            color: Color(0x33000000),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final showCenterLinks = constraints.maxWidth >= 960;

          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Left: Brand Logo & Editorial Motto
              InkWell(
                onTap: () => _safeGo(context, '/home'),
                borderRadius: BorderRadius.circular(8),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: AppColors.goldAccent.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(10),
                        border:
                            Border.all(color: AppColors.goldAccent, width: 1.2),
                      ),
                      alignment: Alignment.center,
                      child: const Text('🏛️', style: TextStyle(fontSize: 20)),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'PuneExplorer',
                          style: GoogleFonts.playfairDisplay(
                            fontSize: 19,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: 0.2,
                          ),
                        ),
                        const Text(
                          'Explore • Live • Belong',
                          style: TextStyle(
                            fontSize: 10,
                            color: AppColors.goldAccent,
                            letterSpacing: 1.1,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Center: Desktop Navigation Links (shown when ample width)
              if (showCenterLinks)
                Flexible(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildNavbarLink('Home', '/home', false),
                          _buildNavbarLink('Destinations', '/explore', true),
                          _buildNavbarLink('Food', '/explore', false),
                          _buildNavbarLink('Experiences', '/routes', false),
                          _buildNavbarLink('Plan Trip', '/itinerary', false),
                        ],
                      ),
                    ),
                  ),
                ),

              // Right: Action Icons (Search, Favorite, Profile, Menu)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    tooltip: 'Search',
                    icon: const Icon(Icons.search_rounded,
                        color: Colors.white, size: 21),
                    onPressed: () => showDialog(
                      context: context,
                      builder: (_) => const OmniSearchDialog(),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Favorites',
                    icon: Icon(
                      isFav
                          ? Icons.favorite_rounded
                          : Icons.favorite_border_rounded,
                      color: isFav ? const Color(0xFFEF4444) : Colors.white,
                      size: 21,
                    ),
                    onPressed: () {
                      HapticFeedback.mediumImpact();
                      ref
                          .read(favoritesProvider.notifier)
                          .toggle(widget.destinationId);
                    },
                  ),
                  IconButton(
                    tooltip: 'Profile',
                    icon: const Icon(Icons.person_outline_rounded,
                        color: Colors.white, size: 21),
                    onPressed: () => _safeGo(context, '/profile'),
                  ),
                  const SizedBox(width: 4),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                          color: Colors.white.withValues(alpha: 0.3), width: 1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: IconButton(
                      tooltip: 'Menu',
                      icon: const Icon(Icons.menu_rounded,
                          color: Colors.white, size: 19),
                      onPressed: () => _safeGo(context, '/explore'),
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildNavbarLink(String label, String route, bool isActive) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: TextButton(
        onPressed: () => _safeGo(context, route),
        style: TextButton.styleFrom(
          foregroundColor: isActive ? AppColors.goldAccent : Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isActive ? FontWeight.w800 : FontWeight.w600,
                color: isActive ? AppColors.goldAccent : Colors.white,
              ),
            ),
            if (isActive)
              Container(
                margin: const EdgeInsets.only(top: 3),
                width: 16,
                height: 2.5,
                decoration: BoxDecoration(
                  color: AppColors.goldAccent,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ── Desktop Hero Section ───────────────────────────────────────────────────
  Widget _buildDesktopHeroSection(
    Destination destination,
    bool isDark,
    bool isFav,
    List<String> imagesList,
    double screenWidth,
  ) {
    final activeImage = imagesList[_selectedImageIndex % imagesList.length];
    const heroHeight = 540.0;
    final isUltraWide = screenWidth >= 1200;

    return Container(
      height: heroHeight,
      width: double.infinity,
      color: const Color(0xFF021915),
      child: Stack(
        children: [
          // 1. Right-side Editorial Photographic Visual (Dominant 48-55% width)
          Positioned(
            top: 0,
            bottom: 0,
            right: 0,
            width: isUltraWide ? screenWidth * 0.52 : screenWidth * 0.48,
            child: Stack(
              fit: StackFit.expand,
              children: [
                AppCardImage(
                  imageUrl: activeImage,
                  heroTag: 'dest_img_${destination.id}',
                  categoryIcon: destination.category.icon,
                  categoryLabel: destination.category.label,
                  title: destination.name,
                  fit: BoxFit.cover,
                ),
                // Smooth horizontal fade gradient to seamlessly blend into dark background on left
                Positioned.fill(
                  child: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [
                          Color(0xFF021915),
                          Color(0xEE021915),
                          Color(0x66021915),
                          Colors.transparent,
                        ],
                        stops: [0.0, 0.25, 0.65, 1.0],
                      ),
                    ),
                  ),
                ),
                // Soft vertical top/bottom gradient to integrate with edges
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.35),
                          Colors.transparent,
                          const Color(0xFF021915).withValues(alpha: 0.7),
                        ],
                        stops: const [0.0, 0.5, 1.0],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 2. Editorial Content Overlay (Breadcrumb, Badges, Title, Desc, CTAs, Thumbnails)
          Positioned.fill(
            child: MaxWidthWrapper(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Top Row: Breadcrumbs & Location / Weather Chips
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Breadcrumb: Home > Destinations > [Name]
                      Flexible(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            InkWell(
                              onTap: () => _safeGo(context, '/home'),
                              borderRadius: BorderRadius.circular(4),
                              child: const Text(
                                'Home',
                                style: TextStyle(
                                  color: Color(0xFF94A3B8),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 8),
                              child: Icon(Icons.chevron_right_rounded,
                                  size: 14, color: Color(0xFF64748B)),
                            ),
                            InkWell(
                              onTap: () => _safeGo(context, '/explore'),
                              borderRadius: BorderRadius.circular(4),
                              child: const Text(
                                'Destinations',
                                style: TextStyle(
                                  color: Color(0xFF94A3B8),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 8),
                              child: Icon(Icons.chevron_right_rounded,
                                  size: 14, color: Color(0xFF64748B)),
                            ),
                            Flexible(
                              child: Text(
                                destination.name,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),

                      // Right Chip: Location Badge & Weather Altitude Badge
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 7),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.5),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: AppColors.goldAccent.withValues(alpha: 0.6),
                                width: 1.2,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.location_on_rounded,
                                    color: AppColors.goldAccent, size: 15),
                                const SizedBox(width: 6),
                                Text(
                                  destination.state,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 10),
                          Floating3DWeatherAltitudeBadge(
                            altitude:
                                '~${((destination.latitude * 72).abs().toInt() + 450)}m Alt',
                            weather: '~26°C Pleasant',
                            weatherIcon: '⛅',
                          ),
                        ],
                      ),
                    ],
                  ),

                  // Middle / Main Column: Badges, Title, Subtitle, Description, CTAs
                  ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: screenWidth >= 1100 ? 640 : 540,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Category & Heritage Badges
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 5),
                              decoration: BoxDecoration(
                                color: const Color(0xFF064E3B).withValues(alpha: 0.85),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: const Color(0xFF10B981).withValues(alpha: 0.5),
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(destination.category.icon,
                                      style: const TextStyle(fontSize: 12)),
                                  const SizedBox(width: 6),
                                  Text(
                                    destination.category.label,
                                    style: const TextStyle(
                                      color: Color(0xFF6EE7B7),
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (destination.isTrending)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 5),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF1E293B).withValues(alpha: 0.9),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: const Color(0xFF475569),
                                    width: 1,
                                  ),
                                ),
                                child: const Text(
                                  '🔥 Trending in Pune',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 5),
                              decoration: BoxDecoration(
                                color: const Color(0xFF2E1F07).withValues(alpha: 0.9),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: AppColors.goldAccent.withValues(alpha: 0.6),
                                  width: 1,
                                ),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text('👑', style: TextStyle(fontSize: 12)),
                                  SizedBox(width: 6),
                                  Text(
                                    'Maratha Heritage',
                                    style: TextStyle(
                                      color: AppColors.goldAccent,
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),

                        // Destination Title in Playfair Display
                        Text(
                          destination.name,
                          style: GoogleFonts.playfairDisplay(
                            fontSize: screenWidth >= 1200 ? 46 : 38,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: -0.5,
                            height: 1.12,
                          ),
                        ),
                        const SizedBox(height: 8),

                        // Subtitle / Tagline
                        Text(
                          'A Glimpse into Pune’s Glorious Past',
                          style: GoogleFonts.inter(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: AppColors.goldAccent,
                            letterSpacing: 0.2,
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Description paragraph
                        Text(
                          destination.longDescription,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Color(0xFFCBD5E1),
                            fontSize: 13.5,
                            height: 1.6,
                          ),
                        ),
                        const SizedBox(height: 22),

                        // Action Buttons: Book Visit Pass + Book Darshan / Tour
                        Wrap(
                          spacing: 12,
                          runSpacing: 10,
                          children: [
                            ElevatedButton.icon(
                              onPressed: () {
                                HapticFeedback.lightImpact();
                                showDestinationBookingModal(context, destination);
                              },
                              icon: const Icon(
                                Icons.confirmation_number_rounded,
                                size: 18,
                                color: AppColors.darkText,
                              ),
                              label: const Text(
                                'Book Monument Entry Pass',
                                style: TextStyle(
                                  color: AppColors.darkText,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 13.5,
                                  letterSpacing: 0.3,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.goldAccent,
                                foregroundColor: AppColors.darkText,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 22, vertical: 15),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 4,
                              ),
                            ),
                            Tooltip(
                              message: 'Book organized Pune Darshan Bus Tour covering this monument and 6 other major Pune heritage landmarks',
                              child: OutlinedButton.icon(
                                onPressed: () {
                                  HapticFeedback.lightImpact();
                                  _safeGo(context, '/darshan');
                                },
                                icon: const Icon(
                                  Icons.directions_bus_rounded,
                                  size: 17,
                                  color: Colors.white,
                                ),
                                label: const Text(
                                  'Book Darshan / Tour',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 13,
                                  ),
                                ),
                                style: OutlinedButton.styleFrom(
                                  backgroundColor: Colors.black.withValues(alpha: 0.3),
                                  side: BorderSide(
                                    color: Colors.white.withValues(alpha: 0.6),
                                    width: 1.2,
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 18, vertical: 15),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Bottom Row: Right Thumbnail & Gallery Badge Stack
                  Align(
                    alignment: Alignment.bottomRight,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.45),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.15),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ...List.generate(
                            imagesList.length.clamp(1, 3),
                            (idx) {
                              final isSelected = idx == _selectedImageIndex;
                              return Padding(
                                padding: const EdgeInsets.only(right: 6),
                                child: InkWell(
                                  onTap: () {
                                    HapticFeedback.selectionClick();
                                    setState(() => _selectedImageIndex = idx);
                                  },
                                  borderRadius: BorderRadius.circular(8),
                                  child: Container(
                                    width: 48,
                                    height: 48,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: isSelected
                                            ? AppColors.goldAccent
                                            : Colors.white24,
                                        width: isSelected ? 2 : 1,
                                      ),
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(6),
                                      child: AppCardImage(
                                        imageUrl: imagesList[idx],
                                        fit: BoxFit.cover,
                                        title: destination.name,
                                        categoryIcon: destination.category.icon,
                                        categoryLabel: destination.category.label,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                          InkWell(
                            onTap: () => _openLightbox(
                                context, imagesList, 0, destination.name),
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 12),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.65),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: Colors.white30,
                                  width: 1,
                                ),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.photo_library_outlined,
                                      size: 15, color: Colors.white),
                                  SizedBox(width: 5),
                                  Text(
                                    'View Gallery +24 Photos',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Floating Quick Info Matrix Card (Desktop & Adaptive) ───────────────────
  Widget _buildFloatingQuickInfoCard(
      Destination dest, bool isDark, bool isFav) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.08),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < 900) {
            return Column(
              children: [
                Row(
                  children: [
                    Expanded(child: _buildQuickStatItem('⏱️', 'Duration', dest.recommendedDuration, isDark)),
                    const SizedBox(width: 8),
                    Expanded(child: _buildQuickStatItem('🧗', 'Difficulty', dest.difficulty.label, isDark)),
                    const SizedBox(width: 8),
                    Expanded(child: _buildQuickStatItem('🚗', 'Distance', '${dest.distanceFromPuneKm.toInt()} km', isDark)),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: _buildQuickStatItem('⛅', 'Best Season', dest.bestTime.split('(').first.trim(), isDark)),
                    const SizedBox(width: 8),
                    Expanded(child: _buildQuickStatItem('⭐', 'Rating', '${dest.rating.toStringAsFixed(1)} (${dest.reviewCount})', isDark)),
                    const SizedBox(width: 8),
                    Expanded(child: _buildSavePlaceButton(dest, isFav, isDark)),
                  ],
                ),
              ],
            );
          }

          return Row(
            children: [
              Expanded(child: _buildQuickStatItem('⏱️', 'Duration', dest.recommendedDuration, isDark)),
              _buildVerticalDivider(isDark),
              Expanded(child: _buildQuickStatItem('🧗', 'Difficulty', dest.difficulty.label, isDark)),
              _buildVerticalDivider(isDark),
              Expanded(child: _buildQuickStatItem('🚗', 'Distance', '${dest.distanceFromPuneKm.toInt()} km', isDark)),
              _buildVerticalDivider(isDark),
              Expanded(child: _buildQuickStatItem('⛅', 'Best Season', dest.bestTime.split('(').first.trim(), isDark)),
              _buildVerticalDivider(isDark),
              Expanded(child: _buildQuickStatItem('⭐', 'Rating', '${dest.rating.toStringAsFixed(1)} (${dest.reviewCount})', isDark)),
              _buildVerticalDivider(isDark),
              _buildSavePlaceButton(dest, isFav, isDark),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSavePlaceButton(Destination dest, bool isFav, bool isDark) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          tooltip: isFav ? 'Saved in favorites' : 'Save place',
          icon: Icon(
            isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
            color: isFav ? const Color(0xFFEF4444) : AppColors.mutedText,
            size: 24,
          ),
          onPressed: () {
            HapticFeedback.mediumImpact();
            ref.read(favoritesProvider.notifier).toggle(dest.id);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(isFav
                    ? 'Removed ${dest.name} from saved places'
                    : 'Saved ${dest.name} to favorites!'),
                backgroundColor: AppColors.deepForest,
                duration: const Duration(seconds: 2),
              ),
            );
          },
        ),
        const Text(
          'Save Place',
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: AppColors.mutedText,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickStatItem(
      String icon, String label, String value, bool isDark) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: isDark
                ? const Color(0xFF0F172A)
                : AppColors.creamBg.withValues(alpha: 0.7),
            shape: BoxShape.circle,
            border: Border.all(
              color: isDark
                  ? const Color(0xFF334155)
                  : AppColors.teal.withValues(alpha: 0.2),
              width: 1,
            ),
          ),
          alignment: Alignment.center,
          child: Text(icon, style: const TextStyle(fontSize: 16)),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 10.5,
                  color: AppColors.mutedText,
                  fontWeight: FontWeight.w700,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w900,
                  color: isDark ? Colors.white : AppColors.darkText,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildVerticalDivider(bool isDark) {
    return Container(
      width: 1,
      height: 36,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
    );
  }

  // ── Destination Tabs Bar ───────────────────────────────────────────────────
  Widget _buildDestinationTabsBar(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: TabBar(
        controller: _tabController,
        onTap: (index) {
          HapticFeedback.selectionClick();
          setState(() {});
        },
        isScrollable: true,
        tabAlignment: TabAlignment.start,
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        physics: const BouncingScrollPhysics(),
        indicator: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF003C36), Color(0xFF0F766E)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0F766E).withValues(alpha: 0.35),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        labelColor: Colors.white,
        unselectedLabelColor:
            isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
        labelStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
        unselectedLabelStyle:
            const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
        tabs: const [
          Tab(text: 'Overview'),
          Tab(text: 'Map View'),
          Tab(text: 'Live Weather'),
          Tab(text: 'Food Spots'),
          Tab(text: 'Reviews'),
          Tab(text: 'Budget'),
          Tab(text: 'Nearby Places'),
        ],
      ),
    );
  }

  // ── Active Tab Content ─────────────────────────────────────────────────────
  Widget _buildActiveTabContent(Destination dest, ThemeData theme, bool isDark,
      List<String> imagesList) {
    switch (_tabController.index) {
      case 1:
        return _buildMapTab(dest, isDark);
      case 2:
        return _buildWeatherTab(dest, ref, isDark);
      case 3:
        return _buildFoodTab(dest, theme, isDark);
      case 4:
        return _buildReviewsTab(dest, ref, theme, isDark);
      case 5:
        return _buildBudgetTab(dest, theme, isDark);
      case 6:
        return _buildNearbyPlacesTab(dest, theme, isDark);
      case 0:
      default:
        return _buildOverviewTab(dest, theme, isDark, imagesList);
    }
  }

  // ── Tab 0: Overview (Contains About, Highlights, Points of Interest, Gallery, Tips) ─
  Widget _buildOverviewTab(Destination dest, ThemeData theme, bool isDark,
      List<String> imagesList) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isMobile = screenWidth < 768;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Small Eyebrow
        Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: AppColors.teal,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            const Flexible(
              child: Text(
                "PUNE'S HERITAGE • OUR PRIDE",
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: AppColors.teal,
                  fontWeight: FontWeight.w900,
                  fontSize: 11.5,
                  letterSpacing: 1.2,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // Section Heading
        Text(
          'About ${dest.name}',
          style: GoogleFonts.playfairDisplay(
            fontSize: 26,
            fontWeight: FontWeight.w800,
            color: isDark ? Colors.white : AppColors.darkText,
          ),
        ),
        const SizedBox(height: 14),

        // Body Text + Quote Card (Row on desktop/tablet, Column on mobile)
        LayoutBuilder(
          builder: (context, constraints) {
            final isNarrow = constraints.maxWidth < 620;
            if (isNarrow) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildAboutDescription(dest, theme, isDark),
                  const SizedBox(height: 16),
                  _buildAboutQuoteCard(dest, isDark),
                ],
              );
            }

            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 60,
                  child: _buildAboutDescription(dest, theme, isDark),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 40,
                  child: _buildAboutQuoteCard(dest, isDark),
                ),
              ],
            );
          },
        ),
        const SizedBox(height: 24),

        // Official Monument Entry & Passes Card
        _buildMonumentEntryTicketsCard(dest, isDark),
        const SizedBox(height: 28),

        // Famous Highlights (2x2 Grid)
        _buildFamousHighlightsSection(dest, isDark),
        const SizedBox(height: 28),

        // Key Points of Interest / Nearby Places (4 cards)
        _buildNearbyPlacesSection(dest, theme, isDark),
        const SizedBox(height: 28),

        // Gallery Row (4 photos with +24 More Photos overlay)
        _buildGalleryRow(dest, imagesList, isDark),

        // On mobile, also render Punekar Tips and Heritage CTA here
        if (isMobile) ...[
          const SizedBox(height: 28),
          _buildPunekarTipsSidebarCard(dest, isDark),
          const SizedBox(height: 20),
          _buildPremiumHeritageCtaCard(dest, isDark),
        ],
      ],
    );
  }

  Widget _buildAboutDescription(Destination dest, ThemeData theme, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _isDescriptionExpanded
              ? dest.longDescription
              : (dest.longDescription.length > 280
                  ? '${dest.longDescription.substring(0, 280)}...'
                  : dest.longDescription),
          style: theme.textTheme.bodyMedium?.copyWith(
            height: 1.7,
            fontSize: 14.5,
            color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF334155),
          ),
        ),
        if (dest.longDescription.length > 280) ...[
          const SizedBox(height: 6),
          InkWell(
            onTap: () => setState(() => _isDescriptionExpanded = !_isDescriptionExpanded),
            borderRadius: BorderRadius.circular(4),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _isDescriptionExpanded ? 'Read Less' : 'Read More',
                    style: const TextStyle(
                      color: AppColors.teal,
                      fontWeight: FontWeight.w800,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    _isDescriptionExpanded
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    color: AppColors.teal,
                    size: 18,
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildAboutQuoteCard(Destination dest, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F2620) : const Color(0xFFF0F7F4),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? const Color(0xFF134E4A) : const Color(0xFFCCECE2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '“',
            style: GoogleFonts.playfairDisplay(
              fontSize: 36,
              color: const Color(0xFF0F766E),
              height: 0.8,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            _getDestinationQuote(dest),
            style: GoogleFonts.inter(
              fontStyle: FontStyle.italic,
              fontSize: 13.5,
              height: 1.5,
              color: isDark ? const Color(0xFFE2E8F0) : const Color(0xFF134E4A),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              _getDestinationQuoteAttribution(dest),
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w700,
                color: isDark ? const Color(0xFF5EEAD4) : const Color(0xFF0F766E),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Official Monument Entry & Tickets Card ─────────────────────────────────
  Widget _buildMonumentEntryTicketsCard(Destination dest, bool isDark) {
    final borderColor = isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
            blurRadius: 12,
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
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.emerald.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.confirmation_number_rounded, color: AppColors.emerald, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Official Monument Entry & Permits',
                      style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14.5),
                    ),
                    Text(
                      'Timings: ${dest.openingHours}',
                      style: const TextStyle(fontSize: 11.5, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Indian Visitors', style: TextStyle(fontSize: 11, color: Colors.grey)),
                      const SizedBox(height: 2),
                      Text(
                        dest.entryFeeIndian == 0 ? 'Free Entry' : '₹${dest.entryFeeIndian.toInt()}',
                        style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: AppColors.emerald),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Foreign Visitors', style: TextStyle(fontSize: 11, color: Colors.grey)),
                      const SizedBox(height: 2),
                      Text(
                        dest.entryFeeForeign > 0
                            ? '₹${dest.entryFeeForeign.toInt()}'
                            : (dest.entryFeeIndian == 0 ? 'Free Entry' : '₹${dest.entryFeeIndian.toInt()} (Standard)'),
                        style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: AppColors.emerald),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: CustomButton(
              text: 'Book Pass for ${dest.name}',
              icon: const Icon(Icons.confirmation_number_outlined, size: 16),
              variant: ButtonVariant.primary,
              height: 44,
              onPressed: () {
                HapticFeedback.lightImpact();
                showDestinationBookingModal(context, dest);
              },
            ),
          ),
        ],
      ),
    );
  }

  // ── Famous Highlights Section ──────────────────────────────────────────────
  Widget _buildFamousHighlightsSection(Destination dest, bool isDark) {
    final highlights = _getDestinationHighlights(dest);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text('⭐', style: TextStyle(fontSize: 18)),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Highlights',
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: isDark ? Colors.white : AppColors.darkText,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const Text(
                    'Famous Highlights',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.mutedText,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        LayoutBuilder(
          builder: (context, constraints) {
            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: highlights.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: constraints.maxWidth < 500 ? 1 : 2,
                childAspectRatio: constraints.maxWidth < 500 ? 3.4 : 2.7,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemBuilder: (context, index) {
                final h = highlights[index];
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E293B) : Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isDark
                          ? const Color(0xFF334155)
                          : const Color(0xFFE2E8F0),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppColors.goldAccent.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.goldAccent.withValues(alpha: 0.4),
                            width: 1,
                          ),
                        ),
                        alignment: Alignment.center,
                        child: Text(h['icon']!, style: const TextStyle(fontSize: 18)),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              h['title']!,
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 13,
                                color: isDark ? Colors.white : AppColors.darkText,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              h['desc']!,
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.mutedText,
                                height: 1.3,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }

  // ── Nearby Places Section ──────────────────────────────────────────────────
  Widget _buildNearbyPlacesSection(Destination dest, ThemeData theme, bool isDark) {
    final nearby = _getNearbyAttractions(dest);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Row(
                children: [
                  const Text('📍', style: TextStyle(fontSize: 18)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Nearby Places',
                          style: GoogleFonts.playfairDisplay(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: isDark ? Colors.white : AppColors.darkText,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const Text(
                          'Key Points of Interest',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.mutedText,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            TextButton(
              onPressed: () => _tabController.animateTo(6),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'View All',
                    style: TextStyle(
                      color: AppColors.teal,
                      fontWeight: FontWeight.w800,
                      fontSize: 13,
                    ),
                  ),
                  SizedBox(width: 4),
                  Icon(Icons.arrow_forward_rounded, size: 14, color: AppColors.teal),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        LayoutBuilder(
          builder: (context, constraints) {
            final isNarrow = constraints.maxWidth < 620;
            if (isNarrow) {
              return SizedBox(
                height: 175,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: nearby.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder: (context, idx) {
                    return SizedBox(
                      width: 170,
                      child: _buildNearbyCard(nearby[idx], isDark),
                    );
                  },
                ),
              );
            }

            return Row(
              children: List.generate(nearby.length, (idx) {
                return Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(right: idx < nearby.length - 1 ? 12 : 0),
                    child: _buildNearbyCard(nearby[idx], isDark),
                  ),
                );
              }),
            );
          },
        ),
      ],
    );
  }

  Widget _buildNearbyCard(AttractionItem att, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(13)),
            child: SizedBox(
              height: 100,
              width: double.infinity,
              child: AppCardImage(
                imageUrl: att.image,
                fit: BoxFit.cover,
                title: att.name,
                categoryIcon: '📍',
                categoryLabel: att.name,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  att.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 12.5,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                Text(
                  '${att.distance} • ${att.travelTime}',
                  style: const TextStyle(
                    color: AppColors.teal,
                    fontWeight: FontWeight.w700,
                    fontSize: 11,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Gallery Row ────────────────────────────────────────────────────────────
  Widget _buildGalleryRow(Destination dest, List<String> imagesList, bool isDark) {
    final galleryImages = _getGalleryImages(dest, imagesList);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Row(
                children: [
                  const Text('📷', style: TextStyle(fontSize: 18)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Gallery',
                          style: GoogleFonts.playfairDisplay(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: isDark ? Colors.white : AppColors.darkText,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          'Moments from ${dest.name}',
                          style: const TextStyle(fontSize: 12, color: AppColors.mutedText),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            TextButton(
              onPressed: () => _openLightbox(context, galleryImages, 0, dest.name),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'View All Photos',
                    style: TextStyle(
                      color: AppColors.teal,
                      fontWeight: FontWeight.w800,
                      fontSize: 13,
                    ),
                  ),
                  SizedBox(width: 4),
                  Icon(Icons.arrow_forward_rounded, size: 14, color: AppColors.teal),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        LayoutBuilder(
          builder: (context, constraints) {
            final isNarrow = constraints.maxWidth < 600;
            if (isNarrow) {
              return SizedBox(
                height: 140,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: 4,
                  separatorBuilder: (_, __) => const SizedBox(width: 10),
                  itemBuilder: (context, idx) {
                    return SizedBox(
                      width: 180,
                      child: _buildGalleryCard(
                        galleryImages[idx % galleryImages.length],
                        idx,
                        idx == 3,
                        dest,
                        galleryImages,
                      ),
                    );
                  },
                ),
              );
            }

            return SizedBox(
              height: 160,
              child: Row(
                children: List.generate(4, (idx) {
                  return Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(right: idx < 3 ? 12 : 0),
                      child: _buildGalleryCard(
                        galleryImages[idx % galleryImages.length],
                        idx,
                        idx == 3,
                        dest,
                        galleryImages,
                      ),
                    ),
                  );
                }),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildGalleryCard(
    String imageUrl,
    int idx,
    bool isLast,
    Destination dest,
    List<String> images,
  ) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: () => _openLightbox(context, images, idx, dest.name),
        child: Stack(
          fit: StackFit.expand,
          children: [
            AppCardImage(
              imageUrl: imageUrl,
              fit: BoxFit.cover,
              title: dest.name,
              categoryIcon: dest.category.icon,
              categoryLabel: dest.category.label,
            ),
            if (isLast)
              Container(
                color: Colors.black.withValues(alpha: 0.55),
                alignment: Alignment.center,
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '+24',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.5,
                      ),
                    ),
                    Text(
                      'More Photos',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              )
            else
              Positioned(
                bottom: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.4),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.zoom_in_rounded, size: 16, color: Colors.white),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ── Right Sidebar Card 1: Location ─────────────────────────────────────────
  Widget _buildLocationSidebarCard(Destination dest, bool isDark) {
    final pos = LatLng(dest.latitude, dest.longitude);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'LOCATION',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.2,
                  color: AppColors.teal,
                ),
              ),
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.emerald.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${dest.distanceFromPuneKm.toInt()} km away',
                    style: const TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w800,
                      color: AppColors.emerald,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            dest.name,
            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
          ),
          Text(
            dest.state.contains('Pune') ? dest.state : '${dest.city}, Maharashtra',
            style: const TextStyle(fontSize: 12.5, color: AppColors.mutedText),
          ),
          const SizedBox(height: 12),

          // Interactive Map Box
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: SizedBox(
              height: 160,
              child: FlutterMap(
                options: MapOptions(
                  initialCenter: pos,
                  initialZoom: 13.5,
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.puneexplorer.app',
                  ),
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: pos,
                        width: 44,
                        height: 44,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: AppColors.goldButtonGradient,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.3),
                                blurRadius: 6,
                                offset: const Offset(0, 3),
                              ),
                            ],
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          alignment: Alignment.center,
                          child:
                              const Text('📍', style: TextStyle(fontSize: 18)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),

          // Real Coordinates Label
          Text(
            'Coordinates: ${dest.latitude.toStringAsFixed(4)}, ${dest.longitude.toStringAsFixed(4)}',
            style: const TextStyle(fontSize: 11, color: AppColors.mutedText),
          ),
          const SizedBox(height: 12),

          // Get Directions Action Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                HapticFeedback.lightImpact();
                _safeGo(context, '/routes');
              },
              icon: const Icon(Icons.directions_rounded, size: 16),
              label: const Text('Get Directions',
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.teal,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Right Sidebar Card 2: Live Weather ─────────────────────────────────────
  Widget _buildLiveWeatherSidebarCard(Destination dest, bool isDark) {
    final weatherAsync = ref.watch(
      destinationWeatherProvider((lat: dest.latitude, lng: dest.longitude)),
    );

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'LIVE WEATHER',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.2,
                  color: AppColors.teal,
                ),
              ),
              const Text(
                'Pune, MH',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppColors.mutedText,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          weatherAsync.when(
            loading: () => const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: CircularProgressIndicator(),
              ),
            ),
            error: (_, __) => const Text('Weather data unavailable.'),
            data: (weather) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Text(weather.weatherIcon,
                              style: const TextStyle(fontSize: 34)),
                          const SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${weather.temperature.round()}°C',
                                style: const TextStyle(
                                  fontSize: 26,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: -0.5,
                                ),
                              ),
                              Text(
                                weather.conditionText,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 13,
                                    color: AppColors.mutedText),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        Expanded(child: _buildWeatherMiniMetric('Feels like', '${weather.feelsLike.round()}°C', isDark)),
                        Expanded(child: _buildWeatherMiniMetric('Humidity', '${weather.humidity}%', isDark)),
                        Expanded(child: _buildWeatherMiniMetric('Wind', '12 km/h', isDark)),
                        Expanded(child: _buildWeatherMiniMetric('Updated', '10:30 AM', isDark)),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildWeatherMiniMetric(String label, String val, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 10, color: AppColors.mutedText, fontWeight: FontWeight.w600),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 2),
        Text(
          val,
          style: TextStyle(
            fontSize: 11.5,
            fontWeight: FontWeight.w800,
            color: isDark ? Colors.white : AppColors.darkText,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  // ── Right Sidebar Card 3: Premium Heritage CTA ─────────────────────────────
  Widget _buildPremiumHeritageCtaCard(Destination dest, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF032B25), Color(0xFF011C18)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.goldAccent.withValues(alpha: 0.4),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF003C36).withValues(alpha: 0.35),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: AppColors.goldAccent.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: const Text('🛕', style: TextStyle(fontSize: 18)),
              ),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: SizedBox(
                  width: 52,
                  height: 36,
                  child: AppCardImage(
                    imageUrl: dest.primaryImage,
                    fit: BoxFit.cover,
                    title: dest.name,
                    categoryIcon: dest.category.icon,
                    categoryLabel: dest.category.label,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Book ${dest.name} Visit Pass',
            style: GoogleFonts.playfairDisplay(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              height: 1.25,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            dest.entryFeeIndian == 0
                ? 'Reserve your free official entrance pass with optional local historian guide.'
                : 'Official entry from ₹${dest.entryFeeIndian.toInt()} • Instant QR pass with optional historian guide.',
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFFCBD5E1),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                HapticFeedback.lightImpact();
                showDestinationBookingModal(context, dest);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.goldAccent,
                foregroundColor: AppColors.darkText,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 2,
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.confirmation_number_rounded,
                      size: 16, color: AppColors.darkText),
                  SizedBox(width: 6),
                  Text(
                    'Book Visit Pass',
                    style: TextStyle(
                      color: AppColors.darkText,
                      fontWeight: FontWeight.w900,
                      fontSize: 13,
                    ),
                  ),
                  SizedBox(width: 4),
                  Icon(Icons.arrow_forward_rounded,
                      size: 15, color: AppColors.darkText),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Right Sidebar Card 4: Punekar Explorer Tips ────────────────────────────
  Widget _buildPunekarTipsSidebarCard(Destination dest, bool isDark) {
    final tip = dest.travelTips.isNotEmpty
        ? dest.travelTips.first
        : 'Early morning 6:30 AM Aarti is peaceful with minimal waiting queues.';

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF272115) : const Color(0xFFFFFBEB),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark ? const Color(0xFF78350F) : const Color(0xFFFDE68A),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('💡', style: TextStyle(fontSize: 18)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Punekar Explorer Tips',
                  style: GoogleFonts.inter(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w800,
                    color: isDark ? AppColors.goldAccent : const Color(0xFFB45309),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '• ',
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  color: isDark ? AppColors.goldAccent : const Color(0xFFD97706),
                ),
              ),
              Expanded(
                child: Text(
                  tip,
                  style: TextStyle(
                    fontSize: 12.5,
                    height: 1.45,
                    color: isDark ? const Color(0xFFE2E8F0) : const Color(0xFF451A03),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // ── MOBILE ANDROID LAYOUT (Width < 768px) ──────────────────────────────────
  // ===========================================================================
  Widget _buildMobileLayout(
    Destination destination,
    ThemeData theme,
    bool isDark,
    bool isFav,
    double screenWidth,
  ) {
    final imagesList = destination.images.isNotEmpty
        ? destination.images
        : [destination.primaryImage];

    return CustomScrollView(
      slivers: [
        // 1. Mobile Compact Header (Dark Green)
        SliverAppBar(
          pinned: true,
          elevation: 0,
          backgroundColor: AppColors.deepForest,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded,
                color: Colors.white, size: 22),
            onPressed: () {
              if (Navigator.of(context).canPop()) {
                Navigator.of(context).pop();
              } else {
                _safeGo(context, '/explore');
              }
            },
          ),
          title: Text(
            destination.name,
            style: GoogleFonts.playfairDisplay(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.search_rounded,
                  color: Colors.white, size: 20),
              onPressed: () => showDialog(
                context: context,
                builder: (_) => const OmniSearchDialog(),
              ),
            ),
            IconButton(
              icon: Icon(
                isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                color: isFav ? const Color(0xFFEF4444) : Colors.white,
                size: 20,
              ),
              onPressed: () {
                HapticFeedback.mediumImpact();
                ref
                    .read(favoritesProvider.notifier)
                    .toggle(widget.destinationId);
              },
            ),
            IconButton(
              icon: const Icon(Icons.share_rounded,
                  color: Colors.white, size: 20),
              onPressed: () {
                HapticFeedback.lightImpact();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Sharing guide for ${destination.name}...'),
                    backgroundColor: AppColors.deepForest,
                  ),
                );
              },
            ),
            const SizedBox(width: 4),
          ],
        ),

        // 2. Full-Width Mobile Hero Section
        SliverToBoxAdapter(
          child: _buildMobileHeroSection(destination, imagesList, isDark),
        ),

        // 3. Mobile Content Body
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Quick Stats Card (2-column layout)
                _buildMobileQuickStatsCard(destination, isDark),
                const SizedBox(height: 16),

                // Mobile Tab Navigation
                _buildDestinationTabsBar(isDark),
                const SizedBox(height: 16),

                // Active Tab Content View (renders ONLY the selected tab view)
                _buildActiveTabContent(
                    destination, theme, isDark, imagesList),

                // Bottom clearance for floating action dock
                const SizedBox(height: 85),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ── Mobile Hero Section ────────────────────────────────────────────────────
  Widget _buildMobileHeroSection(
      Destination destination, List<String> imagesList, bool isDark) {
    final activeImage = imagesList[_selectedImageIndex % imagesList.length];

    return Stack(
      children: [
        // Active Hero Image
        SizedBox(
          height: 340,
          width: double.infinity,
          child: AppCardImage(
            imageUrl: activeImage,
            heroTag: 'dest_img_${destination.id}',
            categoryIcon: destination.category.icon,
            categoryLabel: destination.category.label,
            title: destination.name,
            fit: BoxFit.cover,
          ),
        ),

        // Overlay Gradient
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.15),
                  const Color(0xFF003C36).withValues(alpha: 0.85),
                  const Color(0xFF003C36),
                ],
                stops: const [0.0, 0.35, 0.75, 1.0],
              ),
            ),
          ),
        ),

        // Floating 3D Altitude/Weather Badge (Top-Right)
        Positioned(
          top: 12,
          right: 14,
          child: Floating3DWeatherAltitudeBadge(
            altitude:
                '${((destination.latitude * 72).abs().toInt() + 450)}m Alt',
            weather: '26°C Pleasant',
            weatherIcon: '⛅',
          ),
        ),

        // Mobile Hero Details (Clean, non-colliding layout)
        Positioned(
          bottom: 12,
          left: 14,
          right: 14,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Location Pill & Royal Badges Row
              Wrap(
                spacing: 6,
                runSpacing: 6,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
                    decoration: BoxDecoration(
                      color: AppColors.teal.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                          color: AppColors.teal.withValues(alpha: 0.7), width: 1),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.location_on_rounded,
                            color: AppColors.goldAccent, size: 12),
                        const SizedBox(width: 3),
                        Text(
                          destination.state,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
                    decoration: BoxDecoration(
                      color: AppColors.goldAccent.withValues(alpha: 0.25),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      destination.category.label,
                      style: const TextStyle(
                        color: AppColors.goldAccent,
                        fontSize: 10.5,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  if (destination.isTrending)
                    Container(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF059669), Color(0xFF047857)],
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        '🔥 Trending in Pune',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10.5,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  const RoyalMarathaCrestBadge(
                    label: 'Maratha Heritage',
                    icon: '👑',
                    accentColor: AppColors.goldAccent,
                  ),
                ],
              ),
              const SizedBox(height: 6),

              // Title
              Text(
                destination.name,
                style: GoogleFonts.playfairDisplay(
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: -0.3,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),

              // Subtitle
              const Text(
                'A Glimpse into Pune’s Glorious Past',
                style: TextStyle(
                  color: AppColors.goldAccent,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 10),

              // Thumbnail strip
              if (imagesList.length > 1)
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: List.generate(imagesList.length, (idx) {
                      return Floating3DImageThumbnail(
                        imageUrl: imagesList[idx],
                        isSelected: idx == _selectedImageIndex,
                        categoryIcon: destination.category.icon,
                        categoryLabel: destination.category.label,
                        onTap: () => setState(() => _selectedImageIndex = idx),
                      );
                    }),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  // ── Mobile Quick Stats Card ────────────────────────────────────────────────
  Widget _buildMobileQuickStatsCard(Destination dest, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildMobileStatPill(
                  '⏱️',
                  'Duration',
                  dest.recommendedDuration,
                  const Color(0xFF0F766E),
                  isDark,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildMobileStatPill(
                  '🧗',
                  'Difficulty',
                  dest.difficulty.label,
                  const Color(0xFFD97706),
                  isDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _buildMobileStatPill(
                  '🚗',
                  'Distance',
                  '${dest.distanceFromPuneKm.toInt()} km',
                  const Color(0xFF059669),
                  isDark,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildMobileStatPill(
                  '⛅',
                  'Best Season',
                  dest.bestTime.split('(').first.trim(),
                  const Color(0xFF7C3AED),
                  isDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDark
                    ? [const Color(0xFF0F172A), const Color(0xFF1E293B)]
                    : [
                        const Color(0xFFFFFBEB),
                        const Color(0xFFFEF3C7).withValues(alpha: 0.5)
                      ],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.amber.withValues(alpha: isDark ? 0.35 : 0.5),
                width: 1,
              ),
            ),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.star_rounded,
                      color: AppColors.amber, size: 20),
                  const SizedBox(width: 4),
                  Text(
                    '${dest.rating.toStringAsFixed(1)} ',
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 13.5,
                      color: isDark ? Colors.white : AppColors.darkText,
                    ),
                  ),
                  Text(
                    '(${dest.reviewCount} reviews)',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isDark
                          ? const Color(0xFF94A3B8)
                          : const Color(0xFF64748B),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.amber.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      '★ Punekar Verified',
                      style: TextStyle(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFFB45309),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileStatPill(
      String icon, String label, String val, Color accentColor, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF0F172A)
            : accentColor.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark
              ? const Color(0xFF334155)
              : accentColor.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: isDark ? 0.25 : 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            alignment: Alignment.center,
            child: Text(icon, style: const TextStyle(fontSize: 14)),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: AppColors.mutedText,
                    letterSpacing: 0.2,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 1),
                Text(
                  val,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    color: isDark ? Colors.white : AppColors.darkText,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }


  // ── Mobile Bottom Navigation Dock ──────────────────────────────────────────
  Widget _buildMobileBottomDock(
      Destination dest, bool isDark, BuildContext context) {
    final isSmall = Breakpoints.isSmallPhone(context);

    return Container(
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF0F172A).withValues(alpha: 0.96)
            : Colors.white.withValues(alpha: 0.98),
        border: Border(
          top: BorderSide(
            color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.08),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: isSmall ? 12 : 16,
            vertical: isSmall ? 8 : 10,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Price & Fee Details
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Entry Pass / Fee',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.mutedText,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        dest.entryFeeIndian == 0
                            ? 'Free Entry'
                            : '₹${dest.entryFeeIndian.toInt()}',
                        style: const TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.w900,
                          color: AppColors.emerald,
                          letterSpacing: -0.3,
                        ),
                      ),
                      if (dest.entryFeeIndian > 0) ...[
                        const SizedBox(width: 3),
                        Text(
                          '/ person',
                          style: TextStyle(
                            fontSize: 10,
                            color: isDark
                                ? const Color(0xFF94A3B8)
                                : const Color(0xFF64748B),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
              const SizedBox(width: 8),

              // Action Buttons
              Flexible(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: CustomButton(
                        text: isSmall ? 'Book Pass' : 'Book Entry Pass',
                        icon: const Icon(Icons.confirmation_number_outlined,
                            size: 16),
                        variant: ButtonVariant.primary,
                        height: 42,
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          showDestinationBookingModal(context, dest);
                        },
                      ),
                    ),
                    const SizedBox(width: 4),
                    IconButton(
                      tooltip: 'Pune Darshan Full Tour',
                      icon: const Icon(
                        Icons.directions_bus_outlined,
                        size: 20,
                        color: AppColors.emerald,
                      ),
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        _safeGo(context, '/darshan');
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ===========================================================================
  // ── TAB VIEWS IMPLEMENTATIONS ──────────────────────────────────────────────
  // ===========================================================================

  // ── Tab 1: Map View ────────────────────────────────────────────────────────
  Widget _buildMapTab(Destination dest, bool isDark) {
    final pos = LatLng(dest.latitude, dest.longitude);

    return SizedBox(
      height: 380,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            FlutterMap(
              options: MapOptions(
                initialCenter: pos,
                initialZoom: 13.5,
              ),
              children: [
                TileLayer(
                  urlTemplate:
                      'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.puneexplorer.app',
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: pos,
                      width: 52,
                      height: 52,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: AppColors.goldButtonGradient,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.4),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                          border: Border.all(color: Colors.white, width: 2.5),
                        ),
                        alignment: Alignment.center,
                        child: const Text('📍', style: TextStyle(fontSize: 22)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            // Glassmorphic Map HUD Overlay
            Positioned(
              top: 12,
              left: 12,
              right: 12,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: (isDark ? const Color(0xFF0F172A) : Colors.white)
                          .withValues(alpha: 0.85),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: AppColors.goldAccent.withValues(alpha: 0.4),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Coordinates: ${dest.latitude.toStringAsFixed(4)}, ${dest.longitude.toStringAsFixed(4)}',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: isDark
                                      ? AppColors.darkTextSecondary
                                      : AppColors.lightTextSecondary,
                                  fontWeight: FontWeight.w600,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${dest.distanceFromPuneKm.toInt()} km from Pune',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w900,
                                  color: AppColors.emerald,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () {
                            HapticFeedback.lightImpact();
                            _safeGo(context, '/routes');
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.teal,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 6),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8)),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.directions_rounded, size: 14),
                              SizedBox(width: 4),
                              Text('Directions',
                                  style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w800)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Tab 2: Weather ─────────────────────────────────────────────────────────
  Widget _buildWeatherTab(Destination dest, WidgetRef ref, bool isDark) {
    final weatherAsync = ref.watch(
      destinationWeatherProvider((lat: dest.latitude, lng: dest.longitude)),
    );

    return weatherAsync.when(
      loading: () => const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: CircularProgressIndicator(),
        ),
      ),
      error: (_, __) => const Center(child: Text('Weather data unavailable.')),
      data: (weather) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Weather Station Display Card
            RoyalSahyadriBevelCard(
              isDark: isDark,
              isHighlighted: true,
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${weather.temperature.round()}°C',
                        style: const TextStyle(
                          fontSize: 42,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -1,
                        ),
                      ),
                      Text(
                        weather.conditionText,
                        style: const TextStyle(
                            fontWeight: FontWeight.w800, fontSize: 15),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Feels like ${weather.feelsLike.round()}°C • Humidity ${weather.humidity}%',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.lightTextSecondary,
                        ),
                      ),
                    ],
                  ),
                  Text(weather.weatherIcon,
                      style: const TextStyle(fontSize: 54)),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Trek Advisory Card
            RoyalSahyadriBevelCard(
              isDark: isDark,
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.goldAccent.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Text('💡', style: TextStyle(fontSize: 20)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      weather.trekAdvice,
                      style: const TextStyle(
                          fontSize: 12.5,
                          height: 1.4,
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // 7-Day Forecast Section
            const Text(
              '7-Day Forecast',
              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 124,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: weather.dailyForecasts.length,
                separatorBuilder: (_, __) => const SizedBox(width: 10),
                itemBuilder: (context, index) {
                  final day = weather.dailyForecasts[index];
                  return RoyalSahyadriBevelCard(
                    isDark: isDark,
                    padding: const EdgeInsets.all(10),
                    child: SizedBox(
                      width: 68,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            day.date,
                            style: TextStyle(
                              fontSize: 11,
                              color: isDark
                                  ? AppColors.darkTextMuted
                                  : AppColors.lightTextMuted,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(day.weatherIcon,
                              style: const TextStyle(fontSize: 24)),
                          const SizedBox(height: 6),
                          Text(
                            '${day.maxTemp.round()}° / ${day.minTemp.round()}°',
                            style: const TextStyle(
                                fontSize: 11, fontWeight: FontWeight.w800),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  // ── Tab 3: Food Spots ──────────────────────────────────────────────────────
  Widget _buildFoodTab(Destination dest, ThemeData theme, bool isDark) {
    final foodList = dest.foods.isNotEmpty
        ? dest.foods
        : [
            const FoodSpot(
              name: 'Puneri Misal Pav',
              description: 'Authentic fiery sprouted moth beans curry with farsan',
              price: '₹90',
              category: 'Snack',
              isVeg: true,
              image:
                  'https://images.unsplash.com/photo-1601050690597-df0568f70950?q=80&w=400',
            ),
            const FoodSpot(
              name: 'Sujata Mastani',
              description: 'Rich thick mango ice cream shake beverage',
              price: '₹120',
              category: 'Dessert',
              isVeg: true,
              image:
                  'https://images.unsplash.com/photo-1504674900247-0877df9cc836?q=80&w=400',
            ),
          ];

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: foodList.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final food = foodList[index];
        return RoyalSahyadriBevelCard(
          isDark: isDark,
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              AppCardImage(
                imageUrl: food.image,
                width: 76,
                height: 76,
                borderRadius: BorderRadius.circular(14),
                categoryIcon: '🍽️',
                categoryLabel: food.name,
                fit: BoxFit.cover,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Text(
                            food.name,
                            style: const TextStyle(
                                fontWeight: FontWeight.w900, fontSize: 14),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          food.price,
                          style: const TextStyle(
                            color: AppColors.emerald,
                            fontWeight: FontWeight.w900,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: (food.isVeg
                                ? AppColors.emerald
                                : const Color(0xFFDC2626))
                            .withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                          color: (food.isVeg
                                  ? AppColors.emerald
                                  : const Color(0xFFDC2626))
                              .withValues(alpha: 0.4),
                          width: 0.8,
                        ),
                      ),
                      child: Text(
                        food.isVeg ? '🌱 Puneri Veg' : '🍗 Non-Veg',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: food.isVeg
                              ? AppColors.emerald
                              : const Color(0xFFDC2626),
                        ),
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      food.description,
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.lightTextSecondary,
                        height: 1.35,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ── Tab 4: Reviews ─────────────────────────────────────────────────────────
  Widget _buildReviewsTab(
      Destination dest, WidgetRef ref, ThemeData theme, bool isDark) {
    final reviewsAsync = ref.watch(destinationReviewsProvider(dest.id));

    return reviewsAsync.when(
      loading: () => const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: CircularProgressIndicator(),
        ),
      ),
      error: (e, _) => Center(child: Text('Error loading reviews: $e')),
      data: (reviews) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with Title & Add Review Button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      const Icon(Icons.star_rounded,
                          color: AppColors.amber, size: 24),
                      const SizedBox(width: 4),
                      Text(
                        dest.rating.toStringAsFixed(1),
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.w900),
                      ),
                      Flexible(
                        child: Text(
                          ' (${dest.reviewCount} total)',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: isDark
                                ? AppColors.darkTextSecondary
                                : AppColors.lightTextSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: () => _showAddReviewDialog(context, dest.id),
                  icon: const Icon(Icons.edit_rounded, size: 14),
                  label: const Text('Add Review'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.teal,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 8),
                    textStyle: const TextStyle(
                        fontSize: 12, fontWeight: FontWeight.w800),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // 3D Rating Gauge Breakdown with 5-star distribution
            Royal3DRatingGauge(
              rating: dest.rating,
              totalReviews: dest.reviewCount,
              isDark: isDark,
            ),
            const SizedBox(height: 16),

            // Reviews List
            if (reviews.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Center(
                    child: Text('Be the first to review this landmark!')),
              )
            else
              ...reviews.map(
                (rev) => RoyalSahyadriBevelCard(
                  isDark: isDark,
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: AppColors.teal,
                            radius: 15,
                            child: Text(
                              rev.authorAvatar,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  rev.authorName,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 13.5),
                                ),
                                Row(
                                  children: List.generate(
                                    5,
                                    (idx) => Icon(
                                      idx < rev.rating
                                          ? Icons.star_rounded
                                          : Icons.star_border_rounded,
                                      color: AppColors.amber,
                                      size: 13,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            rev.date,
                            style: TextStyle(
                              fontSize: 11,
                              color: isDark
                                  ? AppColors.darkTextMuted
                                  : AppColors.lightTextMuted,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        rev.comment,
                        style: TextStyle(
                          fontSize: 12.5,
                          color: isDark
                              ? const Color(0xFFE2E8F0)
                              : const Color(0xFF334155),
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  // ── Tab 5: Budget ──────────────────────────────────────────────────────────
  Widget _buildBudgetTab(Destination dest, ThemeData theme, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Estimated Trip Budget per Person',
          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14),
        ),
        const SizedBox(height: 12),
        LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth < 460) {
              return Column(
                children: [
                  _buildBudgetCard('🎒 Backpacker', '₹400 – ₹800',
                      'Local Bus + Fort Snack', isDark, false),
                  const SizedBox(height: 8),
                  _buildBudgetCard('🚗 Moderate', '₹1,200 – ₹2,500',
                      'Cab + Meals + Entry', isDark, false),
                  const SizedBox(height: 8),
                  _buildBudgetCard('👑 Royal Luxury', '₹4,000+',
                      'Resort Stay + Private Car', isDark, true),
                ],
              );
            }
            return Row(
              children: [
                Expanded(
                    child: _buildBudgetCard('🎒 Backpacker', '₹400 – ₹800',
                        'Local Bus + Fort Snack', isDark, false)),
                const SizedBox(width: 8),
                Expanded(
                    child: _buildBudgetCard('🚗 Moderate', '₹1,200 – ₹2,500',
                        'Cab + Meals + Entry', isDark, false)),
                const SizedBox(width: 8),
                Expanded(
                    child: _buildBudgetCard('👑 Royal Luxury', '₹4,000+',
                        'Resort Stay + Private Car', isDark, true)),
              ],
            );
          },
        ),
        const SizedBox(height: 22),

        // Recommended Accommodations
        if (dest.hotels.isNotEmpty) ...[
          const Text(
            'Recommended Nearby Accommodations',
            style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14),
          ),
          const SizedBox(height: 12),
          ...dest.hotels.map(
            (h) => RoyalSahyadriBevelCard(
              isDark: isDark,
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  AppCardImage(
                    imageUrl: h.image,
                    width: 76,
                    height: 76,
                    borderRadius: BorderRadius.circular(14),
                    categoryIcon: '🏨',
                    categoryLabel: h.name,
                    fit: BoxFit.cover,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          h.name,
                          style: const TextStyle(
                              fontWeight: FontWeight.w900, fontSize: 13.5),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          h.description,
                          style: TextStyle(
                            fontSize: 11,
                            color: isDark
                                ? AppColors.darkTextSecondary
                                : AppColors.lightTextSecondary,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '₹${h.pricePerNight.toInt()} / night • ${h.distance}',
                          style: const TextStyle(
                            color: AppColors.emerald,
                            fontWeight: FontWeight.w900,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildBudgetCard(String title, String cost, String desc, bool isDark,
      bool isHighlighted) {
    return RoyalSahyadriBevelCard(
      isDark: isDark,
      isHighlighted: isHighlighted,
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  title,
                  style: const TextStyle(
                      fontWeight: FontWeight.w900, fontSize: 12),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (isHighlighted)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                  decoration: BoxDecoration(
                    color: AppColors.goldAccent,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'POPULAR',
                    style: TextStyle(
                        fontSize: 8,
                        fontWeight: FontWeight.w900,
                        color: Colors.black),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            cost,
            style: const TextStyle(
              color: AppColors.emerald,
              fontWeight: FontWeight.w900,
              fontSize: 13.5,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            desc,
            style: TextStyle(
              fontSize: 10,
              color:
                  isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
            ),
          ),
        ],
      ),
    );
  }

  // ── Tab 6: Nearby Places ───────────────────────────────────────────────────
  Widget _buildNearbyPlacesTab(
      Destination dest, ThemeData theme, bool isDark) {
    if (dest.attractions.isEmpty) {
      return const Center(child: Text('No nearby attractions listed.'));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Key Points of Interest',
          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14),
        ),
        const SizedBox(height: 12),
        ...dest.attractions.map(
          (att) => RoyalSahyadriBevelCard(
            isDark: isDark,
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                AppCardImage(
                  imageUrl: att.image,
                  width: 72,
                  height: 72,
                  borderRadius: BorderRadius.circular(12),
                  categoryIcon: '📍',
                  categoryLabel: att.name,
                  fit: BoxFit.cover,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        att.name,
                        style: const TextStyle(
                            fontWeight: FontWeight.w900, fontSize: 14),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        att.description,
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.lightTextSecondary,
                          height: 1.35,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${att.distance} • ${att.travelTime}',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppColors.teal,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ── Review Dialog ────────────────────────────────────────────────────────────
class _AddReviewDialogWidget extends StatefulWidget {
  final String destinationId;
  final WidgetRef ref;

  const _AddReviewDialogWidget(
      {required this.destinationId, required this.ref});

  @override
  State<_AddReviewDialogWidget> createState() => _AddReviewDialogWidgetState();
}

class _AddReviewDialogWidgetState extends State<_AddReviewDialogWidget> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _commentCtrl;
  double _rating = 5.0;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController();
    _commentCtrl = TextEditingController();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _commentCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return AlertDialog(
      backgroundColor: isDark ? const Color(0xFF0F172A) : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: const BorderSide(color: AppColors.goldAccent, width: 1.2),
      ),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: AppColors.goldAccent.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Text('⭐', style: TextStyle(fontSize: 18)),
          ),
          const SizedBox(width: 10),
          const Text(
            'Write a Review',
            style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Rate your experience:',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (idx) {
                final isFilled = idx < _rating;
                return Semantics(
                  label: '${idx + 1} Stars',
                  child: IconButton(
                    icon: Icon(
                      isFilled
                          ? Icons.star_rounded
                          : Icons.star_border_rounded,
                      color: AppColors.amber,
                      size: 34,
                    ),
                    onPressed: () {
                      HapticFeedback.selectionClick();
                      setState(() => _rating = idx + 1.0);
                    },
                  ),
                );
              }),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _nameCtrl,
              decoration: InputDecoration(
                labelText: 'Your Name',
                hintText: 'e.g. Rahul Patil',
                prefixIcon: const Icon(Icons.person_outline_rounded,
                    color: AppColors.teal),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      const BorderSide(color: AppColors.teal, width: 1.5),
                ),
              ),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _commentCtrl,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'Your Review',
                hintText: 'Share tips about the trail, food, or sunset views...',
                prefixIcon: const Icon(Icons.edit_note_rounded,
                    color: AppColors.teal),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      const BorderSide(color: AppColors.teal, width: 1.5),
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('Cancel',
              style:
                  TextStyle(color: isDark ? Colors.white70 : Colors.black54)),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.teal,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
          ),
          onPressed: () {
            if (_commentCtrl.text.trim().isNotEmpty) {
              HapticFeedback.mediumImpact();
              final rev = Review(
                id: 'rev_${DateTime.now().millisecondsSinceEpoch}',
                destinationId: widget.destinationId,
                authorName: _nameCtrl.text.trim().isEmpty
                    ? 'Punekar Explorer'
                    : _nameCtrl.text.trim(),
                authorAvatar: _nameCtrl.text.trim().isEmpty
                    ? 'PE'
                    : _nameCtrl.text.trim().substring(0, 2).toUpperCase(),
                rating: _rating,
                comment: _commentCtrl.text.trim(),
                date: 'August 2026',
              );
              widget.ref.read(destinationRepositoryProvider).addReview(rev);
              widget.ref
                  .invalidate(destinationReviewsProvider(widget.destinationId));
              final messenger = ScaffoldMessenger.maybeOf(context);
              Navigator.of(context).pop();
              messenger?.showSnackBar(
                const SnackBar(
                  content: Text('✨ Thank you! Your review has been submitted.'),
                  backgroundColor: AppColors.teal,
                ),
              );
            }
          },
          child: const Text('Submit Review',
              style: TextStyle(fontWeight: FontWeight.w800)),
        ),
      ],
    );
  }
}
