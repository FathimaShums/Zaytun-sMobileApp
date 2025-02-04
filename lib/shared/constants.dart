// lib/shared/constants.dart
class AppConstants {
  // API URLs
  static const String baseUrl = 'http://192.168.55.15:8000/api';
  static const String baseImageUrl = 'http://192.168.55.15:8000/storage/';

  // API Endpoints
  static const String loginEndpoint = '/login';
  static const String registerEndpoint = '/register';
  static const String foodItemsEndpoint = '/food-items';

  // Storage Keys
  static const String tokenKey = 'auth_token';
  static const String userKey = 'user_data';
  static const String favoritesKey = 'favorites';
  static const String cartKey = 'cart';

  // Validation
  static const int minPasswordLength = 6;

  // UI Constants
  static const double defaultPadding = 16.0;
  static const double defaultRadius = 8.0;
}
