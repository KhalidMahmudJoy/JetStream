import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/typography.dart';
import '../../../core/theme/spacing.dart';
import '../../../services/deezer_service.dart';
import '../../../providers/player_provider.dart';
import '../../../providers/library_provider.dart';
import '../../../shared/models/track.dart';
import '../../../shared/models/album.dart';
import '../../../shared/widgets/glass_container.dart';

class AlbumDetailScreen extends StatefulWidget {
  final String albumId;
  
  const AlbumDetailScreen({super.key, required this.albumId});

  @override
  State<AlbumDetailScreen> createState() => _AlbumDetailScreenState();
}

class _AlbumDetailScreenState extends State<AlbumDetailScreen> {
  final DeezerService _deezerService = DeezerService();
  Album? _album;
  List<Track> _tracks = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAlbum();
  }

  Future<void> _loadAlbum() async {
    setState(() => _isLoading = true);
    try {
      final album = await _deezerService.getAlbum(widget.albumId);
      final tracks = await _deezerService.getAlbumTracks(widget.albumId);
      
      setState(() {
        _album = album;
        _tracks = tracks;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: AppColors.backgroundPrimary,
        body: Center(child: CircularProgressIndicator(color: AppColors.accentPrimary)),
      );
    }

    if (_album == null) {
      return Scaffold(
        backgroundColor: AppColors.backgroundPrimary,
        appBar: AppBar(
          backgroundColor: AppColors.backgroundPrimary,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: const Center(
          child: Text('Album not found', style: TextStyle(color: AppColors.textSecondary)),
        ),
      );
    }

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
          CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 300,
                pinned: true,
                backgroundColor: Colors.transparent,
                elevation: 0,
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      CachedNetworkImage(
                        imageUrl: _album!.coverArt ?? '',
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(color: AppColors.backgroundTertiary),
                        errorWidget: (context, url, error) => Container(
                          color: AppColors.backgroundTertiary,
                          child: const Icon(Icons.album, size: 100, color: AppColors.textSecondary),
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              AppColors.backgroundPrimary.withOpacity(0.8),
                              AppColors.backgroundPrimary,
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _album!.title,
                        style: AppTypography.h3.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        _album!.artist,
                        style: AppTypography.h6.copyWith(color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Row(
                        children: [
                          ElevatedButton.icon(
                            onPressed: () => _playAll(),
                            icon: const Icon(Icons.play_arrow, color: AppColors.black),
                            label: const Text('Play All'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.secondaryPrimary,
                              foregroundColor: AppColors.black,
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          ElevatedButton.icon(
                            onPressed: () {},
                            icon: const Icon(Icons.shuffle, color: AppColors.textPrimary),
                            label: const Text('Shuffle'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.backgroundSecondary,
                              foregroundColor: AppColors.textPrimary,
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      Text('Tracks', style: AppTypography.h5),
                      const SizedBox(height: AppSpacing.md),
                    ],
                  ),
                ),
              ),
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final track = _tracks[index];
                    return _buildTrackTile(track, index);
                  },
                  childCount: _tracks.length,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTrackTile(Track track, int index) {
    final playerProvider = context.watch<PlayerProvider>();
    final isPlaying = playerProvider.currentTrack?.id == track.id && playerProvider.isPlaying;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 4),
      child: GlassContainer(
        padding: EdgeInsets.zero,
        borderRadius: BorderRadius.circular(12),
        color: AppColors.backgroundSecondary.withOpacity(0.5),
        child: ListTile(
          leading: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.backgroundTertiary,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Center(
              child: Text(
                '${index + 1}',
                style: const TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          title: Text(
            track.title,
            style: TextStyle(
              color: isPlaying ? AppColors.accentPrimary : AppColors.textPrimary,
              fontWeight: isPlaying ? FontWeight.bold : FontWeight.normal,
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
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: Icon(
                  isPlaying ? Icons.pause : Icons.play_arrow,
                  color: AppColors.accentPrimary,
                ),
                onPressed: () {
                  if (isPlaying) {
                    playerProvider.pause();
                  } else {
                    playerProvider.playTrack(track, playlist: _tracks);
                    context.read<LibraryProvider>().addToRecentlyPlayed(track);
                  }
                },
              ),
              IconButton(
                icon: const Icon(Icons.more_vert, color: AppColors.textSecondary),
                onPressed: () {},
              ),
            ],
          ),
          onTap: () {
            playerProvider.playTrack(track, playlist: _tracks);
            context.read<LibraryProvider>().addToRecentlyPlayed(track);
          },
        ),
      ),
    ).animate().fadeIn(delay: Duration(milliseconds: index * 30)).slideX(
      begin: -0.2,
      duration: const Duration(milliseconds: 300),
    );
  }

  void _playAll() {
    if (_tracks.isEmpty) return;

    context.read<PlayerProvider>().playTrack(_tracks.first, playlist: _tracks);
    context.read<LibraryProvider>().addToRecentlyPlayed(_tracks.first);
  }
}
