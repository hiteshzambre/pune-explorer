import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_hi.dart';
import 'app_localizations_mr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('hi'),
    Locale('mr')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'PuneExplorer'**
  String get appTitle;

  /// No description provided for @tagline.
  ///
  /// In en, this message translates to:
  /// **'Explore Pune Your Way.'**
  String get tagline;

  /// No description provided for @heroSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Handcrafted fort treks, royal heritage wadas, misty hill stations, and curated Pune Darshan tours with certified local leaders.'**
  String get heroSubtitle;

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navExplore.
  ///
  /// In en, this message translates to:
  /// **'Explore'**
  String get navExplore;

  /// No description provided for @navDarshan.
  ///
  /// In en, this message translates to:
  /// **'Pune Darshan'**
  String get navDarshan;

  /// No description provided for @navRoutes.
  ///
  /// In en, this message translates to:
  /// **'Routes'**
  String get navRoutes;

  /// No description provided for @navBudget.
  ///
  /// In en, this message translates to:
  /// **'Budget'**
  String get navBudget;

  /// No description provided for @navFavorites.
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get navFavorites;

  /// No description provided for @navProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get navProfile;

  /// No description provided for @navAdmin.
  ///
  /// In en, this message translates to:
  /// **'Admin CMS'**
  String get navAdmin;

  /// No description provided for @searchPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Search Sinhagad, Lonavala, Misal joints, forts...'**
  String get searchPlaceholder;

  /// No description provided for @filterAll.
  ///
  /// In en, this message translates to:
  /// **'All Categories'**
  String get filterAll;

  /// No description provided for @filterForts.
  ///
  /// In en, this message translates to:
  /// **'Historical Forts'**
  String get filterForts;

  /// No description provided for @filterHillStations.
  ///
  /// In en, this message translates to:
  /// **'Hill Stations & Lakes'**
  String get filterHillStations;

  /// No description provided for @filterSpiritual.
  ///
  /// In en, this message translates to:
  /// **'Temples & Wadas'**
  String get filterSpiritual;

  /// No description provided for @filterAdventure.
  ///
  /// In en, this message translates to:
  /// **'Adventure & Treks'**
  String get filterAdventure;

  /// No description provided for @filterWeekend.
  ///
  /// In en, this message translates to:
  /// **'Weekend Getaways'**
  String get filterWeekend;

  /// No description provided for @filterCity.
  ///
  /// In en, this message translates to:
  /// **'Pune City Culture'**
  String get filterCity;

  /// No description provided for @bookTourNow.
  ///
  /// In en, this message translates to:
  /// **'Book Tour Now'**
  String get bookTourNow;

  /// No description provided for @selectSeats.
  ///
  /// In en, this message translates to:
  /// **'Select Bus Seats'**
  String get selectSeats;

  /// No description provided for @travelers.
  ///
  /// In en, this message translates to:
  /// **'Travelers'**
  String get travelers;

  /// No description provided for @dateOfTravel.
  ///
  /// In en, this message translates to:
  /// **'Date of Travel'**
  String get dateOfTravel;

  /// No description provided for @pickupPoint.
  ///
  /// In en, this message translates to:
  /// **'Pickup Terminal'**
  String get pickupPoint;

  /// No description provided for @confirmed.
  ///
  /// In en, this message translates to:
  /// **'Confirmed'**
  String get confirmed;

  /// No description provided for @paymentPending.
  ///
  /// In en, this message translates to:
  /// **'Payment Pending'**
  String get paymentPending;

  /// No description provided for @viewBoardingPass.
  ///
  /// In en, this message translates to:
  /// **'View QR Boarding Pass'**
  String get viewBoardingPass;

  /// No description provided for @printTicket.
  ///
  /// In en, this message translates to:
  /// **'Print E-Ticket'**
  String get printTicket;

  /// No description provided for @downloadPdf.
  ///
  /// In en, this message translates to:
  /// **'Download PDF Pass'**
  String get downloadPdf;

  /// No description provided for @budgetPlanner.
  ///
  /// In en, this message translates to:
  /// **'Budget Planner'**
  String get budgetPlanner;

  /// No description provided for @aiAssistant.
  ///
  /// In en, this message translates to:
  /// **'PunekarBot AI'**
  String get aiAssistant;

  /// No description provided for @aiAssistantSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your 24/7 Pune Travel & Heritage Guide'**
  String get aiAssistantSubtitle;

  /// No description provided for @offlineBanner.
  ///
  /// In en, this message translates to:
  /// **'You are currently offline. Viewing cached travel guides.'**
  String get offlineBanner;

  /// No description provided for @backOnline.
  ///
  /// In en, this message translates to:
  /// **'Back online. Syncing latest data.'**
  String get backOnline;

  /// No description provided for @applyCoupon.
  ///
  /// In en, this message translates to:
  /// **'Apply Coupon'**
  String get applyCoupon;

  /// No description provided for @totalAmount.
  ///
  /// In en, this message translates to:
  /// **'Total Amount'**
  String get totalAmount;

  /// No description provided for @proceedToPayment.
  ///
  /// In en, this message translates to:
  /// **'Proceed to Payment'**
  String get proceedToPayment;

  /// No description provided for @payWithRazorpay.
  ///
  /// In en, this message translates to:
  /// **'Pay Securely with Razorpay'**
  String get payWithRazorpay;

  /// No description provided for @mockPayment.
  ///
  /// In en, this message translates to:
  /// **'Simulate Test Payment'**
  String get mockPayment;

  /// No description provided for @reviews.
  ///
  /// In en, this message translates to:
  /// **'Reviews'**
  String get reviews;

  /// No description provided for @writeReview.
  ///
  /// In en, this message translates to:
  /// **'Write a Review'**
  String get writeReview;

  /// No description provided for @rating.
  ///
  /// In en, this message translates to:
  /// **'Rating'**
  String get rating;

  /// No description provided for @savePlace.
  ///
  /// In en, this message translates to:
  /// **'Save Place'**
  String get savePlace;

  /// No description provided for @savedPlaces.
  ///
  /// In en, this message translates to:
  /// **'Saved Places'**
  String get savedPlaces;

  /// No description provided for @myBookings.
  ///
  /// In en, this message translates to:
  /// **'My Bookings'**
  String get myBookings;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get signIn;

  /// No description provided for @signOut.
  ///
  /// In en, this message translates to:
  /// **'Sign Out'**
  String get signOut;

  /// No description provided for @guestMode.
  ///
  /// In en, this message translates to:
  /// **'Continue as Guest'**
  String get guestMode;

  /// No description provided for @darkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get darkMode;

  /// No description provided for @lightMode.
  ///
  /// In en, this message translates to:
  /// **'Light Mode'**
  String get lightMode;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @bestTime.
  ///
  /// In en, this message translates to:
  /// **'Best Time'**
  String get bestTime;

  /// No description provided for @duration.
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get duration;

  /// No description provided for @entryFee.
  ///
  /// In en, this message translates to:
  /// **'Entry Fee'**
  String get entryFee;

  /// No description provided for @difficulty.
  ///
  /// In en, this message translates to:
  /// **'Difficulty'**
  String get difficulty;

  /// No description provided for @distanceFromPune.
  ///
  /// In en, this message translates to:
  /// **'Distance from Pune'**
  String get distanceFromPune;

  /// No description provided for @overview.
  ///
  /// In en, this message translates to:
  /// **'Overview'**
  String get overview;

  /// No description provided for @map.
  ///
  /// In en, this message translates to:
  /// **'Map'**
  String get map;

  /// No description provided for @weather.
  ///
  /// In en, this message translates to:
  /// **'Weather'**
  String get weather;

  /// No description provided for @food.
  ///
  /// In en, this message translates to:
  /// **'Food & Delicacies'**
  String get food;

  /// No description provided for @budget.
  ///
  /// In en, this message translates to:
  /// **'Budget'**
  String get budget;

  /// No description provided for @emptySearchTitle.
  ///
  /// In en, this message translates to:
  /// **'No Destinations Found'**
  String get emptySearchTitle;

  /// No description provided for @emptySearchDesc.
  ///
  /// In en, this message translates to:
  /// **'Try searching for Sinhagad, Pawna Lake, Shaniwar Wada, or adjust your filters.'**
  String get emptySearchDesc;

  /// No description provided for @emptyBookingsTitle.
  ///
  /// In en, this message translates to:
  /// **'No Bookings Yet'**
  String get emptyBookingsTitle;

  /// No description provided for @emptyBookingsDesc.
  ///
  /// In en, this message translates to:
  /// **'Discover Pune Darshan bus tours or Sahyadri treks and book your first experience!'**
  String get emptyBookingsDesc;

  /// No description provided for @emptyFavoritesTitle.
  ///
  /// In en, this message translates to:
  /// **'No Favorites Saved'**
  String get emptyFavoritesTitle;

  /// No description provided for @emptyFavoritesDesc.
  ///
  /// In en, this message translates to:
  /// **'Tap the heart icon on any destination to save it for your next trip.'**
  String get emptyFavoritesDesc;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'hi', 'mr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'hi':
      return AppLocalizationsHi();
    case 'mr':
      return AppLocalizationsMr();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
