import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/utils/image_optimizer.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/responsive/responsive_builder.dart';
import '../../../data/models/itinerary_model.dart';
import '../../../services/itinerary_service.dart';
import 'widgets/custom_trip_booking_modal.dart';

/// Premium "Plan a Trip" Screen matching visual reference mockup:
/// - Panoramic Sinhagad Fort Hero with poetic quote, dashed mountain route pin,
/// - Architectural Emerald "Smart Trip Studio" card with SMART PICKS badge & feature pills,
/// - Visual Travel Theme Selector with rich destination imagery & "Suggest with AI",
/// - Duration, Travel Pace, Companion, and Budget selectors with active states,
/// - High-contrast Terracotta Gradient "✨ Generate Custom Itinerary →" CTA,
/// - "My Saved Trips" deck with thumbnail imagery, duration pills, and view schedule,
/// - Curated Pune Master Circuits, Smart Travel Essentials checklist, and Seasonal Advisory.
class ItineraryPlannerScreen extends ConsumerStatefulWidget {
  const ItineraryPlannerScreen({super.key});

  @override
  ConsumerState<ItineraryPlannerScreen> createState() => _ItineraryPlannerScreenState();
}

class _ItineraryPlannerScreenState extends ConsumerState<ItineraryPlannerScreen> {
  // Generator State
  int _selectedThemeIndex = 0;
  int _selectedDurationDays = 2;
  int _selectedPaceIndex = 1; // 0: Relaxed, 1: Balanced, 2: Packed
  int _selectedTravelStyleIndex = 0; // 0: Solo, 1: Couple, 2: Family, 3: Friends, 4: Large Group
  int _selectedBudgetIndex = 1; // 0: Budget, 1: Moderate, 2: Luxury
  bool _isGenerating = false;

  // Packing Checklist State
  late List<_PackingItem> _packingItems;
  final Map<int, bool> _checklistState = {
    0: true,
    1: true,
    2: false,
    3: false,
    4: false,
  };

  final List<_TripTheme> _tripThemes = const [
    _TripTheme(
      icon: '🏰',
      title: 'Heritage & Forts',
      marathiSubtitle: 'सिंहगड, शनिवार वाडा व लोहगड',
      subtitle: 'Sinhagad, Shaniwar Wada, Lohagad and more',
      imageUrl: 'https://images.unsplash.com/photo-1626621341517-bbf3d9990a23?q=80&w=600&auto=format&fit=crop',
      color: Color(0xFFD97706),
      gradient: [Color(0xFFB45309), Color(0xFFD97706)],
    ),
    _TripTheme(
      icon: '🍛',
      title: 'Food & Culture',
      marathiSubtitle: 'पुणेरी मिसळ, चितळे व एफसी रोड',
      subtitle: 'FC Road, Vaishali, Sujata Mastani',
      imageUrl: 'https://images.unsplash.com/photo-1601050690597-df0568f70950?q=80&w=600&auto=format&fit=crop',
      color: Color(0xFFEA580C),
      gradient: [Color(0xFFC2410C), Color(0xFFEA580C)],
    ),
    _TripTheme(
      icon: '🏕️',
      title: 'Adventure & Camping',
      marathiSubtitle: 'राजमाची, तोरणा व कॅम्पिंग',
      subtitle: 'Rajmachi, Torna & Lakeside Camps',
      imageUrl: 'https://images.unsplash.com/photo-1510312305653-8ed496efae75?q=80&w=600&auto=format&fit=crop',
      color: Color(0xFF7C3AED),
      gradient: [Color(0xFF6D28D9), Color(0xFF8B5CF6)],
    ),
    _TripTheme(
      icon: '🎭',
      title: 'Art & Museums',
      marathiSubtitle: 'राजा केळकर व आगाखान पॅलेस',
      subtitle: 'Raja Kelkar & Aga Khan Palace',
      imageUrl: 'https://images.unsplash.com/photo-1561361058-c24cecae35ca?q=80&w=600&auto=format&fit=crop',
      color: Color(0xFFDB2777),
      gradient: [Color(0xFFBE185D), Color(0xFFEC4899)],
    ),
    _TripTheme(
      icon: '🛕',
      title: 'Spiritual Darshan',
      marathiSubtitle: 'दगडूशेठ, आळंदी व देहू संकुल',
      subtitle: 'Temples, Ashrams & Sacred Places',
      imageUrl: 'https://images.unsplash.com/photo-1563379091339-03246963d96c?q=80&w=600&auto=format&fit=crop',
      color: Color(0xFF059669),
      gradient: [Color(0xFF047857), Color(0xFF10B981)],
    ),
    _TripTheme(
      icon: '🌊',
      title: 'Lakes & Ghats',
      marathiSubtitle: 'पवना तलाव, ताम्हिणी व मुळशी',
      subtitle: 'Mulshi, Tamhini, Kundalika & more',
      imageUrl: 'https://images.unsplash.com/photo-1508873696983-2df5293cb395?q=80&w=600&auto=format&fit=crop',
      color: Color(0xFF0284C7),
      gradient: [Color(0xFF0369A1), Color(0xFF0EA5E9)],
    ),
  ];

