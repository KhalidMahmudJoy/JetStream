import 'package:flutter/material.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/typography.dart';
import '../../../core/theme/spacing.dart';
import '../../../services/storage_service.dart';
import '../../../shared/widgets/glass_container.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  StorageService? _storageService;
  Map<String, dynamic> _settings = {};

  @override
  void initState() {
    super.initState();
    _initializeService();
  }

  Future<void> _initializeService() async {
    _storageService = await StorageService.init();
    await _loadSettings();
  }

  Future<void> _loadSettings() async {
    if (_storageService == null) return;
    final settings = await _storageService!.getSettings();
    setState(() => _settings = settings);
  }

  Future<void> _updateSetting(String key, dynamic value) async {
    if (_storageService == null) return;
    setState(() => _settings[key] = value);
    await _storageService!.saveSetting(key, value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('Settings', style: AppTypography.h5),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          // Background Gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.backgroundPrimary,
                  AppColors.backgroundSecondary,
                  Colors.black,
                ],
              ),
            ),
          ),
          
          // Content
          ListView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md, 
              kToolbarHeight + AppSpacing.xl, 
              AppSpacing.md, 
              AppSpacing.xl
            ),
            children: [
              // Playback Settings
              _buildSectionTitle('Playback'),
              _buildSettingTile(
                'Audio Quality',
                'High',
                Icons.music_note,
                onTap: () => _showQualityDialog(),
              ),
              _buildSwitchTile(
                'Crossfade',
                'Smooth transition between tracks',
                Icons.tune,
                _settings['crossfade'] ?? false,
                (value) => _updateSetting('crossfade', value),
              ),
              _buildSwitchTile(
                'Gapless Playback',
                'No silence between tracks',
                Icons.link,
                _settings['gapless'] ?? true,
                (value) => _updateSetting('gapless', value),
              ),
              _buildSwitchTile(
                'Volume Normalization',
                'Equalize volume across tracks',
                Icons.equalizer,
                _settings['volumeNormalization'] ?? false,
                (value) => _updateSetting('volumeNormalization', value),
              ),

              const SizedBox(height: AppSpacing.xl),

              // Appearance
              _buildSectionTitle('Appearance'),
              _buildSettingTile(
                'Theme',
                'Dark',
                Icons.palette,
                onTap: () => _showThemeDialog(),
              ),
              _buildSettingTile(
                'Language',
                'English',
                Icons.language,
                onTap: () => _showLanguageDialog(),
              ),

              const SizedBox(height: AppSpacing.xl),

              // Privacy & Notifications
              _buildSectionTitle('Privacy & Notifications'),
              _buildSwitchTile(
                'Push Notifications',
                'Get notified about new releases',
                Icons.notifications,
                _settings['pushNotifications'] ?? true,
                (value) => _updateSetting('pushNotifications', value),
              ),
              _buildSwitchTile(
                'Private Profile',
                'Hide your listening activity',
                Icons.lock,
                _settings['privateProfile'] ?? false,
                (value) => _updateSetting('privateProfile', value),
              ),
              _buildSwitchTile(
                'Explicit Content',
                'Show explicit content',
                Icons.explicit,
                _settings['explicitContent'] ?? true,
                (value) => _updateSetting('explicitContent', value),
              ),

              const SizedBox(height: AppSpacing.xl),

              // Storage & Data
              _buildSectionTitle('Storage & Data'),
              _buildSettingTile(
                'Cache Size',
                'Calculate...',
                Icons.storage,
                onTap: () {},
              ),
              _buildActionTile(
                'Clear Cache',
                'Free up storage space',
                Icons.delete_sweep,
                onTap: () => _showClearCacheDialog(),
              ),
              _buildActionTile(
                'Reset to Defaults',
                'Reset all settings',
                Icons.restore,
                onTap: () => _showResetDialog(),
                isDestructive: true,
              ),

              const SizedBox(height: AppSpacing.xl),

              // About
              _buildSectionTitle('About'),
              _buildSettingTile(
                'Version',
                '1.0.0',
                Icons.info,
              ),
              _buildSettingTile(
                'Terms of Service',
                '',
                Icons.description,
                onTap: () {},
              ),
              _buildSettingTile(
                'Privacy Policy',
                '',
                Icons.privacy_tip,
                onTap: () {},
              ),

              const SizedBox(height: AppSpacing.xl),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md, top: AppSpacing.sm),
      child: Text(
        title,
        style: AppTypography.h6.copyWith(
          color: AppColors.accentPrimary,
          fontWeight: FontWeight.bold,
          shadows: [
            Shadow(
              color: AppColors.accentPrimary.withOpacity(0.5),
              blurRadius: 10,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingTile(String title, String subtitle, IconData icon, {VoidCallback? onTap}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: GestureDetector(
        onTap: onTap,
        child: GlassContainer(
          child: ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.accentPrimary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: AppColors.accentPrimary),
            ),
            title: Text(title, style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w500)),
            subtitle: subtitle.isNotEmpty ? Text(subtitle, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)) : null,
            trailing: onTap != null ? const Icon(Icons.chevron_right, color: AppColors.textTertiary) : null,
          ),
        ),
      ),
    );
  }

  Widget _buildSwitchTile(String title, String subtitle, IconData icon, bool value, ValueChanged<bool> onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: GlassContainer(
        child: SwitchListTile(
          secondary: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.accentPrimary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: AppColors.accentPrimary),
          ),
          title: Text(title, style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w500)),
          subtitle: Text(subtitle, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
          value: value,
          onChanged: onChanged,
          activeColor: AppColors.secondaryPrimary,
          inactiveTrackColor: AppColors.backgroundTertiary,
        ),
      ),
    );
  }

  Widget _buildActionTile(String title, String subtitle, IconData icon, {VoidCallback? onTap, bool isDestructive = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: GestureDetector(
        onTap: onTap,
        child: GlassContainer(
          child: ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isDestructive ? AppColors.error.withOpacity(0.1) : AppColors.accentPrimary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: isDestructive ? AppColors.error : AppColors.accentPrimary),
            ),
            title: Text(title, style: TextStyle(color: isDestructive ? AppColors.error : AppColors.textPrimary, fontWeight: FontWeight.w500)),
            subtitle: Text(subtitle, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
          ),
        ),
      ),
    );
  }

  void _showQualityDialog() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: GlassContainer(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text('Audio Quality', style: AppTypography.h6),
              ),
              ListTile(
                title: const Text('Low (96 kbps)', style: TextStyle(color: AppColors.textPrimary)),
                onTap: () => Navigator.pop(context),
              ),
              ListTile(
                title: const Text('Medium (160 kbps)', style: TextStyle(color: AppColors.textPrimary)),
                onTap: () => Navigator.pop(context),
              ),
              ListTile(
                title: const Text('High (320 kbps)', style: TextStyle(color: AppColors.textPrimary)),
                onTap: () => Navigator.pop(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showThemeDialog() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: GlassContainer(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text('Theme', style: AppTypography.h6),
              ),
              ListTile(
                title: const Text('Dark', style: TextStyle(color: AppColors.textPrimary)),
                onTap: () => Navigator.pop(context),
              ),
              ListTile(
                title: const Text('Light', style: TextStyle(color: AppColors.textPrimary)),
                onTap: () => Navigator.pop(context),
              ),
              ListTile(
                title: const Text('Auto', style: TextStyle(color: AppColors.textPrimary)),
                onTap: () => Navigator.pop(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: GlassContainer(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text('Language', style: AppTypography.h6),
              ),
              ListTile(
                title: const Text('English', style: TextStyle(color: AppColors.textPrimary)),
                onTap: () => Navigator.pop(context),
              ),
              ListTile(
                title: const Text('বাংলা', style: TextStyle(color: AppColors.textPrimary)),
                onTap: () => Navigator.pop(context),
              ),
              ListTile(
                title: const Text('Español', style: TextStyle(color: AppColors.textPrimary)),
                onTap: () => Navigator.pop(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showClearCacheDialog() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: GlassContainer(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Clear Cache', style: AppTypography.h6),
                const SizedBox(height: 16),
                const Text(
                  'Are you sure you want to clear the cache? This will free up storage space.',
                  style: TextStyle(color: AppColors.textSecondary),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () async {
                        Navigator.pop(context);
                        if (_storageService != null) {
                          await _storageService!.clearCache();
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Cache cleared successfully')),
                            );
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.error,
                        foregroundColor: AppColors.white,
                      ),
                      child: const Text('Clear'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showResetDialog() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: GlassContainer(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Reset Settings', style: AppTypography.h6),
                const SizedBox(height: 16),
                const Text(
                  'Are you sure you want to reset all settings to defaults?',
                  style: TextStyle(color: AppColors.textSecondary),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () async {
                        Navigator.pop(context);
                        if (_storageService != null) {
                          await _storageService!.resetSettings();
                          await _loadSettings();
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Settings reset successfully')),
                            );
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.error,
                        foregroundColor: AppColors.white,
                      ),
                      child: const Text('Reset'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
