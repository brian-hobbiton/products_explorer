import 'package:flutter/material.dart';
import 'package:products_explorer/pages/cart_screen.dart';
import 'package:products_explorer/providers/theme_provider.dart';
import 'package:products_explorer/widgets/cart/cart_icon.dart';
import 'package:provider/provider.dart';
import '../providers/product_provider.dart';
import '../widgets/products/product_card.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    final provider = Provider.of<ProductProvider>(context, listen: false);
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      provider.loadProducts();
      provider.fetchCategories();
    });
    _scrollController = ScrollController();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 100) {
        provider.loadMore();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProductProvider>();
    final themeProvider = context.watch<ThemeProvider>();
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Product Explorer',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        actions: [
          CartIcon(),
          IconButton(
            onPressed: () {
              themeProvider.toggleTheme();
            },
            icon: Icon(
              themeProvider.isDarkMode
                  ? Icons.light_mode_outlined
                  : Icons.dark_mode_outlined,
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => provider.refresh(),
        child: Column(
          children: [
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 8,
                ),
                child: Row(
                  spacing: 10,
                  children: [
                    if (provider.categories.isNotEmpty)
                      ChoiceChip(
                        label: Text("All"),
                        selected: provider.selectedCategory == null,
                        onSelected: (value) {
                          provider.setCategory(null);
                        },
                      ),
                    ...provider.categories.map(
                      (e) => ChoiceChip(
                        onSelected: (value) {
                          provider.setCategory(e);
                        },
                        label: Text(e),
                        selected: provider.selectedCategory == e,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: Builder(
                builder: (context) {
                  if (provider.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (provider.error != null) {
                    if (!provider.error!.contains('offline')) {
                      return Center(child: Text('Error: ${provider.error}'));
                    }
                  } else if (provider.products.isEmpty) {
                    return const Center(child: Text('No products available.'));
                  }

                  return Column(
                    children: [
                      if (provider.error != null &&
                          provider.error!.contains('offline'))
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(
                            provider.error!,
                            style: const TextStyle(color: Colors.red),
                          ),
                        ),
                      Expanded(
                        child: GridView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.all(12),
                          gridDelegate:
                              const SliverGridDelegateWithMaxCrossAxisExtent(
                                maxCrossAxisExtent: 200,
                                mainAxisExtent: 285,
                                crossAxisSpacing: 8,
                                mainAxisSpacing: 8,
                              ),
                          itemCount: provider.products.length,
                          itemBuilder: (context, index) {
                            final product = provider.products[index];
                            return ProductCard(productId: product.id!.toInt());
                          },
                        ),
                      ),
                      if (provider.isLoadingMore)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          child: CircularProgressIndicator(),
                        ),
                    ],
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
