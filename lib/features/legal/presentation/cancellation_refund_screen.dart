import 'package:flutter/material.dart';
import 'widgets/legal_page_scaffold.dart';

class CancellationRefundScreen extends StatelessWidget {
  const CancellationRefundScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const LegalPageScaffold(
      title: 'Cancellation & Refund Policy',
      category: 'Transparent Refund Guarantees',
      lastUpdated: 'August 2026',
      children: [
        LegalSectionCard(
          icon: Icons.currency_rupee_rounded,
          title: '1. Standard Cancellation Tiers',
          content:
              'PuneExplorer operates a transparent, tiered refund model for all Pune Darshan bus tours and guided Sahyadri circuits:',
          bulletPoints: [
            'More than 24 hours prior to tour departure: 90% refund of the total booking value (10% retained for payment gateway and reservation processing).',
            'Between 12 to 24 hours prior to tour departure: 50% refund of the total booking value.',
            'Less than 12 hours prior or No-Show: Non-refundable due to reserved coach seat and historian guide commitments.',
          ],
        ),
        LegalSectionCard(
          icon: Icons.flash_on_rounded,
          title: '2. Refund Processing Timelines',
          content:
              'Approved cancellation refunds are initiated immediately by our automated billing engine. The credit will reflect in your original payment source (UPI account, Credit/Debit card, or Net Banking) within 3 to 5 business days, subject to your banking institution.',
        ),
        LegalSectionCard(
          icon: Icons.cloud_off_rounded,
          title: '3. Weather & Force Majeure Cancellations',
          content:
              'In the event of extreme monsoon landslides, red weather alerts by the IMD, or state government fort closures, PuneExplorer will offer you the choice of a 100% full refund or free rescheduling to a future departure date of your choice.',
        ),
        LegalSectionCard(
          icon: Icons.cancel_presentation_rounded,
          title: '4. How to Cancel a Booking',
          content:
              'To cancel a reservation, navigate to "Profile" ➔ "My Tour Bookings", select the active booking, and tap "Cancel Booking". The calculated refund amount will be displayed for your confirmation before finalizing.',
        ),
      ],
    );
  }
}
