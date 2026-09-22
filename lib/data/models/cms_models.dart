import '../../core/constants/admin_permissions.dart';

/// Single dynamic Hero slide item managed via Homepage CMS.
class HeroSlideItem {
  final String id;
  final String imageUrl;
  final String title;
  final String subtitle;
  final String ctaLabel;
  final String ctaRoute;
  final int sortOrder;
  final bool isActive;

  const HeroSlideItem({
    required this.id,
    required this.imageUrl,
    required this.title,
    required this.subtitle,
    this.ctaLabel = 'Explore Now',
    this.ctaRoute = '/explore',
    this.sortOrder = 0,
    this.isActive = true,
  });

  HeroSlideItem copyWith({
    String? id,
    String? imageUrl,
    String? title,
    String? subtitle,
    String? ctaLabel,
    String? ctaRoute,
    int? sortOrder,
    bool? isActive,
  }) {
    return HeroSlideItem(
      id: id ?? this.id,
      imageUrl: imageUrl ?? this.imageUrl,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      ctaLabel: ctaLabel ?? this.ctaLabel,
      ctaRoute: ctaRoute ?? this.ctaRoute,
      sortOrder: sortOrder ?? this.sortOrder,
      isActive: isActive ?? this.isActive,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'imageUrl': imageUrl,
        'title': title,
        'subtitle': subtitle,
        'ctaLabel': ctaLabel,
        'ctaRoute': ctaRoute,
        'sortOrder': sortOrder,
        'isActive': isActive,
      };

  factory HeroSlideItem.fromJson(Map<String, dynamic> json) => HeroSlideItem(
        id: json['id'] as String? ?? 'slide_${DateTime.now().millisecondsSinceEpoch}',
        imageUrl: json['imageUrl'] as String? ?? '',
        title: json['title'] as String? ?? '',
        subtitle: json['subtitle'] as String? ?? '',
        ctaLabel: json['ctaLabel'] as String? ?? 'Explore Now',
        ctaRoute: json['ctaRoute'] as String? ?? '/explore',
        sortOrder: (json['sortOrder'] as num?)?.toInt() ?? 0,
        isActive: json['isActive'] as bool? ?? true,
      );
}

/// Controls section visibility and rendering order for the Home screen.
class SectionVisibilityConfig {
  final bool showHero;
  final bool showSearch;
  final bool showCategories;
  final bool showDarshanSpotlight;
  final bool showTrendingDestinations;
  final bool showHistoryTimeline;
  final bool showTestimonialsFaq;
  final bool showFooter;
  final List<String> sectionOrder;

  const SectionVisibilityConfig({
    this.showHero = true,
    this.showSearch = true,
    this.showCategories = true,
    this.showDarshanSpotlight = true,
    this.showTrendingDestinations = true,
    this.showHistoryTimeline = true,
    this.showTestimonialsFaq = true,
    this.showFooter = true,
    this.sectionOrder = const [
      'hero',
      'search',
      'categories',
      'darshan',
      'trending',
      'timeline',
      'faq',
      'footer',
    ],
  });

  SectionVisibilityConfig copyWith({
    bool? showHero,
    bool? showSearch,
    bool? showCategories,
    bool? showDarshanSpotlight,
    bool? showTrendingDestinations,
    bool? showHistoryTimeline,
    bool? showTestimonialsFaq,
    bool? showFooter,
    List<String>? sectionOrder,
  }) {
    return SectionVisibilityConfig(
      showHero: showHero ?? this.showHero,
      showSearch: showSearch ?? this.showSearch,
      showCategories: showCategories ?? this.showCategories,
      showDarshanSpotlight: showDarshanSpotlight ?? this.showDarshanSpotlight,
      showTrendingDestinations: showTrendingDestinations ?? this.showTrendingDestinations,
      showHistoryTimeline: showHistoryTimeline ?? this.showHistoryTimeline,
      showTestimonialsFaq: showTestimonialsFaq ?? this.showTestimonialsFaq,
      showFooter: showFooter ?? this.showFooter,
      sectionOrder: sectionOrder ?? this.sectionOrder,
    );
  }

  Map<String, dynamic> toJson() => {
        'showHero': showHero,
        'showSearch': showSearch,
        'showCategories': showCategories,
        'showDarshanSpotlight': showDarshanSpotlight,
        'showTrendingDestinations': showTrendingDestinations,
        'showHistoryTimeline': showHistoryTimeline,
        'showTestimonialsFaq': showTestimonialsFaq,
        'showFooter': showFooter,
        'sectionOrder': sectionOrder,
      };

