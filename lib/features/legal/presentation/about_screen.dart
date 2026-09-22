import 'package:flutter/material.dart';
import 'widgets/legal_page_scaffold.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const LegalPageScaffold(
      title: 'About PuneExplorer',
      category: 'Heritage Travel Platform',
      lastUpdated: 'Version 2.4.0 (2026)',
      showHelplineBanner: false,
      children: [
        LegalSectionCard(
          icon: Icons.flag_rounded,
          title: 'Our Puneri Mission',
          content:
              'PuneExplorer was founded with a singular purpose: to connect locals, domestic travelers, and international visitors with the living history, sacred traditions, and natural beauty of Pune, the cultural capital of Maharashtra, and the majestic Sahyadri mountain range.',
        ),
        LegalSectionCard(
          icon: Icons.castle_rounded,
          title: 'What We Provide',
          content:
              'Our platform combines digital booking convenience with authentic local expertise:',
          bulletPoints: [
            '22+ Curated Destinations: Detailed guides to Maratha hillforts (Sinhagad, Rajgad, Torna), Peshwa landmarks (Shaniwar Wada), and iconic spiritual centers (Dagdusheth Ganpati).',
            'Official Pune Darshan AC Bus Tours: Daily curated departures with guaranteed seating and certified historian commentary.',
            'Sahyadri Scenic Circuits: Turn-by-turn waypoint routes for self-drive enthusiasts and trekking groups.',
            'PunekarBot AI: Smart conversational assistant trained on Pune cuisine, culture, and transit options.',
            'Cryptographic Digital Boarding Passes: Offline-ready ticket verification with live seat map selection.',
          ],
        ),
        LegalSectionCard(
          icon: Icons.verified_user_rounded,
          title: 'Certified Guides & Local Partners',
          content:
              'Every tour package featured on PuneExplorer is operated in coordination with licensed Maharashtra Tourism operators, certified Sahyadri mountaineering guides, and accredited Punekar historians to ensure the highest standards of safety, accuracy, and hospitality.',
        ),
        LegalSectionCard(
          icon: Icons.info_outline_rounded,
          title: 'Application & Release Info',
          content:
              'PuneExplorer v2.4.0 (Production Release 2026)\nBuilt with Flutter (Material 3 + Riverpod)\nDesigned & Developed in Pune, Maharashtra, India.\n© 2026 PuneExplorer. All rights reserved.',
        ),
      ],
    );
  }
}
