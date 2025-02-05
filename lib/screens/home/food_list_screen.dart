// lib/screens/home/food_list_screen.dart
import 'package:flutter/material.dart';
import '../../models/food_item.dart';
import '../../services/api_service.dart';
import '../../services/local_storage_service.dart';
import '../../shared/widgets/food_item_card.dart';
import '../favorites/favorites_screen.dart';
import '../cart/cart_screen.dart';
import '../profile/profile_screen.dart';
import 'food_detail_screen.dart';

class FoodListScreen extends StatefulWidget {
  const FoodListScreen({Key? key}) : super(key: key);

  @override
  State<FoodListScreen> createState() => _FoodListScreenState();
}

class _FoodListScreenState extends State<FoodListScreen> {
  final ApiService _apiService = ApiService();
  final LocalStorageService _storageService = LocalStorageService();
  List<FoodItem> _foodItems = [];
  bool _isLoading = true;
  String _errorMessage = '';
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadFoodItems();
  }

  Future<void> _loadFoodItems() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final items = await _apiService.getFoodItems();
      if (mounted) {
        setState(() {
          _foodItems = items;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to load food items. Please try again.';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: [
          _buildFoodList(),
          const FavoritesScreen(),
          const CartScreen(),
          const ProfileScreen(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Favorites',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Cart',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  Widget _buildFoodList() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_errorMessage),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadFoodItems,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadFoodItems,
      child: GridView.builder(
        padding: const EdgeInsets.all(8),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.75,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
        ),
        itemCount: _foodItems.length,
        itemBuilder: (context, index) {
          final item = _foodItems[index];
          return FoodItemCard(
            foodItem: item,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => FoodDetailScreen(foodItem: item),
                ),
              );
            },
            onAddToCart: (foodItem) async {
              try {
                await _storageService.addToCart(foodItem);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${foodItem.name} added to cart'),
                      action: SnackBarAction(
                        label: 'View Cart',
                        onPressed: () {
                          setState(() {
                            _currentIndex = 2; // Switch to cart screen
                          });
                        },
                      ),
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Failed to add item to cart')),
                  );
                }
              }
            },
          );
        },
      ),
    );
  }
}