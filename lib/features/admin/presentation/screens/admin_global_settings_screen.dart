import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/app_providers.dart';
import '../../../../data/models/admin_global_settings.dart';
import '../theme/admin_theme.dart';

class AdminGlobalSettingsScreen extends ConsumerStatefulWidget {
  const AdminGlobalSettingsScreen({super.key});

  @override
  ConsumerState<AdminGlobalSettingsScreen> createState() => _AdminGlobalSettingsScreenState();
}

class _AdminGlobalSettingsScreenState extends ConsumerState<AdminGlobalSettingsScreen> {
  late AdminGlobalSettings _settings;

  final _appNameCtrl = TextEditingController();
  final _supportEmailCtrl = TextEditingController();
  final _supportPhoneCtrl = TextEditingController();
  final _merchantNameCtrl = TextEditingController();
  final _merchantUpiCtrl = TextEditingController();
  final _cutoffHoursCtrl = TextEditingController();
  final _cancellationWindowCtrl = TextEditingController();
  final _cancellationFeeCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _settings = ref.read(adminGlobalSettingsProvider);
    _appNameCtrl.text = _settings.appName;
    _supportEmailCtrl.text = _settings.supportEmail;
    _supportPhoneCtrl.text = _settings.supportPhone;
    _merchantNameCtrl.text = _settings.merchantName;
    _merchantUpiCtrl.text = _settings.merchantUpiId;
    _cutoffHoursCtrl.text = _settings.bookingCutoffHours.toString();
    _cancellationWindowCtrl.text = _settings.cancellationWindowHours.toString();
    _cancellationFeeCtrl.text = _settings.defaultCancellationFeePercent.toString();
  }

  @override
  void dispose() {
    _appNameCtrl.dispose();
    _supportEmailCtrl.dispose();
    _supportPhoneCtrl.dispose();
    _merchantNameCtrl.dispose();
    _merchantUpiCtrl.dispose();
    _cutoffHoursCtrl.dispose();
    _cancellationWindowCtrl.dispose();
    _cancellationFeeCtrl.dispose();
    super.dispose();
  }

  Future<void> _saveSettings() async {
    final updated = _settings.copyWith(
      appName: _appNameCtrl.text.trim(),
      supportEmail: _supportEmailCtrl.text.trim(),
      supportPhone: _supportPhoneCtrl.text.trim(),
      merchantName: _merchantNameCtrl.text.trim(),
      merchantUpiId: _merchantUpiCtrl.text.trim(),
      bookingCutoffHours: int.tryParse(_cutoffHoursCtrl.text.trim()) ?? 2,
      cancellationWindowHours: int.tryParse(_cancellationWindowCtrl.text.trim()) ?? 24,
      defaultCancellationFeePercent: double.tryParse(_cancellationFeeCtrl.text.trim()) ?? 15.0,
    );

    await ref.read(adminGlobalSettingsProvider.notifier).updateSettings(updated);
    setState(() => _settings = updated);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Global enterprise settings updated and synchronized!'),
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
            // Top Bar
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Global System & Operations Settings',
                        style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Configure company identity, payment endpoints, cancellation lead times, and platform feature flags.',
                        style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12.5),
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
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  icon: const Icon(Icons.save_rounded, size: 18),
                  label: const Text('Save Changes', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
                  onPressed: _saveSettings,
                ),
              ],
            ),

            const SizedBox(height: 24),

            // General & Identity
            _buildSectionCard(
              title: 'Brand Identity & Contact',
              icon: Icons.business_rounded,
              children: [
                Row(
                  children: [
                    Expanded(child: _buildTextField('Platform Application Name', _appNameCtrl)),
                    const SizedBox(width: 16),
                    Expanded(child: _buildTextField('Official Support Email', _supportEmailCtrl)),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(child: _buildTextField('Helpline Phone Number', _supportPhoneCtrl)),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Operating Timezone', style: TextStyle(color: Colors.white, fontSize: 12.5, fontWeight: FontWeight.w700)),
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                            decoration: BoxDecoration(
                              color: const Color(0xFF0F172A),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: const Color(0xFF334155)),
                            ),
                            child: const Row(
                              children: [
                                Icon(Icons.schedule_rounded, color: AdminTheme.emerald, size: 18),
                                SizedBox(width: 10),
                                Text('Asia/Kolkata (IST, UTC+05:30)', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Booking & Cancellation Policies
            _buildSectionCard(
              title: 'Booking & Cancellation Policies',
              icon: Icons.policy_rounded,
              children: [
                Row(
                  children: [
                    Expanded(child: _buildTextField('Booking Cutoff Hours (Before Trip)', _cutoffHoursCtrl, keyboardType: TextInputType.number)),
                    const SizedBox(width: 16),
                    Expanded(child: _buildTextField('Free Cancellation Window (Hours)', _cancellationWindowCtrl, keyboardType: TextInputType.number)),
                    const SizedBox(width: 16),
                    Expanded(child: _buildTextField('Default Cancellation Deduction (%)', _cancellationFeeCtrl, keyboardType: TextInputType.number)),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Payments & UPI Integration
            _buildSectionCard(
              title: 'UPI Payment Gateway Configuration',
              icon: Icons.account_balance_rounded,
              children: [
                Row(
                  children: [
                    Expanded(child: _buildTextField('Merchant Business Name', _merchantNameCtrl)),
                    const SizedBox(width: 16),
                    Expanded(child: _buildTextField('Merchant Virtual Payment Address (UPI VPA)', _merchantUpiCtrl)),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Feature Flags
            _buildSectionCard(
              title: 'Platform Feature Flags',
              icon: Icons.flag_rounded,
              children: [
                SwitchListTile(
                  title: const Text('Maintenance Mode', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700)),
                  subtitle: const Text('Temporarily lock public access and display maintenance alert banner', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12)),
                  value: _settings.isMaintenanceMode,
                  activeThumbColor: AdminTheme.crimson,
                  onChanged: (val) => setState(() => _settings = _settings.copyWith(isMaintenanceMode: val)),
                ),
                const Divider(color: Color(0xFF334155), height: 16),
                SwitchListTile(
                  title: const Text('Allow Guest Bookings', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700)),
                  subtitle: const Text('Allow users to reserve seats without registering an account beforehand', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12)),
                  value: _settings.allowGuestBookings,
                  activeThumbColor: AdminTheme.emerald,
                  onChanged: (val) => setState(() => _settings = _settings.copyWith(allowGuestBookings: val)),
                ),
                const Divider(color: Color(0xFF334155), height: 16),
                SwitchListTile(
                  title: const Text('Enable Dark Mode on Consumer Web', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700)),
                  subtitle: const Text('Allow traveler web visitors to toggle dark appearance', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12)),
                  value: _settings.enableDarkModeWeb,
                  activeThumbColor: AdminTheme.emerald,
                  onChanged: (val) => setState(() => _settings = _settings.copyWith(enableDarkModeWeb: val)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Material(
      color: const Color(0xFF1E293B),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFF334155)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: AdminTheme.emerald, size: 22),
                const SizedBox(width: 8),
                Text(title, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800)),
              ],
            ),
            const SizedBox(height: 18),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, {TextInputType keyboardType = TextInputType.text}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white, fontSize: 12.5, fontWeight: FontWeight.w700)),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          style: const TextStyle(color: Colors.white, fontSize: 13),
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFF0F172A),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFF334155))),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          ),
        ),
      ],
    );
  }
}
