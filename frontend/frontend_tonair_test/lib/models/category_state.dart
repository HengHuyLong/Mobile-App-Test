import 'category.dart';

class CategoryState {
  final List<Category> categories;
  final bool isLoading;
  final String? error;
  final String search;

  CategoryState({
    required this.categories,
    required this.isLoading,
    required this.search,
    this.error,
  });

  factory CategoryState.initial() {
    return CategoryState(
      categories: [],
      isLoading: false,
      search: '',
      error: null,
    );
  }

  CategoryState copyWith({
    List<Category>? categories,
    bool? isLoading,
    String? error,
    String? search,
  }) {
    return CategoryState(
      categories: categories ?? this.categories,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      search: search ?? this.search,
    );
  }
}
