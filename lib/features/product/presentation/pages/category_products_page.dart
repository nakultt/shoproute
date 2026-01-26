import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../../config/theme/app_text_styles.dart';

/// Category Products Page with filters
class CategoryProductsPage extends StatefulWidget {
  final int categoryId;
  final String categoryName;

  const CategoryProductsPage({
    super.key,
    required this.categoryId,
    required this.categoryName,
  });

  @override
  State<CategoryProductsPage> createState() => _CategoryProductsPageState();
}

class _CategoryProductsPageState extends State<CategoryProductsPage> {
  String _sortBy = 'distance';
  final List<String> _activeFilters = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: Text(widget.categoryName),
        actions: [
          IconButton(
            onPressed: () {
              // TODO: Open filter bottom sheet
            },
            icon: const Icon(Icons.filter_list),
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter chips
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _FilterChip(
                    label: 'In Stock',
                    isSelected: _activeFilters.contains('in_stock'),
                    onTap: () => _toggleFilter('in_stock'),
                  ),
                  _FilterChip(
                    label: 'On Sale',
                    isSelected: _activeFilters.contains('on_sale'),
                    onTap: () => _toggleFilter('on_sale'),
                  ),
                  _FilterChip(
                    label: 'Nearby',
                    isSelected: _activeFilters.contains('nearby'),
                    onTap: () => _toggleFilter('nearby'),
                  ),
                  _FilterChip(
                    label: 'Highly Rated',
                    isSelected: _activeFilters.contains('rated'),
                    onTap: () => _toggleFilter('rated'),
                  ),
                ],
              ),
            ),
          ),
          // Sort dropdown
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Text('Sort by: ', style: AppTextStyles.bodyMedium()),
                DropdownButton<String>(
                  value: _sortBy,
                  underline: const SizedBox(),
                  items: const [
                    DropdownMenuItem(
                      value: 'distance',
                      child: Text('Distance'),
                    ),
                    DropdownMenuItem(
                      value: 'price_asc',
                      child: Text('Price: Low to High'),
                    ),
                    DropdownMenuItem(
                      value: 'price_desc',
                      child: Text('Price: High to Low'),
                    ),
                    DropdownMenuItem(value: 'rating', child: Text('Rating')),
                  ],
                  onChanged: (value) => setState(() => _sortBy = value!),
                ),
              ],
            ),
          ),
          // Products list
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: 10,
              itemBuilder: (context, index) => Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: AppColors.primarySurface,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.image, color: AppColors.primary),
                  ),
                  title: Text('Product ${index + 1}'),
                  subtitle: Text(
                    'Store • ${(index * 0.5 + 0.5).toStringAsFixed(1)} km',
                  ),
                  trailing: Text(
                    '\$${(index * 2 + 4.99).toStringAsFixed(2)}',
                    style: AppTextStyles.price(),
                  ),
                  onTap: () => context.push('/product/$index'),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _toggleFilter(String filter) {
    setState(() {
      if (_activeFilters.contains(filter)) {
        _activeFilters.remove(filter);
      } else {
        _activeFilters.add(filter);
      }
    });
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.borderLight,
          ),
        ),
        child: Text(
          label,
          style: AppTextStyles.labelMedium(
            color: isSelected ? Colors.white : AppColors.textSecondaryLight,
          ),
        ),
      ),
    );
  }
}
