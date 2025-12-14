import 'package:flutter/material.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../../config/theme/app_text_styles.dart';
import '../../../../config/theme/app_theme.dart';

/// Pantry Page - Track purchased items at home with expiry dates
class PantryPage
    extends
        StatefulWidget {
  const PantryPage({
    super.key,
  });

  @override
  State<
    PantryPage
  >
  createState() => _PantryPageState();
}

class _PantryPageState
    extends
        State<
          PantryPage
        >
    with
        SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedLocation = 'all';

  // Sample pantry items
  final List<
    Map<
      String,
      dynamic
    >
  >
  _pantryItems = [
    {
      'id': 1,
      'name': 'Organic Milk',
      'quantity': 1,
      'unit': 'L',
      'location': 'fridge',
      'expiry_date': DateTime.now().add(
        const Duration(
          days: 3,
        ),
      ),
      'is_low_stock': false,
      'icon': '🥛',
    },
    {
      'id': 2,
      'name': 'Eggs',
      'quantity': 6,
      'unit': 'pcs',
      'location': 'fridge',
      'expiry_date': DateTime.now().add(
        const Duration(
          days: 10,
        ),
      ),
      'is_low_stock': true,
      'icon': '🥚',
    },
    {
      'id': 3,
      'name': 'Bread',
      'quantity': 1,
      'unit': 'loaf',
      'location': 'pantry',
      'expiry_date': DateTime.now().add(
        const Duration(
          days: 2,
        ),
      ),
      'is_low_stock': false,
      'icon': '🍞',
    },
    {
      'id': 4,
      'name': 'Chicken Breast',
      'quantity': 500,
      'unit': 'g',
      'location': 'freezer',
      'expiry_date': DateTime.now().add(
        const Duration(
          days: 30,
        ),
      ),
      'is_low_stock': false,
      'icon': '🍗',
    },
    {
      'id': 5,
      'name': 'Spinach',
      'quantity': 200,
      'unit': 'g',
      'location': 'fridge',
      'expiry_date': DateTime.now().subtract(
        const Duration(
          days: 1,
        ),
      ),
      'is_low_stock': false,
      'icon': '🥬',
    },
    {
      'id': 6,
      'name': 'Rice',
      'quantity': 2,
      'unit': 'kg',
      'location': 'pantry',
      'expiry_date': DateTime.now().add(
        const Duration(
          days: 180,
        ),
      ),
      'is_low_stock': false,
      'icon': '🍚',
    },
    {
      'id': 7,
      'name': 'Yogurt',
      'quantity': 2,
      'unit': 'cups',
      'location': 'fridge',
      'expiry_date': DateTime.now().add(
        const Duration(
          days: 5,
        ),
      ),
      'is_low_stock': true,
      'icon': '🥛',
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 4,
      vsync: this,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<
    Map<
      String,
      dynamic
    >
  >
  get _filteredItems {
    if (_selectedLocation ==
        'all')
      return _pantryItems;
    return _pantryItems
        .where(
          (
            item,
          ) =>
              item['location'] ==
              _selectedLocation,
        )
        .toList();
  }

  List<
    Map<
      String,
      dynamic
    >
  >
  get _expiringItems {
    return _pantryItems.where(
      (
        item,
      ) {
        final expiry =
            item['expiry_date']
                as DateTime;
        final daysUntil = expiry
            .difference(
              DateTime.now(),
            )
            .inDays;
        return daysUntil <=
                3 &&
            daysUntil >=
                0;
      },
    ).toList();
  }

  List<
    Map<
      String,
      dynamic
    >
  >
  get _expiredItems {
    return _pantryItems.where(
      (
        item,
      ) {
        final expiry =
            item['expiry_date']
                as DateTime;
        return expiry.isBefore(
          DateTime.now(),
        );
      },
    ).toList();
  }

  List<
    Map<
      String,
      dynamic
    >
  >
  get _lowStockItems {
    return _pantryItems
        .where(
          (
            item,
          ) =>
              item['is_low_stock'] ==
              true,
        )
        .toList();
  }

  String _getFreshnessStatus(
    DateTime expiryDate,
  ) {
    final daysUntil = expiryDate
        .difference(
          DateTime.now(),
        )
        .inDays;
    if (daysUntil <
        0)
      return 'expired';
    if (daysUntil <=
        3)
      return 'expiring_soon';
    return 'fresh';
  }

  Color _getFreshnessColor(
    String status,
  ) {
    switch (status) {
      case 'expired':
        return AppColors.error;
      case 'expiring_soon':
        return AppColors.warning;
      default:
        return AppColors.success;
    }
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: Text(
          'My Pantry',
          style: AppTextStyles.titleLarge(),
        ),
        actions: [
          IconButton(
            onPressed: _showRecipeSuggestions,
            icon: const Icon(
              Icons.restaurant_menu,
            ),
            tooltip: 'Recipe Ideas',
          ),
          IconButton(
            onPressed: _generateShoppingList,
            icon: const Icon(
              Icons.add_shopping_cart,
            ),
            tooltip: 'Generate Shopping List',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textTertiaryLight,
          indicatorColor: AppColors.primary,
          tabs: [
            Tab(
              text: 'All (${_pantryItems.length})',
            ),
            Tab(
              text: 'Expiring (${_expiringItems.length})',
            ),
            Tab(
              text: 'Low Stock (${_lowStockItems.length})',
            ),
            const Tab(
              text: 'Recipes',
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildAllItemsTab(),
          _buildExpiringTab(),
          _buildLowStockTab(),
          _buildRecipesTab(),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddItemDialog,
        icon: const Icon(
          Icons.add,
        ),
        label: const Text(
          'Add Item',
        ),
        backgroundColor: AppColors.primary,
      ),
    );
  }

  Widget _buildAllItemsTab() {
    return Column(
      children: [
        // Location filter
        Container(
          padding: const EdgeInsets.all(
            16,
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildLocationChip(
                  'all',
                  'All',
                  Icons.home,
                ),
                const SizedBox(
                  width: 8,
                ),
                _buildLocationChip(
                  'fridge',
                  'Fridge',
                  Icons.kitchen,
                ),
                const SizedBox(
                  width: 8,
                ),
                _buildLocationChip(
                  'freezer',
                  'Freezer',
                  Icons.ac_unit,
                ),
                const SizedBox(
                  width: 8,
                ),
                _buildLocationChip(
                  'pantry',
                  'Pantry',
                  Icons.inventory_2,
                ),
              ],
            ),
          ),
        ),
        // Items list
        Expanded(
          child: _filteredItems.isEmpty
              ? _buildEmptyState(
                  'No items in your pantry',
                  'Add items to track them',
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                  ),
                  itemCount: _filteredItems.length,
                  itemBuilder:
                      (
                        context,
                        index,
                      ) {
                        return _buildPantryItemCard(
                          _filteredItems[index],
                        );
                      },
                ),
        ),
      ],
    );
  }

  Widget _buildLocationChip(
    String value,
    String label,
    IconData icon,
  ) {
    final isSelected =
        _selectedLocation ==
        value;
    return GestureDetector(
      onTap: () => setState(
        () => _selectedLocation = value,
      ),
      child: AnimatedContainer(
        duration: AppTheme.animationFast,
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 10,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary
              : AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(
            20,
          ),
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : AppColors.borderLight,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected
                  ? Colors.white
                  : AppColors.textSecondaryLight,
            ),
            const SizedBox(
              width: 6,
            ),
            Text(
              label,
              style: AppTextStyles.labelMedium(
                color: isSelected
                    ? Colors.white
                    : AppColors.textSecondaryLight,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPantryItemCard(
    Map<
      String,
      dynamic
    >
    item,
  ) {
    final expiry =
        item['expiry_date']
            as DateTime;
    final status = _getFreshnessStatus(
      expiry,
    );
    final statusColor = _getFreshnessColor(
      status,
    );
    final daysUntil = expiry
        .difference(
          DateTime.now(),
        )
        .inDays;

    return Dismissible(
      key: Key(
        'pantry_${item['id']}',
      ),
      background: Container(
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(
          left: 20,
        ),
        color: AppColors.success,
        child: const Icon(
          Icons.check,
          color: Colors.white,
        ),
      ),
      secondaryBackground: Container(
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
            direction,
          ) {
            setState(
              () {
                _pantryItems.removeWhere(
                  (
                    i,
                  ) =>
                      i['id'] ==
                      item['id'],
                );
              },
            );
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(
              SnackBar(
                content: Text(
                  direction ==
                          DismissDirection.startToEnd
                      ? '${item['name']} marked as used'
                      : '${item['name']} removed',
                ),
                action: SnackBarAction(
                  label: 'Undo',
                  onPressed: () {
                    setState(
                      () => _pantryItems.add(
                        item,
                      ),
                    );
                  },
                ),
              ),
            );
          },
      child: Card(
        margin: const EdgeInsets.only(
          bottom: 12,
        ),
        child: ListTile(
          leading: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: statusColor.withOpacity(
                0.1,
              ),
              borderRadius: BorderRadius.circular(
                12,
              ),
            ),
            child: Center(
              child: Text(
                item['icon'],
                style: const TextStyle(
                  fontSize: 24,
                ),
              ),
            ),
          ),
          title: Row(
            children: [
              Expanded(
                child: Text(
                  item['name'],
                  style: AppTextStyles.titleSmall(),
                ),
              ),
              if (item['is_low_stock'])
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.warningLight,
                    borderRadius: BorderRadius.circular(
                      4,
                    ),
                  ),
                  child: Text(
                    'Low',
                    style: AppTextStyles.labelSmall(
                      color: AppColors.warning,
                    ),
                  ),
                ),
            ],
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${item['quantity']} ${item['unit']} • ${item['location']}',
              ),
              const SizedBox(
                height: 4,
              ),
              Row(
                children: [
                  Icon(
                    Icons.access_time,
                    size: 14,
                    color: statusColor,
                  ),
                  const SizedBox(
                    width: 4,
                  ),
                  Text(
                    status ==
                            'expired'
                        ? 'Expired ${-daysUntil} days ago'
                        : daysUntil ==
                              0
                        ? 'Expires today!'
                        : daysUntil ==
                              1
                        ? 'Expires tomorrow'
                        : 'Expires in $daysUntil days',
                    style: AppTextStyles.labelSmall(
                      color: statusColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
          trailing: IconButton(
            onPressed: () => _showEditItemDialog(
              item,
            ),
            icon: const Icon(
              Icons.edit_outlined,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildExpiringTab() {
    final allExpiring = [
      ..._expiredItems,
      ..._expiringItems,
    ];

    if (allExpiring.isEmpty) {
      return _buildEmptyState(
        'No items expiring soon! 🎉',
        'Your pantry items are all fresh',
      );
    }

    return ListView(
      padding: const EdgeInsets.all(
        16,
      ),
      children: [
        if (_expiredItems.isNotEmpty) ...[
          _buildSectionHeader(
            'Expired',
            AppColors.error,
            _expiredItems.length,
          ),
          ..._expiredItems.map(
            (
              item,
            ) => _buildPantryItemCard(
              item,
            ),
          ),
          const SizedBox(
            height: 16,
          ),
        ],
        if (_expiringItems.isNotEmpty) ...[
          _buildSectionHeader(
            'Expiring Soon',
            AppColors.warning,
            _expiringItems.length,
          ),
          ..._expiringItems.map(
            (
              item,
            ) => _buildPantryItemCard(
              item,
            ),
          ),
        ],
        const SizedBox(
          height: 16,
        ),
        // Recipe suggestions for expiring items
        Card(
          color: AppColors.accentSurface,
          child: Padding(
            padding: const EdgeInsets.all(
              16,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.lightbulb,
                      color: AppColors.accent,
                    ),
                    const SizedBox(
                      width: 8,
                    ),
                    Text(
                      'Use Before It Expires',
                      style: AppTextStyles.titleSmall(
                        color: AppColors.accentDark,
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 12,
                ),
                Text(
                  'AI suggests: Make a fresh spinach salad with eggs!',
                  style: AppTextStyles.bodyMedium(),
                ),
                const SizedBox(
                  height: 12,
                ),
                ElevatedButton.icon(
                  onPressed: _showRecipeSuggestions,
                  icon: const Icon(
                    Icons.restaurant_menu,
                    size: 18,
                  ),
                  label: const Text(
                    'View Recipe Ideas',
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLowStockTab() {
    if (_lowStockItems.isEmpty) {
      return _buildEmptyState(
        'All stocked up! 📦',
        'No items are running low',
      );
    }

    return ListView(
      padding: const EdgeInsets.all(
        16,
      ),
      children: [
        Card(
          color: AppColors.primarySurface,
          child: Padding(
            padding: const EdgeInsets.all(
              16,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.shopping_cart,
                      color: AppColors.primary,
                    ),
                    const SizedBox(
                      width: 8,
                    ),
                    Text(
                      'Auto-Generate Shopping List',
                      style: AppTextStyles.titleSmall(
                        color: AppColors.primaryDark,
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 8,
                ),
                Text(
                  '${_lowStockItems.length} items need restocking',
                  style: AppTextStyles.bodySmall(),
                ),
                const SizedBox(
                  height: 12,
                ),
                ElevatedButton.icon(
                  onPressed: _generateShoppingList,
                  icon: const Icon(
                    Icons.add_shopping_cart,
                    size: 18,
                  ),
                  label: const Text(
                    'Create Shopping List',
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(
          height: 16,
        ),
        ..._lowStockItems.map(
          (
            item,
          ) => _buildPantryItemCard(
            item,
          ),
        ),
      ],
    );
  }

  Widget _buildRecipesTab() {
    final recipes = [
      {
        'name': 'Spinach Omelette',
        'time': '15 min',
        'difficulty': 'Easy',
        'uses': [
          'Eggs',
          'Spinach',
        ],
        'missing': [],
        'image': '🍳',
      },
      {
        'name': 'Chicken Fried Rice',
        'time': '25 min',
        'difficulty': 'Medium',
        'uses': [
          'Chicken Breast',
          'Rice',
          'Eggs',
        ],
        'missing': [
          'Soy Sauce',
        ],
        'image': '🍛',
      },
      {
        'name': 'Yogurt Parfait',
        'time': '5 min',
        'difficulty': 'Easy',
        'uses': [
          'Yogurt',
        ],
        'missing': [
          'Granola',
          'Berries',
        ],
        'image': '🥣',
      },
    ];

    return ListView(
      padding: const EdgeInsets.all(
        16,
      ),
      children: [
        Card(
          color: AppColors.infoLight,
          child: Padding(
            padding: const EdgeInsets.all(
              16,
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.auto_awesome,
                  color: AppColors.info,
                ),
                const SizedBox(
                  width: 12,
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'AI Recipe Suggestions',
                        style: AppTextStyles.titleSmall(
                          color: AppColors.info,
                        ),
                      ),
                      Text(
                        'Based on your pantry items',
                        style: AppTextStyles.bodySmall(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(
          height: 16,
        ),
        ...recipes.map(
          (
            recipe,
          ) => _buildRecipeCard(
            recipe,
          ),
        ),
      ],
    );
  }

  Widget _buildRecipeCard(
    Map<
      String,
      dynamic
    >
    recipe,
  ) {
    final uses =
        recipe['uses']
            as List;
    final missing =
        recipe['missing']
            as List;

    return Card(
      margin: const EdgeInsets.only(
        bottom: 12,
      ),
      child: Padding(
        padding: const EdgeInsets.all(
          16,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  recipe['image'],
                  style: const TextStyle(
                    fontSize: 40,
                  ),
                ),
                const SizedBox(
                  width: 16,
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        recipe['name'],
                        style: AppTextStyles.titleMedium(),
                      ),
                      const SizedBox(
                        height: 4,
                      ),
                      Row(
                        children: [
                          const Icon(
                            Icons.access_time,
                            size: 14,
                            color: AppColors.textTertiaryLight,
                          ),
                          const SizedBox(
                            width: 4,
                          ),
                          Text(
                            recipe['time'],
                            style: AppTextStyles.bodySmall(),
                          ),
                          const SizedBox(
                            width: 12,
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.accentSurface,
                              borderRadius: BorderRadius.circular(
                                8,
                              ),
                            ),
                            child: Text(
                              recipe['difficulty'],
                              style: AppTextStyles.labelSmall(
                                color: AppColors.accent,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 12,
            ),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                ...uses.map(
                  (
                    item,
                  ) => Chip(
                    label: Text(
                      item,
                      style: AppTextStyles.labelSmall(
                        color: AppColors.success,
                      ),
                    ),
                    backgroundColor: AppColors.successLight,
                    padding: EdgeInsets.zero,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    avatar: const Icon(
                      Icons.check,
                      size: 14,
                      color: AppColors.success,
                    ),
                  ),
                ),
                ...missing.map(
                  (
                    item,
                  ) => Chip(
                    label: Text(
                      item,
                      style: AppTextStyles.labelSmall(
                        color: AppColors.warning,
                      ),
                    ),
                    backgroundColor: AppColors.warningLight,
                    padding: EdgeInsets.zero,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    avatar: const Icon(
                      Icons.add,
                      size: 14,
                      color: AppColors.warning,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 12,
            ),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {},
                    child: const Text(
                      'View Recipe',
                    ),
                  ),
                ),
                const SizedBox(
                  width: 8,
                ),
                if (missing.isNotEmpty)
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {},
                      child: const Text(
                        'Add Missing',
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

  Widget _buildSectionHeader(
    String title,
    Color color,
    int count,
  ) {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: 12,
      ),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 20,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(
                2,
              ),
            ),
          ),
          const SizedBox(
            width: 8,
          ),
          Text(
            title,
            style: AppTextStyles.titleSmall(
              color: color,
            ),
          ),
          const SizedBox(
            width: 8,
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 8,
              vertical: 2,
            ),
            decoration: BoxDecoration(
              color: color.withOpacity(
                0.1,
              ),
              borderRadius: BorderRadius.circular(
                10,
              ),
            ),
            child: Text(
              '$count',
              style: AppTextStyles.labelSmall(
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(
    String title,
    String subtitle,
  ) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.inventory_2_outlined,
            size: 64,
            color: AppColors.textTertiaryLight,
          ),
          const SizedBox(
            height: 16,
          ),
          Text(
            title,
            style: AppTextStyles.titleMedium(),
          ),
          const SizedBox(
            height: 8,
          ),
          Text(
            subtitle,
            style: AppTextStyles.bodySmall(),
          ),
        ],
      ),
    );
  }

  void _showAddItemDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(
            20,
          ),
        ),
      ),
      builder:
          (
            ctx,
          ) => Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(
                ctx,
              ).viewInsets.bottom,
              left: 20,
              right: 20,
              top: 20,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Add Pantry Item',
                  style: AppTextStyles.headlineSmall(),
                ),
                const SizedBox(
                  height: 20,
                ),
                TextField(
                  decoration: const InputDecoration(
                    labelText: 'Item Name',
                    hintText: 'e.g., Organic Milk',
                    prefixIcon: Icon(
                      Icons.inventory_2,
                    ),
                  ),
                ),
                const SizedBox(
                  height: 16,
                ),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Quantity',
                          hintText: '1',
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 16,
                    ),
                    Expanded(
                      child:
                          DropdownButtonFormField<
                            String
                          >(
                            decoration: const InputDecoration(
                              labelText: 'Unit',
                            ),
                            value: 'unit',
                            items: const [
                              DropdownMenuItem(
                                value: 'unit',
                                child: Text(
                                  'unit',
                                ),
                              ),
                              DropdownMenuItem(
                                value: 'pcs',
                                child: Text(
                                  'pcs',
                                ),
                              ),
                              DropdownMenuItem(
                                value: 'kg',
                                child: Text(
                                  'kg',
                                ),
                              ),
                              DropdownMenuItem(
                                value: 'g',
                                child: Text(
                                  'g',
                                ),
                              ),
                              DropdownMenuItem(
                                value: 'L',
                                child: Text(
                                  'L',
                                ),
                              ),
                              DropdownMenuItem(
                                value: 'ml',
                                child: Text(
                                  'ml',
                                ),
                              ),
                            ],
                            onChanged:
                                (
                                  v,
                                ) {},
                          ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 16,
                ),
                DropdownButtonFormField<
                  String
                >(
                  decoration: const InputDecoration(
                    labelText: 'Location',
                    prefixIcon: Icon(
                      Icons.location_on,
                    ),
                  ),
                  value: 'pantry',
                  items: const [
                    DropdownMenuItem(
                      value: 'pantry',
                      child: Text(
                        'Pantry',
                      ),
                    ),
                    DropdownMenuItem(
                      value: 'fridge',
                      child: Text(
                        'Fridge',
                      ),
                    ),
                    DropdownMenuItem(
                      value: 'freezer',
                      child: Text(
                        'Freezer',
                      ),
                    ),
                  ],
                  onChanged:
                      (
                        v,
                      ) {},
                ),
                const SizedBox(
                  height: 16,
                ),
                TextField(
                  decoration: const InputDecoration(
                    labelText: 'Expiry Date',
                    prefixIcon: Icon(
                      Icons.event,
                    ),
                    hintText: 'Select date',
                  ),
                  readOnly: true,
                  onTap: () async {
                    await showDatePicker(
                      context: context,
                      initialDate: DateTime.now().add(
                        const Duration(
                          days: 7,
                        ),
                      ),
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(
                        const Duration(
                          days: 365,
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(
                  height: 24,
                ),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(
                        ctx,
                      );
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Item added to pantry',
                          ),
                        ),
                      );
                    },
                    child: const Text(
                      'Add Item',
                    ),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
              ],
            ),
          ),
    );
  }

  void _showEditItemDialog(
    Map<
      String,
      dynamic
    >
    item,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(
            20,
          ),
        ),
      ),
      builder:
          (
            ctx,
          ) => Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(
                ctx,
              ).viewInsets.bottom,
              left: 20,
              right: 20,
              top: 20,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Edit ${item['name']}',
                  style: AppTextStyles.headlineSmall(),
                ),
                const SizedBox(
                  height: 20,
                ),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Quantity',
                          hintText: '${item['quantity']}',
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 16,
                    ),
                    Expanded(
                      child:
                          DropdownButtonFormField<
                            String
                          >(
                            decoration: const InputDecoration(
                              labelText: 'Unit',
                            ),
                            value: item['unit'],
                            items: const [
                              DropdownMenuItem(
                                value: 'unit',
                                child: Text(
                                  'unit',
                                ),
                              ),
                              DropdownMenuItem(
                                value: 'pcs',
                                child: Text(
                                  'pcs',
                                ),
                              ),
                              DropdownMenuItem(
                                value: 'kg',
                                child: Text(
                                  'kg',
                                ),
                              ),
                              DropdownMenuItem(
                                value: 'g',
                                child: Text(
                                  'g',
                                ),
                              ),
                              DropdownMenuItem(
                                value: 'L',
                                child: Text(
                                  'L',
                                ),
                              ),
                              DropdownMenuItem(
                                value: 'ml',
                                child: Text(
                                  'ml',
                                ),
                              ),
                            ],
                            onChanged:
                                (
                                  v,
                                ) {},
                          ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 24,
                ),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.pop(
                            ctx,
                          );
                        },
                        child: const Text(
                          'Cancel',
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 12,
                    ),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(
                            ctx,
                          );
                          ScaffoldMessenger.of(
                            context,
                          ).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Item updated',
                              ),
                            ),
                          );
                        },
                        child: const Text(
                          'Save',
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 20,
                ),
              ],
            ),
          ),
    );
  }

  void _showRecipeSuggestions() {
    _tabController.animateTo(
      3,
    ); // Switch to recipes tab
  }

  void _generateShoppingList() {
    showDialog(
      context: context,
      builder:
          (
            ctx,
          ) => AlertDialog(
            title: const Text(
              'Generate Shopping List',
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Add these items to your shopping list?',
                ),
                const SizedBox(
                  height: 16,
                ),
                ..._lowStockItems.map(
                  (
                    item,
                  ) => Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 4,
                    ),
                    child: Row(
                      children: [
                        Text(
                          item['icon'],
                          style: const TextStyle(
                            fontSize: 20,
                          ),
                        ),
                        const SizedBox(
                          width: 8,
                        ),
                        Text(
                          item['name'],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
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
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(
                    ctx,
                  );
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Shopping list created!',
                      ),
                    ),
                  );
                },
                child: const Text(
                  'Create List',
                ),
              ),
            ],
          ),
    );
  }
}
