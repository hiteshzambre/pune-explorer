import 'package:flutter/material.dart';

/// Semantic wrapper ensuring min touch target sizes and accessible screen reader labeling
class AccessibleTouchTarget extends StatelessWidget {
  final Widget child;
  final String? label;
  final String? hint;
  final VoidCallback? onTap;
  final double minSize;

  const AccessibleTouchTarget({
    super.key,
    required this.child,
    this.label,
    this.hint,
    this.onTap,
    this.minSize = 48.0,
  });

  @override
  Widget build(BuildContext context) {
    Widget result = ConstrainedBox(
      constraints: BoxConstraints(
        minWidth: minSize,
        minHeight: minSize,
      ),
      child: Center(child: child),
    );

    if (label != null) {
      result = Semantics(
        label: label,
        hint: hint,
        button: onTap != null,
        onTap: onTap,
        child: result,
      );
    }

    return result;
  }
}
