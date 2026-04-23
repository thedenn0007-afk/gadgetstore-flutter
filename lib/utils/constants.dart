// lib/utils/constants.dart
class AppConstants {
  static const String baseUrl = 'https://gadgetstore-backend-ilo2.onrender.com/api';
  
  static const String tokenKey = 'auth_token';
  static const String userKey = 'user_data';
  
  static const List<Map<String, dynamic>> categories = [
    {'id': 'earbuds',     'label': 'Earbuds',       'icon': '🎧', 'color': 0xFFE8F0FE},
    {'id': 'headphones',  'label': 'Headphones',    'icon': '🎵', 'color': 0xFFE6F4EA},
    {'id': 'smartwatches','label': 'Smartwatches',  'icon': '⌚', 'color': 0xFFFEF7E0},
    {'id': 'smart_rings', 'label': 'Smart Rings',   'icon': '💍', 'color': 0xFFFCE8E6},
  ];
  
  static const List<String> orderStatuses = [
    'PLACED', 'CONFIRMED', 'PROCESSING', 'SHIPPED', 'DELIVERED'
  ];
}
