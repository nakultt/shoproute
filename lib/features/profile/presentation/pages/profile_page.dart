import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../../config/theme/app_text_styles.dart';
import '../../../../config/theme/app_theme.dart';
import '../../../../config/routes/app_router.dart';

/// Profile Page
class ProfilePage
    extends
        StatefulWidget {
  const ProfilePage({
    super.key,
  });

  @override
  State<
    ProfilePage
  >
  createState() => _ProfilePageState();
}

class _ProfilePageState
    extends
        State<
          ProfilePage
        > {
  String _userName = 'John Doe';
  String _userEmail = 'john.doe@email.com';
  String? _avatarUrl;

  void _showEditProfileDialog() {
    final nameController = TextEditingController(
      text: _userName,
    );
    final emailController = TextEditingController(
      text: _userEmail,
    );

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
            ),
            decoration: const BoxDecoration(
              color: AppColors.surfaceLight,
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(
                  24,
                ),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(
                24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Edit Profile',
                        style: AppTextStyles.headlineSmall(),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(
                          ctx,
                        ),
                        icon: const Icon(
                          Icons.close,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 24,
                  ),
                  // Avatar editor
                  Center(
                    child: GestureDetector(
                      onTap: () {
                        // TODO: Implement image picker
                        ScaffoldMessenger.of(
                          context,
                        ).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Image picker coming soon!',
                            ),
                          ),
                        );
                      },
                      child: Stack(
                        children: [
                          Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              color: AppColors.primarySurface,
                              shape: BoxShape.circle,
                              image:
                                  _avatarUrl !=
                                      null
                                  ? DecorationImage(
                                      image: NetworkImage(
                                        _avatarUrl!,
                                      ),
                                      fit: BoxFit.cover,
                                    )
                                  : null,
                            ),
                            child:
                                _avatarUrl ==
                                    null
                                ? const Icon(
                                    Icons.person,
                                    size: 50,
                                    color: AppColors.primary,
                                  )
                                : null,
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.all(
                                8,
                              ),
                              decoration: const BoxDecoration(
                                color: AppColors.primary,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.camera_alt,
                                size: 16,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 24,
                  ),
                  Text(
                    'Full Name',
                    style: AppTextStyles.labelLarge(),
                  ),
                  const SizedBox(
                    height: 8,
                  ),
                  TextFormField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      hintText: 'Enter your name',
                      prefixIcon: Icon(
                        Icons.person_outline,
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 16,
                  ),
                  Text(
                    'Email',
                    style: AppTextStyles.labelLarge(),
                  ),
                  const SizedBox(
                    height: 8,
                  ),
                  TextFormField(
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      hintText: 'Enter your email',
                      prefixIcon: Icon(
                        Icons.email_outlined,
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
                        setState(
                          () {
                            _userName = nameController.text;
                            _userEmail = emailController.text;
                          },
                        );
                        Navigator.pop(
                          ctx,
                        );
                        ScaffoldMessenger.of(
                          context,
                        ).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Profile updated successfully!',
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
                        'Save Changes',
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 16,
                  ),
                ],
              ),
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
                          image:
                              _avatarUrl !=
                                  null
                              ? DecorationImage(
                                  image: NetworkImage(
                                    _avatarUrl!,
                                  ),
                                  fit: BoxFit.cover,
                                )
                              : null,
                        ),
                        child:
                            _avatarUrl ==
                                null
                            ? const Icon(
                                Icons.person,
                                size: 40,
                                color: AppColors.primary,
                              )
                            : null,
                      ),
                      const SizedBox(
                        height: 12,
                      ),
                      Text(
                        _userName,
                        style: AppTextStyles.headlineMedium(
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        _userEmail,
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
              onPressed: () {
                if (context.canPop()) {
                  context.pop();
                } else {
                  context.go(
                    AppRoutes.home,
                  );
                }
              },
              icon: const Icon(
                Icons.arrow_back,
                color: Colors.white,
              ),
            ),
            actions: [
              IconButton(
                onPressed: _showEditProfileDialog,
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
