import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/responsive/breakpoints.dart';
import '../../../services/ai_service.dart';

class PunekarBotSheet extends ConsumerStatefulWidget {
  const PunekarBotSheet({super.key});

  static Future<void> show(BuildContext context) {
    HapticFeedback.mediumImpact();
    if (Breakpoints.isMobile(context)) {
      return showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) => const PunekarBotSheet(),
      );
    } else {
      return showDialog(
        context: context,
        builder: (_) => const Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: EdgeInsets.all(24),
          child: SizedBox(
            width: 540,
            height: 720,
            child: PunekarBotSheet(),
          ),
        ),
      );
    }
  }

  @override
  ConsumerState<PunekarBotSheet> createState() => _PunekarBotSheetState();
}

class _PunekarBotSheetState extends ConsumerState<PunekarBotSheet> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<AIMessage> _messages = [];
  bool _isLoading = false;

  final List<String> _quickPrompts = [
    '🏰 Plan 1-day Sinhagad Fort trek',
    '🍲 Best Misal spots in Pune',
    '🚌 Pune Darshan bus timings & route',
    '🏕️ Pawna Lake camping guide',
    '🌧️ Monsoon safety tips for Tamhini Ghat',
    '💰 1-Day Pune trip under ₹2,000',
  ];

  @override
  void initState() {
    super.initState();
    _messages.add(
      AIMessage(
        text: 'Namaste! 🙏 I\'m **PunekarBot**, your AI travel guide.\n\n'
            'Ask me anything about Pune heritage, fort treks, Darshan buses, or iconic food spots!',
        isUser: false,
        timestamp: DateTime.now(),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage(String text) async {
    final clean = text.trim();
    if (clean.isEmpty || _isLoading) return;

    HapticFeedback.lightImpact();

    setState(() {
      _messages.add(AIMessage(text: clean, isUser: true, timestamp: DateTime.now()));
      _isLoading = true;
    });
    _controller.clear();
    _scrollToBottom();

    final aiService = ref.read(aiServiceProvider);
    final reply = await aiService.askAssistant(clean);

    if (mounted) {
      setState(() {
        _messages.add(AIMessage(text: reply, isUser: false, timestamp: DateTime.now()));
        _isLoading = false;
      });
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isMobile = Breakpoints.isMobile(context);
    final viewInsets = MediaQuery.viewInsetsOf(context);
    final isKeyboardOpen = viewInsets.bottom > 0;
    final availableHeight = MediaQuery.sizeOf(context).height - viewInsets.bottom;
    final sheetHeight = isMobile ? (availableHeight * (isKeyboardOpen ? 0.94 : 0.85)).clamp(320.0, availableHeight) : 720.0;

    return Padding(
      padding: EdgeInsets.only(bottom: viewInsets.bottom),
      child: Container(
        height: sheetHeight,
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(isMobile ? 28 : 24), bottom: Radius.circular(isMobile ? 0 : 24)),
          border: Border.all(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.5 : 0.15),
              blurRadius: 24,
              offset: const Offset(0, -6),
            ),
          ],
        ),
        child: Column(
          children: [
            // Header Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurfaceVariant : AppColors.lightSurfaceVariant,
              borderRadius: BorderRadius.vertical(top: Radius.circular(isMobile ? 26 : 22)),
            ),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: AppColors.saffron.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.saffron.withValues(alpha: 0.3)),
                  ),
                  alignment: Alignment.center,
                  child: const Text('🤖', style: TextStyle(fontSize: 22)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'PunekarBot AI',
                        style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
                      ),
                      const Row(
                        children: [
                          CircleAvatar(radius: 3.5, backgroundColor: AppColors.emerald),
                          SizedBox(width: 5),
                          Text('Live Local Guide • Pune Knowledge Base', style: TextStyle(fontSize: 11, color: AppColors.emerald, fontWeight: FontWeight.w700)),
                        ],
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),

          // Messages List
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                return _buildMessageBubble(msg, isDark);
              },
            ),
          ),

          // Loading Indicator
          if (_isLoading)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
              child: Row(
                children: [
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.emerald),
                  ),
                  const SizedBox(width: 10),
                  Text('PunekarBot is preparing your answer...', style: theme.textTheme.bodySmall?.copyWith(fontSize: 12)),
                ],
              ),
            ),

          // Quick Prompt Chips
          SizedBox(
            height: 38,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              itemCount: _quickPrompts.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final prompt = _quickPrompts[index];
                return ActionChip(
                  label: Text(prompt, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                  backgroundColor: isDark ? AppColors.darkSurfaceVariant : AppColors.lightSurfaceVariant,
                  side: BorderSide(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                  onPressed: () => _sendMessage(prompt),
                );
              },
            ),
          ),
          const SizedBox(height: 10),

          // Input Bar with Keyboard Inset Handling
          Container(
            padding: EdgeInsets.fromLTRB(
              16,
              12,
              16,
              12 + (isMobile && !isKeyboardOpen ? MediaQuery.paddingOf(context).bottom : 0),
            ),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
              border: Border(top: BorderSide(color: isDark ? AppColors.darkBorder : AppColors.lightBorder)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    textInputAction: TextInputAction.send,
                    onSubmitted: _sendMessage,
                    decoration: InputDecoration(
                      hintText: 'Ask about treks, food, bus timings...',
                      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                      filled: true,
                      fillColor: isDark ? AppColors.darkSurfaceVariant : AppColors.lightSurfaceVariant,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                CircleAvatar(
                  backgroundColor: AppColors.emerald,
                  radius: 23,
                  child: IconButton(
                    icon: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
                    onPressed: () => _sendMessage(_controller.text),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

  Widget _buildMessageBubble(AIMessage msg, bool isDark) {
    final textColor = msg.isUser ? Colors.white : (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary);

    return Align(
      alignment: msg.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        constraints: BoxConstraints(maxWidth: MediaQuery.sizeOf(context).width * 0.82),
        decoration: BoxDecoration(
          color: msg.isUser
              ? AppColors.emerald
              : (isDark ? AppColors.darkSurfaceVariant : AppColors.lightSurfaceVariant),
          borderRadius: BorderRadius.circular(18).copyWith(
            bottomRight: msg.isUser ? const Radius.circular(2) : const Radius.circular(18),
            bottomLeft: !msg.isUser ? const Radius.circular(2) : const Radius.circular(18),
          ),
          border: !msg.isUser ? Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder) : null,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: _buildRichMessage(msg.text, textColor),
      ),
    );
  }

  Widget _buildRichMessage(String text, Color baseColor) {
    final spans = <TextSpan>[];
    final regex = RegExp(r'\*\*(.*?)\*\*');
    int lastMatchEnd = 0;

    for (final match in regex.allMatches(text)) {
      if (match.start > lastMatchEnd) {
        spans.add(TextSpan(
          text: text.substring(lastMatchEnd, match.start),
          style: TextStyle(color: baseColor, fontSize: 13.5, height: 1.45),
        ));
      }
      spans.add(TextSpan(
        text: match.group(1),
        style: TextStyle(color: baseColor, fontWeight: FontWeight.w800, fontSize: 13.5, height: 1.45),
      ));
      lastMatchEnd = match.end;
    }

    if (lastMatchEnd < text.length) {
      spans.add(TextSpan(
        text: text.substring(lastMatchEnd),
        style: TextStyle(color: baseColor, fontSize: 13.5, height: 1.45),
      ));
    }

    return SelectableText.rich(
      TextSpan(children: spans),
    );
  }
}
