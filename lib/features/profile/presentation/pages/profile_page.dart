import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../auth/data/auth_service.dart';
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
  String _userName = 'Loading...';
  String _userEmail = '...';
  String _userPhone = '...';
  String? _avatarUrl;
  final _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<
    void
  >
  _loadUserProfile() async {
    try {
      final user = await _authService.getCurrentUser();
      if (mounted) {
        setState(
          () {
            _userName =
                user['full_name'] ??
                'User';
            _userEmail =
                user['email'] ??
                '';
            _userPhone =
                user['phone'] ??
                'Not set';
            _avatarUrl = user['profile_picture'];
          },
        );
      }
    } catch (
      e
    ) {
      print(
        'Error loading profile: $e',
      );
    }
  }

  void _showEditProfileDialog() {
    final nameController = TextEditingController(
      text: _userName,
    );
    final emailController = TextEditingController(
      text: _userEmail,
    );
    // Note: Phone number editing not implemented in this dialog yet

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
                  // Avatar editor code remains same...
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

          // Personal Information Section
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(
                16,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Personal Information',
                    style: AppTextStyles.titleLarge(
                      color: isDark
                          ? Colors.white
                          : AppColors.textPrimaryLight,
                    ),
                  ),
                  const SizedBox(
                    height: 16,
                  ),

                  // Email Tile
                  _ProfileInfoTile(
                    icon: Icons.email_outlined,
                    label: 'Email',
                    value: _userEmail,
                  ),
                  const SizedBox(
                    height: 12,
                  ),

                  // Phone Tile
                  _ProfileInfoTile(
                    icon: Icons.phone_outlined,
                    label: 'Phone Number',
                    value: _userPhone,
                  ),
                ],
              ),
            ),
          ),

          // Logout Button
          SliverFillRemaining(
            hasScrollBody: false,
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.all(
                  16,
                ),
                child: SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {
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
                    icon: const Icon(
                      Icons.logout,
                      color: AppColors.error,
                    ),
                    label: const Text(
                      'Logout',
                      style: TextStyle(
                        color: AppColors.error,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        vertical: 16,
                      ),
                      side: const BorderSide(
                        color: AppColors.error,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          12,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileInfoTile
    extends
        StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _ProfileInfoTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return Container(
      padding: const EdgeInsets.all(
        16,
      ),
      decoration: BoxDecoration(
        color:
            Theme.of(
                  context,
                ).brightness ==
                Brightness.dark
            ? AppColors.surfaceDark
            : Colors.white, // Using white for better contrast in light mode
        borderRadius: BorderRadius.circular(
          12,
        ),
        boxShadow: AppTheme.shadowSm,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(
              10,
            ),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(
                0.1,
              ),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: AppColors.primary,
              size: 20,
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
                  label,
                  style: AppTextStyles.bodySmall(
                    color: AppColors.textTertiaryLight,
                  ),
                ),
                const SizedBox(
                  height: 4,
                ),
                Text(
                  value,
                  style: AppTextStyles.bodyLarge(
                    color:
                        Theme.of(
                              context,
                            ).brightness ==
                            Brightness.dark
                        ? Colors.white
                        : AppColors.textPrimaryLight,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
