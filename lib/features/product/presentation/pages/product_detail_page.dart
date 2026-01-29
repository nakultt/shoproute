import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../../config/theme/app_text_styles.dart';
import '../../../../config/theme/app_theme.dart';
import '../../../../core/widgets/animated_button.dart';
import '../../../shop/data/product_service.dart';
import '../../../cart/data/cart_service.dart';
import '../../../profile/data/user_service.dart';

/// Product Detail Page
class ProductDetailPage
    extends
        StatefulWidget {
  final int productId;

  const ProductDetailPage({
    super.key,
    required this.productId,
  });

  @override
  State<
    ProductDetailPage
  >
  createState() => _ProductDetailPageState();
}

class _ProductDetailPageState
    extends
        State<
          ProductDetailPage
        > {
  final _productService = ProductService();
  final _cartService = CartService();
  final _userService = UserService();

  bool _isLoading = true;
  bool _isFavorite = false;
  Map<
    String,
    dynamic
  >?
  _productData;
  List<
    dynamic
  >
  _stores = [];
  int _quantity = 1;
  bool _isAddingToCart = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<
    void
  >
  _loadData() async {
    try {
      final data = await _productService.getProductDetails(
        widget.productId,
      );
      if (mounted) {
        setState(
          () {
            _productData = data['product'];
            _stores =
                data['stores'] ??
                [];
            _isLoading = false;
          },
        );
      }
    } catch (
      e
    ) {
      if (mounted) {
        setState(
          () => _isLoading = false,
        );
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to load product: $e',
            ),
          ),
        );
      }
    }
  }

  void _toggleFavorite() async {
    setState(
      () => _isFavorite = !_isFavorite,
    );
    try {
      await _userService.toggleFavorite(
        'products',
        widget.productId,
      );
    } catch (
      e
    ) {
      if (mounted) {
        setState(
          () => _isFavorite = !_isFavorite,
        );
      }
    }
  }

  Future<
    void
  >
  _addToCart() async {
    if (_isAddingToCart) return;

    // Default to best store (first one typically sorted by price) or throw error
    if (_stores.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(
        const SnackBar(
          content: Text(
            'Product not available in any store',
          ),
        ),
      );
      return;
    }

    // For now, simple logic: pick the first available store
    // In a real app, user selects the store from the list
    final bestStore = _stores.firstWhere(
      (
        s,
      ) =>
          s['is_available'] ==
              true &&
          s['stock_count'] >
              0,
      orElse: () => null,
    );

    if (bestStore ==
        null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(
        const SnackBar(
          content: Text(
            'Out of stock in all nearby stores',
          ),
        ),
      );
      return;
    }

    setState(
      () => _isAddingToCart = true,
    );

    try {
      await _cartService.addToCart(
        productId: widget.productId,
        storeId: bestStore['id'],
        quantity: _quantity,
      );

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(
          SnackBar(
            content: Text(
              '${_productData!['name']} added to cart',
            ),
          ),
        );
      }
    } catch (
      e
    ) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to add to cart: $e',
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(
          () => _isAddingToCart = false,
        );
      }
    }
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_productData ==
        null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(
          child: Text(
            'Product not found',
          ),
        ),
      );
    }

    final product = _productData!;
    final isDark =
        Theme.of(
          context,
        ).brightness ==
        Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.backgroundDark
          : AppColors.backgroundLight,
      body: CustomScrollView(
        slivers: [
          // App Bar with Image
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            backgroundColor: isDark
                ? AppColors.surfaceDark
                : AppColors.surfaceLight,
            leading: GestureDetector(
              onTap: () => context.pop(),
              child: Container(
                margin: const EdgeInsets.all(
                  8,
                ),
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.surfaceDark
                      : Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: AppTheme.shadowSm,
                ),
                child: Icon(
                  Icons.arrow_back,
                  color: isDark
                      ? AppColors.textPrimaryDark
                      : AppColors.textPrimaryLight,
                ),
              ),
            ),
            actions: [
              GestureDetector(
                onTap: _toggleFavorite,
                child: Container(
                  margin: const EdgeInsets.all(
                    8,
                  ),
                  padding: const EdgeInsets.all(
                    8,
                  ),
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.surfaceDark
                        : Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: AppTheme.shadowSm,
                  ),
                  child: Icon(
                    _isFavorite
                        ? Icons.favorite
                        : Icons.favorite_border,
                    color: _isFavorite
                        ? AppColors.error
                        : (isDark
                              ? AppColors.textPrimaryDark
                              : AppColors.textPrimaryLight),
                  ),
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                color: AppColors.primarySurface,
                child:
                    product['image_url'] !=
                        null
                    ? Image.network(
                        product['image_url'],
                        fit: BoxFit.cover,
                        errorBuilder:
                            (
                              c,
                              e,
                              s,
                            ) => const Center(
                              child: Icon(
                                Icons.broken_image,
                                size: 60,
                              ),
                            ),
                      )
                    : Center(
                        child: Icon(
                          Icons.image,
                          size: 100,
                          color: AppColors.primary.withValues(
                            alpha: 0.3,
                          ),
                        ),
                      ),
              ),
            ),
          ),

          // Product Info
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(
                20,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category badge
                  if (product['category_name'] !=
                      null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.accentSurface,
                        borderRadius: BorderRadius.circular(
                          20,
                        ),
                      ),
                      child: Text(
                        product['category_name'],
                        style: AppTextStyles.labelMedium(
                          color: AppColors.accentDark,
                        ),
                      ),
                    ),
                  const SizedBox(
                    height: 12,
                  ),

                  // Product name
                  Text(
                    product['name'],
                    style: AppTextStyles.headlineLarge(
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : null,
                    ),
                  ),
                  const SizedBox(
                    height: 8,
                  ),

                  // Rating (Placeholder if null)
                  Row(
                    children: [
                      const Icon(
                        Icons.star,
                        color: AppColors.warning,
                        size: 18,
                      ),
                      const SizedBox(
                        width: 4,
                      ),
                      Text(
                        '0.0', // TODO: Add rating to product details response or join
                        style: AppTextStyles.labelLarge(
                          color: isDark
                              ? AppColors.textPrimaryDark
                              : null,
                        ),
                      ),
                      Text(
                        ' (0 reviews)',
                        style: AppTextStyles.bodySmall(
                          color: isDark
                              ? AppColors.textSecondaryDark
                              : null,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 16,
                  ),

                  // Description
                  Text(
                    'Description',
                    style: AppTextStyles.titleLarge(
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : null,
                    ),
                  ),
                  const SizedBox(
                    height: 8,
                  ),
                  Text(
                    product['description'] ??
                        'No description available.',
                    style: AppTextStyles.bodyMedium(
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondaryLight,
                    ),
                  ),
                  const SizedBox(
                    height: 24,
                  ),

                  // Price Comparison / Available Stores
                  Text(
                    'Available at stores',
                    style: AppTextStyles.titleLarge(
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : null,
                    ),
                  ),
                  const SizedBox(
                    height: 12,
                  ),
                  _buildStoreList(
                    isDark,
                  ),
                  const SizedBox(
                    height: 100,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(
          16,
        ),
        decoration: BoxDecoration(
          color: isDark
              ? AppColors.surfaceDark
              : AppColors.surfaceLight,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(
                alpha: 0.08,
              ),
              blurRadius: 16,
              offset: const Offset(
                0,
                -4,
              ),
            ),
          ],
        ),
        child: SafeArea(
          child: Row(
            children: [
              // Quantity selector
              Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: isDark
                        ? AppColors.borderDark
                        : AppColors.borderLight,
                  ),
                  borderRadius: BorderRadius.circular(
                    12,
                  ),
                ),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        if (_quantity >
                            1) {
                          setState(
                            () => _quantity--,
                          );
                        }
                      },
                      icon: Icon(
                        Icons.remove,
                        color: isDark
                            ? AppColors.textPrimaryDark
                            : null,
                      ),
                    ),
                    Text(
                      '$_quantity',
                      style: AppTextStyles.titleMedium(
                        color: isDark
                            ? AppColors.textPrimaryDark
                            : null,
                      ),
                    ),
                    IconButton(
                      onPressed: () => setState(
                        () => _quantity++,
                      ),
                      icon: Icon(
                        Icons.add,
                        color: isDark
                            ? AppColors.textPrimaryDark
                            : null,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(
                width: 16,
              ),
              // Add to cart button
              Expanded(
                child: AnimatedButton(
                  onPressed: _addToCart,
                  gradient: AppColors.primaryGradient,
                  child: _isAddingToCart
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(
                              Icons.shopping_cart,
                              size: 20,
                              color: Colors.white,
                            ),
                            SizedBox(
                              width: 8,
                            ),
                            Text(
                              'Add to Cart',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStoreList(
    bool isDark,
  ) {
    if (_stores.isEmpty) {
      return Text(
        'Not available nearby',
        style: AppTextStyles.bodyMedium(
          color: AppColors.error,
        ),
      );
    }

    return Column(
      children: _stores.map(
        (
          store,
        ) {
          final isAvailable =
              store['is_available'] ==
                  true &&
              (store['stock_count'] ??
                      0) >
                  0;
          return Container(
            margin: const EdgeInsets.only(
              bottom: 8,
            ),
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
              border: Border.all(
                color: isDark
                    ? AppColors.borderDark
                    : AppColors.borderLight,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.primarySurface,
                    borderRadius: BorderRadius.circular(
                      8,
                    ),
                    image:
                        store['logo_url'] !=
                            null
                        ? DecorationImage(
                            image: NetworkImage(
                              store['logo_url'],
                            ),
                          )
                        : null,
                  ),
                  child:
                      store['logo_url'] ==
                          null
                      ? const Icon(
                          Icons.store,
                          color: AppColors.primary,
                        )
                      : null,
                ),
                const SizedBox(
                  width: 12,
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        store['name'] ??
                            'Unknown Store',
                        style: AppTextStyles.titleSmall(
                          color: isDark
                              ? AppColors.textPrimaryDark
                              : null,
                        ),
                      ),
                      if (store['distance'] !=
                          null)
                        Text(
                          '${(store['distance'] / 1000).toStringAsFixed(1)} km away',
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
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '₹${store['price']}',
                      style: AppTextStyles.price(),
                    ),
                    if (!isAvailable)
                      Text(
                        'Out of Stock',
                        style: AppTextStyles.labelSmall(
                          color: AppColors.error,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          );
        },
      ).toList(),
    );
  }
}
