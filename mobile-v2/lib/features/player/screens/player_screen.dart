import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/typography.dart';
import '../../../core/theme/spacing.dart';
import '../../../providers/player_provider.dart';
import '../../../providers/library_provider.dart';
import '../../../shared/widgets/glass_container.dart';
import '../../../shared/widgets/neon_button.dart';
import '../../../shared/widgets/glowing_slider.dart';

class PlayerScreen extends StatelessWidget {
  const PlayerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final playerProvider = context.watch<PlayerProvider>();
    final libraryProvider = context.watch<LibraryProvider>();
    final track = playerProvider.currentTrack;

    if (track == null) {
      return const Scaffold(
        backgroundColor: AppColors.backgroundPrimary,
        body: Center(
          child: Text('No track playing', style: TextStyle(color: AppColors.textSecondary)),
        ),
      );
    }

    final isLiked = libraryProvider.isLiked(track.id);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.backgroundSecondary,
              AppColors.backgroundPrimary,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header with back button and more options
              Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.keyboard_arrow_down, size: 32, color: AppColors.textPrimary),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Text('Now Playing', style: AppTypography.h6),
                    IconButton(
                      icon: const Icon(Icons.more_vert, color: AppColors.textPrimary),
                      onPressed: () => _showOptionsMenu(context, track),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.xl),

              // Album Art
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                child: Hero(
                  tag: 'album-art-${track.id}',
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.accentPrimary.withOpacity(0.2),
                          blurRadius: 30,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: CachedNetworkImage(
                        imageUrl: track.albumArt ?? '',
                        width: double.infinity,
                        height: MediaQuery.of(context).size.width - 48,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          color: AppColors.backgroundTertiary,
                          child: const Center(
                            child: CircularProgressIndicator(color: AppColors.accentPrimary),
                          ),
                        ),
                        errorWidget: (context, url, error) => Container(
                          color: AppColors.backgroundTertiary,
                          child: const Icon(Icons.music_note, size: 100, color: AppColors.textSecondary),
                        ),
                      ),
                    ),
                  ),
                ).animate().scale(duration: const Duration(milliseconds: 400)),
              ),

              const SizedBox(height: AppSpacing.xl),

              // Track Info
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                child: Column(
                  children: [
                    Text(
                      track.title,
                      style: AppTypography.h4.copyWith(fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      track.artist,
                      style: AppTypography.h6.copyWith(color: AppColors.textSecondary),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.xl),

              // Progress Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                child: Column(
                  children: [
                    GlowingSlider(
                      value: playerProvider.position.inSeconds.toDouble(),
                      max: playerProvider.duration.inSeconds.toDouble() > 0 
                          ? playerProvider.duration.inSeconds.toDouble() 
                          : 1.0,
                      onChanged: (value) => playerProvider.seek(Duration(seconds: value.toInt())),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _formatDuration(playerProvider.position.inSeconds),
                            style: AppTypography.caption.copyWith(color: AppColors.textTertiary),
                          ),
                          Text(
                            _formatDuration(playerProvider.duration.inSeconds),
                            style: AppTypography.caption.copyWith(color: AppColors.textTertiary),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // Main Controls
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                child: GlassContainer(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.md, horizontal: AppSpacing.sm),
                  borderRadius: BorderRadius.circular(30),
                  color: AppColors.backgroundSecondary.withOpacity(0.3),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Shuffle
                      IconButton(
                        icon: Icon(
                          Icons.shuffle,
                          color: playerProvider.isShuffle ? AppColors.accentPrimary : AppColors.textSecondary,
                          size: 24,
                        ),
                        onPressed: playerProvider.toggleShuffle,
                      ),
                      // Previous
                      IconButton(
                        icon: const Icon(Icons.skip_previous, color: AppColors.textPrimary, size: 32),
                        onPressed: () => playerProvider.skipPrevious(),
                      ),
                      // Play/Pause
                      NeonButton(
                        width: 64,
                        height: 64,
                        onPressed: () => playerProvider.togglePlayPause(),
                        child: Icon(
                          playerProvider.isPlaying ? Icons.pause : Icons.play_arrow,
                          color: AppColors.black,
                          size: 32,
                        ),
                      ).animate(
                        target: playerProvider.isPlaying ? 1 : 0,
                      ).scale(
                        duration: const Duration(milliseconds: 200),
                        begin: const Offset(1, 1),
                        end: const Offset(1.05, 1.05),
                      ),
                      // Next
                      IconButton(
                        icon: const Icon(Icons.skip_next, color: AppColors.textPrimary, size: 32),
                        onPressed: () => playerProvider.skipNext(),
                      ),
                      // Repeat
                      IconButton(
                        icon: Icon(
                          playerProvider.repeatMode == RepeatMode.one
                              ? Icons.repeat_one
                              : Icons.repeat,
                          color: playerProvider.repeatMode != RepeatMode.off ? AppColors.accentPrimary : AppColors.textSecondary,
                          size: 24,
                        ),
                        onPressed: playerProvider.toggleRepeat,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: AppSpacing.xl),

              // Secondary Controls
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    IconButton(
                      icon: Icon(
                        isLiked ? Icons.favorite : Icons.favorite_border,
                        color: isLiked ? AppColors.error : AppColors.textPrimary,
                        size: 28,
                      ),
                      onPressed: () {
                        if (isLiked) {
                          libraryProvider.unlikeSong(track.id);
                        } else {
                          libraryProvider.likeSong(track);
                        }
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.queue_music, color: AppColors.textPrimary, size: 28),
                      onPressed: () => _showQueueSheet(context),
                    ),
                    IconButton(
                      icon: const Icon(Icons.share, color: AppColors.textPrimary, size: 28),
                      onPressed: () {
                        // Share functionality
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.xl),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(1, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  void _showOptionsMenu(BuildContext context, track) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => GlassContainer(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: AppSpacing.lg),
                decoration: BoxDecoration(
                  color: AppColors.textSecondary.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.playlist_add, color: AppColors.accentPrimary),
                title: const Text('Add to Playlist', style: TextStyle(color: AppColors.textPrimary)),
                onTap: () {
                  Navigator.pop(context);
                  // Show playlist selector
                },
              ),
              ListTile(
                leading: const Icon(Icons.queue_music, color: AppColors.accentPrimary),
                title: const Text('Add to Queue', style: TextStyle(color: AppColors.textPrimary)),
                onTap: () {
                  Navigator.pop(context);
                  context.read<PlayerProvider>().addToQueue(track);
                },
              ),
              ListTile(
                leading: const Icon(Icons.album, color: AppColors.accentPrimary),
                title: const Text('Go to Album', style: TextStyle(color: AppColors.textPrimary)),
                onTap: () {
                  Navigator.pop(context);
                  // Navigate to album
                },
              ),
              ListTile(
                leading: const Icon(Icons.person, color: AppColors.accentPrimary),
                title: const Text('Go to Artist', style: TextStyle(color: AppColors.textPrimary)),
                onTap: () {
                  Navigator.pop(context);
                  // Navigate to artist
                },
              ),
              const SizedBox(height: AppSpacing.xl),
            ],
          ),
        ),
      ),
    );
  }

  void _showQueueSheet(BuildContext context) {
    final playerProvider = context.read<PlayerProvider>();
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        builder: (context, scrollController) => GlassContainer(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          child: Column(
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.textSecondary.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Queue', style: AppTypography.h5),
                    TextButton(
                      onPressed: () {
                        playerProvider.clearQueue();
                        Navigator.pop(context);
                      },
                      child: const Text('Clear All', style: TextStyle(color: AppColors.error)),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  itemCount: playerProvider.queue.length,
                  itemBuilder: (context, index) {
                    final track = playerProvider.queue[index];
                    final isCurrentTrack = track.id == playerProvider.currentTrack?.id;
                    
                    return ListTile(
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
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
                      title: Text(
                        track.title,
                        style: TextStyle(
                          color: isCurrentTrack ? AppColors.accentPrimary : AppColors.textPrimary,
                          fontWeight: isCurrentTrack ? FontWeight.bold : FontWeight.normal,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Text(
                        track.artist,
                        style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.close, color: AppColors.textSecondary),
                        onPressed: () {
                          playerProvider.removeFromQueue(index);
                        },
                      ),
                      onTap: () {
                        playerProvider.playTrack(track, playlist: playerProvider.queue);
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
