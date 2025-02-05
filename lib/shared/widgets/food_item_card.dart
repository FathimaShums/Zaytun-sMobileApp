// lib/shared/widgets/food_item_card.dart

import 'package:flutter/material.dart';
import '../../models/food_item.dart';
import '../../services/local_storage_service.dart';

class FoodItemCard extends StatefulWidget {
  final FoodItem foodItem;
  final VoidCallback? onTap;
  final Function(FoodItem) onAddToCart;

  const FoodItemCard({
    Key? key,
    required this.foodItem,
    this.onTap,
    required this.onAddToCart,
  }) : super(key: key);

  @override
  State<FoodItemCard> createState() => _FoodItemCardState();
}

class _FoodItemCardState extends State<FoodItemCard> {
  final LocalStorageService _storageService = LocalStorageService();
  bool _isFavorite = false;

  @override
  void initState() {
    super.initState();
    _checkFavoriteStatus();
  }

  Future<void> _checkFavoriteStatus() async {
    final isFavorite = await _storageService.isFavorite(widget.foodItem.id);
    if (mounted) {
      setState(() {
        _isFavorite = isFavorite;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: widget.onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image and Favorite Button Stack
            Stack(
              children: [
                if (widget.foodItem.image != null)
                  Image.network(
                    'http://16.170.228.132:8000/storage/${widget.foodItem.image}', // Updated URL
                    height: 150,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 150,
                        color: Colors.grey[300],
                        child: const Icon(Icons.restaurant, size: 50),
                      );
                    },
                  )
                else
                  Container(
                    height: 150,
                    color: Colors.grey[300],
                    child: const Icon(Icons.restaurant, size: 50),
                  ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: IconButton(
                    icon: Icon(
                      _isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: _isFavorite ? Colors.red : Colors.grey,
                    ),
                    onPressed: () async {
                      if (_isFavorite) {
                        await _storageService.removeFromFavorites(widget.foodItem.id);
                      } else {
                        await _storageService.addToFavorites(widget.foodItem);
                      }
                      await _checkFavoriteStatus();
                    },
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.foodItem.name,
                    style: Theme.of(context).textTheme.titleMedium,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.foodItem.description,
                    style: Theme.of(context).textTheme.bodySmall,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '\$${widget.foodItem.price}',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      IconButton(
                        icon: const Icon(Icons.add_shopping_cart),
                        onPressed: () => widget.onAddToCart(widget.foodItem),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
