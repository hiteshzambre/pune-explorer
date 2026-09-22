import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/app_providers.dart';
import '../../../../data/models/admin_personalization.dart';
import '../theme/admin_theme.dart';

class AdminPersonalizationScreen extends ConsumerStatefulWidget {
  const AdminPersonalizationScreen({super.key});

  @override
  ConsumerState<AdminPersonalizationScreen> createState() => _AdminPersonalizationScreenState();
}

class _AdminPersonalizationScreenState extends ConsumerState<AdminPersonalizationScreen> {
  late AdminPersonalization _settings;

  @override
  void initState() {
    super.initState();
    _settings = ref.read(adminPersonalizationProvider);
  }

  Future<void> _saveSettings() async {
    await ref.read(adminPersonalizationProvider.notifier).updateSettings(_settings);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Personalization preferences saved successfully!'),
          backgroundColor: AdminTheme.emerald,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AdminTheme.scaffoldBgDark : AdminTheme.scaffoldBg,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Admin Workspace Personalization',
                        style: TextStyle(
                          color: isDark ? Colors.white : AdminTheme.textPrimary,
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Customize your administration dashboard layout, sidebar density, and visual theme preferences.',
                        style: TextStyle(
                          color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                          fontSize: 12.5,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AdminTheme.emerald,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  icon: const Icon(Icons.save_rounded, size: 18),
                  label: const Text('Save Preferences', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
                  onPressed: _saveSettings,
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Visual Theme & Appearance
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B) : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Appearance & Theme',
                    style: TextStyle(
                      color: isDark ? Colors.white : AdminTheme.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      _buildThemeOption('Light Enterprise (Default)', 'light', Icons.light_mode_rounded, isDark),
                      const SizedBox(width: 14),
                      _buildThemeOption('Dark Modern', 'dark', Icons.dark_mode_rounded, isDark),
                      const SizedBox(width: 14),
                      _buildThemeOption('System Automatic', 'system', Icons.settings_brightness_rounded, isDark),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Navigation & Sidebar Layout
            Material(
              color: isDark ? const Color(0xFF1E293B) : Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Navigation & Tables',
                      style: TextStyle(
                        color: isDark ? Colors.white : AdminTheme.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 16),
                    SwitchListTile(
                      title: Text(
                        'Collapse Sidebar by Default on Tablets',
                        style: TextStyle(
                          color: isDark ? Colors.white : AdminTheme.textPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      subtitle: Text(
                        'Keeps the navigation rail compact to maximize catalog workspace',
                        style: TextStyle(
                          color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                          fontSize: 12,
                        ),
                      ),
                      value: _settings.sidebarCollapsedDefault,
                      activeThumbColor: AdminTheme.emerald,
                      onChanged: (val) => setState(() => _settings = _settings.copyWith(sidebarCollapsedDefault: val)),
                    ),
                    Divider(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0), height: 24),
                    Row(
                      children: [
                        Text(
                          'Data Table Display Density:',
                          style: TextStyle(
                            color: isDark ? Colors.white : AdminTheme.textPrimary,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Wrap(
                          spacing: 8,
                          children: ['compact', 'standard', 'comfortable'].map((d) {
                            final isSelected = _settings.tableDensity == d;
                            return ChoiceChip(
                              label: Text(
                                d.toUpperCase(),
                                style: TextStyle(
                                  color: isSelected
                                      ? Colors.white
                                      : (isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              selected: isSelected,
                              selectedColor: AdminTheme.emerald,
                              backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
                              side: BorderSide(
                                color: isSelected
                                    ? AdminTheme.emerald
                                    : (isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1)),
                              ),
                              onSelected: (_) => setState(() => _settings = _settings.copyWith(tableDensity: d)),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Dashboard Widgets Toggle
            Material(
              color: isDark ? const Color(0xFF1E293B) : Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Dashboard Widgets Configuration',
                      style: TextStyle(
                        color: isDark ? Colors.white : AdminTheme.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Enable or disable modular widgets displayed on the Overview Dashboard.',
                      style: TextStyle(
                        color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 16),
                    SwitchListTile(
                      title: Text(
                        'Show Revenue Performance Trend Chart',
                        style: TextStyle(
                          color: isDark ? Colors.white : AdminTheme.textPrimary,
                          fontSize: 13.5,
                        ),
                      ),
                      value: _settings.showRevenueChart,
                      activeThumbColor: AdminTheme.emerald,
                      onChanged: (val) => setState(() => _settings = _settings.copyWith(showRevenueChart: val)),
                    ),
                    SwitchListTile(
                      title: Text(
                        'Show Booking Status Donut Breakdown',
                        style: TextStyle(
                          color: isDark ? Colors.white : AdminTheme.textPrimary,
                          fontSize: 13.5,
                        ),
                      ),
                      value: _settings.showBookingDonut,
                      activeThumbColor: AdminTheme.emerald,
                      onChanged: (val) => setState(() => _settings = _settings.copyWith(showBookingDonut: val)),
                    ),
                    SwitchListTile(
                      title: Text(
                        'Show Action Items Queue',
                        style: TextStyle(
                          color: isDark ? Colors.white : AdminTheme.textPrimary,
                          fontSize: 13.5,
                        ),
                      ),
                      value: _settings.showActionQueue,
                      activeThumbColor: AdminTheme.emerald,
                      onChanged: (val) => setState(() => _settings = _settings.copyWith(showActionQueue: val)),
                    ),
                    SwitchListTile(
                      title: Text(
                        'Show Recent Audit Activity Stream',
                        style: TextStyle(
                          color: isDark ? Colors.white : AdminTheme.textPrimary,
                          fontSize: 13.5,
                        ),
                      ),
                      value: _settings.showAuditStream,
                      activeThumbColor: AdminTheme.emerald,
                      onChanged: (val) => setState(() => _settings = _settings.copyWith(showAuditStream: val)),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeOption(String label, String value, IconData icon, bool isDark) {
    final isSelected = _settings.themeMode == value;
    final cardBg = isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC);
    final border = isSelected
        ? AdminTheme.emerald
        : (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0));
    final textColor = isSelected
        ? (isDark ? Colors.white : AdminTheme.emeraldDark)
        : (isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B));

    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _settings = _settings.copyWith(themeMode: value)),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: border,
              width: isSelected ? 2.0 : 1.0,
            ),
          ),
          child: Column(
            children: [
              Icon(icon, color: isSelected ? AdminTheme.emerald : (isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)), size: 28),
              const SizedBox(height: 10),
              Text(
                label,
                style: TextStyle(
                  color: textColor,
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
