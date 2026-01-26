import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../../config/theme/app_text_styles.dart';
import '../../../../config/theme/app_theme.dart';
import '../../../profile/data/user_service.dart';

class StoreCard extends StatefulWidget {
  final Map<String, dynamic> store;
  final bool isLarge;

  const StoreCard({super.key, required this.store, this.isLarge = false});

  @override
  State<StoreCard> createState() => _StoreCardState();
}

class _StoreCardState extends State<StoreCard> {
  final _userService = UserService();
  bool _isFavorite = false;

  void _toggleFavorite() async {
    setState(() => _isFavorite = !_isFavorite);
    try {
      await _userService.toggleFavorite('stores', widget.store['id']);
    } catch (e) {
      // Revert if failed
      if (mounted) {
        setState(() => _isFavorite = !_isFavorite);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update favorite: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () => context.push('/store/${widget.store['id']}'),
      child: Container(
        width: widget.isLarge ? 280 : 200,
        margin: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(16),
          boxShadow: AppTheme.shadowSm,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image & Favorite
            Stack(
              children: [
                Container(
                  height: widget.isLarge ? 140 : 100,
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(16),
                    ),
                    child:
                        (widget.store['image_url'] != null ||
                            widget.store['logo_url'] != null)
                        ? Image.network(
                            widget.store['image_url'] ??
                                widget.store['logo_url'],
                            fit: BoxFit.cover,
                            width: double.infinity,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: AppColors.primarySurface,
                                child: const Center(
                                  child: Icon(
                                    Icons.store,
                                    size: 40,
                                    color: AppColors.primary,
                                  ),
                                ),
                              );
                            },
                          )
                        : Container(
                            color: AppColors.primarySurface,
                            child: const Center(
                              child: Icon(
                                Icons.store,
                                size: 40,
                                color: AppColors.primary,
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
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: AppTheme.shadowSm,
                      ),
                      child: Icon(
                        _isFavorite ? Icons.favorite : Icons.favorite_border,
                        size: 18,
                        color: _isFavorite
                            ? AppColors.error
                            : AppColors.textTertiaryLight,
                      ),
                    ),
                  ),
                ),
                if (widget.store['rating'] != null)
                  Positioned(
                    bottom: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.star,
                            size: 14,
                            color: AppColors.warning,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${widget.store['rating']}',
                            style: AppTextStyles.labelSmall().copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),

            // Info
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.store['name'],
                    style: AppTextStyles.titleSmall(
                      color: isDark ? AppColors.textPrimaryDark : null,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on,
                        size: 14,
                        color: AppColors.textTertiaryLight,
                      ),
                      const SizedBox(width: 2),
                      Expanded(
                        child: Text(
                          widget.store['distance_km'] != null
                              ? '${widget.store['distance_km']} km away'
                              : 'Nearby',
                          style: AppTextStyles.bodySmall(
                            color: isDark
                                ? AppColors.textSecondaryDark
                                : AppColors.textSecondaryLight,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
