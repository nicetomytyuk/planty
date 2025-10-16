class AppConstants {
  // App info
  static const String appName = 'Planty';
  static const String appVersion = '1.0.0';

  // API endpoints (for future use)
  static const String baseUrl = 'https://your-api-endpoint.com/api';
  static const String vasesEndpoint = '/vases';
  static const String plantsEndpoint = '/plants';

  // Time formats
  static const String dateFormat = 'MMM dd, yyyy';
  static const String timeFormat = 'HH:mm';
  static const String dateTimeFormat = 'MMM dd, yyyy HH:mm';

  // Durations
  static const Duration refreshInterval = Duration(minutes: 5);
  static const Duration sensorTimeout = Duration(minutes: 10);

  // Limits
  static const int maxVases = 20;
  static const int maxHistoryItems = 100;
  static const double minHumidity = 0.0;
  static const double maxHumidity = 100.0;

  // Default values
  static const int defaultWaterDuration = 30; // seconds
  static const int defaultWaterAmount = 200; // milliliters
  static const int defaultLightDurationMinutes = 60; // minutes
  static const int defaultLightIntensityPercent = 80; // percentage output

  // Animation durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 300);
  static const Duration longAnimation = Duration(milliseconds: 500);

  // UI measurements
  static const double cardBorderRadius = 16.0;
  static const double buttonBorderRadius = 12.0;
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;

  // Asset paths (for later use with local images)
  static const String assetsPath = 'assets/images';
  static const String emptyVaseImage = '$assetsPath/empty_vase.png';
}
