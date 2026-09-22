import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/admin_support_ticket.dart';

abstract class AdminSupportRepository {
  Future<List<AdminSupportTicket>> getTickets();
  Future<AdminSupportTicket?> getTicketById(String id);
  Future<void> updateTicketStatus(String id, String status);
  Future<void> assignAdmin(String id, String adminEmail);
  Future<void> addMessage(String ticketId, SupportMessage message);
  Future<void> addInternalNote(String ticketId, String note);
  Future<void> saveTicket(AdminSupportTicket ticket);
}

class LocalAdminSupportRepository implements AdminSupportRepository {
  static const String keySupportTickets = 'pune_explorer_support_tickets';
  List<AdminSupportTicket>? _cache;

  Future<void> _initFromStorage() async {
    if (_cache != null) return;
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(keySupportTickets);
    if (raw != null && raw.isNotEmpty) {
      try {
        final List<dynamic> list = jsonDecode(raw);
        _cache = list.map((e) => AdminSupportTicket.fromJson(e as Map<String, dynamic>)).toList();
        return;
      } catch (_) {}
    }

    final now = DateTime.now();
    _cache = [
      AdminSupportTicket(
        id: 'TICK-1001',
        customerName: 'Rohit Kulkarni',
        customerEmail: 'rohit.kulkarni@gmail.com',
        customerPhone: '+91 98230 45678',
        subject: 'UTR submission confirmation for Shaniwar Wada tour',
        priority: 'high',
        status: 'open',
        bookingId: 'PUNE-ADMIN-01',
        orderId: 'PE-2026-888999',
        createdAt: now.subtract(const Duration(hours: 2)).toIso8601String(),
        updatedAt: now.subtract(const Duration(minutes: 30)).toIso8601String(),
        assignedAdmin: 'admin@puneexplorer.in',
        messages: [
          SupportMessage(
            id: 'm1',
            sender: 'customer',
            senderName: 'Rohit Kulkarni',
            message: 'Hello, I submitted my UTR reference 425619842011 via Google Pay 2 hours ago. Could you please confirm if my pass is active?',
            timestamp: now.subtract(const Duration(hours: 2)).toIso8601String(),
          ),
          SupportMessage(
            id: 'm2',
            sender: 'agent',
            senderName: 'Admin Support',
            message: 'Hello Rohit, our banking operations team is verifying your UTR against our HDFC statement. You will receive an instant pass notification shortly.',
            timestamp: now.subtract(const Duration(minutes: 30)).toIso8601String(),
          ),
        ],
        internalNotes: [
          'Bank statement reconciliation pending for batch #14.',
        ],
      ),
      AdminSupportTicket(
        id: 'TICK-1002',
        customerName: 'Ananya Joshi',
        customerEmail: 'ananya.joshi@outlook.com',
        customerPhone: '+91 98811 54321',
        subject: 'Reschedule Pune Darshan Bus seat pickup location',
        priority: 'medium',
        status: 'in_progress',
        bookingId: 'PUNE-BK-202',
        createdAt: now.subtract(const Duration(days: 1)).toIso8601String(),
        updatedAt: now.subtract(const Duration(hours: 4)).toIso8601String(),
        assignedAdmin: 'priya.kulkarni@puneexplorer.in',
        messages: [
          SupportMessage(
            id: 'm1',
            sender: 'customer',
            senderName: 'Ananya Joshi',
            message: 'Can I change my pickup stop from Pune Station to Deccan Gymkhana for tomorrow morning?',
            timestamp: now.subtract(const Duration(days: 1)).toIso8601String(),
          ),
        ],
        internalNotes: [
          'Checked bus manifest: Seat 12 is flexible. Notified driver Mr. Shinde.',
        ],
      ),
      AdminSupportTicket(
        id: 'TICK-1003',
        customerName: 'Sanjay Deshmukh',
        customerEmail: 'sanjay.d@yahoo.com',
        customerPhone: '+91 97654 32109',
        subject: 'Monsoon fort trek safety guide inquiry',
        priority: 'low',
        status: 'resolved',
        createdAt: now.subtract(const Duration(days: 3)).toIso8601String(),
        updatedAt: now.subtract(const Duration(days: 2)).toIso8601String(),
        assignedAdmin: 'admin@puneexplorer.in',
        messages: [
          SupportMessage(
            id: 'm1',
            sender: 'customer',
            senderName: 'Sanjay Deshmukh',
            message: 'Is Sinhagad fort open during heavy rains this Saturday?',
            timestamp: now.subtract(const Duration(days: 3)).toIso8601String(),
          ),
          SupportMessage(
            id: 'm2',
            sender: 'agent',
            senderName: 'Admin Support',
            message: 'Yes, the trekking trail is open under Forest Dept supervision. Please wear high-traction footwear and adhere to designated railings.',
            timestamp: now.subtract(const Duration(days: 2)).toIso8601String(),
          ),
        ],
        internalNotes: ['Customer was satisfied with Forest Dept safety bulletin link.'],
      ),
    ];
    await _saveToStorage();
  }

  Future<void> _saveToStorage() async {
    final prefs = await SharedPreferences.getInstance();
    if (_cache != null) {
      final raw = jsonEncode(_cache!.map((t) => t.toJson()).toList());
      await prefs.setString(keySupportTickets, raw);
    }
  }

  @override
  Future<List<AdminSupportTicket>> getTickets() async {
    await _initFromStorage();
    return List.unmodifiable(_cache!);
  }

  @override
  Future<AdminSupportTicket?> getTicketById(String id) async {
    await _initFromStorage();
    return _cache!.where((t) => t.id == id).firstOrNull;
  }

  @override
  Future<void> updateTicketStatus(String id, String status) async {
    await _initFromStorage();
    final idx = _cache!.indexWhere((t) => t.id == id);
    if (idx >= 0) {
      _cache![idx] = _cache![idx].copyWith(
        status: status,
        updatedAt: DateTime.now().toIso8601String(),
      );
      await _saveToStorage();
    }
  }

  @override
  Future<void> assignAdmin(String id, String adminEmail) async {
    await _initFromStorage();
    final idx = _cache!.indexWhere((t) => t.id == id);
    if (idx >= 0) {
      _cache![idx] = _cache![idx].copyWith(
        assignedAdmin: adminEmail,
        updatedAt: DateTime.now().toIso8601String(),
      );
      await _saveToStorage();
    }
  }

  @override
  Future<void> addMessage(String ticketId, SupportMessage message) async {
    await _initFromStorage();
    final idx = _cache!.indexWhere((t) => t.id == ticketId);
    if (idx >= 0) {
      final old = _cache![idx];
      _cache![idx] = old.copyWith(
        messages: [...old.messages, message],
        updatedAt: DateTime.now().toIso8601String(),
      );
      await _saveToStorage();
    }
  }

  @override
  Future<void> addInternalNote(String ticketId, String note) async {
    await _initFromStorage();
    final idx = _cache!.indexWhere((t) => t.id == ticketId);
    if (idx >= 0) {
      final old = _cache![idx];
      _cache![idx] = old.copyWith(
        internalNotes: [...old.internalNotes, note],
        updatedAt: DateTime.now().toIso8601String(),
      );
      await _saveToStorage();
    }
  }

  @override
  Future<void> saveTicket(AdminSupportTicket ticket) async {
    await _initFromStorage();
    final idx = _cache!.indexWhere((t) => t.id == ticket.id);
    if (idx >= 0) {
      _cache![idx] = ticket;
    } else {
      _cache!.insert(0, ticket);
    }
    await _saveToStorage();
  }
}
