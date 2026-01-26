import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../../config/theme/app_text_styles.dart';
import '../../../profile/data/user_service.dart';

class SavedPage
    extends
        StatefulWidget {
  const SavedPage({
    super.key,
  });

  @override
  State<
    SavedPage
  >
  createState() => _SavedPageState();
}

class _SavedPageState
    extends
        State<
          SavedPage
        >
    with
        SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _userService = UserService();

  bool _isLoading = true;
  List<
    dynamic
  >
  _savedProducts = [];
  List<
    dynamic
  >
  _savedStores = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 2,
      vsync: this,
    );
    _loadData();
  }

  Future<
    void
  >
  _loadData() async {
    setState(
      () => _isLoading = true,
    );
    try {
      final products = await _userService.getFavorites(
        'products',
      );
      final stores = await _userService.getFavorites(
        'stores',
      );

      if (mounted) {
        setState(
          () {
            _savedProducts = products;
            _savedStores = stores;
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
        // Silently fail or show snackbar?
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _removeFavorite(
    String type,
    int id,
  ) async {
    // Optimistic update
    setState(
      () {
        if (type ==
            'products') {
          _savedProducts.removeWhere(
            (
              p,
            ) =>
                p['id'] ==
                id,
          );
        } else {
          _savedStores.removeWhere(
            (
              s,
            ) =>
                s['id'] ==
                id,
          );
        }
      },
    );

    try {
      await _userService.toggleFavorite(
        type,
        id,
      );
      // Note: toggle might re-add if logic is flip-flop, strictly should use specific remove or check state
      // But UserService.toggleFavorite handles logic: if present -> remove.
      // Since we are continuously fetching, valid enough for now.
      // Ideally explicit delete.
    } catch (
      e
    ) {
      _loadData(); // Revert on error
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
      appBar: AppBar(
        backgroundColor: isDark
            ? AppColors.surfaceDark
            : AppColors.surfaceLight,
        title: Text(
          'Saved',
          style: AppTextStyles.titleLarge(
            color: isDark
                ? AppColors.textPrimaryDark
                : null,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: isDark
              ? AppColors.textTertiaryDark
              : AppColors.textTertiaryLight,
          indicatorColor: AppColors.primary,
          tabs: const [
            Tab(
              text: 'Products',
            ),
            Tab(
              text: 'Stores',
            ),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : TabBarView(
              controller: _tabController,
              children: [
                _buildProductsTab(
                  isDark,
                ),
                _buildStoresTab(
                  isDark,
                ),
              ],
            ),
    );
  }

  Widget _buildProductsTab(
    bool isDark,
  ) {
    if (_savedProducts.isEmpty) {
      return _buildEmptyState(
        isDark,
        Icons.bookmark_border,
        'No saved products yet',
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(
        16,
      ),
      itemCount: _savedProducts.length,
      separatorBuilder:
          (
            _,
            __,
          ) => const SizedBox(
            height: 12,
          ),
      itemBuilder:
          (
            context,
            index,
          ) {
            final product = _savedProducts[index];
            // Reuse ProductCard or create a Dismissible Tile
            return Dismissible(
              key: Key(
                'product_${product['id']}',
              ),
              direction: DismissDirection.endToStart,
              background: Container(
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.only(
                  right: 20,
                ),
                color: AppColors.error,
                child: const Icon(
                  Icons.delete,
                  color: Colors.white,
                ),
              ),
              onDismissed:
                  (
                    _,
                  ) => _removeFavorite(
                    'products',
                    product['id'],
                  ),
              child: GestureDetector(
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
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(
                          0.05,
                        ),
                        blurRadius: 10,
                        offset: const Offset(
                          0,
                          4,
                        ),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: AppColors.primarySurface,
                          borderRadius: BorderRadius.circular(
                            8,
                          ),
                          image:
                              product['image_url'] !=
                                  null
                              ? DecorationImage(
                                  image: NetworkImage(
                                    product['image_url'],
                                  ),
                                  fit: BoxFit.cover,
                                )
                              : null,
                        ),
                        child:
                            product['image_url'] ==
                                null
                            ? const Icon(
                                Icons.image,
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
                              product['name'],
                              style: AppTextStyles.titleMedium(
                                color: isDark
                                    ? AppColors.textPrimaryDark
                                    : null,
                              ),
                            ),
                            const SizedBox(
                              height: 4,
                            ),
                            Text(
                              product['min_price'] !=
                                      null
                                  ? 'From ₹${product['min_price']}'
                                  : 'View Options',
                              style: AppTextStyles.price(),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.delete_outline,
                          color: AppColors.textTertiaryLight,
                        ),
                        onPressed: () => _removeFavorite(
                          'products',
                          product['id'],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
    );
  }

  Widget _buildStoresTab(
    bool isDark,
  ) {
    if (_savedStores.isEmpty) {
      return _buildEmptyState(
        isDark,
        Icons.store_outlined,
        'No saved stores yet',
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(
        16,
      ),
      itemCount: _savedStores.length,
      separatorBuilder:
          (
            _,
            __,
          ) => const SizedBox(
            height: 12,
          ),
      itemBuilder:
          (
            context,
            index,
          ) {
            final store = _savedStores[index];
            return Dismissible(
              key: Key(
                'store_${store['id']}',
              ),
              direction: DismissDirection.endToStart,
              background: Container(
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.only(
                  right: 20,
                ),
                color: AppColors.error,
                child: const Icon(
                  Icons.delete,
                  color: Colors.white,
                ),
              ),
              onDismissed:
                  (
                    _,
                  ) => _removeFavorite(
                    'stores',
                    store['id'],
                  ),
              child: GestureDetector(
                onTap: () => context.push(
                  '/store/${store['id']}',
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
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(
                          0.05,
                        ),
                        blurRadius: 10,
                        offset: const Offset(
                          0,
                          4,
                        ),
                      ),
                    ],
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
                          image:
                              (store['image_url'] !=
                                      null ||
                                  store['logo_url'] !=
                                      null)
                              ? DecorationImage(
                                  image: NetworkImage(
                                    store['image_url'] ??
                                        store['logo_url'],
                                  ),
                                  fit: BoxFit.cover,
                                )
                              : null,
                        ),
                        child:
                            (store['image_url'] ==
                                    null &&
                                store['logo_url'] ==
                                    null)
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
                              store['name'],
                              style: AppTextStyles.titleMedium(
                                color: isDark
                                    ? AppColors.textPrimaryDark
                                    : null,
                              ),
                            ),
                            Row(
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
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
    );
  }

  Widget _buildEmptyState(
    bool isDark,
    IconData icon,
    String message,
  ) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 64,
            color: isDark
                ? AppColors.textTertiaryDark
                : AppColors.textTertiaryLight,
          ),
          const SizedBox(
            height: 16,
          ),
          Text(
            message,
            style: AppTextStyles.bodyLarge(
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight,
            ),
          ),
        ],
      ),
    );
  }
}
