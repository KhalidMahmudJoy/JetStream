import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shimmer/shimmer.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/typography.dart';
import '../../../core/theme/spacing.dart';
import '../../../providers/player_provider.dart';
import '../../../providers/library_provider.dart';
import '../../../shared/widgets/glass_container.dart';
import '../../../shared/widgets/neon_button.dart';

class PlayerScreen extends StatefulWidget {
  const PlayerScreen({super.key});

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _rotationController;
  double _dragOffset = 0;
  bool _showLyrics = false;
  bool _showQueue = false;

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();
  }

  @override
  void dispose() {
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final playerProvider = context.watch<PlayerProvider>();
    final libraryProvider = context.watch<LibraryProvider>();
    final track = playerProvider.currentTrack;

    if (track == null) {
      return Scaffold(
        backgroundColor: AppColors.backgroundPrimary,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.music_note,
                size: 80,
                color: AppColors.textSecondary,
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                'No track playing',
                style: AppTypography.h6.copyWith(color: AppColors.textSecondary),
              ),
            ],
          ).animate().fadeIn(duration: 300.ms).scale(),
        ),
      );
    }

    final isLiked = libraryProvider.isLiked(track.id);

    // Control rotation based on playback state
    if (playerProvider.isPlaying) {
      _rotationController.repeat();
    } else {
      _rotationController.stop();
    }

    return Scaffold(
      body: GestureDetector(
        onHorizontalDragUpdate: (details) {
          setState(() {
            _dragOffset += details.delta.dx;
          });
        },
        onHorizontalDragEnd: (details) {
          if (_dragOffset.abs() > 100) {
            HapticFeedback.mediumImpact();
            if (_dragOffset > 0) {
              playerProvider.skipPrevious();
            } else {
              playerProvider.skipNext();
            }
          }
          setState(() {
            _dragOffset = 0;
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.backgroundSecondary,
                AppColors.backgroundPrimary,
                AppColors.backgroundPrimary,
              ],
            ),
          ),
          child: SafeArea(
            child: Stack(
              children: [
                // Animated gradient particles in background
                ...List.generate(5, (index) => _buildParticle(index)),

                // Main content
                Column(
                  children: [
                    _buildHeader(context),
                    const SizedBox(height: AppSpacing.xl),
                    Expanded(
                      child: _showQueue
                          ? _buildQueueView(playerProvider)
                          : _showLyrics
                              ? _buildLyricsView()
                              : _buildPlayerView(track, playerProvider, libraryProvider, isLiked),
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

  Widget _buildParticle(int index) {
    return Positioned(
      left: (index * 80.0) - 40,
      top: (index * 120.0) + 50,
      child: Container(
        width: 100 + (index * 20.0),
        height: 100 + (index * 20.0),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              AppColors.accentPrimary.withOpacity(0.1),
              AppColors.accentPrimary.withOpacity(0.0),
            ],
          ),
        ),
      )
          .animate(
            onPlay: (controller) => controller.repeat(reverse: true),
          )
          .moveY(
            begin: 0,
            end: 50 + (index * 10),
            duration: (3000 + (index * 500)).ms,
            curve: Curves.easeInOut,
          )
          .fadeIn(duration: 1.seconds),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Back button with animation
          IconButton(
            icon: const Icon(Icons.keyboard_arrow_down, size: 32, color: AppColors.textPrimary),
            onPressed: () => Navigator.pop(context),
          )
              .animate(target: _dragOffset.abs() > 50 ? 1 : 0)
              .rotate(duration: 200.ms)
              .scale(begin: const Offset(1, 1), end: const Offset(1.2, 1.2)),

          // Title with shimmer effect
          Shimmer.fromColors(
            baseColor: AppColors.textPrimary,
            highlightColor: AppColors.accentPrimary,
            period: const Duration(seconds: 3),
            child: Text('Now Playing', style: AppTypography.h6),
          ),

          // More options
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: AppColors.textPrimary),
            color: AppColors.backgroundSecondary,
            onSelected: (value) {
              switch (value) {
                case 'queue':
                  setState(() {
                    _showQueue = !_showQueue;
                    _showLyrics = false;
                  });
                  break;
                case 'lyrics':
                  setState(() {
                    _showLyrics = !_showLyrics;
                    _showQueue = false;
                  });
                  break;
                case 'share':
                  // Share functionality
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'queue',
                child: Row(
                  children: [
                    Icon(Icons.queue_music, color: AppColors.accentPrimary),
                    SizedBox(width: AppSpacing.sm),
                    Text('Queue', style: TextStyle(color: AppColors.textPrimary)),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'lyrics',
                child: Row(
                  children: [
                    Icon(Icons.lyrics, color: AppColors.accentPrimary),
                    SizedBox(width: AppSpacing.sm),
                    Text('Lyrics', style: TextStyle(color: AppColors.textPrimary)),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'share',
                child: Row(
                  children: [
                    Icon(Icons.share, color: AppColors.accentPrimary),
                    SizedBox(width: AppSpacing.sm),
                    Text('Share', style: TextStyle(color: AppColors.textPrimary)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPlayerView(track, PlayerProvider playerProvider, LibraryProvider libraryProvider, bool isLiked) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Rotating Album Art with glow effect
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
            child: Hero(
              tag: 'album-art-${track.id}',
              child: AnimatedBuilder(
                animation: _rotationController,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(_dragOffset * 0.5, 0),
                    child: Transform.rotate(
                      angle: _rotationController.value * 2 * math.pi,
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.accentPrimary.withOpacity(0.5),
                              blurRadius: 40,
                              spreadRadius: playerProvider.isPlaying ? 10 : 0,
                            ),
                            BoxShadow(
                              color: AppColors.secondaryPrimary.withOpacity(0.3),
                              blurRadius: 60,
                              spreadRadius: playerProvider.isPlaying ? 20 : 0,
                            ),
                          ],
                        ),
                        child: ClipOval(
                          child: CachedNetworkImage(
                            imageUrl: track.albumArt ?? '',
                            width: MediaQuery.of(context).size.width * 0.7,
                            height: MediaQuery.of(context).size.width * 0.7,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Shimmer.fromColors(
                              baseColor: AppColors.backgroundTertiary,
                              highlightColor: AppColors.backgroundSecondary,
                              child: Container(color: AppColors.backgroundTertiary),
                            ),
                            errorWidget: (context, url, error) => Container(
                              color: AppColors.backgroundTertiary,
                              child: const Icon(
                                Icons.music_note,
                                size: 100,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            )
                .animate(target: playerProvider.isPlaying ? 1 : 0)
                .scaleXY(
                  begin: 1.0,
                  end: 1.05,
                  duration: 500.ms,
                  curve: Curves.easeInOut,
                ),
          ),

          const SizedBox(height: AppSpacing.xxl),

          // Track Info with slide animation
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
                )
                    .animate()
                    .fadeIn(delay: 100.ms, duration: 400.ms)
                    .slideY(begin: 0.3, end: 0, curve: Curves.easeOut),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  track.artist,
                  style: AppTypography.h6.copyWith(color: AppColors.textSecondary),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                )
                    .animate()
                    .fadeIn(delay: 200.ms, duration: 400.ms)
                    .slideY(begin: 0.3, end: 0, curve: Curves.easeOut),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.xl),

          // Progress Bar with glow
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
            child: Column(
              children: [
                Stack(
                  children: [
                    // Glow effect
                    Container(
                      height: 4,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(2),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.accentPrimary.withOpacity(0.5),
                            blurRadius: 10,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                    ),
                    // Actual slider
                    SliderTheme(
                      data: SliderThemeData(
                        trackHeight: 4,
                        thumbShape: const RoundSliderThumbShape(
                          enabledThumbRadius: 6,
                          elevation: 4,
                          pressedElevation: 8,
                        ),
                        overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
                        activeTrackColor: AppColors.accentPrimary,
                        inactiveTrackColor: AppColors.backgroundTertiary,
                        thumbColor: AppColors.accentPrimary,
                        overlayColor: AppColors.accentPrimary.withOpacity(0.2),
                      ),
                      child: Slider(
                        value: playerProvider.position.inSeconds.toDouble(),
                        max: playerProvider.duration.inSeconds.toDouble() > 0
                            ? playerProvider.duration.inSeconds.toDouble()
                            : 1.0,
                        onChanged: (value) {
                          HapticFeedback.selectionClick();
                          playerProvider.seek(Duration(seconds: value.toInt()));
                        },
                      ),
                    ),
                  ],
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

          const SizedBox(height: AppSpacing.xxl),

          // Main Controls with animations
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: GlassContainer(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg, horizontal: AppSpacing.sm),
              borderRadius: BorderRadius.circular(30),
              color: AppColors.backgroundSecondary.withOpacity(0.3),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Shuffle
                  _buildControlButton(
                    icon: Icons.shuffle,
                    isActive: playerProvider.isShuffle,
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      playerProvider.toggleShuffle();
                    },
                  ),

                  // Previous
                  _buildControlButton(
                    icon: Icons.skip_previous,
                    size: 36,
                    onPressed: () {
                      HapticFeedback.mediumImpact();
                      playerProvider.skipPrevious();
                    },
                  ),

                  // Play/Pause with pulsing animation
                  NeonButton(
                    width: 70,
                    height: 70,
                    onPressed: () {
                      HapticFeedback.heavyImpact();
                      playerProvider.togglePlayPause();
                    },
                    child: Icon(
                      playerProvider.isPlaying ? Icons.pause : Icons.play_arrow,
                      color: AppColors.black,
                      size: 36,
                    ),
                  )
                      .animate(
                        onPlay: (controller) => playerProvider.isPlaying
                            ? controller.repeat(reverse: true)
                            : controller.stop(),
                      )
                      .scaleXY(
                        begin: 1.0,
                        end: 1.1,
                        duration: 1.seconds,
                        curve: Curves.easeInOut,
                      )
                      .shimmer(duration: 2.seconds, color: AppColors.accentPrimary.withOpacity(0.3)),

                  // Next
                  _buildControlButton(
                    icon: Icons.skip_next,
                    size: 36,
                    onPressed: () {
                      HapticFeedback.mediumImpact();
                      playerProvider.skipNext();
                    },
                  ),

                  // Repeat
                  _buildControlButton(
                    icon: playerProvider.repeatMode == RepeatMode.one
                        ? Icons.repeat_one
                        : Icons.repeat,
                    isActive: playerProvider.repeatMode != RepeatMode.off,
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      playerProvider.toggleRepeat();
                    },
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
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                // Like button with heart animation
                IconButton(
                  icon: Icon(
                    isLiked ? Icons.favorite : Icons.favorite_border,
                    color: isLiked ? AppColors.error : AppColors.textPrimary,
                    size: 32,
                  ),
                  onPressed: () {
                    HapticFeedback.mediumImpact();
                    if (isLiked) {
                      libraryProvider.unlikeSong(track.id);
                    } else {
                      libraryProvider.likeSong(track);
                    }
                  },
                )
                    .animate(target: isLiked ? 1 : 0)
                    .scaleXY(begin: 1, end: 1.3, duration: 200.ms, curve: Curves.elasticOut),

                // Volume slider popup
                IconButton(
                  icon: const Icon(Icons.volume_up, color: AppColors.textPrimary, size: 32),
                  onPressed: () => _showVolumeSlider(context, playerProvider),
                ),

                // Speed control
                IconButton(
                  icon: const Icon(Icons.speed, color: AppColors.textPrimary, size: 32),
                  onPressed: () => _showSpeedControl(context, playerProvider),
                ),

                // Share
                IconButton(
                  icon: const Icon(Icons.share_outlined, color: AppColors.textPrimary, size: 32),
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    // Share functionality
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.xl),
        ],
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    double size = 28,
    bool isActive = false,
    required VoidCallback onPressed,
  }) {
    return IconButton(
      icon: Icon(
        icon,
        color: isActive ? AppColors.accentPrimary : AppColors.textPrimary,
        size: size,
      ),
      onPressed: onPressed,
    )
        .animate(target: isActive ? 1 : 0)
        .scaleXY(begin: 1, end: 1.1, duration: 200.ms)
        .shimmer(duration: 1.seconds, color: AppColors.accentPrimary);
  }

  Widget _buildQueueView(PlayerProvider playerProvider) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Queue (${playerProvider.queue.length})', style: AppTypography.h5),
              TextButton(
                onPressed: () {
                  HapticFeedback.lightImpact();
                  playerProvider.clearQueue();
                },
                child: const Text('Clear All', style: TextStyle(color: AppColors.error)),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: playerProvider.queue.length,
            itemBuilder: (context, index) {
              final track = playerProvider.queue[index];
              final isCurrentTrack = track.id == playerProvider.currentTrack?.id;

              return Dismissible(
                key: Key(track.id),
                direction: DismissDirection.endToStart,
                onDismissed: (_) {
                  HapticFeedback.mediumImpact();
                  playerProvider.removeFromQueue(index);
                },
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: AppSpacing.md),
                  color: AppColors.error.withOpacity(0.2),
                  child: const Icon(Icons.delete, color: AppColors.error),
                ),
                child: ListTile(
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: CachedNetworkImage(
                      imageUrl: track.albumArt ?? '',
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Shimmer.fromColors(
                        baseColor: AppColors.backgroundTertiary,
                        highlightColor: AppColors.backgroundSecondary,
                        child: Container(color: AppColors.backgroundTertiary),
                      ),
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
                  trailing: const Icon(Icons.drag_handle, color: AppColors.textSecondary),
                  onTap: () {
                    HapticFeedback.selectionClick();
                    playerProvider.playTrack(track, playlist: playerProvider.queue);
                  },
                ),
              )
                  .animate(delay: (index * 50).ms)
                  .fadeIn(duration: 300.ms)
                  .slideX(begin: 0.2, end: 0);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildLyricsView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.lyrics_outlined, size: 80, color: AppColors.textSecondary),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Lyrics not available',
            style: AppTypography.h6.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Lyrics will be displayed here when available',
            style: AppTypography.caption.copyWith(color: AppColors.textTertiary),
            textAlign: TextAlign.center,
          ),
        ],
      ).animate().fadeIn(duration: 300.ms).scale(),
    );
  }

  void _showVolumeSlider(BuildContext context, PlayerProvider playerProvider) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => GlassContainer(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Icon(Icons.volume_down, color: AppColors.textSecondary),
                  Expanded(
                    child: Slider(
                      value: playerProvider.volume,
                      onChanged: (value) {
                        HapticFeedback.selectionClick();
                        playerProvider.setVolume(value);
                      },
                      activeColor: AppColors.accentPrimary,
                      inactiveColor: AppColors.backgroundTertiary,
                    ),
                  ),
                  const Icon(Icons.volume_up, color: AppColors.textPrimary),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSpeedControl(BuildContext context, PlayerProvider playerProvider) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => GlassContainer(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Playback Speed', style: AppTypography.h6),
              const SizedBox(height: AppSpacing.md),
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: [0.5, 0.75, 1.0, 1.25, 1.5, 2.0].map((speed) {
                  final isSelected = playerProvider.playbackSpeed == speed;
                  return GestureDetector(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      playerProvider.setPlaybackSpeed(speed);
                      Navigator.pop(context);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.sm,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.accentPrimary
                            : AppColors.backgroundTertiary,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${speed}x',
                        style: TextStyle(
                          color: isSelected ? AppColors.black : AppColors.textPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  );
                }).toList(),
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
}
