// lib/services/local_storage_service.dart
import 'package:shared_preferences/shared_preferences.dart';
import '../models/food_item.dart';
import '../models/cart_item.dart';
import 'dart:convert';

class LocalStorageService {
  static const String favoritesKey = 'favorites';
  static const String cartKey = 'cart';

  // Favorites methods
  Future<void> saveFavorites(List<FoodItem> favorites) async {
    final prefs = await SharedPreferences.getInstance();
    final favoritesJson =
        favorites.map((item) => _encodeFoodItem(item)).toList();
    await prefs.setStringList(favoritesKey, favoritesJson);
  }

  Future<List<FoodItem>> getFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final favoritesJson = prefs.getStringList(favoritesKey) ?? [];
    return favoritesJson
        .map((item) => FoodItem.fromJson(json.decode(item)))
        .toList();
  }

  Future<void> addToFavorites(FoodItem item) async {
    final favorites = await getFavorites();
    if (!favorites.any((element) => element.id == item.id)) {
      favorites.add(item);
      await saveFavorites(favorites);
    }
  }

  Future<void> removeFromFavorites(int foodItemId) async {
    final favorites = await getFavorites();
    favorites.removeWhere((item) => item.id == foodItemId);
    await saveFavorites(favorites);
  }

  Future<bool> isFavorite(int foodItemId) async {
    final favorites = await getFavorites();
    return favorites.any((item) => item.id == foodItemId);
  }

  // Cart methods
  Future<void> saveCart(List<CartItem> cartItems) async {
    final prefs = await SharedPreferences.getInstance();
    final cartJson = cartItems.map((item) => _encodeCartItem(item)).toList();
    await prefs.setStringList(cartKey, cartJson);
  }

  Future<List<CartItem>> getCart() async {
    final prefs = await SharedPreferences.getInstance();
    final cartJson = prefs.getStringList(cartKey) ?? [];
    return cartJson.map((item) => _decodeCartItem(item)).toList();
  }

  Future<void> addToCart(FoodItem item, [int quantity = 1]) async {
    final cart = await getCart();
    final existingItemIndex =
        cart.indexWhere((cartItem) => cartItem.foodItem.id == item.id);

    if (existingItemIndex != -1) {
      cart[existingItemIndex].quantity += quantity;
    } else {
      cart.add(CartItem(foodItem: item, quantity: quantity));
    }

    await saveCart(cart);
  }

  Future<void> removeFromCart(int foodItemId) async {
    final cart = await getCart();
    cart.removeWhere((item) => item.foodItem.id == foodItemId);
    await saveCart(cart);
  }

  Future<void> updateCartItemQuantity(int foodItemId, int quantity) async {
    final cart = await getCart();
    final itemIndex = cart.indexWhere((item) => item.foodItem.id == foodItemId);

    if (itemIndex != -1) {
      if (quantity > 0) {
        cart[itemIndex].quantity = quantity;
      } else {
        cart.removeAt(itemIndex);
      }
      await saveCart(cart);
    }
  }

  Future<void> clearCart() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(cartKey, []);
  }

  // Helper methods for encoding/decoding
  String _encodeFoodItem(FoodItem item) {
    final itemMap = {
      'id': item.id,
      'name': item.name,
      'description': item.description,
      'price': item.price,
      'quantity': item.quantity,
      'image': item.image,
      'created_at': item.createdAt.toIso8601String(),
      'updated_at': item.updatedAt.toIso8601String(),
    };
    return json.encode(itemMap);
  }

  String _encodeCartItem(CartItem item) {
    return json.encode({
      'foodItem': _encodeFoodItem(item.foodItem),
      'quantity': item.quantity,
    });
  }

  CartItem _decodeCartItem(String jsonString) {
    final Map<String, dynamic> decodedJson = json.decode(jsonString);
    return CartItem(
      foodItem: FoodItem.fromJson(json.decode(decodedJson['foodItem'])),
      quantity: decodedJson['quantity'],
    );
  }
}
