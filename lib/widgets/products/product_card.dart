import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:products_explorer/providers/cart_provider.dart';
import 'package:products_explorer/providers/product_provider.dart';
import 'package:provider/provider.dart';
import '../../pages/product_detail_page.dart';

class ProductCard extends StatelessWidget {
  final int productId;
  final bool showFavorite;

  const ProductCard({
    super.key,
    required this.productId,
    this.showFavorite = true,
  });

  @override
  Widget build(BuildContext context) {
    final product = context.watch<ProductProvider>().products.firstWhere(
      (element) => element.id == productId,
    );
    final bool hasDiscount = (product.price ?? 0) > 20;
    final double discountPrice = hasDiscount
        ? (product.price ?? 0 * 1.2).toDouble()
        : (product.price ?? 0).toDouble();

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ProductDetailPage(productId: productId),
        ),
      ),
      child: Card(
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product Image
                Hero(
                  tag: 'product-${product.id}',
                  child: Container(
                    height: 150,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(16),
                      ),
                      color: Colors.grey.shade100,
                    ),
                    child: Stack(
                      children: [
                        Center(
                          child: CachedNetworkImage(
                            imageUrl:
                                product.image ??
                                "https://picsum.photos/140/120?random=0",
                            fit: BoxFit.contain,
                            height: 120,
                            errorWidget: (_, __, ___) => const Icon(
                              Icons.broken_image,
                              size: 40,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                        if (hasDiscount)
                          Positioned(
                            top: 8,
                            left: 8,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.red.shade600,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Text(
                                'SALE',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),

                // Product Details
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Product Title
                      Text(
                        product.title ?? "Unnamed Product",
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Rating
                      Row(
                        children: [
                          RatingBarIndicator(
                            rating: (product.rating?.count ?? 0).toDouble(),
                            itemSize: 14,
                            itemBuilder: (context, _) =>
                                const Icon(Icons.star, color: Colors.amber),
                            unratedColor: Colors.amber.shade100,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            product.rating?.count?.toStringAsFixed(1) ?? "0.0",
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      // Price
                      Row(
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                Text(
                                  '\$${product.price?.toStringAsFixed(2)}',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context).colorScheme.primary,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                if (hasDiscount)
                                  Text(
                                    '\$${discountPrice.toStringAsFixed(2)}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade600,
                                      decoration: TextDecoration.lineThrough,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              context.read<CartProvider>().addToCart(product);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    '${product.title} added to cart',
                                  ),
                                  duration: const Duration(seconds: 2),
                                ),
                              );
                            },
                            child: Icon(Icons.add_shopping_cart_outlined),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // Favorite Button
            if (showFavorite)
              Positioned(
                top: 4,
                right: 4,
                child: IconButton(
                  icon: Icon(
                    product.isFavorite!
                        ? Icons.favorite
                        : Icons.favorite_border,
                    color: product.isFavorite! ? Colors.red : Colors.grey,
                  ),
                  iconSize: 20,
                  onPressed: () {
                    context.read<ProductProvider>().toggleProductIsFavorite(
                      product,
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
