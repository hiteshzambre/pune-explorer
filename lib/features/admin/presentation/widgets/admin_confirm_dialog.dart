import 'package:flutter/material.dart';
import '../theme/admin_theme.dart';

/// Reusable confirmation dialog for critical and destructive administrative actions.
/// Provides summary key-value list, destructive warning (if applicable), and loading state.
class AdminConfirmDialog extends StatefulWidget {
  final String title;
  final String message;
  final Map<String, String>? summaryDetails;
  final String confirmLabel;
  final Color confirmColor;
  final IconData icon;
  final Future<void> Function() onConfirm;

  const AdminConfirmDialog({
    super.key,
    required this.title,
    required this.message,
    this.summaryDetails,
    this.confirmLabel = 'Confirm',
    this.confirmColor = AdminTheme.emerald,
    this.icon = Icons.verified_user_rounded,
    required this.onConfirm,
  });

  static Future<bool?> show({
    required BuildContext context,
    required String title,
    required String message,
    Map<String, String>? details,
    Map<String, String>? summaryDetails,
    String confirmLabel = 'Confirm',
    Color? confirmColor,
    bool isDestructive = false,
    IconData? icon,
    IconData? confirmIcon,
    required Future<void> Function() onConfirm,
  }) {
    final effectiveColor = confirmColor ?? (isDestructive ? AdminTheme.crimson : AdminTheme.emerald);
    final effectiveIcon = confirmIcon ?? icon ?? (isDestructive ? Icons.warning_rounded : Icons.verified_user_rounded);
    final effectiveDetails = details ?? summaryDetails;

    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AdminConfirmDialog(
        title: title,
        message: message,
        summaryDetails: effectiveDetails,
        confirmLabel: confirmLabel,
        confirmColor: effectiveColor,
        icon: effectiveIcon,
        onConfirm: onConfirm,
      ),
    );
  }

  @override
  State<AdminConfirmDialog> createState() => _AdminConfirmDialogState();
}

class _AdminConfirmDialogState extends State<AdminConfirmDialog> {
  bool _isLoading = false;
  String? _errorMessage;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Dialog(
      backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 460),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: widget.confirmColor.withValues(alpha: isDark ? 0.2 : 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(widget.icon, color: widget.confirmColor, size: 22),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      widget.title,
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: isDark ? Colors.white : AdminTheme.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Description
              Text(
                widget.message,
                style: TextStyle(
                  fontSize: 13.5,
                  height: 1.5,
                  color: isDark ? AdminTheme.textSecondaryDark : AdminTheme.textSecondary,
                ),
              ),

              // Summary key-value table
              if (widget.summaryDetails != null && widget.summaryDetails!.isNotEmpty) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                    ),
                  ),
                  child: Column(
                    children: widget.summaryDetails!.entries.map((e) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 3),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              e.key,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Flexible(
                              child: Text(
                                e.value,
                                textAlign: TextAlign.right,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w800,
                                  color: isDark ? Colors.white : AdminTheme.textPrimary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],

              // Error display
              if (_errorMessage != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AdminTheme.rose.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline_rounded, color: AdminTheme.rose, size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: const TextStyle(color: AdminTheme.rose, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 24),

              // Actions
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: _isLoading ? null : () => Navigator.of(context).pop(false),
                    child: Text(
                      'Cancel',
                      style: TextStyle(
                        color: isDark ? Colors.white70 : Colors.black54,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: widget.confirmColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: _isLoading
                        ? null
                        : () async {
                            setState(() {
                              _isLoading = true;
                              _errorMessage = null;
                            });
                            final nav = Navigator.of(context);
                            try {
                              await widget.onConfirm();
                              if (mounted) {
                                nav.pop(true);
                              }
                            } catch (e) {
                              if (mounted) {
                                setState(() {
                                  _isLoading = false;
                                  _errorMessage = e.toString().replaceAll('Exception:', '').trim();
                                });
                              }
                            }
                          },
                    child: _isLoading
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : Text(
                            widget.confirmLabel,
                            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
                          ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
