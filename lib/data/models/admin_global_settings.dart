class AdminGlobalSettings {
  final String appName;
  final String tagline;
  final String helplineNumber;
  final String supportEmail;
  final String defaultTimezone;
  final bool maintenanceMode;
  final String logoUrl;
  final String faviconUrl;
  final int sameDayCutoffHours;
  final int cancellationGraceDays;
  final int maxTravelersPerBooking;
  final String merchantUpiId;
  final String merchantName;
  final String defaultCurrency;
  final int paymentTimeoutMinutes;
  final String defaultSeoTitle;
  final String defaultSeoDescription;
  final String defaultKeywords;
  final Map<String, bool> featureFlags;

  const AdminGlobalSettings({
    this.appName = 'PuneExplorer',
    this.tagline = 'Explore • Live • Belong',
    this.helplineNumber = '1363',
    this.supportEmail = 'support@puneexplorer.in',
    this.defaultTimezone = 'Asia/Kolkata',
    this.maintenanceMode = false,
    this.logoUrl = 'assets/icons/pune_flower.png',
    this.faviconUrl = 'favicon.png',
    this.sameDayCutoffHours = 2,
    this.cancellationGraceDays = 1,
    this.maxTravelersPerBooking = 10,
    this.merchantUpiId = 'pay.puneexplorer@upi',
    this.merchantName = 'PuneExplorer Official',
    this.defaultCurrency = 'INR',
    this.paymentTimeoutMinutes = 15,
    this.defaultSeoTitle = 'PuneExplorer | Official Travel & Heritage Guide',
    this.defaultSeoDescription = 'Discover Pune forts, Sahyadri treks, street foods, and daily guided Pune Darshan AC bus tours.',
    this.defaultKeywords = 'pune tourism, shaniwar wada, sinhagad fort, pune darshan, maharashtra travel',
    this.featureFlags = const {
      'punekar_bot': true,
      'user_reviews': true,
      'weather_widget': true,
      'budget_calculator': true,
      'heritage_walk_passes': true,
      'offline_pass_download': true,
      'allow_guest_bookings': true,
      'enable_dark_mode_web': true,
    },
  });

  String get supportPhone => helplineNumber;
  int get bookingCutoffHours => sameDayCutoffHours;
  int get cancellationWindowHours => cancellationGraceDays * 24;
  double get defaultCancellationFeePercent => 15.0;
  bool get isMaintenanceMode => maintenanceMode;
  bool get allowGuestBookings => featureFlags['allow_guest_bookings'] ?? true;
  bool get enableDarkModeWeb => featureFlags['enable_dark_mode_web'] ?? true;

  AdminGlobalSettings copyWith({
    String? appName,
    String? tagline,
    String? helplineNumber,
    String? supportPhone,
    String? supportEmail,
    String? defaultTimezone,
    bool? maintenanceMode,
    bool? isMaintenanceMode,
    String? logoUrl,
    String? faviconUrl,
    int? sameDayCutoffHours,
    int? bookingCutoffHours,
    int? cancellationGraceDays,
    int? cancellationWindowHours,
    double? defaultCancellationFeePercent,
    int? maxTravelersPerBooking,
    String? merchantUpiId,
    String? merchantName,
    String? defaultCurrency,
    int? paymentTimeoutMinutes,
    String? defaultSeoTitle,
    String? defaultSeoDescription,
    String? defaultKeywords,
    Map<String, bool>? featureFlags,
    bool? allowGuestBookings,
    bool? enableDarkModeWeb,
  }) {
    final flags = Map<String, bool>.from(featureFlags ?? this.featureFlags);
    if (allowGuestBookings != null) flags['allow_guest_bookings'] = allowGuestBookings;
    if (enableDarkModeWeb != null) flags['enable_dark_mode_web'] = enableDarkModeWeb;

    return AdminGlobalSettings(
      appName: appName ?? this.appName,
      tagline: tagline ?? this.tagline,
      helplineNumber: supportPhone ?? helplineNumber ?? this.helplineNumber,
      supportEmail: supportEmail ?? this.supportEmail,
      defaultTimezone: defaultTimezone ?? this.defaultTimezone,
      maintenanceMode: isMaintenanceMode ?? maintenanceMode ?? this.maintenanceMode,
      logoUrl: logoUrl ?? this.logoUrl,
      faviconUrl: faviconUrl ?? this.faviconUrl,
      sameDayCutoffHours: bookingCutoffHours ?? sameDayCutoffHours ?? this.sameDayCutoffHours,
      cancellationGraceDays: cancellationWindowHours != null
          ? (cancellationWindowHours / 24).ceil()
          : (cancellationGraceDays ?? this.cancellationGraceDays),
      maxTravelersPerBooking: maxTravelersPerBooking ?? this.maxTravelersPerBooking,
      merchantUpiId: merchantUpiId ?? this.merchantUpiId,
      merchantName: merchantName ?? this.merchantName,
      defaultCurrency: defaultCurrency ?? this.defaultCurrency,
      paymentTimeoutMinutes: paymentTimeoutMinutes ?? this.paymentTimeoutMinutes,
      defaultSeoTitle: defaultSeoTitle ?? this.defaultSeoTitle,
      defaultSeoDescription: defaultSeoDescription ?? this.defaultSeoDescription,
      defaultKeywords: defaultKeywords ?? this.defaultKeywords,
      featureFlags: flags,
    );
  }

  Map<String, dynamic> toJson() => {
        'appName': appName,
        'tagline': tagline,
        'helplineNumber': helplineNumber,
        'supportEmail': supportEmail,
        'defaultTimezone': defaultTimezone,
        'maintenanceMode': maintenanceMode,
        'logoUrl': logoUrl,
        'faviconUrl': faviconUrl,
        'sameDayCutoffHours': sameDayCutoffHours,
        'cancellationGraceDays': cancellationGraceDays,
        'maxTravelersPerBooking': maxTravelersPerBooking,
        'merchantUpiId': merchantUpiId,
        'merchantName': merchantName,
        'defaultCurrency': defaultCurrency,
        'paymentTimeoutMinutes': paymentTimeoutMinutes,
        'defaultSeoTitle': defaultSeoTitle,
        'defaultSeoDescription': defaultSeoDescription,
        'defaultKeywords': defaultKeywords,
        'featureFlags': featureFlags,
      };

  factory AdminGlobalSettings.fromJson(Map<String, dynamic> json) => AdminGlobalSettings(
        appName: json['appName'] as String? ?? 'PuneExplorer',
        tagline: json['tagline'] as String? ?? 'Explore • Live • Belong',
        helplineNumber: json['helplineNumber'] as String? ?? '1363',
        supportEmail: json['supportEmail'] as String? ?? 'support@puneexplorer.in',
        defaultTimezone: json['defaultTimezone'] as String? ?? 'Asia/Kolkata',
        maintenanceMode: json['maintenanceMode'] as bool? ?? false,
        logoUrl: json['logoUrl'] as String? ?? 'assets/icons/pune_flower.png',
        faviconUrl: json['faviconUrl'] as String? ?? 'favicon.png',
        sameDayCutoffHours: (json['sameDayCutoffHours'] as num?)?.toInt() ?? 2,
        cancellationGraceDays: (json['cancellationGraceDays'] as num?)?.toInt() ?? 1,
        maxTravelersPerBooking: (json['maxTravelersPerBooking'] as num?)?.toInt() ?? 10,
        merchantUpiId: json['merchantUpiId'] as String? ?? 'pay.puneexplorer@upi',
        merchantName: json['merchantName'] as String? ?? 'PuneExplorer Official',
        defaultCurrency: json['defaultCurrency'] as String? ?? 'INR',
        paymentTimeoutMinutes: (json['paymentTimeoutMinutes'] as num?)?.toInt() ?? 15,
        defaultSeoTitle: json['defaultSeoTitle'] as String? ?? 'PuneExplorer | Official Travel & Heritage Guide',
        defaultSeoDescription: json['defaultSeoDescription'] as String? ??
            'Discover Pune forts, Sahyadri treks, street foods, and daily guided Pune Darshan AC bus tours.',
        defaultKeywords: json['defaultKeywords'] as String? ?? '',
        featureFlags: (json['featureFlags'] as Map<String, dynamic>?)?.map(
              (k, v) => MapEntry(k, v as bool),
            ) ??
            const {
              'punekar_bot': true,
              'user_reviews': true,
              'weather_widget': true,
              'budget_calculator': true,
              'heritage_walk_passes': true,
              'offline_pass_download': true,
              'allow_guest_bookings': true,
              'enable_dark_mode_web': true,
            },
      );
}
