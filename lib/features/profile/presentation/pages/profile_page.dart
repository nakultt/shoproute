import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../../config/theme/app_text_styles.dart';
import '../../../../config/theme/app_theme.dart';
import '../../../../config/routes/app_router.dart';

/// Profile Page
class ProfilePage
    extends
        StatelessWidget {
  const ProfilePage({
    super.key,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: CustomScrollView(
        slivers: [
          // Header with gradient
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: AppColors.primaryGradient,
                ),
                child: SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(
                        height: 20,
                      ),
                      // Avatar
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: AppTheme.shadowMd,
                        ),
                        child: const Icon(
                          Icons.person,
                          size: 40,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(
                        height: 12,
                      ),
                      Text(
                        'John Doe',
                        style: AppTextStyles.headlineMedium(
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        'john.doe@email.com',
                        style: AppTextStyles.bodySmall(
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            leading: IconButton(
              onPressed: () => context.pop(),
              icon: const Icon(
                Icons.arrow_back,
                color: Colors.white,
              ),
            ),
            actions: [
              IconButton(
                onPressed: () {
                  // TODO: Edit profile
                },
                icon: const Icon(
                  Icons.edit,
                  color: Colors.white,
                ),
              ),
            ],
          ),

          // Stats
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(
                16,
              ),
              child: Row(
                children: [
                  _StatCard(
                    icon: Icons.shopping_cart,
                    value: '24',
                    label: 'Orders',
                  ),
                  const SizedBox(
                    width: 12,
                  ),
                  _StatCard(
                    icon: Icons.savings,
                    value: '\$156',
                    label: 'Saved',
                  ),
                  const SizedBox(
                    width: 12,
                  ),
                  _StatCard(
                    icon: Icons.store,
                    value: '8',
                    label: 'Favorites',
                  ),
                  const SizedBox(
                    width: 12,
                  ),
                  _StatCard(
                    icon: Icons.rate_review,
                    value: '12',
                    label: 'Reviews',
                  ),
                ],
              ),
            ),
          ),

          // Menu items
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
              ),
              child: Column(
                children: [
                  _ProfileMenuItem(
                    icon: Icons.history,
                    title: 'Order History',
                    onTap: () {},
                  ),
                  _ProfileMenuItem(
                    icon: Icons.location_on_outlined,
                    title: 'Saved Addresses',
                    onTap: () {},
                  ),
                  _ProfileMenuItem(
                    icon: Icons.payment,
                    title: 'Payment Methods',
                    onTap: () {},
                  ),
                  _ProfileMenuItem(
                    icon: Icons.notifications_outlined,
                    title: 'Notifications',
                    badge: '3',
                    onTap: () {},
                  ),
                  _ProfileMenuItem(
                    icon: Icons.help_outline,
                    title: 'Help & Support',
                    onTap: () {},
                  ),
                  const SizedBox(
                    height: 24,
                  ),
                  _ProfileMenuItem(
                    icon: Icons.logout,
                    title: 'Logout',
                    iconColor: AppColors.error,
                    titleColor: AppColors.error,
                    onTap: () {
                      showDialog(
                        context: context,
                        builder:
                            (
                              ctx,
                            ) => AlertDialog(
                              title: const Text(
                                'Logout',
                              ),
                              content: const Text(
                                'Are you sure you want to logout?',
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
                                    context.go(
                                      AppRoutes.login,
                                    );
                                  },
                                  child: const Text(
                                    'Logout',
                                  ),
                                ),
                              ],
                            ),
                      );
                    },
                  ),
                  const SizedBox(
                    height: 40,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard
    extends
        StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(
          12,
        ),
        decoration: BoxDecoration(
          color: AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(
            12,
          ),
          boxShadow: AppTheme.shadowSm,
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: AppColors.primary,
              size: 24,
            ),
            const SizedBox(
              height: 8,
            ),
            Text(
              value,
              style: AppTextStyles.titleLarge(),
            ),
            Text(
              label,
              style: AppTextStyles.bodySmall(),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileMenuItem
    extends
        StatelessWidget {
  final IconData icon;
  final String title;
  final String? badge;
  final VoidCallback onTap;
  final Color? iconColor;
  final Color? titleColor;

  const _ProfileMenuItem({
    required this.icon,
    required this.title,
    required this.onTap,
    this.badge,
    this.iconColor,
    this.titleColor,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return Card(
      margin: const EdgeInsets.only(
        bottom: 8,
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color:
              iconColor ??
              AppColors.primary,
        ),
        title: Text(
          title,
          style: AppTextStyles.bodyLarge(
            color: titleColor,
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (badge !=
                null)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.error,
                  borderRadius: BorderRadius.circular(
                    12,
                  ),
                ),
                child: Text(
                  badge!,
                  style: AppTextStyles.badge(),
                ),
              ),
            const SizedBox(
              width: 8,
            ),
            const Icon(
              Icons.chevron_right,
              color: AppColors.textTertiaryLight,
            ),
          ],
        ),
        onTap: onTap,
      ),
    );
  }
}
