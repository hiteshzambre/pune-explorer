/// Role-Based Access Control (RBAC) Permissions & Role Definitions
/// for the PuneExplorer Admin Portal & CMS.
library;

enum AdminRole {
  superAdmin('Super Admin', 'Full system control, administrative users, settings, and audit logs'),
  contentAdmin('Content Admin', 'Destinations, tours, heritage walks, media library, and homepage CMS'),
  bookingAdmin('Booking Admin', 'Bookings operations, payment verification, and tour capacities'),
  supportAdmin('Support Admin', 'User accounts, customer feedback, review moderation, and notices'),
  analyticsViewer('Analytics / Viewer', 'Read-only access to operational metrics, charts, and reports');

  final String label;
  final String description;

  const AdminRole(this.label, this.description);

  static AdminRole fromString(String? role) {
    if (role == null) return AdminRole.superAdmin;
    final normalized = role.trim().toLowerCase();
    if (normalized.contains('content')) return AdminRole.contentAdmin;
    if (normalized.contains('booking') || normalized.contains('operation')) return AdminRole.bookingAdmin;
    if (normalized.contains('support')) return AdminRole.supportAdmin;
    if (normalized.contains('analytic') || normalized.contains('view')) return AdminRole.analyticsViewer;
    return AdminRole.superAdmin;
  }
}

class AdminPermissions {
  // Content Management
  static const String contentView = 'content.view';
  static const String contentCreate = 'content.create';
  static const String contentEdit = 'content.edit';
  static const String contentDelete = 'content.delete';
  static const String contentPublish = 'content.publish';

  // Tours & Pune Darshan
  static const String tourView = 'tour.view';
  static const String tourCreate = 'tour.create';
  static const String tourEdit = 'tour.edit';
  static const String tourDelete = 'tour.delete';

  // Bookings & Capacity
  static const String bookingView = 'booking.view';
  static const String bookingEdit = 'booking.edit';
  static const String bookingCancel = 'booking.cancel';

  // Payments & Verification
  static const String paymentView = 'payment.view';
  static const String paymentVerify = 'payment.verify';
  static const String paymentReject = 'payment.reject';

  // Media Library
  static const String mediaView = 'media.view';
  static const String mediaUpload = 'media.upload';
  static const String mediaDelete = 'media.delete';
  static const String mediaReplace = 'media.replace';

  // User Accounts
  static const String userView = 'user.view';
  static const String userEdit = 'user.edit';
  static const String userSuspend = 'user.suspend';

  // Reviews Moderation
  static const String reviewView = 'review.view';
  static const String reviewModerate = 'review.moderate';

  // Settings & System
  static const String settingsView = 'settings.view';
  static const String settingsEdit = 'settings.edit';
  static const String adminManage = 'admin.manage';
  static const String auditView = 'audit.view';

  static const Map<AdminRole, Set<String>> _rolePermissions = {
    AdminRole.superAdmin: {
      contentView, contentCreate, contentEdit, contentDelete, contentPublish,
      tourView, tourCreate, tourEdit, tourDelete,
      bookingView, bookingEdit, bookingCancel,
      paymentView, paymentVerify, paymentReject,
      mediaView, mediaUpload, mediaDelete, mediaReplace,
      userView, userEdit, userSuspend,
      reviewView, reviewModerate,
      settingsView, settingsEdit, adminManage, auditView,
    },
    AdminRole.contentAdmin: {
      contentView, contentCreate, contentEdit, contentDelete, contentPublish,
      tourView, tourCreate, tourEdit, tourDelete,
      mediaView, mediaUpload, mediaDelete, mediaReplace,
      reviewView,
      settingsView,
    },
    AdminRole.bookingAdmin: {
      bookingView, bookingEdit, bookingCancel,
      paymentView, paymentVerify, paymentReject,
      tourView,
      userView,
    },
    AdminRole.supportAdmin: {
      userView, userEdit, userSuspend,
      reviewView, reviewModerate,
      bookingView,
      contentView,
    },
    AdminRole.analyticsViewer: {
      contentView,
      tourView,
      bookingView,
      paymentView,
      userView,
      reviewView,
      settingsView,
      auditView,
    },
  };

  static bool hasPermission(AdminRole role, String permission) {
    final permissions = _rolePermissions[role];
    return permissions?.contains(permission) ?? false;
  }
}

/// Thrown at repository or service level when an administrative action
/// violates the active administrator's RBAC role permissions.
class AdminPermissionDeniedException implements Exception {
  final String requiredPermission;
  final AdminRole currentRole;
  final String action;

  const AdminPermissionDeniedException({
    required this.requiredPermission,
    required this.currentRole,
    required this.action,
  });

  @override
  String toString() =>
      'AdminPermissionDeniedException: Role "${currentRole.label}" lacks permission "$requiredPermission" to perform "$action".';
}
