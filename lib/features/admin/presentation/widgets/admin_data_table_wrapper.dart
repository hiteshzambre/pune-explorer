import 'package:flutter/material.dart';
import '../theme/admin_theme.dart';

/// Responsive wrapper around admin data tables with search, filter slots, and pagination bar.
class AdminDataTableWrapper extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? actionButton;
  final Widget? searchField;
  final List<Widget>? filterChips;
  final Widget child;
  final int totalCount;
  final int currentPage;
  final int totalPages;
  final ValueChanged<int>? onPageChanged;

  const AdminDataTableWrapper({
    super.key,
    required this.title,
    this.subtitle,
    this.actionButton,
    this.searchField,
    this.filterChips,
    required this.child,
    this.totalCount = 0,
    this.currentPage = 1,
    this.totalPages = 1,
    this.onPageChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: AdminTheme.cardDecoration(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header Row
          Padding(
            padding: const EdgeInsets.all(20),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isCompact = constraints.maxWidth < 600;
                if (isCompact) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: isDark ? Colors.white : AdminTheme.textPrimary,
                        ),
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          subtitle!,
                          style: TextStyle(
                            fontSize: 12.5,
                            color: isDark ? AdminTheme.textSecondaryDark : AdminTheme.textSecondary,
                          ),
                        ),
                      ],
                      if (actionButton != null) ...[
                        const SizedBox(height: 12),
                        actionButton!,
                      ],
                    ],
                  );
                }

                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: isDark ? Colors.white : AdminTheme.textPrimary,
                            ),
                          ),
                          if (subtitle != null) ...[
                            const SizedBox(height: 4),
                            Text(
                              subtitle!,
                              style: TextStyle(
                                fontSize: 12.5,
                                color: isDark ? AdminTheme.textSecondaryDark : AdminTheme.textSecondary,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    if (actionButton != null) ...[
                      const SizedBox(width: 16),
                      actionButton!,
                    ],
                  ],
                );
              },
            ),
          ),

          // Search & Filter Bar (if present)
          if (searchField != null || (filterChips != null && filterChips!.isNotEmpty)) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  if (searchField != null) searchField!,
                  if (filterChips != null && filterChips!.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Wrap(spacing: 8, runSpacing: 8, children: filterChips!),
                  ],
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ],

          const Divider(height: 1),

          // Content child (Table / ListView)
          child,

          const Divider(height: 1),

          // Pagination bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Showing ${totalCount > 0 ? ((currentPage - 1) * 10 + 1) : 0}–${(currentPage * 10).clamp(0, totalCount)} of $totalCount items',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? AdminTheme.textSecondaryDark : AdminTheme.textSecondary,
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.chevron_left_rounded, size: 20),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                      onPressed: currentPage > 1 && onPageChanged != null
                          ? () => onPageChanged!(currentPage - 1)
                          : null,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '$currentPage / ${totalPages > 0 ? totalPages : 1}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: isDark ? Colors.white : AdminTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(width: 4),
                    IconButton(
                      icon: const Icon(Icons.chevron_right_rounded, size: 20),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                      onPressed: currentPage < totalPages && onPageChanged != null
                          ? () => onPageChanged!(currentPage + 1)
                          : null,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
