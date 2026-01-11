import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../providers/product_provider.dart';
import '../providers/category_provider.dart';
import '../models/category.dart';
import '../models/product.dart';

import 'category_screen.dart';
import 'product_list_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    _HomePage(),
    CategoryScreen(),
    ProductListScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        titleSpacing: 16,
        title: Image.asset('assets/images/app_logo.png', height: 120),
        backgroundColor: theme.scaffoldBackgroundColor,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: _pages[_currentIndex],
      bottomNavigationBar: _SquareBottomNav(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
      ),
    );
  }
}

/// HOME PAGE
class _HomePage extends ConsumerStatefulWidget {
  const _HomePage();

  @override
  ConsumerState<_HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<_HomePage> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  int? _selectedCategoryId;
  String _sortBy = 'name';
  String _sortOrder = 'asc';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(productProvider.notifier).loadProducts();
      ref.read(categoryProvider.notifier).loadCategories();
    });
  }

  void _reload() {
    ref
        .read(productProvider.notifier)
        .loadProducts(
          search: _searchController.text,
          categoryId: _selectedCategoryId,
          sortBy: _sortBy,
          sortOrder: _sortOrder,
        );
  }

  void _onSearchChanged(String _) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), _reload);
  }

  void _openSort(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _SortItem('Name (A → Z)', () {
                _sortBy = 'name';
                _sortOrder = 'asc';
                _reload();
              }),
              _SortItem('Name (Z → A)', () {
                _sortBy = 'name';
                _sortOrder = 'desc';
                _reload();
              }),
              _SortItem('Price (Low → High)', () {
                _sortBy = 'price';
                _sortOrder = 'asc';
                _reload();
              }),
              _SortItem('Price (High → Low)', () {
                _sortBy = 'price';
                _sortOrder = 'desc';
                _reload();
              }),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final productState = ref.watch(productProvider);
    final categoryState = ref.watch(categoryProvider);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Discover Books',
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Browse and explore your collection',
            style: theme.textTheme.bodySmall,
          ),
          const SizedBox(height: 16),

          // SEARCH
          Row(
            children: [
              Expanded(
                child: Container(
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
                            hintText: 'Search books',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: () => _openSort(context),
                child: Container(
                  height: 44,
                  width: 44,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.tune),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          SizedBox(
            height: 36,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _CategoryChip(
                  label: 'All',
                  active: _selectedCategoryId == null,
                  onTap: () {
                    setState(() => _selectedCategoryId = null);
                    _reload();
                  },
                ),
                ...categoryState.categories.map(
                  (Category c) => _CategoryChip(
                    label: c.name,
                    active: _selectedCategoryId == c.id,
                    onTap: () {
                      setState(() => _selectedCategoryId = c.id);
                      _reload();
                    },
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          Expanded(
            child: Builder(
              builder: (_) {
                if (productState.isLoading && productState.products.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (productState.products.isEmpty) {
                  return const Center(child: Text('No books found'));
                }

                return GridView.builder(
                  itemCount: productState.products.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.58,
                  ),
                  itemBuilder: (_, index) {
                    return _BookCard(product: productState.products[index]);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// BOOK CARD
class _BookCard extends StatelessWidget {
  final Product product;

  const _BookCard({required this.product});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: 0.72,
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(14),
              ),
              child: CachedNetworkImage(
                imageUrl:
                    product.imageUrl != null && product.imageUrl!.isNotEmpty
                    ? 'http://10.0.2.2:3000/${product.imageUrl}'
                    : '',
                fit: BoxFit.cover,
                placeholder: (_, __) => Container(
                  color: theme.dividerColor,
                  alignment: Alignment.center,
                  child: const Icon(Icons.menu_book, size: 36),
                ),
                errorWidget: (_, __, ___) => Container(
                  color: theme.dividerColor,
                  alignment: Alignment.center,
                  child: const Icon(Icons.menu_book, size: 36),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '\$${product.price.toStringAsFixed(2)}',
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// CATEGORY CARD
class _CategoryChip extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _CategoryChip({
    required this.label,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: active ? Colors.black : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: theme.dividerColor),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: active ? Colors.white : theme.textTheme.bodySmall?.color,
          ),
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

/// BOTTOM NAV
class _SquareBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _SquareBottomNav({required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      top: false,
      child: Container(
        height: 56,
        color: theme.colorScheme.surface,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _nav(Icons.home, 0),
            _nav(Icons.category_outlined, 1),
            _nav(Icons.inventory_2_outlined, 2),
            _nav(Icons.person_outline, 3),
          ],
        ),
      ),
    );
  }

  Widget _nav(IconData icon, int index) {
    final active = index == currentIndex;

    return GestureDetector(
      onTap: () => onTap(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 44,
        height: 36,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: active ? Colors.black : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, size: 22, color: active ? Colors.white : Colors.grey),
      ),
    );
  }
}
