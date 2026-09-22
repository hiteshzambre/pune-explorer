import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/providers/app_providers.dart';
import '../../../../data/models/cms_models.dart';

class AdminFaqsScreen extends ConsumerStatefulWidget {
  const AdminFaqsScreen({super.key});

  @override
  ConsumerState<AdminFaqsScreen> createState() => _AdminFaqsScreenState();
}

class _AdminFaqsScreenState extends ConsumerState<AdminFaqsScreen> {
  void _showFaqDialog(BuildContext context, {FaqItem? faq}) {
    final isNew = faq == null;
    final qCtrl = TextEditingController(text: faq?.question ?? '');
    final aCtrl = TextEditingController(text: faq?.answer ?? '');
    final catCtrl = TextEditingController(text: faq?.category ?? 'General');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(isNew ? 'Create New FAQ' : 'Edit FAQ', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
        content: SizedBox(
          width: 500,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildField('Question', qCtrl),
              const SizedBox(height: 12),
              _buildField('Answer Explanation', aCtrl, maxLines: 3),
              const SizedBox(height: 12),
              _buildField('Category Group', catCtrl),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.emerald),
            onPressed: () async {
              final messenger = ScaffoldMessenger.of(context);
              final newFaq = FaqItem(
                id: faq?.id ?? 'faq_${DateTime.now().millisecondsSinceEpoch}',
                question: qCtrl.text.trim(),
                answer: aCtrl.text.trim(),
                category: catCtrl.text.trim(),
                sortOrder: faq?.sortOrder ?? 0,
              );
              Navigator.of(ctx).pop();
              await ref.read(cmsRepositoryProvider).saveFaq(newFaq);
              setState(() {});

              if (mounted) {
                messenger.showSnackBar(
                  const SnackBar(content: Text('FAQ saved and published!'), backgroundColor: AppColors.emerald),
                );
              }
            },
            child: const Text('Save FAQ', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  Widget _buildField(String label, TextEditingController controller, {int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 11.5, fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          maxLines: maxLines,
          style: const TextStyle(color: Colors.white, fontSize: 13),
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFF0F172A),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<FaqItem>>(
      future: ref.read(cmsRepositoryProvider).getFaqs(),
      builder: (context, snapshot) {
        final faqs = snapshot.data ?? [];

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
                        Text('Help & Information FAQs CMS', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900)),
                        SizedBox(height: 4),
                        Text('Frequently asked questions rendered on Home, Darshan, and Help screens.', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12)),
                      ],
                    ),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.emerald),
                      icon: const Icon(Icons.add, color: Colors.white, size: 18),
                      label: const Text('Add FAQ', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                      onPressed: () => _showFaqDialog(context),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: faqs.length,
                  itemBuilder: (context, index) {
                    final f = faqs[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E293B),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFF334155)),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(color: AppColors.emerald.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(8)),
                            child: const Icon(Icons.help_outline_rounded, color: AppColors.emerald, size: 20),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(f.question, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700)),
                                const SizedBox(height: 4),
                                Text(f.answer, style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12.5)),
                                const SizedBox(height: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(color: const Color(0xFF0F172A), borderRadius: BorderRadius.circular(6)),
                                  child: Text(f.category, style: const TextStyle(color: Color(0xFF64748B), fontSize: 10, fontWeight: FontWeight.w800)),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.edit_rounded, color: Colors.white70, size: 18),
                            onPressed: () => _showFaqDialog(context, faq: f),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline, color: AppColors.error, size: 18),
                            onPressed: () async {
                              await ref.read(cmsRepositoryProvider).deleteFaq(f.id);
                              setState(() {});
                            },
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
