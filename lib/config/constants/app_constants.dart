/// App-wide constants for ShopRoute
class AppConstants {
  AppConstants._();

  // App Info
  static const String appName = 'ShopRoute';
  static const String appTagline = 'Shop Smarter, Route Faster';
  static const String appVersion = '1.0.0';

  // Timing
  static const int splashDuration = 2500; // milliseconds
  static const int otpExpiryMinutes = 10;
  static const int searchDebounceMs = 300;
  static const int animationDurationMs = 300;

  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 50;

  // Validation
  static const int minPasswordLength = 8;
  static const int maxNameLength = 255;
  static const int otpLength = 6;

  // Map
  static const double defaultLatitude = 11.0168; // Coimbatore
  static const double defaultLongitude = 76.9558;
  static const double defaultZoom = 14.0;
  static const double maxSearchRadius = 20000; // meters (20km)
  static const double defaultSearchRadius = 5000; // meters (5km)

  // Storage Keys
  static const String tokenKey = 'auth_token';
  static const String userKey = 'user_data';
  static const String themeKey = 'theme_mode';
  static const String languageKey = 'language';
  static const String onboardingKey = 'onboarding_complete';
  static const String searchHistoryKey = 'search_history';

  // Categories
  // Categories
  static const List<
    Map<
      String,
      dynamic
    >
  >
  defaultCategories = [
    {
      'id': 0,
      'name': 'All Products',
      'icon': '🔥',
      'color': 0xFFEF4444,
    },
    {
      'id': 1,
      'name': 'Fruits & Vegetables',
      'icon': '🍎',
      'color': 0xFF22C55E,
    },
    {
      'id': 2,
      'name': 'Dairy & Breakfast',
      'icon': '🥛',
      'color': 0xFF0EA5E9,
    },
    {
      'id': 3,
      'name': 'Rice & Grains',
      'icon': '🌾',
      'color': 0xFFEAB308,
    },
    {
      'id': 4,
      'name': 'Bakery & Snacks',
      'icon': '🍞',
      'color': 0xFFF97316,
    },
    {
      'id': 5,
      'name': 'Beverages',
      'icon': '🥤',
      'color': 0xFF8B5CF6,
    },
    {
      'id': 6,
      'name': 'Personal Care',
      'icon': '🧴',
      'color': 0xFFEC4899,
    },
    {
      'id': 7,
      'name': 'Household',
      'icon': '🧹',
      'color': 0xFF6B7280,
    },
  ];

  // Dietary Preferences
  static const List<
    String
  >
  dietaryPreferences = [
    'Vegetarian',
    'Vegan',
    'Gluten-free',
    'Dairy-free',
    'Nut-free',
    'Halal',
    'Kosher',
    'Low-sodium',
    'Low-sugar',
    'Organic',
  ];

  // Languages
  static const List<
    Map<
      String,
      String
    >
  >
  supportedLanguages = [
    {
      'code': 'en',
      'name': 'English',
    },
    {
      'code': 'es',
      'name': 'Español',
    },
    {
      'code': 'fr',
      'name': 'Français',
    },
    {
      'code': 'de',
      'name': 'Deutsch',
    },
    {
      'code': 'hi',
      'name': 'हिन्दी',
    },
    {
      'code': 'ta',
      'name': 'தமிழ்',
    },
  ];

  // Quick Action Chips for AI
  static const List<
    String
  >
  aiQuickActions = [
    'Find best deals',
    'Plan shopping route',
    'Recommend products',
    'Compare stores',
  ];
}
