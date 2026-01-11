import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/category.dart';
import '../services/token_storage.dart';

class CategoryService {
  static const String baseUrl = 'http://10.0.2.2:3000/api/categories';

  // GET /categories (with search)
  static Future<List<Category>> getCategories({String? search}) async {
    final token = await TokenStorage.getToken();

    Uri uri = Uri.parse(baseUrl);

    if (search != null && search.trim().isNotEmpty) {
      uri = uri.replace(queryParameters: {'search': search.trim()});
    }

    final response = await http.get(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      final List list = body['data'];

      return list.map((e) => Category.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load categories');
    }
  }

  // ==========================
  // POST /categories
  // ==========================
  static Future<void> createCategory({
    required String name,
    String? description,
  }) async {
    final token = await TokenStorage.getToken();

    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'name': name, 'description': description}),
    );

    if (response.statusCode != 201) {
      final body = jsonDecode(response.body);
      throw Exception(body['message'] ?? 'Failed to create category');
    }
  }

  // ==========================
  // PUT /categories/:id
  // ==========================
  static Future<void> updateCategory({
    required int id,
    required String name,
    String? description,
  }) async {
    final token = await TokenStorage.getToken();

    final response = await http.put(
      Uri.parse('$baseUrl/$id'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'name': name, 'description': description}),
    );

    if (response.statusCode != 200) {
      final body = jsonDecode(response.body);
      throw Exception(body['message'] ?? 'Failed to update category');
    }
  }

  // ==========================
  // DELETE /categories/:id
  // ==========================
  static Future<void> deleteCategory(int id) async {
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
      throw Exception(body['message'] ?? 'Failed to delete category');
    }
  }
}
