import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../../config/theme/app_text_styles.dart';
import '../../../../config/theme/app_theme.dart';
import '../../../../config/routes/app_router.dart';
import '../../../../config/constants/app_constants.dart';
import '../../../../core/widgets/loading_shimmer.dart';

/// Home Page with categories, products, and search
class HomePage
    extends
        StatefulWidget {
  const HomePage({
    super.key,
  });

  @override
  State<
    HomePage
  >
  createState() => _HomePageState();
}

class _HomePageState
    extends
        State<
          HomePage
        > {
  int _selectedCategoryIndex = 0;
  bool _isGridView = true;
  bool _isLoading = true;
  int _cartItemCount = 3;

  // Sample product data with categories
  final List<
    Map<
      String,
      dynamic
    >
  >
  _allProducts = [
    {
      'id': 0,
      'name': 'Organic Milk 1L',
      'price': '4.99',
      'store': 'Fresh Mart',
      'rating': '4.5',
      'distance': '1.2 km',
      'category': 5,
      'image': '🥛',
      'inStock': true,
    },
    {
      'id': 1,
      'name': 'Whole Wheat Bread',
      'price': '3.49',
      'store': 'QuickShop',
      'rating': '4.3',
      'distance': '0.8 km',
      'category': 6,
      'image': '🍞',
      'inStock': true,
    },
    {
      'id': 2,
      'name': 'Free Range Eggs (12)',
      'price': '5.99',
      'store': 'Fresh Mart',
      'rating': '4.7',
      'distance': '1.2 km',
      'category': 5,
      'image': '🥚',
      'inStock': true,
    },
    {
      'id': 3,
      'name': 'Chicken Breast 500g',
      'price': '12.99',
      'store': 'Health Foods',
      'rating': '4.6',
      'distance': '2.1 km',
      'category': 7,
      'image': '🍗',
      'inStock': true,
    },
    {
      'id': 4,
      'name': 'Fresh Orange Juice',
      'price': '3.99',
      'store': 'QuickShop',
      'rating': '4.4',
      'distance': '0.8 km',
      'category': 8,
      'image': '🧃',
      'inStock': true,
    },
    {
      'id': 5,
      'name': 'Organic Spinach',
      'price': '2.99',
      'store': 'Fresh Mart',
      'rating': '4.2',
      'distance': '1.2 km',
      'category': 5,
      'image': '🥬',
      'inStock': true,
    },
    {
      'id': 6,
      'name': 'Greek Yogurt',
      'price': '4.49',
      'store': 'Health Foods',
      'rating': '4.8',
      'distance': '2.1 km',
      'category': 5,
      'image': '🥛',
      'inStock': true,
    },
    {
      'id': 7,
      'name': 'Salmon Fillet',
      'price': '15.99',
      'store': 'Fresh Mart',
      'rating': '4.9',
      'distance': '1.2 km',
      'category': 7,
      'image': '🐟',
      'inStock': false,
    },
    {
      'id': 8,
      'name': 'Shampoo',
      'price': '8.99',
      'store': 'SuperStore',
      'rating': '4.1',
      'distance': '1.5 km',
      'category': 9,
      'image': '🧴',
      'inStock': true,
    },
    {
      'id': 9,
      'name': 'Cleaning Spray',
      'price': '5.49',
      'store': 'SuperStore',
      'rating': '4.0',
      'distance': '1.5 km',
      'category': 10,
      'image': '🧹',
      'inStock': true,
    },
  ];

  List<
    Map<
      String,
      dynamic
    >
  >
  get _filteredProducts {
    final selectedCategory = AppConstants.defaultCategories[_selectedCategoryIndex];
    final categoryId =
        selectedCategory['id']
            as int;

    // Special categories (0-4) show all or filtered products
    if (categoryId ==
        0) {
      // Hot Discounts - show products with high rating
      return _allProducts
          .where(
            (
              p,
            ) =>
                double.parse(
                  p['rating'],
                ) >=
                4.5,
          )
          .toList();
    } else if (categoryId ==
        1) {
      // Seasonal Offers - show random selection
      return _allProducts
          .take(
            4,
          )
          .toList();
    } else if (categoryId ==
        2) {
      // Most Bought - show all
      return _allProducts;
    } else if (categoryId ==
        3) {
      // Similar Items - show based on first product category
      return _allProducts
          .where(
            (
              p,
            ) =>
                p['category'] ==
                5,
          )
          .toList();
    } else if (categoryId ==
        4) {
      // Top Rated
      return _allProducts
          .where(
            (
              p,
            ) =>
                double.parse(
                  p['rating'],
                ) >=
                4.6,
          )
          .toList();
    }

    // Regular categories filter by category ID
    return _allProducts
        .where(
          (
            p,
          ) =>
              p['category'] ==
              categoryId,
        )
        .toList();
  }

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<
    void
  >
  _loadData() async {
    await Future.delayed(
      const Duration(
        seconds: 1,
      ),
    );
    if (mounted) {
      setState(
        () => _isLoading = false,
      );
    }
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    final isDark =
        Theme.of(
          context,
        ).brightness ==
        Brightness.dark;
    return Scaffold(
      backgroundColor: isDark
          ? AppColors.backgroundDark
          : AppColors.backgroundLight,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadData,
          color: AppColors.primary,
          child: CustomScrollView(
            slivers: [
              // Top Bar
              SliverToBoxAdapter(
                child: _buildTopBar(),
              ),
              // Categories
              SliverToBoxAdapter(
                child: _buildCategories(),
              ),
              // View Toggle
              SliverToBoxAdapter(
                child: _buildViewToggle(),
              ),
              // Products Grid/List
              _isLoading
                  ? _buildLoadingGrid()
                  : _buildProductGrid(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    final isDark =
        Theme.of(
          context,
        ).brightness ==
        Brightness.dark;
    return Padding(
      padding: const EdgeInsets.all(
        16,
      ),
      child: Row(
        children: [
          // Profile Avatar
          GestureDetector(
            onTap: () => context.go(
              AppRoutes.profile,
            ),
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: AppColors.primaryGradient,
                boxShadow: AppTheme.shadowSm,
              ),
              child: const Center(
                child: Icon(
                  Icons.person,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ),
          ),
          const SizedBox(
            width: 12,
          ),
          // Search Bar
          Expanded(
            child: GestureDetector(
              onTap: () {
                context.push(
                  AppRoutes.search,
                );
              },
              child: Container(
                height: 44,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                ),
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.surfaceDark
                      : AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(
                    12,
                  ),
                  border: Border.all(
                    color: isDark
                        ? AppColors.borderDark
                        : AppColors.borderLight,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.search,
                      color: isDark
                          ? AppColors.textTertiaryDark
                          : AppColors.textTertiaryLight,
                      size: 20,
                    ),
                    const SizedBox(
                      width: 8,
                    ),
                    Text(
                      'Search products, stores...',
                      style: AppTextStyles.bodyMedium(
                        color: isDark
                            ? AppColors.textTertiaryDark
                            : AppColors.textTertiaryLight,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(
            width: 12,
          ),
          // Cart Icon
          GestureDetector(
            onTap: () {
              context.push(
                AppRoutes.cart,
              );
            },
            child: Stack(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.surfaceDark
                        : AppColors.surfaceLight,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isDark
                          ? AppColors.borderDark
                          : AppColors.borderLight,
                    ),
                  ),
                  child: Icon(
                    Icons.shopping_cart_outlined,
                    color: isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimaryLight,
                    size: 22,
                  ),
                ),
                if (_cartItemCount >
                    0)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      padding: const EdgeInsets.all(
                        4,
                      ),
                      decoration: const BoxDecoration(
                        color: AppColors.error,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '$_cartItemCount',
                        style: AppTextStyles.badge(),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategories() {
    final isDark =
        Theme.of(
          context,
        ).brightness ==
        Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
          ),
          child: Text(
            'Categories',
            style: AppTextStyles.headlineSmall(
              color: isDark
                  ? AppColors.textPrimaryDark
                  : null,
            ),
          ),
        ),
        const SizedBox(
          height: 12,
        ),
        SizedBox(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
            ),
            physics: const BouncingScrollPhysics(),
            itemCount: AppConstants.defaultCategories.length,
            itemBuilder:
                (
                  context,
                  index,
                ) {
                  final category = AppConstants.defaultCategories[index];
                  final isSelected =
                      _selectedCategoryIndex ==
                      index;
                  return GestureDetector(
                    onTap: () => setState(
                      () => _selectedCategoryIndex = index,
                    ),
                    child: AnimatedContainer(
                      duration: AppTheme.animationFast,
                      width: 80,
                      margin: const EdgeInsets.symmetric(
                        horizontal: 4,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primary
                            : isDark
                            ? AppColors.surfaceDark
                            : AppColors.surfaceLight,
                        borderRadius: BorderRadius.circular(
                          16,
                        ),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primary
                              : isDark
                              ? AppColors.borderDark
                              : AppColors.borderLight,
                          width: isSelected
                              ? 2
                              : 1,
                        ),
                        boxShadow: isSelected
                            ? AppTheme.shadowMd
                            : null,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            category['icon'],
                            style: const TextStyle(
                              fontSize: 28,
                            ),
                          ),
                          const SizedBox(
                            height: 4,
                          ),
                          Text(
                            category['name'],
                            style: AppTextStyles.labelSmall(
                              color: isSelected
                                  ? Colors.white
                                  : isDark
                                  ? AppColors.textSecondaryDark
                                  : AppColors.textSecondaryLight,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  );
                },
          ),
        ),
      ],
    );
  }

  Widget _buildViewToggle() {
    final isDark =
        Theme.of(
          context,
        ).brightness ==
        Brightness.dark;
    return Padding(
      padding: const EdgeInsets.all(
        16,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            _selectedCategoryIndex ==
                    0
                ? 'All Products'
                : '${AppConstants.defaultCategories[_selectedCategoryIndex]['name']} Products',
            style: AppTextStyles.headlineSmall(
              color: isDark
                  ? AppColors.textPrimaryDark
                  : null,
            ),
          ),
          Row(
            children: [
              GestureDetector(
                onTap: () => setState(
                  () => _isGridView = true,
                ),
                child: Container(
                  padding: const EdgeInsets.all(
                    8,
                  ),
                  decoration: BoxDecoration(
                    color: _isGridView
                        ? AppColors.primary
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(
                      8,
                    ),
                  ),
                  child: Icon(
                    Icons.grid_view_rounded,
                    size: 20,
                    color: _isGridView
                        ? Colors.white
                        : isDark
                        ? AppColors.textTertiaryDark
                        : AppColors.textTertiaryLight,
                  ),
                ),
              ),
              const SizedBox(
                width: 8,
              ),
              GestureDetector(
                onTap: () => setState(
                  () => _isGridView = false,
                ),
                child: Container(
                  padding: const EdgeInsets.all(
                    8,
                  ),
                  decoration: BoxDecoration(
                    color: !_isGridView
                        ? AppColors.primary
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(
                      8,
                    ),
                  ),
                  child: Icon(
                    Icons.view_list_rounded,
                    size: 20,
                    color: !_isGridView
                        ? Colors.white
                        : isDark
                        ? AppColors.textTertiaryDark
                        : AppColors.textTertiaryLight,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingGrid() {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
      ),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 0.75,
        ),
        delegate: SliverChildBuilderDelegate(
          (
            context,
            index,
          ) => const ProductCardShimmer(),
          childCount: 6,
        ),
      ),
    );
  }

  Widget _buildProductGrid() {
    final products = _filteredProducts;

    if (products.isEmpty) {
      return SliverToBoxAdapter(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(
              32,
            ),
            child: Column(
              children: [
                Icon(
                  Icons.inventory_2_outlined,
                  size: 64,
                  color: AppColors.textTertiaryLight,
                ),
                const SizedBox(
                  height: 16,
                ),
                Text(
                  'No products found in this category',
                  style: AppTextStyles.bodyLarge(
                    color: AppColors.textSecondaryLight,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
      ),
      sliver: AnimationLimiter(
        child: SliverGrid(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: _isGridView
                ? 2
                : 1,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: _isGridView
                ? 0.75
                : 3,
          ),
          delegate: SliverChildBuilderDelegate(
            (
              context,
              index,
            ) {
              final product = products[index];
              return AnimationConfiguration.staggeredGrid(
                position: index,
                duration: const Duration(
                  milliseconds: 400,
                ),
                columnCount: _isGridView
                    ? 2
                    : 1,
                child: SlideAnimation(
                  verticalOffset: 50.0,
                  child: FadeInAnimation(
                    child: _isGridView
                        ? _ProductCard(
                            product: product,
                            onAddToCart: () {
                              setState(
                                () => _cartItemCount++,
                              );
                              ScaffoldMessenger.of(
                                context,
                              ).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    '${product['name']} added to cart',
                                  ),
                                  duration: const Duration(
                                    seconds: 1,
                                  ),
                                  action: SnackBarAction(
                                    label: 'View Cart',
                                    onPressed: () => context.push(
                                      AppRoutes.cart,
                                    ),
                                  ),
                                ),
                              );
                            },
                          )
                        : _ProductListTile(
                            product: product,
                            onAddToCart: () {
                              setState(
                                () => _cartItemCount++,
                              );
                              ScaffoldMessenger.of(
                                context,
                              ).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    '${product['name']} added to cart',
                                  ),
                                  duration: const Duration(
                                    seconds: 1,
                                  ),
                                  action: SnackBarAction(
                                    label: 'View Cart',
                                    onPressed: () => context.push(
                                      AppRoutes.cart,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ),
              );
            },
            childCount: products.length,
          ),
        ),
      ),
    );
  }
}

class _ProductCard
    extends
        StatelessWidget {
  final Map<
    String,
    dynamic
  >
  product;
  final VoidCallback? onAddToCart;

  const _ProductCard({
    required this.product,
    this.onAddToCart,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    final isDark =
        Theme.of(
          context,
        ).brightness ==
        Brightness.dark;
    return GestureDetector(
      onTap: () => context.push(
        '/product/${product['id']}',
      ),
      child: Container(
        decoration: BoxDecoration(
          color: isDark
              ? AppColors.surfaceDark
              : AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(
            16,
          ),
          boxShadow: AppTheme.shadowSm,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            Container(
              height: 100,
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.primarySurface.withOpacity(
                        0.3,
                      )
                    : AppColors.primarySurface,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(
                    16,
                  ),
                ),
                image:
                    product['image'] !=
                        null
                    ? DecorationImage(
                        image: NetworkImage(
                          product['image'],
                        ),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child:
                  product['image'] ==
                      null
                  ? Center(
                      child: Icon(
                        Icons.image,
                        size: 40,
                        color: AppColors.primary.withOpacity(
                          0.5,
                        ),
                      ),
                    )
                  : null,
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(
                  12,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product['name'],
                      style: AppTextStyles.titleSmall(
                        color: isDark
                            ? AppColors.textPrimaryDark
                            : null,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(
                      height: 4,
                    ),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.accentSurface,
                            borderRadius: BorderRadius.circular(
                              4,
                            ),
                          ),
                          child: Text(
                            product['store'],
                            style: AppTextStyles.labelSmall(
                              color: AppColors.accent,
                            ),
                          ),
                        ),
                        const Spacer(),
                        const Icon(
                          Icons.star,
                          size: 14,
                          color: AppColors.warning,
                        ),
                        const SizedBox(
                          width: 2,
                        ),
                        Text(
                          product['rating'],
                          style: AppTextStyles.labelSmall(
                            color: isDark
                                ? AppColors.textSecondaryDark
                                : null,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '\$${product['price']}',
                          style: AppTextStyles.price(),
                        ),
                        GestureDetector(
                          onTap: onAddToCart,
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(
                                8,
                              ),
                            ),
                            child: const Icon(
                              Icons.add,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProductListTile
    extends
        StatelessWidget {
  final Map<
    String,
    dynamic
  >
  product;
  final VoidCallback? onAddToCart;

  const _ProductListTile({
    required this.product,
    this.onAddToCart,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    final isDark =
        Theme.of(
          context,
        ).brightness ==
        Brightness.dark;
    return GestureDetector(
      onTap: () => context.push(
        '/product/${product['id']}',
      ),
      child: Container(
        padding: const EdgeInsets.all(
          12,
        ),
        decoration: BoxDecoration(
          color: isDark
              ? AppColors.surfaceDark
              : AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(
            12,
          ),
          boxShadow: AppTheme.shadowSm,
        ),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.primarySurface.withOpacity(
                        0.3,
                      )
                    : AppColors.primarySurface,
                borderRadius: BorderRadius.circular(
                  8,
                ),
                image:
                    product['image'] !=
                        null
                    ? DecorationImage(
                        image: NetworkImage(
                          product['image'],
                        ),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child:
                  product['image'] ==
                      null
                  ? Icon(
                      Icons.image,
                      color: AppColors.primary.withOpacity(
                        0.5,
                      ),
                    )
                  : null,
            ),
            const SizedBox(
              width: 12,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    product['name'],
                    style: AppTextStyles.titleSmall(
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : null,
                    ),
                  ),
                  const SizedBox(
                    height: 4,
                  ),
                  Text(
                    '${product['store']} • ${product['distance']}',
                    style: AppTextStyles.bodySmall(
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : null,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '\$${product['price']}',
                  style: AppTextStyles.price(),
                ),
                Row(
                  children: [
                    const Icon(
                      Icons.star,
                      size: 14,
                      color: AppColors.warning,
                    ),
                    Text(
                      ' ${product['rating']}',
                      style: AppTextStyles.labelSmall(
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : null,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(
              width: 8,
            ),
            GestureDetector(
              onTap: onAddToCart,
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(
                    8,
                  ),
                ),
                child: const Icon(
                  Icons.add,
                  color: Colors.white,
                  size: 18,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
