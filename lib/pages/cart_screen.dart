import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:products_explorer/models/cart_item.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
import 'product_detail_page.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Consumer<CartProvider>(
          builder: (context, cart, _) => Text(
            'My Cart (${cart.totalItems})',
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () => _clearCartDialog(context),
          ),
        ],
      ),
      body: Consumer<CartProvider>(
        builder: (context, cart, _) {
          if (cart.items.isEmpty) {
            return _buildEmptyCart(context);
          }
          return Column(
            children: [
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  separatorBuilder: (_, __) => const SizedBox(height: 16),
                  itemCount: cart.items.length,
                  itemBuilder: (context, index) {
                    final item = cart.items.values.toList()[index];
                    return _buildCartItem(context, item);
                  },
                ),
              ),
              _buildBottomSummary(context, cart),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCartItem(BuildContext context, CartItem item) {
    return Dismissible(
      key: Key(item.product.id.toString()),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: Colors.red,
        child: const Icon(Icons.delete, color: Colors.white, size: 30),
      ),
      confirmDismiss: (direction) async {
        return await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Remove Item'),
            content: const Text(
              'Are you sure you want to remove this item from your cart?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('CANCEL'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text(
                  'REMOVE',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
        );
      },
      onDismissed: (direction) {
        Provider.of<CartProvider>(
          context,
          listen: false,
        ).removeItem(item.product.id!.toInt());
      },
      child: InkWell(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ProductDetailPage(productId: item.product.id!.toInt()),
          ),
        ),
        child: Card(
          margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product Image
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: CachedNetworkImage(
                    imageUrl:
                        item.product.image ??
                        "https://picsum.photos/80/80?random=${item.product.id}",
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      color: Colors.grey[200],
                      child: const Center(
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: Colors.grey[200],
                      child: const Icon(Icons.broken_image),
                    ),
                  ),
                ),
                const SizedBox(width: 16),

                // Product Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.product.title ?? "No Title",
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'K${item.product.price?.toStringAsFixed(2)}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Quantity Controls
                      Row(
                        children: [
                          _buildQuantityButton(
                            icon: Icons.remove,
                            onPressed: () {
                              if (item.quantity > 1) {
                                Provider.of<CartProvider>(
                                  context,
                                  listen: false,
                                ).updateQuantity(item.product, item.quantity - 1);
                              }
                            },
                            color: item.quantity > 1 ? null : Colors.grey[300],
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: Text(
                              item.quantity.toString(),
                              style: const TextStyle(fontSize: 16),
                            ),
                          ),
                          _buildQuantityButton(
                            icon: Icons.add,
                            onPressed: () {
                              Provider.of<CartProvider>(
                                context,
                                listen: false,
                              ).updateQuantity(item.product, item.quantity + 1);
                            },
                          ),
                          const Spacer(),
                          Text(
                            'K${(item.quantity * (item.product.price ?? 0)).toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuantityButton({
    required IconData icon,
    required VoidCallback onPressed,
    Color? color,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: color ?? Colors.grey[200],
        shape: BoxShape.circle,
      ),
      child: IconButton(
        icon: Icon(icon, size: 18),
        onPressed: onPressed,
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(),
        iconSize: 18,
      ),
    );
  }

  Widget _buildBottomSummary(BuildContext context, CartProvider cart) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Subtotal', style: Theme.of(context).textTheme.bodyLarge),
                Text(
                  'K${cart.totalPrice.toStringAsFixed(2)}',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Shipping', style: Theme.of(context).textTheme.bodyLarge),
                Text(
                  'K${cart.totalPrice > 50 ? '0.00' : '5.99'}',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ],
            ),
            const Divider(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                Text(
                  'K${(cart.totalPrice + (cart.totalPrice > 50 ? 0 : 5.99)).toStringAsFixed(2)}',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SafeArea(
              child: SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => _checkout(context),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('PROCEED TO CHECKOUT'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyCart(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.remove_shopping_cart_outlined, size: 30),
          const SizedBox(height: 24),
          const Text(
            'Your cart is empty',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 48),
            child: Text(
              'Looks like you haven\'t added anything to your cart yet',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('SHOP NOW'),
          ),
        ],
      ),
    );
  }

  void _clearCartDialog(BuildContext context) {
    final cart = Provider.of<CartProvider>(context, listen: false);
    if (cart.items.isEmpty) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Cart'),
        content: const Text(
          'Are you sure you want to remove all items from your cart?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () {
              cart.clearCart();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Cart cleared successfully')),
              );
            },
            child: const Text('CLEAR', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _checkout(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Checkout functionality coming soon!')),
    );
  }
}
