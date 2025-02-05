// lib/shared/widgets/food_item_card.dart
import 'package:cached_network_image/cached_network_image.dart';
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
  bool isFavorite = false;

  @override
  void initState() {
    super.initState();
    _checkFavoriteStatus();
  }

  Future<void> _checkFavoriteStatus() async {
    final status = await _storageService.isFavorite(widget.foodItem.id);
    if (mounted) {
      setState(() {
        isFavorite = status;
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
            // Image section
            Stack(
              children: [
                ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(12)),
                  child: widget.foodItem.image != null
                      ? CachedNetworkImage(
                          imageUrl:
                              'http://192.168.55.15:8000/storage/${widget.foodItem.image}',
                          height: 150,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            color: Colors.grey[300],
                            child: const Center(
                              child: CircularProgressIndicator(),
                            ),
                          ),
                          errorWidget: (context, url, error) => Container(
                            color: Colors.grey[300],
                            child: const Icon(Icons.restaurant, size: 50),
                          ),
                        )
                      : Container(
                          height: 150,
                          color: Colors.grey[300],
                          child: const Icon(Icons.restaurant, size: 50),
                        ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: IconButton(
                    icon: Icon(
                      isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: isFavorite ? Colors.red : Colors.white,
                    ),
                    onPressed: () async {
                      if (isFavorite) {
                        await _storageService
                            .removeFromFavorites(widget.foodItem.id);
                      } else {
                        await _storageService.addToFavorites(widget.foodItem);
                      }
                      await _checkFavoriteStatus();
                    },
                  ),
                ),
              ],
            ),
            // Content section
            Padding(
              padding: const EdgeInsets.all(12),
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
                    style: Theme.of(context).textTheme.bodyMedium,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '\$${widget.foodItem.price}',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                      ElevatedButton.icon(
                        onPressed: () => widget.onAddToCart(widget.foodItem),
                        icon: const Icon(Icons.add_shopping_cart),
                        label: const Text('Add'),
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
