import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../app/theme/app_colors.dart';

enum ButtonVariant { primary, secondary, outline, text, saffron }

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final ButtonVariant variant;
  final Widget? icon;
  final bool isLoading;
  final bool isFullWidth;
  final double? width;
  final double height;
  final double borderRadius;
  final String? tooltip;

  const CustomButton({
    super.key,
    required this.text,
    this.onPressed,
    this.variant = ButtonVariant.primary,
    this.icon,
    this.isLoading = false,
    this.isFullWidth = false,
    this.width,
    this.height = 50,
    this.borderRadius = 14,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final screenWidth = MediaQuery.sizeOf(context).width;
    final isCompact = screenWidth < 360;
    final horizontalPadding = isCompact ? 12.0 : 16.0;

    Widget child = isLoading
        ? SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              color: variant == ButtonVariant.outline || variant == ButtonVariant.text
                  ? AppColors.emerald
                  : Colors.white,
            ),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                icon!,
                const SizedBox(width: 8),
              ],
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    text,
                    maxLines: 1,
                    style: const TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.1,
                    ),
                  ),
                ),
              ),
            ],
          );

    Color bg;
    Color fg;
    BorderSide? border;
    List<BoxShadow>? shadow;

    switch (variant) {
      case ButtonVariant.primary:
        bg = AppColors.emerald;
        fg = Colors.white;
        border = null;
        if (onPressed != null) {
          shadow = AppColors.glowShadow(AppColors.emerald);
        }
        break;
      case ButtonVariant.saffron:
        bg = AppColors.saffron;
        fg = Colors.white;
        border = null;
        if (onPressed != null) {
          shadow = AppColors.glowShadow(AppColors.saffron);
        }
        break;
      case ButtonVariant.secondary:
        bg = isDark ? AppColors.darkSurfaceVariant : AppColors.lightSurfaceVariant;
        fg = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
        border = BorderSide(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          width: 1,
        );
        break;
      case ButtonVariant.outline:
        bg = Colors.transparent;
        fg = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
        border = BorderSide(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          width: 1.5,
        );
        break;
      case ButtonVariant.text:
        bg = Colors.transparent;
        fg = AppColors.emerald;
        border = null;
        break;
    }

    final clampedHeight = height < 48.0 ? 48.0 : height;

    Widget button = AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      height: clampedHeight,
      width: isFullWidth ? double.infinity : width,
      decoration: BoxDecoration(
        color: onPressed == null ? bg.withValues(alpha: 0.5) : bg,
        borderRadius: BorderRadius.circular(borderRadius),
        border: border != null ? Border.fromBorderSide(border) : null,
        boxShadow: shadow,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(borderRadius),
        child: InkWell(
          onTap: (isLoading || onPressed == null)
              ? null
              : () {
                  HapticFeedback.lightImpact();
                  onPressed!();
                },
          borderRadius: BorderRadius.circular(borderRadius),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
            child: Center(
              child: DefaultTextStyle(
                style: TextStyle(
                  color: onPressed == null ? fg.withValues(alpha: 0.6) : fg,
                  fontWeight: FontWeight.w700,
                  fontSize: 14.5,
                ),
                child: IconTheme(
                  data: IconThemeData(
                    color: onPressed == null ? fg.withValues(alpha: 0.6) : fg,
                    size: 19,
                  ),
                  child: child,
                ),
              ),
            ),
          ),
        ),
      ),
    );

    if (tooltip != null) {
      button = Tooltip(message: tooltip!, child: button);
    }

    button = Semantics(
      button: true,
      label: text,
      enabled: !isLoading,
      child: button,
    );

    return isFullWidth ? SizedBox(width: double.infinity, child: button) : button;
  }
}

