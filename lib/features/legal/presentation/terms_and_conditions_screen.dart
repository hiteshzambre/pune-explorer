import 'package:flutter/material.dart';
import 'widgets/legal_page_scaffold.dart';

class TermsAndConditionsScreen extends StatelessWidget {
  const TermsAndConditionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const LegalPageScaffold(
      title: 'Terms & Conditions',
      category: 'User Agreement & Platform Rules',
      lastUpdated: 'August 2026',
      children: [
        LegalSectionCard(
          icon: Icons.gavel_rounded,
          title: '1. Acceptance of Terms',
          content:
              'By creating an account, browsing heritage landmarks, or purchasing tour passes on PuneExplorer, you agree to comply with and be legally bound by these Terms & Conditions. If you disagree with any part of these terms, please discontinue platform use.',
        ),
        LegalSectionCard(
          icon: Icons.castle_rounded,
          title: '2. Heritage Conservation Code',
          content:
              'PuneExplorer promotes responsible and sustainable tourism across Maratha forts, ASI monuments, and Western Ghats sanctuaries. Users agree to:',
          bulletPoints: [
            'Refrain from carving, painting, or defacing historic bastions, inscriptions, or temple walls.',
            'Adhere to strict zero-plastic and waste carry-back rules on all Sahyadri trek routes.',
            'Respect local village customs, temple dress codes, and forest department photography regulations.',
          ],
        ),
        LegalSectionCard(
          icon: Icons.confirmation_number_outlined,
          title: '3. Digital Boarding Passes & QR Verification',
          content:
              'All booked tour passes generate a tamper-proof digital boarding pass containing a unique QR verification code. Passes are non-transferable without advance notice. Passengers must present valid photo identification corresponding to the passenger manifest at bus boarding terminals.',
        ),
        LegalSectionCard(
          icon: Icons.price_change_outlined,
          title: '4. Tour Pricing, Customization & GST',
          content:
              'Published tour package prices include AC bus transport, certified historian commentary, and basic admission passes unless specified otherwise. Add-on vehicle upgrades, traditional Puneri meal options, and luxury stays are calculated dynamically. A statutory 5% GST and ₹99 platform service fee apply at checkout.',
        ),
        LegalSectionCard(
          icon: Icons.security_rounded,
          title: '5. Limitation of Liability & Trek Safety',
          content:
              'Trekking in high-altitude Sahyadri forts involves natural terrain challenges. While PuneExplorer partners only with certified tour coordinators, travelers are advised to exercise personal caution, wear appropriate footwear, and heed monsoon weather advisories.',
        ),
      ],
    );
  }
}
