import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/admin_support_ticket.dart';
import '../admin_support_repository.dart';
import '../../../core/supabase/supabase_config.dart';

class SupabaseSupportRepository implements AdminSupportRepository {
  final SupabaseClient? _client;
  final LocalAdminSupportRepository _fallback = LocalAdminSupportRepository();

  SupabaseSupportRepository([SupabaseClient? client])
      : _client = client ?? SupabaseConfig.client;

  SupabaseClient get client {
    final c = _client ?? SupabaseConfig.client;
    if (c == null) throw StateError('Supabase is not initialized.');
    return c;
  }

  @override
  Future<List<AdminSupportTicket>> getTickets() async {
    try {
      final res = await client
          .from(SupabaseConfig.tableSupportTickets)
          .select()
          .order('created_at', ascending: false);

      final list = res as List<dynamic>;
      if (list.isEmpty) return await _fallback.getTickets();

      return list.map((item) {
        return AdminSupportTicket(
          id: item['id'] as String,
          customerName: item['customer_name'] as String? ?? 'Customer',
          customerEmail: item['customer_email'] as String? ?? '',
          customerPhone: item['customer_phone'] as String? ?? '',
          subject: item['subject'] as String? ?? '',
          priority: item['priority'] as String? ?? 'medium',
          status: item['status'] as String? ?? 'open',
          bookingId: item['booking_id'] as String?,
          createdAt: item['created_at']?.toString() ?? DateTime.now().toIso8601String(),
          updatedAt: item['updated_at']?.toString() ?? DateTime.now().toIso8601String(),
          assignedAdmin: item['assigned_to'] as String? ?? 'Unassigned',
          messages: const [],
        );
      }).toList();
    } catch (e) {
      debugPrint('[SupabaseSupportRepository] getTickets error: $e');
      return await _fallback.getTickets();
    }
  }

  @override
  Future<AdminSupportTicket?> getTicketById(String id) async {
    try {
      final res = await client
          .from(SupabaseConfig.tableSupportTickets)
          .select()
          .eq('id', id)
          .maybeSingle();

      if (res == null) return await _fallback.getTicketById(id);

      final msgRes = await client
          .from(SupabaseConfig.tableSupportMessages)
          .select()
          .eq('ticket_id', id)
          .order('created_at', ascending: true);

      final msgList = (msgRes as List<dynamic>).map((m) {
        return SupportMessage(
          id: m['id'] as String,
          sender: m['sender_type'] as String? ?? 'customer',
          senderName: m['sender_name'] as String? ?? 'Sender',
          message: m['message'] as String? ?? '',
          timestamp: m['created_at']?.toString() ?? DateTime.now().toIso8601String(),
        );
      }).toList();

      return AdminSupportTicket(
        id: res['id'] as String,
        customerName: res['customer_name'] as String? ?? 'Customer',
        customerEmail: res['customer_email'] as String? ?? '',
        customerPhone: res['customer_phone'] as String? ?? '',
        subject: res['subject'] as String? ?? '',
        priority: res['priority'] as String? ?? 'medium',
        status: res['status'] as String? ?? 'open',
        bookingId: res['booking_id'] as String?,
        createdAt: res['created_at']?.toString() ?? DateTime.now().toIso8601String(),
        updatedAt: res['updated_at']?.toString() ?? DateTime.now().toIso8601String(),
        assignedAdmin: res['assigned_to'] as String? ?? 'Unassigned',
        messages: msgList,
      );
    } catch (e) {
      debugPrint('[SupabaseSupportRepository] getTicketById error: $e');
      return await _fallback.getTicketById(id);
    }
  }

  @override
  Future<void> updateTicketStatus(String id, String status) async {
    try {
      await client
          .from(SupabaseConfig.tableSupportTickets)
          .update({'status': status, 'updated_at': DateTime.now().toIso8601String()})
          .eq('id', id);
      await _fallback.updateTicketStatus(id, status);
    } catch (e) {
      debugPrint('[SupabaseSupportRepository] updateTicketStatus error: $e');
      await _fallback.updateTicketStatus(id, status);
    }
  }

  @override
  Future<void> assignAdmin(String id, String adminEmail) async {
    try {
      await client
          .from(SupabaseConfig.tableSupportTickets)
          .update({'assigned_to': adminEmail, 'updated_at': DateTime.now().toIso8601String()})
          .eq('id', id);
      await _fallback.assignAdmin(id, adminEmail);
    } catch (e) {
      debugPrint('[SupabaseSupportRepository] assignAdmin error: $e');
      await _fallback.assignAdmin(id, adminEmail);
    }
  }

  @override
  Future<void> addMessage(String ticketId, SupportMessage message) async {
    try {
      await client.from(SupabaseConfig.tableSupportMessages).insert({
        'ticket_id': ticketId,
        'sender_id': message.sender,
        'sender_name': message.senderName,
        'sender_type': message.sender,
        'message': message.message,
      });
      await _fallback.addMessage(ticketId, message);
    } catch (e) {
      debugPrint('[SupabaseSupportRepository] addMessage error: $e');
      await _fallback.addMessage(ticketId, message);
    }
  }

  @override
  Future<void> addInternalNote(String ticketId, String note) async {
    try {
      await client.from(SupabaseConfig.tableSupportMessages).insert({
        'ticket_id': ticketId,
        'sender_id': 'staff',
        'sender_name': 'Staff Internal Note',
        'sender_type': 'staff',
        'message': note,
        'is_internal_note': true,
      });
      await _fallback.addInternalNote(ticketId, note);
    } catch (e) {
      debugPrint('[SupabaseSupportRepository] addInternalNote error: $e');
      await _fallback.addInternalNote(ticketId, note);
    }
  }

  @override
  Future<void> saveTicket(AdminSupportTicket ticket) async {
    try {
      await client.from(SupabaseConfig.tableSupportTickets).upsert({
        'id': ticket.id,
        'ticket_code': ticket.id,
        'customer_name': ticket.customerName,
        'customer_email': ticket.customerEmail,
        'customer_phone': ticket.customerPhone,
        'subject': ticket.subject,
        'priority': ticket.priority,
        'status': ticket.status,
        'booking_id': ticket.bookingId,
        'assigned_to': ticket.assignedAdmin,
      });
      await _fallback.saveTicket(ticket);
    } catch (e) {
      debugPrint('[SupabaseSupportRepository] saveTicket error: $e');
      await _fallback.saveTicket(ticket);
    }
  }
}