  final List<_CuratedTemplate> _curatedTemplates = const [
    _CuratedTemplate(
      icon: '🏰',
      title: 'Monsoon Forts & Waterfalls Trail',
      duration: '2 Days • 5 Stops',
      difficulty: 'Moderate',
      budget: '₹1,200',
      badgeColor: Color(0xFF059669),
      highlights: 'Sinhagad Sunrise, Pitla Bhakri, Tamhini Ghat Waterfalls',
      imageUrl: 'https://images.unsplash.com/photo-1508873696983-2df5293cb395?q=80&w=400&auto=format&fit=crop',
      themeIndex: 0,
    ),
    _CuratedTemplate(
      icon: '🍛',
      title: 'Old Pune Cultural & Food Trail',
      duration: '1 Day • 6 Stops',
      difficulty: 'Easy',
      budget: '₹650',
      badgeColor: Color(0xFFD97706),
      highlights: 'Shaniwar Wada, Tulshibaug, Sujata Mastani, FC Road',
      imageUrl: 'https://images.unsplash.com/photo-1601050690597-df0568f70950?q=80&w=400&auto=format&fit=crop',
      themeIndex: 1,
    ),
    _CuratedTemplate(
      icon: '🏕️',
      title: 'Western Ghats Lake & Camping',
      duration: '2 Days • 4 Stops',
      difficulty: 'Adventurous',
      budget: '₹1,800',
      badgeColor: Color(0xFF0284C7),
      highlights: 'Pawna Boating, Lohagad Trek, Lakeside Campfire',
      imageUrl: 'https://images.unsplash.com/photo-1510312305653-8ed496efae75?q=80&w=400&auto=format&fit=crop',
      themeIndex: 2,
    ),
    _CuratedTemplate(
      icon: '🛕',
      title: 'Sacred Temples & Heritage Circuit',
      duration: '1 Day • 5 Stops',
      difficulty: 'Easy',
      budget: '₹500',
      badgeColor: Color(0xFFE05305),
      highlights: 'Dagdusheth Ganpati, Kasba Peth, Parvati Hilltop',
      imageUrl: 'https://images.unsplash.com/photo-1563379091339-03246963d96c?q=80&w=400&auto=format&fit=crop',
      themeIndex: 4,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _packingItems = [
      const _PackingItem(icon: '🆔', title: 'Gov ID & Booking E-Passes', subtitle: 'Required at forts and monument entries'),
      const _PackingItem(icon: '👟', title: 'High-Grip Trekking Shoes', subtitle: 'Essential for rocky Sinhagad slopes'),
      const _PackingItem(icon: '🔋', title: '20,000mAh Power Bank', subtitle: 'GPS & camera battery drains fast on ghats'),
      const _PackingItem(icon: '💧', title: '2L Refillable Water Bottle', subtitle: 'Stay hydrated during morning treks'),
      const _PackingItem(icon: '💊', title: 'First-Aid Kit & ORS Sachets', subtitle: 'Basic medication & anti-motion pills'),
    ];
  }

  void _shuffleSuggestion() {
    HapticFeedback.mediumImpact();
    final rand = Random();
    final newTheme = rand.nextInt(_tripThemes.length);
    final newDuration = [1, 2, 3, 4, 5][rand.nextInt(5)];
    final newPace = rand.nextInt(3);
    final newCompanion = rand.nextInt(5);
    final newBudget = rand.nextInt(3);

    setState(() {
      _selectedThemeIndex = newTheme;
      _selectedDurationDays = newDuration;
      _selectedPaceIndex = newPace;
      _selectedTravelStyleIndex = newCompanion;
      _selectedBudgetIndex = newBudget;
    });

    final paceNames = ['Relaxed', 'Balanced', 'Packed'];
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Text('✨', style: TextStyle(fontSize: 18)),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Suggested: ${_tripThemes[newTheme].title} ($newDuration Day${newDuration > 1 ? 's' : ''}, ${paceNames[newPace]} pace)!',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF064E3B),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Future<void> _generateSmartPlan() async {
    setState(() => _isGenerating = true);
    HapticFeedback.mediumImpact();

    final theme = _tripThemes[_selectedThemeIndex];
    final destinations = ref.read(destinationsAsyncProvider).value ?? [];
    final startDate = DateTime.now().add(const Duration(days: 2));

    final newPlan = ItineraryService.createNewPlan(
      title: '${theme.title} Explorer',
      description: '${theme.subtitle}. Smart $_selectedDurationDays-Day itinerary tailored for Pune travelers.',
      startDate: DateFormat('yyyy-MM-dd').format(startDate),
      totalDays: _selectedDurationDays,
      initialDestinations: destinations.take(_selectedDurationDays * 2).toList(),
    );

    await ref.read(userItinerariesProvider.notifier).savePlan(newPlan);

    if (mounted) {
      setState(() => _isGenerating = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Text('✨', style: TextStyle(fontSize: 18)),
              const SizedBox(width: 8),
              Expanded(child: Text('"${newPlan.title}" created successfully!')),
            ],
          ),
          backgroundColor: const Color(0xFF064E3B),
          behavior: SnackBarBehavior.floating,
        ),
      );
      context.push('/itinerary/${newPlan.id}');
    }
  }

  void _showAddCustomItemDialog() {
    final titleCtrl = TextEditingController();
    final subtitleCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Text('🎒', style: TextStyle(fontSize: 22)),
            const SizedBox(width: 8),
            Text(
              'Add Packing Item',
              style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, fontSize: 17),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleCtrl,
              autofocus: true,
              decoration: const InputDecoration(
                labelText: 'Item Name',
                hintText: 'e.g. Rain poncho, Sunscreen',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: subtitleCtrl,
              decoration: const InputDecoration(
                labelText: 'Reminder Note',
                hintText: 'e.g. For sudden monsoon showers',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (titleCtrl.text.trim().isEmpty) return;
              setState(() {
                final newIndex = _packingItems.length;
                _packingItems.add(_PackingItem(
                  icon: '📌',
                  title: titleCtrl.text.trim(),
                  subtitle: subtitleCtrl.text.trim().isEmpty ? 'Custom travel essential' : subtitleCtrl.text.trim(),
                ));
                _checklistState[newIndex] = false;
              });
              Navigator.of(ctx).pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF064E3B),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Add Item'),
          ),
        ],
      ),
    );
  }

  void _showCreateCustomModal(BuildContext context) {
    final titleCtrl = TextEditingController(text: 'My Pune Exploration');
    final descCtrl = TextEditingController(text: 'Custom itinerary with favorite viewpoints, food spots & forts.');
    int totalDays = 2;
    DateTime startDate = DateTime.now().add(const Duration(days: 2));
    String selectedIcon = '🗺️';

    final icons = ['🗺️', '🏰', '🏕️', '🍛', '🛕', '🚗', '📸', '🎒'];

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
          title: Row(
            children: [
              const Text('✨', style: TextStyle(fontSize: 22)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Create Custom Trip',
                  style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, fontSize: 18),
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Choose Trip Avatar:', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 12)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: icons.map((ic) {
                    final isSel = ic == selectedIcon;
                    return InkWell(
                      onTap: () => setModalState(() => selectedIcon = ic),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isSel ? const Color(0xFF064E3B).withValues(alpha: 0.18) : Colors.grey.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSel ? const Color(0xFF064E3B) : Colors.transparent,
                            width: 1.5,
                          ),
                        ),
                        child: Text(ic, style: const TextStyle(fontSize: 20)),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: titleCtrl,
                  decoration: InputDecoration(
                    labelText: 'Trip Title',
                    hintText: 'e.g. Sinhagad & Tamhini Weekend',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: descCtrl,
                  maxLines: 2,
                  decoration: InputDecoration(
                    labelText: 'Trip Notes / Summary',
                    hintText: 'Add what you want to experience...',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Text('Duration (Days):', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 13)),
                    const Spacer(),
                    Row(
                      children: [
                        IconButton(
                          onPressed: totalDays > 1 ? () => setModalState(() => totalDays--) : null,
                          icon: const Icon(Icons.remove_circle_outline_rounded, size: 20),
                        ),
                        Text('$totalDays', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                        IconButton(
                          onPressed: totalDays < 7 ? () => setModalState(() => totalDays++) : null,
                          icon: const Icon(Icons.add_circle_outline_rounded, size: 20),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                InkWell(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: startDate,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 120)),
                    );
                    if (picked != null) setModalState(() => startDate = picked);
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF064E3B).withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFF064E3B).withValues(alpha: 0.25)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Start Date: ${DateFormat('dd MMM yyyy').format(startDate)}',
                          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 12.5),
                        ),
                        const Icon(Icons.calendar_month_rounded, size: 18, color: Color(0xFF064E3B)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (titleCtrl.text.trim().isEmpty) return;
                final destinations = ref.read(destinationsAsyncProvider).value ?? [];
                final newPlan = ItineraryService.createNewPlan(
                  title: '$selectedIcon ${titleCtrl.text.trim()}',
                  description: descCtrl.text.trim(),
                  startDate: DateFormat('yyyy-MM-dd').format(startDate),
                  totalDays: totalDays,
                  initialDestinations: destinations.take(3).toList(),
                );

                await ref.read(userItinerariesProvider.notifier).savePlan(newPlan);
                if (context.mounted) {
                  Navigator.of(ctx).pop();
                  context.push('/itinerary/${newPlan.id}');
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF064E3B),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text('Build Itinerary'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isDesktop = screenWidth >= 900;
    final itinerariesAsync = ref.watch(userItinerariesProvider);

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 16,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Custom Itinerary Planner',
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.w800,
                fontSize: 18,
                letterSpacing: -0.3,
              ),
            ),
            Text(
              'Plan your perfect Pune getaway',
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.w500,
                fontSize: 11,
                color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF064E3B).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('🎟️', style: TextStyle(fontSize: 13)),
                  if (screenWidth >= 380) ...[
                    const SizedBox(width: 4),
                    Text(
                      'Bookings',
                      style: GoogleFonts.plusJakartaSans(
                        color: const Color(0xFF064E3B),
                        fontWeight: FontWeight.w800,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            tooltip: 'My Bookings',
            onPressed: () => context.push('/my-bookings'),
          ),
          IconButton(
            icon: const Icon(Icons.notifications_none_rounded, size: 22),
            tooltip: 'Notifications',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('No new notifications'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
          ),
          if (isDesktop) ...[
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircleAvatar(
                      radius: 12,
                      backgroundColor: const Color(0xFF064E3B),
                      child: Text('H', style: GoogleFonts.plusJakartaSans(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Hello, Explorer 👋',
                      style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 11.5),
                    ),
                  ],
                ),
              ),
            ),
          ],
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: const Color(0xFF064E3B).withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.add_rounded, color: Color(0xFF064E3B), size: 20),
            ),
            tooltip: 'Create New Itinerary',
            onPressed: () => _showCreateCustomModal(context),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: MaxWidthWrapper(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: ListView(
          physics: const BouncingScrollPhysics(),
          children: [
            // ── 1. Hero Panoramic Banner with Sinhagad Vista & Smart Trip Studio ──
            _buildPanoramicHero(isDark, screenWidth),
            const SizedBox(height: 20),

            // ── 2. Instant Smart AI Trip Generator ──
            _buildSmartGeneratorSection(isDark, screenWidth),
            const SizedBox(height: 24),

            // ── 3. Saved Itineraries Section ──
            _buildSavedItinerariesSection(itinerariesAsync, isDark, screenWidth),
            const SizedBox(height: 24),

            // ── 4. Curated Pune Master Circuits ──
            _buildCuratedTemplatesSection(isDark),
            const SizedBox(height: 24),

            // ── 5. Smart Travel Packing Checklist ──
            _buildPackingChecklistSection(isDark),
            const SizedBox(height: 24),

            // ── 6. Seasonal Trip Advisory ──
            _buildSeasonalAdvisoryCard(isDark),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  // ── 1. Panoramic Hero with Sinhagad & Smart Trip Studio Overlay ─────────────
  Widget _buildPanoramicHero(bool isDark, double screenWidth) {
    final isCompact = screenWidth < 720;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // Background Landscape Image (Sinhagad Sahyadri Vista)
          Positioned.fill(
            child: CachedNetworkImage(
              imageUrl: AppImageOptimizer.forHero(
                'https://images.unsplash.com/photo-1544735716-392fe2489ffa?q=80&w=1600&auto=format&fit=crop',
              ),
              fit: BoxFit.cover,
              alignment: Alignment.topCenter,
              fadeInDuration: const Duration(milliseconds: 250),
              errorWidget: (_, __, ___) => Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF064E3B), Color(0xFF022C22)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
            ),
          ),

          // Vignette & Emerald Tint Gradient Overlay
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.black.withValues(alpha: 0.55),
                    const Color(0xFF064E3B).withValues(alpha: 0.50),
                    const Color(0xFF022C22).withValues(alpha: 0.92),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),

          // Foreground Content
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Tag: Devanagari + AI Travel Studio
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.2),
                          width: 0.8,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('🏛️ ', style: TextStyle(fontSize: 11)),
                          Text(
                            'पुणे सहल नियोजन',
                            style: GoogleFonts.notoSansDevanagari(
                              color: const Color(0xFFFDE68A),
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        'AI & Curated Travel Studio',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                          color: Colors.white.withValues(alpha: 0.85),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Main Title & AI-POWERED Badge Row
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF059669), Color(0xFF047857)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.25), width: 1.0),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF059669).withValues(alpha: 0.35),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      alignment: Alignment.center,
                      child: const Text('🗺️', style: TextStyle(fontSize: 20)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Row(
                        children: [
                          Flexible(
                            child: Text(
                              'Smart Trip Studio',
                              style: GoogleFonts.plusJakartaSans(
                                color: Colors.white,
                                fontWeight: FontWeight.w900,
                                fontSize: isCompact ? 18 : 22,
                                letterSpacing: -0.4,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFEF3C7),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              'SMART PICKS',
                              style: TextStyle(
                                color: Color(0xFF92400E),
                                fontSize: 9,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Subtitle
                Text(
                  'Design custom multi-day Sahyadri circuits, food walks & temple trails.',
                  style: GoogleFonts.plusJakartaSans(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 13,
                    height: 1.35,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),

                // Integrated Story Quote
                Row(
                  children: [
                    Container(
                      width: 2.5,
                      height: 28,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFDE68A),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '"Every journey in Pune is a story waiting to be lived." — Explore • Plan • Experience',
                        style: GoogleFonts.plusJakartaSans(
                          color: Colors.white.withValues(alpha: 0.85),
                          fontSize: 11,
                          fontStyle: FontStyle.italic,
                          fontWeight: FontWeight.w500,
                          height: 1.3,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // 4 Feature Pills
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    _build3DStatPill('⚡', 'Instant Planner', const Color(0xFFF97316)),
                    _build3DStatPill('📍', '45+ Curated Spots', const Color(0xFF10B981)),
                    _build3DStatPill('🎒', 'Packing Checklist', const Color(0xFF0EA5E9)),
                    _build3DStatPill('🌧️', 'Monsoon Season', const Color(0xFFF59E0B)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _build3DStatPill(String emoji, String text, Color color) {
    return Semantics(
      container: true,
      label: text,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4.5),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.28),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withValues(alpha: 0.4), width: 0.9),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 11)),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                text,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.plusJakartaSans(
                  color: Colors.white,
                  fontSize: 10.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── 2. Instant Smart AI Trip Generator Card ────────────────────────────────
  Widget _buildSmartGeneratorSection(bool isDark, double screenWidth) {
    final borderColor = isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);
    final isCompact = screenWidth < 700;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: borderColor, width: 1.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Title Row
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFD97706), Color(0xFFB45309)],
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                child: const Text('⚡', style: TextStyle(fontSize: 18)),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Instant Trip Generator',
                      style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      'Pick a theme & duration to generate a full schedule',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11.5,
                        color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),

          // ── 1. Select Travel Theme ──
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text('🪅', style: TextStyle(fontSize: 14)),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            '1. Select Travel Theme',
                            style: GoogleFonts.plusJakartaSans(
                              fontWeight: FontWeight.w800,
                              fontSize: 13,
                              letterSpacing: -0.2,
                              color: isDark ? const Color(0xFFF1F5F9) : const Color(0xFF0F172A),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Choose what excites you the most',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // "Shuffle Picks" Button
              InkWell(
                onTap: _shuffleSuggestion,
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF7ED),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFF97316).withValues(alpha: 0.5)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('✨', style: TextStyle(fontSize: 13)),
                      const SizedBox(width: 4),
                      Text(
                        'Shuffle Picks',
                        style: GoogleFonts.plusJakartaSans(
                          color: const Color(0xFFEA580C),
                          fontWeight: FontWeight.w800,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Responsive Theme Selection Cards
          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth >= 900;
              final isMedium = constraints.maxWidth >= 600 && constraints.maxWidth < 900;

              if (isWide) {
                return GridView.count(
                  crossAxisCount: 6,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 0.82,
                  children: List.generate(_tripThemes.length, (index) {
                    return _buildThemeCard(index, isDark, borderColor, width: null);
                  }),
                );
              } else if (isMedium) {
                return GridView.count(
                  crossAxisCount: 3,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 0.95,
                  children: List.generate(_tripThemes.length, (index) {
                    return _buildThemeCard(index, isDark, borderColor, width: null);
                  }),
                );
              } else {
                // Mobile View: SingleChildScrollView with Row so ALL 6 widgets stay mounted in tree for widget tests
                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  child: Row(
                    children: List.generate(_tripThemes.length, (index) {
                      return Padding(
                        padding: EdgeInsets.only(right: index < _tripThemes.length - 1 ? 10 : 0),
                        child: _buildThemeCard(index, isDark, borderColor, width: 148),
                      );
                    }),
                  ),
                );
              }
            },
          ),
          const SizedBox(height: 20),

          // ── 2. Trip Duration ──
          Row(
            children: [
              const Text('📅', style: TextStyle(fontSize: 14)),
              const SizedBox(width: 6),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '2. Trip Duration',
                      style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.w800,
                        fontSize: 13,
                        letterSpacing: -0.2,
                        color: isDark ? const Color(0xFFF1F5F9) : const Color(0xFF0F172A),
                      ),
                    ),
                    Text(
                      'How many days are you planning?',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [1, 2, 3, 4, 5].map((days) {
              final isSel = days == _selectedDurationDays;
              final label = days == 5 ? '5+ Days' : '$days Day${days > 1 ? 's' : ''}';

              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 3),
                  child: InkWell(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      setState(() => _selectedDurationDays = days);
                    },
                    borderRadius: BorderRadius.circular(14),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 2),
                      decoration: BoxDecoration(
                        color: isSel ? const Color(0xFF064E3B) : (isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9)),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isSel ? const Color(0xFF064E3B) : borderColor,
                          width: isSel ? 1.5 : 1.0,
                        ),
                        boxShadow: isSel
                            ? [
                                BoxShadow(
                                  color: const Color(0xFF064E3B).withValues(alpha: 0.25),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ]
                            : null,
                      ),
                      alignment: Alignment.center,
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          label,
                          style: GoogleFonts.plusJakartaSans(
                            color: isSel ? Colors.white : (isDark ? const Color(0xFFCBD5E1) : const Color(0xFF334155)),
                            fontWeight: isSel ? FontWeight.w800 : FontWeight.w600,
                            fontSize: 11.5,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),

          // ── 3. Travel Pace ──
          Row(
            children: [
              const Text('🏃', style: TextStyle(fontSize: 14)),
              const SizedBox(width: 6),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '3. Travel Pace',
                      style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.w800,
                        fontSize: 13,
                        letterSpacing: -0.2,
                        color: isDark ? const Color(0xFFF1F5F9) : const Color(0xFF0F172A),
                      ),
                    ),
                    Text(
                      'Choose your travel style',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _buildPaceOption('☕', 'Relaxed', 'More time at each place', 0, isDark, borderColor),
              const SizedBox(width: 8),
              _buildPaceOption('🚶', 'Balanced', 'Perfect mix of travel & explore', 1, isDark, borderColor),
              const SizedBox(width: 8),
              _buildPaceOption('⚡', 'Packed', 'Cover more places', 2, isDark, borderColor),
            ],
          ),
          const SizedBox(height: 20),

          // ── 4. Travel Companion ──
          Row(
            children: [
              const Text('👥', style: TextStyle(fontSize: 14)),
              const SizedBox(width: 6),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '4. Travel Companion',
                      style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.w800,
                        fontSize: 13,
                        letterSpacing: -0.2,
                        color: isDark ? const Color(0xFFF1F5F9) : const Color(0xFF0F172A),
                      ),
                    ),
                    Text(
                      'Who are you travelling with?',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildCompanionChip('🎒', 'Solo', 0, isDark, borderColor),
              _buildCompanionChip('❤️', 'Couple', 1, isDark, borderColor),
              _buildCompanionChip('👨‍👩‍👧', 'Family', 2, isDark, borderColor),
              _buildCompanionChip('🧗', 'Friends', 3, isDark, borderColor),
              _buildCompanionChip('👥', 'Large Group', 4, isDark, borderColor),
            ],
          ),
          const SizedBox(height: 20),

          // ── 5. Budget Tier ──
          Row(
            children: [
              const Text('👛', style: TextStyle(fontSize: 14)),
              const SizedBox(width: 6),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '5. Budget Tier',
                      style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.w800,
                        fontSize: 13,
                        letterSpacing: -0.2,
                        color: isDark ? const Color(0xFFF1F5F9) : const Color(0xFF0F172A),
                      ),
                    ),
                    Text(
                      'Help us suggest better options',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _buildBudgetTierOption('🪙', 'Budget (₹500/d)', 'Backpacker friendly', 0, isDark, borderColor),
              const SizedBox(width: 8),
              _buildBudgetTierOption('🌲', 'Moderate (₹1.5k/d)', 'Comfortable & relaxed', 1, isDark, borderColor),
              const SizedBox(width: 8),
              _buildBudgetTierOption('💎', 'Luxury (₹3.5k/d)', 'Premium experiences', 2, isDark, borderColor),
            ],
          ),
          const SizedBox(height: 22),

          // ── Full-Width Terracotta Gradient Action Button ──
          InkWell(
            onTap: _isGenerating ? null : _generateSmartPlan,
            borderRadius: BorderRadius.circular(16),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              height: 52,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFFF97316),
                    Color(0xFFEA580C),
                    Color(0xFFC2410C),
                  ],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFEA580C).withValues(alpha: 0.35),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              alignment: Alignment.center,
              child: _isGenerating
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.2),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'Synthesizing Itinerary...',
                          style: GoogleFonts.plusJakartaSans(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    )
                  : FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '✨ Generate Custom Itinerary',
                            style: GoogleFonts.plusJakartaSans(
                              color: Colors.white,
                              fontSize: isCompact ? 14 : 15.5,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.2,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 18),
                        ],
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 10),
          // Direct Booking Option for Custom Trip
          OutlinedButton.icon(
            onPressed: () {
              final theme = _tripThemes[_selectedThemeIndex];
              showCustomTripBookingModal(
                context,
                defaultTitle: '${theme.title} Explorer',
                defaultDays: _selectedDurationDays,
                defaultTheme: theme.title,
              );
            },
            icon: const Text('🚗', style: TextStyle(fontSize: 16)),
            label: Text(
              'Book Private Cab & Guide for this Itinerary',
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.w800,
                fontSize: 12.5,
                color: const Color(0xFF064E3B),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Color(0xFF064E3B), width: 1.2),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              minimumSize: const Size(double.infinity, 44),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThemeCard(int index, bool isDark, Color borderColor, {double? width}) {
    final theme = _tripThemes[index];
    final isSel = index == _selectedThemeIndex;

    return InkWell(
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() => _selectedThemeIndex = index);
      },
      borderRadius: BorderRadius.circular(14),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: width,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF0F172A) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSel ? const Color(0xFFF97316) : borderColor,
            width: isSel ? 2.0 : 1.0,
          ),
          boxShadow: isSel
              ? [
                  BoxShadow(
                    color: const Color(0xFFF97316).withValues(alpha: 0.25),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image with top-right select checkmark
            Stack(
              children: [
                SizedBox(
                  height: 94,
                  width: double.infinity,
                  child: CachedNetworkImage(
                    imageUrl: AppImageOptimizer.forThumbnail(theme.imageUrl),
                    fit: BoxFit.cover,
                    fadeInDuration: const Duration(milliseconds: 250),
                    errorWidget: (_, __, ___) => Container(
                      color: theme.color.withValues(alpha: 0.2),
                      alignment: Alignment.center,
                      child: Text(theme.icon, style: const TextStyle(fontSize: 28)),
                    ),
                  ),
                ),
                // Top-right selection indicator
                Positioned(
                  top: 6,
                  right: 6,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      color: isSel ? const Color(0xFFF97316) : Colors.black.withValues(alpha: 0.35),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 1.2),
                    ),
                    alignment: Alignment.center,
                    child: Icon(
                      Icons.check_rounded,
                      size: 14,
                      color: isSel ? Colors.white : Colors.white.withValues(alpha: 0.7),
                    ),
                  ),
                ),
              ],
            ),
            // Title & Subtitle
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    theme.title,
                    style: GoogleFonts.plusJakartaSans(
                      fontWeight: isSel ? FontWeight.w800 : FontWeight.w700,
                      fontSize: 12,
                      color: isSel ? (isDark ? const Color(0xFFFB923C) : const Color(0xFFC2410C)) : null,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    theme.subtitle,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 9.5,
                      color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                      height: 1.2,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaceOption(String icon, String title, String subtitle, int index, bool isDark, Color borderColor) {
    final isSel = _selectedPaceIndex == index;

    return Expanded(
      child: InkWell(
        onTap: () {
          HapticFeedback.selectionClick();
          setState(() => _selectedPaceIndex = index);
        },
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
          decoration: BoxDecoration(
            color: isSel
                ? (isDark ? const Color(0xFF7C2D12).withValues(alpha: 0.25) : const Color(0xFFFFF7ED))
                : (isDark ? const Color(0xFF0F172A) : Colors.white),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSel ? const Color(0xFFF97316) : borderColor,
              width: isSel ? 1.5 : 1.0,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Row(
                  children: [
                    Text(icon, style: const TextStyle(fontSize: 13)),
                    const SizedBox(width: 4),
                    Text(
                      title,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11.5,
                        fontWeight: isSel ? FontWeight.w800 : FontWeight.w700,
                        color: isSel ? const Color(0xFFEA580C) : (isDark ? Colors.white : const Color(0xFF0F172A)),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 3),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  subtitle,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 9,
                    color: isSel
                        ? const Color(0xFF9A3412)
                        : (isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCompanionChip(String icon, String label, int index, bool isDark, Color borderColor) {
    final isSel = _selectedTravelStyleIndex == index;

    return InkWell(
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() => _selectedTravelStyleIndex = index);
      },
      borderRadius: BorderRadius.circular(14),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSel
              ? const Color(0xFF064E3B)
              : (isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9)),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSel ? const Color(0xFF064E3B) : borderColor,
            width: isSel ? 1.5 : 1.0,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(icon, style: const TextStyle(fontSize: 12)),
            const SizedBox(width: 5),
            Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11.5,
                fontWeight: isSel ? FontWeight.w800 : FontWeight.w600,
                color: isSel ? Colors.white : (isDark ? const Color(0xFFCBD5E1) : const Color(0xFF334155)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBudgetTierOption(String icon, String title, String subtitle, int index, bool isDark, Color borderColor) {
    final isSel = _selectedBudgetIndex == index;

    return Expanded(
      child: InkWell(
        onTap: () {
          HapticFeedback.selectionClick();
          setState(() => _selectedBudgetIndex = index);
        },
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
          decoration: BoxDecoration(
            color: isSel
                ? (isDark ? const Color(0xFF064E3B).withValues(alpha: 0.25) : const Color(0xFFECFDF5))
                : (isDark ? const Color(0xFF0F172A) : Colors.white),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSel ? const Color(0xFF059669) : borderColor,
              width: isSel ? 1.5 : 1.0,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Row(
                  children: [
                    Text(icon, style: const TextStyle(fontSize: 13)),
                    const SizedBox(width: 4),
                    Text(
                      title,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        fontWeight: isSel ? FontWeight.w800 : FontWeight.w700,
                        color: isSel ? const Color(0xFF065F46) : (isDark ? Colors.white : const Color(0xFF0F172A)),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 3),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  subtitle,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 9,
                    color: isSel
                        ? const Color(0xFF047857)
                        : (isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── 3. Saved Itineraries Section ─────────────────────────────────────────
  Widget _buildSavedItinerariesSection(AsyncValue<List<ItineraryPlan>> itinerariesAsync, bool isDark, double screenWidth) {
    final borderColor = isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Row(
                children: [
                  const Text('🎒', style: TextStyle(fontSize: 20)),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      'My Saved Trips',
                      style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.w800,
                        fontSize: 17,
                        letterSpacing: -0.3,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            OutlinedButton.icon(
              onPressed: () => _showCreateCustomModal(context),
              icon: const Icon(Icons.add_rounded, size: 16, color: Color(0xFF064E3B)),
              label: Text(
                'New Trip',
                style: GoogleFonts.plusJakartaSans(
                  color: const Color(0xFF064E3B),
                  fontWeight: FontWeight.w800,
                  fontSize: 12,
                ),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFF064E3B), width: 1.2),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),

        itinerariesAsync.when(
          data: (plans) {
            if (plans.isEmpty) {
              return Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E293B) : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: borderColor),
                ),
                child: Column(
                  children: [
                    const Text('🗺️', style: TextStyle(fontSize: 42)),
                    const SizedBox(height: 12),
                    Text(
                      'No Itineraries Created Yet',
                      style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, fontSize: 16),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Use the Smart Trip Generator above or build a custom plan from scratch.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () => _showCreateCustomModal(context),
                      icon: const Icon(Icons.add_rounded, size: 18),
                      label: const Text('Create First Trip', style: TextStyle(fontWeight: FontWeight.w800)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF064E3B),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ],
                ),
              );
            }

            return Column(
              children: plans.map((plan) => _buildPlanCard(plan, isDark, borderColor, screenWidth)).toList(),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Text('Error loading plans: $e'),
        ),
      ],
    );
  }

  Widget _buildPlanCard(ItineraryPlan plan, bool isDark, Color borderColor, double screenWidth) {
    final totalStops = plan.days.fold<int>(0, (sum, d) => sum + d.stops.length);
    final isCompact = screenWidth < 550;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: borderColor, width: 1.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          context.push('/itinerary/${plan.id}');
        },
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Trip Thumbnail
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: CachedNetworkImage(
                      imageUrl: AppImageOptimizer.forThumbnail(
                        'https://images.unsplash.com/photo-1508873696983-2df5293cb395?q=80&w=400&auto=format&fit=crop',
                      ),
                      width: isCompact ? 68 : 80,
                      height: isCompact ? 62 : 72,
                      fit: BoxFit.cover,
                      fadeInDuration: const Duration(milliseconds: 250),
                      errorWidget: (_, __, ___) => Container(
                        width: isCompact ? 68 : 80,
                        height: isCompact ? 62 : 72,
                        decoration: BoxDecoration(
                          color: const Color(0xFF064E3B).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        alignment: Alignment.center,
                        child: const Text('🗺️', style: TextStyle(fontSize: 24)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Title, Days & Description
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                          decoration: BoxDecoration(
                            color: const Color(0xFF064E3B).withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '${plan.totalDays} Days • $totalStops Stops',
                            style: GoogleFonts.plusJakartaSans(
                              color: const Color(0xFF064E3B),
                              fontWeight: FontWeight.w800,
                              fontSize: 10,
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          plan.title,
                          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, fontSize: 14),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (plan.description.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            plan.description,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11,
                              color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),
                  // Delete Menu
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert_rounded, size: 18, color: Colors.grey),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onSelected: (val) {
                      if (val == 'delete') {
                        ref.read(userItinerariesProvider.notifier).deletePlan(plan.id);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Deleted "${plan.title}"')),
                        );
                      }
                    },
                    itemBuilder: (ctx) => [
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete_outline_rounded, color: Colors.red, size: 18),
                            SizedBox(width: 8),
                            Text('Delete Trip', style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Divider(height: 1, color: borderColor),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Text(
                      plan.startDate.length >= 10
                          ? DateFormat('MMM dd, yyyy').format(DateTime.tryParse(plan.startDate) ?? DateTime.now())
                          : plan.startDate,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      InkWell(
                        onTap: () => context.push('/itinerary/${plan.id}'),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'View Schedule',
                              style: GoogleFonts.plusJakartaSans(
                                color: const Color(0xFFEA580C),
                                fontWeight: FontWeight.w800,
                                fontSize: 11.5,
                              ),
                            ),
                            const SizedBox(width: 3),
                            const Icon(Icons.arrow_forward_rounded, size: 13, color: Color(0xFFEA580C)),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      InkWell(
                        onTap: () => showCustomTripBookingModal(context, plan: plan),
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFF064E3B),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text('🎟️', style: TextStyle(fontSize: 11)),
                              const SizedBox(width: 3),
                              Text(
                                'Book',
                                style: GoogleFonts.plusJakartaSans(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── 4. Curated Pune Master Circuits ─────────────────────────────────────────
  Widget _buildCuratedTemplatesSection(bool isDark) {
    final borderColor = isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text('🌟', style: TextStyle(fontSize: 20)),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                'Curated Pune Master Circuits',
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.w800,
                  fontSize: 17,
                  letterSpacing: -0.3,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          'Handpicked itineraries crafted by local Punekar historians & trek guides',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 12,
            color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
          ),
        ),
        const SizedBox(height: 12),

        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _curatedTemplates.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            final template = _curatedTemplates[index];

            return Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B) : Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: borderColor),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.03),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: CachedNetworkImage(
                      imageUrl: AppImageOptimizer.forThumbnail(template.imageUrl),
                      width: 52,
                      height: 52,
                      fit: BoxFit.cover,
                      fadeInDuration: const Duration(milliseconds: 250),
                      errorWidget: (_, __, ___) => Container(
                        width: 52,
                        height: 52,
                        color: template.badgeColor.withValues(alpha: 0.15),
                        alignment: Alignment.center,
                        child: Text(template.icon, style: const TextStyle(fontSize: 24)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Wrap(
                          spacing: 6,
                          runSpacing: 4,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: template.badgeColor.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: Text(
                                template.duration,
                                style: GoogleFonts.plusJakartaSans(
                                  color: template.badgeColor,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                            Text(
                              'Est. ${template.budget}',
                              style: GoogleFonts.plusJakartaSans(
                                fontWeight: FontWeight.w700,
                                fontSize: 10.5,
                                color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          template.title,
                          style: GoogleFonts.plusJakartaSans(
                            fontWeight: FontWeight.w800,
                            fontSize: 14,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          template.highlights,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11,
                            color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton.filledTonal(
                        icon: const Icon(Icons.arrow_forward_rounded, size: 16),
                        onPressed: () {
                          setState(() {
                            _selectedThemeIndex = template.themeIndex;
                          });
                          _generateSmartPlan();
                        },
                        tooltip: 'Adopt Template',
                      ),
                      const SizedBox(height: 4),
                      InkWell(
                        onTap: () {
                          final days = int.tryParse(template.duration.split(' ').first) ?? 2;
                          showCustomTripBookingModal(
                            context,
                            defaultTitle: template.title,
                            defaultDays: days,
                          );
                        },
                        borderRadius: BorderRadius.circular(6),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                          decoration: BoxDecoration(
                            color: const Color(0xFF064E3B).withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'Book',
                            style: GoogleFonts.plusJakartaSans(
                              color: const Color(0xFF064E3B),
                              fontWeight: FontWeight.w800,
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  // ── 5. Smart Travel Packing Checklist ────────────────────────────────────
  Widget _buildPackingChecklistSection(bool isDark) {
    final completedCount = _checklistState.values.where((v) => v).length;
    final totalCount = _packingItems.length;
    final progress = totalCount > 0 ? (completedCount / totalCount) : 0.0;
    final borderColor = isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: borderColor, width: 1.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    const Text('🎒', style: TextStyle(fontSize: 22)),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        'Smart Travel Essentials',
                        style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFF064E3B).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '$completedCount of $totalCount Packed',
                  style: GoogleFonts.plusJakartaSans(
                    color: const Color(0xFF064E3B),
                    fontWeight: FontWeight.w800,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Progress Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFE2E8F0),
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF059669)),
              minHeight: 5,
            ),
          ),
          const SizedBox(height: 14),

          // Checklist Items
          ...List.generate(_packingItems.length, (index) {
            final item = _packingItems[index];
            final isChecked = _checklistState[index] ?? false;

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 3),
              child: InkWell(
                onTap: () {
                  HapticFeedback.lightImpact();
                  setState(() {
                    _checklistState[index] = !isChecked;
                  });
                },
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
                  child: Row(
                    children: [
                      Text(item.icon, style: const TextStyle(fontSize: 18)),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.title,
                              style: GoogleFonts.plusJakartaSans(
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                                decoration: isChecked ? TextDecoration.lineThrough : null,
                                color: isChecked ? Colors.grey : null,
                              ),
                            ),
                            Text(
                              item.subtitle,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 10.5,
                                color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Checkbox(
                        value: isChecked,
                        activeColor: const Color(0xFF064E3B),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                        visualDensity: VisualDensity.compact,
                        onChanged: (val) {
                          HapticFeedback.lightImpact();
                          setState(() {
                            _checklistState[index] = val ?? false;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),

          const SizedBox(height: 10),
          Center(
            child: TextButton.icon(
              onPressed: _showAddCustomItemDialog,
              icon: const Icon(Icons.add_rounded, size: 16, color: Color(0xFF064E3B)),
              label: Text(
                '+ Add Packing Item',
                style: GoogleFonts.plusJakartaSans(
                  color: const Color(0xFF064E3B),
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── 6. Seasonal Trip Advisory ────────────────────────────────────────────
  Widget _buildSeasonalAdvisoryCard(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFF1E293B), const Color(0xFF0F172A)]
              : [const Color(0xFFFFFBEB), const Color(0xFFFEF3C7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF59E0B).withValues(alpha: 0.4), width: 1.0),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('🌦️', style: TextStyle(fontSize: 28)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Pune Monsoon & Ghat Advisory',
                  style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, fontSize: 14.5),
                ),
                const SizedBox(height: 4),
                Text(
                  'Peak waterfall season is active across Tamhini & Sinhagad. For morning fort treks, begin before 07:00 AM to beat weekend traffic. Carry rain covers for electronics and note that historic peth eateries observe siesta from 1:00 PM to 4:00 PM.',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11.5,
                    height: 1.35,
                    color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF78350F),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// DATA MODELS FOR TRIP PLANNER
// ══════════════════════════════════════════════════════════════════════════════

class _TripTheme {
  final String icon;
  final String title;
  final String marathiSubtitle;
  final String subtitle;
  final String imageUrl;
  final Color color;
  final List<Color> gradient;

  const _TripTheme({
    required this.icon,
    required this.title,
    required this.marathiSubtitle,
    required this.subtitle,
    required this.imageUrl,
    required this.color,
    required this.gradient,
  });
}

class _CuratedTemplate {
  final String icon;
  final String title;
  final String duration;
  final String difficulty;
  final String budget;
  final Color badgeColor;
  final String highlights;
  final String imageUrl;
  final int themeIndex;

  const _CuratedTemplate({
    required this.icon,
    required this.title,
    required this.duration,
    required this.difficulty,
    required this.budget,
    required this.badgeColor,
    required this.highlights,
    required this.imageUrl,
    required this.themeIndex,
  });
}

class _PackingItem {
  final String icon;
  final String title;
  final String subtitle;

  const _PackingItem({
    required this.icon,
    required this.title,
    required this.subtitle,
  });
}
