import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/product.dart';

import '../services/product_service.dart';

class ProductState {
  final List<Product> products;
  final bool isLoading;
  final int page;
  final int totalPages;
  final bool hasMore;
  final String search;
  final int? categoryId;
  final String sortBy;
  final String sortOrder;

  ProductState({
    required this.products,
    required this.isLoading,
    required this.page,
    required this.totalPages,
    required this.hasMore,
    required this.search,
    required this.categoryId,
    required this.sortBy,
    required this.sortOrder,
  });

  factory ProductState.initial() {
    return ProductState(
      products: [],
      isLoading: false,
      page: 1,
      totalPages: 1,
      hasMore: true,
      search: '',
      categoryId: null,
      sortBy: 'name',
      sortOrder: 'asc',
    );
  }

  ProductState copyWith({
    List<Product>? products,
    bool? isLoading,
    int? page,
    int? totalPages,
    bool? hasMore,
    String? search,
    int? categoryId,
    String? sortBy,
    String? sortOrder,
  }) {
    return ProductState(
      products: products ?? this.products,
      isLoading: isLoading ?? this.isLoading,
      page: page ?? this.page,
      totalPages: totalPages ?? this.totalPages,
      hasMore: hasMore ?? this.hasMore,
      search: search ?? this.search,
      categoryId: categoryId ?? this.categoryId,
      sortBy: sortBy ?? this.sortBy,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }
}

final productProvider = StateNotifierProvider<ProductNotifier, ProductState>((
  ref,
) {
  return ProductNotifier();
});

class ProductNotifier extends StateNotifier<ProductState> {
  ProductNotifier() : super(ProductState.initial());

  // LOAD FIRST PAGE
  Future<void> loadProducts({
    String search = '',
    int? categoryId,
    String sortBy = 'name',
    String sortOrder = 'asc',
  }) async {
    state = state.copyWith(
      isLoading: true,
      page: 1,
      products: [],
      search: search,
      categoryId: categoryId,
      sortBy: sortBy,
      sortOrder: sortOrder,
    );

    final result = await ProductService.getProducts(
      page: 1,
      search: search,
      categoryId: categoryId,
      sortBy: sortBy,
      sortOrder: sortOrder,
    );

    final pagination = result['pagination'];

    state = state.copyWith(
      products: result['products'],
      isLoading: false,
      page: 1,
      totalPages: pagination['totalPages'],
      hasMore: 1 < pagination['totalPages'],
    );
  }

  // LOAD NEXT PAGE
  Future<void> loadMore() async {
    if (state.isLoading || !state.hasMore) return;

    final nextPage = state.page + 1;
    state = state.copyWith(isLoading: true);

    final result = await ProductService.getProducts(
      page: nextPage,
      search: state.search,
      categoryId: state.categoryId,
      sortBy: state.sortBy,
      sortOrder: state.sortOrder,
    );

    final pagination = result['pagination'];

    state = state.copyWith(
      products: [...state.products, ...result['products']],
      isLoading: false,
      page: nextPage,
      hasMore: nextPage < pagination['totalPages'],
    );
  }
}
