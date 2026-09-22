class AdminPersonalization {
  final String themeMode; // 'dark', 'light', 'system'
  final bool sidebarExpanded;
  final String density; // 'comfortable', 'standard', 'compact'
  final String defaultLandingPage; // '/admin/dashboard', '/admin/bookings', etc.
  final String timezone;
  final String dateFormat;
  final Map<String, bool> visibleDashboardWidgets;

  const AdminPersonalization({
    this.themeMode = 'light',
    this.sidebarExpanded = true,
    this.density = 'comfortable',
    this.defaultLandingPage = '/admin/dashboard',
    this.timezone = 'Asia/Kolkata',
    this.dateFormat = 'DD MMM YYYY',
    this.visibleDashboardWidgets = const {
      'kpi_metrics': true,
      'trend_chart': true,
      'status_donut': true,
      'quick_actions': true,
      'recent_activity': true,
      'pending_actions': true,
    },
  });

  bool get sidebarCollapsedDefault => !sidebarExpanded;
  String get tableDensity => density;
  bool get showRevenueChart => visibleDashboardWidgets['trend_chart'] ?? true;
  bool get showBookingDonut => visibleDashboardWidgets['status_donut'] ?? true;
  bool get showActionQueue => visibleDashboardWidgets['pending_actions'] ?? true;
  bool get showAuditStream => visibleDashboardWidgets['recent_activity'] ?? true;

  AdminPersonalization copyWith({
    String? themeMode,
    bool? sidebarExpanded,
    bool? sidebarCollapsedDefault,
    String? density,
    String? tableDensity,
    String? defaultLandingPage,
    String? timezone,
    String? dateFormat,
    Map<String, bool>? visibleDashboardWidgets,
    bool? showRevenueChart,
    bool? showBookingDonut,
    bool? showActionQueue,
    bool? showAuditStream,
  }) {
    final widgets = Map<String, bool>.from(visibleDashboardWidgets ?? this.visibleDashboardWidgets);
    if (showRevenueChart != null) widgets['trend_chart'] = showRevenueChart;
    if (showBookingDonut != null) widgets['status_donut'] = showBookingDonut;
    if (showActionQueue != null) widgets['pending_actions'] = showActionQueue;
    if (showAuditStream != null) widgets['recent_activity'] = showAuditStream;

    return AdminPersonalization(
      themeMode: themeMode ?? this.themeMode,
      sidebarExpanded: sidebarCollapsedDefault != null ? !sidebarCollapsedDefault : (sidebarExpanded ?? this.sidebarExpanded),
      density: tableDensity ?? density ?? this.density,
      defaultLandingPage: defaultLandingPage ?? this.defaultLandingPage,
      timezone: timezone ?? this.timezone,
      dateFormat: dateFormat ?? this.dateFormat,
      visibleDashboardWidgets: widgets,
    );
  }

  Map<String, dynamic> toJson() => {
        'themeMode': themeMode,
        'sidebarExpanded': sidebarExpanded,
        'density': density,
        'defaultLandingPage': defaultLandingPage,
        'timezone': timezone,
        'dateFormat': dateFormat,
        'visibleDashboardWidgets': visibleDashboardWidgets,
      };

  factory AdminPersonalization.fromJson(Map<String, dynamic> json) => AdminPersonalization(
        themeMode: json['themeMode'] as String? ?? 'light',
        sidebarExpanded: json['sidebarExpanded'] as bool? ?? true,
        density: json['density'] as String? ?? 'comfortable',
        defaultLandingPage: json['defaultLandingPage'] as String? ?? '/admin/dashboard',
        timezone: json['timezone'] as String? ?? 'Asia/Kolkata',
        dateFormat: json['dateFormat'] as String? ?? 'DD MMM YYYY',
        visibleDashboardWidgets: json['visibleDashboardWidgets'] != null
            ? Map<String, bool>.from(json['visibleDashboardWidgets'] as Map)
            : const {
                'kpi_metrics': true,
                'trend_chart': true,
                'status_donut': true,
                'quick_actions': true,
                'recent_activity': true,
                'pending_actions': true,
              },
      );
}
