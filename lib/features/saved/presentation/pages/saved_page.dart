import 'package:flutter/material.dart';
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

  @override
  Widget build(
    BuildContext context,
  ) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: Text(
          'Saved',
          style: AppTextStyles.titleLarge(),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textTertiaryLight,
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
          _buildProductsTab(),
          _buildStoresTab(),
          _buildListsTab(),
        ],
      ),
    );
  }

  Widget _buildProductsTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(
        16,
      ),
      itemCount: 5,
      itemBuilder:
          (
            context,
            index,
          ) => Dismissible(
            key: Key(
              'product_$index',
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
            child: Card(
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
                  'Saved Product ${index + 1}',
                ),
                subtitle: Text(
                  '\$${(4.99 + index * 2).toStringAsFixed(2)} • Fresh Mart',
                ),
                trailing: IconButton(
                  onPressed: () {},
                  icon: const Icon(
                    Icons.add_shopping_cart,
                  ),
                ),
              ),
            ),
          ),
    );
  }

  Widget _buildStoresTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(
        16,
      ),
      itemCount: 3,
      itemBuilder:
          (
            context,
            index,
          ) => Card(
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
                'Store ${index + 1}',
              ),
              subtitle: Row(
                children: [
                  const Icon(
                    Icons.star,
                    size: 14,
                    color: AppColors.warning,
                  ),
                  Text(
                    ' 4.${5 + index} • ${(1.5 + index * 0.5).toStringAsFixed(1)} km',
                  ),
                ],
              ),
              trailing: OutlinedButton(
                onPressed: () {},
                child: const Text(
                  'Directions',
                ),
              ),
            ),
          ),
    );
  }

  Widget _buildListsTab() {
    return Scaffold(
      body: ListView.builder(
        padding: const EdgeInsets.all(
          16,
        ),
        itemCount: 2,
        itemBuilder:
            (
              context,
              index,
            ) => Card(
              margin: const EdgeInsets.only(
                bottom: 12,
              ),
              child: ListTile(
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
                  index ==
                          0
                      ? 'Weekly Groceries'
                      : 'Party Supplies',
                ),
                subtitle: Text(
                  '${index == 0 ? 8 : 5} items',
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(
                        Icons.route,
                      ),
                      tooltip: 'Optimize Route',
                    ),
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(
                        Icons.share,
                      ),
                    ),
                  ],
                ),
              ),
            ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Create new list
        },
        child: const Icon(
          Icons.add,
        ),
      ),
    );
  }
}
