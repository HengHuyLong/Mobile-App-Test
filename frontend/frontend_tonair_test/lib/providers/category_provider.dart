import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/category_state.dart';
import '../services/category_service.dart';

final categoryProvider = StateNotifierProvider<CategoryNotifier, CategoryState>(
  (ref) {
    return CategoryNotifier();
  },
);

class CategoryNotifier extends StateNotifier<CategoryState> {
  CategoryNotifier() : super(CategoryState.initial());

  Future<void> loadCategories({String search = ''}) async {
    state = state.copyWith(isLoading: true, error: null, search: search);

    try {
      final categories = await CategoryService.getCategories(search: search);

      state = state.copyWith(categories: categories, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  // CREATE
  Future<void> createCategory({
    required String name,
    String? description,
  }) async {
    try {
      await CategoryService.createCategory(
        name: name,
        description: description,
      );

      // Refresh with last search
      await loadCategories(search: state.search);
    } catch (e) {
      rethrow;
    }
  }

  // UPDATE
  Future<void> updateCategory({
    required int id,
    required String name,
    String? description,
  }) async {
    try {
      await CategoryService.updateCategory(
        id: id,
        name: name,
        description: description,
      );

      await loadCategories(search: state.search);
    } catch (e) {
      rethrow;
    }
  }

  // DELETE
  Future<void> deleteCategory(int id) async {
    try {
      await CategoryService.deleteCategory(id);

      await loadCategories(search: state.search);
    } catch (e) {
      rethrow;
    }
  }
}