  factory SectionVisibilityConfig.fromJson(Map<String, dynamic> json) => SectionVisibilityConfig(
        showHero: json['showHero'] as bool? ?? true,
        showSearch: json['showSearch'] as bool? ?? true,
        showCategories: json['showCategories'] as bool? ?? true,
        showDarshanSpotlight: json['showDarshanSpotlight'] as bool? ?? true,
        showTrendingDestinations: json['showTrendingDestinations'] as bool? ?? true,
        showHistoryTimeline: json['showHistoryTimeline'] as bool? ?? true,
        showTestimonialsFaq: json['showTestimonialsFaq'] as bool? ?? true,
        showFooter: json['showFooter'] as bool? ?? true,
        sectionOrder: (json['sectionOrder'] as List<dynamic>?)?.map((e) => e.toString()).toList() ??
            const [
              'hero',
              'search',
              'categories',
              'darshan',
              'trending',
              'timeline',
              'faq',
              'footer',
            ],
      );
}

/// Central configuration for Homepage CMS.
class HomepageCmsConfig {
  final String heroHeadline;
  final String heroSubtitle;
  final String noticeBanner;
  final bool showNoticeBanner;
  final List<HeroSlideItem> slides;
  final SectionVisibilityConfig sectionConfig;
  final List<String> featuredDestinationIds;
  final List<String> featuredTourIds;
  final String lastUpdated;

  const HomepageCmsConfig({
    this.heroHeadline = 'Explore Pune & Sahyadri Heritage',
    this.heroSubtitle = 'Discover historic forts, scenic ghats, authentic Maharashtrian cuisine, and daily guided Pune Darshan tours.',
    this.noticeBanner = '🚩 Monsoon Trekking Alert: Carry rain gear and follow designated fort safety trails.',
    this.showNoticeBanner = true,
    this.slides = const [],
    this.sectionConfig = const SectionVisibilityConfig(),
    this.featuredDestinationIds = const ['dest_1', 'dest_2', 'dest_3', 'dest_4'],
    this.featuredTourIds = const ['PNE-DAR-01', 'PNE-WAL-01'],
    this.lastUpdated = '',
  });

