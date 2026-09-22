class BrandingConfig {
  final String siteName;
  final String heroHeadline;
  final String heroSubtitle;
  final String noticeBanner;
  final bool showNoticeBanner;
  final String logoText;
  final String contactEmail;
  final String contactPhone;
  final String touristHelpline;

  const BrandingConfig({
    this.siteName = 'PuneExplorer',
    this.heroHeadline = 'Explore Pune & Sahyadri Heritage',
    this.heroSubtitle = 'Discover historic forts, scenic ghats, authentic Maharashtrian cuisine, and daily guided Pune Darshan tours.',
    this.noticeBanner = '🚩 Monsoon Trekking Alert: Carry rain gear and follow designated fort safety trails.',
    this.showNoticeBanner = true,
    this.logoText = 'PUNE EXPLORER',
    this.contactEmail = 'contact@puneexplorer.in',
    this.contactPhone = '+91 20 2612 0000',
    this.touristHelpline = '1363',
  });

  BrandingConfig copyWith({
    String? siteName,
    String? heroHeadline,
    String? heroSubtitle,
    String? noticeBanner,
    bool? showNoticeBanner,
    String? logoText,
    String? contactEmail,
    String? contactPhone,
    String? touristHelpline,
  }) {
    return BrandingConfig(
      siteName: siteName ?? this.siteName,
      heroHeadline: heroHeadline ?? this.heroHeadline,
      heroSubtitle: heroSubtitle ?? this.heroSubtitle,
      noticeBanner: noticeBanner ?? this.noticeBanner,
      showNoticeBanner: showNoticeBanner ?? this.showNoticeBanner,
      logoText: logoText ?? this.logoText,
      contactEmail: contactEmail ?? this.contactEmail,
      contactPhone: contactPhone ?? this.contactPhone,
      touristHelpline: touristHelpline ?? this.touristHelpline,
    );
  }

  Map<String, dynamic> toJson() => {
        'siteName': siteName,
        'heroHeadline': heroHeadline,
        'heroSubtitle': heroSubtitle,
        'noticeBanner': noticeBanner,
        'showNoticeBanner': showNoticeBanner,
        'logoText': logoText,
        'contactEmail': contactEmail,
        'contactPhone': contactPhone,
        'touristHelpline': touristHelpline,
      };

  factory BrandingConfig.fromJson(Map<String, dynamic> json) => BrandingConfig(
        siteName: json['siteName'] as String? ?? 'PuneExplorer',
        heroHeadline: json['heroHeadline'] as String? ?? 'Explore Pune & Sahyadri Heritage',
        heroSubtitle: json['heroSubtitle'] as String? ??
            'Discover historic forts, scenic ghats, authentic Maharashtrian cuisine, and daily guided Pune Darshan tours.',
        noticeBanner: json['noticeBanner'] as String? ??
            '🚩 Monsoon Trekking Alert: Carry rain gear and follow designated fort safety trails.',
        showNoticeBanner: json['showNoticeBanner'] as bool? ?? true,
        logoText: json['logoText'] as String? ?? 'PUNE EXPLORER',
        contactEmail: json['contactEmail'] as String? ?? 'contact@puneexplorer.in',
        contactPhone: json['contactPhone'] as String? ?? '+91 20 2612 0000',
        touristHelpline: json['touristHelpline'] as String? ?? '1363',
      );
}
