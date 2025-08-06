import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:products_explorer/providers/cart_provider.dart';
import 'package:products_explorer/providers/product_provider.dart';
import 'package:products_explorer/widgets/cart/cart_icon.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../models/product_model.dart';

class ProductDetailPage extends StatelessWidget {
  final int productId;

  const ProductDetailPage({super.key, required this.productId});

  @override
  Widget build(BuildContext context) {
    final product = context.watch<ProductProvider>().products.firstWhere(
      (element) => element.id == productId,
      orElse: () => Product(
        id: productId,
        title: "Product not found",
        description: "No description available.",
        price: 0.0,
        image: "https://picsum.photos/300/200?random=0",
        isFavorite: false,
      ),
    );
    return Scaffold(
      appBar: AppBar(
        title: Text(
          product.title ?? "No title available.",
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () => _shareProduct(context, product),
          ),
          CartIcon(),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Hero(
              tag: 'product-${product.id}',
              child: Stack(
                children: [
                  CachedNetworkImage(
                    imageUrl:
                        product.image ??
                        "https://picsum.photos/300/200?random=0",
                    height: 300,
                    width: double.infinity,
                    fit: BoxFit.contain,
                    errorWidget: (_, __, ___) => Container(
                      height: 300,
                      color: Colors.grey[200],
                      child: const Icon(Icons.broken_image, size: 60),
                    ),
                  ),
                  Positioned(
                    bottom: 10,
                    right: 10,
                    child: IconButton.filled(
                      icon: Icon(
                        product.isFavorite!
                            ? Icons.favorite
                            : Icons.favorite_border,
                        color: product.isFavorite! ? Colors.red : Colors.grey,
                      ),
                      onPressed: () {
                        _snowSnackBar(
                          context,
                          product.isFavorite!
                              ? "Removed from favorites"
                              : "Added to favorites",
                        );
                        context.read<ProductProvider>().toggleProductIsFavorite(
                          product,
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16.0),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildHeaderSection(context, product),
                const SizedBox(height: 24),
                _buildDescriptionSection(context, product),
                const SizedBox(height: 24),
                _buildReviewsSection(context, product),
                const SizedBox(height: 24),
                _buildRelatedProductsSection(context, product),
              ]),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomBar(context, product),
    );
  }

  Widget _buildHeaderSection(BuildContext context, Product product) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                'In Stock',
                style: TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
            const Spacer(),
            Text(
              'SKU: ${product.id}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          product.title ?? "No title available.",
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        RatingBarIndicator(
          rating: product.rating?.count?.toDouble() ?? 0,
          itemBuilder: (context, _) =>
              const Icon(Icons.star, color: Colors.amber),
          itemCount: 5,
          itemSize: 20,
          unratedColor: Colors.amber[100],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Text(
              '\$${product.price?.toStringAsFixed(2)}',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 8),
            if ((product.price ?? 0) > 20)
              Text(
                '\$${((product.price ?? 0) * 1.2).toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                  decoration: TextDecoration.lineThrough,
                ),
              ),
            const Spacer(),
            _buildQuantitySelector(product),
          ],
        ),
      ],
    );
  }

  Widget _buildQuantitySelector(Product product) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.remove, size: 18),
            onPressed: () {},
          ),
          const Text('1', style: TextStyle(fontSize: 16)),
          IconButton(icon: const Icon(Icons.add, size: 18), onPressed: () {}),
        ],
      ),
    );
  }

  Widget _buildDescriptionSection(BuildContext context, Product product) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Description', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        Text(
          product.description ?? "No description available.",
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        const SizedBox(height: 16),
        _buildFeatureChips(product),
      ],
    );
  }

  Widget _buildFeatureChips(Product product) {
    final features = product.description?.split(' ').take(5).toList();
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children:
          features?.map((feature) {
            return Chip(
              label: Text(feature),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            );
          }).toList() ??
          [],
    );
  }

  Widget _buildReviewsSection(BuildContext context, Product product) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Reviews (${(product.rating?.count?.toInt() ?? 0) * 23})',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const Spacer(),
            TextButton(onPressed: () {}, child: const Text('See all')),
          ],
        ),
        const SizedBox(height: 12),
        _buildReviewTile(context, product),
      ],
    );
  }

  Widget _buildReviewTile(BuildContext context, Product product) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const CircleAvatar(
                  backgroundImage: CachedNetworkImageProvider(
                    'https://i.pravatar.cc/100',
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Alex Johnson',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 12),
            RatingBarIndicator(
              rating: product.rating?.count?.toDouble() ?? 0.0,
              itemBuilder: (context, _) =>
                  const Icon(Icons.star, color: Colors.amber),
              itemCount: 5,
              itemSize: 20,
            ),
            const SizedBox(height: 8),
            const Text(
              'This product exceeded my expectations! The quality is amazing and it arrived sooner than expected.',
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: List.generate(
                3,
                (index) => ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: CachedNetworkImage(
                    imageUrl: 'https://picsum.photos/80/80?random=$index',
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRelatedProductsSection(BuildContext context, Product product) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'You might also like',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 180,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: 4,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) =>
                _buildRelatedProductItem(index, context, product),
          ),
        ),
      ],
    );
  }

  Widget _buildRelatedProductItem(
    int index,
    BuildContext context,
    Product product,
  ) {
    return SizedBox(
      width: 140,
      child: Card(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
                child: Image.network(
                  'https://picsum.photos/140/120?random=$index',
                  fit: BoxFit.cover,
                  width: double.infinity,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Product ${index + 1}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '\$${((product.price ?? 0) - index * 5).toStringAsFixed(2)}',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context, Product product) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        border: Border(top: BorderSide(color: Colors.grey[300]!)),
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                icon: const Icon(Icons.shopping_bag),
                label: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Text('Add to Cart'),
                ),
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  context.read<CartProvider>().addToCart(product);
                  _snowSnackBar(context, "Added to cart!");
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  _snowSnackBar(context, "Feature coming soon!");
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Text('Buy Now'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _snowSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
    );
  }

  void _shareProduct(BuildContext context, Product product) async {
    await SharePlus.instance.share(
      ShareParams(
        text:
            'Check out this product: ${product.title}\n'
            'Price: \$${product.price?.toStringAsFixed(2)}\n'
            'Description: ${product.description}',
        subject: 'Product Details',
        sharePositionOrigin: Rect.fromLTWH(0, 0, 100, 100),
      ),
    );
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Product shared!')));
  }
}
