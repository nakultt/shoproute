import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../../config/theme/app_text_styles.dart';

/// Saved/Bookmarks Page with tabs
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

  // Sample saved products
  final List<
    Map<
      String,
      dynamic
    >
  >
  _savedProducts = [
    {
      'id': 1,
      'name': 'Organic Milk',
      'price': 4.99,
      'store': 'Fresh Mart',
      'image': null,
    },
    {
      'id': 2,
      'name': 'Whole Wheat Bread',
      'price': 3.49,
      'store': 'QuickShop',
      'image': null,
    },
    {
      'id': 3,
      'name': 'Farm Fresh Eggs',
      'price': 5.99,
      'store': 'Super Store',
      'image': null,
    },
    {
      'id': 4,
      'name': 'Avocados (3 pack)',
      'price': 4.49,
      'store': 'Fresh Mart',
      'image': null,
    },
    {
      'id': 5,
      'name': 'Greek Yogurt',
      'price': 6.99,
      'store': 'QuickShop',
      'image': null,
    },
  ];

  // Sample saved stores
  final List<
    Map<
      String,
      dynamic
    >
  >
  _savedStores = [
    {
      'id': 1,
      'name': 'Fresh Mart',
      'rating': 4.5,
      'distance': '1.2 km',
      'address': '123 Market St',
      'lat': 37.7749,
      'lng': -122.4194,
    },
    {
      'id': 2,
      'name': 'QuickShop',
      'rating': 4.2,
      'distance': '1.8 km',
      'address': '456 Valencia St',
      'lat': 37.7799,
      'lng': -122.4144,
    },
    {
      'id': 3,
      'name': 'Super Store',
      'rating': 4.7,
      'distance': '2.3 km',
      'address': '789 Mission St',
      'lat': 37.7699,
      'lng': -122.4244,
    },
  ];

  // Sample shopping lists
  final List<
    Map<
      String,
      dynamic
    >
  >
  _shoppingLists = [
    {
      'id': 1,
      'name': 'Weekly Groceries',
      'items': [
        'Milk',
        'Bread',
        'Eggs',
        'Butter',
        'Cheese',
        'Apples',
        'Chicken',
        'Rice',
      ],
      'createdAt': DateTime.now().subtract(
        const Duration(
          days: 2,
        ),
      ),
    },
    {
      'id': 2,
      'name': 'Party Supplies',
      'items': [
        'Chips',
        'Soda',
        'Plates',
        'Napkins',
        'Ice',
      ],
      'createdAt': DateTime.now().subtract(
        const Duration(
          days: 5,
        ),
      ),
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 3,
      vsync: this,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _shareProduct(
    Map<
      String,
      dynamic
    >
    product,
  ) {
    Share.share(
      'Check out ${product['name']} at ${product['store']} for \$${product['price']}!\n\nShared via ShopRoute',
      subject: 'Great deal on ${product['name']}!',
    );
  }

  void _shareStore(
    Map<
      String,
      dynamic
    >
    store,
  ) {
    Share.share(
      'I love shopping at ${store['name']}! ⭐ ${store['rating']} rating\nAddress: ${store['address']}\n\nShared via ShopRoute',
      subject: 'Check out ${store['name']}!',
    );
  }

  void _shareList(
    Map<
      String,
      dynamic
    >
    list,
  ) {
    final items =
        (list['items']
                as List)
            .join(
              '\n• ',
            );
    Share.share(
      '📝 ${list['name']}\n\n• $items\n\nShared via ShopRoute',
      subject: 'Shopping List: ${list['name']}',
    );
  }

  void _openDirections(
    Map<
      String,
      dynamic
    >
    store,
  ) async {
    final lat = store['lat'];
    final lng = store['lng'];
    final googleMapsUrl = 'https://www.google.com/maps/dir/?api=1&destination=$lat,$lng';

    if (await canLaunchUrl(
      Uri.parse(
        googleMapsUrl,
      ),
    )) {
      await launchUrl(
        Uri.parse(
          googleMapsUrl,
        ),
        mode: LaunchMode.externalApplication,
      );
    }
  }

  void _showCreateListDialog() {
    final nameController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (
            ctx,
          ) => Container(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(
                ctx,
              ).viewInsets.bottom,
              left: 24,
              right: 24,
              top: 24,
            ),
            decoration: const BoxDecoration(
              color: AppColors.surfaceLight,
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(
                  24,
                ),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Create New List',
                  style: AppTextStyles.headlineSmall(),
                ),
                const SizedBox(
                  height: 20,
                ),
                TextFormField(
                  controller: nameController,
                  autofocus: true,
                  decoration: const InputDecoration(
                    hintText: 'List name',
                    prefixIcon: Icon(
                      Icons.list_alt,
                    ),
                  ),
                ),
                const SizedBox(
                  height: 24,
                ),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      if (nameController.text.isNotEmpty) {
                        setState(
                          () {
                            _shoppingLists.add(
                              {
                                'id':
                                    _shoppingLists.length +
                                    1,
                                'name': nameController.text,
                                'items': [],
                                'createdAt': DateTime.now(),
                              },
                            );
                          },
                        );
                        Navigator.pop(
                          ctx,
                        );
                        ScaffoldMessenger.of(
                          context,
                        ).showSnackBar(
                          SnackBar(
                            content: Text(
                              'List "${nameController.text}" created!',
                            ),
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(
                        vertical: 16,
                      ),
                    ),
                    child: const Text(
                      'Create List',
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 24,
                ),
              ],
            ),
          ),
    );
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
            Tab(
              text: 'Lists',
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildProductsTab(
            isDark,
          ),
          _buildStoresTab(
            isDark,
          ),
          _buildListsTab(
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
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.bookmark_border,
              size: 64,
              color: isDark
                  ? AppColors.textTertiaryDark
                  : AppColors.textTertiaryLight,
            ),
            const SizedBox(
              height: 16,
            ),
            Text(
              'No saved products yet',
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

    return ListView.builder(
      padding: const EdgeInsets.all(
        16,
      ),
      itemCount: _savedProducts.length,
      itemBuilder:
          (
            context,
            index,
          ) {
            final product = _savedProducts[index];
            return Dismissible(
              key: Key(
                'product_${product['id']}',
              ),
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
              direction: DismissDirection.endToStart,
              onDismissed:
                  (
                    _,
                  ) {
                    setState(
                      () => _savedProducts.removeAt(
                        index,
                      ),
                    );
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(
                      SnackBar(
                        content: Text(
                          '${product['name']} removed',
                        ),
                        action: SnackBarAction(
                          label: 'Undo',
                          onPressed: () => setState(
                            () => _savedProducts.insert(
                              index,
                              product,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
              child: Card(
                color: isDark
                    ? AppColors.surfaceDark
                    : AppColors.surfaceLight,
                margin: const EdgeInsets.only(
                  bottom: 12,
                ),
                child: ListTile(
                  leading: Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: AppColors.primarySurface,
                      borderRadius: BorderRadius.circular(
                        8,
                      ),
                    ),
                    child: const Icon(
                      Icons.shopping_bag,
                      color: AppColors.primary,
                    ),
                  ),
                  title: Text(
                    product['name'],
                    style: TextStyle(
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : null,
                    ),
                  ),
                  subtitle: Text(
                    '\$${product['price']} • ${product['store']}',
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        onPressed: () => _shareProduct(
                          product,
                        ),
                        icon: Icon(
                          Icons.share,
                          color: isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondaryLight,
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          ScaffoldMessenger.of(
                            context,
                          ).showSnackBar(
                            SnackBar(
                              content: Text(
                                '${product['name']} added to cart',
                              ),
                            ),
                          );
                        },
                        icon: const Icon(
                          Icons.add_shopping_cart,
                          color: AppColors.primary,
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
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.store_outlined,
              size: 64,
              color: isDark
                  ? AppColors.textTertiaryDark
                  : AppColors.textTertiaryLight,
            ),
            const SizedBox(
              height: 16,
            ),
            Text(
              'No saved stores yet',
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

    return ListView.builder(
      padding: const EdgeInsets.all(
        16,
      ),
      itemCount: _savedStores.length,
      itemBuilder:
          (
            context,
            index,
          ) {
            final store = _savedStores[index];
            return Card(
              color: isDark
                  ? AppColors.surfaceDark
                  : AppColors.surfaceLight,
              margin: const EdgeInsets.only(
                bottom: 12,
              ),
              child: ListTile(
                leading: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: AppColors.accentSurface,
                    borderRadius: BorderRadius.circular(
                      8,
                    ),
                  ),
                  child: const Icon(
                    Icons.store,
                    color: AppColors.accent,
                  ),
                ),
                title: Text(
                  store['name'],
                  style: TextStyle(
                    color: isDark
                        ? AppColors.textPrimaryDark
                        : null,
                  ),
                ),
                subtitle: Row(
                  children: [
                    const Icon(
                      Icons.star,
                      size: 14,
                      color: AppColors.warning,
                    ),
                    Text(
                      ' ${store['rating']} • ${store['distance']}',
                    ),
                  ],
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      onPressed: () => _shareStore(
                        store,
                      ),
                      icon: Icon(
                        Icons.share,
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondaryLight,
                      ),
                    ),
                    OutlinedButton(
                      onPressed: () => _openDirections(
                        store,
                      ),
                      child: const Text(
                        'Directions',
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
    );
  }

  Widget _buildListsTab(
    bool isDark,
  ) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: _shoppingLists.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.list_alt,
                    size: 64,
                    color: isDark
                        ? AppColors.textTertiaryDark
                        : AppColors.textTertiaryLight,
                  ),
                  const SizedBox(
                    height: 16,
                  ),
                  Text(
                    'No shopping lists yet',
                    style: AppTextStyles.bodyLarge(
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondaryLight,
                    ),
                  ),
                  const SizedBox(
                    height: 8,
                  ),
                  Text(
                    'Tap + to create one',
                    style: AppTextStyles.bodySmall(),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(
                16,
              ),
              itemCount: _shoppingLists.length,
              itemBuilder:
                  (
                    context,
                    index,
                  ) {
                    final list = _shoppingLists[index];
                    final items =
                        list['items']
                            as List;
                    return Card(
                      color: isDark
                          ? AppColors.surfaceDark
                          : AppColors.surfaceLight,
                      margin: const EdgeInsets.only(
                        bottom: 12,
                      ),
                      child: ExpansionTile(
                        leading: Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: AppColors.infoLight,
                            borderRadius: BorderRadius.circular(
                              8,
                            ),
                          ),
                          child: const Icon(
                            Icons.list_alt,
                            color: AppColors.info,
                          ),
                        ),
                        title: Text(
                          list['name'],
                          style: TextStyle(
                            color: isDark
                                ? AppColors.textPrimaryDark
                                : null,
                          ),
                        ),
                        subtitle: Text(
                          '${items.length} items',
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              onPressed: () => _shareList(
                                list,
                              ),
                              icon: Icon(
                                Icons.share,
                                color: isDark
                                    ? AppColors.textSecondaryDark
                                    : AppColors.textSecondaryLight,
                              ),
                              tooltip: 'Share List',
                            ),
                            IconButton(
                              onPressed: () {
                                // Navigate to map with optimized route
                                ScaffoldMessenger.of(
                                  context,
                                ).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Optimizing shopping route...',
                                    ),
                                  ),
                                );
                              },
                              icon: const Icon(
                                Icons.route,
                                color: AppColors.primary,
                              ),
                              tooltip: 'Optimize Route',
                            ),
                          ],
                        ),
                        children: [
                          ...items.map(
                            (
                              item,
                            ) => ListTile(
                              leading: Checkbox(
                                value: false,
                                onChanged:
                                    (
                                      _,
                                    ) {},
                              ),
                              title: Text(
                                item,
                              ),
                              trailing: IconButton(
                                onPressed: () {
                                  setState(
                                    () {
                                      items.remove(
                                        item,
                                      );
                                    },
                                  );
                                },
                                icon: const Icon(
                                  Icons.remove_circle_outline,
                                  color: AppColors.error,
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(
                              16,
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed: () {
                                      _showAddItemDialog(
                                        list,
                                      );
                                    },
                                    icon: const Icon(
                                      Icons.add,
                                    ),
                                    label: const Text(
                                      'Add Item',
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreateListDialog,
        backgroundColor: AppColors.primary,
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
    );
  }

  void _showAddItemDialog(
    Map<
      String,
      dynamic
    >
    list,
  ) {
    final itemController = TextEditingController();

    showDialog(
      context: context,
      builder:
          (
            ctx,
          ) => AlertDialog(
            title: const Text(
              'Add Item',
            ),
            content: TextField(
              controller: itemController,
              autofocus: true,
              decoration: const InputDecoration(
                hintText: 'Item name',
              ),
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
                  if (itemController.text.isNotEmpty) {
                    setState(
                      () {
                        (list['items']
                                as List)
                            .add(
                              itemController.text,
                            );
                      },
                    );
                    Navigator.pop(
                      ctx,
                    );
                  }
                },
                child: const Text(
                  'Add',
                ),
              ),
            ],
          ),
    );
  }
}
