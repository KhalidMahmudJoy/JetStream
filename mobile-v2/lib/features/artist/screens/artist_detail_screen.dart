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
import '../../../shared/models/artist.dart';
import '../../../shared/widgets/glass_container.dart';

class ArtistDetailScreen extends StatefulWidget {
  final String artistId;
  
  const ArtistDetailScreen({super.key, required this.artistId});

  @override
  State<ArtistDetailScreen> createState() => _ArtistDetailScreenState();
}

class _ArtistDetailScreenState extends State<ArtistDetailScreen> {
  final DeezerService _deezerService = DeezerService();
  Artist? _artist;
  List<Track> _topTracks = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadArtist();
  }

  Future<void> _loadArtist() async {
    setState(() => _isLoading = true);
    try {
      final artist = await _deezerService.getArtist(widget.artistId);
      final topTracks = await _deezerService.getArtistTopTracks(widget.artistId);
      
      setState(() {
        _artist = artist;
        _topTracks = topTracks;
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

    if (_artist == null) {
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
          child: Text('Artist not found', style: TextStyle(color: AppColors.textSecondary)),
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
                expandedHeight: 350,
                pinned: true,
                backgroundColor: Colors.transparent,
                elevation: 0,
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      CachedNetworkImage(
                        imageUrl: _artist!.picture ?? '',
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(color: AppColors.backgroundTertiary),
                        errorWidget: (context, url, error) => Container(
                          color: AppColors.backgroundTertiary,
                          child: const Icon(Icons.person, size: 100, color: AppColors.textSecondary),
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
                        _artist!.name,
                        style: AppTypography.h3.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        '${(_artist!.fanCount ?? 0).toString()} fans',
                        style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Row(
                        children: [
                          ElevatedButton.icon(
                            onPressed: () => _playTopTracks(),
                            icon: const Icon(Icons.play_arrow, color: AppColors.black),
                            label: const Text('Play'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.secondaryPrimary,
                              foregroundColor: AppColors.black,
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          ElevatedButton.icon(
                            onPressed: () {},
                            icon: const Icon(Icons.person_add, color: AppColors.textPrimary),
                            label: const Text('Follow'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.backgroundSecondary,
                              foregroundColor: AppColors.textPrimary,
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      Text('Popular Tracks', style: AppTypography.h5),
                      const SizedBox(height: AppSpacing.md),
                    ],
                  ),
                ),
              ),
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final track = _topTracks[index];
                    return _buildTrackTile(track, index);
                  },
                  childCount: _topTracks.length,
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
          trailing: IconButton(
            icon: Icon(
              isPlaying ? Icons.pause : Icons.play_arrow,
              color: AppColors.accentPrimary,
            ),
            onPressed: () {
              if (isPlaying) {
                playerProvider.pause();
              } else {
                playerProvider.playTrack(track, playlist: _topTracks);
                context.read<LibraryProvider>().addToRecentlyPlayed(track);
              }
            },
          ),
          onTap: () {
            playerProvider.playTrack(track, playlist: _topTracks);
            context.read<LibraryProvider>().addToRecentlyPlayed(track);
          },
        ),
      ),
    ).animate().fadeIn(delay: Duration(milliseconds: index * 30)).slideX(
      begin: -0.2,
      duration: const Duration(milliseconds: 300),
    );
  }

  void _playTopTracks() {
    if (_topTracks.isEmpty) return;
    context.read<PlayerProvider>().playTrack(_topTracks.first, playlist: _topTracks);
    context.read<LibraryProvider>().addToRecentlyPlayed(_topTracks.first);
  }
}
