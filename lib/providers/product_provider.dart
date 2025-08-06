import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/product_model.dart';
import '../services/product_service.dart';

class ProductProvider extends ChangeNotifier {
  List<Product> _allProducts = []; // cache all fetched products
  List<Product> _visibleProducts = [];
  String? _selectedCategory;
  List<String> _categories = [];

  bool _isLoading = false;
  bool _isLoadingMore = false;
  String? _error;
  int _page = 0;
  final int _limit = 10;

  List<Product> get products => _visibleProducts;

  bool get isLoading => _isLoading;

  bool get isLoadingMore => _isLoadingMore;

  String? get error => _error;

  String? get selectedCategory => _selectedCategory;

  List<String> get categories => _categories;

  Future<void> loadProducts() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _allProducts.clear();
      final fetched = await ProductService.fetchProducts();
      await cacheProducts(fetched);

      _allProducts.addAll(fetched);
    } catch (e) {
      _allProducts = await getCachedProducts();
      _error = 'You’re offline. Showing cached data.';
    }

    _page = 0;

    List<Product> filtered = _selectedCategory == null
        ? _allProducts
        : _allProducts
              .where((product) => product.category == _selectedCategory)
              .toList();

    _visibleProducts = filtered.take(_limit).toList();

    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadMore() async {
    if (_isLoadingMore) return;

    List<Product> filtered = _selectedCategory == null
        ? _allProducts
        : _allProducts
              .where((product) => product.category == _selectedCategory)
              .toList();

    if (_visibleProducts.length >= filtered.length) return;

    _isLoadingMore = true;
    notifyListeners();

    await Future.delayed(const Duration(seconds: 1)); // simulate network delay

    _page++;
    final start = _page * _limit;
    final end = start + _limit;

    _visibleProducts.addAll(
      filtered.sublist(start, end > filtered.length ? filtered.length : end),
    );

    _isLoadingMore = false;
    notifyListeners();
  }

  Future<void> fetchCategories() async {
    _categories = await ProductService.fetchCategories();
    notifyListeners();
  }

  void toggleProductIsFavorite(Product product) {
    final index = _allProducts.indexWhere((p) => p.id == product.id);
    if (index != -1) {
      _allProducts[index].isFavorite = !_allProducts[index].isFavorite!;
      notifyListeners();
    }
  }

  void setCategory(String? category) {
    _selectedCategory = category;
    loadProducts();
  }

  Future<void> cacheProducts(List<Product> products) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = products
        .map(
          (e) => jsonEncode({
            'id': e.id,
            'title': e.title,
            'description': e.description,
            'image': e.image,
            'price': e.price,
            'rating': e.rating,
          }),
        )
        .toList();

    await prefs.setStringList('cachedProducts', jsonList);
  }

  Future<List<Product>> getCachedProducts() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = prefs.getStringList('cachedProducts') ?? [];
    return jsonList.map((e) => Product.fromJson(jsonDecode(e))).toList();
  }

  void refresh() {
    loadProducts();
  }
}
