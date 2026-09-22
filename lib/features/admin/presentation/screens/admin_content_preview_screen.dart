import 'package:flutter/material.dart';
import '../../../home/presentation/home_screen.dart';
import '../../../explore/presentation/explore_screen.dart';
import '../../../darshan/presentation/pune_darshan_screen.dart';
import '../../../heritage_walks/presentation/heritage_walks_screen.dart';
import '../../../budget/presentation/budget_calculator_screen.dart';
import '../theme/admin_theme.dart';

enum PreviewDevice { desktop, tablet, mobile }

class AdminContentPreviewScreen extends StatefulWidget {
  const AdminContentPreviewScreen({super.key});

  @override
  State<AdminContentPreviewScreen> createState() => _AdminContentPreviewScreenState();
}

class _AdminContentPreviewScreenState extends State<AdminContentPreviewScreen> {
  PreviewDevice _device = PreviewDevice.mobile;
  String _selectedScreen = 'home';
  double _zoomScale = 1.0;

  Widget _buildSelectedScreenWidget() {
    switch (_selectedScreen) {
      case 'home':
        return const HomeScreen();
      case 'explore':
        return const ExploreScreen();
      case 'darshan':
        return const PuneDarshanScreen();
      case 'walks':
        return const HeritageWalksScreen();
      case 'budget':
        return const BudgetCalculatorScreen();
      default:
        return const HomeScreen();
    }
  }

  Size _getDeviceDimensions() {
    switch (_device) {
      case PreviewDevice.desktop:
        return const Size(1024, 680);
      case PreviewDevice.tablet:
        return const Size(768, 800);
      case PreviewDevice.mobile:
        return const Size(375, 780);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final deviceSize = _getDeviceDimensions();

    return Scaffold(
      backgroundColor: isDark ? AdminTheme.scaffoldBgDark : AdminTheme.scaffoldBg,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Top Control Toolbar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            decoration: const BoxDecoration(
              color: Color(0xFF1E293B),
              border: Border(bottom: BorderSide(color: Color(0xFF334155), width: 1)),
            ),
            child: Wrap(
              spacing: 16,
              runSpacing: 12,
              crossAxisAlignment: WrapCrossAlignment.center,
              alignment: WrapAlignment.spaceBetween,
              children: [
                // Screen Selector
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.preview_rounded, color: AdminTheme.emerald, size: 22),
                    const SizedBox(width: 8),
                    const Text('Previewing: ', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13, fontWeight: FontWeight.w600)),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0F172A),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFF334155)),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedScreen,
                          dropdownColor: const Color(0xFF0F172A),
                          style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700),
                          items: const [
                            DropdownMenuItem(value: 'home', child: Text('Homepage & Hero CMS')),
                            DropdownMenuItem(value: 'explore', child: Text('Explore Destinations Catalog')),
                            DropdownMenuItem(value: 'darshan', child: Text('Pune Darshan Circuits')),
                            DropdownMenuItem(value: 'walks', child: Text('Heritage Walks Guide')),
                            DropdownMenuItem(value: 'budget', child: Text('Budget Calculator Tool')),
                          ],
                          onChanged: (val) {
                            if (val != null) setState(() => _selectedScreen = val);
                          },
                        ),
                      ),
                    ),
                  ],
                ),

                // Device Switcher
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _deviceButton(PreviewDevice.mobile, Icons.phone_iphone_rounded, 'Mobile (375px)'),
                    const SizedBox(width: 6),
                    _deviceButton(PreviewDevice.tablet, Icons.tablet_mac_rounded, 'Tablet (768px)'),
                    const SizedBox(width: 6),
                    _deviceButton(PreviewDevice.desktop, Icons.desktop_mac_rounded, 'Desktop (1024px)'),
                  ],
                ),

                // Zoom Controls
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.zoom_out_rounded, color: Color(0xFF94A3B8), size: 20),
                      onPressed: _zoomScale > 0.6 ? () => setState(() => _zoomScale -= 0.15) : null,
                    ),
                    Text(
                      '${(_zoomScale * 100).toInt()}%',
                      style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700),
                    ),
                    IconButton(
                      icon: const Icon(Icons.zoom_in_rounded, color: Color(0xFF94A3B8), size: 20),
                      onPressed: _zoomScale < 1.3 ? () => setState(() => _zoomScale += 0.15) : null,
                    ),
                    TextButton(
                      onPressed: () => setState(() => _zoomScale = 1.0),
                      child: const Text('Reset', style: TextStyle(color: AdminTheme.emerald, fontSize: 12)),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Sandboxed Canvas Body
          Expanded(
            child: Container(
              color: const Color(0xFF070B14),
              child: Center(
                child: SingleChildScrollView(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Transform.scale(
                        scale: _zoomScale,
                        child: _buildDeviceFrame(deviceSize),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _deviceButton(PreviewDevice device, IconData icon, String tooltip) {
    final isSelected = _device == device;
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: () => setState(() => _device = device),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? AdminTheme.emerald : const Color(0xFF0F172A),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: isSelected ? AdminTheme.emerald : const Color(0xFF334155)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16, color: isSelected ? Colors.white : const Color(0xFF94A3B8)),
              const SizedBox(width: 6),
              Text(
                device.name.toUpperCase(),
                style: TextStyle(
                  color: isSelected ? Colors.white : const Color(0xFF94A3B8),
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDeviceFrame(Size size) {
    final isMobile = _device == PreviewDevice.mobile;

    return Container(
      width: size.width,
      height: size.height,
      decoration: BoxDecoration(
        color: const Color(0xFF0B1120),
        borderRadius: BorderRadius.circular(isMobile ? 36 : 16),
        border: Border.all(
          color: const Color(0xFF334155),
          width: isMobile ? 8 : 4,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.6),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(isMobile ? 28 : 12),
        child: Stack(
          children: [
            // Embedded screen contents
            Positioned.fill(
              child: _buildSelectedScreenWidget(),
            ),
            // Mobile Notch / Speaker Bar
            if (isMobile)
              Align(
                alignment: Alignment.topCenter,
                child: Container(
                  width: 120,
                  height: 22,
                  decoration: const BoxDecoration(
                    color: Color(0xFF1E293B),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(14),
                      bottomRight: Radius.circular(14),
                    ),
                  ),
                  child: Center(
                    child: Container(
                      width: 50,
                      height: 4,
                      decoration: BoxDecoration(
                        color: const Color(0xFF475569),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
