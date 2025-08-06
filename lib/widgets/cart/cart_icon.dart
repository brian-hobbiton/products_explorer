import 'package:flutter/material.dart';
import 'package:products_explorer/pages/cart_screen.dart';
import 'package:products_explorer/providers/cart_provider.dart';
import 'package:provider/provider.dart';

class CartIcon extends StatelessWidget {
  const CartIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Badge(
        label: Text(
          '${context.watch<CartProvider>().totalItems}',
          style: const TextStyle(color: Colors.white, fontSize: 12),
        ),
        child: Icon(Icons.shopping_cart_outlined),
      ),
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => CartScreen()),
        );
      },
    );
  }
}
