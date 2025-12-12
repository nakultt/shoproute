import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../../config/theme/app_text_styles.dart';
import '../../../../config/theme/app_theme.dart';
import '../../../../core/widgets/animated_button.dart';

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
  int _quantity = 1;
  bool _isFavorite = false;

  @override
  Widget build(
    BuildContext context,
  ) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: CustomScrollView(
        slivers: [
          // App Bar with Image
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            backgroundColor: AppColors.surfaceLight,
            leading: GestureDetector(
              onTap: () => context.pop(),
              child: Container(
                margin: const EdgeInsets.all(
                  8,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: AppTheme.shadowSm,
                ),
                child: const Icon(
                  Icons.arrow_back,
                  color: AppColors.textPrimaryLight,
                ),
              ),
            ),
            actions: [
              GestureDetector(
                onTap: () => setState(
                  () => _isFavorite = !_isFavorite,
                ),
                child: Container(
                  margin: const EdgeInsets.all(
                    8,
                  ),
                  padding: const EdgeInsets.all(
                    8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: AppTheme.shadowSm,
                  ),
                  child: Icon(
                    _isFavorite
                        ? Icons.favorite
                        : Icons.favorite_border,
                    color: _isFavorite
                        ? AppColors.error
                        : AppColors.textPrimaryLight,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  // TODO: Share product
                },
                child: Container(
                  margin: const EdgeInsets.only(
                    right: 16,
                    top: 8,
                    bottom: 8,
                  ),
                  padding: const EdgeInsets.all(
                    8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: AppTheme.shadowSm,
                  ),
                  child: const Icon(
                    Icons.share,
                    color: AppColors.textPrimaryLight,
                  ),
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                color: AppColors.primarySurface,
                child: Center(
                  child: Icon(
                    Icons.image,
                    size: 100,
                    color: AppColors.primary.withOpacity(
                      0.3,
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
                  // Store badge
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
                      '🏪 Fresh Mart',
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
                    'Organic Fresh Milk 1L',
                    style: AppTextStyles.headlineLarge(),
                  ),
                  const SizedBox(
                    height: 8,
                  ),

                  // Rating & Distance
                  Row(
                    children: [
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
                            '4.5',
                            style: AppTextStyles.labelLarge(),
                          ),
                          Text(
                            ' (234 reviews)',
                            style: AppTextStyles.bodySmall(),
                          ),
                        ],
                      ),
                      const SizedBox(
                        width: 16,
                      ),
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on,
                            color: AppColors.textTertiaryLight,
                            size: 18,
                          ),
                          const SizedBox(
                            width: 4,
                          ),
                          Text(
                            '2.3 km away',
                            style: AppTextStyles.bodySmall(),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 16,
                  ),

                  // Price
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '\$4.99',
                        style: AppTextStyles.price(
                          fontSize: 28,
                        ),
                      ),
                      const SizedBox(
                        width: 8,
                      ),
                      Text(
                        '\$6.99',
                        style: AppTextStyles.priceStrikethrough(),
                      ),
                      const SizedBox(
                        width: 8,
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.errorLight,
                          borderRadius: BorderRadius.circular(
                            6,
                          ),
                        ),
                        child: Text(
                          '-29%',
                          style: AppTextStyles.labelSmall(
                            color: AppColors.error,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 12,
                  ),

                  // Availability
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.successLight,
                      borderRadius: BorderRadius.circular(
                        8,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.check_circle,
                          color: AppColors.success,
                          size: 16,
                        ),
                        const SizedBox(
                          width: 6,
                        ),
                        Text(
                          '12 in stock',
                          style: AppTextStyles.labelMedium(
                            color: AppColors.success,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 24,
                  ),

                  // Description
                  Text(
                    'Description',
                    style: AppTextStyles.titleLarge(),
                  ),
                  const SizedBox(
                    height: 8,
                  ),
                  Text(
                    'Fresh organic whole milk from grass-fed cows. Rich in calcium and essential vitamins. Perfect for your daily nutrition needs.',
                    style: AppTextStyles.bodyMedium(
                      color: AppColors.textSecondaryLight,
                    ),
                  ),
                  const SizedBox(
                    height: 24,
                  ),

                  // Price Comparison
                  Text(
                    'Available at other stores',
                    style: AppTextStyles.titleLarge(),
                  ),
                  const SizedBox(
                    height: 12,
                  ),
                  _buildStoreComparison(),
                  const SizedBox(
                    height: 100,
                  ), // Space for bottom bar
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
          color: AppColors.surfaceLight,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(
                0.08,
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
                    color: AppColors.borderLight,
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
                            1)
                          setState(
                            () => _quantity--,
                          );
                      },
                      icon: const Icon(
                        Icons.remove,
                      ),
                    ),
                    Text(
                      '$_quantity',
                      style: AppTextStyles.titleMedium(),
                    ),
                    IconButton(
                      onPressed: () => setState(
                        () => _quantity++,
                      ),
                      icon: const Icon(
                        Icons.add,
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
                  onPressed: () {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Added to cart!',
                        ),
                      ),
                    );
                  },
                  gradient: AppColors.primaryGradient,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.shopping_cart,
                        size: 20,
                        color: Colors.white,
                      ),
                      const SizedBox(
                        width: 8,
                      ),
                      const Text(
                        'Add to Cart',
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

  Widget _buildStoreComparison() {
    final stores = [
      {
        'name': 'SuperMart',
        'price': '5.49',
        'distance': '3.1',
      },
      {
        'name': 'QuickShop',
        'price': '5.29',
        'distance': '4.5',
      },
      {
        'name': 'Value Store',
        'price': '5.99',
        'distance': '1.8',
      },
    ];

    return Column(
      children: stores
          .map(
            (
              store,
            ) => Container(
              margin: const EdgeInsets.only(
                bottom: 8,
              ),
              padding: const EdgeInsets.all(
                12,
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
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.primarySurface,
                      borderRadius: BorderRadius.circular(
                        8,
                      ),
                    ),
                    child: const Icon(
                      Icons.store,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(
                    width: 12,
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          store['name']!,
                          style: AppTextStyles.titleSmall(),
                        ),
                        Text(
                          '${store['distance']} km away',
                          style: AppTextStyles.bodySmall(),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '\$${store['price']}',
                    style: AppTextStyles.price(),
                  ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }
}
