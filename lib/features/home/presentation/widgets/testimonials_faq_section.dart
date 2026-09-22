import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../data/seed/pune_seed_data.dart';

class TestimonialsFAQSection extends StatelessWidget {
  const TestimonialsFAQSection({super.key});

  final List<Map<String, String>> _faqs = const [
    {
      'q': 'What are the top weekend getaways strictly in Pune district?',
      'a': 'Top getaways include Sinhagad Fort (30 km), Lonavala & Khandala (65 km), Pawna Lake (55 km), Lavasa (55 km), Bhimashankar Jyotirlinga (110 km), Mulshi Dam & Tamhini Ghat (45 km), and Torna Fort (50 km).'
    },
    {
      'q': 'What is the best season to trek Sinhagad and Sahyadri forts?',
      'a': 'Monsoon (July to September) offers waterfalls and mist clouds. Winter (October to February) offers crisp weather and 360-degree clear valley views.'
    },
    {
      'q': 'How does Pune Darshan AC Bus tour booking work?',
      'a': 'Select your preferred Darshan tour under the "Darshan" tab, choose your travelers and 28-seat preference, apply promo coupons, and receive an instant QR boarding pass.'
    },
    {
      'q': 'What authentic Puneri foods should I not miss?',
      'a': 'Must-try specialties include spicy Puneri Misal Pav (KataKirr / Bedekar), Chitale Bakarwadi, Sujata Mastani, Kanda Bhaji & Pithla Bhakri at Sinhagad, and fresh steamed Ukadiche Modak.'
    },
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Testimonials
        Text(
          'Traveler Experiences',
          style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 175,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: PuneSeedData.reviews.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final rev = PuneSeedData.reviews[index];
              return Container(
                width: 280,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: AppColors.emerald,
                          radius: 16,
                          child: Text(rev.authorAvatar, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700)),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(rev.authorName, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                              Text(rev.date, style: TextStyle(color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted, fontSize: 11)),
                            ],
                          ),
                        ),
                        const Row(
                          children: [
                            Icon(Icons.star_rounded, color: AppColors.amber, size: 16),
                            SizedBox(width: 2),
                            Text('5.0', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Expanded(
                      child: Text(
                        '"${rev.comment}"',
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(fontStyle: FontStyle.italic),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 32),

        // Frequently Asked Questions
        Text(
          'Frequently Asked Questions',
          style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 12),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _faqs.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final faq = _faqs[index];
            return Material(
              color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
              ),
              clipBehavior: Clip.antiAlias,
              child: ExpansionTile(
                tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                title: Text(
                  faq['q']!,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                  ),
                ),
                children: [
                  Text(
                    faq['a']!,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}
