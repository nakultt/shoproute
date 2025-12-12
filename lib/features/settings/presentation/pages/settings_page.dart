import 'package:flutter/material.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../../config/theme/app_text_styles.dart';
import '../../../../config/constants/app_constants.dart';

/// Settings Page
class SettingsPage
    extends
        StatefulWidget {
  const SettingsPage({
    super.key,
  });

  @override
  State<
    SettingsPage
  >
  createState() => _SettingsPageState();
}

class _SettingsPageState
    extends
        State<
          SettingsPage
        > {
  String _theme = 'system';
  String _language = 'en';
  bool _pushNotifications = true;
  bool _emailNotifications = true;
  double _distanceLimit = 10;

  @override
  Widget build(
    BuildContext context,
  ) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: Text(
          'Settings',
          style: AppTextStyles.titleLarge(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(
          16,
        ),
        children: [
          _buildSectionHeader(
            'Appearance',
          ),
          _buildSettingCard(
            icon: Icons.palette_outlined,
            title: 'Theme',
            subtitle:
                _theme ==
                    'light'
                ? 'Light'
                : _theme ==
                      'dark'
                ? 'Dark'
                : 'System',
            onTap: () => _showThemeDialog(),
          ),
          const SizedBox(
            height: 24,
          ),
          _buildSectionHeader(
            'Language',
          ),
          _buildSettingCard(
            icon: Icons.language,
            title: 'Language',
            subtitle: AppConstants.supportedLanguages.firstWhere(
              (
                l,
              ) =>
                  l['code'] ==
                  _language,
            )['name']!,
            onTap: () => _showLanguageDialog(),
          ),
          const SizedBox(
            height: 24,
          ),
          _buildSectionHeader(
            'Preferences',
          ),
          _buildSettingCard(
            icon: Icons.location_on_outlined,
            title: 'Search Distance',
            subtitle: '${_distanceLimit.toInt()} km',
            trailing: SizedBox(
              width: 150,
              child: Slider(
                value: _distanceLimit,
                min: 1,
                max: 20,
                divisions: 19,
                onChanged:
                    (
                      value,
                    ) => setState(
                      () => _distanceLimit = value,
                    ),
              ),
            ),
          ),
          const SizedBox(
            height: 24,
          ),
          _buildSectionHeader(
            'Notifications',
          ),
          _buildSettingCard(
            icon: Icons.notifications_outlined,
            title: 'Push Notifications',
            trailing: Switch(
              value: _pushNotifications,
              onChanged:
                  (
                    v,
                  ) => setState(
                    () => _pushNotifications = v,
                  ),
            ),
          ),
          _buildSettingCard(
            icon: Icons.email_outlined,
            title: 'Email Notifications',
            trailing: Switch(
              value: _emailNotifications,
              onChanged:
                  (
                    v,
                  ) => setState(
                    () => _emailNotifications = v,
                  ),
            ),
          ),
          const SizedBox(
            height: 24,
          ),
          _buildSectionHeader(
            'Privacy',
          ),
          _buildSettingCard(
            icon: Icons.history,
            title: 'Clear Search History',
            onTap: () {},
          ),
          _buildSettingCard(
            icon: Icons.cleaning_services_outlined,
            title: 'Clear Cache',
            onTap: () {},
          ),
          const SizedBox(
            height: 24,
          ),
          _buildSectionHeader(
            'About',
          ),
          _buildSettingCard(
            icon: Icons.info_outline,
            title: 'App Version',
            subtitle: AppConstants.appVersion,
          ),
          _buildSettingCard(
            icon: Icons.star_outline,
            title: 'Rate App',
            onTap: () {},
          ),
          _buildSettingCard(
            icon: Icons.feedback_outlined,
            title: 'Send Feedback',
            onTap: () {},
          ),
          const SizedBox(
            height: 24,
          ),
          _buildSettingCard(
            icon: Icons.delete_forever,
            title: 'Delete Account',
            iconColor: AppColors.error,
            titleColor: AppColors.error,
            onTap: () => _showDeleteConfirmation(),
          ),
          const SizedBox(
            height: 40,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(
    String title,
  ) {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: 8,
      ),
      child: Text(
        title,
        style: AppTextStyles.labelLarge(
          color: AppColors.textSecondaryLight,
        ),
      ),
    );
  }

  Widget _buildSettingCard({
    required IconData icon,
    required String title,
    String? subtitle,
    Widget? trailing,
    VoidCallback? onTap,
    Color? iconColor,
    Color? titleColor,
  }) {
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
        subtitle:
            subtitle !=
                null
            ? Text(
                subtitle,
                style: AppTextStyles.bodySmall(),
              )
            : null,
        trailing:
            trailing ??
            (onTap !=
                    null
                ? const Icon(
                    Icons.chevron_right,
                  )
                : null),
        onTap: onTap,
      ),
    );
  }

  void _showThemeDialog() {
    showDialog(
      context: context,
      builder:
          (
            ctx,
          ) => AlertDialog(
            title: const Text(
              'Select Theme',
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                RadioListTile<
                  String
                >(
                  value: 'light',
                  groupValue: _theme,
                  title: const Text(
                    'Light',
                  ),
                  onChanged:
                      (
                        v,
                      ) {
                        setState(
                          () => _theme =
                              v ??
                              'light',
                        );
                        Navigator.pop(
                          ctx,
                        );
                      },
                ),
                RadioListTile<
                  String
                >(
                  value: 'dark',
                  groupValue: _theme,
                  title: const Text(
                    'Dark',
                  ),
                  onChanged:
                      (
                        v,
                      ) {
                        setState(
                          () => _theme =
                              v ??
                              'dark',
                        );
                        Navigator.pop(
                          ctx,
                        );
                      },
                ),
                RadioListTile<
                  String
                >(
                  value: 'system',
                  groupValue: _theme,
                  title: const Text(
                    'System',
                  ),
                  onChanged:
                      (
                        v,
                      ) {
                        setState(
                          () => _theme =
                              v ??
                              'system',
                        );
                        Navigator.pop(
                          ctx,
                        );
                      },
                ),
              ],
            ),
          ),
    );
  }

  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder:
          (
            ctx,
          ) => AlertDialog(
            title: const Text(
              'Select Language',
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: AppConstants.supportedLanguages.map(
                (
                  lang,
                ) {
                  return RadioListTile<
                    String
                  >(
                    value: lang['code']!,
                    groupValue: _language,
                    title: Text(
                      lang['name']!,
                    ),
                    onChanged:
                        (
                          v,
                        ) {
                          setState(
                            () => _language =
                                v ??
                                'en',
                          );
                          Navigator.pop(
                            ctx,
                          );
                        },
                  );
                },
              ).toList(),
            ),
          ),
    );
  }

  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder:
          (
            ctx,
          ) => AlertDialog(
            title: const Text(
              'Delete Account',
            ),
            content: const Text(
              'Are you sure you want to delete your account? This action cannot be undone.',
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
                onPressed: () => Navigator.pop(
                  ctx,
                ),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.error,
                ),
                child: const Text(
                  'Delete',
                ),
              ),
            ],
          ),
    );
  }
}
