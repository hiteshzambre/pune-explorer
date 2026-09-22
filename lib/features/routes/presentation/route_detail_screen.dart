import 'package:flutter/material.dart';
import '../../heritage_walks/presentation/heritage_walk_detail_screen.dart';

/// Legacy RouteDetailScreen forwards seamlessly to the premium HeritageWalkDetailScreen.
class RouteDetailScreen extends StatelessWidget {
  final String routeId;

  const RouteDetailScreen({super.key, required this.routeId});

  @override
  Widget build(BuildContext context) {
    return HeritageWalkDetailScreen(walkId: routeId);
  }
}
