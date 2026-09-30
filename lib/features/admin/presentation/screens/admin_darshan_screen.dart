import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/providers/app_providers.dart';
import '../../../../data/models/route_model.dart';

class AdminDarshanScreen extends ConsumerStatefulWidget {
  const AdminDarshanScreen({super.key});

  @override
  ConsumerState<AdminDarshanScreen> createState() => _AdminDarshanScreenState();
}

class _AdminDarshanScreenState extends ConsumerState<AdminDarshanScreen> {
  void _moveStop(RouteCircuit route, int index, int offset) async {
    final newIndex = index + offset;
    if (newIndex < 0 || newIndex >= route.waypoints.length) return;

    final waypoints = List<RouteWaypoint>.from(route.waypoints);
    final item = waypoints.removeAt(index);
    waypoints.insert(newIndex, item);

    await ref.read(routesCatalogProvider.notifier).reorderRouteStops(route.id, waypoints);

    try {
      final admin = ref.read(adminSessionProvider);
      await ref.read(auditLogsProvider.notifier).log(
        actorEmail: admin.email.isNotEmpty ? admin.email : 'admin@puneexplorer.in',
        actorRole: admin.role,
        action: 'REORDER_DARSHAN_STOPS',
        resourceType: 'ROUTE_CIRCUIT',
        resourceId: route.id,
        metadata: {'movedStop': item.name, 'from': index + 1, 'to': newIndex + 1},
      );
    } catch (_) {}

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Reordered stop: "${item.name}" moved to Stop #${newIndex + 1}. Live in Pune Darshan!'),
          backgroundColor: AppColors.emerald,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _showAddStopDialog(BuildContext context, RouteCircuit route) {
    final nameCtrl = TextEditingController();
    final descCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Add Pune Darshan Stop', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Stop Landmark Name', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12, fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            TextField(
              controller: nameCtrl,
              style: const TextStyle(color: Colors.white, fontSize: 13),
              decoration: InputDecoration(
                hintText: 'e.g. Pataleshwar Cave Temple',
                hintStyle: const TextStyle(color: Color(0xFF64748B)),
                filled: true,
                fillColor: const Color(0xFF0F172A),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 12),
            const Text('Visiting Details & Highlights', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12, fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            TextField(
              controller: descCtrl,
              maxLines: 2,
              style: const TextStyle(color: Colors.white, fontSize: 13),
              decoration: InputDecoration(
                hintText: '8th-century monolithic rock-cut Shiva temple...',
                hintStyle: const TextStyle(color: Color(0xFF64748B)),
                filled: true,
                fillColor: const Color(0xFF0F172A),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.emerald),
            onPressed: () async {
              if (nameCtrl.text.trim().isEmpty) return;
              final messenger = ScaffoldMessenger.of(context);
              final newWaypoint = RouteWaypoint(
                name: nameCtrl.text.trim(),
                lat: 18.5204,
                lng: 73.8567,
                description: descCtrl.text.trim(),
              );

              final updatedWaypoints = [...route.waypoints, newWaypoint];
              Navigator.of(ctx).pop();
              await ref.read(routesCatalogProvider.notifier).reorderRouteStops(route.id, updatedWaypoints);

              if (mounted) {
                messenger.showSnackBar(
                  SnackBar(content: Text('Stop "${newWaypoint.name}" added to itinerary!'), backgroundColor: AppColors.emerald),
                );
              }
            },
            child: const Text('Add Stop', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final routesAsync = ref.watch(routesAsyncProvider);
    final routes = routesAsync.value ?? [];
    final darshanRoute = routes.isNotEmpty ? routes.first : null;

    return Scaffold(
      backgroundColor: const Color(0xFF0B1120),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Pune Darshan Circuit Management', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900)),
                        SizedBox(height: 4),
                        Text('Reorder tour stops, edit arrival timings, and manage live sightseeing itinerary.', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12)),
                      ],
                    ),
                    if (darshanRoute != null)
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(backgroundColor: AppColors.emerald),
                        icon: const Icon(Icons.add_location_alt_rounded, color: Colors.white, size: 18),
                        label: const Text('Add Circuit Stop', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                        onPressed: () => _showAddStopDialog(context, darshanRoute),
                      ),
                  ],
                ),
                const SizedBox(height: 20),
                if (darshanRoute == null)
                  const Center(child: CircularProgressIndicator(color: AppColors.emerald))
                else ...[
                  // Circuit Summary Card
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E293B),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.emerald.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(gradient: AppColors.emeraldGradient, borderRadius: BorderRadius.circular(12)),
                          child: const Icon(Icons.directions_bus_filled_rounded, color: Colors.white, size: 28),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(darshanRoute.title, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800)),
                              const SizedBox(height: 4),
                              Text('${darshanRoute.subtitle} • ${darshanRoute.distanceKm} km • ${darshanRoute.durationFormatted}', style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12)),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(color: AppColors.saffron.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(8)),
                          child: Text('${darshanRoute.waypoints.length} STOPS', style: const TextStyle(color: AppColors.saffron, fontSize: 11, fontWeight: FontWeight.w900)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text('TOUR STOPS ORDER (LIVE ITINERARY)', style: TextStyle(color: Color(0xFF64748B), fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1.1)),
                  const SizedBox(height: 12),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: darshanRoute.waypoints.length,
                    itemBuilder: (context, index) {
                      final stop = darshanRoute.waypoints[index];
                      final isFirst = index == 0;
                      final isLast = index == darshanRoute.waypoints.length - 1;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E293B),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFF334155)),
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 14,
                              backgroundColor: AppColors.emerald,
                              child: Text('${index + 1}', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w800)),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(stop.name, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700)),
                                  if (stop.description.isNotEmpty) ...[
                                    const SizedBox(height: 2),
                                    Text(stop.description, style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 11.5), maxLines: 1),
                                  ],
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.arrow_upward_rounded, size: 18),
                              color: isFirst ? Colors.grey.withValues(alpha: 0.3) : AppColors.emerald,
                              tooltip: 'Move Stop Up',
                              onPressed: isFirst ? null : () => _moveStop(darshanRoute, index, -1),
                            ),
                            IconButton(
                              icon: const Icon(Icons.arrow_downward_rounded, size: 18),
                              color: isLast ? Colors.grey.withValues(alpha: 0.3) : AppColors.emerald,
                              tooltip: 'Move Stop Down',
                              onPressed: isLast ? null : () => _moveStop(darshanRoute, index, 1),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ],
            ),
          ),
        );
  }
}

