import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../../config/theme/app_text_styles.dart';
import '../../../../config/theme/app_theme.dart';
import '../../../shop/data/store_service.dart';
import '../../../shop/presentation/widgets/product_card.dart';
import '../../../cart/data/cart_service.dart';

class StoreDetailPage
    extends
        StatefulWidget {
  final int storeId;

  const StoreDetailPage({
    super.key,
    required this.storeId,
  });

  @override
  State<
    StoreDetailPage
  >
  createState() => _StoreDetailPageState();
}

class _StoreDetailPageState
    extends
        State<
          StoreDetailPage
        > {
  final _storeService = StoreService();
  final _cartService = CartService();

  bool _isLoading = true;
  Map<
    String,
    dynamic
  >?
  _storeData;
  List<
    dynamic
  >
  _products = [];
  int _cartItemCount = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
    _loadCartCount();
  }

  Future<
    void
  >
  _loadCartCount() async {
    try {
      final cart = await _cartService.getCart();
      if (mounted)
        setState(
          () => _cartItemCount =
              cart['item_count'] ??
              0,
        );
    } catch (
      _
    ) {}
  }

  Future<
    void
  >
  _loadData() async {
    try {
      final data = await _storeService.getStoreDetails(
        widget.storeId,
      );
      if (mounted) {
        setState(
          () {
            _storeData = data['store']; // Assuming backend returns { store: ..., products: [...] } or checks structure
            _products =
                data['products'] ??
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
              'Failed to load store: $e',
            ),
          ),
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

    if (_storeData ==
        null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(
          child: Text(
            'Store not found',
          ),
        ),
      );
    }

    final store = _storeData!;
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
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: isDark
                ? AppColors.surfaceDark
                : AppColors.surfaceLight,
            leading: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(
                  8,
                ),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.arrow_back,
                  color: Colors.black,
                ),
              ),
              onPressed: () => context.pop(),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Image.network(
                store['image_url'] ??
                    store['logo_url'] ??
                    'https://via.placeholder.com/400',
                fit: BoxFit.cover,
                errorBuilder:
                    (
                      _,
                      __,
                      ___,
                    ) => Container(
                      color: AppColors.primarySurface,
                    ),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(
                16,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    store['name'],
                    style: AppTextStyles.headlineMedium(
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : null,
                    ),
                  ),
                  const SizedBox(
                    height: 8,
                  ),
                  Row(
                    children: [
                      const Icon(
                        Icons.star,
                        color: AppColors.warning,
                        size: 20,
                      ),
                      const SizedBox(
                        width: 4,
                      ),
                      Text(
                        '${store['rating']} (${store['review_count']} reviews)',
                        style: AppTextStyles.bodyMedium(
                          color: isDark
                              ? AppColors.textSecondaryDark
                              : null,
                        ),
                      ),
                      const Spacer(),
                      if (store['distance'] !=
                          null)
                        Text(
                          '${(store['distance'] / 1000).toStringAsFixed(1)} km away',
                          style: AppTextStyles.bodyMedium(
                            color: AppColors.primary,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(
                    height: 16,
                  ),
                  Text(
                    'Products Available Here',
                    style: AppTextStyles.titleLarge(
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : null,
                    ),
                  ),
                ],
              ),
            ),
          ),

          if (_products.isEmpty)
            SliverToBoxAdapter(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(
                    32,
                  ),
                  child: Text(
                    'No products available right now.',
                    style: AppTextStyles.bodyMedium(),
                  ),
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
              ),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.70,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                ),
                delegate: SliverChildBuilderDelegate(
                  (
                    context,
                    index,
                  ) {
                    final product = _products[index];
                    // Verify product structure has price, etc.
                    // Backend joined structure: product + sp.* (price, stock_count)
                    return ProductCard(
                      product: product,
                      onAddToCart: _loadCartCount,
                    );
                  },
                  childCount: _products.length,
                ),
              ),
            ),
          const SliverToBoxAdapter(
            child: SizedBox(
              height: 40,
            ),
          ),
        ],
      ),
    );
  }
}
