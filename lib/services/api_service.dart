import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:connectivity_plus/connectivity_plus.dart';
import '../models/food_item.dart';
import 'package:flutter/services.dart';

class ApiService {
  static const String baseUrl = 'http://192.168.55.15:8000/api';

  Future<bool> checkConnectivity() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    return connectivityResult != ConnectivityResult.none;
  }

  Future<List<FoodItem>> getFoodItems() async {
    if (!await checkConnectivity()) {
      return _getLocalFoodItems();
    }

    try {
      final response = await http.get(Uri.parse('$baseUrl/food-items'));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => FoodItem.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load food items');
      }
    } catch (e) {
      return _getLocalFoodItems();
    }
  }

  Future<List<FoodItem>> _getLocalFoodItems() async {
    try {
      final String jsonString =
          await rootBundle.loadString('assets/data/local_food_items.json');
      final Map<String, dynamic> jsonData = json.decode(jsonString);
      final List<dynamic> items = jsonData['food_items'];
      return items.map((json) => FoodItem.fromJson(json)).toList();
    } catch (e) {
      return [];
    }
  }
}
