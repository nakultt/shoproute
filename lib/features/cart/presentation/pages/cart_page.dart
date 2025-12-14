import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../../config/theme/app_text_styles.dart';
import '../../../../config/theme/app_theme.dart';
import '../../../../core/widgets/animated_button.dart';

/// Cart Page with items, cost calculation, and checkout
class CartPage
    extends
        StatefulWidget {
  const CartPage({
    super.key,
  });

  @override
  State<
    CartPage
  >
  createState() => _CartPageState();
}

class _CartPageState
    extends
        State<
          CartPage
        > {
  // Sample cart items
  final List<
    Map<
      String,
      dynamic
    >
  >
  _cartItems = [
    {
      'id': 1,
      'name': 'Organic Milk 1L',
      'price': 4.99,
      'compare_at_price': 6.99,
      'quantity': 2,
      'store_name': 'Fresh Mart',
      'image': '🥛',
      'in_stock': true,
    },
    {
      'id': 2,
      'name': 'Whole Wheat Bread',
      'price': 3.49,
      'compare_at_price': null,
      'quantity': 1,
      'store_name': 'Fresh Mart',
      'image': '🍞',
      'in_stock': true,
    },
    {
      'id': 3,
      'name': 'Free Range Eggs (12)',
      'price': 5.99,
      'compare_at_price': 7.49,
      'quantity': 1,
      'store_name': 'QuickShop',
      'image': '🥚',
      'in_stock': true,
    },
    {
      'id': 4,
      'name': 'Organic Almond Milk',
      'price': 4.49,
      'compare_at_price': null,
      'quantity': 1,
      'store_name': 'Health Foods',
      'image': '🥜',
      'in_stock': false,
    },
  ];

  // AI Substitutions for out-of-stock items
  final List<
    Map<
      String,
      dynamic
    >
  >
  _substitutions = [
    {
      'original': 'Organic Almond Milk',
      'suggestions': [
        {
          'name': 'Oat Milk',
          'price': 3.99,
          'reason': 'Creamy texture, similar nutrition, trending choice',
        },
        {
          'name': 'Soy Milk',
          'price': 2.99,
          'reason': 'Higher protein, budget-friendly',
        },
        {
          'name': 'Regular Almond Milk',
          'price': 3.49,
          'reason': 'Non-organic version, same brand',
        },
      ],
    },
  ];

  double get subtotal {
    return _cartItems
        .where(
          (
            item,
          ) => item['in_stock'],
        )
        .fold(
          0.0,
          (
            sum,
            item,
          ) =>
              sum +
              (item['price'] *
                  item['quantity']),
        );
  }

  double get savings {
    return _cartItems
        .where(
          (
            item,
          ) =>
              item['compare_at_price'] !=
                  null &&
              item['in_stock'],
        )
        .fold(
          0.0,
          (
            sum,
            item,
          ) =>
              sum +
              ((item['compare_at_price'] -
                      item['price']) *
                  item['quantity']),
        );
  }

  int get itemCount {
    return _cartItems
        .where(
          (
            item,
          ) => item['in_stock'],
        )
        .fold(
          0,
          (
            sum,
            item,
          ) =>
              sum +
              (item['quantity']
                  as int),
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
        title: Text(
          'Cart',
          style: AppTextStyles.titleLarge(),
        ),
        actions: [
          if (_cartItems.isNotEmpty)
            TextButton(
              onPressed: _clearCart,
              child: const Text(
                'Clear All',
              ),
            ),
        ],
      ),
      body: _cartItems.isEmpty
          ? _buildEmptyCart()
          : Column(
              children: [
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(
                      16,
                    ),
                    children: [
                      // Out of stock items with substitutions
                      if (_cartItems.any(
                        (
                          item,
                        ) => !item['in_stock'],
                      )) ...[
                        _buildOutOfStockSection(),
                        const SizedBox(
                          height: 16,
                        ),
                      ],
                      // In stock items grouped by store
                      ..._buildStoreGroups(),
                    ],
                  ),
                ),
                _buildCheckoutBar(),
              ],
            ),
    );
  }

  Widget _buildEmptyCart() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.shopping_cart_outlined,
            size: 80,
            color: AppColors.textTertiaryLight,
          ),
          const SizedBox(
            height: 16,
          ),
          Text(
            'Your cart is empty',
            style: AppTextStyles.titleLarge(),
          ),
          const SizedBox(
            height: 8,
          ),
          Text(
            'Add items to start shopping',
            style: AppTextStyles.bodyMedium(
              color: AppColors.textSecondaryLight,
            ),
          ),
          const SizedBox(
            height: 24,
          ),
          ElevatedButton.icon(
            onPressed: () => context.go(
              '/home',
            ),
            icon: const Icon(
              Icons.shopping_bag,
            ),
            label: const Text(
              'Browse Products',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOutOfStockSection() {
    final outOfStockItems = _cartItems
        .where(
          (
            item,
          ) => !item['in_stock'],
        )
        .toList();

    return Container(
      padding: const EdgeInsets.all(
        16,
      ),
      decoration: BoxDecoration(
        color: AppColors.warningLight,
        borderRadius: BorderRadius.circular(
          16,
        ),
        border: Border.all(
          color: AppColors.warning.withOpacity(
            0.3,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.warning_amber,
                color: AppColors.warning,
              ),
              const SizedBox(
                width: 8,
              ),
              Text(
                'Out of Stock Items',
                style: AppTextStyles.titleSmall(
                  color: AppColors.warning,
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 12,
          ),
          ...outOfStockItems.map(
            (
              item,
            ) => _buildOutOfStockItem(
              item,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOutOfStockItem(
    Map<
      String,
      dynamic
    >
    item,
  ) {
    final substitution = _substitutions.firstWhere(
      (
        s,
      ) =>
          s['original'] ==
          item['name'],
      orElse: () => {
        'suggestions': [],
      },
    );
    final suggestions =
        substitution['suggestions']
            as List<
              dynamic
            >;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              item['image'],
              style: const TextStyle(
                fontSize: 24,
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
                    item['name'],
                    style:
                        AppTextStyles.bodyLarge(
                          color: AppColors.textSecondaryLight,
                        ).copyWith(
                          decoration: TextDecoration.lineThrough,
                        ),
                  ),
                  Text(
                    'Out of stock',
                    style: AppTextStyles.labelSmall(
                      color: AppColors.error,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: () => _removeItem(
                item['id'],
              ),
              icon: const Icon(
                Icons.close,
                size: 20,
              ),
            ),
          ],
        ),
        if (suggestions.isNotEmpty) ...[
          const SizedBox(
            height: 12,
          ),
          Container(
            padding: const EdgeInsets.all(
              12,
            ),
            decoration: BoxDecoration(
              color: AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(
                12,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.auto_awesome,
                      size: 16,
                      color: AppColors.primary,
                    ),
                    const SizedBox(
                      width: 6,
                    ),
                    Text(
                      'AI Suggests:',
                      style: AppTextStyles.labelMedium(
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 8,
                ),
                ...suggestions.asMap().entries.map(
                  (
                    entry,
                  ) {
                    final index = entry.key;
                    final suggestion = entry.value;
                    return GestureDetector(
                      onTap: () => _replaceWithSubstitute(
                        item,
                        suggestion,
                      ),
                      child: Container(
                        margin: const EdgeInsets.only(
                          bottom: 8,
                        ),
                        padding: const EdgeInsets.all(
                          12,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: AppColors.borderLight,
                          ),
                          borderRadius: BorderRadius.circular(
                            8,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                color: AppColors.primarySurface,
                                borderRadius: BorderRadius.circular(
                                  12,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  '${index + 1}',
                                  style: AppTextStyles.labelSmall(
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(
                              width: 12,
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        suggestion['name'],
                                        style: AppTextStyles.bodyMedium(),
                                      ),
                                      const SizedBox(
                                        width: 8,
                                      ),
                                      Text(
                                        '\$${suggestion['price'].toStringAsFixed(2)}',
                                        style: AppTextStyles.price(
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Text(
                                    suggestion['reason'],
                                    style: AppTextStyles.bodySmall(
                                      color: AppColors.textSecondaryLight,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(
                              Icons.add_circle,
                              color: AppColors.primary,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
        const SizedBox(
          height: 12,
        ),
      ],
    );
  }

  List<
    Widget
  >
  _buildStoreGroups() {
    final inStockItems = _cartItems
        .where(
          (
            item,
          ) => item['in_stock'],
        )
        .toList();
    final stores = inStockItems
        .map(
          (
            item,
          ) => item['store_name'],
        )
        .toSet();

    return stores.map(
      (
        storeName,
      ) {
        final storeItems = inStockItems
            .where(
              (
                item,
              ) =>
                  item['store_name'] ==
                  storeName,
            )
            .toList();
        final storeSubtotal = storeItems.fold(
          0.0,
          (
            sum,
            item,
          ) =>
              sum +
              (item['price'] *
                  item['quantity']),
        );

        return Container(
          margin: const EdgeInsets.only(
            bottom: 16,
          ),
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
              Padding(
                padding: const EdgeInsets.all(
                  16,
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(
                        8,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.accentSurface,
                        borderRadius: BorderRadius.circular(
                          8,
                        ),
                      ),
                      child: const Icon(
                        Icons.store,
                        color: AppColors.accent,
                        size: 20,
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
                            storeName,
                            style: AppTextStyles.titleSmall(),
                          ),
                          Text(
                            '${storeItems.length} items • \$${storeSubtotal.toStringAsFixed(2)}',
                            style: AppTextStyles.bodySmall(),
                          ),
                        ],
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () {},
                      icon: const Icon(
                        Icons.directions,
                        size: 18,
                      ),
                      label: const Text(
                        'Route',
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(
                height: 1,
              ),
              ...storeItems.map(
                (
                  item,
                ) => _buildCartItem(
                  item,
                ),
              ),
            ],
          ),
        );
      },
    ).toList();
  }

  Widget _buildCartItem(
    Map<
      String,
      dynamic
    >
    item,
  ) {
    return Padding(
      padding: const EdgeInsets.all(
        16,
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: AppColors.primarySurface,
              borderRadius: BorderRadius.circular(
                10,
              ),
            ),
            child: Center(
              child: Text(
                item['image'],
                style: const TextStyle(
                  fontSize: 28,
                ),
              ),
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
                  item['name'],
                  style: AppTextStyles.bodyMedium(),
                ),
                const SizedBox(
                  height: 4,
                ),
                Row(
                  children: [
                    Text(
                      '\$${item['price'].toStringAsFixed(2)}',
                      style: AppTextStyles.price(
                        fontSize: 16,
                      ),
                    ),
                    if (item['compare_at_price'] !=
                        null) ...[
                      const SizedBox(
                        width: 6,
                      ),
                      Text(
                        '\$${item['compare_at_price'].toStringAsFixed(2)}',
                        style: AppTextStyles.priceStrikethrough(),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          Row(
            children: [
              IconButton(
                onPressed: () => _updateQuantity(
                  item['id'],
                  item['quantity'] -
                      1,
                ),
                icon: const Icon(
                  Icons.remove_circle_outline,
                ),
                iconSize: 24,
                constraints: const BoxConstraints(),
                padding: EdgeInsets.zero,
              ),
              Container(
                width: 36,
                alignment: Alignment.center,
                child: Text(
                  '${item['quantity']}',
                  style: AppTextStyles.titleSmall(),
                ),
              ),
              IconButton(
                onPressed: () => _updateQuantity(
                  item['id'],
                  item['quantity'] +
                      1,
                ),
                icon: const Icon(
                  Icons.add_circle_outline,
                  color: AppColors.primary,
                ),
                iconSize: 24,
                constraints: const BoxConstraints(),
                padding: EdgeInsets.zero,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCheckoutBar() {
    return Container(
      padding: const EdgeInsets.all(
        20,
      ),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(
            24,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(
              0.1,
            ),
            blurRadius: 20,
            offset: const Offset(
              0,
              -4,
            ),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Cost breakdown
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Subtotal ($itemCount items)',
                  style: AppTextStyles.bodyMedium(),
                ),
                Text(
                  '\$${subtotal.toStringAsFixed(2)}',
                  style: AppTextStyles.bodyMedium(),
                ),
              ],
            ),
            if (savings >
                0) ...[
              const SizedBox(
                height: 8,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Savings',
                    style: AppTextStyles.bodyMedium(
                      color: AppColors.success,
                    ),
                  ),
                  Text(
                    '-\$${savings.toStringAsFixed(2)}',
                    style: AppTextStyles.bodyMedium(
                      color: AppColors.success,
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(
              height: 12,
            ),
            const Divider(),
            const SizedBox(
              height: 12,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total',
                  style: AppTextStyles.titleLarge(),
                ),
                Text(
                  '\$${subtotal.toStringAsFixed(2)}',
                  style: AppTextStyles.price(
                    fontSize: 24,
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 16,
            ),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(
                      Icons.route,
                    ),
                    label: const Text(
                      'Optimize Route',
                    ),
                  ),
                ),
                const SizedBox(
                  width: 12,
                ),
                Expanded(
                  flex: 2,
                  child: AnimatedButton(
                    onPressed: () {},
                    gradient: AppColors.primaryGradient,
                    child: const Text(
                      'Checkout',
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _updateQuantity(
    int id,
    int newQuantity,
  ) {
    if (newQuantity <
        1) {
      _removeItem(
        id,
      );
      return;
    }
    setState(
      () {
        final index = _cartItems.indexWhere(
          (
            item,
          ) =>
              item['id'] ==
              id,
        );
        if (index !=
            -1) {
          _cartItems[index]['quantity'] = newQuantity;
        }
      },
    );
  }

  void _removeItem(
    int id,
  ) {
    setState(
      () {
        _cartItems.removeWhere(
          (
            item,
          ) =>
              item['id'] ==
              id,
        );
      },
    );
  }

  void _replaceWithSubstitute(
    Map<
      String,
      dynamic
    >
    originalItem,
    Map<
      String,
      dynamic
    >
    substitute,
  ) {
    setState(
      () {
        final index = _cartItems.indexWhere(
          (
            item,
          ) =>
              item['id'] ==
              originalItem['id'],
        );
        if (index !=
            -1) {
          _cartItems[index] = {
            ...originalItem,
            'name': substitute['name'],
            'price': substitute['price'],
            'in_stock': true,
          };
        }
      },
    );
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(
      SnackBar(
        content: Text(
          'Replaced with ${substitute['name']}',
        ),
      ),
    );
  }

  void _clearCart() {
    showDialog(
      context: context,
      builder:
          (
            ctx,
          ) => AlertDialog(
            title: const Text(
              'Clear Cart',
            ),
            content: const Text(
              'Are you sure you want to remove all items?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(
                  ctx,
                ),
                child: const Text(
                  'Cancel',
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(
                    ctx,
                  );
                  setState(
                    () => _cartItems.clear(),
                  );
                },
                child: const Text(
                  'Clear',
                  style: TextStyle(
                    color: AppColors.error,
                  ),
                ),
              ),
            ],
          ),
    );
  }
}
