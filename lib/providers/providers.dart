import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/models.dart';
import '../services/api_service.dart';
import '../utils/constants.dart';

// =========== AUTH PROVIDER ===========
class AuthProvider extends ChangeNotifier {
  AppUser? _user;
  bool _loading = false;

  AppUser? get user => _user;
  bool get loading => _loading;
  bool get isLoggedIn => _user != null;

  final _api = ApiService();

  Future<void> loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(AppConstants.userKey);
    if (data != null) {
      _user = AppUser.fromJson(jsonDecode(data));
      notifyListeners();
    }
  }

  Future<void> register(String name, String email, String password) async {
    _loading = true; notifyListeners();
    try {
      final res = await _api.post('/auth/register', {'name': name, 'email': email, 'password': password}, auth: false);
      await _saveAuth(res);
    } finally {
      _loading = false; notifyListeners();
    }
  }

  Future<void> login(String email, String password) async {
    _loading = true; notifyListeners();
    try {
      final res = await _api.post('/auth/login', {'email': email, 'password': password}, auth: false);
      await _saveAuth(res);
    } finally {
      _loading = false; notifyListeners();
    }
  }

  Future<void> _saveAuth(Map<String, dynamic> res) async {
    final prefs = await SharedPreferences.getInstance();
    final token = res['token'];
    _api.setToken(token);
    await prefs.setString(AppConstants.tokenKey, token);
    _user = AppUser.fromJson(res['user']);
    await prefs.setString(AppConstants.userKey, jsonEncode(_user!.toJson()));
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppConstants.tokenKey);
    await prefs.remove(AppConstants.userKey);
    _api.clearToken();
    _user = null;
    notifyListeners();
  }

  void updateWallet(double newBalance) {
    _user?.walletBalance = newBalance;
    notifyListeners();
    _persistUser();
  }

  Future<void> _persistUser() async {
    if (_user == null) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.userKey, jsonEncode(_user!.toJson()));
  }
}

// =========== PRODUCTS PROVIDER ===========
class ProductsProvider extends ChangeNotifier {
  List<Product> _products = [];
  List<Product> _featured = [];
  Product? _selectedProduct;
  List<Product> _related = [];
  bool _loading = false;
  String _selectedCategory = '';
  String _searchQuery = '';

  List<Product> get products => _products;
  List<Product> get featured => _featured;
  Product? get selectedProduct => _selectedProduct;
  List<Product> get related => _related;
  bool get loading => _loading;
  String get selectedCategory => _selectedCategory;

  final _api = ApiService();

  Future<void> loadProducts({String? category, String? search}) async {
    _loading = true; notifyListeners();
    try {
      final params = <String, dynamic>{};
      if (category != null && category.isNotEmpty) params['category'] = category;
      if (search != null && search.isNotEmpty) params['search'] = search;
      final res = await _api.get('/products', params: params);
      _products = (res['products'] as List).map((p) => Product.fromJson(p)).toList();
      if (category == null && search == null) {
        _featured = _products.where((p) => p.rating >= 4.5).take(6).toList();
      }
    } finally {
      _loading = false; notifyListeners();
    }
  }

  Future<void> loadProductDetail(int id) async {
    _loading = true; notifyListeners();
    try {
      final res = await _api.get('/products/$id');
      _selectedProduct = Product.fromJson(res['product']);
      _related = (res['related'] as List).map((p) => Product.fromJson(p)).toList();
    } finally {
      _loading = false; notifyListeners();
    }
  }

  void setCategory(String cat) {
    _selectedCategory = cat;
    notifyListeners();
    loadProducts(category: cat.isEmpty ? null : cat);
  }
}

// =========== CART PROVIDER ===========
class CartProvider extends ChangeNotifier {
  List<CartItem> _items = [];
  double _total = 0;
  bool _loading = false;

  List<CartItem> get items => _items;
  double get total => _total;
  bool get loading => _loading;
  int get itemCount => _items.fold(0, (sum, i) => sum + i.quantity);

  final _api = ApiService();

  Future<void> loadCart() async {
    _loading = true; notifyListeners();
    try {
      final res = await _api.get('/cart');
      _items = (res['items'] as List).map((i) => CartItem.fromJson(i)).toList();
      _total = (res['total'] ?? 0).toDouble();
    } catch (_) {
      _items = [];
    } finally {
      _loading = false; notifyListeners();
    }
  }

  Future<void> addToCart(int productId, {int quantity = 1}) async {
    await _api.post('/cart/add', {'product_id': productId, 'quantity': quantity});
    await loadCart();
  }

  Future<void> removeFromCart(int cartItemId) async {
    await _api.delete('/cart/$cartItemId');
    await loadCart();
  }

  Future<void> clearCart() async {
    await _api.delete('/cart/clear');
    _items = []; _total = 0;
    notifyListeners();
  }
}

// =========== ORDERS PROVIDER ===========
class OrdersProvider extends ChangeNotifier {
  List<Order> _orders = [];
  bool _loading = false;

  List<Order> get orders => _orders;
  bool get loading => _loading;

  final _api = ApiService();

  Future<void> loadOrders() async {
    _loading = true; notifyListeners();
    try {
      final res = await _api.get('/orders');
      _orders = (res['orders'] as List).map((o) => Order.fromJson(o)).toList();
    } finally {
      _loading = false; notifyListeners();
    }
  }

  Future<Order> placeOrder({String? address}) async {
    final res = await _api.post('/orders', {'shipping_address': address ?? 'Default Address'});
    await loadOrders();
    return Order.fromJson(res['order']);
  }
}
