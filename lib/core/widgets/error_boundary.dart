import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';
import 'custom_button.dart';

/// Error Boundary Widget to catch and display unhandled UI errors gracefully
class ErrorBoundaryWidget extends StatelessWidget {
  final String? errorMessage;
  final VoidCallback? onRetry;
  final Widget? child;

  const ErrorBoundaryWidget({
    super.key,
    this.errorMessage,
    this.onRetry,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28.0),
        child: Semantics(
          liveRegion: true,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.error_outline_rounded,
                  color: AppColors.error,
                  size: 40,
                  semanticLabel: 'Error',
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Something went wrong',
                style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              Text(
                errorMessage ?? 'An unexpected error occurred while loading this section.',
                textAlign: TextAlign.center,
                style: textTheme.bodyMedium,
              ),
              if (onRetry != null) ...[
                const SizedBox(height: 20),
                CustomButton(
                  text: 'Try Again',
                  onPressed: onRetry,
                  icon: const Icon(Icons.refresh_rounded, size: 18),
                  variant: ButtonVariant.outline,
                  height: 48,
                ),
              ]
            ],
          ),
        ),
      ),
    );
  }
}
