import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../../core/utils/image_optimizer.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/responsive/responsive_builder.dart';
import '../../../core/widgets/error_boundary.dart';
import '../../../data/models/heritage_walk.dart';
import '../../../data/models/booking.dart';
import '../../../core/enums/app_enums.dart';
import '../../../services/map_service.dart';
import 'theme/heritage_walk_typography.dart';
import 'widgets/turn_by_turn_walk_guide_modal.dart';

class HeritageWalkDetailScreen extends ConsumerStatefulWidget {
  final String walkId;

  const HeritageWalkDetailScreen({super.key, required this.walkId});

  @override
  ConsumerState<HeritageWalkDetailScreen> createState() => _HeritageWalkDetailScreenState();
}

class _HeritageWalkDetailScreenState extends ConsumerState<HeritageWalkDetailScreen> {
  int? _selectedStopIndex;
  final MapController _mapController = MapController();
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _bookingSectionKey = GlobalKey();

  late DateTime _selectedDate;
  int _walkerCount = 1;
  String _selectedSlot = 'Morning (06:30 AM – 09:30 AM)';

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now().add(const Duration(days: 1));
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBookingSection() {
    HapticFeedback.selectionClick();
    final ctx = _bookingSectionKey.currentContext;
    if (ctx != null) {
      Scrollable.ensureVisible(
        ctx,
        duration: const Duration(milliseconds: 550),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  Future<void> _pickCustomDate(BuildContext context) async {
    HapticFeedback.selectionClick();
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate.isAfter(now) ? _selectedDate : now.add(const Duration(days: 1)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 90)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.fromSeed(
              seedColor: AppColors.emerald,
              primary: AppColors.emerald,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _launchGoogleMapsNavigation(HeritageWalk walk) async {
    final origin = '${walk.startLatitude},${walk.startLongitude}';
    final dest = '${walk.stops.last.latitude},${walk.stops.last.longitude}';
    final waypointsStr = walk.stops.sublist(0, walk.stops.length - 1).map((s) => '${s.latitude},${s.longitude}').join('|');

    final uri = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&origin=$origin&destination=$dest&waypoints=$waypointsStr&travelmode=walking',
    );

    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {}
  }

  void _shareWalk(HeritageWalk walk) {
    HapticFeedback.selectionClick();
    Clipboard.setData(ClipboardData(
      text: '🏛️ Discover "${walk.title} (${walk.marathiTitle})" on PuneExplorer!\n'
          'Explore ${walk.stopsCount} historic stops across ${walk.distanceKm} km.\n'
          'https://puneexplorer.app/walk/${walk.id}',
    ));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Trail link for "${walk.title}" copied to clipboard!'),
        backgroundColor: AppColors.emerald,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final walksAsync = ref.watch(heritageWalksAsyncProvider);
    final isFav = ref.watch(favoritesProvider.select((set) => set.contains(widget.walkId)));

    return walksAsync.when(
      data: (walks) {
        final walk = walks.firstWhere(
          (w) => w.id == widget.walkId,
          orElse: () => walks.first,
        );

        // Map Polylines & Markers
        final stopCoordinates = walk.stops.map((s) => LatLng(s.latitude, s.longitude)).toList();
        final startPos = stopCoordinates.first;
        final endPos = stopCoordinates.last;
        final polylinePoints = MapService.generateRouteCurve(startPos, endPos, segments: 24);

        final markers = <Marker>[];
        for (int i = 0; i < walk.stops.length; i++) {
          final stop = walk.stops[i];
          final isSelected = _selectedStopIndex == i;
          markers.add(
            Marker(
              point: LatLng(stop.latitude, stop.longitude),
              width: isSelected ? 48 : 38,
              height: isSelected ? 48 : 38,
              child: GestureDetector(
                onTap: () {
                  HapticFeedback.selectionClick();
                  setState(() => _selectedStopIndex = i);
                  _mapController.move(LatLng(stop.latitude, stop.longitude), 15.5);
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.emerald : AppColors.saffron,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2.5),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.35),
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '${i + 1}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ),
          );
        }

        final midLat = (startPos.latitude + endPos.latitude) / 2;
        final midLng = (startPos.longitude + endPos.longitude) / 2;

        return Scaffold(
          body: Stack(
            children: [
              // Scrollable Detail Content
              CustomScrollView(
                controller: _scrollController,
                slivers: [
                  // 1. Immersive Hero Sliver App Bar
                  SliverAppBar(
                    expandedHeight: 280,
                    pinned: true,
                    stretch: true,
                    leading: Container(
                      margin: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.45),
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ),
                    actions: [
                      Container(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.45),
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.share_rounded, color: Colors.white, size: 20),
                          onPressed: () => _shareWalk(walk),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.45),
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: Icon(
                            isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                            color: isFav ? const Color(0xFFEF4444) : Colors.white,
                            size: 20,
                          ),
                          onPressed: () {
                            HapticFeedback.mediumImpact();
                            ref.read(favoritesProvider.notifier).toggle(walk.id);
                          },
                        ),
                      ),
                      const SizedBox(width: 14),
                    ],
                    flexibleSpace: FlexibleSpaceBar(
                      background: Stack(
                        fit: StackFit.expand,
                        children: [
                          CachedNetworkImage(
                            imageUrl: AppImageOptimizer.forHero(walk.coverImage),
                            fit: BoxFit.cover,
                            fadeInDuration: const Duration(milliseconds: 250),
                            errorWidget: (_, __, ___) => Container(
                              color: AppColors.saffron.withValues(alpha: 0.2),
                              child: const Center(child: Text('🏛️', style: TextStyle(fontSize: 48))),
                            ),
                          ),
                          Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.black.withValues(alpha: 0.6),
                                  Colors.transparent,
                                  Colors.black.withValues(alpha: 0.85),
                                ],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                stops: const [0.0, 0.45, 1.0],
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 16,
                            left: 16,
                            right: 16,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 6,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: walk.category.accentColor,
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        '${walk.category.icon} ${walk.category.label}',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w800,
                                          fontSize: 11,
                                        ),
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withValues(alpha: 0.25),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(Icons.star_rounded, size: 13, color: AppColors.gold),
                                          const SizedBox(width: 3),
                                          Text(
                                            '${walk.rating} (${walk.reviewCount} reviews)',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w800,
                                              fontSize: 11,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  walk.title,
                                  style: HeritageWalkTypography.heroTitle(
                                    color: Colors.white,
                                    fontSize: 22,
                                  ),
                                ),
                                if (walk.marathiTitle.isNotEmpty) ...[
                                  const SizedBox(height: 2),
                                  Text(
                                    walk.marathiTitle,
                                    style: HeritageWalkTypography.marathiSubtitle(
                                      color: const Color(0xFFFDE68A),
                                      fontSize: 13.5,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // 2. Main Content Body
                  SliverToBoxAdapter(
                    child: MaxWidthWrapper(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 20, 16, 120),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // 5-Point Meta Ribbon
                            _buildQuickFactsRibbon(walk, isDark),
                            const SizedBox(height: 24),

                            // Historical Context & Narrative
                            _buildHistoricalContextCard(walk, isDark, theme),
                            const SizedBox(height: 28),

                            // Interactive Map Section with Route Polyline
                            _buildInteractiveMapSection(
                              walk: walk,
                              midLat: midLat,
                              midLng: midLng,
                              polylinePoints: polylinePoints,
                              markers: markers,
                              isDark: isDark,
                              theme: theme,
                            ),
                            const SizedBox(height: 28),

                            // Chronological Stops Timeline
                            _buildStopsTimeline(walk, isDark, theme),
                            const SizedBox(height: 28),

                            // Puneri Food Pitstops Along Walk
                            if (walk.localFoodPitstops.isNotEmpty) ...[
                              _buildFoodPitstopsSection(walk, isDark, theme),
                              const SizedBox(height: 28),
                            ],

                            // Visitor Guidelines & Etiquette
                            _buildGuidelinesSection(walk, isDark, theme),
                            const SizedBox(height: 28),

                            // Certified Guide Card
                            _buildGuideCard(walk, isDark, theme),
                            const SizedBox(height: 28),

                            // Dedicated Interactive Booking Section
                            _buildBookingSection(walk, isDark, theme),
                            const SizedBox(height: 32),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              // 3. Fixed Bottom Action Dock
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: _buildBottomDock(walk, isDark, theme),
              ),
            ],
          ),
        );
      },
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(
        appBar: AppBar(),
        body: ErrorBoundaryWidget(errorMessage: e.toString()),
      ),
    );
  }

  // ── 1. Quick Facts Ribbon ──────────────────────────────────────────────────
  Widget _buildQuickFactsRibbon(HeritageWalk walk, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(child: _buildFactItem('WALK TIME', walk.durationFormatted, Icons.timer_outlined, AppColors.saffron)),
          _buildFactDivider(isDark),
          Expanded(child: _buildFactItem('DISTANCE', '${walk.distanceKm} km', Icons.directions_walk_rounded, AppColors.emerald)),
          _buildFactDivider(isDark),
          Expanded(child: _buildFactItem('TOTAL STOPS', '${walk.stopsCount} stops', Icons.pin_drop_rounded, const Color(0xFF8B5CF6))),
          _buildFactDivider(isDark),
          Expanded(child: _buildFactItem('DIFFICULTY', walk.difficulty.label, Icons.speed_rounded, walk.difficulty.color)),
        ],
      ),
    );
  }

  Widget _buildFactItem(String label, String value, IconData icon, Color color) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(height: 4),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: HeritageWalkTypography.meta(color: color, fontSize: 12, fontWeight: FontWeight.w800),
        ),
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: HeritageWalkTypography.meta(color: Colors.grey, fontSize: 9.5, fontWeight: FontWeight.w700),
        ),
      ],
    );
  }

  Widget _buildFactDivider(bool isDark) {
    return Container(
      width: 1,
      height: 32,
      color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
    );
  }

  // ── 2. Historical Context Card ─────────────────────────────────────────────
  Widget _buildHistoricalContextCard(HeritageWalk walk, bool isDark, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.saffron.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Text('📜', style: TextStyle(fontSize: 18)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'The Story Behind The Walk',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    Text(
                      walk.subtitle,
                      style: TextStyle(
                        fontSize: 11.5,
                        color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            walk.description,
            style: const TextStyle(fontSize: 13.5, height: 1.55),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurfaceVariant : AppColors.lightSurfaceVariant,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('🛡️', style: TextStyle(fontSize: 16)),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    walk.historicalContext,
                    style: TextStyle(
                      fontSize: 12,
                      height: 1.5,
                      color: isDark ? Colors.white70 : Colors.black87,
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

  // ── 3. Interactive Map Section ─────────────────────────────────────────────
  Widget _buildInteractiveMapSection({
    required HeritageWalk walk,
    required double midLat,
    required double midLng,
    required List<LatLng> polylinePoints,
    required List<Marker> markers,
    required bool isDark,
    required ThemeData theme,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Interactive Trail Map',
                        style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
                      ),
                      Text(
                        'Tap any numbered pin to preview that stop',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 11,
                          color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                TextButton.icon(
                  onPressed: () => _launchGoogleMapsNavigation(walk),
                  icon: const Icon(Icons.navigation_rounded, size: 15, color: AppColors.saffron),
                  label: const Text('Navigate', style: TextStyle(color: AppColors.saffron, fontWeight: FontWeight.w800, fontSize: 12)),
                ),
              ],
            ),
          ),

          // Map View
          SizedBox(
            height: 250,
            child: FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: LatLng(midLat, midLng),
                initialZoom: 14.5,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.puneexplorer.app',
                ),
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: polylinePoints,
                      strokeWidth: 4.5,
                      color: AppColors.saffron,
                      borderColor: Colors.black26,
                      borderStrokeWidth: 1.5,
                    ),
                  ],
                ),
                MarkerLayer(markers: markers),
              ],
            ),
          ),

          // Selected Stop Preview Card
          if (_selectedStopIndex != null) ...[
            Container(
              padding: const EdgeInsets.all(14),
              color: isDark ? AppColors.darkSurfaceVariant : AppColors.lightSurfaceVariant,
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: const BoxDecoration(
                      color: AppColors.emerald,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '${_selectedStopIndex! + 1}',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 13),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          walk.stops[_selectedStopIndex!].name,
                          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
                        ),
                        Text(
                          walk.stops[_selectedStopIndex!].era,
                          style: TextStyle(
                            fontSize: 11,
                            color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, size: 18),
                    onPressed: () => setState(() => _selectedStopIndex = null),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ── 4. Stops Timeline ──────────────────────────────────────────────────────
  Widget _buildStopsTimeline(HeritageWalk walk, bool isDark, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Walking Route & Stops',
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
                  ),
                  Text(
                    '${walk.stopsCount} historic landmarks in sequence',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11.5,
                      color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.saffron.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${walk.distanceKm} KM TOTAL',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  color: AppColors.saffron,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Sequenced Stop Cards with Walking Connectors
        ...walk.stops.asMap().entries.map((entry) {
          final index = entry.key;
          final stop = entry.value;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (index > 0) ...[
                Padding(
                  padding: const EdgeInsets.only(left: 17, top: 4, bottom: 8),
                  child: Row(
                    children: [
                      Container(
                        width: 2,
                        height: 26,
                        color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1),
                      ),
                      const SizedBox(width: 12),
                      Flexible(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                              width: 0.8,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.directions_walk_rounded, size: 12, color: Color(0xFFD97706)),
                              const SizedBox(width: 4),
                              Flexible(
                                child: Text(
                                  '${stop.walkingDurationFromPreviousMinutes * 70} m • ${stop.walkingDurationFromPreviousMinutes} min walk',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: HeritageWalkTypography.meta(
                                    color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                                    fontSize: 10.5,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 3),
                              const Icon(Icons.arrow_downward_rounded, size: 11, color: Color(0xFFD97706)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Stop Number Circle
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: const Color(0xFFD97706),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFD97706).withValues(alpha: 0.35),
                            blurRadius: 6,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '${index + 1}',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 14),
                      ),
                    ),
                    const SizedBox(width: 14),

                    // Stop Detail Card
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Era Pill & Walking Time
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    stop.era,
                                    style: HeritageWalkTypography.meta(
                                      color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2.5),
                                  decoration: BoxDecoration(
                                    color: AppColors.emerald.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  child: Text(
                                    '${stop.recommendedTimeSpentMinutes}m visit',
                                    style: HeritageWalkTypography.meta(
                                      color: AppColors.emerald,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),

                            // Title
                            Text(
                              stop.name,
                              style: HeritageWalkTypography.cardTitle(
                                color: isDark ? Colors.white : Colors.black87,
                                fontSize: 14.5,
                              ),
                            ),
                            if (stop.marathiName.isNotEmpty) ...[
                              const SizedBox(height: 2),
                              Text(
                                stop.marathiName,
                                style: HeritageWalkTypography.marathiSubtitle(
                                  color: isDark ? const Color(0xFFFDBA74) : const Color(0xFFB45309),
                                  fontSize: 12,
                                ),
                              ),
                            ],
                            const SizedBox(height: 8),

                            // Story snippet
                            Text(
                              stop.historicalStory,
                              style: HeritageWalkTypography.cardDescription(
                                color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF334155),
                                fontSize: 12.5,
                              ),
                            ),

                            // Architectural Style
                            if (stop.architecturalStyle.isNotEmpty) ...[
                              const SizedBox(height: 8),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('🏛️ ', style: TextStyle(fontSize: 12)),
                                  Expanded(
                                    child: Text(
                                      stop.architecturalStyle,
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontStyle: FontStyle.italic,
                                        color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],

                            // Insider Tip
                            if (stop.insiderTip.isNotEmpty) ...[
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFEF3C7).withValues(alpha: isDark ? 0.12 : 0.6),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: const Color(0xFFD97706).withValues(alpha: 0.2),
                                  ),
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('💡 ', style: TextStyle(fontSize: 11)),
                                    Expanded(
                                      child: Text(
                                        stop.insiderTip,
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                          color: isDark ? const Color(0xFFFDE68A) : const Color(0xFF92400E),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        }),
      ],
    );
  }

  // ── 5. Food Pitstops Section ───────────────────────────────────────────────
  Widget _buildFoodPitstopsSection(HeritageWalk walk, bool isDark, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
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
                child: const Text('🍲', style: TextStyle(fontSize: 18)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Puneri Food & Heritage Pitstops', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900)),
                    Text(
                      'Taste authentic flavours along this walking trail',
                      style: TextStyle(fontSize: 11, color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ...walk.localFoodPitstops.map((food) => Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Row(
                  children: [
                    const Icon(Icons.restaurant_rounded, size: 15, color: AppColors.emerald),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(food, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  // ── 6. Guidelines Section ──────────────────────────────────────────────────
  Widget _buildGuidelinesSection(HeritageWalk walk, bool isDark, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.amber.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Text('👟', style: TextStyle(fontSize: 18)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Visitor Etiquette & Tips', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900)),
                    Text(
                      'Essential advice from local historians',
                      style: TextStyle(fontSize: 11, color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ...walk.culturalEtiquette.map((tip) => Padding(
                padding: const EdgeInsets.only(bottom: 6.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('✓ ', style: TextStyle(color: AppColors.emerald, fontWeight: FontWeight.w900)),
                    Expanded(child: Text(tip, style: const TextStyle(fontSize: 12.5, height: 1.4))),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  // ── 7. Historian Guide Card ────────────────────────────────────────────────
  Widget _buildGuideCard(HeritageWalk walk, bool isDark, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFF1E293B), const Color(0xFF0F172A)]
              : [const Color(0xFFFFFBEB), const Color(0xFFFEF3C7)],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.amber.withValues(alpha: 0.35)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: AppColors.saffron,
            child: Text(
              walk.guideName.split(' ').map((e) => e.isNotEmpty ? e[0] : '').take(2).join(),
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        walk.guideName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14),
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Icon(Icons.verified_rounded, size: 15, color: AppColors.emerald),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  walk.guideRole,
                  style: TextStyle(
                    fontSize: 11.5,
                    color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Speaks: Marathi, English, Hindi',
                  style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w600, color: AppColors.saffron),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── 8. Dedicated Interactive Booking Section ──────────────────────────────
  Widget _buildBookingSection(HeritageWalk walk, bool isDark, ThemeData theme) {
    final basePrice = walk.isFree ? 0.0 : walk.price;
    final rawTotal = basePrice * _walkerCount;
    final groupDiscount = (_walkerCount >= 4 && !walk.isFree) ? (100.0 * _walkerCount) : 0.0;
    final finalTotal = (rawTotal - groupDiscount).clamp(0.0, double.infinity);
    final formattedDate = DateFormat('EEEE, d MMMM yyyy').format(_selectedDate);

    DateTime getNextSaturday() {
      final now = DateTime.now();
      int days = (DateTime.saturday - now.weekday + 7) % 7;
      if (days == 0) days = 7;
      return DateTime(now.year, now.month, now.day).add(Duration(days: days));
    }

    DateTime getNextSunday() {
      final now = DateTime.now();
      int days = (DateTime.sunday - now.weekday + 7) % 7;
      if (days == 0) days = 7;
      return DateTime(now.year, now.month, now.day).add(Duration(days: days));
    }

    final tomorrow = DateTime.now().add(const Duration(days: 1));
    final nextSat = getNextSaturday();
    final nextSun = getNextSunday();

    bool isSameDay(DateTime a, DateTime b) =>
        a.year == b.year && a.month == b.month && a.day == b.day;

    return Container(
      key: _bookingSectionKey,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: AppColors.emerald.withValues(alpha: isDark ? 0.45 : 0.35),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.emerald.withValues(alpha: isDark ? 0.18 : 0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Badge & Title
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: AppColors.emeraldGradient,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: AppColors.glowShadow(AppColors.emerald),
                ),
                child: const Icon(Icons.confirmation_number_rounded, color: Colors.white, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2.5),
                          decoration: BoxDecoration(
                            color: AppColors.emerald.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            'HISTORIAN PASS',
                            style: TextStyle(
                              color: AppColors.emerald,
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.verified_rounded, size: 14, color: AppColors.emerald),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Book Guided Heritage Walk',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                        fontSize: 19,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Exclusive storytelling trail with ${walk.guideName}',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),
          const Divider(height: 1),
          const SizedBox(height: 18),

          // 1. DATE SELECTION
          Text(
            'SELECT DATE',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.0,
              color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
            ),
          ),
          const SizedBox(height: 10),

          // Selected Date Display Box
          InkWell(
            onTap: () => _pickCustomDate(context),
            borderRadius: BorderRadius.circular(14),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurfaceVariant : const Color(0xFFF1F8F5),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: AppColors.emerald.withValues(alpha: 0.4),
                  width: 1.2,
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.calendar_month_rounded, color: AppColors.emerald, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          formattedDate,
                          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
                        ),
                        const Text(
                          'Tap to choose custom date on calendar',
                          style: TextStyle(fontSize: 10.5, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.edit_calendar_rounded, size: 18, color: AppColors.emerald),
                ],
              ),
            ),
          ),

          const SizedBox(height: 10),

          // Quick Date Chips
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildQuickDateChip(
                label: 'Tomorrow',
                date: tomorrow,
                isSelected: isSameDay(_selectedDate, tomorrow),
                isDark: isDark,
              ),
              _buildQuickDateChip(
                label: 'This Saturday',
                date: nextSat,
                isSelected: isSameDay(_selectedDate, nextSat),
                isDark: isDark,
              ),
              _buildQuickDateChip(
                label: 'This Sunday',
                date: nextSun,
                isSelected: isSameDay(_selectedDate, nextSun),
                isDark: isDark,
              ),
            ],
          ),

          const SizedBox(height: 20),

          // 2. TIME SESSION / BATCH SELECTION
          Text(
            'SELECT WALKING SESSION',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.0,
              color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
            ),
          ),
          const SizedBox(height: 10),

          _buildSessionRadio(
            title: 'Morning Batch (06:30 AM – 09:30 AM)',
            subtitle: 'Cool morning breeze, quiet streets & temple bells • Recommended',
            icon: Icons.wb_sunny_rounded,
            slotValue: 'Morning (06:30 AM – 09:30 AM)',
            isDark: isDark,
          ),
          const SizedBox(height: 8),
          _buildSessionRadio(
            title: 'Evening Batch (04:30 PM – 07:30 PM)',
            subtitle: 'Golden hour twilight & illuminated heritage wadas',
            icon: Icons.nights_stay_rounded,
            slotValue: 'Evening (04:30 PM – 07:30 PM)',
            isDark: isDark,
          ),

          const SizedBox(height: 20),

          // 3. WALKERS COUNTER
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'NUMBER OF WALKERS',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.0,
                        color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                      ),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'Max 10 walkers per historian batch',
                      style: TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkSurfaceVariant : const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove_rounded, size: 18),
                      onPressed: _walkerCount > 1
                          ? () {
                              HapticFeedback.selectionClick();
                              setState(() => _walkerCount--);
                            }
                          : null,
                      color: _walkerCount > 1 ? AppColors.emerald : Colors.grey,
                      tooltip: 'Decrease walkers',
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Text(
                        '$_walkerCount',
                        style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add_rounded, size: 18),
                      onPressed: _walkerCount < 10
                          ? () {
                              HapticFeedback.selectionClick();
                              setState(() => _walkerCount++);
                            }
                          : null,
                      color: _walkerCount < 10 ? AppColors.emerald : Colors.grey,
                      tooltip: 'Increase walkers',
                    ),
                  ],
                ),
              ),
            ],
          ),

          if (_walkerCount >= 4 && !walk.isFree) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF3C7),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFF59E0B)),
              ),
              child: Row(
                children: [
                  const Text('🎉', style: TextStyle(fontSize: 14)),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Group Discount Applied: ₹100 off per person (Saving ₹${100 * _walkerCount})',
                      style: const TextStyle(
                        color: Color(0xFF92400E),
                        fontWeight: FontWeight.w700,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 20),

          // 4. INCLUSIONS CHECKLIST
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF13231B) : const Color(0xFFF0FDF4),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.emerald.withValues(alpha: 0.25)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.check_circle_rounded, color: AppColors.emerald, size: 16),
                    SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'INCLUDED WITH THIS HISTORIAN PASS',
                        style: TextStyle(
                          color: AppColors.emerald,
                          fontWeight: FontWeight.w800,
                          fontSize: 11,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                _buildInclusionItem('🎙️ Live storytelling by certified historian & author (${walk.guideName})'),
                _buildInclusionItem('🎧 Individual HD wireless audio receiver & stereo headset'),
                _buildInclusionItem('☕ Authentic Puneri breakfast & hot chai tasting stop'),
                _buildInclusionItem('🎟️ All historic monument entry passes & photography permits'),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // 5. LIVE PRICE SUMMARY
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurfaceVariant : const Color(0xFFF9FAFB),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        walk.isFree ? 'Walk Registration' : 'Pass Fare (₹${walk.price.toInt()} × $_walkerCount)',
                        style: const TextStyle(fontSize: 13),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      walk.isFree ? 'FREE' : '₹${rawTotal.toInt()}',
                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                    ),
                  ],
                ),
                if (groupDiscount > 0) ...[
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Expanded(
                        child: Text('Group Savings (4+ Walkers)', style: TextStyle(color: Color(0xFF059669), fontSize: 12.5)),
                      ),
                      const SizedBox(width: 8),
                      Text('- ₹${groupDiscount.toInt()}', style: const TextStyle(color: Color(0xFF059669), fontWeight: FontWeight.w700, fontSize: 12.5)),
                    ],
                  ),
                ],
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Divider(height: 1),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Total Amount', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14)),
                          Text('All taxes, guide fees & audio gear included', style: TextStyle(fontSize: 10, color: Colors.grey)),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      walk.isFree ? '₹0 Free' : '₹${finalTotal.toInt()}',
                      style: const TextStyle(
                        color: AppColors.emerald,
                        fontWeight: FontWeight.w900,
                        fontSize: 20,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // 6. PRIMARY BOOKING CTA
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                HapticFeedback.mediumImpact();
                _showWalkBookingModal(walk, finalTotal);
              },
              icon: const Icon(Icons.confirmation_number_rounded, size: 20, color: Colors.white),
              label: Text(
                walk.isFree
                    ? 'Reserve Free Walk Slot →'
                    : 'Book Walk Slot • ₹${finalTotal.toInt()} →',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 15,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.emerald,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 4,
                shadowColor: AppColors.emerald.withValues(alpha: 0.4),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickDateChip({
    required String label,
    required DateTime date,
    required bool isSelected,
    required bool isDark,
  }) {
    return InkWell(
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() => _selectedDate = date);
      },
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.emerald
              : (isDark ? AppColors.darkSurfaceVariant : const Color(0xFFF3F4F6)),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected
                ? AppColors.emerald
                : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected
                ? Colors.white
                : (isDark ? Colors.white70 : Colors.black87),
            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildSessionRadio({
    required String title,
    required String subtitle,
    required IconData icon,
    required String slotValue,
    required bool isDark,
  }) {
    final isSelected = _selectedSlot == slotValue;
    return InkWell(
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() => _selectedSlot = slotValue);
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.emerald.withValues(alpha: isDark ? 0.2 : 0.08)
              : (isDark ? AppColors.darkSurfaceVariant : const Color(0xFFFAFAFA)),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? AppColors.emerald
                : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: isSelected ? AppColors.emerald : Colors.grey,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                      fontSize: 13,
                      color: isSelected
                          ? AppColors.emerald
                          : (isDark ? Colors.white : Colors.black87),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? AppColors.emerald : Colors.grey.shade400,
                  width: 2,
                ),
                color: isSelected ? AppColors.emerald : Colors.transparent,
              ),
              alignment: Alignment.center,
              child: isSelected
                  ? const Icon(Icons.check_rounded, size: 14, color: Colors.white)
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInclusionItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(color: AppColors.emerald, fontWeight: FontWeight.bold)),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 11.5, height: 1.35),
            ),
          ),
        ],
      ),
    );
  }

  // ── 9. Booking Checkout Modal Sheet ────────────────────────────────────────
  void _showWalkBookingModal(HeritageWalk walk, double totalAmount) {
    final user = ref.read(authStateProvider).value;
    final nameCtrl = TextEditingController(text: user?.name ?? 'Puneri Traveler');
    final phoneCtrl = TextEditingController(text: '9876543210');
    final emailCtrl = TextEditingController(text: user?.email ?? 'explorer@puneexplorer.app');
    String dietary = 'Maharashtrian Pure Veg';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Container(
              margin: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 20,
              ),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : Colors.white,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: SafeArea(
                child: SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(
                    20,
                    14,
                    20,
                    MediaQuery.of(context).viewInsets.bottom + 20,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Drag Handle
                      Center(
                        child: Container(
                          width: 44,
                          height: 5,
                          decoration: BoxDecoration(
                            color: Colors.grey.withValues(alpha: 0.35),
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Sheet Header
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Confirm Heritage Walk Pass',
                                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  walk.title,
                                  style: TextStyle(
                                    fontSize: 12.5,
                                    color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close_rounded),
                            onPressed: () => Navigator.of(ctx).pop(),
                          ),
                        ],
                      ),
                      const Divider(height: 24),

                      // Walk Details Summary Capsule
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.darkSurfaceVariant : const Color(0xFFF1F8F5),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.emerald.withValues(alpha: 0.3)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.calendar_today_rounded, size: 14, color: AppColors.emerald),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    '${DateFormat('EEE, d MMM yyyy').format(_selectedDate)} • $_selectedSlot',
                                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                const Icon(Icons.group_rounded, size: 14, color: AppColors.emerald),
                                const SizedBox(width: 6),
                                Text(
                                  '$_walkerCount Participant${_walkerCount > 1 ? 's' : ''} • Guide: ${walk.guideName}',
                                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                const Icon(Icons.pin_drop_rounded, size: 14, color: AppColors.saffron),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    'Meeting Point: ${walk.startLocationName}',
                                    style: const TextStyle(fontSize: 11.5, color: Colors.grey),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),

                      // Traveler Details Form
                      const Text(
                        'PRIMARY WALKER DETAILS',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.8,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 10),

                      TextField(
                        controller: nameCtrl,
                        decoration: InputDecoration(
                          labelText: 'Full Name *',
                          prefixIcon: const Icon(Icons.person_outline_rounded, size: 20),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        ),
                      ),
                      const SizedBox(height: 12),

                      TextField(
                        controller: phoneCtrl,
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(
                          labelText: 'WhatsApp Mobile Number *',
                          prefixIcon: const Icon(Icons.phone_outlined, size: 20),
                          prefixText: '+91 ',
                          helperText: 'For meeting point updates & digital pass on WhatsApp',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        ),
                      ),
                      const SizedBox(height: 12),

                      TextField(
                        controller: emailCtrl,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          labelText: 'Email Address',
                          prefixIcon: const Icon(Icons.mail_outline_rounded, size: 20),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Dietary Preference
                      const Text(
                        'PUNERI SNACK TASTING PREFERENCE',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.8,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        children: [
                          ChoiceChip(
                            label: const Text('Pure Vegetarian'),
                            selected: dietary == 'Maharashtrian Pure Veg',
                            onSelected: (_) => setSheetState(() => dietary = 'Maharashtrian Pure Veg'),
                            selectedColor: AppColors.emerald.withValues(alpha: 0.2),
                          ),
                          ChoiceChip(
                            label: const Text('Jain Friendly'),
                            selected: dietary == 'Jain Friendly',
                            onSelected: (_) => setSheetState(() => dietary = 'Jain Friendly'),
                            selectedColor: AppColors.emerald.withValues(alpha: 0.2),
                          ),
                          ChoiceChip(
                            label: const Text('No Preference'),
                            selected: dietary == 'No Preference',
                            onSelected: (_) => setSheetState(() => dietary = 'No Preference'),
                            selectedColor: AppColors.emerald.withValues(alpha: 0.2),
                          ),
                        ],
                      ),

                      const SizedBox(height: 22),

                      // Bottom Confirmation Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            final leadName = nameCtrl.text.trim().isNotEmpty
                                ? nameCtrl.text.trim()
                                : 'Puneri Traveler';
                            final leadPhone = phoneCtrl.text.trim().isNotEmpty
                                ? phoneCtrl.text.trim()
                                : '9876543210';
                            final leadEmail = emailCtrl.text.trim().isNotEmpty
                                ? emailCtrl.text.trim()
                                : 'explorer@puneexplorer.app';

                            final bookingId = 'HWK-${DateTime.now().millisecondsSinceEpoch.toString().substring(6)}';
                            final travelDateStr = DateFormat('yyyy-MM-dd').format(_selectedDate);
                            final createdAtStr = DateTime.now().toIso8601String();

                            final booking = Booking(
                              id: bookingId,
                              tourId: walk.id,
                              tourTitle: '${walk.title} (${walk.marathiTitle})',
                              travelDate: travelDateStr,
                              pickupPoint: walk.startLocationName,
                              passengers: [
                                Passenger(fullName: leadName, age: 28, gender: 'Traveler'),
                                for (int i = 1; i < _walkerCount; i++)
                                  Passenger(fullName: 'Walker ${i + 1}', age: 26, gender: 'Companion'),
                              ],
                              selectedSeats: const ['HISTORIAN-WALK-PASS'],
                              basePrice: walk.price,
                              seatExtraPrice: 0.0,
                              discountAmount: (_walkerCount >= 4 && !walk.isFree) ? (100.0 * _walkerCount) : 0.0,
                              gstAmount: 0.0,
                              platformFee: 0.0,
                              totalAmount: totalAmount,
                              status: BookingStatus.confirmed,
                              createdAt: createdAtStr,
                              customerName: leadName,
                              customerEmail: leadEmail,
                              customerPhone: leadPhone,
                              verificationHash: 'HWKPASS-${bookingId.replaceAll('-', '')}',
                              paymentStatus: PaymentStatus.paid,
                              paymentMethod: walk.isFree ? 'Complimentary Public Pass' : 'PuneExplorer Pass',
                            );

                            ref.read(userBookingsProvider.notifier).addBooking(booking);

                            Navigator.of(ctx).pop();
                            HapticFeedback.mediumImpact();
                            _showBookingSuccessDialog(booking, walk);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.emerald,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                          child: Text(
                            walk.isFree
                                ? 'Confirm Free Reservation'
                                : 'Confirm Reservation • ₹${totalAmount.toInt()}',
                            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  // ── 10. Instant Booking Confirmed Dialog ────────────────────────────────────
  void _showBookingSuccessDialog(Booking booking, HeritageWalk walk) {
    showDialog(
      context: context,
      builder: (dialogCtx) {
        final isDark = Theme.of(dialogCtx).brightness == Brightness.dark;
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
          contentPadding: const EdgeInsets.all(22),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: AppColors.emeraldGradient,
                  shape: BoxShape.circle,
                  boxShadow: AppColors.glowShadow(AppColors.emerald),
                ),
                child: const Icon(Icons.check_rounded, color: Colors.white, size: 36),
              ),
              const SizedBox(height: 16),
              const Text(
                'Heritage Pass Confirmed! 🎉',
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                'Pass ID: ${booking.id}',
                style: const TextStyle(
                  color: AppColors.emerald,
                  fontWeight: FontWeight.w800,
                  fontSize: 13,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 14),

              // QR Code
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.withValues(alpha: 0.25)),
                ),
                child: QrImageView(
                  data: booking.verificationHash.isNotEmpty ? booking.verificationHash : booking.id,
                  size: 130,
                  eyeStyle: const QrEyeStyle(eyeShape: QrEyeShape.square, color: AppColors.emerald),
                  dataModuleStyle: const QrDataModuleStyle(dataModuleShape: QrDataModuleShape.square, color: Colors.black87),
                ),
              ),
              const SizedBox(height: 14),

              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkSurfaceVariant : const Color(0xFFF9FAFB),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    _buildSuccessDetailRow('Walk', walk.title),
                    _buildSuccessDetailRow('Date', DateFormat('EEE, d MMM yyyy').format(_selectedDate)),
                    _buildSuccessDetailRow('Slot', _selectedSlot),
                    _buildSuccessDetailRow('Walkers', '$_walkerCount Person(s)'),
                    _buildSuccessDetailRow('Meeting Point', walk.startLocationName),
                    _buildSuccessDetailRow('Historian', walk.guideName),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(dialogCtx).pop(),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Close'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(dialogCtx).pop();
                        context.push('/digital-ticket/${booking.id}');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.emerald,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text('View Pass →', style: TextStyle(fontWeight: FontWeight.w800)),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSuccessDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }

  // ── 11. Fixed Bottom Action Dock ───────────────────────────────────────────
  Widget _buildBottomDock(HeritageWalk walk, bool isDark, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        border: Border(top: BorderSide(color: isDark ? AppColors.darkBorder : AppColors.lightBorder)),
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
        child: Row(
          children: [
            // Price Info
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  walk.isFree ? 'FREE TOUR' : 'HISTORIAN PASS',
                  style: HeritageWalkTypography.priceLabel(
                    color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                    fontSize: 9.5,
                  ),
                ),
                Text(
                  walk.isFree ? 'Free Pass' : '₹${walk.price.toInt()}/person',
                  style: HeritageWalkTypography.price(
                    color: walk.isFree ? AppColors.emerald : const Color(0xFFD97706),
                    fontSize: 14.5,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 12),

            // Start Walking Tour (Outlined Secondary CTA)
            Expanded(
              flex: 11,
              child: OutlinedButton.icon(
                onPressed: () {
                  HapticFeedback.mediumImpact();
                  TurnByTurnWalkGuideModal.show(context, walk);
                },
                icon: const Icon(Icons.directions_walk_rounded, size: 16),
                label: const FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    'Start Walking Tour',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12.5),
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFFD97706),
                  side: const BorderSide(color: Color(0xFFD97706), width: 1.5),
                  padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            const SizedBox(width: 8),

            // Book Walk Primary CTA (Elevated Emerald)
            Expanded(
              flex: 9,
              child: ElevatedButton.icon(
                onPressed: () {
                  HapticFeedback.selectionClick();
                  _scrollToBookingSection();
                },
                icon: const Icon(Icons.confirmation_number_rounded, size: 16),
                label: const FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    'Book Walk',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 13),
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.emerald,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
