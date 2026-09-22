import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';

class BookingStepper extends StatelessWidget {
  final int currentStep; // 1: Customize, 2: Traveler Details, 3: Payment, 4: Confirmation
  final bool isMobile;

  const BookingStepper({
    super.key,
    required this.currentStep,
    this.isMobile = false,
  });

  static const List<String> stepTitles = [
    'Customize',
    'Traveler Details',
    'Payment',
    'Confirmation',
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (isMobile) {
      return _buildMobileStepper(isDark);
    }
    return _buildDesktopStepper(isDark, theme);
  }

  Widget _buildDesktopStepper(bool isDark, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          for (int i = 0; i < stepTitles.length; i++) ...[
            _buildDesktopStepItem(i + 1, stepTitles[i], isDark),
            if (i < stepTitles.length - 1)
              Expanded(
                child: Container(
                  height: 2,
                  margin: const EdgeInsets.symmetric(horizontal: 10),
                  color: (i + 1) < currentStep
                      ? AppColors.emerald
                      : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
                ),
              ),
          ],
        ],
      ),
    );
  }

  Widget _buildDesktopStepItem(int stepNumber, String title, bool isDark) {
    final isCompleted = stepNumber < currentStep;
    final isCurrent = stepNumber == currentStep;

    Color circleBg;
    Color textColor;
    Widget circleContent;

    if (isCompleted) {
      circleBg = AppColors.emerald;
      textColor = isDark ? Colors.white : Colors.black87;
      circleContent = const Icon(Icons.check, size: 14, color: Colors.white);
    } else if (isCurrent) {
      circleBg = AppColors.emerald;
      textColor = AppColors.emerald;
      circleContent = Text(
        '$stepNumber',
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 13),
      );
    } else {
      circleBg = isDark ? AppColors.darkBorder : const Color(0xFFE2E8F0);
      textColor = Colors.grey;
      circleContent = Text(
        '$stepNumber',
        style: TextStyle(color: isDark ? Colors.white60 : Colors.black54, fontWeight: FontWeight.w700, fontSize: 13),
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: circleBg,
            shape: BoxShape.circle,
            boxShadow: isCurrent
                ? [
                    BoxShadow(
                      color: AppColors.emerald.withValues(alpha: 0.35),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          alignment: Alignment.center,
          child: circleContent,
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 13.5,
            fontWeight: isCurrent ? FontWeight.w800 : (isCompleted ? FontWeight.w600 : FontWeight.w500),
            color: textColor,
          ),
        ),
      ],
    );
  }

  Widget _buildMobileStepper(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          for (int i = 0; i < stepTitles.length; i++) ...[
            _buildMobileCircle(i + 1, isDark),
            if (i < stepTitles.length - 1)
              Expanded(
                child: Container(
                  height: 2,
                  margin: const EdgeInsets.symmetric(horizontal: 6),
                  color: (i + 1) < currentStep
                      ? AppColors.emerald
                      : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
                ),
              ),
          ],
        ],
      ),
    );
  }

  Widget _buildMobileCircle(int stepNumber, bool isDark) {
    final isCompleted = stepNumber < currentStep;
    final isCurrent = stepNumber == currentStep;

    if (isCompleted) {
      return Container(
        width: 24,
        height: 24,
        decoration: const BoxDecoration(
          color: AppColors.emerald,
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.check, size: 13, color: Colors.white),
      );
    } else if (isCurrent) {
      return Container(
        width: 26,
        height: 26,
        decoration: BoxDecoration(
          color: AppColors.emerald,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 2),
          boxShadow: [
            BoxShadow(
              color: AppColors.emerald.withValues(alpha: 0.4),
              blurRadius: 6,
            ),
          ],
        ),
        alignment: Alignment.center,
        child: Text(
          '$stepNumber',
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 12),
        ),
      );
    } else {
      return Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurfaceVariant : const Color(0xFFE2E8F0),
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: Text(
          '$stepNumber',
          style: TextStyle(
            color: isDark ? Colors.white54 : Colors.black45,
            fontWeight: FontWeight.w700,
            fontSize: 11,
          ),
        ),
      );
    }
  }
}
