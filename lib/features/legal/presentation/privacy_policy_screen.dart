import 'package:flutter/material.dart';
import 'widgets/legal_page_scaffold.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const LegalPageScaffold(
      title: 'Privacy Policy',
      category: 'Data Protection & Transparency',
      lastUpdated: 'August 2026',
      children: [
        LegalSectionCard(
          icon: Icons.shield_outlined,
          title: '1. Introduction & Our Commitment',
          content:
              'PuneExplorer ("we", "our", or "the Platform") is committed to safeguarding your privacy and ensuring transparency in all travel discovery and booking operations. This Privacy Policy details the exact data collected, stored, and processed when you use our mobile and web applications.',
        ),
        LegalSectionCard(
          icon: Icons.storage_rounded,
          title: '2. Information We Collect',
          content:
              'We collect only the minimal information essential for creating user accounts, booking tour passes, and delivering personalized travel recommendations:',
          bulletPoints: [
            'Account Information: Full name, verified email address, and optional phone number during registration.',
            'Tour Booking Data: Passenger details (names, ages, genders), selected departure dates, seat allocations, and pickup terminal locations.',
            'Local Preferences: Saved favorite landmarks, recent search queries, theme preference (Dark/Light mode), and selected app language (English, Marathi, Hindi).',
            'Cryptographic Pass Hashes: Deterministic SHA-256 digital boarding pass tokens for offline QR ticket verification.',
          ],
        ),
        LegalSectionCard(
          icon: Icons.lock_outline_rounded,
          title: '3. Data Storage & Local Persistence',
          content:
              'PuneExplorer emphasizes on-device security. User authentication tokens, cached itinerary plans, offline landmark catalogues, and booking records are stored locally using encrypted SharedPreferences storage. No biometric or financial card details are ever persisted on your device.',
        ),
        LegalSectionCard(
          icon: Icons.payment_rounded,
          title: '4. Payments & Financial Information',
          content:
              'All tour ticket transactions are processed through certified PCI-DSS compliant payment gateway partners (Razorpay / UPI). PuneExplorer does not capture, store, or view full credit/debit card numbers or UPI PINs. We only retain the transaction reference ID for booking confirmation and refund processing.',
        ),
        LegalSectionCard(
          icon: Icons.share_location_rounded,
          title: '5. Location & Map Data',
          content:
              'Approximate device coordinates are used solely within the interactive Sahyadri route map and turn-by-turn navigation screens to calculate distance to Pune landmarks. Your real-time geolocation is never logged on remote servers or shared with advertising third parties.',
        ),
        LegalSectionCard(
          icon: Icons.delete_forever_rounded,
          title: '6. User Rights & Account Deletion',
          content:
              'You have full control over your personal data. You may export your booking history or permanently delete your account and all associated records at any time directly through the "Account & Data Deletion" screen in Profile Settings.',
        ),
      ],
    );
  }
}
