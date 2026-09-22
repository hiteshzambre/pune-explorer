import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/responsive/responsive_builder.dart';
import '../../../../core/utils/booking_cutoff_validator.dart';
import '../../../../core/widgets/app_network_image.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../data/models/tour_package.dart';

class TourDetailsView extends StatefulWidget {
  final TourPackage tour;
  final DateTime initialDate;
  final int initialTravelers;
  final VoidCallback onBack;
  final Function(DateTime date, int travelers) onContinueToBooking;

  const TourDetailsView({
    super.key,
    required this.tour,
    required this.initialDate,
    required this.initialTravelers,
    required this.onBack,
    required this.onContinueToBooking,
  });

  @override
  State<TourDetailsView> createState() => _TourDetailsViewState();
}

class _TourDetailsViewState extends State<TourDetailsView> with SingleTickerProviderStateMixin {
  late DateTime _selectedDate;
  late int _travelers;
  late TabController _tabController;
  int _activeGalleryIndex = 0;
  bool _isFavorite = false;

  @override
  void initState() {
    super.initState();
    final earliest = BookingCutoffValidator.getEarliestSelectableDate(widget.tour);
    _selectedDate = BookingCutoffValidator.isDateSelectable(widget.initialDate, widget.tour)
        ? widget.initialDate
        : earliest;
    _travelers = widget.initialTravelers;
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _pickDate(BuildContext context) async {
    final now = DateTime.now();
    final earliest = BookingCutoffValidator.getEarliestSelectableDate(widget.tour, currentTime: now);
    final effectiveInitial = (!BookingCutoffValidator.isDateSelectable(_selectedDate, widget.tour, currentTime: now))
        ? earliest
        : _selectedDate;

    final picked = await showDatePicker(
      context: context,
      initialDate: effectiveInitial,
      firstDate: now,
      lastDate: now.add(const Duration(days: 180)),
      selectableDayPredicate: (date) => BookingCutoffValidator.isDateSelectable(date, widget.tour, currentTime: now),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.emerald,
              onPrimary: Colors.white,
              onSurface: Colors.black87,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  void _handleContinue() {
    final validationError = BookingCutoffValidator.validateBookingDate(date: _selectedDate, tour: widget.tour);
    if (validationError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(validationError),
          backgroundColor: Colors.red.shade800,
        ),
      );
      return;
    }
    widget.onContinueToBooking(_selectedDate, _travelers);
  }

  void _shareTour() {
    HapticFeedback.selectionClick();
    Clipboard.setData(ClipboardData(
      text: 'Discover ${widget.tour.title} on PuneExplorer!\n'
          'Price: ₹${widget.tour.price.toInt()} per traveler\n'
          'Explore Pune: https://puneexplorer.app/booking/${widget.tour.id}',
    ));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Tour link for "${widget.tour.title}" copied to clipboard!'),
        backgroundColor: AppColors.emerald,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return ResponsiveBuilder(
      mobile: _buildMobileLayout(isDark, theme),
      tablet: _buildDesktopLayout(isDark, theme),
      desktop: _buildDesktopLayout(isDark, theme),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // DESKTOP LAYOUT (Split 2-Column with Sticky Booking Summary Card)
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildDesktopLayout(bool isDark, ThemeData theme) {
    final currencyFormatter = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Navigation Bar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton.icon(
                onPressed: widget.onBack,
                icon: const Icon(Icons.arrow_back_rounded, size: 18, color: AppColors.emerald),
                label: const Text(
                  'Back to Tours',
                  style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.emerald, fontSize: 14),
                ),
                style: TextButton.styleFrom(
                  backgroundColor: AppColors.emerald.withValues(alpha: 0.08),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
              Row(
                children: [
                  IconButton(
                    icon: Icon(
                      _isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                      color: _isFavorite ? AppColors.error : (isDark ? Colors.white70 : Colors.black54),
                    ),
                    tooltip: 'Save to Favorites',
                    onPressed: () {
                      setState(() => _isFavorite = !_isFavorite);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(_isFavorite ? 'Saved to Favorites' : 'Removed from Favorites'),
                          duration: const Duration(seconds: 1),
                        ),
                      );
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.share_outlined, color: isDark ? Colors.white70 : Colors.black54),
                    tooltip: 'Share Tour',
                    onPressed: _shareTour,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Main Hero Banner Card
          _buildHeroCard(isDark, theme, isMobile: false),
          const SizedBox(height: 16),

          // 2-Column Split: Content (65%) & Sticky Booking Card (35%)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left Column: Gallery, About This Tour, Tabs & Detailed Info
              Expanded(
                flex: 65,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildGalleryStrip(isDark),
                    const SizedBox(height: 20),
                    _buildAboutThisTourCard(isDark, theme),
                    const SizedBox(height: 20),
                    _buildTabsHeader(isDark),
                    const SizedBox(height: 20),
                    _buildTabContent(isDark, theme),
                  ],
                ),
              ),
              const SizedBox(width: 28),

              // Right Column: Sticky Booking Summary Card + Expert Help + Discover Promo
              Expanded(
                flex: 35,
                child: Column(
                  children: [
                    _buildDesktopBookingCard(isDark, theme, currencyFormatter),
                    const SizedBox(height: 16),
                    _buildHelpCard(isDark, theme),
                    const SizedBox(height: 16),
                    _buildDiscoverPromoCard(isDark, theme),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // MOBILE LAYOUT (Full-Bleed Hero, Compact Tabs, Sticky Bottom Bar)
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildMobileLayout(bool isDark, ThemeData theme) {
    final currencyFormatter = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);

    return Scaffold(
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 110),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Full bleed hero with back button overlay
                _buildHeroCard(isDark, theme, isMobile: true),
                const SizedBox(height: 14),

                // Gallery Strip
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: _buildGalleryStrip(isDark, isMobile: true),
                ),
                const SizedBox(height: 16),

                // About This Tour Card
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: _buildAboutThisTourCard(isDark, theme),
                ),
                const SizedBox(height: 16),

                // Tab Bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: _buildTabsHeader(isDark),
                ),
                const SizedBox(height: 16),

                // Tab Content
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: _buildTabContent(isDark, theme),
                ),
                const SizedBox(height: 16),

                // Mobile Help Card
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: _buildHelpCard(isDark, theme),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),

          // Sticky Bottom Booking Bar
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : Colors.white,
                border: Border(top: BorderSide(color: isDark ? AppColors.darkBorder : AppColors.lightBorder)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.08),
                    blurRadius: 16,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: SafeArea(
                top: false,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${currencyFormatter.format(widget.tour.price)} / traveler',
                          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: AppColors.emerald),
                        ),
                        const Text(
                          'Best Price Guaranteed',
                          style: TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                    CustomButton(
                      text: 'Continue to Booking →',
                      variant: ButtonVariant.saffron,
                      height: 46,
                      onPressed: _handleContinue,
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

  // ── HERO CARD ──────────────────────────────────────────────────────────────
  Widget _buildHeroCard(bool isDark, ThemeData theme, {required bool isMobile}) {
    final images = widget.tour.images.isNotEmpty ? widget.tour.images : [widget.tour.primaryImage];
    final activeImg = images[_activeGalleryIndex.clamp(0, images.length - 1)];

    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(isMobile ? 0 : 20),
          child: Container(
            height: isMobile ? 320 : 380,
            width: double.infinity,
            foregroundDecoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.4),
                  Colors.black.withValues(alpha: 0.15),
                  Colors.black.withValues(alpha: 0.85),
                ],
                stops: const [0.0, 0.45, 1.0],
              ),
            ),
            child: AppCardImage(
              imageUrl: activeImg,
              width: double.infinity,
              height: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
        ),

        // Desktop Cursive Slogan (Top Right)
        if (!isMobile)
          Positioned(
            top: 22,
            right: 24,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'Explore Heritage',
                  style: GoogleFonts.playfairDisplay(
                    color: Colors.white,
                    fontSize: 22,
                    fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.w700,
                    shadows: [
                      Shadow(
                        color: Colors.black.withValues(alpha: 0.7),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ),
                Text(
                  'Live the Adventure',
                  style: GoogleFonts.playfairDisplay(
                    color: Colors.white,
                    fontSize: 20,
                    fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.w600,
                    shadows: [
                      Shadow(
                        color: Colors.black.withValues(alpha: 0.7),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

        // Desktop View Gallery Button (Bottom Right)
        if (!isMobile)
          Positioned(
            bottom: 20,
            right: 20,
            child: InkWell(
              onTap: () => _openGalleryModal(context),
              borderRadius: BorderRadius.circular(10),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.white30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.photo_library_outlined, color: Colors.white, size: 16),
                    SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'View Gallery',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 11),
                        ),
                        Text(
                          '24 Photos',
                          style: TextStyle(color: Colors.white70, fontSize: 9.5, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

        // Mobile top overlay bar
        if (isMobile)
          Positioned(
            top: 40,
            left: 16,
            right: 16,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CircleAvatar(
                  backgroundColor: Colors.black54,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 20),
                    onPressed: widget.onBack,
                  ),
                ),
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.black54,
                      child: IconButton(
                        icon: Icon(
                          _isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                          color: _isFavorite ? AppColors.error : Colors.white,
                          size: 20,
                        ),
                        onPressed: () => setState(() => _isFavorite = !_isFavorite),
                      ),
                    ),
                    const SizedBox(width: 8),
                    CircleAvatar(
                      backgroundColor: Colors.black54,
                      child: IconButton(
                        icon: const Icon(Icons.share_outlined, color: Colors.white, size: 20),
                        onPressed: _shareTour,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

        // Hero Info Overlay (Bottom)
        Positioned(
          left: 20,
          right: isMobile ? 20 : 180,
          bottom: 20,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Dual Badges Row: [ Fort & Caves ] [ Cave & Fort ]
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF47A00),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      widget.tour.badge.isNotEmpty ? widget.tour.badge : 'Fort & Caves',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 11),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.emerald,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      widget.tour.category.isNotEmpty ? widget.tour.category : 'Cave & Fort',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 11),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Title
              Text(
                widget.tour.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 23,
                  height: 1.25,
                ),
              ),
              const SizedBox(height: 6),

              // Subtitle
              Text(
                widget.tour.subtitle.isNotEmpty
                    ? widget.tour.subtitle
                    : '22 rock-cut Buddhist monasteries, rare stupa galleries, and the iron-strong Lohagad fort ramparts.',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Colors.white70, fontSize: 12.5, height: 1.3),
              ),
              const SizedBox(height: 10),

              // Meta chips row
              Wrap(
                spacing: 12,
                runSpacing: 6,
                children: [
                  _buildMetaChip(Icons.star_rounded, '${widget.tour.rating} (${widget.tour.reviewCount} reviews)', Colors.amber),
                  _buildMetaChip(Icons.access_time_rounded, widget.tour.duration, Colors.white),
                  _buildMetaChip(Icons.directions_walk_rounded, 'Moderate', Colors.white),
                  _buildMetaChip(Icons.group_rounded, 'Ideal for Groups', Colors.white),
                ],
              ),
              const SizedBox(height: 10),

              // Feature Tags Pills Row
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: [
                  _buildFeaturePill(Icons.terrain_rounded, 'Trekking', const Color(0xFF0F5132)),
                  _buildFeaturePill(Icons.account_balance_rounded, 'Historical', const Color(0xFF0D6858)),
                  _buildFeaturePill(Icons.photo_camera_rounded, 'Photography', const Color(0xFF0D6858)),
                  _buildFeaturePill(Icons.forest_rounded, 'Nature Trails', const Color(0xFF0F5132)),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMetaChip(IconData icon, String label, Color iconColor) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: iconColor, size: 14),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildFeaturePill(IconData icon, String label, Color bg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bg.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white24),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 13),
          const SizedBox(width: 5),
          Text(
            label,
            style: const TextStyle(color: Colors.white, fontSize: 11.5, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }

  // ── GALLERY STRIP ──────────────────────────────────────────────────────────
  Widget _buildGalleryStrip(bool isDark, {bool isMobile = false}) {
    final images = widget.tour.images.isNotEmpty
        ? widget.tour.images
        : [
            'assets/images/bhaja_chaitya_hall_hd.jpg',
            'assets/images/lohagad_fort_ramparts_hd.jpg',
            'assets/images/bhaja_trail_steps_hd.jpg',
          ];

    final displayCount = isMobile ? (images.length > 4 ? 4 : images.length) : (images.length > 3 ? 3 : images.length);

    return SizedBox(
      height: 85,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: displayCount,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final isSelected = index == _activeGalleryIndex;
          final isOverlayItem = isMobile && index == 3;

          return GestureDetector(
            onTap: () {
              if (isOverlayItem) {
                _openGalleryModal(context);
              } else {
                setState(() => _activeGalleryIndex = index);
              }
            },
            child: Container(
              width: 115,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected ? AppColors.emerald : Colors.transparent,
                  width: 2.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.06),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: AppCardImage(
                      imageUrl: images[index % images.length],
                      fit: BoxFit.cover,
                    ),
                  ),
                  if (isOverlayItem)
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.65),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      alignment: Alignment.center,
                      child: const Text(
                        '+24',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _openGalleryModal(BuildContext context) {
    final images = widget.tour.images.isNotEmpty
        ? widget.tour.images
        : [
            'assets/images/bhaja_lohagad_hero_hd.jpg',
            'assets/images/bhaja_chaitya_hall_hd.jpg',
            'assets/images/lohagad_fort_ramparts_hd.jpg',
            'assets/images/bhaja_trail_steps_hd.jpg',
          ];

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) {
          return Dialog(
            backgroundColor: Colors.black.withValues(alpha: 0.94),
            insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: SizedBox(
              width: 820,
              height: 560,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(18, 12, 12, 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${_activeGalleryIndex + 1} of ${images.length} Photos',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 14),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close_rounded, color: Colors.white),
                          onPressed: () => Navigator.of(ctx).pop(),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: AppCardImage(
                            imageUrl: images[_activeGalleryIndex % images.length],
                            fit: BoxFit.contain,
                          ),
                        ),
                        Positioned(
                          left: 8,
                          child: CircleAvatar(
                            backgroundColor: Colors.black54,
                            child: IconButton(
                              icon: const Icon(Icons.chevron_left_rounded, color: Colors.white),
                              onPressed: () {
                                setModalState(() {
                                  setState(() {
                                    _activeGalleryIndex = (_activeGalleryIndex - 1 + images.length) % images.length;
                                  });
                                });
                              },
                            ),
                          ),
                        ),
                        Positioned(
                          right: 8,
                          child: CircleAvatar(
                            backgroundColor: Colors.black54,
                            child: IconButton(
                              icon: const Icon(Icons.chevron_right_rounded, color: Colors.white),
                              onPressed: () {
                                setModalState(() {
                                  setState(() {
                                    _activeGalleryIndex = (_activeGalleryIndex + 1) % images.length;
                                  });
                                });
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    height: 72,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: images.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 8),
                      itemBuilder: (_, idx) {
                        final sel = idx == _activeGalleryIndex;
                        return GestureDetector(
                          onTap: () {
                            setModalState(() {
                              setState(() => _activeGalleryIndex = idx);
                            });
                          },
                          child: Container(
                            width: 72,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: sel ? AppColors.emerald : Colors.transparent,
                                width: 2,
                              ),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: AppCardImage(
                                imageUrl: images[idx],
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ── ABOUT THIS TOUR CARD ───────────────────────────────────────────────────
  Widget _buildAboutThisTourCard(bool isDark, ThemeData theme) {
    final highlights = widget.tour.highlights.isNotEmpty
        ? widget.tour.highlights
        : [
            'Explore 22 ancient rock-cut caves',
            'Trek to the historic Lohagad Fort',
            'Learn about Buddhist history',
            'Scenic views & photography points',
          ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'About This Tour',
            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800, fontSize: 16),
          ),
          const SizedBox(height: 10),
          Text(
            widget.tour.subtitle.isNotEmpty
                ? 'Explore the ancient Bhaja Caves, a group of 22 rock-cut Buddhist monasteries dating back to the 2nd century BCE, and trek to the majestic Lohagad Fort with panoramic views of the Sahyadri ranges.'
                : 'Begin your day with an unforgettable journey to Pune\'s most revered historic peaks. Soak in breathtaking panoramic valley views, explore century-old bastions and gates, and conclude with a traditional home-style feast prepared by local village families.',
            style: TextStyle(
              fontSize: 13,
              height: 1.55,
              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Highlights',
            style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800, fontSize: 14),
          ),
          const SizedBox(height: 10),
          Column(
            children: highlights.map((h) => _buildHighlightCard(h, isDark)).toList(),
          ),
        ],
      ),
    );
  }

  // ── TABS HEADER ────────────────────────────────────────────────────────────
  Widget _buildTabsHeader(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
            width: 1.5,
          ),
        ),
      ),
      child: TabBar(
        controller: _tabController,
        isScrollable: true,
        labelColor: AppColors.emerald,
        unselectedLabelColor: isDark ? Colors.white60 : Colors.black54,
        indicatorColor: AppColors.emerald,
        indicatorWeight: 3,
        tabAlignment: TabAlignment.start,
        labelStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
        tabs: const [
          Tab(text: 'Overview'),
          Tab(text: 'Itinerary'),
          Tab(text: 'Inclusions'),
          Tab(text: 'Reviews'),
          Tab(text: 'FAQs'),
        ],
      ),
    );
  }

  // ── TABS CONTENT ───────────────────────────────────────────────────────────
  Widget _buildTabContent(bool isDark, ThemeData theme) {
    return AnimatedBuilder(
      animation: _tabController,
      builder: (context, _) {
        switch (_tabController.index) {
          case 0:
            return _buildOverviewTab(isDark, theme);
          case 1:
            return _buildItineraryTab(isDark, theme);
          case 2:
            return _buildInclusionsTab(isDark, theme);
          case 3:
            return _buildReviewsTab(isDark, theme);
          case 4:
            return _buildFAQsTab(isDark, theme);
          default:
            return _buildOverviewTab(isDark, theme);
        }
      },
    );
  }

  Widget _buildOverviewTab(bool isDark, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tour Experience & Guide',
          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 10),
        Text(
          widget.tour.subtitle.isNotEmpty
              ? widget.tour.subtitle
              : 'Begin your day with an unforgettable journey to Pune\'s most revered historic peaks. Soak in breathtaking panoramic valley views, explore century-old bastions and gates, and conclude with a traditional home-style feast prepared by local village families.',
          style: TextStyle(
            fontSize: 13.5,
            height: 1.6,
            color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
          ),
        ),
        const SizedBox(height: 20),

        // Guide Info Card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
          ),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: const BoxDecoration(
                  color: AppColors.emerald,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.badge_rounded, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Certified Local Historian & Guide', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13.5)),
                    SizedBox(height: 2),
                    Text('Fluent in Marathi, Hindi & English • First-Aid Certified', style: TextStyle(fontSize: 12, color: Colors.grey)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHighlightCard(String text, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurfaceVariant : Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
      ),
      child: Row(
        children: [
          Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              color: AppColors.emerald.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check_rounded, color: AppColors.emerald, size: 14),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItineraryTab(bool isDark, ThemeData theme) {
    final items = widget.tour.itinerary.isNotEmpty
        ? widget.tour.itinerary
        : [
            const TourItineraryItem(time: '05:30 AM', title: 'Pickup at Swargate Terminal', desc: 'Board the AC coach; briefing by tour lead.'),
            const TourItineraryItem(time: '06:45 AM', title: 'Arrival at Base & Sunrise Trek', desc: 'Ascend via the scenic trail as the sun rises over Khadakwasla lake.'),
            const TourItineraryItem(time: '08:30 AM', title: 'Fort Exploration & Historic Gates', desc: 'Visit Tanaji Malusare Memorial, Kalyan Darwaza, and Tanaji Kada.'),
            const TourItineraryItem(time: '12:30 PM', title: 'Traditional Maharashtrian Feast', desc: 'Relish hot bhakri, pitla, kanda bhaji, and fresh mattha at the fort summit.'),
            const TourItineraryItem(time: '03:30 PM', title: 'Return Journey to Pune', desc: 'Drop-off at starting pickup locations.'),
          ];

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final item = items[index];
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.emerald.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    item.time,
                    style: const TextStyle(color: AppColors.emerald, fontWeight: FontWeight.w800, fontSize: 11),
                  ),
                ),
                if (index < items.length - 1)
                  Container(
                    width: 2,
                    height: 40,
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    color: AppColors.emerald.withValues(alpha: 0.2),
                  ),
              ],
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13.5)),
                    const SizedBox(height: 4),
                    Text(item.desc, style: const TextStyle(fontSize: 12, color: Colors.grey, height: 1.3)),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildInclusionsTab(bool isDark, ThemeData theme) {
    final inclusions = widget.tour.inclusions.isNotEmpty
        ? widget.tour.inclusions
        : ['AC Coach Transport', 'Guided Heritage Walk', 'Authentic Lunch Feast', 'Entry Tickets & Permits'];
    final exclusions = widget.tour.exclusions.isNotEmpty
        ? widget.tour.exclusions
        : ['Personal Shopping & Souvenirs', 'Camera & Drone Fees', 'Alcoholic Beverages'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('What\'s Included', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800)),
        const SizedBox(height: 8),
        ...inclusions.map((i) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  const Icon(Icons.check_circle_rounded, color: AppColors.emerald, size: 16),
                  const SizedBox(width: 8),
                  Expanded(child: Text(i, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600))),
                ],
              ),
            )),
        const SizedBox(height: 18),
        Text('What\'s Excluded', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800)),
        const SizedBox(height: 8),
        ...exclusions.map((e) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  const Icon(Icons.cancel_rounded, color: AppColors.error, size: 16),
                  const SizedBox(width: 8),
                  Expanded(child: Text(e, style: const TextStyle(fontSize: 13, color: Colors.grey))),
                ],
              ),
            )),
      ],
    );
  }

  Widget _buildReviewsTab(bool isDark, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
          ),
          child: Row(
            children: [
              Text(
                '${widget.tour.rating}',
                style: const TextStyle(fontSize: 36, fontWeight: FontWeight.w900, color: AppColors.emerald),
              ),
              const SizedBox(width: 14),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: List.generate(
                      5,
                      (i) => const Icon(Icons.star_rounded, color: Colors.amber, size: 18),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text('Based on ${widget.tour.reviewCount} verified travelers', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        _buildSampleReview('Ananya Joshi', 'Amazing experience! The sunrise at Sinhagad was magical and the rural pitla bhakri meal was to die for. Very well organized!', '5.0', '2 days ago', isDark),
        _buildSampleReview('Rohan Kulkarni', 'Comfortable coach and very knowledgeable guide. Great for both locals and tourists wanting to explore Pune properly.', '5.0', '1 week ago', isDark),
      ],
    );
  }

  Widget _buildSampleReview(String name, String comment, String rating, String date, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(name, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
              Row(
                children: [
                  const Icon(Icons.star_rounded, color: Colors.amber, size: 14),
                  Text(rating, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(comment, style: const TextStyle(fontSize: 12.5, height: 1.35)),
          const SizedBox(height: 4),
          Text(date, style: const TextStyle(fontSize: 11, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildFAQsTab(bool isDark, ThemeData theme) {
    final faqs = [
      {
        'q': 'What is the cancellation policy?',
        'a': 'Free cancellation with full refund up to 24 hours prior to tour departure. 50% refund between 12-24 hours. No cancellation fee within the standard window.',
        'open': true,
      },
      {
        'q': 'Is the trek suitable for senior citizens and children?',
        'a': 'Yes, the path has paved stone stairs and handrails. Children aged 6+ and active seniors can comfortably complete the climb with occasional breaks.',
        'open': false,
      },
      {
        'q': 'Are vegetarian and Jain meals available?',
        'a': 'Yes! All provided meals are 100% pure vegetarian with Jain options available on prior request during booking.',
        'open': false,
      },
      {
        'q': 'What should I carry for the trek?',
        'a': 'Comfortable trekking/sports shoes, 2L water bottle, light rain jacket during monsoon, sun protection cap, and a valid photo ID.',
        'open': false,
      },
      {
        'q': 'Is there a guide throughout the trip?',
        'a': 'Yes, an experienced English and Marathi-speaking certified PuneExplorer heritage guide accompanies the tour throughout the day.',
        'open': false,
      },
    ];

    return Column(
      children: faqs
          .map((f) => Container(
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkSurface : Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                ),
                child: ExpansionTile(
                  initiallyExpanded: f['open'] as bool,
                  title: Text(f['q'] as String, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
                      child: Text(f['a'] as String, style: const TextStyle(fontSize: 12.5, color: Colors.grey, height: 1.4)),
                    ),
                  ],
                ),
              ))
          .toList(),
    );
  }

  Widget _buildHelpCard(bool isDark, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.emerald.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.support_agent_rounded, color: AppColors.emerald, size: 26),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Need Help?',
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
                ),
                const SizedBox(height: 2),
                Text(
                  'Talk to our travel expert',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  '📞 1800-PUNE-DARSHAN (7 AM – 9 PM)',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                    color: AppColors.emerald,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDiscoverPromoCard(bool isDark, ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            const AppCardImage(
              imageUrl: 'assets/images/pune_discover_promo_hd.jpg',
              height: 140,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
            Container(
              height: 140,
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.2),
                    Colors.black.withValues(alpha: 0.75),
                  ],
                ),
              ),
              padding: const EdgeInsets.all(16),
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Discover More PuneExplorer',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Explore 50+ curated experiences across Pune & Sahyadri',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── DESKTOP STICKY BOOKING CARD ────────────────────────────────────────────
  Widget _buildDesktopBookingCard(bool isDark, ThemeData theme, NumberFormat currencyFormatter) {
    final totalPrice = widget.tour.price * _travelers;

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.06),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Price Header
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                currencyFormatter.format(widget.tour.price),
                style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 26, color: AppColors.emerald),
              ),
              const Text(' / traveler', style: TextStyle(fontSize: 13, color: Colors.grey, fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: AppColors.emerald.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.verified_rounded, size: 13, color: AppColors.emerald),
                SizedBox(width: 4),
                Text('Best Price Guaranteed', style: TextStyle(color: AppColors.emerald, fontSize: 11, fontWeight: FontWeight.w800)),
              ],
            ),
          ),
          const Divider(height: 28),

          // Date Selector Box
          const Text('Date', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
          const SizedBox(height: 6),
          InkWell(
            onTap: () => _pickDate(context),
            borderRadius: BorderRadius.circular(10),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.calendar_today_rounded, size: 16, color: AppColors.emerald),
                      const SizedBox(width: 10),
                      Text(
                        DateFormat('EEE, dd MMM yyyy').format(_selectedDate),
                        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5),
                      ),
                    ],
                  ),
                  const Icon(Icons.arrow_drop_down_rounded, color: Colors.grey),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Travelers Counter Box
          const Text('Travelers', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Expanded(
                  child: Text(
                    'Number of Travelers',
                    style: TextStyle(fontSize: 13, color: Colors.grey),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove_circle_outline, size: 20),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                      color: _travelers > 1 ? AppColors.emerald : Colors.grey,
                      onPressed: _travelers > 1 ? () => setState(() => _travelers--) : null,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Text(
                        '$_travelers',
                        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add_circle_outline, size: 20),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                      color: _travelers < 10 ? AppColors.emerald : Colors.grey,
                      onPressed: _travelers < 10 ? () => setState(() => _travelers++) : null,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Total Price Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Total', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
              Text(
                currencyFormatter.format(totalPrice),
                style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 22, color: AppColors.emerald),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Continue Button
          CustomButton(
            text: 'Continue to Booking →',
            variant: ButtonVariant.saffron,
            isFullWidth: true,
            height: 50,
            onPressed: _handleContinue,
          ),
          const SizedBox(height: 20),

          // Trust Indicators
          _buildTrustItem(Icons.security_rounded, 'Free cancellation up to 24 hrs'),
          const SizedBox(height: 8),
          _buildTrustItem(Icons.bolt_rounded, 'Instant confirmation'),
          const SizedBox(height: 8),
          _buildTrustItem(Icons.people_alt_outlined, 'Trusted by 1,000+ travelers'),
        ],
      ),
    );
  }

  Widget _buildTrustItem(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 15, color: AppColors.emerald),
        const SizedBox(width: 8),
        Expanded(
          child: Text(text, style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w600)),
        ),
      ],
    );
  }
}
