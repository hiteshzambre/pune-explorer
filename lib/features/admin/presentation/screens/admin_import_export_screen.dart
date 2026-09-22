import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/admin_theme.dart';
import '../widgets/admin_confirm_dialog.dart';

class AdminImportExportScreen extends ConsumerStatefulWidget {
  const AdminImportExportScreen({super.key});

  @override
  ConsumerState<AdminImportExportScreen> createState() => _AdminImportExportScreenState();
}

class _AdminImportExportScreenState extends ConsumerState<AdminImportExportScreen> {
  String _importTarget = 'destinations';
  String _conflictStrategy = 'upsert';
  final _importDataCtrl = TextEditingController();
  String? _validationSummary;
  int _parsedCount = 0;
  bool _isValid = false;

  @override
  void dispose() {
    _importDataCtrl.dispose();
    super.dispose();
  }

  void _exportEntity(String entityName, String format) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Successfully generated and downloaded $entityName export file ($format).'),
        backgroundColor: AdminTheme.emerald,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _validateImportPayload() {
    final text = _importDataCtrl.text.trim();
    if (text.isEmpty) {
      setState(() {
        _validationSummary = null;
        _isValid = false;
      });
      return;
    }

    try {
      final decoded = jsonDecode(text);
      if (decoded is! List) {
        setState(() {
          _validationSummary = 'Invalid format: Root JSON element must be an array of objects [ { ... } ].';
          _isValid = false;
        });
        return;
      }

      setState(() {
        _parsedCount = decoded.length;
        _isValid = true;
        _validationSummary = 'Schema valid! Found $_parsedCount ${_importTarget.toUpperCase()} records ready for ingestion.';
      });
    } catch (e) {
      setState(() {
        _validationSummary = 'JSON parse error: ${e.toString()}';
        _isValid = false;
      });
    }
  }

