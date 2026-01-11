import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../providers/product_provider.dart';
import '../providers/category_provider.dart';
import '../models/category.dart';
import '../models/product.dart';
import '../widgets/product_form_dialog.dart';
import '../services/product_service.dart';

class ProductListScreen extends ConsumerStatefulWidget {
  const ProductListScreen({super.key});

  @override
  ConsumerState<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends ConsumerState<ProductListScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  String _sortBy = 'name';
  String _sortOrder = 'asc';
  int? _selectedCategoryId;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(productProvider.notifier).loadProducts();
      ref.read(categoryProvider.notifier).loadCategories();
    });

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        ref.read(productProvider.notifier).loadMore();
      }
    });
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), _reloadProducts);
  }

  void _reloadProducts() {
    ref
        .read(productProvider.notifier)
        .loadProducts(
          search: _searchController.text,
          categoryId: _selectedCategoryId,
          sortBy: _sortBy,
          sortOrder: _sortOrder,
        );
  }

  void _openSort(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _SortItem('A → Z', () {
            _sortBy = 'name';
            _sortOrder = 'asc';
            _reloadProducts();
          }),
          _SortItem('Z → A', () {
            _sortBy = 'name';
            _sortOrder = 'desc';
            _reloadProducts();
          }),
          _SortItem('Price: Low → High', () {
            _sortBy = 'price';
            _sortOrder = 'asc';
            _reloadProducts();
          }),
          _SortItem('Price: High → Low', () {
            _sortBy = 'price';
            _sortOrder = 'desc';
            _reloadProducts();
          }),
        ],
      ),
    );
  }

  void _confirmDelete(Product product) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Product'),
        content: Text('Delete "${product.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          GestureDetector(
            onTap: () async {
              Navigator.pop(context);
              await ProductService.deleteProduct(product.id);
              ref.read(productProvider.notifier).loadProducts();
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              color: Colors.black,
              child: const Text(
                'DELETE',
                style: TextStyle(color: Colors.white, letterSpacing: 1),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final productState = ref.watch(productProvider);
    final categoryState = ref.watch(categoryProvider);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Products'),
        backgroundColor: theme.scaffoldBackgroundColor,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.tune),
            onPressed: () => _openSort(context),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.black,
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () {
          showDialog(
            context: context,
            builder: (_) => const ProductFormDialog(),
          );
        },
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              height: 44,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.search,
                    size: 20,
                    color: theme.textTheme.bodySmall?.color,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      onChanged: _onSearchChanged,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Search products',
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            //CATEGORY DROPDOWN
            Container(
              height: 44,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<int?>(
                  isExpanded: true,
                  value: _selectedCategoryId,
                  hint: const Text('All Categories'),
                  items: [
                    const DropdownMenuItem<int?>(
                      value: null,
                      child: Text('All Categories'),
                    ),
                    ...categoryState.categories.map(
                      (Category c) => DropdownMenuItem<int?>(
                        value: c.id,
                        child: Text(c.name),
                      ),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() => _selectedCategoryId = value);
                    _reloadProducts();
                  },
                ),
              ),
            ),

            const SizedBox(height: 16),

            //  PRODUCT LIST
            Expanded(
              child: Builder(
                builder: (_) {
                  if (productState.isLoading && productState.products.isEmpty) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (productState.products.isEmpty) {
                    return const Center(child: Text('No products found'));
                  }

                  return ListView.builder(
                    controller: _scrollController,
                    itemCount:
                        productState.products.length +
                        (productState.hasMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index >= productState.products.length) {
                        return const Padding(
                          padding: EdgeInsets.all(16),
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }

                      final product = productState.products[index];

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surface,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: CachedNetworkImage(
                              imageUrl:
                                  product.imageUrl != null &&
                                      product.imageUrl!.isNotEmpty
                                  ? 'http://10.0.2.2:3000/${product.imageUrl}'
                                  : '',
                              width: 48,
                              height: 64,
                              fit: BoxFit.cover,
                              placeholder: (_, __) => Container(
                                width: 48,
                                height: 64,
                                color: theme.dividerColor,
                                child: const Icon(Icons.menu_book, size: 20),
                              ),
                              errorWidget: (_, __, ___) => Container(
                                width: 48,
                                height: 64,
                                color: theme.dividerColor,
                                child: const Icon(Icons.menu_book, size: 20),
                              ),
                            ),
                          ),
                          title: Text(product.name),
                          subtitle: Text(
                            '${product.categoryName} • \$${product.price.toStringAsFixed(2)}',
                          ),
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (_) =>
                                  ProductFormDialog(product: product),
                            );
                          },
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.black),
                            onPressed: () => _confirmDelete(product),
                          ),
                        ),
                      );
                    },
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

class _SortItem extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _SortItem(this.label, this.onTap);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(label),
      onTap: () {
        Navigator.pop(context);
        onTap();
      },
    );
  }
}
