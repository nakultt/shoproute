import 'package:flutter/foundation.dart';

/// API Endpoints for ShopRoute Backend
class ApiEndpoints {
  ApiEndpoints._();

  // Base URL - Auto-switch between Prod and Dev
  static String get baseUrl {
    if (kReleaseMode) {
      return 'https://shoproute.onrender.com';
    }
    return 'http://10.0.2.2:3000'; // Default for Android Emulator
  }

  static const String apiVersion = '/api';

  // Full API base
  static String get apiBase => '$baseUrl$apiVersion';

  // Auth Endpoints
  static const String auth = '/auth';
  static String get register => '$auth/register';
  static String get login => '$auth/login';
  static String get verifyEmail => '$auth/verify-email';
  static String get resendOtp => '$auth/resend-otp';
  static String get forgotPassword => '$auth/forgot-password';
  static String get resetPassword => '$auth/reset-password';
  static String get me => '$auth/me';

  // Products Endpoints
  static const String products = '/products';
  static String productById(
    int id,
  ) => '$products/$id';
  static String productStores(
    int id,
  ) => '$products/$id/stores';
  static String productReviews(
    int id,
  ) => '$products/$id/reviews';
  static String get productSearch => '$products/search';
  static String get productSuggestions => '$products/suggestions';
  static String get productRecommendations => '$products/recommendations';

  // Stores Endpoints
  static const String stores = '/stores';
  static String get nearbyStores => '$stores/nearby';
  static String storeById(
    int id,
  ) => '$stores/$id';
  static String storeWithProduct(
    int productId,
  ) => '$stores/with-product/$productId';

  // Categories Endpoints
  static const String categories = '/categories';
  static String categoryById(
    int id,
  ) => '$categories/$id';

  // Cart Endpoints
  static const String cart = '/cart';
  static String get addToCart => '$cart/add';
  static String updateCartItem(
    int id,
  ) => '$cart/update/$id';
  static String removeCartItem(
    int id,
  ) => '$cart/remove/$id';
  static String get clearCart => '$cart/clear';

  // User Endpoints
  static const String user = '/user';
  static String get profile => '$user/profile';
  static String get statistics => '$user/statistics';
  static String get preferences => '$user/preferences';
  static String get favoriteProducts => '$user/favorites/products';
  static String get favoriteStores => '$user/favorites/stores';
  static String get favorites => '$user/favorites';
  static String deleteFavorite(
    String type,
    int id,
  ) => '$user/favorites/$type/$id';
  static String get shoppingLists => '$user/shopping-lists';
  static String shoppingListById(
    int id,
  ) => '$user/shopping-lists/$id';
  static String get deleteAccount => '$user/account';

  // AI Endpoints
  static const String ai = '/ai';
  static String get aiChat => '$ai/chat';
  static String get aiRouteOptimization => '$ai/route-optimization';
  static String get aiRecommendations => '$ai/recommendations';
  static String get aiConversationHistory => '$ai/conversation-history';

  // External Services
  static const String osrmBaseUrl = 'http://router.project-osrm.org';
  static String osrmRoute(
    String coordinates,
  ) => '$osrmBaseUrl/route/v1/driving/$coordinates?overview=full&geometries=geojson';
}