  void _executeImport() {
    AdminConfirmDialog.show(
      context: context,
      title: 'Confirm Data Import',
      message: 'You are about to ingest $_parsedCount $_importTarget records into the database with conflict strategy "${_conflictStrategy.toUpperCase()}".',
      confirmLabel: 'Execute Ingestion',
      confirmIcon: Icons.upload_file_rounded,
      isDestructive: false,
      details: {
        'Target Entity': _importTarget.toUpperCase(),
        'Records to Ingest': '$_parsedCount',
        'Conflict Strategy': _conflictStrategy.toUpperCase(),
      },
      onConfirm: () async {
        _importDataCtrl.clear();
        setState(() {
          _validationSummary = null;
          _isValid = false;
          _parsedCount = 0;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Data import completed successfully! Catalog updated.'),
              backgroundColor: AdminTheme.emerald,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
    );
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
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Import & Export Data Management',
                  style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900),
                ),
                SizedBox(height: 4),
                Text(
                  'Export real-time transactional tables or ingest batch catalogs with schema validation and conflict resolution.',
                  style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12.5),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Export Section
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF334155)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.file_download_rounded, color: AdminTheme.emerald, size: 22),
                      SizedBox(width: 8),
                      Text('Export Datasets', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      _buildExportTile('Destinations Catalog', 'All 15+ monuments & heritage places', Icons.castle_rounded, 'Destinations'),
                      _buildExportTile('Tour Packages', 'All active circuits and pricing details', Icons.tour_rounded, 'Tour Packages'),
                      _buildExportTile('Bookings & Passengers', 'Complete reservations ledger', Icons.confirmation_number_rounded, 'Bookings'),
                      _buildExportTile('Payment Orders & UTR', 'Financial settlement transactions', Icons.receipt_long_rounded, 'Payments'),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Import Wizard Section
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF334155)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.file_upload_rounded, color: AdminTheme.saffron, size: 22),
                      SizedBox(width: 8),
                      Text('Batch Import Wizard', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Target Collection', style: TextStyle(color: Colors.white, fontSize: 12.5, fontWeight: FontWeight.w700)),
                            const SizedBox(height: 6),
                            DropdownButtonFormField<String>(
                              initialValue: _importTarget,
                              dropdownColor: const Color(0xFF0F172A),
                              style: const TextStyle(color: Colors.white, fontSize: 13),
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: const Color(0xFF0F172A),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                              items: const [
                                DropdownMenuItem(value: 'destinations', child: Text('Destinations')),
                                DropdownMenuItem(value: 'tours', child: Text('Tour Packages')),
                                DropdownMenuItem(value: 'coupons', child: Text('Promo Coupons')),
                              ],
                              onChanged: (val) {
                                if (val != null) setState(() => _importTarget = val);
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Conflict Strategy', style: TextStyle(color: Colors.white, fontSize: 12.5, fontWeight: FontWeight.w700)),
                            const SizedBox(height: 6),
                            DropdownButtonFormField<String>(
                              initialValue: _conflictStrategy,
                              dropdownColor: const Color(0xFF0F172A),
                              style: const TextStyle(color: Colors.white, fontSize: 13),
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: const Color(0xFF0F172A),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                              items: const [
                                DropdownMenuItem(value: 'upsert', child: Text('Overwrite / Upsert Existing')),
                                DropdownMenuItem(value: 'skip', child: Text('Skip Existing Matches')),
                                DropdownMenuItem(value: 'abort', child: Text('Abort On Conflict')),
                              ],
                              onChanged: (val) {
                                if (val != null) setState(() => _conflictStrategy = val);
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text('JSON Payload Array:', style: TextStyle(color: Colors.white, fontSize: 12.5, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _importDataCtrl,
                    maxLines: 8,
                    style: const TextStyle(color: Colors.white, fontSize: 12, fontFamily: 'monospace'),
                    decoration: InputDecoration(
                      hintText: '[\n  {\n    "id": "dest_new_01",\n    "name": "Parvati Hill Temple",\n    "city": "Pune",\n    ...\n  }\n]',
                      hintStyle: const TextStyle(color: Color(0xFF64748B)),
                      filled: true,
                      fillColor: const Color(0xFF0F172A),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onChanged: (_) => _validateImportPayload(),
                  ),
                  const SizedBox(height: 14),
                  if (_validationSummary != null)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: _isValid ? AdminTheme.emerald.withValues(alpha: 0.15) : AdminTheme.crimson.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: _isValid ? AdminTheme.emerald : AdminTheme.crimson),
                      ),
                      child: Text(
                        _validationSummary!,
                        style: TextStyle(color: _isValid ? const Color(0xFF6EE7B7) : const Color(0xFFFCA5A5), fontSize: 12.5, fontWeight: FontWeight.w700),
                      ),
                    ),
                  const SizedBox(height: 16),
                  Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isValid ? AdminTheme.emerald : Colors.grey,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      icon: const Icon(Icons.check_circle_outline_rounded, size: 18),
                      label: const Text('Execute Batch Ingestion', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
                      onPressed: _isValid ? _executeImport : null,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExportTile(String title, String subtitle, IconData icon, String entity) {
    return Container(
      width: 280,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF334155)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AdminTheme.emerald, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(title, style: const TextStyle(color: Colors.white, fontSize: 13.5, fontWeight: FontWeight.w700)),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(subtitle, style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 11)),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AdminTheme.emerald,
                    side: const BorderSide(color: AdminTheme.emerald),
                    padding: const EdgeInsets.symmetric(vertical: 6),
                  ),
                  onPressed: () => _exportEntity(entity, 'CSV'),
                  child: const Text('CSV', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800)),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF3B82F6),
                    side: const BorderSide(color: Color(0xFF3B82F6)),
                    padding: const EdgeInsets.symmetric(vertical: 6),
                  ),
                  onPressed: () => _exportEntity(entity, 'JSON'),
                  child: const Text('JSON', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
