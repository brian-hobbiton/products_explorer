import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/product_model.dart';

class ProductService {
  static const String _baseUrl = 'https://fakestoreapi.com/products';

  static Future<List<Product>> fetchProducts() async {
    final response = await http.get(Uri.parse(_baseUrl));

    if (response.statusCode == 200) {
      final List jsonData = json.decode(response.body);
      return jsonData.map((item) => Product.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load products');
    }
  }
  static Future<List<String>> fetchCategories() async {
    final response = await http.get(Uri.parse('https://fakestoreapi.com/products/categories'));

    if (response.statusCode == 200) {
      final List categories = json.decode(response.body);
      return categories.cast<String>();
    } else {
      throw Exception('Failed to load categories');
    }
  }

}
