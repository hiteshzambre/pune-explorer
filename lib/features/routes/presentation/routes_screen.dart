import 'package:flutter/material.dart';
import '../../heritage_walks/presentation/heritage_walks_screen.dart';

/// Legacy RoutesScreen now seamlessly forwards to the premium HeritageWalksScreen.
class RoutesScreen extends StatelessWidget {
  const RoutesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const HeritageWalksScreen();
  }
}
