import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:geolocator/geolocator.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../../config/theme/app_text_styles.dart';
import '../../../../config/theme/app_theme.dart';
import '../../../../config/routes/app_router.dart';
import '../../../../config/constants/app_constants.dart';
import '../../../../core/widgets/loading_shimmer.dart';
import '../../../shop/data/store_service.dart';
import '../../../shop/data/product_service.dart';
import '../../../shop/presentation/widgets/store_card.dart';
import '../../../shop/presentation/widgets/product_card.dart';
import '../../../cart/data/cart_service.dart';

/// Home Page with categories, products, and search
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedCategoryIndex = 0;
  bool _isGridView = true;
  bool _isLoading = true;
  int _cartItemCount = 0;

  final _storeService = StoreService();
  final _productService = ProductService();
  final _cartService = CartService();

  List<dynamic> _stores = [];
  List<dynamic> _products = [];
  Position? _currentPosition;
  // String _distanceText = 'Locating...';

  @override
  void initState() {
    super.initState();
    _loadData();
    _loadCartCount();
  }

  Future<void> _loadCartCount() async {
    try {
      final cart = await _cartService.getCart();
      if (mounted) {
        setState(() {
          _cartItemCount = cart['item_count'] ?? 0;
        });
      }
    } catch (_) {
      // Silent error for cart count
    }
  }

  Future<void> _loadData() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      // 1. Get Location
      await _getCurrentLocation();

      // 2. Fetch Data
      final lat = _currentPosition?.latitude ?? 11.0168; // Default Coimbatore
      final lng = _currentPosition?.longitude ?? 76.9558;

      final storesFuture = _storeService.getNearbyStores(lat: lat, lng: lng);
      final productsFuture = _productService.getProducts(page: 1);

      final results = await Future.wait([storesFuture, productsFuture]);

      if (mounted) {
        setState(() {
          _stores = results[0];
          _products = results[1];
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading home data: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to load data: $e')));
      }
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          // setState(
          //   () => _distanceText = 'Location denied',
          // );
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        // setState(
        //   () => _distanceText = 'Location denied',
        // );
        return;
      }

      final position = await Geolocator.getCurrentPosition();
      if (mounted) {
        setState(() {
          _currentPosition = position;
        });
      }
    } catch (e) {
      debugPrint('Error looking up location: $e');
    }
  }

  List<dynamic> get _filteredProducts {
    // 0: All Products (Hot Discounts for demo)
    // 1-N: Specific Categories
    // Currently, our seed categories are ID 1-5.
    // The UI 'selectedCategoryIndex' maps to AppConstants.defaultCategories list.

    if (_products.isEmpty) return [];

    final selectedCategory =
        AppConstants.defaultCategories[_selectedCategoryIndex];
    // final categoryName = selectedCategory['name'];
    final categoryId =
        selectedCategory['id']
            as int; // This might be a mock ID, need to align with DB

    // Special "All" tab or specific logic
    if (_selectedCategoryIndex == 0) {
      return _products;
    }

    // Aligning UI category index with DB Category ID for now.
    // In seed: 1=Fruits, 2=Dairy, 3=Grocery, 4=Bakery, 5=Beverages.
    // AppConstants might strictly match this or we filter by string matching if IDs don't sync.
    // Let's filter by matching DB `category_id` to the index (offset by 1 if needed) or name.
    // The API returns `category_name`.

    // Simple filter by name matching for robustness
    if (categoryId == 0) return _products; // "All"

    return _products.where((p) {
      // Check if API response's category_id matches the UI expected ID or Name
      // API `category_id` is an integer.
      // Let's assume AppConstants categories 1..5 map to DB IDs 1..5
      return p['category_id'] == categoryId;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
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
              SliverToBoxAdapter(child: _buildTopBar()),
              // Nearby Stores
              if (_stores.isNotEmpty)
                SliverToBoxAdapter(child: _buildNearbyStores()),
              // Categories
              SliverToBoxAdapter(child: _buildCategories()),
              // View Toggle
              SliverToBoxAdapter(child: _buildViewToggle()),
              // Products Grid/List
              _isLoading ? _buildLoadingGrid() : _buildProductGrid(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNearbyStores() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Nearby Stores',
                style: AppTextStyles.headlineSmall(
                  color: isDark ? AppColors.textPrimaryDark : null,
                ),
              ),
              GestureDetector(
                onTap: () => context.push(AppRoutes.search, extra: 'stores'),
                child: Text(
                  'See all',
                  style: AppTextStyles.bodyMedium(
                    color: AppColors.primary,
                  ).copyWith(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 220, // Adjusted for StoreCard
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            physics: const BouncingScrollPhysics(),
            itemCount: _stores.length,
            itemBuilder: (context, index) {
              return StoreCard(store: _stores[index]);
            },
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildTopBar() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // Profile Avatar
          GestureDetector(
            onTap: () => context.go(AppRoutes.profile),
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: AppColors.primaryGradient,
                boxShadow: AppTheme.shadowSm,
              ),
              child: const Center(
                child: Icon(Icons.person, color: Colors.white, size: 24),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Search Bar
          Expanded(
            child: GestureDetector(
              onTap: () {
                context.push(AppRoutes.search);
              },
              child: Container(
                height: 44,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.surfaceDark
                      : AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(12),
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
                    const SizedBox(width: 8),
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
          const SizedBox(width: 12),
          // Cart Icon
          GestureDetector(
            onTap: () {
              context.push(AppRoutes.cart);
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
                if (_cartItemCount > 0)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      padding: const EdgeInsets.all(4),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Categories',
            style: AppTextStyles.headlineSmall(
              color: isDark ? AppColors.textPrimaryDark : null,
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            physics: const BouncingScrollPhysics(),
            itemCount: AppConstants.defaultCategories.length,
            itemBuilder: (context, index) {
              final category = AppConstants.defaultCategories[index];
              final isSelected = _selectedCategoryIndex == index;
              return GestureDetector(
                onTap: () => setState(() => _selectedCategoryIndex = index),
                child: AnimatedContainer(
                  duration: AppTheme.animationFast,
                  width: 80,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primary
                        : isDark
                        ? AppColors.surfaceDark
                        : AppColors.surfaceLight,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.primary
                          : isDark
                          ? AppColors.borderDark
                          : AppColors.borderLight,
                      width: isSelected ? 2 : 1,
                    ),
                    boxShadow: isSelected ? AppTheme.shadowMd : null,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        category['icon'],
                        style: const TextStyle(fontSize: 28),
                      ),
                      const SizedBox(height: 4),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            _selectedCategoryIndex == 0
                ? 'All Products'
                : '${AppConstants.defaultCategories[_selectedCategoryIndex]['name']} Products',
            style: AppTextStyles.headlineSmall(
              color: isDark ? AppColors.textPrimaryDark : null,
            ),
          ),
          Row(
            children: [
              GestureDetector(
                onTap: () => setState(() => _isGridView = true),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _isGridView ? AppColors.primary : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
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
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () => setState(() => _isGridView = false),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: !_isGridView
                        ? AppColors.primary
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
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
      padding: const EdgeInsets.symmetric(horizontal: 16),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 0.75,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) => const ProductCardShimmer(),
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
            padding: const EdgeInsets.all(32),
            child: Column(
              children: [
                Icon(
                  Icons.inventory_2_outlined,
                  size: 64,
                  color: AppColors.textTertiaryLight,
                ),
                const SizedBox(height: 16),
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
      padding: const EdgeInsets.symmetric(horizontal: 16),
      sliver: AnimationLimiter(
        child: SliverGrid(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: _isGridView ? 2 : 1,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: _isGridView ? 0.75 : 3,
          ),
          delegate: SliverChildBuilderDelegate((context, index) {
            final product = products[index];
            return AnimationConfiguration.staggeredGrid(
              position: index,
              duration: const Duration(milliseconds: 400),
              columnCount: _isGridView ? 2 : 1,
              child: SlideAnimation(
                verticalOffset: 50.0,
                child: FadeInAnimation(
                  child: ProductCard(
                    product: product,
                    isGridView: _isGridView,
                    onAddToCart: () {
                      _loadCartCount(); // Refresh badge
                    },
                  ),
                ),
              ),
            );
          }, childCount: products.length),
        ),
      ),
    );
  }
}
