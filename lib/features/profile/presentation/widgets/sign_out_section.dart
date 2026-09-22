import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../app/theme/app_colors.dart';

/// Sign Out / Sign In section at the bottom of the profile page.
class SignOutSection extends StatelessWidget {
  final bool isGuest;
  final VoidCallback onSignOut;
  final VoidCallback onSignIn;

  const SignOutSection({
    super.key,
    required this.isGuest,
    required this.onSignOut,
    required this.onSignIn,
  });

  @override
  Widget build(BuildContext context) {
    if (!isGuest) {
      return SizedBox(
        width: double.infinity,
        child: OutlinedButton.icon(
          onPressed: onSignOut,
          icon: const Icon(Icons.logout_rounded, size: 16, color: AppColors.error),
          label: const Text(
            'Sign Out of PuneExplorer',
            style: TextStyle(color: AppColors.error, fontWeight: FontWeight.w700),
          ),
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: AppColors.error),
            padding: const EdgeInsets.symmetric(vertical: 13),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
        ),
      );
    }

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () {
          HapticFeedback.lightImpact();
          onSignIn();
        },
        icon: const Icon(Icons.login_rounded, size: 16),
        label: const Text(
          'Sign In / Join PuneExplorer',
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13.5),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.emerald,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
    );
  }
}
