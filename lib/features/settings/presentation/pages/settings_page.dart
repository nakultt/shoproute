import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../../config/theme/app_text_styles.dart';
import '../../../../config/constants/app_constants.dart';
import '../../../../config/theme/theme_notifier.dart';

/// Settings Page
class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  String _language = 'en';
  bool _pushNotifications = true;
  bool _emailNotifications = true;
  double _distanceLimit = 10;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _language = prefs.getString('language') ?? 'en';
      _pushNotifications = prefs.getBool('pushNotifications') ?? true;
      _emailNotifications = prefs.getBool('emailNotifications') ?? true;
      _distanceLimit = prefs.getDouble('distanceLimit') ?? 10;
    });
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language', _language);
    await prefs.setBool('pushNotifications', _pushNotifications);
    await prefs.setBool('emailNotifications', _emailNotifications);
    await prefs.setDouble('distanceLimit', _distanceLimit);
  }

  String get _currentThemeName {
    switch (themeNotifier.themeMode) {
      case ThemeMode.light:
        return 'Light';
      case ThemeMode.dark:
        return 'Dark';
      case ThemeMode.system:
        return 'System';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark
          ? AppColors.backgroundDark
          : AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: isDark
            ? AppColors.surfaceDark
            : AppColors.surfaceLight,
        title: Text(
          'Settings',
          style: AppTextStyles.titleLarge(
            color: isDark ? AppColors.textPrimaryDark : null,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSectionHeader('Appearance', isDark),
          _buildSettingCard(
            isDark: isDark,
            icon: Icons.palette_outlined,
            title: 'Theme',
            subtitle: _currentThemeName,
            onTap: () => _showThemeDialog(),
          ),
          const SizedBox(height: 24),
          _buildSectionHeader('Language', isDark),
          _buildSettingCard(
            isDark: isDark,
            icon: Icons.language,
            title: 'Language',
            subtitle: AppConstants.supportedLanguages.firstWhere(
              (l) => l['code'] == _language,
            )['name']!,
            onTap: () => _showLanguageDialog(),
          ),
          const SizedBox(height: 24),
          _buildSectionHeader('Preferences', isDark),
          _buildSettingCard(
            isDark: isDark,
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
                onChanged: (value) {
                  setState(() => _distanceLimit = value);
                  _saveSettings();
                },
              ),
            ),
          ),
          const SizedBox(height: 24),
          _buildSectionHeader('Notifications', isDark),
          _buildSettingCard(
            isDark: isDark,
            icon: Icons.notifications_outlined,
            title: 'Push Notifications',
            trailing: Switch(
              value: _pushNotifications,
              onChanged: (v) {
                setState(() => _pushNotifications = v);
                _saveSettings();
              },
            ),
          ),
          _buildSettingCard(
            isDark: isDark,
            icon: Icons.email_outlined,
            title: 'Email Notifications',
            trailing: Switch(
              value: _emailNotifications,
              onChanged: (v) {
                setState(() => _emailNotifications = v);
                _saveSettings();
              },
            ),
          ),
          const SizedBox(height: 24),
          _buildSectionHeader('Privacy', isDark),
          _buildSettingCard(
            isDark: isDark,
            icon: Icons.history,
            title: 'Clear Search History',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Search history cleared')),
              );
            },
          ),
          _buildSettingCard(
            isDark: isDark,
            icon: Icons.cleaning_services_outlined,
            title: 'Clear Cache',
            onTap: () {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('Cache cleared')));
            },
          ),
          const SizedBox(height: 24),
          _buildSectionHeader('About', isDark),
          _buildSettingCard(
            isDark: isDark,
            icon: Icons.info_outline,
            title: 'App Version',
            subtitle: AppConstants.appVersion,
          ),
          _buildSettingCard(
            isDark: isDark,
            icon: Icons.star_outline,
            title: 'Rate App',
            onTap: () {},
          ),
          _buildSettingCard(
            isDark: isDark,
            icon: Icons.feedback_outlined,
            title: 'Send Feedback',
            onTap: () {},
          ),
          const SizedBox(height: 24),
          _buildSettingCard(
            isDark: isDark,
            icon: Icons.delete_forever,
            title: 'Delete Account',
            iconColor: AppColors.error,
            titleColor: AppColors.error,
            onTap: () => _showDeleteConfirmation(),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: AppTextStyles.labelLarge(
          color: isDark
              ? AppColors.textSecondaryDark
              : AppColors.textSecondaryLight,
        ),
      ),
    );
  }

  Widget _buildSettingCard({
    required bool isDark,
    required IconData icon,
    required String title,
    String? subtitle,
    Widget? trailing,
    VoidCallback? onTap,
    Color? iconColor,
    Color? titleColor,
  }) {
    return Card(
      color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon, color: iconColor ?? AppColors.primary),
        title: Text(
          title,
          style: AppTextStyles.bodyLarge(
            color: titleColor ?? (isDark ? AppColors.textPrimaryDark : null),
          ),
        ),
        subtitle: subtitle != null
            ? Text(
                subtitle,
                style: AppTextStyles.bodySmall(
                  color: isDark ? AppColors.textSecondaryDark : null,
                ),
              )
            : null,
        trailing:
            trailing ??
            (onTap != null ? const Icon(Icons.chevron_right) : null),
        onTap: onTap,
      ),
    );
  }

  void _showThemeDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Select Theme'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<ThemeMode>(
              value: ThemeMode.light,
              groupValue: themeNotifier.themeMode,
              title: const Text('Light'),
              onChanged: (v) {
                themeNotifier.setThemeMode(v ?? ThemeMode.light);
                setState(() {});
                Navigator.pop(ctx);
              },
            ),
            RadioListTile<ThemeMode>(
              value: ThemeMode.dark,
              groupValue: themeNotifier.themeMode,
              title: const Text('Dark'),
              onChanged: (v) {
                themeNotifier.setThemeMode(v ?? ThemeMode.dark);
                setState(() {});
                Navigator.pop(ctx);
              },
            ),
            RadioListTile<ThemeMode>(
              value: ThemeMode.system,
              groupValue: themeNotifier.themeMode,
              title: const Text('System'),
              onChanged: (v) {
                themeNotifier.setThemeMode(v ?? ThemeMode.system);
                setState(() {});
                Navigator.pop(ctx);
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
      builder: (ctx) => AlertDialog(
        title: const Text('Select Language'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: AppConstants.supportedLanguages.map((lang) {
            return RadioListTile<String>(
              value: lang['code']!,
              groupValue: _language,
              title: Text(lang['name']!),
              onChanged: (v) {
                setState(() => _language = v ?? 'en');
                _saveSettings();
                Navigator.pop(ctx);
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Account'),
        content: const Text(
          'Are you sure you want to delete your account? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
