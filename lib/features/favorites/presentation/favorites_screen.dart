import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/responsive/breakpoints.dart';
import '../../../core/responsive/responsive_builder.dart';
import '../../../core/widgets/empty_state_view.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import '../../explore/presentation/widgets/destination_card.dart';
import '../../heritage_walks/presentation/widgets/heritage_walk_card.dart';

class FavoritesScreen extends ConsumerStatefulWidget {
  const FavoritesScreen({super.key});

  @override
  ConsumerState<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends ConsumerState<FavoritesScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final favorites = ref.watch(favoritesProvider);
    final destinationsAsync = ref.watch(destinationsAsyncProvider);
    final walksAsync = ref.watch(heritageWalksAsyncProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Saved & Favorites'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.saffron,
          labelColor: AppColors.saffron,
          unselectedLabelColor: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
          labelStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
          tabs: const [
            Tab(text: 'Destinations & Forts', icon: Icon(Icons.castle_rounded, size: 18)),
            Tab(text: 'Heritage Walks', icon: Icon(Icons.directions_walk_rounded, size: 18)),
          ],
        ),
      ),
      body: MaxWidthWrapper(
        child: TabBarView(
          controller: _tabController,
          children: [
            // 1. Saved Destinations
            destinationsAsync.when(
              data: (destinations) {
                final savedList = destinations.where((d) => favorites.contains(d.id)).toList();

                if (savedList.isEmpty) {
                  return EmptyStateView(
                    icon: '❤️',
                    title: 'No Saved Destinations Yet',
                    description: 'Explore Pune\'s top hillforts, scenic lakes, and cultural landmarks and tap the heart icon to save them for quick access.',
                    actionText: 'Explore Destinations',
                    onAction: () => context.go('/explore'),
                  );
                }

                return MasonryGridView.count(
                  padding: const EdgeInsets.all(16),
                  crossAxisCount: Breakpoints.getGridColumnCount(context, mobile: 1, tablet: 2, desktop: 3),
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  itemCount: savedList.length,
                  itemBuilder: (context, index) {
                    final dest = savedList[index];
                    return DestinationCard(destination: dest);
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error loading favorites: $e')),
            ),

            // 2. Saved Heritage Walks
            walksAsync.when(
              data: (walks) {
                final savedWalks = walks.where((w) => favorites.contains(w.id)).toList();

                if (savedWalks.isEmpty) {
                  return EmptyStateView(
                    icon: '🏛️',
                    title: 'No Saved Heritage Walks',
                    description: 'Discover Pune\'s historic wadas, copper craft lanes, and sacred trails, and bookmark your favorite walking tours.',
                    actionText: 'Browse Heritage Walks',
                    onAction: () => context.go('/walks'),
                  );
                }

                return MasonryGridView.count(
                  padding: const EdgeInsets.all(16),
                  crossAxisCount: Breakpoints.getGridColumnCount(context, mobile: 1, tablet: 2, desktop: 3),
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  itemCount: savedWalks.length,
                  itemBuilder: (context, index) {
                    final walk = savedWalks[index];
                    return HeritageWalkCard(
                      walk: walk,
                      variant: HeritageWalkCardVariant.full,
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error loading saved walks: $e')),
            ),
          ],
        ),
      ),
    );
  }
}
