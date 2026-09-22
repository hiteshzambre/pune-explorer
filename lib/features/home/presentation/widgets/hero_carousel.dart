import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../data/models/destination.dart';
import '../../../../core/responsive/breakpoints.dart';
import '../../../../core/widgets/app_network_image.dart';
import 'home_3d_decorations.dart';

bool get _isTestEnv =>
    WidgetsBinding.instance.runtimeType.toString().contains('Test') ||
    const bool.fromEnvironment('FLUTTER_TEST');

/// Premium Luxury Travel Hero Section for PuneExplorer
/// Features editorial typography, 3D rotating compass, floating 3D location pin,
/// layered Pune landmark silhouettes, dynamic greetings, and interactive CTA.
class HeroCarousel extends StatefulWidget {
  final List<Destination> destinations;

  const HeroCarousel({
    super.key,
    required this.destinations,
  });

  @override
  State<HeroCarousel> createState() => _HeroCarouselState();
}

class _HeroCarouselState extends State<HeroCarousel> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  Timer? _autoPlayTimer;

  @override
  void initState() {
    super.initState();
    if (!_isTestEnv && widget.destinations.length > 1) {
      _autoPlayTimer = Timer.periodic(const Duration(seconds: 5), (_) {
        if (_pageController.hasClients) {
          final next = (_currentPage + 1) % widget.destinations.length;
          _pageController.animateToPage(
            next,
            duration: const Duration(milliseconds: 700),
            curve: Curves.easeInOutCubic,
          );
        }
      });
    }
  }

  @override
  void dispose() {
    _autoPlayTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning / Namaskar, Explorer 👋';
    if (hour < 17) return 'Namaskar, Explorer 👋';
    return 'Shubh Sandhya / Namaskar, Explorer 👋';
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final isTabletOrDesktop = size.width > 600;
    final isLandscape = MediaQuery.orientationOf(context) == Orientation.landscape;
    final isSmall = Breakpoints.isSmallPhone(context);

    // Responsive hero height
    final double carouselHeight;
    if (isLandscape) {
      carouselHeight = (size.height * 0.75).clamp(260.0, 380.0);
    } else if (size.width > 1024) {
      carouselHeight = 460.0;
    } else if (isTabletOrDesktop) {
      carouselHeight = 420.0;
    } else if (isSmall) {
      carouselHeight = 350.0;
    } else {
      carouselHeight = 390.0;
    }

    if (widget.destinations.isEmpty) return const SizedBox.shrink();

    final currentDest = widget.destinations[_currentPage.clamp(0, widget.destinations.length - 1)];

    return SizedBox(
      height: carouselHeight,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Background Image Carousel
          PageView.builder(
            controller: _pageController,
            itemCount: widget.destinations.length,
            onPageChanged: (idx) => setState(() => _currentPage = idx),
            itemBuilder: (context, index) {
              final dest = widget.destinations[index];
              return _buildHeroSlideImage(dest);
            },
          ),

          // 2. Multi-stop Dark Scrim Gradient for guaranteed text contrast
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  const Color(0xFF00281E).withValues(alpha: 0.72),
                  const Color(0xFF00281E).withValues(alpha: 0.40),
                  const Color(0xFF0F172A).withValues(alpha: 0.78),
                  const Color(0xFF0F172A).withValues(alpha: 0.96),
                ],
                stops: const [0.0, 0.30, 0.70, 1.0],
              ),
            ),
          ),

          // 3. Layered 3D Pune Landmark Silhouette & Sahyadri Ridge
          Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(
                painter: PuneLandmarkSilhouettePainter(
                  tintColor: Colors.white,
                ),
              ),
            ),
          ),

          // 4. Top Branding & 3D Compass / Location Pin Bar
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.fromLTRB(
                isSmall ? 12 : 20,
                MediaQuery.paddingOf(context).top + 6,
                isSmall ? 12 : 20,
                0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Pune Explorer Brand Badge
                  Flexible(
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: isSmall ? 8 : 10,
                        vertical: isSmall ? 4 : 5,
                      ),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFF7A00), Color(0xFFEA580C)],
                        ),
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: AppColors.glowShadow(AppColors.saffron),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('🚩', style: TextStyle(fontSize: 13)),
                          const SizedBox(width: 5),
                          Flexible(
                            child: Text(
                              'PUNE EXPLORER',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: isSmall ? 10 : 11,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.8,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Location Pill Badge
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: isSmall ? 8 : 10,
                      vertical: isSmall ? 4 : 5,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.45),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white24),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.location_on_rounded, color: AppColors.emeraldLight, size: 14),
                        SizedBox(width: 4),
                        Text(
                          'Pune, MH',
                          maxLines: 1,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 5. Editorial Content Overlay (Greetings, Discover Pune, CTA, Floating Badge)
          Positioned(
            left: isSmall ? 14 : 20,
            right: isSmall ? 14 : 20,
            bottom: isSmall ? 36 : 42,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Editorial Cultural Greeting Label (subtle, non-interactive)
                Padding(
                  padding: const EdgeInsets.only(left: 2, bottom: 2),
                  child: Text(
                    _getGreeting(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.92),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.2,
                      shadows: const [
                        Shadow(color: Colors.black54, blurRadius: 4, offset: Offset(0, 1)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 8),

                // Grand Editorial Headline: "Discover Pune"
                Text(
                  'Discover Pune',
                  style: AppTypography.heroTitle(context),
                ),
                const SizedBox(height: 3),

                // Subtitle: "One place. Thousands of stories."
                Text(
                  'One place. Thousands of stories.',
                  style: AppTypography.heroSubtitle(context),
                ),
                const SizedBox(height: 14),

                // Interactive Action Row: [ Explore Pune → ] CTA + Floating Destination Badge
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    // CTA Button: [ Explore Pune ]
                    ElevatedButton.icon(
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        context.go('/explore');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.saffron,
                        foregroundColor: Colors.white,
                        elevation: 6,
                        shadowColor: AppColors.saffron.withValues(alpha: 0.5),
                        padding: EdgeInsets.symmetric(
                          horizontal: isSmall ? 14 : 18,
                          vertical: isSmall ? 10 : 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      icon: const Icon(Icons.explore_rounded, size: 16),
                      label: const Text(
                        'Explore Pune',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 13,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),

                    // Floating 3D Destination Micro-Badge
                    FloatingDestinationBadge3D(
                      title: currentDest.name,
                      rating: currentDest.rating.toStringAsFixed(1),
                      tag: currentDest.category.label,
                      emoji: currentDest.category.icon,
                      onTap: () {
                        HapticFeedback.lightImpact();
                        context.push('/destination/${currentDest.id}');
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),

          // 6. Unified Accessible Carousel Status & Controls: [ ‹ ] • • ● • • 1 / 5 [ › ]
          Positioned(
            bottom: 12,
            left: isSmall ? 14 : 20,
            right: isSmall ? 14 : 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.55),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white24, width: 0.8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Previous Slide Button
                      Semantics(
                        button: true,
                        label: 'Previous slide',
                        child: IconButton(
                          icon: const Icon(Icons.chevron_left_rounded, size: 18, color: Colors.white),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(minWidth: 26, minHeight: 26),
                          tooltip: 'Previous slide',
                          onPressed: _currentPage > 0
                              ? () {
                                  HapticFeedback.selectionClick();
                                  _pageController.previousPage(
                                    duration: const Duration(milliseconds: 350),
                                    curve: Curves.easeInOutCubic,
                                  );
                                }
                              : null,
                        ),
                      ),
                      const SizedBox(width: 4),

                      // Indicators
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: List.generate(widget.destinations.length, (idx) {
                          final isSelected = idx == _currentPage;
                          return InkWell(
                            onTap: () {
                              HapticFeedback.selectionClick();
                              _pageController.animateToPage(
                                idx,
                                duration: const Duration(milliseconds: 350),
                                curve: Curves.easeInOutCubic,
                              );
                            },
                            borderRadius: BorderRadius.circular(4),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              margin: const EdgeInsets.symmetric(horizontal: 2.5),
                              width: isSelected ? 18 : 6,
                              height: 6,
                              decoration: BoxDecoration(
                                color: isSelected ? AppColors.emerald : Colors.white.withValues(alpha: 0.45),
                                borderRadius: BorderRadius.circular(4),
                                boxShadow: isSelected ? AppColors.glowShadow(AppColors.emerald) : null,
                              ),
                            ),
                          );
                        }),
                      ),
                      const SizedBox(width: 8),

                      // Slide Counter Text: e.g. "1 / 5"
                      Semantics(
                        liveRegion: true,
                        label: 'Slide ${_currentPage + 1} of ${widget.destinations.length}',
                        child: Text(
                          '${_currentPage + 1} / ${widget.destinations.length}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),

                      // Next Slide Button
                      Semantics(
                        button: true,
                        label: 'Next slide',
                        child: IconButton(
                          icon: const Icon(Icons.chevron_right_rounded, size: 18, color: Colors.white),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(minWidth: 26, minHeight: 26),
                          tooltip: 'Next slide',
                          onPressed: _currentPage < widget.destinations.length - 1
                              ? () {
                                  HapticFeedback.selectionClick();
                                  _pageController.nextPage(
                                    duration: const Duration(milliseconds: 350),
                                    curve: Curves.easeInOutCubic,
                                  );
                                }
                              : null,
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

  Widget _buildHeroSlideImage(Destination dest) {
    return Semantics(
      label: 'Featured destination: ${dest.name}',
      button: true,
      child: GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          context.push('/destination/${dest.id}');
        },
        child: AppCardImage(
          imageUrl: dest.primaryImage,
          heroTag: 'dest_hero_${dest.id}',
          categoryIcon: dest.category.icon,
          categoryLabel: dest.category.label,
          title: dest.name,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