  HomepageCmsConfig copyWith({
    String? heroHeadline,
    String? heroSubtitle,
    String? noticeBanner,
    bool? showNoticeBanner,
    List<HeroSlideItem>? slides,
    SectionVisibilityConfig? sectionConfig,
    List<String>? featuredDestinationIds,
    List<String>? featuredTourIds,
    String? lastUpdated,
  }) {
    return HomepageCmsConfig(
      heroHeadline: heroHeadline ?? this.heroHeadline,
      heroSubtitle: heroSubtitle ?? this.heroSubtitle,
      noticeBanner: noticeBanner ?? this.noticeBanner,
      showNoticeBanner: showNoticeBanner ?? this.showNoticeBanner,
      slides: slides ?? this.slides,
      sectionConfig: sectionConfig ?? this.sectionConfig,
      featuredDestinationIds: featuredDestinationIds ?? this.featuredDestinationIds,
      featuredTourIds: featuredTourIds ?? this.featuredTourIds,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  Map<String, dynamic> toJson() => {
        'heroHeadline': heroHeadline,
        'heroSubtitle': heroSubtitle,
        'noticeBanner': noticeBanner,
        'showNoticeBanner': showNoticeBanner,
        'slides': slides.map((s) => s.toJson()).toList(),
        'sectionConfig': sectionConfig.toJson(),
        'featuredDestinationIds': featuredDestinationIds,
        'featuredTourIds': featuredTourIds,
        'lastUpdated': lastUpdated,
      };

  factory HomepageCmsConfig.fromJson(Map<String, dynamic> json) => HomepageCmsConfig(
        heroHeadline: json['heroHeadline'] as String? ?? 'Explore Pune & Sahyadri Heritage',
        heroSubtitle: json['heroSubtitle'] as String? ??
            'Discover historic forts, scenic ghats, authentic Maharashtrian cuisine, and daily guided Pune Darshan tours.',
        noticeBanner: json['noticeBanner'] as String? ??
            '🚩 Monsoon Trekking Alert: Carry rain gear and follow designated fort safety trails.',
        showNoticeBanner: json['showNoticeBanner'] as bool? ?? true,
        slides: (json['slides'] as List<dynamic>?)
                ?.map((e) => HeroSlideItem.fromJson(e as Map<String, dynamic>))
                .toList() ??
            const [],
        sectionConfig: json['sectionConfig'] != null
            ? SectionVisibilityConfig.fromJson(json['sectionConfig'] as Map<String, dynamic>)
            : const SectionVisibilityConfig(),
        featuredDestinationIds:
            (json['featuredDestinationIds'] as List<dynamic>?)?.map((e) => e.toString()).toList() ??
                const ['dest_1', 'dest_2', 'dest_3', 'dest_4'],
        featuredTourIds:
            (json['featuredTourIds'] as List<dynamic>?)?.map((e) => e.toString()).toList() ??
                const ['PNE-DAR-01', 'PNE-WAL-01'],
        lastUpdated: json['lastUpdated'] as String? ?? '',
      );

  factory HomepageCmsConfig.defaultSeed() {
    return HomepageCmsConfig(
      lastUpdated: DateTime.now().toIso8601String(),
      slides: const [
        HeroSlideItem(
          id: 'slide_1',
          imageUrl: 'https://images.unsplash.com/photo-1599661046289-e31897846e41?q=80&w=1200&auto=format&fit=crop',
          title: 'Relive Peshwa Glory at Shaniwar Wada',
          subtitle: 'Step through the monumental Dilli Darwaza and experience light & sound heritage.',
          ctaLabel: 'Book Entry Pass',
          ctaRoute: '/destination/dest_1',
          sortOrder: 1,
          isActive: true,
        ),
        HeroSlideItem(
          id: 'slide_2',
          imageUrl: 'https://images.unsplash.com/photo-1588668214407-6ea9a6d8c272?q=80&w=1200&auto=format&fit=crop',
          title: 'Sinhagad Fort: The Lion Citadel',
          subtitle: 'Trek the legendary Sahyadri ridge and enjoy authentic pithla bhakri.',
          ctaLabel: 'View Fort Guide',
          ctaRoute: '/destination/dest_2',
          sortOrder: 2,
          isActive: true,
        ),
        HeroSlideItem(
          id: 'slide_3',
          imageUrl: 'https://images.unsplash.com/photo-1544735716-392fe2489ffa?q=80&w=1200&auto=format&fit=crop',
          title: 'Official Daily Pune Darshan AC Bus',
          subtitle: '10 major heritage landmarks covered in a single guided day circuit.',
          ctaLabel: 'Reserve Bus Seat',
          ctaRoute: '/darshan',
          sortOrder: 3,
          isActive: true,
        ),
      ],
    );
  }
}

/// Managed media asset in the Media Library.
class MediaAsset {
  final String id;
  final String url;
  final String title;
  final String altText;
  final String category;
  final int fileSizeKb;
  final String dimensions;
  final String uploadedBy;
  final String uploadedAt;
  final int usageCount;
  final List<String> usageReferences;

  const MediaAsset({
    required this.id,
    required this.url,
    required this.title,
    this.altText = '',
    this.category = 'destinations',
    this.fileSizeKb = 250,
    this.dimensions = '1200x800',
    this.uploadedBy = 'admin@puneexplorer.in',
    required this.uploadedAt,
    this.usageCount = 1,
    this.usageReferences = const [],
  });

  MediaAsset copyWith({
    String? id,
    String? url,
    String? title,
    String? altText,
    String? category,
    int? fileSizeKb,
    String? dimensions,
    String? uploadedBy,
    String? uploadedAt,
    int? usageCount,
    List<String>? usageReferences,
  }) {
    return MediaAsset(
      id: id ?? this.id,
      url: url ?? this.url,
      title: title ?? this.title,
      altText: altText ?? this.altText,
      category: category ?? this.category,
      fileSizeKb: fileSizeKb ?? this.fileSizeKb,
      dimensions: dimensions ?? this.dimensions,
      uploadedBy: uploadedBy ?? this.uploadedBy,
      uploadedAt: uploadedAt ?? this.uploadedAt,
      usageCount: usageCount ?? this.usageCount,
      usageReferences: usageReferences ?? this.usageReferences,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'url': url,
        'title': title,
        'altText': altText,
        'category': category,
        'fileSizeKb': fileSizeKb,
        'dimensions': dimensions,
        'uploadedBy': uploadedBy,
        'uploadedAt': uploadedAt,
        'usageCount': usageCount,
        'usageReferences': usageReferences,
      };

  factory MediaAsset.fromJson(Map<String, dynamic> json) => MediaAsset(
        id: json['id'] as String? ?? 'med_${DateTime.now().millisecondsSinceEpoch}',
        url: json['url'] as String? ?? '',
        title: json['title'] as String? ?? 'Media Asset',
        altText: json['altText'] as String? ?? '',
        category: json['category'] as String? ?? 'destinations',
        fileSizeKb: (json['fileSizeKb'] as num?)?.toInt() ?? 250,
        dimensions: json['dimensions'] as String? ?? '1200x800',
        uploadedBy: json['uploadedBy'] as String? ?? 'admin@puneexplorer.in',
        uploadedAt: json['uploadedAt'] as String? ?? DateTime.now().toIso8601String(),
        usageCount: (json['usageCount'] as num?)?.toInt() ?? 0,
        usageReferences: (json['usageReferences'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? const [],
      );
}

/// Immutable audit trail event record.
class AuditLogEntry {
  final String id;
  final String actorEmail;
  final String actorRole;
  final String action;
  final String resourceType;
  final String resourceId;
  final String timestamp;
  final Map<String, dynamic> metadata;
  final String ipAddress;

  const AuditLogEntry({
    required this.id,
    required this.actorEmail,
    required this.actorRole,
    required this.action,
    required this.resourceType,
    required this.resourceId,
    required this.timestamp,
    this.metadata = const {},
    this.ipAddress = '127.0.0.1 (Local)',
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'actorEmail': actorEmail,
        'actorRole': actorRole,
        'action': action,
        'resourceType': resourceType,
        'resourceId': resourceId,
        'timestamp': timestamp,
        'metadata': metadata,
        'ipAddress': ipAddress,
      };

  factory AuditLogEntry.fromJson(Map<String, dynamic> json) => AuditLogEntry(
        id: json['id'] as String? ?? 'log_${DateTime.now().millisecondsSinceEpoch}',
        actorEmail: json['actorEmail'] as String? ?? 'admin@puneexplorer.in',
        actorRole: json['actorRole'] as String? ?? 'Super Admin',
        action: json['action'] as String? ?? 'MUTATION',
        resourceType: json['resourceType'] as String? ?? 'SYSTEM',
        resourceId: json['resourceId'] as String? ?? '-',
        timestamp: json['timestamp'] as String? ?? DateTime.now().toIso8601String(),
        metadata: (json['metadata'] as Map<String, dynamic>?) ?? const {},
        ipAddress: json['ipAddress'] as String? ?? '127.0.0.1 (Local)',
      );
}

/// Administrative user account with RBAC assignment.
class AdminAccount {
  final String id;
  final String email;
  final String name;
  final AdminRole role;
  final bool isActive;
  final String? lastLoginAt;
  final String createdAt;

  const AdminAccount({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
    this.isActive = true,
    this.lastLoginAt,
    required this.createdAt,
  });

  AdminAccount copyWith({
    String? id,
    String? email,
    String? name,
    AdminRole? role,
    bool? isActive,
    String? lastLoginAt,
    String? createdAt,
  }) {
    return AdminAccount(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      role: role ?? this.role,
      isActive: isActive ?? this.isActive,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        'name': name,
        'role': role.name,
        'isActive': isActive,
        'lastLoginAt': lastLoginAt,
        'createdAt': createdAt,
      };

  factory AdminAccount.fromJson(Map<String, dynamic> json) => AdminAccount(
        id: json['id'] as String? ?? 'adm_${DateTime.now().millisecondsSinceEpoch}',
        email: json['email'] as String? ?? '',
        name: json['name'] as String? ?? 'Admin',
        role: AdminRole.fromString(json['role'] as String?),
        isActive: json['isActive'] as bool? ?? true,
        lastLoginAt: json['lastLoginAt'] as String?,
        createdAt: json['createdAt'] as String? ?? DateTime.now().toIso8601String(),
      );
}

/// CMS-managed Frequently Asked Question item.
class FaqItem {
  final String id;
  final String question;
  final String answer;
  final String category;
  final int sortOrder;
  final bool isPublished;

  const FaqItem({
    required this.id,
    required this.question,
    required this.answer,
    this.category = 'General',
    this.sortOrder = 0,
    this.isPublished = true,
  });

  FaqItem copyWith({
    String? id,
    String? question,
    String? answer,
    String? category,
    int? sortOrder,
    bool? isPublished,
  }) {
    return FaqItem(
      id: id ?? this.id,
      question: question ?? this.question,
      answer: answer ?? this.answer,
      category: category ?? this.category,
      sortOrder: sortOrder ?? this.sortOrder,
      isPublished: isPublished ?? this.isPublished,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'question': question,
        'answer': answer,
        'category': category,
        'sortOrder': sortOrder,
        'isPublished': isPublished,
      };

  factory FaqItem.fromJson(Map<String, dynamic> json) => FaqItem(
        id: json['id'] as String? ?? 'faq_${DateTime.now().millisecondsSinceEpoch}',
        question: json['question'] as String? ?? '',
        answer: json['answer'] as String? ?? '',
        category: json['category'] as String? ?? 'General',
        sortOrder: (json['sortOrder'] as num?)?.toInt() ?? 0,
        isPublished: json['isPublished'] as bool? ?? true,
      );
}

/// CMS-managed dynamic Announcement or Emergency Notice banner.
class AnnouncementItem {
  final String id;
  final String title;
  final String message;
  final String badgeText;
  final String linkUrl;
  final bool isActive;
  final String priority; // 'info', 'warning', 'urgent'
  final String createdAt;

  const AnnouncementItem({
    required this.id,
    required this.title,
    required this.message,
    this.badgeText = 'NOTICE',
    this.linkUrl = '',
    this.isActive = true,
    this.priority = 'info',
    required this.createdAt,
  });

  AnnouncementItem copyWith({
    String? id,
    String? title,
    String? message,
    String? badgeText,
    String? linkUrl,
    bool? isActive,
    String? priority,
    String? createdAt,
  }) {
    return AnnouncementItem(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      badgeText: badgeText ?? this.badgeText,
      linkUrl: linkUrl ?? this.linkUrl,
      isActive: isActive ?? this.isActive,
      priority: priority ?? this.priority,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'message': message,
        'badgeText': badgeText,
        'linkUrl': linkUrl,
        'isActive': isActive,
        'priority': priority,
        'createdAt': createdAt,
      };

  factory AnnouncementItem.fromJson(Map<String, dynamic> json) => AnnouncementItem(
        id: json['id'] as String? ?? 'ann_${DateTime.now().millisecondsSinceEpoch}',
        title: json['title'] as String? ?? '',
        message: json['message'] as String? ?? '',
        badgeText: json['badgeText'] as String? ?? 'NOTICE',
        linkUrl: json['linkUrl'] as String? ?? '',
        isActive: json['isActive'] as bool? ?? true,
        priority: json['priority'] as String? ?? 'info',
        createdAt: json['createdAt'] as String? ?? DateTime.now().toIso8601String(),
      );
}

/// SEO Metadata definition per screen or route.
class SeoMetadata {
  final String routePath;
  final String pageTitle;
  final String metaDescription;
  final String keywords;
  final String ogImageUrl;

  const SeoMetadata({
    required this.routePath,
    required this.pageTitle,
    required this.metaDescription,
    this.keywords = 'pune tourism, maharashtra heritage, shaniwar wada, pune darshan',
    this.ogImageUrl = '',
  });

  SeoMetadata copyWith({
    String? routePath,
    String? pageTitle,
    String? metaDescription,
    String? keywords,
    String? ogImageUrl,
  }) {
    return SeoMetadata(
      routePath: routePath ?? this.routePath,
      pageTitle: pageTitle ?? this.pageTitle,
      metaDescription: metaDescription ?? this.metaDescription,
      keywords: keywords ?? this.keywords,
      ogImageUrl: ogImageUrl ?? this.ogImageUrl,
    );
  }

  Map<String, dynamic> toJson() => {
        'routePath': routePath,
        'pageTitle': pageTitle,
        'metaDescription': metaDescription,
        'keywords': keywords,
        'ogImageUrl': ogImageUrl,
      };

  factory SeoMetadata.fromJson(Map<String, dynamic> json) => SeoMetadata(
        routePath: json['routePath'] as String? ?? '/',
        pageTitle: json['pageTitle'] as String? ?? 'PuneExplorer',
        metaDescription: json['metaDescription'] as String? ?? 'Official travel guide to Pune',
        keywords: json['keywords'] as String? ?? '',
        ogImageUrl: json['ogImageUrl'] as String? ?? '',
      );
}
