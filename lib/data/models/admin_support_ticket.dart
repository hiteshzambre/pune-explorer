class SupportMessage {
  final String id;
  final String sender; // 'customer' or 'agent'
  final String senderName;
  final String message;
  final String timestamp;

  const SupportMessage({
    required this.id,
    required this.sender,
    required this.senderName,
    required this.message,
    required this.timestamp,
  });

  bool get isAgent => sender == 'agent';
  String get content => message;

  Map<String, dynamic> toJson() => {
        'id': id,
        'sender': sender,
        'senderName': senderName,
        'message': message,
        'timestamp': timestamp,
      };

  factory SupportMessage.fromJson(Map<String, dynamic> json) => SupportMessage(
        id: json['id'] as String? ?? 'msg_1',
        sender: json['sender'] as String? ?? 'customer',
        senderName: json['senderName'] as String? ?? 'Customer',
        message: json['message'] as String? ?? '',
        timestamp: json['timestamp'] as String? ?? DateTime.now().toIso8601String(),
      );
}

class AdminSupportTicket {
  final String id;
  final String customerName;
  final String customerEmail;
  final String customerPhone;
  final String subject;
  final String priority; // 'low', 'medium', 'high', 'urgent'
  final String status; // 'open', 'in_progress', 'resolved', 'closed'
  final String? bookingId;
  final String? orderId;
  final String createdAt;
  final String updatedAt;
  final String assignedAdmin;
  final List<SupportMessage> messages;
  final List<String> internalNotes;

  const AdminSupportTicket({
    required this.id,
    required this.customerName,
    required this.customerEmail,
    this.customerPhone = '',
    required this.subject,
    this.priority = 'medium',
    this.status = 'open',
    this.bookingId,
    this.orderId,
    required this.createdAt,
    required this.updatedAt,
    this.assignedAdmin = 'Unassigned',
    this.messages = const [],
    this.internalNotes = const [],
  });

  String get userEmail => customerEmail;
  String get userName => customerName;
  String get category => 'Traveler Support';

  AdminSupportTicket copyWith({
    String? id,
    String? customerName,
    String? customerEmail,
    String? customerPhone,
    String? subject,
    String? priority,
    String? status,
    String? bookingId,
    String? orderId,
    String? createdAt,
    String? updatedAt,
    String? assignedAdmin,
    List<SupportMessage>? messages,
    List<String>? internalNotes,
  }) {
    return AdminSupportTicket(
      id: id ?? this.id,
      customerName: customerName ?? this.customerName,
      customerEmail: customerEmail ?? this.customerEmail,
      customerPhone: customerPhone ?? this.customerPhone,
      subject: subject ?? this.subject,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      bookingId: bookingId ?? this.bookingId,
      orderId: orderId ?? this.orderId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      assignedAdmin: assignedAdmin ?? this.assignedAdmin,
      messages: messages ?? this.messages,
      internalNotes: internalNotes ?? this.internalNotes,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'customerName': customerName,
        'customerEmail': customerEmail,
        'customerPhone': customerPhone,
        'subject': subject,
        'priority': priority,
        'status': status,
        'bookingId': bookingId,
        'orderId': orderId,
        'createdAt': createdAt,
        'updatedAt': updatedAt,
        'assignedAdmin': assignedAdmin,
        'messages': messages.map((m) => m.toJson()).toList(),
        'internalNotes': internalNotes,
      };

  factory AdminSupportTicket.fromJson(Map<String, dynamic> json) => AdminSupportTicket(
        id: json['id'] as String? ?? 'TICK-1001',
        customerName: json['customerName'] as String? ?? 'Traveler',
        customerEmail: json['customerEmail'] as String? ?? '',
        customerPhone: json['customerPhone'] as String? ?? '',
        subject: json['subject'] as String? ?? 'General Inquiry',
        priority: json['priority'] as String? ?? 'medium',
        status: json['status'] as String? ?? 'open',
        bookingId: json['bookingId'] as String?,
        orderId: json['orderId'] as String?,
        createdAt: json['createdAt'] as String? ?? DateTime.now().toIso8601String(),
        updatedAt: json['updatedAt'] as String? ?? DateTime.now().toIso8601String(),
        assignedAdmin: json['assignedAdmin'] as String? ?? 'Unassigned',
        messages: (json['messages'] as List<dynamic>?)
                ?.map((m) => SupportMessage.fromJson(m as Map<String, dynamic>))
                .toList() ??
            const [],
        internalNotes: (json['internalNotes'] as List<dynamic>?)?.map((n) => n.toString()).toList() ?? const [],
      );
}
