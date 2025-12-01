import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/typography.dart';
import '../../../core/theme/spacing.dart';
import '../../../providers/library_provider.dart';
import '../../../features/settings/screens/settings_screen.dart';
import '../../../shared/widgets/glass_container.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final libraryProvider = context.watch<LibraryProvider>();
    final likedSongsCount = libraryProvider.likedSongs.length;
    final playlistsCount = libraryProvider.playlists.length;
    final recentCount = libraryProvider.recentlyPlayed.length;

    return Scaffold(
      extendBodyBehindAppBar: true,
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
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                children: [
                  // Profile Header
                  Stack(
                    children: [
                      const CircleAvatar(
                        radius: 60,
                        backgroundColor: AppColors.backgroundTertiary,
                        child: Icon(
                          Icons.person,
                          size: 60,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.accentPrimary,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.accentPrimary.withOpacity(0.4),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Icon(Icons.edit, size: 16, color: AppColors.black),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    'Music Lover',
                    style: AppTypography.h4,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    '@musiclover',
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  // Stats
                  GlassContainer(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    borderRadius: BorderRadius.circular(16),
                    color: AppColors.backgroundSecondary.withOpacity(0.5),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildStatCard(playlistsCount.toString(), 'Playlists'),
                        Container(
                          width: 1,
                          height: 40,
                          color: AppColors.backgroundTertiary,
                        ),
                        _buildStatCard(likedSongsCount.toString(), 'Liked Songs'),
                        Container(
                          width: 1,
                          height: 40,
                          color: AppColors.backgroundTertiary,
                        ),
                        _buildStatCard(recentCount.toString(), 'Recent'),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppSpacing.xl),

                  // Options
                  _buildOption(context, Icons.edit, 'Edit Profile', () {
                    _showEditProfileDialog(context);
                  }),
                  _buildOption(context, Icons.settings, 'Settings', () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const SettingsScreen()),
                    );
                  }),
                  _buildOption(context, Icons.privacy_tip, 'Privacy', () {}),
                  _buildOption(context, Icons.help, 'Help & Support', () {}),
                  _buildOption(context, Icons.info, 'About', () {
                    _showAboutDialog(context);
                  }),
                  _buildOption(context, Icons.logout, 'Logout', () {}, isDestructive: true),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: AppTypography.h4.copyWith(
            color: AppColors.accentPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          label,
          style: AppTypography.caption.copyWith(fontSize: 11),
        ),
      ],
    );
  }

  Widget _buildOption(BuildContext context, IconData icon, String title, VoidCallback onTap, {bool isDestructive = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: GlassContainer(
        padding: EdgeInsets.zero,
        borderRadius: BorderRadius.circular(AppRadius.md),
        color: AppColors.backgroundSecondary.withOpacity(0.5),
        child: ListTile(
          leading: Icon(
            icon,
            color: isDestructive ? AppColors.error : AppColors.accentPrimary,
          ),
          title: Text(
            title,
            style: AppTypography.bodyMedium.copyWith(
              color: isDestructive ? AppColors.error : AppColors.textPrimary,
            ),
          ),
          trailing: const Icon(
            Icons.chevron_right,
            color: AppColors.textTertiary,
          ),
          onTap: onTap,
        ),
      ),
    );
  }

  void _showEditProfileDialog(BuildContext context) {
    final nameController = TextEditingController(text: 'Music Lover');
    final usernameController = TextEditingController(text: 'musiclover');
    
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.backgroundSecondary,
        title: const Text('Edit Profile', style: TextStyle(color: AppColors.textPrimary)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: InputDecoration(
                labelText: 'Display Name',
                labelStyle: const TextStyle(color: AppColors.textSecondary),
                filled: true,
                fillColor: AppColors.backgroundTertiary,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: usernameController,
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: InputDecoration(
                labelText: 'Username',
                labelStyle: const TextStyle(color: AppColors.textSecondary),
                prefixText: '@',
                filled: true,
                fillColor: AppColors.backgroundTertiary,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogContext),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accentPrimary,
              foregroundColor: AppColors.black,
            ),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.backgroundSecondary,
        title: const Text('About JetStream', style: TextStyle(color: AppColors.textPrimary)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Version: 1.0.0',
              style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'A modern music streaming app built with Flutter.',
              style: AppTypography.bodySmall.copyWith(color: AppColors.textTertiary),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              '© 2024 JetStream. All rights reserved.',
              style: AppTypography.caption.copyWith(color: AppColors.textTertiary),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogContext),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accentPrimary,
              foregroundColor: AppColors.black,
            ),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
