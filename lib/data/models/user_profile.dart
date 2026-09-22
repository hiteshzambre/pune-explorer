class UserProfile {
  final String id;
  final String email;
  final String name;
  final String phone;
  final String avatarUrl;
  final bool isGuest;
  final bool isAdmin;
  final bool isSuspended;
  final String role;

  const UserProfile({
    required this.id,
    required this.email,
    required this.name,
    this.phone = '',
    this.avatarUrl = '',
    this.isGuest = false,
    this.isAdmin = false,
    this.isSuspended = false,
    this.role = 'User',
  });

  UserProfile copyWith({
    String? id,
    String? email,
    String? name,
    String? phone,
    String? avatarUrl,
    bool? isGuest,
    bool? isAdmin,
    bool? isSuspended,
    String? role,
  }) {
    return UserProfile(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      isGuest: isGuest ?? this.isGuest,
      isAdmin: isAdmin ?? this.isAdmin,
      isSuspended: isSuspended ?? this.isSuspended,
      role: role ?? this.role,
    );
  }

  factory UserProfile.guest() => const UserProfile(
        id: 'guest_user',
        email: 'guest@puneexplorer.in',
        name: 'Puneri Explorer',
        isGuest: true,
        isAdmin: false,
        role: 'Guest',
      );

  factory UserProfile.admin() => const UserProfile(
        id: 'admin_user',
        email: 'admin@puneexplorer.in',
        name: 'PuneExplorer Admin',
        phone: '+91 98220 12345',
        isGuest: false,
        isAdmin: true,
        role: 'Super Admin',
      );

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
        id: json['id'] as String,
        email: json['email'] as String? ?? '',
        name: json['name'] as String? ?? 'Traveler',
        phone: json['phone'] as String? ?? '',
        avatarUrl: json['avatarUrl'] as String? ?? '',
        isGuest: json['isGuest'] as bool? ?? false,
        isAdmin: json['isAdmin'] as bool? ?? false,
        isSuspended: json['isSuspended'] as bool? ?? false,
        role: json['role'] as String? ?? (json['isAdmin'] == true ? 'Super Admin' : 'User'),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        'name': name,
        'phone': phone,
        'avatarUrl': avatarUrl,
        'isGuest': isGuest,
        'isAdmin': isAdmin,
        'isSuspended': isSuspended,
        'role': role,
      };
}
