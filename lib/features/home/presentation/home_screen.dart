import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/responsive/responsive_builder.dart';
import '../../../core/widgets/skeleton_loader.dart';
import '../../../core/widgets/error_boundary.dart';
import '../../../core/widgets/app_network_image.dart';
import 'widgets/hero_carousel.dart';
import 'widgets/home_search_bar.dart';
import 'widgets/category_section.dart';
import 'widgets/destination_multi_view_section.dart';
import 'widgets/darshan_highlight_card.dart';
import 'widgets/history_timeline_section.dart';
import 'widgets/testimonials_faq_section.dart';
import 'widgets/home_footer.dart';
import '../../heritage_walks/presentation/widgets/heritage_walk_card.dart';
import '../../../data/models/tour_package.dart';
import '../../../data/models/cms_models.dart';

bool get _isTestEnv =>
    WidgetsBinding.instance.runtimeType.toString().contains('Test') ||
    const bool.fromEnvironment('FLUTTER_TEST');

/// Production-Grade Home Screen with Staggered Entrance Animation
/// and Responsive Pune Travel Design System
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _entranceController;
  late Animation<double> _heroAnim;
  late Animation<double> _searchAnim;
  late Animation<double> _categoryAnim;
  late Animation<double> _darshanAnim;
  late Animation<double> _trendingAnim;
  late Animation<double> _bodyAnim;

  @override
  void initState() {
    super.initState();
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _heroAnim = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.0, 0.45, curve: Curves.easeOutCubic),
    );
    _searchAnim = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.18, 0.55, curve: Curves.easeOutCubic),
    );
    _categoryAnim = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.32, 0.68, curve: Curves.easeOutCubic),
    );
    _darshanAnim = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.45, 0.80, curve: Curves.easeOutCubic),
    );
    _trendingAnim = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.58, 0.90, curve: Curves.easeOutCubic),
    );
    _bodyAnim = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.70, 1.0, curve: Curves.easeOutCubic),
    );

    if (_isTestEnv) {
      _entranceController.value = 1.0;
    } else {
      _entranceController.forward();
    }
  }

  @override
  void dispose() {
    _entranceController.dispose();
    super.dispose();
  }

  Widget _buildAnimatedSection({
    required Animation<double> animation,
    required Widget child,
    double slideDistance = 18.0,
  }) {
    if (_isTestEnv) return child;
    return AnimatedBuilder(
      animation: animation,
      builder: (context, c) {
        final val = animation.value.clamp(0.0, 1.0);
        return Opacity(
          opacity: val,
          child: Transform.translate(
            offset: Offset(0, (1.0 - val) * slideDistance),
            child: c,
          ),
        );
      },
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final destinationsAsync = ref.watch(destinationsAsyncProvider);
    final tourPackagesAsync = ref.watch(tourPackagesAsyncProvider);
    final heritageWalksAsync = ref.watch(heritageWalksAsyncProvider);
    final trending = ref.watch(trendingDestinationsProvider);
    final heroDestinations = ref.watch(featuredDestinationsProvider);
    final cms = ref.watch(homepageCmsProvider).value ?? const HomepageCmsConfig();
    final cfg = cms.sectionConfig;

    return Scaffold(
      body: SafeArea(
        top: false,
        child: destinationsAsync.when(
          data: (destinations) {
            final activeHeroDestinations = heroDestinations.isNotEmpty
                ? heroDestinations
                : destinations.take(4).toList();

            return RefreshIndicator(
              color: AppColors.emerald,
              onRefresh: () async {
                HapticFeedback.lightImpact();
                ref.invalidate(destinationsAsyncProvider);
                ref.invalidate(tourPackagesAsyncProvider);
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Emergency Advisory Banner (CMS Managed)
                    if (cms.showNoticeBanner && cms.noticeBanner.isNotEmpty)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        color: AppColors.saffron,
                        child: Row(
                          children: [
                            const Icon(Icons.campaign_rounded, color: Colors.white, size: 20),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                cms.noticeBanner,
                                style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
                              ),
                            ),
                          ],
                        ),
                      ),

                    // 1. Hero Carousel with Editorial Travel Branding & 3D Badges
                    if (cfg.showHero)
                      _buildAnimatedSection(
                        animation: _heroAnim,
                        slideDistance: 0.0,
                        child: HeroCarousel(
                          destinations: activeHeroDestinations,
                        ),
                      ),

                    // MaxWidthWrapper for responsive layout
                    MaxWidthWrapper(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 2. Search Bar with Quick Suggestion Chips
                          if (cfg.showSearch) ...[
                            _buildAnimatedSection(
                              animation: _searchAnim,
                              child: const HomeSearchBar(),
                            ),
                            const SizedBox(height: 28),
                          ],

                          // 3. Category Selector Section
                          if (cfg.showCategories) ...[
                            _buildAnimatedSection(
                              animation: _categoryAnim,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: _buildSectionTitle('Explore by Experience', 'Sahyadri & Pune themes', theme),
                                      ),
                                      const SizedBox(width: 8),
                                      TextButton.icon(
                                        onPressed: () {
                                          HapticFeedback.selectionClick();
                                          context.go('/explore');
                                        },
                                        icon: const Icon(Icons.arrow_forward_rounded, size: 16),
                                        label: const Text('View All'),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  const CategorySection(),
                                ],
                              ),
                            ),
                            const SizedBox(height: 32),
                          ],

                          // 4. Pune Darshan Feature Card
                          if (cfg.showDarshanSpotlight) ...[
                            _buildAnimatedSection(
                              animation: _darshanAnim,
                              child: const DarshanHighlightCard(),
                            ),
                            const SizedBox(height: 36),
                          ],

                          // 5. Multi-View Trending Destinations Section (Grid / Detailed / Compact + Quick View)
                          if (cfg.showTrendingDestinations) ...[
                            _buildAnimatedSection(
                              animation: _trendingAnim,
                              child: DestinationMultiViewSection(
                                destinations: trending,
                                totalCount: trending.length,
                              ),
                            ),
                            const SizedBox(height: 36),
                          ],

                          // 6. Walk Through Pune — Curated Heritage Walks Showcase
                          _buildAnimatedSection(
                            animation: _bodyAnim,
                            child: heritageWalksAsync.when(
                              data: (walks) => Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: _buildSectionTitle('Walk Through Pune', '🏛️ Curated Heritage & Story Trails', theme),
                                      ),
                                      const SizedBox(width: 8),
                                      TextButton.icon(
                                        onPressed: () {
                                          HapticFeedback.selectionClick();
                                          context.go('/walks');
                                        },
                                        icon: const Icon(Icons.arrow_forward_rounded, size: 16),
                                        label: const Text('All Walks'),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 14),
                                  LayoutBuilder(
                                    builder: (context, constraints) {
                                      final availableWidth = constraints.maxWidth;
                                      final textScale = MediaQuery.textScalerOf(context).scale(1.0);

                                      // Dynamic card width calculation based on available width:
                                      // Large Desktop (>= 1200): 4 cards visible with comfortable peek
                                      // Medium Desktop / Tablet landscape (>= 900): 3 cards visible
                                      // Tablet portrait (>= 600): 2 cards visible
                                      // Mobile (< 600): 1 full card + intentional partial preview for clear scroll affordance
                                      final double cardWidth;
                                      if (availableWidth >= 1200) {
                                        cardWidth = ((availableWidth - 3 * 16) / 4.15).clamp(260.0, 360.0);
                                      } else if (availableWidth >= 900) {
                                        cardWidth = ((availableWidth - 2 * 16) / 3.2).clamp(260.0, 340.0);
                                      } else if (availableWidth >= 600) {
                                        cardWidth = ((availableWidth - 16) / 2.25).clamp(250.0, 340.0);
                                      } else if (availableWidth < 340) {
                                        cardWidth = (availableWidth * 0.90).clamp(245.0, 320.0);
                                      } else {
                                        cardWidth = ((availableWidth - 16) * 0.84).clamp(240.0, 320.0);
                                      }

                                      final carouselHeight = (435.0 * textScale).clamp(425.0, 600.0);

                                      return SizedBox(
                                        height: carouselHeight,
                                        child: ListView.separated(
                                          scrollDirection: Axis.horizontal,
                                          physics: const BouncingScrollPhysics(),
                                          itemCount: walks.length,
                                          separatorBuilder: (_, __) => const SizedBox(width: 16),
                                          itemBuilder: (context, index) {
                                            final walk = walks[index];
                                            return SizedBox(
                                              width: cardWidth,
                                              child: Align(
                                                alignment: Alignment.topCenter,
                                                child: HeritageWalkCard(
                                                  walk: walk,
                                                  variant: HeritageWalkCardVariant.compact,
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                              loading: () => const Padding(
                                padding: EdgeInsets.symmetric(vertical: 24),
                                child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
                              ),
                              error: (e, _) => Padding(
                                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
                                child: Container(
                                  padding: const EdgeInsets.all(14),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFEF2F2),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: const Color(0xFFFECACA)),
                                  ),
                                  child: const Row(
                                    children: [
                                      Icon(Icons.info_outline_rounded, color: Color(0xFFEF4444), size: 18),
                                      SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          'Heritage walks could not be loaded. Pull to refresh.',
                                          style: TextStyle(fontSize: 12, color: Color(0xFF991B1B)),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 36),

                          // 6. Curated Tour Packages Showcase
                          _buildAnimatedSection(
                            animation: _bodyAnim,
                            child: tourPackagesAsync.when(
                              data: (packages) => Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: _buildSectionTitle('Curated Weekend Packages', 'AC Bus tours & Sahyadri treks', theme),
                                      ),
                                      const SizedBox(width: 8),
                                      TextButton(
                                        onPressed: () {
                                          HapticFeedback.selectionClick();
                                          context.go('/explore');
                                        },
                                        child: const Text('All Tours'),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 14),
                                  Builder(
                                    builder: (context) {
                                      final textScale = MediaQuery.textScalerOf(context).scale(1.0);
                                      final tourHeight = (330.0 * textScale).clamp(320.0, 440.0);
                                      return SizedBox(
                                        height: tourHeight,
                                        child: ListView.separated(
                                          scrollDirection: Axis.horizontal,
                                          itemCount: packages.length,
                                          separatorBuilder: (_, __) => const SizedBox(width: 14),
                                          itemBuilder: (context, index) {
                                            final pkg = packages[index];
                                            return Align(
                                              alignment: Alignment.topCenter,
                                              child: _buildTourPackageCard(pkg, isDark, theme, context),
                                            );
                                          },
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                              loading: () => const Padding(
                                padding: EdgeInsets.symmetric(vertical: 24),
                                child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
                              ),
                              error: (e, _) => Padding(
                                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
                                child: Container(
                                  padding: const EdgeInsets.all(14),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFEF2F2),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: const Color(0xFFFECACA)),
                                  ),
                                  child: const Row(
                                    children: [
                                      Icon(Icons.info_outline_rounded, color: Color(0xFFEF4444), size: 18),
                                      SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          'Tour packages could not be loaded. Pull to refresh.',
                                          style: TextStyle(fontSize: 12, color: Color(0xFF991B1B)),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 32),

                          // 7. Custom Multi-Day Itinerary Planner Banner
                          _buildAnimatedSection(
                            animation: _bodyAnim,
                            child: Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: isDark
                                      ? [const Color(0xFF1E293B), const Color(0xFF0F172A)]
                                      : [const Color(0xFF064E3B), const Color(0xFF047857)],
                                ),
                                borderRadius: BorderRadius.circular(22),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.emerald.withValues(alpha: isDark ? 0.3 : 0.25),
                                    blurRadius: 16,
                                    offset: const Offset(0, 6),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(alpha: 0.15),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Text('🧭', style: TextStyle(fontSize: 28)),
                                  ),
                                  const SizedBox(width: 16),
                                  const Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Custom Multi-Day Itinerary Planner',
                                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16),
                                        ),
                                        SizedBox(height: 4),
                                        Text(
                                          'Build your personalized Pune & Sahyadri trip schedule with draggable stops & checklist.',
                                          style: TextStyle(color: Color(0xFFD1FAE5), fontSize: 12),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  ElevatedButton(
                                    onPressed: () {
                                      HapticFeedback.selectionClick();
                                      context.push('/itinerary');
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.saffron,
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                    ),
                                    child: const Text('Plan Trip', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12.5)),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 40),

                          // 8. Pune Heritage Timeline
                          if (cfg.showHistoryTimeline) ...[
                            _buildAnimatedSection(
                              animation: _bodyAnim,
                              child: const HistoryTimelineSection(),
                            ),
                            const SizedBox(height: 40),
                          ],

                          // 9. Testimonials & FAQs
                          if (cfg.showTestimonialsFaq) ...[
                            _buildAnimatedSection(
                              animation: _bodyAnim,
                              child: const TestimonialsFAQSection(),
                            ),
                            const SizedBox(height: 36),
                          ],
                        ],
                      ),
                    ),

                    // 10. Home Footer (Only on Home Page)
                    if (cfg.showFooter) const HomeFooter(),
                  ],
                ),
              ),
            );
          },
          loading: () => const Center(
            child: Padding(
              padding: EdgeInsets.all(24.0),
              child: DestinationCardSkeleton(),
            ),
          ),
          error: (err, _) => ErrorBoundaryWidget(
            errorMessage: err.toString(),
            onRetry: () => ref.refresh(destinationsAsyncProvider),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, String subtitle, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 3.5,
              height: 18,
              decoration: BoxDecoration(
                color: AppColors.saffron,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.2,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          subtitle,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.bodySmall?.copyWith(fontSize: 11.5),
        ),
      ],
    );
  }

  Widget _buildTourPackageCard(TourPackage pkg, bool isDark, ThemeData theme, BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final cardWidth = (screenWidth * 0.72).clamp(260.0, 320.0);
    return Container(
      width: cardWidth,
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder, width: 1.2),
        boxShadow: AppColors.cardShadow(isDark),
      ),
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          context.push('/booking/${pkg.id}');
        },
        borderRadius: BorderRadius.circular(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image header
            Stack(
              children: [
                AppCardImage(
                  imageUrl: pkg.primaryImage,
                  aspectRatio: 16 / 9.5,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(19)),
                  categoryIcon: '🚌',
                  categoryLabel: pkg.category,
                  title: pkg.title,
                ),
                Positioned(
                  top: 10,
                  left: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.saffron,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      pkg.badge,
                      style: const TextStyle(color: Colors.white, fontSize: 10.5, fontWeight: FontWeight.w800),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.65),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      pkg.duration,
                      style: const TextStyle(color: Colors.white, fontSize: 10.5, fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ],
            ),

            // Content
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    pkg.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13.5),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    pkg.subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted, fontSize: 11),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    alignment: WrapAlignment.spaceBetween,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 8,
                    runSpacing: 4,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '₹${pkg.price.toInt()}',
                            style: const TextStyle(color: AppColors.emerald, fontWeight: FontWeight.w900, fontSize: 16),
                          ),
                          Text(
                            '₹${pkg.originalPrice.toInt()}',
                            style: TextStyle(
                              decoration: TextDecoration.lineThrough,
                              color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                              fontSize: 10.5,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                        decoration: BoxDecoration(
                          color: AppColors.emerald.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'Book Tour',
                          style: TextStyle(color: AppColors.emerald, fontWeight: FontWeight.w800, fontSize: 11.5),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
