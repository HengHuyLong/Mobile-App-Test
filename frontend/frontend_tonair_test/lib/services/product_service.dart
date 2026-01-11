import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/product.dart';
import '../services/token_storage.dart';

class ProductService {
  static const String baseUrl = 'http://10.0.2.2:3000/api/products';

  // ==========================
  // GET /products (pagination + search + sorting)
  // ==========================
  static Future<Map<String, dynamic>> getProducts({
    required int page,
    String? search,
    int? categoryId,
    String sortBy = 'name',
    String sortOrder = 'asc',
  }) async {
    final token = await TokenStorage.getToken();

    final queryParams = {
      'page': page.toString(),
      'limit': '20',
      'sort_by': sortBy,
      'sort_order': sortOrder,
    };

    if (search != null && search.trim().isNotEmpty) {
      queryParams['search'] = search.trim();
    }

    if (categoryId != null) {
      queryParams['category_id'] = categoryId.toString();
    }

    final uri = Uri.parse(baseUrl).replace(queryParameters: queryParams);

    final response = await http.get(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);

      final List productsJson = body['data'];
      final products = productsJson.map((e) => Product.fromJson(e)).toList();

      return {'products': products, 'pagination': body['pagination']};
    } else {
      throw Exception('Failed to load products');
    }
  }

  // ==========================
  // POST /products (Create)
  // ==========================
  static Future<void> createProduct({
    required String name,
    String? description,
    required double price,
    String? imageUrl,
    required int categoryId,
  }) async {
    final token = await TokenStorage.getToken();

    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'name': name,
        'description': description,
        'price': price,
        'image_url': imageUrl,
        'category_id': categoryId,
      }),
    );

    if (response.statusCode != 201) {
      final body = jsonDecode(response.body);
      throw Exception(body['message'] ?? 'Failed to create product');
    }
  }

  // ==========================
  // PUT /products/:id (Update)
  // ==========================
  static Future<void> updateProduct({
    required int id,
    required String name,
    String? description,
    required double price,
    String? imageUrl,
    required int categoryId,
  }) async {
    final token = await TokenStorage.getToken();

    final response = await http.put(
      Uri.parse('$baseUrl/$id'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'name': name,
        'description': description,
        'price': price,
        'image_url': imageUrl,
        'category_id': categoryId,
      }),
    );

    if (response.statusCode != 200) {
      final body = jsonDecode(response.body);
      throw Exception(body['message'] ?? 'Failed to update product');
    }
  }

  // ==========================
  // DELETE /products/:id
  // ==========================
  static Future<void> deleteProduct(int id) async {
    final token = await TokenStorage.getToken();

    final response = await http.delete(
      Uri.parse('$baseUrl/$id'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode != 200) {
      final body = jsonDecode(response.body);
      throw Exception(body['message'] ?? 'Failed to delete product');
    }
  }
}
