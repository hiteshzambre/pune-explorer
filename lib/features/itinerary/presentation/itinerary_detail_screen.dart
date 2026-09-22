import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/responsive/responsive_builder.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../data/models/itinerary_model.dart';
import '../../../data/models/destination.dart';
import 'widgets/custom_trip_booking_modal.dart';

class ItineraryDetailScreen extends ConsumerStatefulWidget {
  final String planId;

  const ItineraryDetailScreen({super.key, required this.planId});

  @override
  ConsumerState<ItineraryDetailScreen> createState() => _ItineraryDetailScreenState();
}

class _ItineraryDetailScreenState extends ConsumerState<ItineraryDetailScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedDayIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showAddStopModal(BuildContext context, ItineraryPlan plan, int dayIndex) {
    final destinations = ref.read(destinationsAsyncProvider).value ?? [];
    Destination? selectedDest = destinations.isNotEmpty ? destinations.first : null;
    String timeSlot = 'Morning (09:00 AM)';
    final notesCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text('Add Stop to Day ${dayIndex + 1}'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<Destination>(
                  initialValue: selectedDest,
                  decoration: const InputDecoration(labelText: 'Choose Landmark'),
                  items: destinations.map((d) {
                    return DropdownMenuItem(
                      value: d,
                      child: Text('${d.category.icon} ${d.name}', style: const TextStyle(fontSize: 13), overflow: TextOverflow.ellipsis),
                    );
                  }).toList(),
                  onChanged: (val) => setModalState(() => selectedDest = val),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: timeSlot,
                  decoration: const InputDecoration(labelText: 'Time Slot'),
                  items: const [
                    DropdownMenuItem(value: 'Sunrise (06:00 AM - 08:30 AM)', child: Text('Sunrise (06:00 AM)')),
                    DropdownMenuItem(value: 'Morning (09:00 AM - 12:30 PM)', child: Text('Morning (09:00 AM)')),
                    DropdownMenuItem(value: 'Afternoon (01:00 PM - 04:00 PM)', child: Text('Afternoon (01:00 PM)')),
                    DropdownMenuItem(value: 'Evening (05:00 PM - 07:30 PM)', child: Text('Evening (05:00 PM)')),
                    DropdownMenuItem(value: 'Night Camp (08:00 PM onwards)', child: Text('Night Camp (08:00 PM)')),
                  ],
                  onChanged: (val) {
                    if (val != null) setModalState(() => timeSlot = val);
                  },
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: notesCtrl,
                  decoration: const InputDecoration(labelText: 'Activity Notes', hintText: 'e.g. Try Misal at local dhaba'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () async {
                if (selectedDest == null) return;
                final newStop = ItineraryStop(
                  id: 'stop_${DateTime.now().millisecondsSinceEpoch}',
                  destinationId: selectedDest!.id,
                  name: selectedDest!.name,
                  categoryIcon: selectedDest!.category.icon,
                  timeSlot: timeSlot,
                  notes: notesCtrl.text.trim().isNotEmpty
                      ? notesCtrl.text.trim()
                      : 'Recommended duration: ${selectedDest!.recommendedDuration}',
                );

                final currentDays = List<ItineraryDay>.from(plan.days);
                if (dayIndex < currentDays.length) {
                  final stops = List<ItineraryStop>.from(currentDays[dayIndex].stops)..add(newStop);
                  currentDays[dayIndex] = currentDays[dayIndex].copyWith(stops: stops);
                  final updatedPlan = plan.copyWith(days: currentDays);
                  await ref.read(userItinerariesProvider.notifier).savePlan(updatedPlan);
                }

                if (context.mounted) Navigator.of(ctx).pop();
              },
              child: const Text('Add Stop'),
            ),
          ],
        ),
      ),
    );
  }

  void _moveStop(ItineraryPlan plan, int dayIndex, int stopIndex, int direction) async {
    final currentDays = List<ItineraryDay>.from(plan.days);
    final stops = List<ItineraryStop>.from(currentDays[dayIndex].stops);
    final targetIndex = stopIndex + direction;
    if (targetIndex >= 0 && targetIndex < stops.length) {
      final item = stops.removeAt(stopIndex);
      stops.insert(targetIndex, item);
      currentDays[dayIndex] = currentDays[dayIndex].copyWith(stops: stops);
      final updatedPlan = plan.copyWith(days: currentDays);
      await ref.read(userItinerariesProvider.notifier).savePlan(updatedPlan);
      HapticFeedback.selectionClick();
    }
  }

  void _deleteStop(ItineraryPlan plan, int dayIndex, int stopIndex) async {
    final currentDays = List<ItineraryDay>.from(plan.days);
    final stops = List<ItineraryStop>.from(currentDays[dayIndex].stops)..removeAt(stopIndex);
    currentDays[dayIndex] = currentDays[dayIndex].copyWith(stops: stops);
    final updatedPlan = plan.copyWith(days: currentDays);
    await ref.read(userItinerariesProvider.notifier).savePlan(updatedPlan);
    HapticFeedback.mediumImpact();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final plans = ref.watch(userItinerariesProvider).value ?? [];
    if (plans.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Itinerary Details')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    final plan = plans.where((p) => p.id == widget.planId).firstOrNull ?? plans.first;

    return Scaffold(
      appBar: AppBar(
        title: Text(plan.title, maxLines: 1, overflow: TextOverflow.ellipsis),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_rounded),
            tooltip: 'Share Itinerary',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Itinerary link copied to clipboard!')),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.bookmark_add_outlined),
            tooltip: 'Book Cab & Guide',
            onPressed: () => showCustomTripBookingModal(context, plan: plan),
          ),
          const SizedBox(width: 8),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.emerald,
          indicatorColor: AppColors.emerald,
          tabs: const [
            Tab(icon: Icon(Icons.route_rounded, size: 18), text: 'Daily Schedule'),
            Tab(icon: Icon(Icons.checklist_rounded, size: 18), text: 'Packing & Notes'),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.08),
              blurRadius: 10,
              offset: const Offset(0, -3),
            ),
          ],
          border: Border(
            top: BorderSide(
              color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
            ),
          ),
        ),
        child: SafeArea(
          child: Row(
            children: [
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${plan.totalDays} Days • Private Tour',
                      style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.w800,
                        fontSize: 13,
                        color: isDark ? Colors.white : const Color(0xFF0F172A),
                      ),
                    ),
                    Text(
                      'Private Cab + Guide Available',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton.icon(
                onPressed: () => showCustomTripBookingModal(context, plan: plan),
                icon: const Text('🚗', style: TextStyle(fontSize: 15)),
                label: Text(
                  'Book This Trip',
                  style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, fontSize: 13),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF064E3B),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ],
          ),
        ),
      ),
      body: MaxWidthWrapper(
        padding: const EdgeInsets.all(16),
        child: TabBarView(
          controller: _tabController,
          children: [
            // Tab 1: Daily Schedule
            _buildScheduleTab(plan, isDark, theme),

            // Tab 2: Packing Checklist & Notes
            _buildChecklistTab(plan, isDark, theme),
          ],
        ),
      ),
    );
  }

  Widget _buildScheduleTab(ItineraryPlan plan, bool isDark, ThemeData theme) {
    if (plan.days.isEmpty) {
      return const Center(child: Text('No days scheduled.'));
    }

    final currentDay = _selectedDayIndex < plan.days.length ? plan.days[_selectedDayIndex] : plan.days.first;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Day Tabs Strip
        SizedBox(
          height: 42,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: plan.days.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, idx) {
              final isSelected = _selectedDayIndex == idx;
              return ChoiceChip(
                label: Text('Day ${idx + 1}', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12)),
                selected: isSelected,
                selectedColor: AppColors.emerald,
                backgroundColor: isDark ? AppColors.darkSurfaceVariant : AppColors.lightSurfaceVariant,
                labelStyle: TextStyle(color: isSelected ? Colors.white : (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary)),
                onSelected: (_) => setState(() => _selectedDayIndex = idx),
                showCheckmark: false,
              );
            },
          ),
        ),
        const SizedBox(height: 14),

        // Day Title & Add Stop Action
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                currentDay.title,
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            CustomButton(
              text: '+ Add Stop',
              variant: ButtonVariant.primary,
              height: 36,
              onPressed: () => _showAddStopModal(context, plan, _selectedDayIndex),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Stops Timeline List
        Expanded(
          child: currentDay.stops.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('📍', style: TextStyle(fontSize: 36)),
                      const SizedBox(height: 8),
                      const Text('No stops added for this day yet.', style: TextStyle(fontWeight: FontWeight.w700)),
                      const SizedBox(height: 4),
                      TextButton(
                        onPressed: () => _showAddStopModal(context, plan, _selectedDayIndex),
                        child: const Text('Add Landmark or Activity'),
                      ),
                    ],
                  ),
                )
              : ListView.separated(
                  itemCount: currentDay.stops.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, stopIdx) {
                    final stop = currentDay.stops[stopIdx];
                    return Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder, width: 1.2),
                        boxShadow: AppColors.cardShadow(isDark),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppColors.emerald.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(stop.categoryIcon, style: const TextStyle(fontSize: 20)),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  stop.timeSlot,
                                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.emerald),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  stop.name,
                                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
                                ),
                                if (stop.notes.isNotEmpty) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    stop.notes,
                                    style: TextStyle(fontSize: 11.5, color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          // Reordering Controls (Accessible Up/Down & Remove with 44px hit areas)
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Semantics(
                                button: true,
                                label: 'Move stop up',
                                child: IconButton(
                                  constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
                                  tooltip: 'Move stop earlier',
                                  icon: const Icon(Icons.arrow_upward_rounded, size: 19),
                                  onPressed: stopIdx > 0
                                      ? () => _moveStop(plan, _selectedDayIndex, stopIdx, -1)
                                      : null,
                                ),
                              ),
                              Semantics(
                                button: true,
                                label: 'Move stop down',
                                child: IconButton(
                                  constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
                                  tooltip: 'Move stop later',
                                  icon: const Icon(Icons.arrow_downward_rounded, size: 19),
                                  onPressed: stopIdx < currentDay.stops.length - 1
                                      ? () => _moveStop(plan, _selectedDayIndex, stopIdx, 1)
                                      : null,
                                ),
                              ),
                              Semantics(
                                button: true,
                                label: 'Delete stop',
                                child: IconButton(
                                  constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
                                  tooltip: 'Remove stop',
                                  icon: const Icon(Icons.delete_outline_rounded, size: 18, color: Colors.grey),
                                  onPressed: () => _deleteStop(plan, _selectedDayIndex, stopIdx),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildChecklistTab(ItineraryPlan plan, bool isDark, ThemeData theme) {
    return ListView(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('🎒 Pune & Sahyadri Packing Checklist', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800)),
              const SizedBox(height: 10),
              ...plan.checklist.map((item) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle_outline_rounded, color: AppColors.emerald, size: 18),
                      const SizedBox(width: 8),
                      Expanded(child: Text(item, style: const TextStyle(fontSize: 13))),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('💡 Pune Trekker & Travel Tips', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800)),
              const SizedBox(height: 10),
              const Text('• Wear shoes with firm rubber grip for wet basalt rock at Sinhagad and Rajgad.'),
              const SizedBox(height: 6),
              const Text('• Carry ₹200-500 cash as mobile network can be intermittent at valley viewpoints.'),
              const SizedBox(height: 6),
              const Text('• Pune Darshan AC coaches depart promptly at 08:00 AM from Swargate.'),
            ],
          ),
        ),
      ],
    );
  }
}
