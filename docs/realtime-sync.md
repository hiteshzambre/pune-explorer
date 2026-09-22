# PuneExplorer — Realtime Synchronization Architecture & Streaming Guide

## 1. Overview

PuneExplorer utilizes **Supabase Realtime** (powered by Elixir Phoenix Channels and PostgreSQL Logical Replication WAL) to push instantaneous updates to connected web clients without polling.

`
┌─────────────────────────────────────────────────────────────┐
│                    PostgreSQL Engine (WAL)                  │
│       INSERT / UPDATE / DELETE on published tables          │
└──────────────────────────────┬──────────────────────────────┘
                               │ pg_notify / Replication Slot
                               ▼
┌─────────────────────────────────────────────────────────────┐
│                 Supabase Realtime Server                    │
│            (Phoenix WebSockets Broadcast Layer)             │
└──────────────────────────────┬──────────────────────────────┘
                               │ Secure WSS Connection
                               ▼
┌─────────────────────────────────────────────────────────────┐
│               Flutter Web Client (supabase_flutter)         │
│   • Bookings Stream        • Payment Status Updates         │
│   • Live Support Chat      • Roster Seat Availability       │
└─────────────────────────────────────────────────────────────┘
`

---

## 2. Realtime Publications Configuration

In PostgreSQL, selected high-velocity operational tables are enrolled in the supabase_realtime publication:

`sql
-- Add operational tables to the Realtime publication
ALTER PUBLICATION supabase_realtime ADD TABLE public.bookings;
ALTER PUBLICATION supabase_realtime ADD TABLE public.payments;
ALTER PUBLICATION supabase_realtime ADD TABLE public.support_messages;
ALTER PUBLICATION supabase_realtime ADD TABLE public.notifications;
ALTER PUBLICATION supabase_realtime ADD TABLE public.tours;
`

---

## 3. Realtime Features & Use Cases

### 3.1 Live Booking & Payment Status Updates
When a traveler submits a UPI UTR reference, their payment status switches to claimed. As soon as an admin verifies the payment in the Admin Portal, the status switches to erified. The traveler's checkout screen automatically transitions from Pending Verification to Booking Confirmed & QR Ticket Ready within 250 milliseconds.

`dart
// Stream payment updates for an active booking
Stream<Payment?> watchBookingPayment(String bookingId) {
  return client
      .from(SupabaseConfig.tablePayments)
      .stream(primaryKey: ['id'])
      .eq('booking_id', bookingId)
      .map((records) {
        if (records.isEmpty) return null;
        return _mapToPayment(records.first);
      });
}
`

### 3.2 Live Customer Support Chat
Support tickets feature bidirectional live messaging between the traveler and support agents without page refresh:

`dart
// Subscribe to messages on an open support ticket
RealtimeChannel subscribeToTicketMessages({
  required String ticketId,
  required void Function(Map<String, dynamic> message) onNewMessage,
}) {
  final channel = client.channel('ticket:');

  channel.onPostgresChanges(
    event: PostgresChangeEvent.insert,
    schema: 'public',
    table: 'support_messages',
    filter: PostgresChangeFilter(
      type: PostgresChangeFilterType.eq,
      column: 'ticket_id',
      value: ticketId,
    ),
    callback: (payload) {
      onNewMessage(payload.newRecord);
    },
  ).subscribe();

  return channel;
}
`

### 3.3 Tour Seat Availability Sync
When multiple travelers book seats on the same Pune Darshan morning departure, remaining seat counts update synchronously, preventing double-booking race conditions.

---

## 4. Connection Lifecycle & Memory Management

1. **Auto-Reconnection**: The Flutter client automatically manages WebSocket reconnections with exponential backoff if the user experiences network drops.
2. **Channel Disposal**: Stream subscriptions and Realtime channels must always be cleaned up in the widget's dispose() or Riverpod's ef.onDispose() to prevent memory leaks and unnecessary server sockets:

`dart
ref.onDispose(() {
  client.removeChannel(channel);
});
`

---

## 5. Security & Row Level Security in Realtime

Supabase Realtime respects PostgreSQL Row Level Security (RLS) policies.
- Travelers **only receive events** for rows where their user ID matches the row's user_id.
- Staff members receive broadcast events for all rows according to their role permissions.
