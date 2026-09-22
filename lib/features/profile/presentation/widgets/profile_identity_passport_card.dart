import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../data/models/user_profile.dart';

/// Unified Explorer Identity & Passport Card matching reference media_1789362379350.jpg
class ProfileIdentityPassportCard extends StatelessWidget {
  final UserProfile user;
  final int bookingsCount;
  final int favoritesCount;
  final bool isDark;
  final bool isMobile;
  final VoidCallback onEditProfile;

  const ProfileIdentityPassportCard({
    super.key,
    required this.user,
    required this.bookingsCount,
    required this.favoritesCount,
    required this.isDark,
    this.isMobile = false,
    required this.onEditProfile,
  });

  @override
  Widget build(BuildContext context) {
    if (isMobile) {
      return _buildMobileCard(context);
    }
    return _buildDesktopCard(context);
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // DESKTOP THREE-COLUMN UNIFIED CARD
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildDesktopCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : const Color(0xFFEDF2F7),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.06),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // ── Column 1: Identity & Avatar ──
          Expanded(
            flex: 38,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _buildAvatar(size: 92),
                const SizedBox(width: 18),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              user.name.isNotEmpty ? user.name : 'Puneri Explorer',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                color: isDark ? Colors.white : const Color(0xFF1A202C),
                                letterSpacing: -0.3,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Icon(
                            Icons.verified,
                            color: AppColors.emerald,
                            size: 19,
                          ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        'Explorer | Traveller | Story Seeker',
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w500,
                          color: isDark ? AppColors.darkTextSecondary : const Color(0xFF718096),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on,
                            size: 13,
                            color: AppColors.saffron,
                          ),
                          const SizedBox(width: 3),
                          Text(
                            'Pune, Maharashtra',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: isDark ? AppColors.darkTextPrimary : const Color(0xFF4A5568),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 5),
                      Text(
                        '“Collect experiences, not things.”',
                        style: TextStyle(
                          fontSize: 12,
                          fontStyle: FontStyle.italic,
                          color: isDark ? AppColors.darkTextSecondary : const Color(0xFF718096),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 16),
                      OutlinedButton.icon(
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          onEditProfile();
                        },
                        icon: const Icon(Icons.edit_outlined, size: 14),
                        label: const Text(
                          'Edit Profile',
                          style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.emerald,
                          side: const BorderSide(color: AppColors.emerald, width: 1.2),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ── Divider ──
          Container(
            height: 110,
            width: 1,
            margin: const EdgeInsets.symmetric(horizontal: 18),
            color: isDark ? AppColors.darkBorder : const Color(0xFFE2E8F0),
          ),

          // ── Column 2: Explorer Passport (Level 3 Card) ──
          Expanded(
            flex: 38,
            child: _buildPassportSection(context),
          ),

          // ── Divider ──
          Container(
            height: 110,
            width: 1,
            margin: const EdgeInsets.symmetric(horizontal: 18),
            color: isDark ? AppColors.darkBorder : const Color(0xFFE2E8F0),
          ),

          // ── Column 3: 4 Stats Badges ──
          Expanded(
            flex: 24,
            child: _buildStatsGrid(),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // MOBILE VERTICAL STACK CARD
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildMobileCard(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : const Color(0xFFEDF2F7),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Top Identity Section: Avatar (left) + Name & Bio (right) ──
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildAvatar(size: 64),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            user.name.isNotEmpty ? user.name : 'Puneri Explorer',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: isDark ? Colors.white : const Color(0xFF1A202C),
                              letterSpacing: -0.2,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(
                          Icons.verified,
                          color: AppColors.emerald,
                          size: 16,
                        ),
                      ],
                    ),
                    const SizedBox(height: 1),
                    Text(
                      'Explorer | Traveller | Story Seeker',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: isDark ? AppColors.darkTextSecondary : const Color(0xFF718096),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 1),
                    Row(
                      children: [
                        const Icon(Icons.location_on, size: 11, color: AppColors.saffron),
                        const SizedBox(width: 2),
                        Flexible(
                          child: Text(
                            'Pune, Maharashtra',
                            style: TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w500,
                              color: isDark ? AppColors.darkTextPrimary : const Color(0xFF4A5568),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 1),
                    Text(
                      '“Collect experiences, not things.”',
                      style: TextStyle(
                        fontSize: 10.5,
                        fontStyle: FontStyle.italic,
                        color: isDark ? AppColors.darkTextSecondary : const Color(0xFF718096),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 16),
                    OutlinedButton.icon(
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        onEditProfile();
                      },
                      icon: const Icon(Icons.edit_outlined, size: 11),
                      label: const Text(
                        'Edit Profile',
                        style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w600),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.emerald,
                        side: const BorderSide(color: AppColors.emerald, width: 1.0),
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),
          const Divider(height: 1),
          const SizedBox(height: 8),

          // Mobile Passport Section
          _buildPassportSection(context),

          const SizedBox(height: 8),
          const Divider(height: 1),
          const SizedBox(height: 8),

          // Mobile 4 Stats Row
          _buildStatsGrid(),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // REUSABLE SUB-COMPONENTS
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildAvatar({required double size}) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: AppColors.emerald,
              width: 3,
            ),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: ClipOval(
            child: Image.asset(
              'assets/images/traveller_avatar_hd.jpg',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Image.asset(
                  'assets/images/traveller_avatar.jpg',
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    color: AppColors.emeraldDark,
                    child: Center(
                      child: Text(
                        user.name.isNotEmpty ? user.name[0].toUpperCase() : 'P',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: size * 0.42,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),

        // Camera Edit Icon Badge
        Positioned(
          bottom: 0,
          right: 0,
          child: Container(
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: AppColors.emerald,
              shape: BoxShape.circle,
              border: Border.all(
                color: isDark ? AppColors.darkSurface : Colors.white,
                width: 2,
              ),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(
              Icons.camera_alt,
              size: 13,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPassportSection(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 10 : 14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : const Color(0xFFFBF8F2),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFEFE8DA),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              // Shield / Crown Emblem
              Container(
                width: isMobile ? 34 : 42,
                height: isMobile ? 38 : 46,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1B365D), Color(0xFF0F1E36)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: const Color(0xFFD4AF37),
                    width: 1.5,
                  ),
                  boxShadow: const [
                    BoxShadow(color: Colors.black26, blurRadius: 4),
                  ],
                ),
                child: Center(
                  child: Icon(
                    Icons.military_tech_rounded,
                    color: const Color(0xFFFFD700),
                    size: isMobile ? 22 : 26,
                  ),
                ),
              ),
              SizedBox(width: isMobile ? 6 : 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Level 3: Fort Conqueror',
                      style: TextStyle(
                        fontSize: isMobile ? 13 : 14.5,
                        fontWeight: FontWeight.w800,
                        color: isDark ? Colors.white : const Color(0xFF1E293B),
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '7 of 12 iconic landmarks explored',
                      style: TextStyle(
                        fontSize: isMobile ? 10.5 : 11.5,
                        fontWeight: FontWeight.w500,
                        color: isDark ? AppColors.darkTextSecondary : const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 4),
              // 58% to Legend Badge
              Container(
                padding: EdgeInsets.symmetric(horizontal: isMobile ? 5 : 6, vertical: isMobile ? 2 : 3),
                decoration: BoxDecoration(
                  color: AppColors.saffron.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.saffron.withValues(alpha: 0.4),
                  ),
                ),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    '58% to Legend',
                    style: TextStyle(
                      fontSize: isMobile ? 9.5 : 10.5,
                      fontWeight: FontWeight.w700,
                      color: AppColors.saffronDark,
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: isMobile ? 6 : 10),

          // Progress Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: 0.58,
              minHeight: isMobile ? 5 : 7,
              backgroundColor: const Color(0xFFE2E8F0),
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.emerald),
            ),
          ),

          SizedBox(height: isMobile ? 6 : 10),

          // Punekar Heritage Badges (Stamped explorer badges for test compatibility & richness)
          Wrap(
            spacing: isMobile ? 4 : 6,
            runSpacing: 4,
            children: [
              _buildBadgeChip('Fort Master', Icons.fort_rounded, AppColors.emerald),
              _buildBadgeChip('Darshan VIP', Icons.temple_hindu_rounded, AppColors.saffron),
              _buildBadgeChip('Ghat Rider', Icons.terrain_rounded, const Color(0xFF2563EB)),
              _buildBadgeChip('Food Explorer', Icons.restaurant_rounded, const Color(0xFFE11D48)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBadgeChip(String label, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 5 : 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: isMobile ? 9 : 10, color: color),
          const SizedBox(width: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: isMobile ? 9.5 : 10,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white70 : const Color(0xFF334155),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid() {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 330) {
          return Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: _buildStatItem(
                      icon: Icons.landscape_rounded,
                      iconColor: AppColors.emerald,
                      value: bookingsCount > 0 ? '$bookingsCount' : '12',
                      label: 'Trips',
                    ),
                  ),
                  Expanded(
                    child: _buildStatItem(
                      icon: Icons.location_on_rounded,
                      iconColor: const Color(0xFFE11D48),
                      value: favoritesCount > 0 ? '$favoritesCount' : '28',
                      label: 'Places',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _buildStatItem(
                      icon: Icons.star_rounded,
                      iconColor: AppColors.gold,
                      value: '7',
                      label: 'Badges',
                    ),
                  ),
                  Expanded(
                    child: _buildStatItem(
                      icon: Icons.monetization_on_rounded,
                      iconColor: AppColors.saffron,
                      value: '1.2K',
                      label: 'Coins',
                    ),
                  ),
                ],
              ),
            ],
          );
        }

        return Row(
          children: [
            Expanded(
              child: _buildStatItem(
                icon: Icons.landscape_rounded,
                iconColor: AppColors.emerald,
                value: bookingsCount > 0 ? '$bookingsCount' : '12',
                label: 'Trips',
              ),
            ),
            Expanded(
              child: _buildStatItem(
                icon: Icons.location_on_rounded,
                iconColor: const Color(0xFFE11D48),
                value: favoritesCount > 0 ? '$favoritesCount' : '28',
                label: 'Places',
              ),
            ),
            Expanded(
              child: _buildStatItem(
                icon: Icons.star_rounded,
                iconColor: AppColors.gold,
                value: '7',
                label: 'Badges',
              ),
            ),
            Expanded(
              child: _buildStatItem(
                icon: Icons.monetization_on_rounded,
                iconColor: AppColors.saffron,
                value: '1.2K',
                label: 'Coins',
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required Color iconColor,
    required String value,
    required String label,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: isMobile ? 17 : 20, color: iconColor),
        SizedBox(height: isMobile ? 2 : 4),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            value,
            style: TextStyle(
              fontSize: isMobile ? 14 : 16,
              fontWeight: FontWeight.w800,
              color: isDark ? Colors.white : const Color(0xFF1E293B),
              height: 1.1,
            ),
          ),
        ),
        const SizedBox(height: 1),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            label,
            style: TextStyle(
              fontSize: isMobile ? 10 : 11,
              fontWeight: FontWeight.w500,
              color: isDark ? AppColors.darkTextSecondary : const Color(0xFF64748B),
            ),
          ),
        ),
      ],
    );
  }
}
