import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/responsive/responsive_builder.dart';

class HelpSupportScreen extends StatefulWidget {
  const HelpSupportScreen({super.key});

  @override
  State<HelpSupportScreen> createState() => _HelpSupportScreenState();
}

class _HelpSupportScreenState extends State<HelpSupportScreen> {
  String _searchQuery = '';
  String _selectedCategory = 'All';

  final List<Map<String, String>> _faqList = [
    {
      'cat': 'Bookings',
      'q': 'How do I download my digital boarding pass?',
      'a': 'Go to "Profile" ➔ "My Tour Bookings", tap on your confirmed tour, and select "View Digital Pass". You can also save the pass offline or take a screenshot of the QR verification code.'
    },
    {
      'cat': 'Bookings',
      'q': 'Can I apply promotional coupons during checkout?',
      'a': 'Yes! On the tour booking screen, enter promo codes such as "PUNEFIRST" (15% off) or "HERITAGE20" in the coupon field. Discounts apply automatically if minimum traveler and amount conditions are met.'
    },
    {
      'cat': 'Tours',
      'q': 'Where are the primary bus pickup points in Pune?',
      'a': 'Standard pickup terminals include Swargate Bus Station (Platform 4), Pune Railway Station (Main Gate), and Deccan Gymkhana (Goodluck Cafe Stop). Specific reporting times are indicated on your boarding pass.'
    },
    {
      'cat': 'Tours',
      'q': 'What should I carry for Sahyadri fort treks?',
      'a': 'We recommend comfortable trekking shoes with firm grip, 2 liters of water per person, rainwear during June–October monsoon, sun protection, and a photo ID.'
    },
    {
      'cat': 'Account',
      'q': 'How do I switch the application language to Marathi or Hindi?',
      'a': 'Navigate to "Profile" ➔ "Language Preference" and tap on either "English", "मराठी", or "हिंदी" for instant bilingual updates.'
    },
    {
      'cat': 'Account',
      'q': 'Can I use PuneExplorer offline without mobile internet?',
      'a': 'Yes. All saved favorite landmarks, downloaded boarding passes, and emergency contact numbers are cached on your device for reliable offline access.'
    },
  ];

  void _showFeedbackDialog() {
    HapticFeedback.lightImpact();
    final nameCtrl = TextEditingController();
    final messageCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Text('💬', style: TextStyle(fontSize: 20)),
            SizedBox(width: 8),
            Text('Submit Feedback / Report', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17)),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(
                  labelText: 'Your Name / Email',
                  hintText: 'e.g. rahul@example.com',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: messageCtrl,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Feedback or Issue Description',
                  hintText: 'Tell us how we can make your Pune travel experience better...',
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
            onPressed: () {
              Navigator.of(ctx).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('🙏 Thank you! Your feedback has been logged with our support team.'),
                  backgroundColor: AppColors.emerald,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.emerald,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Send Feedback'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final filteredFaqs = _faqList.where((f) {
      final matchesCat = _selectedCategory == 'All' || f['cat'] == _selectedCategory;
      final matchesQuery = _searchQuery.isEmpty ||
          f['q']!.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          f['a']!.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesCat && matchesQuery;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Help & Support Center', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17)),
      ),
      body: SafeArea(
        top: false,
        bottom: true,
        child: MaxWidthWrapper(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: ListView(
            physics: const BouncingScrollPhysics(),
            children: [
              // Search Input
              Container(
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                  boxShadow: AppColors.subtleShadow(isDark),
                ),
                child: TextField(
                  onChanged: (v) => setState(() => _searchQuery = v),
                  decoration: const InputDecoration(
                    hintText: 'Search FAQs, tickets, pickup points...',
                    prefixIcon: Icon(Icons.search_rounded, color: AppColors.emerald),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Filter category chips
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: ['All', 'Bookings', 'Tours', 'Account'].map((cat) {
                    final isSel = _selectedCategory == cat;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: ChoiceChip(
                        label: Text(cat, style: const TextStyle(fontSize: 12)),
                        selected: isSel,
                        selectedColor: AppColors.emerald.withValues(alpha: 0.2),
                        onSelected: (_) => setState(() => _selectedCategory = cat),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 16),

              // FAQ Accordion List
              Text(
                'FREQUENTLY ASKED QUESTIONS',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.8,
                  color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                ),
              ),
              const SizedBox(height: 10),
              ...filteredFaqs.map(
                (faq) => Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                  ),
                  child: ExpansionTile(
                    shape: const Border(),
                    collapsedShape: const Border(),
                    title: Text(
                      faq['q']!,
                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5),
                    ),
                    childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
                    children: [
                      Text(
                        faq['a']!,
                        style: TextStyle(
                          fontSize: 12.5,
                          height: 1.4,
                          color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Feedback Button Action
              OutlinedButton.icon(
                onPressed: _showFeedbackDialog,
                icon: const Icon(Icons.feedback_outlined, size: 18, color: AppColors.emerald),
                label: const Text('Send Feedback / Report an Issue', style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.emerald)),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.emerald, width: 1.2),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
