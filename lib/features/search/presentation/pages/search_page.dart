import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../../config/theme/app_text_styles.dart';
import '../../../../config/theme/app_theme.dart';

/// Search Page with product and store search
class SearchPage
    extends
        StatefulWidget {
  final String? initialQuery;
  final String? initialFilter;

  const SearchPage({
    super.key,
    this.initialQuery,
    this.initialFilter,
  });

  @override
  State<
    SearchPage
  >
  createState() => _SearchPageState();
}

class _SearchPageState
    extends
        State<
          SearchPage
        > {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  bool _isSearching = false;
  String _selectedFilter = 'all';

  // Sample search history
  final List<
    String
  >
  _recentSearches = [
    'organic milk',
    'fresh bread',
    'eggs',
    'chicken breast',
  ];

  // Sample trending searches
  final List<
    String
  >
  _trendingSearches = [
    '🔥 Holiday Deals',
    '🥬 Fresh Vegetables',
    '🍞 Bakery',
    '🥛 Dairy Products',
  ];

  // Sample search results
  List<
    Map<
      String,
      dynamic
    >
  >
  _productResults = [];
  List<
    Map<
      String,
      dynamic
    >
  >
  _storeResults = [];

  @override
  void initState() {
    super.initState();
    if (widget.initialQuery !=
        null) {
      _searchController.text = widget.initialQuery!;
      _performSearch(
        widget.initialQuery!,
      );
    } else if (widget.initialFilter ==
        'stores') {
      _selectedFilter = 'stores';
      // Auto-trigger search for stores (empty query implies 'all' nearby if backend supports,
      // but here we might need to simulate a generic search or just set state)
      _performSearch(
        '',
      );
    }
    WidgetsBinding.instance.addPostFrameCallback(
      (
        _,
      ) {
        _searchFocusNode.requestFocus();
      },
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _performSearch(
    String query,
  ) {
    if (query.isEmpty &&
        _selectedFilter ==
            'all') {
      setState(
        () {
          _productResults = [];
          _storeResults = [];
          _isSearching = false;
        },
      );
      return;
    }

    setState(
      () => _isSearching = true,
    );

    // Simulate API call
    Future.delayed(
      const Duration(
        milliseconds: 500,
      ),
      () {
        if (!mounted) return;
        setState(
          () {
            _isSearching = false;
            // Sample results
            _productResults = [
              {
                'id': 1,
                'name': 'Organic Fresh Milk 1L',
                'price': 4.99,
                'store': 'Fresh Mart',
                'rating': 4.5,
                'distance': '1.2 km',
                'image': '🥛',
                'in_stock': true,
              },
              {
                'id': 2,
                'name': 'Whole Wheat Bread',
                'price': 3.49,
                'store': 'QuickShop',
                'rating': 4.3,
                'distance': '0.8 km',
                'image': '🍞',
                'in_stock': true,
              },
              {
                'id': 3,
                'name': 'Free Range Eggs (12)',
                'price': 5.99,
                'store': 'Fresh Mart',
                'rating': 4.7,
                'distance': '1.2 km',
                'image': '🥚',
                'in_stock': true,
              },
              {
                'id': 4,
                'name': 'Organic Chicken Breast',
                'price': 12.99,
                'store': 'Health Foods',
                'rating': 4.6,
                'distance': '2.1 km',
                'image': '🍗',
                'in_stock': false,
              },
            ];
            _storeResults = [
              {
                'id': 1,
                'name': 'Fresh Mart',
                'rating': 4.5,
                'distance': '1.2 km',
                'products_count': 234,
                'logo': '🏪',
              },
              {
                'id': 2,
                'name': 'QuickShop',
                'rating': 4.2,
                'distance': '0.8 km',
                'products_count': 156,
                'logo': '🛒',
              },
            ];
          },
        );
      },
    );
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(
            Icons.arrow_back,
          ),
        ),
        title: _buildSearchBar(),
        titleSpacing: 0,
      ),
      body: _searchController.text.isEmpty
          ? _buildSuggestions()
          : _buildSearchResults(),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      height: 44,
      margin: const EdgeInsets.only(
        right: 16,
      ),
      child: TextField(
        controller: _searchController,
        focusNode: _searchFocusNode,
        onChanged:
            (
              value,
            ) {
              _performSearch(
                value,
              );
            },
        onSubmitted:
            (
              value,
            ) {
              if (value.isNotEmpty &&
                  !_recentSearches.contains(
                    value,
                  )) {
                setState(
                  () {
                    _recentSearches.insert(
                      0,
                      value,
                    );
                    if (_recentSearches.length >
                        10) {
                      _recentSearches.removeLast();
                    }
                  },
                );
              }
            },
        decoration: InputDecoration(
          hintText: 'Search products, stores...',
          hintStyle: AppTextStyles.bodyMedium(
            color: AppColors.textTertiaryLight,
          ),
          prefixIcon: const Icon(
            Icons.search,
            color: AppColors.textTertiaryLight,
          ),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  onPressed: () {
                    _searchController.clear();
                    _performSearch(
                      '',
                    );
                  },
                  icon: const Icon(
                    Icons.close,
                    size: 20,
                  ),
                )
              : null,
          filled: true,
          fillColor: AppColors.backgroundLight,
          contentPadding: EdgeInsets.zero,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(
              12,
            ),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _buildSuggestions() {
    return ListView(
      padding: const EdgeInsets.all(
        16,
      ),
      children: [
        // Recent searches
        if (_recentSearches.isNotEmpty) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recent Searches',
                style: AppTextStyles.titleSmall(),
              ),
              TextButton(
                onPressed: () {
                  setState(
                    () => _recentSearches.clear(),
                  );
                },
                child: const Text(
                  'Clear',
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 8,
          ),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _recentSearches.map(
              (
                search,
              ) {
                return GestureDetector(
                  onTap: () {
                    _searchController.text = search;
                    _performSearch(
                      search,
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceLight,
                      borderRadius: BorderRadius.circular(
                        20,
                      ),
                      border: Border.all(
                        color: AppColors.borderLight,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.history,
                          size: 16,
                          color: AppColors.textTertiaryLight,
                        ),
                        const SizedBox(
                          width: 8,
                        ),
                        Text(
                          search,
                          style: AppTextStyles.bodyMedium(),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ).toList(),
          ),
          const SizedBox(
            height: 24,
          ),
        ],

        // Trending searches
        Text(
          'Trending',
          style: AppTextStyles.titleSmall(),
        ),
        const SizedBox(
          height: 12,
        ),
        ...List.generate(
          _trendingSearches.length,
          (
            index,
          ) {
            return ListTile(
              onTap: () {
                final search = _trendingSearches[index]
                    .replaceAll(
                      RegExp(
                        r'[^\w\s]',
                      ),
                      '',
                    )
                    .trim();
                _searchController.text = search;
                _performSearch(
                  search,
                );
              },
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.primarySurface,
                  borderRadius: BorderRadius.circular(
                    10,
                  ),
                ),
                child: Center(
                  child: Text(
                    '${index + 1}',
                    style: AppTextStyles.titleSmall(
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),
              title: Text(
                _trendingSearches[index],
              ),
              trailing: const Icon(
                Icons.trending_up,
                color: AppColors.accent,
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildSearchResults() {
    if (_isSearching) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_productResults.isEmpty &&
        _storeResults.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.search_off,
              size: 64,
              color: AppColors.textTertiaryLight,
            ),
            const SizedBox(
              height: 16,
            ),
            Text(
              'No results found',
              style: AppTextStyles.titleMedium(),
            ),
            const SizedBox(
              height: 8,
            ),
            Text(
              'Try searching for something else',
              style: AppTextStyles.bodySmall(),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        // Filter tabs
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
          child: Row(
            children: [
              _buildFilterChip(
                'all',
                'All',
              ),
              const SizedBox(
                width: 8,
              ),
              _buildFilterChip(
                'products',
                'Products (${_productResults.length})',
              ),
              const SizedBox(
                width: 8,
              ),
              _buildFilterChip(
                'stores',
                'Stores (${_storeResults.length})',
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(
              16,
            ),
            children: [
              // Stores section
              if (_storeResults.isNotEmpty &&
                  (_selectedFilter ==
                          'all' ||
                      _selectedFilter ==
                          'stores')) ...[
                Text(
                  'Stores',
                  style: AppTextStyles.titleSmall(),
                ),
                const SizedBox(
                  height: 12,
                ),
                ..._storeResults.map(
                  (
                    store,
                  ) => _buildStoreCard(
                    store,
                  ),
                ),
                const SizedBox(
                  height: 16,
                ),
              ],
              // Products section
              if (_productResults.isNotEmpty &&
                  (_selectedFilter ==
                          'all' ||
                      _selectedFilter ==
                          'products')) ...[
                Text(
                  'Products',
                  style: AppTextStyles.titleSmall(),
                ),
                const SizedBox(
                  height: 12,
                ),
                ..._productResults.map(
                  (
                    product,
                  ) => _buildProductCard(
                    product,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChip(
    String value,
    String label,
  ) {
    final isSelected =
        _selectedFilter ==
        value;
    return GestureDetector(
      onTap: () => setState(
        () => _selectedFilter = value,
      ),
      child: AnimatedContainer(
        duration: AppTheme.animationFast,
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary
              : AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(
            20,
          ),
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : AppColors.borderLight,
          ),
        ),
        child: Text(
          label,
          style: AppTextStyles.labelMedium(
            color: isSelected
                ? Colors.white
                : AppColors.textSecondaryLight,
          ),
        ),
      ),
    );
  }

  Widget _buildStoreCard(
    Map<
      String,
      dynamic
    >
    store,
  ) {
    return Card(
      margin: const EdgeInsets.only(
        bottom: 12,
      ),
      child: ListTile(
        onTap: () => context.push(
          '/store/${store['id']}',
        ),
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: AppColors.accentSurface,
            borderRadius: BorderRadius.circular(
              12,
            ),
          ),
          child: Center(
            child: Text(
              store['logo'],
              style: const TextStyle(
                fontSize: 28,
              ),
            ),
          ),
        ),
        title: Text(
          store['name'],
          style: AppTextStyles.titleSmall(),
        ),
        subtitle: Row(
          children: [
            const Icon(
              Icons.star,
              size: 14,
              color: AppColors.warning,
            ),
            Text(
              ' ${store['rating']}',
              style: AppTextStyles.bodySmall(),
            ),
            Text(
              ' • ${store['distance']}',
              style: AppTextStyles.bodySmall(),
            ),
            Text(
              ' • ${store['products_count']} products',
              style: AppTextStyles.bodySmall(),
            ),
          ],
        ),
        trailing: const Icon(
          Icons.chevron_right,
        ),
      ),
    );
  }

  Widget _buildProductCard(
    Map<
      String,
      dynamic
    >
    product,
  ) {
    return Card(
      margin: const EdgeInsets.only(
        bottom: 12,
      ),
      child: ListTile(
        onTap: () => context.push(
          '/product/${product['id']}',
        ),
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: AppColors.primarySurface,
            borderRadius: BorderRadius.circular(
              12,
            ),
          ),
          child: Center(
            child: Text(
              product['image'],
              style: const TextStyle(
                fontSize: 28,
              ),
            ),
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                product['name'],
                style: AppTextStyles.titleSmall(),
              ),
            ),
            if (!product['in_stock'])
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 6,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: AppColors.errorLight,
                  borderRadius: BorderRadius.circular(
                    4,
                  ),
                ),
                child: Text(
                  'Out of stock',
                  style: AppTextStyles.labelSmall(
                    color: AppColors.error,
                  ),
                ),
              ),
          ],
        ),
        subtitle: Row(
          children: [
            Text(
              '\$${product['price']}',
              style: AppTextStyles.price(
                fontSize: 14,
              ),
            ),
            Text(
              ' • ${product['store']}',
              style: AppTextStyles.bodySmall(),
            ),
            Text(
              ' • ${product['distance']}',
              style: AppTextStyles.bodySmall(),
            ),
          ],
        ),
        trailing: IconButton(
          onPressed: product['in_stock']
              ? () {}
              : null,
          icon: Icon(
            Icons.add_shopping_cart,
            color: product['in_stock']
                ? AppColors.primary
                : AppColors.textTertiaryLight,
          ),
        ),
      ),
    );
  }
}
