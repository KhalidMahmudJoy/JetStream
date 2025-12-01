import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/theme/colors.dart';
import '../../providers/player_provider.dart';
import '../../providers/library_provider.dart';

class MiniPlayer extends StatelessWidget {
  const MiniPlayer({super.key});

  @override
  Widget build(BuildContext context) {
    final playerProvider = context.watch<PlayerProvider>();
    final currentTrack = playerProvider.currentTrack;

    if (currentTrack == null) {
      return const SizedBox.shrink();
    }

    return Container(
      height: 70,
      decoration: BoxDecoration(
        color: AppColors.backgroundSecondary,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildProgressBar(playerProvider),
          Expanded(
            child: Row(
              children: [
                _buildAlbumArt(currentTrack.albumArt ?? ''),
                const SizedBox(width: 12),
                Expanded(child: _buildTrackInfo(currentTrack)),
                _buildControls(playerProvider, context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar(PlayerProvider playerProvider) {
    final progress = playerProvider.duration.inSeconds > 0
        ? playerProvider.position.inSeconds / playerProvider.duration.inSeconds
        : 0.0;

    return LinearProgressIndicator(
      value: progress,
      backgroundColor: AppColors.backgroundTertiary,
      valueColor: const AlwaysStoppedAnimation<Color>(AppColors.accentPrimary),
      minHeight: 2,
    );
  }

  Widget _buildAlbumArt(String imageUrl) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: CachedNetworkImage(
          imageUrl: imageUrl,
          width: 50,
          height: 50,
          fit: BoxFit.cover,
          placeholder: (context, url) => Container(
            color: AppColors.backgroundTertiary,
          ),
          errorWidget: (context, url, error) => Container(
            color: AppColors.backgroundTertiary,
            child: const Icon(Icons.music_note, color: AppColors.textSecondary),
          ),
        ),
      ),
    );
  }

  Widget _buildTrackInfo(currentTrack) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          currentTrack.title,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 2),
        Text(
          currentTrack.artist,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 12,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildControls(PlayerProvider playerProvider, BuildContext context) {
    final libraryProvider = context.watch<LibraryProvider>();
    final isLiked = libraryProvider.isLiked(playerProvider.currentTrack!.id);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: Icon(
            isLiked ? Icons.favorite : Icons.favorite_border,
            color: isLiked ? AppColors.secondaryPrimary : AppColors.textSecondary,
          ),
          onPressed: () {
            if (playerProvider.currentTrack != null) {
              libraryProvider.toggleLike(playerProvider.currentTrack!);
            }
          },
        ),
        IconButton(
          icon: Icon(
            playerProvider.isPlaying ? Icons.pause : Icons.play_arrow,
            color: AppColors.textPrimary,
          ),
          onPressed: () => playerProvider.togglePlayPause(),
        ),
        IconButton(
          icon: const Icon(
            Icons.skip_next,
            color: AppColors.textPrimary,
          ),
          onPressed: playerProvider.hasNext ? () => playerProvider.skipNext() : null,
        ),
        const SizedBox(width: 8),
      ],
    );
  }
}
