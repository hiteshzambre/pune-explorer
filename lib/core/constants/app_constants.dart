/// Core App Constants
class AppConstants {
  static const String appName = 'PuneExplorer';
  static const String appVersion = '1.0.0';
  static const String helplinePhone = '+91 20 2612 6867';
  static const String helplineEmail = 'support@puneexplorer.in';

  // Pune Coordinates (Default Center)
  static const double defaultLat = 18.5204;
  static const double defaultLng = 73.8567;
  static const double defaultZoom = 11.5;

  // Platform Booking Pricing Constants
  static const double gstRate = 0.05; // 5% GST
  static const double platformFee = 99.0; // ₹99 per booking

  // Storage Keys
  static const String keyThemeMode = 'pune_theme_mode';
  static const String keyLanguage = 'pune_language';
  static const String keyFavorites = 'pune_favorites_v1';
  static const String keyBookings = 'pune_bookings_v1';
  static const String keyRecentSearches = 'pune_recent_searches';
  static const String keyCustomTrips = 'pune_custom_trips';
  static const String keyUserAuth = 'pune_user_auth';
  static const String keyPayments = 'pune_payments_v1';
}
