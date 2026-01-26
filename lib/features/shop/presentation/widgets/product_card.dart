import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../../config/theme/app_text_styles.dart';
import '../../../../config/theme/app_theme.dart';
import '../../../profile/data/user_service.dart';
import '../../../cart/data/cart_service.dart';

class ProductCard
    extends
        StatefulWidget {
  final Map<
    String,
    dynamic
  >
  product;
  final VoidCallback? onAddToCart;
  final bool isGridView;

  const ProductCard({
    super.key,
    required this.product,
    this.onAddToCart,
    this.isGridView = true,
  });

  @override
  State<
    ProductCard
  >
  createState() => _ProductCardState();
}

class _ProductCardState
    extends
        State<
          ProductCard
        > {
  final _userService = UserService();
  final _cartService = CartService();
  bool _isFavorite = false;
  bool _isAddingToCart = false;

  void _toggleFavorite() async {
    setState(
      () => _isFavorite = !_isFavorite,
    );
    try {
      await _userService.toggleFavorite(
        'products',
        widget.product['id'],
      );
    } catch (
      e
    ) {
      if (mounted)
        setState(
          () => _isFavorite = !_isFavorite,
        );
    }
  }

  Future<
    void
  >
  _addToCart() async {
    if (_isAddingToCart) return;

    final storeId = widget.product['store_id'];
    if (storeId ==
        null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(
        const SnackBar(
          content: Text(
            'Product not available in nearby stores',
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
        productId: widget.product['id'],
        storeId: storeId,
      );

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(
          SnackBar(
            content: Text(
              '${widget.product['name']} added to cart',
            ),
          ),
        );
        widget.onAddToCart?.call();
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
      if (mounted)
        setState(
          () => _isAddingToCart = false,
        );
    }
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    if (widget.isGridView) {
      return _buildGridView(
        context,
      );
    }
    return _buildListView(
      context,
    );
  }

  Widget _buildGridView(
    BuildContext context,
  ) {
    final isDark =
        Theme.of(
          context,
        ).brightness ==
        Brightness.dark;
    final isAvailable =
        widget.product['is_available'] !=
        false; // Default to true if null

    return GestureDetector(
      onTap: () => context.push(
        '/product/${widget.product['id']}',
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
            Stack(
              children: [
                Container(
                  height: 100,
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.primarySurface.withValues(
                            alpha: 0.3,
                          )
                        : AppColors.primarySurface,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(
                        16,
                      ),
                    ),
                    image:
                        widget.product['image_url'] !=
                            null
                        ? DecorationImage(
                            image: NetworkImage(
                              widget.product['image_url'],
                            ),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child:
                      widget.product['image_url'] ==
                          null
                      ? Center(
                          child: Icon(
                            Icons.image,
                            size: 40,
                            color: AppColors.primary.withValues(
                              alpha: 0.5,
                            ),
                          ),
                        )
                      : null,
                ),
                if (!isAvailable)
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(
                          alpha: 0.5,
                        ),
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(
                            16,
                          ),
                        ),
                      ),
                      child: Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.error,
                            borderRadius: BorderRadius.circular(
                              4,
                            ),
                          ),
                          child: Text(
                            'OUT OF STOCK',
                            style: AppTextStyles.badge(),
                          ),
                        ),
                      ),
                    ),
                  ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: GestureDetector(
                    onTap: _toggleFavorite,
                    child: Container(
                      padding: const EdgeInsets.all(
                        4,
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
                        size: 16,
                        color: _isFavorite
                            ? AppColors.error
                            : AppColors.textTertiaryLight,
                      ),
                    ),
                  ),
                ),
              ],
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
                      widget.product['name'],
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

                    if (widget.product['brand'] !=
                        null)
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
                          widget.product['brand'],
                          style: AppTextStyles.labelSmall(
                            color: AppColors.accent,
                          ),
                        ),
                      ),

                    const Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          widget.product['price'] !=
                                  null
                              ? '₹${widget.product['price']}'
                              : widget.product['min_price'] !=
                                    null
                              ? 'From ₹${widget.product['min_price']}'
                              : 'View Options',
                          style: AppTextStyles.price().copyWith(
                            fontSize:
                                widget.product['price'] ==
                                    null
                                ? 12
                                : 14,
                          ),
                        ),

                        GestureDetector(
                          onTap: isAvailable
                              ? _addToCart
                              : null,
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: !isAvailable
                                  ? AppColors.textTertiaryLight.withValues(
                                      alpha: 0.1,
                                    )
                                  : AppColors.primary,
                              borderRadius: BorderRadius.circular(
                                8,
                              ),
                            ),
                            child: !isAvailable
                                ? const Icon(
                                    Icons.remove_shopping_cart,
                                    color: AppColors.textTertiaryLight,
                                    size: 18,
                                  )
                                : _isAddingToCart
                                ? const Padding(
                                    padding: EdgeInsets.all(
                                      8.0,
                                    ),
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Icon(
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

  Widget _buildListView(
    BuildContext context,
  ) {
    // Reusing grid view logic for simplicity as per previous state
    return _buildGridView(
      context,
    );
  }
}
