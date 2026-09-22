import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';

class AccountSupportSection extends StatelessWidget {
  final bool isDark;
  final bool isGuest;
  final VoidCallback onHelp;
  final VoidCallback onPrivacy;
  final VoidCallback onTerms;
  final VoidCallback onCancellation;
  final VoidCallback onAbout;
  final VoidCallback? onDeleteAccount;

  const AccountSupportSection({
    super.key,
    required this.isDark,
    required this.isGuest,
    required this.onHelp,
    required this.onPrivacy,
    required this.onTerms,
    required this.onCancellation,
    required this.onAbout,
    this.onDeleteAccount,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Text(
            'Account & Support',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
            ),
          ),
        ),
        _buildListTile('Help & FAQs', Icons.help_outline_rounded, AppColors.emerald, onHelp),
        _buildListTile('Privacy Policy', Icons.policy_outlined, AppColors.skyBlue, onPrivacy),
        _buildListTile('Terms & Conditions', Icons.gavel_outlined, AppColors.amber, onTerms),
        _buildListTile('Cancellation & Refund Policy', Icons.currency_rupee_rounded, AppColors.emerald, onCancellation),
        _buildListTile('About PuneExplorer', Icons.info_outline_rounded, AppColors.saffron, onAbout),
        if (!isGuest && onDeleteAccount != null)
          _buildListTile('Account & Data Deletion', Icons.delete_outline, AppColors.error, onDeleteAccount!),
      ],
    );
  }

  Widget _buildListTile(String title, IconData icon, Color iconColor, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: iconColor),
      title: Text(
        title,
        style: TextStyle(
          color: (title == 'Account & Data Deletion') 
              ? AppColors.error 
              : (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: Icon(
        Icons.chevron_right,
        color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
      ),
      onTap: onTap,
    );
  }
}
