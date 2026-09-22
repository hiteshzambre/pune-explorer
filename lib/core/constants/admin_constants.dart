class AdminConstants {
  // Configurable Admin Environment Keys (no production credentials in source code)
  static const String defaultAdminEmail =
      String.fromEnvironment('ADMIN_EMAIL', defaultValue: 'admin@puneexplorer.com');
  static const String defaultAdminPassword =
      String.fromEnvironment('ADMIN_PASSWORD', defaultValue: 'TestAdminPass123!');
  static const String defaultAdminPin =
      String.fromEnvironment('ADMIN_PIN', defaultValue: '1234');

  // Role Names
  static const String roleSuperAdmin = 'Super Admin';
  static const String roleOperations = 'Operations Manager';
  static const String roleContent = 'Content Editor';

  // Storage Keys
  static const String keyAdminToken = 'pune_admin_session_token';
  static const String keyAdminEmail = 'pune_admin_email';
  static const String keyAdminRole = 'pune_admin_role';
  static const String keyAdminLastLogin = 'pune_admin_last_login';
}
