import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../../config/theme/app_text_styles.dart';
import '../../../../config/theme/app_theme.dart';
import 'package:geolocator/geolocator.dart';
import '../../data/cart_service.dart';
import '../../../navigation/data/navigation_service.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  final _cartService = CartService();
  final _navigationService = NavigationService();
  bool _isLoading = true;
  Map<String, dynamic>? _cartData;

  @override
  void initState() {
    super.initState();
    _loadCart();
  }

  Future<void> _loadCart() async {
    try {
      final data = await _cartService.getCart();
      if (mounted) {
        setState(() {
          _cartData = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to load cart: $e')));
      }
    }
  }

  Future<void> _updateQuantity(int itemId, int quantity) async {
    try {
      await _cartService.updateQuantity(itemId, quantity);
      _loadCart(); // Reload to update totals
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to update: $e')));
    }
  }

  Future<void> _removeItem(int itemId) async {
    try {
      await _cartService.removeItem(itemId);
      _loadCart();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to remove: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Check if cart is empty
    final items = _cartData?['items'] as List<dynamic>? ?? [];

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.backgroundDark
          : AppColors.backgroundLight,
      appBar: AppBar(
        title: Text(
          'Shopping Cart',
          style: AppTextStyles.headlineSmall(
            color: isDark
                ? AppColors.textPrimaryDark
                : AppColors.textPrimaryLight,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: isDark
                ? AppColors.textPrimaryDark
                : AppColors.textPrimaryLight,
          ),
          onPressed: () => context.pop(),
        ),
        actions: [
          if (items.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_outline, color: AppColors.error),
              onPressed: () async {
                // Confirm dialog
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Clear Cart?'),
                    content: const Text(
                      'Are you sure you want to remove all items?',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text('Clear'),
                      ),
                    ],
                  ),
                );
                if (confirm == true) {
                  await _cartService.clearCart();
                  _loadCart();
                }
              },
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : items.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.shopping_cart_outlined,
                    size: 64,
                    color: AppColors.textTertiaryLight,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Your cart is empty',
                    style: AppTextStyles.bodyLarge(
                      color: AppColors.textSecondaryLight,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => context.pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Start Shopping',
                      style: AppTextStyles.buttonMedium(),
                    ),
                  ),
                ],
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: items.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final item = items[index];
                      return _buildCartItem(item, isDark);
                    },
                  ),
                ),
                _buildCheckoutSection(isDark),
              ],
            ),
    );
  }

  Widget _buildCartItem(Map<String, dynamic> item, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppTheme.shadowSm,
      ),
      child: Row(
        children: [
          // Image
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.primarySurface,
              borderRadius: BorderRadius.circular(12),
              image: item['product_image'] != null
                  ? DecorationImage(
                      image: NetworkImage(item['product_image']),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: item['product_image'] == null
                ? const Icon(Icons.image, color: AppColors.primary)
                : null,
          ),
          const SizedBox(width: 12),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['product_name'],
                  style: AppTextStyles.titleSmall(
                    color: isDark ? AppColors.textPrimaryDark : null,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  item['store_name'] ?? 'Unknown Store',
                  style: AppTextStyles.bodySmall(
                    color: AppColors.textSecondaryLight,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '₹${item['price']}',
                      style: AppTextStyles.price(fontSize: 16),
                    ),
                    // Quantity Control
                    Container(
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.backgroundDark
                            : AppColors.backgroundLight,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          _QuantityButton(
                            icon: Icons.remove,
                            onTap: () {
                              if (item['quantity'] > 1) {
                                _updateQuantity(
                                  item['id'],
                                  item['quantity'] - 1,
                                );
                              } else {
                                _removeItem(item['id']);
                              }
                            },
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: Text(
                              '${item['quantity']}',
                              style: AppTextStyles.bodyMedium(
                                color: isDark
                                    ? AppColors.textPrimaryDark
                                    : null,
                              ).copyWith(fontWeight: FontWeight.bold),
                            ),
                          ),
                          _QuantityButton(
                            icon: Icons.add,
                            onTap: () => _updateQuantity(
                              item['id'],
                              item['quantity'] + 1,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckoutSection(bool isDark) {
    if (_cartData == null) return const SizedBox.shrink();

    final subtotal = double.tryParse(_cartData!['subtotal'].toString()) ?? 0.0;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: AppTheme.shadowMd,
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total',
                style: AppTextStyles.titleMedium(
                  color: isDark ? AppColors.textPrimaryDark : null,
                ),
              ),
              Text(
                '₹${subtotal.toStringAsFixed(2)}',
                style: AppTextStyles.price(fontSize: 24),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: () async {
                setState(() => _isLoading = true);
                try {
                  LocationPermission permission =
                      await Geolocator.checkPermission();
                  if (permission == LocationPermission.denied) {
                    permission = await Geolocator.requestPermission();
                    if (permission == LocationPermission.denied) {
                      throw Exception(
                        'Location permission is required to plan your route',
                      );
                    }
                  }

                  if (permission == LocationPermission.deniedForever) {
                    throw Exception(
                      'Location permission is permanently denied. Please enable it in settings.',
                    );
                  }

                  final position = await Geolocator.getCurrentPosition();

                  if (_cartData == null || _cartData!['items'] == null) return;

                  final products = (_cartData!['items'] as List)
                      .map((item) => item['product_name'] as String)
                      .toList();

                  final routeData = await _navigationService.optimizeRoute(
                    products: products,
                    latitude: position.latitude,
                    longitude: position.longitude,
                  );

                  if (context.mounted) {
                    context.push(
                      '/route-summary',
                      extra: {
                        'routeData': routeData,
                        'initialProducts': products,
                        'userLat': position.latitude,
                        'userLng': position.longitude,
                      },
                    );
                  }
                } catch (e) {
                  String errorMessage = 'An error occurred';
                  if (e is Exception && e.toString().contains('DioException')) {
                    // Try to parse the response data
                    try {
                      // This is a dynamic check because we don't have Dio types imported directly
                      final dynamic errorObj = e;
                      if (errorObj.response?.data != null) {
                        errorMessage =
                            errorObj.response.data['error'] ?? errorObj.message;
                      } else {
                        errorMessage =
                            "Connection refused or server error (404/500)";
                      }
                    } catch (_) {
                      errorMessage = e.toString();
                    }
                  } else {
                    errorMessage = e.toString();
                  }

                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error: $errorMessage'),
                        backgroundColor: AppColors.error,
                      ),
                    );
                  }
                } finally {
                  if (mounted) setState(() => _isLoading = false);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Text('Checkout', style: AppTextStyles.buttonLarge()),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuantityButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _QuantityButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: Icon(icon, size: 16, color: AppColors.primary),
      ),
    );
  }
}
