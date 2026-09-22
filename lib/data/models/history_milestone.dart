import 'package:flutter/material.dart';

/// Data model representing a pivotal historical milestone in Pune's rich heritage.
class HistoryMilestone {
  final String id;
  final int startYear;
  final int? endYear;
  final String period;
  final String title;
  final String description;
  final String quote;
  final String categoryEmoji;
  final IconData iconData;
  final List<String> tags;
  final Color accentColor;
  final String imageAsset;
  final IconData watermarkIcon;
  final String? routePath;

  const HistoryMilestone({
    required this.id,
    required this.startYear,
    this.endYear,
    required this.period,
    required this.title,
    required this.description,
    required this.quote,
    required this.categoryEmoji,
    required this.iconData,
    required this.tags,
    required this.accentColor,
    required this.imageAsset,
    required this.watermarkIcon,
    this.routePath,
  });

  /// Canonical list of Pune's historical milestones strictly matching the reference visual specification.
  static const List<HistoryMilestone> defaultMilestones = [
    HistoryMilestone(
      id: 'lal_mahal',
      startYear: 1630,
      endYear: 1645,
      period: '1630s – 1640s',
      title: 'Shivaji Maharaj & Childhood at Lal Mahal',
      description:
          'Jijabai ploughed Pune with a Golden Plough. Young Shivaji Maharaj sowed Swarajya from Lal Mahal and conquered Torna at age 16.',
      quote: '“The seeds of Swarajya were sown in Pune.”',
      categoryEmoji: '👑',
      iconData: Icons.castle_rounded,
      tags: ['People', 'Origins', 'Lal Mahal'],
      accentColor: Color(0xFF10B981), // Emerald
      imageAsset: 'assets/images/history_lal_mahal_hd.jpg',
      watermarkIcon: Icons.fort_rounded,
      routePath: '/explore?search=Lal+Mahal',
    ),
    HistoryMilestone(
      id: 'sinhagad_battle',
      startYear: 1670,
      endYear: 1670,
      period: '1670',
      title: 'Battle of Sinhagad & Tanaji Malusare',
      description:
          'Subedar Tanaji Malusare scaled the sheer 400m cliff to reclaim Kondhana fort. Shivaji Maharaj proclaimed: "Gad aala pan Sinha gela".',
      quote: '“Gad aala pan Sinha gela.”',
      categoryEmoji: '⚔️',
      iconData: Icons.shield_rounded,
      tags: ['Battle', 'Bravery', 'Sinhagad'],
      accentColor: Color(0xFFF97316), // Orange
      imageAsset: 'assets/images/history_sinhagad_battle_hd.jpg',
      watermarkIcon: Icons.landscape_rounded,
      routePath: '/explore?search=Sinhagad',
    ),
    HistoryMilestone(
      id: 'shaniwar_wada',
      startYear: 1732,
      endYear: 1818,
      period: '1732 – 1818',
      title: 'Peshwa Era & Shaniwar Wada Capital',
      description:
          'Peshwa Bajirao I established Shaniwar Wada. Pune blossomed into the epic political, cultural, and military capital of India.',
      quote: '“Pune rose as the heart of a new India.”',
      categoryEmoji: '🏛️',
      iconData: Icons.account_balance_rounded,
      tags: ['Peshwas', 'Culture', 'Shaniwar Wada'],
      accentColor: Color(0xFF0EA5E9), // Sky Blue
      imageAsset: 'assets/images/history_shaniwar_wada_hd.jpg',
      watermarkIcon: Icons.account_balance_rounded,
      routePath: '/explore?search=Shaniwar+Wada',
    ),
    HistoryMilestone(
      id: 'ganeshotsav',
      startYear: 1893,
      endYear: 1893,
      period: '1893',
      title: 'Sarvajanik Ganeshotsav Movement',
      description:
          'Lokmanya Tilak transformed Ganesh festival into a public social awakening to unite citizens in the freedom struggle.',
      quote: '“A festival that united a nation.”',
      categoryEmoji: '👥',
      iconData: Icons.groups_rounded,
      tags: ['Freedom', 'People Power', 'Ganeshotsav'],
      accentColor: Color(0xFFF43F5E), // Rose
      imageAsset: 'assets/images/history_ganeshotsav_hd.jpg',
      watermarkIcon: Icons.festival_rounded,
      routePath: '/explore?search=Ganeshotsav',
    ),
    HistoryMilestone(
      id: 'aga_khan_palace',
      startYear: 1942,
      endYear: 1944,
      period: '1942 – 1944',
      title: 'Quit India Movement & Aga Khan Palace',
      description:
          'Mahatma Gandhi, Kasturba Gandhi, and Sarojini Naidu were interned at Aga Khan Palace. Preserved as a National Freedom Memorial.',
      quote: '“Sacrifice today for a brighter tomorrow.”',
      categoryEmoji: '🕊️',
      iconData: Icons.volunteer_activism_rounded,
      tags: ['Freedom Struggle', 'Mahatma Gandhi', 'Aga Khan Palace'],
      accentColor: Color(0xFF8B5CF6), // Purple
      imageAsset: 'assets/images/history_aga_khan_palace_hd.jpg',
      watermarkIcon: Icons.home_work_rounded,
      routePath: '/explore?search=Aga+Khan+Palace',
    ),
  ];
}
