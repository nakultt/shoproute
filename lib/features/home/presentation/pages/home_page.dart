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
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
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
                // TODO: Navigate to search page
              },
              child: Container(
                height: 44,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                ),
                decoration: BoxDecoration(
                  color: AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(
                    12,
                  ),
                  border: Border.all(
                    color: AppColors.borderLight,
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.search,
                      color: AppColors.textTertiaryLight,
                      size: 20,
                    ),
                    const SizedBox(
                      width: 8,
                    ),
                    Text(
                      'Search products, stores...',
                      style: AppTextStyles.bodyMedium(
                        color: AppColors.textTertiaryLight,
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
          Stack(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.surfaceLight,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.borderLight,
                  ),
                ),
                child: const Icon(
                  Icons.shopping_cart_outlined,
                  color: AppColors.textPrimaryLight,
                  size: 22,
                ),
              ),
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
                    '3',
                    style: AppTextStyles.badge(),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCategories() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
          ),
          child: Text(
            'Categories',
            style: AppTextStyles.headlineSmall(),
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
                            : AppColors.surfaceLight,
                        borderRadius: BorderRadius.circular(
                          16,
                        ),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primary
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
    return Padding(
      padding: const EdgeInsets.all(
        16,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Products',
            style: AppTextStyles.headlineSmall(),
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
    // Sample product data
    final products = List.generate(
      10,
      (
        index,
      ) => {
        'id': index,
        'name': 'Product ${index + 1}',
        'price':
            (9.99 +
                    index *
                        2)
                .toStringAsFixed(
                  2,
                ),
        'store': 'Store ${index % 3 + 1}',
        'rating':
            (3.5 +
                    (index %
                            3) *
                        0.5)
                .toStringAsFixed(
                  1,
                ),
        'distance': '${(0.5 + index * 0.3).toStringAsFixed(1)} km',
      },
    );

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
                          )
                        : _ProductListTile(
                            product: product,
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

  const _ProductCard({
    required this.product,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return GestureDetector(
      onTap: () => context.push(
        '/product/${product['id']}',
      ),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(
            16,
          ),
          boxShadow: AppTheme.shadowSm,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image placeholder
            Container(
              height: 100,
              decoration: BoxDecoration(
                color: AppColors.primarySurface,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(
                    16,
                  ),
                ),
              ),
              child: Center(
                child: Icon(
                  Icons.image,
                  size: 40,
                  color: AppColors.primary.withOpacity(
                    0.5,
                  ),
                ),
              ),
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
                      style: AppTextStyles.titleSmall(),
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
                        Icon(
                          Icons.star,
                          size: 14,
                          color: AppColors.warning,
                        ),
                        const SizedBox(
                          width: 2,
                        ),
                        Text(
                          product['rating'],
                          style: AppTextStyles.labelSmall(),
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
                        Container(
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

  const _ProductListTile({
    required this.product,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return GestureDetector(
      onTap: () => context.push(
        '/product/${product['id']}',
      ),
      child: Container(
        padding: const EdgeInsets.all(
          12,
        ),
        decoration: BoxDecoration(
          color: AppColors.surfaceLight,
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
                color: AppColors.primarySurface,
                borderRadius: BorderRadius.circular(
                  8,
                ),
              ),
              child: Icon(
                Icons.image,
                color: AppColors.primary.withOpacity(
                  0.5,
                ),
              ),
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
                    style: AppTextStyles.titleSmall(),
                  ),
                  const SizedBox(
                    height: 4,
                  ),
                  Text(
                    '${product['store']} • ${product['distance']}',
                    style: AppTextStyles.bodySmall(),
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
                    Icon(
                      Icons.star,
                      size: 14,
                      color: AppColors.warning,
                    ),
                    Text(
                      ' ${product['rating']}',
                      style: AppTextStyles.labelSmall(),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
