import 'package:flutter/material.dart';
import '../../../config/theme/app_colors.dart';
import '../../../config/theme/app_text_styles.dart';

/// A reusable rating widget that allows users to rate products/stores
class RatingWidget
    extends
        StatefulWidget {
  final double initialRating;
  final int totalRatings;
  final bool allowRating;
  final Function(
    double rating,
    String? review,
  )?
  onRatingSubmitted;
  final bool showDistribution;
  final Map<
    int,
    int
  >?
  distribution;

  const RatingWidget({
    super.key,
    this.initialRating = 0,
    this.totalRatings = 0,
    this.allowRating = true,
    this.onRatingSubmitted,
    this.showDistribution = false,
    this.distribution,
  });

  @override
  State<
    RatingWidget
  >
  createState() => _RatingWidgetState();
}

class _RatingWidgetState
    extends
        State<
          RatingWidget
        > {
  double _selectedRating = 0;
  bool _hasRated = false;

  @override
  void initState() {
    super.initState();
    _selectedRating = widget.initialRating;
  }

  void _showRatingDialog() {
    double tempRating =
        _selectedRating >
            0
        ? _selectedRating
        : 5;
    final reviewController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (
            ctx,
          ) => StatefulBuilder(
            builder:
                (
                  context,
                  setModalState,
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
                    children: [
                      Text(
                        'Rate this item',
                        style: AppTextStyles.headlineSmall(),
                      ),
                      const SizedBox(
                        height: 24,
                      ),
                      // Star rating
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          5,
                          (
                            index,
                          ) {
                            final starValue =
                                index +
                                1;
                            return GestureDetector(
                              onTap: () => setModalState(
                                () => tempRating = starValue.toDouble(),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 4,
                                ),
                                child: Icon(
                                  starValue <=
                                          tempRating
                                      ? Icons.star
                                      : Icons.star_border,
                                  color: AppColors.warning,
                                  size: 40,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(
                        height: 8,
                      ),
                      Text(
                        _getRatingText(
                          tempRating,
                        ),
                        style: AppTextStyles.bodyMedium(
                          color: AppColors.textSecondaryLight,
                        ),
                      ),
                      const SizedBox(
                        height: 24,
                      ),
                      // Review text field
                      TextFormField(
                        controller: reviewController,
                        maxLines: 3,
                        maxLength: 500,
                        decoration: const InputDecoration(
                          hintText: 'Write a review (optional)',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(
                        height: 24,
                      ),
                      // Submit button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            setState(
                              () {
                                _selectedRating = tempRating;
                                _hasRated = true;
                              },
                            );
                            widget.onRatingSubmitted?.call(
                              tempRating,
                              reviewController.text.isNotEmpty
                                  ? reviewController.text
                                  : null,
                            );
                            Navigator.pop(
                              ctx,
                            );
                            ScaffoldMessenger.of(
                              context,
                            ).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Thank you for your rating!',
                                ),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            padding: const EdgeInsets.symmetric(
                              vertical: 16,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                12,
                              ),
                            ),
                          ),
                          child: const Text(
                            'Submit Rating',
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
          ),
    );
  }

  String _getRatingText(
    double rating,
  ) {
    if (rating <=
        1)
      return 'Poor';
    if (rating <=
        2)
      return 'Fair';
    if (rating <=
        3)
      return 'Good';
    if (rating <=
        4)
      return 'Very Good';
    return 'Excellent';
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Rating display row
        Row(
          children: [
            // Stars
            Row(
              children: List.generate(
                5,
                (
                  index,
                ) {
                  final starValue =
                      index +
                      1;
                  final rating = _hasRated
                      ? _selectedRating
                      : widget.initialRating;
                  IconData icon;
                  if (starValue <=
                      rating.floor()) {
                    icon = Icons.star;
                  } else if (starValue -
                          0.5 <=
                      rating) {
                    icon = Icons.star_half;
                  } else {
                    icon = Icons.star_border;
                  }
                  return Icon(
                    icon,
                    color: AppColors.warning,
                    size: 20,
                  );
                },
              ),
            ),
            const SizedBox(
              width: 8,
            ),
            // Rating value
            Text(
              (_hasRated
                      ? _selectedRating
                      : widget.initialRating)
                  .toStringAsFixed(
                    1,
                  ),
              style: AppTextStyles.titleMedium(
                color: isDark
                    ? AppColors.textPrimaryDark
                    : null,
              ),
            ),
            const SizedBox(
              width: 4,
            ),
            Text(
              '(${widget.totalRatings} reviews)',
              style: AppTextStyles.bodySmall(
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
              ),
            ),
            const Spacer(),
            // Rate button
            if (widget.allowRating &&
                !_hasRated)
              TextButton(
                onPressed: _showRatingDialog,
                child: const Text(
                  'Rate',
                ),
              ),
            if (_hasRated)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.successLight,
                  borderRadius: BorderRadius.circular(
                    12,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.check,
                      size: 14,
                      color: AppColors.success,
                    ),
                    const SizedBox(
                      width: 4,
                    ),
                    Text(
                      'Rated',
                      style: AppTextStyles.labelSmall(
                        color: AppColors.success,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),

        // Rating distribution
        if (widget.showDistribution &&
            widget.distribution !=
                null) ...[
          const SizedBox(
            height: 16,
          ),
          ...List.generate(
            5,
            (
              index,
            ) {
              final star =
                  5 -
                  index;
              final count =
                  widget.distribution![star] ??
                  0;
              final total = widget.distribution!.values.fold(
                0,
                (
                  a,
                  b,
                ) =>
                    a +
                    b,
              );
              final percentage =
                  total >
                      0
                  ? count /
                        total
                  : 0.0;

              return Padding(
                padding: const EdgeInsets.only(
                  bottom: 4,
                ),
                child: Row(
                  children: [
                    Text(
                      '$star',
                      style: AppTextStyles.bodySmall(),
                    ),
                    const SizedBox(
                      width: 4,
                    ),
                    const Icon(
                      Icons.star,
                      size: 12,
                      color: AppColors.warning,
                    ),
                    const SizedBox(
                      width: 8,
                    ),
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(
                          4,
                        ),
                        child: LinearProgressIndicator(
                          value: percentage,
                          backgroundColor: isDark
                              ? AppColors.borderDark
                              : AppColors.borderLight,
                          valueColor: const AlwaysStoppedAnimation(
                            AppColors.warning,
                          ),
                          minHeight: 8,
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 8,
                    ),
                    SizedBox(
                      width: 30,
                      child: Text(
                        '$count',
                        style: AppTextStyles.bodySmall(
                          color: isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondaryLight,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ],
    );
  }
}

/// A simple inline star rating display
class StarRating
    extends
        StatelessWidget {
  final double rating;
  final double size;
  final Color? color;

  const StarRating({
    super.key,
    required this.rating,
    this.size = 16,
    this.color,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(
        5,
        (
          index,
        ) {
          final starValue =
              index +
              1;
          IconData icon;
          if (starValue <=
              rating.floor()) {
            icon = Icons.star;
          } else if (starValue -
                  0.5 <=
              rating) {
            icon = Icons.star_half;
          } else {
            icon = Icons.star_border;
          }
          return Icon(
            icon,
            color:
                color ??
                AppColors.warning,
            size: size,
          );
        },
      ),
    );
  }
}
