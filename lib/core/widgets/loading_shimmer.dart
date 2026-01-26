import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../../config/theme/app_colors.dart';

/// Shimmer loading placeholder for content
class LoadingShimmer extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;

  const LoadingShimmer({
    super.key,
    this.width = double.infinity,
    this.height = 100,
    this.borderRadius = 12,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Shimmer.fromColors(
      baseColor: isDark ? AppColors.surfaceDark : Colors.grey[300]!,
      highlightColor: isDark
          ? AppColors.surfaceElevatedDark
          : Colors.grey[100]!,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }
}

/// Shimmer for product card
class ProductCardShimmer extends StatelessWidget {
  const ProductCardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const LoadingShimmer(height: 120, borderRadius: 12),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const LoadingShimmer(height: 14, width: 100),
                const SizedBox(height: 8),
                const LoadingShimmer(height: 12, width: 60),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const LoadingShimmer(height: 16, width: 50),
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        shape: BoxShape.circle,
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
}

/// Shimmer for list item
class ListItemShimmer extends StatelessWidget {
  const ListItemShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const LoadingShimmer(width: 60, height: 60, borderRadius: 8),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const LoadingShimmer(height: 14, width: double.infinity),
                const SizedBox(height: 8),
                LoadingShimmer(
                  height: 12,
                  width: MediaQuery.of(context).size.width * 0.4,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
