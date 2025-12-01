import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/typography.dart';
import '../../../core/theme/spacing.dart';
import '../../../providers/library_provider.dart';
import '../../../providers/player_provider.dart';
import '../../../shared/widgets/glass_container.dart';

class LibraryScreen extends StatelessWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Text('Your Library', style: AppTypography.h5),
          actions: [
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () => _showCreatePlaylistDialog(context),
            ),
          ],
          bottom: const TabBar(
            indicatorColor: AppColors.accentPrimary,
            labelColor: AppColors.accentPrimary,
            unselectedLabelColor: AppColors.textSecondary,
            tabs: [
              Tab(text: 'Liked Songs'),
              Tab(text: 'Playlists'),
              Tab(text: 'Recent'),
            ],
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
            const TabBarView(
              children: [
                LikedSongsTab(),
                PlaylistsTab(),
                RecentTab(),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showCreatePlaylistDialog(BuildContext context) {
    final nameController = TextEditingController();
    final descController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.backgroundSecondary,
        title: const Text('Create Playlist', style: TextStyle(color: AppColors.textPrimary)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: InputDecoration(
                labelText: 'Playlist Name',
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
              controller: descController,
              style: const TextStyle(color: AppColors.textPrimary),
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'Description (optional)',
                labelStyle: const TextStyle(color: AppColors.textSecondary),
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
            onPressed: () {
              if (nameController.text.isNotEmpty) {
                context.read<LibraryProvider>().createPlaylist(
                      nameController.text,
                      descController.text,
                    );
                Navigator.pop(dialogContext);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accentPrimary,
              foregroundColor: AppColors.black,
            ),
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }
}

class LikedSongsTab extends StatelessWidget {
  const LikedSongsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final libraryProvider = context.watch<LibraryProvider>();
    final likedSongs = libraryProvider.likedSongs;

    if (likedSongs.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.favorite_border, size: 64, color: AppColors.textTertiary),
            const SizedBox(height: AppSpacing.md),
            Text('No liked songs yet', style: AppTypography.h6.copyWith(color: AppColors.textSecondary)),
            const SizedBox(height: AppSpacing.sm),
            Text('Start liking songs to see them here', style: AppTypography.bodySmall.copyWith(color: AppColors.textTertiary)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(AppSpacing.md),
      itemCount: likedSongs.length,
      itemBuilder: (context, index) {
        final track = likedSongs[index];
        final playerProvider = context.watch<PlayerProvider>();
        final isPlaying = playerProvider.currentTrack?.id == track.id && playerProvider.isPlaying;

        return Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.sm),
          child: GlassContainer(
            padding: EdgeInsets.zero,
            borderRadius: BorderRadius.circular(12),
            color: AppColors.backgroundSecondary.withOpacity(0.5),
            child: ListTile(
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: CachedNetworkImage(
                  imageUrl: track.albumArt ?? '',
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(color: AppColors.backgroundTertiary),
                  errorWidget: (context, url, error) => Container(
                    color: AppColors.backgroundTertiary,
                    child: const Icon(Icons.music_note, size: 24),
                  ),
                ),
              ),
              title: Text(track.title, style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis),
              subtitle: Text(track.artist, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow, color: AppColors.accentPrimary),
                    onPressed: () {
                      if (isPlaying) {
                        playerProvider.pause();
                      } else {
                        playerProvider.playTrack(track, playlist: likedSongs);
                      }
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.favorite, color: AppColors.error),
                    onPressed: () => libraryProvider.unlikeSong(track.id),
                  ),
                ],
              ),
              onTap: () => playerProvider.playTrack(track, playlist: likedSongs),
            ),
          ),
        ).animate().fadeIn(delay: Duration(milliseconds: index * 30)).slideX(begin: -0.2, duration: const Duration(milliseconds: 300));
      },
    );
  }
}

class PlaylistsTab extends StatelessWidget {
  const PlaylistsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final libraryProvider = context.watch<LibraryProvider>();
    final playlists = libraryProvider.playlists;

    if (playlists.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.library_music, size: 64, color: AppColors.textTertiary),
            const SizedBox(height: AppSpacing.md),
            Text('No playlists yet', style: AppTypography.h6.copyWith(color: AppColors.textSecondary)),
            const SizedBox(height: AppSpacing.sm),
            Text('Create your first playlist', style: AppTypography.bodySmall.copyWith(color: AppColors.textTertiary)),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(AppSpacing.md),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: AppSpacing.md,
        mainAxisSpacing: AppSpacing.md,
        childAspectRatio: 0.8,
      ),
      itemCount: playlists.length,
      itemBuilder: (context, index) {
        final playlist = playlists[index];
        return GlassContainer(
          padding: EdgeInsets.zero,
          borderRadius: BorderRadius.circular(AppRadius.md),
          color: AppColors.backgroundSecondary.withOpacity(0.5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                    color: AppColors.backgroundTertiary,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.md)),
                  ),
                  child: const Center(child: Icon(Icons.library_music, size: 48, color: AppColors.textSecondary)),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(AppSpacing.sm),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(playlist.name, style: AppTypography.bodyMedium.copyWith(fontWeight: AppTypography.semibold), maxLines: 1, overflow: TextOverflow.ellipsis),
                    Text('${playlist.tracks.length} tracks', style: AppTypography.caption),
                  ],
                ),
              ),
            ],
          ),
        ).animate().fadeIn(delay: Duration(milliseconds: index * 50)).scale(begin: const Offset(0.9, 0.9), duration: const Duration(milliseconds: 300));
      },
    );
  }
}

class RecentTab extends StatelessWidget {
  const RecentTab({super.key});

  @override
  Widget build(BuildContext context) {
    final libraryProvider = context.watch<LibraryProvider>();
    final recentTracks = libraryProvider.recentlyPlayed;

    if (recentTracks.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.history, size: 64, color: AppColors.textTertiary),
            const SizedBox(height: AppSpacing.md),
            Text('No recent activity', style: AppTypography.h6.copyWith(color: AppColors.textSecondary)),
            const SizedBox(height: AppSpacing.sm),
            Text('Play some music to see your history', style: AppTypography.bodySmall.copyWith(color: AppColors.textTertiary)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(AppSpacing.md),
      itemCount: recentTracks.length,
      itemBuilder: (context, index) {
        final track = recentTracks[index];
        final playerProvider = context.watch<PlayerProvider>();
        final isPlaying = playerProvider.currentTrack?.id == track.id && playerProvider.isPlaying;

        return Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.sm),
          child: GlassContainer(
            padding: EdgeInsets.zero,
            borderRadius: BorderRadius.circular(12),
            color: AppColors.backgroundSecondary.withOpacity(0.5),
            child: ListTile(
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: CachedNetworkImage(
                  imageUrl: track.albumArt ?? '',
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(color: AppColors.backgroundTertiary),
                  errorWidget: (context, url, error) => Container(
                    color: AppColors.backgroundTertiary,
                    child: const Icon(Icons.music_note, size: 24),
                  ),
                ),
              ),
              title: Text(track.title, style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis),
              subtitle: Text(track.artist, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis),
              trailing: IconButton(
                icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow, color: AppColors.accentPrimary),
                onPressed: () {
                  if (isPlaying) {
                    playerProvider.pause();
                  } else {
                    playerProvider.playTrack(track, playlist: recentTracks);
                  }
                },
              ),
              onTap: () => playerProvider.playTrack(track, playlist: recentTracks),
            ),
          ),
        ).animate().fadeIn(delay: Duration(milliseconds: index * 30)).slideX(begin: -0.2, duration: const Duration(milliseconds: 300));
      },
    );
  }
}
