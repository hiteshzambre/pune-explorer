import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import 'floating_travel_elements.dart';

/// Immersive travel storytelling hero section for desktop and tablet authentication views,
/// matching the exact visual specification of PuneExplorer's brand identity.
class AuthHeroSection extends StatelessWidget {
  final bool isCompact;
  final bool isRegisterMode;

  const AuthHeroSection({
    super.key,
    this.isCompact = false,
    this.isRegisterMode = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isCompact) {
      return _buildCompactHero(context);
    }
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 400),
      switchInCurve: Curves.easeInOut,
      switchOutCurve: Curves.easeInOut,
      child: isRegisterMode
          ? _buildRegisterHero(context, key: const ValueKey('register_hero'))
          : _buildSignInHero(context, key: const ValueKey('signin_hero')),
    );
  }

  /// Compact header for mobile/tablet top section
  Widget _buildCompactHero(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF0F172A), Color(0xFF004D38)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  gradient: AppColors.emeraldGradient,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.authPrimaryGreen.withValues(alpha: 0.4),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: const Text('🚩', style: TextStyle(fontSize: 22)),
              ),
              const SizedBox(width: 12),
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Flexible(
                          child: Text(
                            'PuneExplorer',
                            style: theme.textTheme.titleLarge?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                              fontSize: 19,
                              letterSpacing: -0.3,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.saffron.withValues(alpha: 0.25),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: AppColors.saffron.withValues(alpha: 0.5)),
                          ),
                          child: const Text(
                            'पुणे',
                            style: TextStyle(
                              color: AppColors.saffronLight,
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Text(
                      'Travel & Heritage Platform',
                      style: TextStyle(
                        fontSize: 11.5,
                        color: Color(0xFF94A3B8),
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FloatingTravelBadge(
                  emoji: '🏰',
                  label: 'Sinhagad Fort',
                  subtitle: 'Maratha Glory',
                  accentColor: AppColors.saffron,
                  delayFraction: 0.0,
                ),
                SizedBox(width: 8),
                FloatingTravelBadge(
                  emoji: '🚌',
                  label: 'Pune Darshan',
                  subtitle: 'Daily AC Bus',
                  accentColor: AppColors.emerald,
                  delayFraction: 0.4,
                ),
                SizedBox(width: 8),
                FloatingTravelBadge(
                  emoji: '🧭',
                  label: 'Sahyadri Trails',
                  subtitle: 'Ghat Circuits',
                  accentColor: AppColors.skyBlue,
                  delayFraction: 0.7,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Desktop Sign In Left Panel (Matching top-left panel of reference)
  Widget _buildSignInHero(BuildContext context, {required Key key}) {
    final theme = Theme.of(context);

    return Container(
      key: key,
      decoration: const BoxDecoration(
        color: Color(0xFF022C22),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // 1. High-definition Sinhagad Fort Hero Asset
          Image.asset(
            'assets/images/auth_hero_sinhagad_hd.jpg',
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              color: const Color(0xFF064E3B),
              child: const Center(
                child: Icon(Icons.terrain_rounded, size: 80, color: Colors.white24),
              ),
            ),
          ),

          // 2. Cinematic Gradient Scrim (deep emerald to slate dark)
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  const Color(0xFF064E3B).withValues(alpha: 0.45),
                  const Color(0xFF022C22).withValues(alpha: 0.75),
                  const Color(0xFF0A1E19).withValues(alpha: 0.95),
                ],
                stops: const [0.0, 0.45, 1.0],
              ),
            ),
          ),

          // 3. Foliage Accents (top-right leaves)
          Positioned(
            top: -20,
            right: -20,
            child: Opacity(
              opacity: 0.35,
              child: Icon(
                Icons.eco_rounded,
                size: 140,
                color: AppColors.emerald.withValues(alpha: 0.3),
              ),
            ),
          ),

          // 4. Content Composition
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: MediaQuery.of(context).size.width < 1200 ? 28 : 44,
              vertical: 40,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Top Header Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Brand Identity
                    Expanded(
                      child: Row(
                        children: [
                          Container(
                            width: 46,
                            height: 46,
                            decoration: BoxDecoration(
                              color: AppColors.authPrimaryGreen,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.3),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            alignment: Alignment.center,
                            child: const Text('🚩', style: TextStyle(fontSize: 22)),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Wrap(
                                  crossAxisAlignment: WrapCrossAlignment.center,
                                  children: [
                                    Text(
                                      'PuneExplorer',
                                      style: theme.textTheme.titleLarge?.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w900,
                                        fontSize: 21,
                                        letterSpacing: -0.4,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: AppColors.saffron.withValues(alpha: 0.25),
                                        borderRadius: BorderRadius.circular(5),
                                        border: Border.all(color: AppColors.saffron.withValues(alpha: 0.5)),
                                      ),
                                      child: const Text(
                                        'पुणे',
                                        style: TextStyle(
                                          color: AppColors.saffronLight,
                                          fontSize: 10.5,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const Text(
                                  'Travel & Sahyadri Heritage Platform',
                                  style: TextStyle(
                                    fontSize: 11.5,
                                    color: Color(0xFFCBD5E1),
                                    fontWeight: FontWeight.w500,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Calligraphic Script: "Explore Experience Belong"
                    Transform.rotate(
                      angle: -0.05,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                        ),
                        child: const Text(
                          'Explore\nExperience\nBelong',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'serif',
                            fontStyle: FontStyle.italic,
                            color: Color(0xFFFEF3C7),
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                            height: 1.25,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                // Center Headline & Feature Cards
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Main Headline (Discover Pune. Beyond Destinations.)
                    RichText(
                      text: TextSpan(
                        children: [
                          const TextSpan(
                            text: 'Discover Pune\n',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 38,
                              fontWeight: FontWeight.w900,
                              height: 1.15,
                              letterSpacing: -0.8,
                            ),
                          ),
                          TextSpan(
                            text: 'Beyond Destinations',
                            style: TextStyle(
                              color: AppColors.authGold,
                              fontSize: 38,
                              fontWeight: FontWeight.w900,
                              height: 1.15,
                              letterSpacing: -0.8,
                              shadows: [
                                Shadow(
                                  color: Colors.black.withValues(alpha: 0.4),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Subtitle
                    const Text(
                      'Forts, temples, culture, food and stories —\nall in one journey.',
                      style: TextStyle(
                        fontSize: 15,
                        color: Color(0xFFE2E8F0),
                        height: 1.5,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(height: 32),

                    // 4 Circular Feature Badges Connected in Row
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildFeatureCircle(
                            icon: Icons.castle_rounded,
                            label: 'Heritage\nPlaces',
                            bgColor: const Color(0xFFD97706).withValues(alpha: 0.2),
                            borderColor: const Color(0xFFF59E0B),
                            iconColor: const Color(0xFFFDE68A),
                          ),
                          _buildConnectingArrow(),
                          _buildFeatureCircle(
                            icon: Icons.directions_bus_rounded,
                            label: 'Official\nBus Tours',
                            bgColor: AppColors.emerald.withValues(alpha: 0.2),
                            borderColor: AppColors.emerald,
                            iconColor: const Color(0xFFA7F3D0),
                          ),
                          _buildConnectingArrow(),
                          _buildFeatureCircle(
                            icon: Icons.map_rounded,
                            label: 'Curated\nItineraries',
                            bgColor: AppColors.saffron.withValues(alpha: 0.2),
                            borderColor: AppColors.saffron,
                            iconColor: const Color(0xFFFED7AA),
                          ),
                          _buildConnectingArrow(),
                          _buildFeatureCircle(
                            icon: Icons.smart_toy_rounded,
                            label: 'AI Travel\nGuide',
                            bgColor: AppColors.skyBlue.withValues(alpha: 0.2),
                            borderColor: AppColors.skyBlue,
                            iconColor: const Color(0xFFBAE6FD),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                // Bottom Editorial Quote & Line Art
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '“Not just a trip,\n a story you live.”',
                      style: TextStyle(
                        fontFamily: 'serif',
                        fontStyle: FontStyle.italic,
                        color: Color(0xFFFDE68A),
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Subtle Pune architectural sketch line
                    Row(
                      children: [
                        Icon(
                          Icons.location_city_rounded,
                          size: 16,
                          color: Colors.white.withValues(alpha: 0.3),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Container(
                            height: 1,
                            color: Colors.white.withValues(alpha: 0.15),
                          ),
                        ),
                      ],
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

  /// Desktop Register Left Panel (Matching top-right panel of reference)
  Widget _buildRegisterHero(BuildContext context, {required Key key}) {
    final theme = Theme.of(context);

    return Container(
      key: key,
      decoration: const BoxDecoration(
        color: Color(0xFF1E1B18),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // 1. High-definition Arch & Pune Skyline Asset
          Image.asset(
            'assets/images/auth_hero_arch_pune_hd.jpg',
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              color: const Color(0xFF292524),
              child: const Center(
                child: Icon(Icons.account_balance_rounded, size: 80, color: Colors.white24),
              ),
            ),
          ),

          // 2. Warm Sunset Vignette Scrim
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  const Color(0xFF0F172A).withValues(alpha: 0.35),
                  const Color(0xFF1C1917).withValues(alpha: 0.65),
                  const Color(0xFF0C0A09).withValues(alpha: 0.9),
                ],
              ),
            ),
          ),

          // 3. Content Composition
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: MediaQuery.of(context).size.width < 1200 ? 28 : 44,
              vertical: 40,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Top Header Quote inside the stone arch
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Become a part of\na community that\ncelebrates Pune.',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontFamily: 'serif',
                        fontStyle: FontStyle.italic,
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 32,
                        height: 1.25,
                        shadows: [
                          Shadow(
                            color: Colors.black.withValues(alpha: 0.6),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      width: 60,
                      height: 3,
                      decoration: BoxDecoration(
                        color: AppColors.authOrange,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ],
                ),

                // Center Vertical Feature Cards (Glassmorphic)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildGlassmorphicFeatureRow(
                      icon: Icons.directions_bus_filled_rounded,
                      text: 'Book Official\nDarshan Tours',
                      accentColor: AppColors.emerald,
                    ),
                    const SizedBox(height: 12),
                    _buildGlassmorphicFeatureRow(
                      icon: Icons.bookmark_rounded,
                      text: 'Save Your\nItineraries',
                      accentColor: AppColors.skyBlue,
                    ),
                    const SizedBox(height: 12),
                    _buildGlassmorphicFeatureRow(
                      icon: Icons.auto_awesome_rounded,
                      text: 'Get Personalized\nRecommendations',
                      accentColor: AppColors.authGold,
                    ),
                    const SizedBox(height: 12),
                    _buildGlassmorphicFeatureRow(
                      icon: Icons.groups_rounded,
                      text: 'Be Part of a\nHeritage Community',
                      accentColor: AppColors.authOrange,
                    ),
                  ],
                ),

                // Bottom Calligraphy: "Pune More Than a Place It's a Feeling"
                Align(
                  alignment: Alignment.bottomRight,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
                    ),
                    child: const Text(
                      'Pune\nMore Than a Place\nIt\'s a Feeling',
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        fontFamily: 'serif',
                        fontStyle: FontStyle.italic,
                        color: Color(0xFFFFF9EE),
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        height: 1.25,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Feature circle used in Sign In layout
  Widget _buildFeatureCircle({
    required IconData icon,
    required String label,
    required Color bgColor,
    required Color borderColor,
    required Color iconColor,
  }) {
    return Column(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: bgColor,
            shape: BoxShape.circle,
            border: Border.all(color: borderColor, width: 1.5),
            boxShadow: [
              BoxShadow(
                color: borderColor.withValues(alpha: 0.3),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(icon, color: iconColor, size: 22),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 10.5,
            fontWeight: FontWeight.w600,
            height: 1.2,
          ),
        ),
      ],
    );
  }

  Widget _buildConnectingArrow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 12),
      child: Icon(
        Icons.chevron_right_rounded,
        size: 16,
        color: Colors.white.withValues(alpha: 0.3),
      ),
    );
  }

  /// Glassmorphic vertical feature row for Register layout
  Widget _buildGlassmorphicFeatureRow({
    required IconData icon,
    required String text,
    required Color accentColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: accentColor, size: 20),
          ),
          const SizedBox(width: 12),
          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 12.5,
              height: 1.25,
            ),
          ),
        ],
      ),
    );
  }
}
