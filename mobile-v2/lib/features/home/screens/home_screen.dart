import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/typography.dart';
import '../../../core/theme/spacing.dart';
import '../../../providers/player_provider.dart';
import '../../../providers/library_provider.dart';
import '../../../services/deezer_service.dart';
import '../../../shared/models/track.dart';
import '../../../shared/models/album.dart';
import '../../../shared/models/artist.dart';
import '../../../shared/widgets/shimmer_loader.dart';
import '../../../shared/widgets/glass_container.dart';
import 'package:cached_network_image/cached_network_image.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final DeezerService _deezerService = DeezerService();
  List<Track> _trendingTracks = [];
  List<Album> _trendingAlbums = [];
  List<Artist> _popularArtists = [];
  List<Album> _madeForYou = [];
  List<Track> _recentlyPlayed = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    
    try {
      print('🎵 Fetching music data from Deezer...');
      
      // Fetch chart data (tracks, albums, artists)
      final chartData = await _deezerService.getChart(limit: 50);
      print('📊 Chart data fetched');
      
      final tracks = chartData['tracks'] as List<Track>? ?? [];
      final albums = chartData['albums'] as List<Album>? ?? [];
      final artists = chartData['artists'] as List<Artist>? ?? [];
      
      print('✅ Got ${tracks.length} tracks, ${albums.length} albums, ${artists.length} artists');
      
      // Fetch "Made For You" - Mix of different genres
      print('🎁 Fetching Made For You...');
      final madeForYouResults = await Future.wait([
        _deezerService.searchAlbums('pop hits 2024', limit: 10),
        _deezerService.searchAlbums('chill relax', limit: 10),
        _deezerService.searchAlbums('workout energy', limit: 10),
      ]);
      
      final allMadeForYou = madeForYouResults.expand((list) => list).toList();
      allMadeForYou.shuffle();
      print('✅ Made For You: ${allMadeForYou.length} albums');
      
      final libraryProvider = context.read<LibraryProvider>();
      
      setState(() {
        _trendingTracks = tracks.take(20).toList();
        _trendingAlbums = albums.take(12).toList();
        _popularArtists = artists.take(12).toList();
        _madeForYou = allMadeForYou.take(12).toList();
        _recentlyPlayed = libraryProvider.recentlyPlayed.take(10).toList();
        _isLoading = false;
      });
      
      print('🎉 All data loaded successfully!');
    } catch (e) {
      print('❌ Error loading home data: $e');
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to load music. Please check your connection.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final libraryProvider = context.watch<LibraryProvider>();
    
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
          RefreshIndicator(
            onRefresh: _loadData,
            color: AppColors.accentPrimary,
            backgroundColor: AppColors.backgroundSecondary,
            child: SafeArea(
              child: CustomScrollView(
                slivers: [
                  // App Bar
                  SliverAppBar(
                    backgroundColor: Colors.transparent,
                    floating: true,
                    title: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _getGreeting(),
                          style: AppTypography.caption,
                        ),
                        Text(
                          'JetStream',
                          style: AppTypography.h5,
                        ),
                      ],
                    ),
                    actions: [
                      IconButton(
                        icon: const Icon(Icons.notifications_outlined),
                        onPressed: () {},
                      ),
                      IconButton(
                        icon: const Icon(Icons.settings_outlined),
                        onPressed: () {},
                      ),
                    ],
                  ),

                  // Content
                  SliverPadding(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        // Error Message
                        if (_errorMessage != null) ...[
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppColors.error.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.error.withOpacity(0.3)),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.error_outline, color: AppColors.error),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    _errorMessage!,
                                    style: const TextStyle(color: AppColors.textPrimary),
                                  ),
                                ),
                                TextButton(
                                  onPressed: _loadData,
                                  child: const Text('Retry'),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xl),
                        ],
                        
                        // Quick Play Section
                        Text(
                          'Quick Play',
                          style: AppTypography.h5,
                        ),
                        const SizedBox(height: AppSpacing.md),
                        _buildQuickPlayGrid(libraryProvider),
                        
                        const SizedBox(height: AppSpacing.xl),

                        // Recently Played
                        if (_recentlyPlayed.isNotEmpty) ...[
                          Text(
                            'Recently Played',
                            style: AppTypography.h5,
                          ),
                          const SizedBox(height: AppSpacing.md),
                          _buildRecentlyPlayed(),
                          const SizedBox(height: AppSpacing.xl),
                        ],

                        // Trending Albums
                        if (_trendingAlbums.isNotEmpty) ...[
                          Text(
                            'Trending Albums',
                            style: AppTypography.h5,
                          ),
                          const SizedBox(height: AppSpacing.md),
                          _buildAlbumsSection(_trendingAlbums),
                          const SizedBox(height: AppSpacing.xl),
                        ],

                        // Popular Artists
                        if (_popularArtists.isNotEmpty) ...[
                          Text(
                            'Popular Artists',
                            style: AppTypography.h5,
                          ),
                          const SizedBox(height: AppSpacing.md),
                          _buildArtistsSection(_popularArtists),
                          const SizedBox(height: AppSpacing.xl),
                        ],

                        // Trending Tracks
                        if (_trendingTracks.isNotEmpty) ...[
                          Text(
                            'Trending Tracks',
                            style: AppTypography.h5,
                          ),
                          const SizedBox(height: AppSpacing.md),
                          _buildTrendingSection(),
                          const SizedBox(height: AppSpacing.xl),
                        ],

                        // Made For You
                        if (_madeForYou.isNotEmpty) ...[
                          Text(
                            '🎁 Made For You',
                            style: AppTypography.h5,
                          ),
                          const SizedBox(height: AppSpacing.md),
                          _buildAlbumsSection(_madeForYou),
                          const SizedBox(height: AppSpacing.xl),
                        ],
                      ]),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 18) return 'Good Afternoon';
    return 'Good Evening';
  }

  Widget _buildQuickPlayGrid(LibraryProvider libraryProvider) {
    final likedCount = libraryProvider.likedSongs.length;
    final playlistCount = libraryProvider.playlists.length;

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: AppSpacing.sm,
      mainAxisSpacing: AppSpacing.sm,
      childAspectRatio: 3,
      children: [
        _buildQuickPlayCard(
          'Liked Songs',
          '$likedCount songs',
          Icons.favorite,
          AppColors.secondaryPrimary,
          () => _playLikedSongs(),
        ),
        _buildQuickPlayCard(
          'Playlists',
          '$playlistCount lists',
          Icons.library_music,
          AppColors.accentPrimary,
          () => _navigateToLibrary(),
        ),
        _buildQuickPlayCard(
          'Recently Played',
          '${_recentlyPlayed.length}',
          Icons.history,
          AppColors.accentPrimary,
          () => _playRecentlyPlayed(),
        ),
        _buildQuickPlayCard(
          'Trending',
          'Top ${_trendingTracks.length}',
          Icons.trending_up,
          AppColors.secondaryPrimary,
          () => _playTrending(),
        ),
      ],
    );
  }

  Widget _buildQuickPlayCard(String title, String subtitle, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: GlassContainer(
        padding: EdgeInsets.zero,
        borderRadius: BorderRadius.circular(16),
        color: AppColors.backgroundSecondary.withOpacity(0.5),
        child: Row(
          children: [
            Container(
              width: 60,
              height: double.infinity,
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  bottomLeft: Radius.circular(16),
                ),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentlyPlayed() {
    if (_isLoading) {
      return SizedBox(
        height: 180,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: 5,
          itemBuilder: (context, index) => Container(
            width: 140,
            margin: const EdgeInsets.only(right: 12),
            child: const ShimmerCard(),
          ),
        ),
      );
    }

    return SizedBox(
      height: 200,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _recentlyPlayed.length,
        itemBuilder: (context, index) {
          final track = _recentlyPlayed[index];
          return _buildMusicCard(track);
        },
      ),
    );
  }

  Widget _buildTrendingSection() {
    if (_isLoading) {
      return SizedBox(
        height: 180,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: 5,
          itemBuilder: (context, index) => Container(
            width: 140,
            margin: const EdgeInsets.only(right: 12),
            child: const ShimmerCard(),
          ),
        ),
      );
    }

    if (_trendingTracks.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Failed to load trending music',
              style: TextStyle(color: AppColors.textSecondary),
            ),
            TextButton(
              onPressed: _loadData,
              child: const Text('Retry', style: TextStyle(color: AppColors.accentPrimary)),
            ),
          ],
        ),
      );
    }

    return SizedBox(
      height: 200,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _trendingTracks.length,
        itemBuilder: (context, index) {
          final track = _trendingTracks[index];
          return _buildMusicCard(track);
        },
      ),
    );
  }

  Widget _buildMusicCard(Track track) {
    return GestureDetector(
      onTap: () => _playTrack(track),
      child: Container(
        width: 140,
        margin: const EdgeInsets.only(right: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: CachedNetworkImage(
                    imageUrl: track.albumArt ?? '',
                    width: 140,
                    height: 140,
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
                Positioned(
                  right: 8,
                  bottom: 8,
                  child: GestureDetector(
                    onTap: () => _playTrack(track),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: AppColors.secondaryPrimary,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.secondaryPrimary.withOpacity(0.4),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.play_arrow,
                        color: AppColors.black,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              track.title,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              track.artist,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  void _playTrack(Track track) {
    final playerProvider = context.read<PlayerProvider>();
    final libraryProvider = context.read<LibraryProvider>();
    
    playerProvider.playTrack(track, playlist: _trendingTracks);
    libraryProvider.addToRecentlyPlayed(track);
  }

  void _playLikedSongs() {
    final libraryProvider = context.read<LibraryProvider>();
    final playerProvider = context.read<PlayerProvider>();
    
    if (libraryProvider.likedSongs.isNotEmpty) {
      playerProvider.playTrack(
        libraryProvider.likedSongs.first,
        playlist: libraryProvider.likedSongs,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No liked songs yet')),
      );
    }
  }

  void _playRecentlyPlayed() {
    final playerProvider = context.read<PlayerProvider>();
    
    if (_recentlyPlayed.isNotEmpty) {
      playerProvider.playTrack(
        _recentlyPlayed.first,
        playlist: _recentlyPlayed,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No recently played tracks')),
      );
    }
  }

  void _playTrending() {
    final playerProvider = context.read<PlayerProvider>();
    
    if (_trendingTracks.isNotEmpty) {
      playerProvider.playTrack(
        _trendingTracks.first,
        playlist: _trendingTracks,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No trending tracks available')),
      );
    }
  }

  void _navigateToLibrary() {
    // Navigate to Library tab - show message to guide user
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Tap Library icon at the bottom to view all playlists'),
        duration: Duration(seconds: 2),
        backgroundColor: AppColors.accentPrimary,
      ),
    );
  }

  Widget _buildAlbumsSection(List<Album> albums) {
    if (_isLoading) {
      return SizedBox(
        height: 200,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: 5,
          itemBuilder: (context, index) => Container(
            width: 140,
            margin: const EdgeInsets.only(right: 12),
            child: const ShimmerCard(),
          ),
        ),
      );
    }

    return SizedBox(
      height: 220,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: albums.length,
        itemBuilder: (context, index) {
          final album = albums[index];
          return GestureDetector(
            onTap: () {
              // Navigate to album detail
              // Navigator.pushNamed(context, '/album', arguments: album.id);
            },
            child: Container(
              width: 140,
              margin: const EdgeInsets.only(right: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: CachedNetworkImage(
                          imageUrl: album.coverArt ?? '',
                          width: 140,
                          height: 140,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            color: AppColors.backgroundTertiary,
                          ),
                          errorWidget: (context, url, error) => Container(
                            color: AppColors.backgroundTertiary,
                            child: const Icon(Icons.album, color: AppColors.textSecondary),
                          ),
                        ),
                      ),
                      Positioned(
                        right: 8,
                        bottom: 8,
                        child: Container(
                          width: 36,
                          height: 36,
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
                          child: const Icon(
                            Icons.play_arrow,
                            color: AppColors.black,
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    album.title,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    album.artist,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildArtistsSection(List<Artist> artists) {
    if (_isLoading) {
      return SizedBox(
        height: 200,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: 5,
          itemBuilder: (context, index) => Container(
            width: 140,
            margin: const EdgeInsets.only(right: 12),
            child: const ShimmerCard(),
          ),
        ),
      );
    }

    return SizedBox(
      height: 200,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: artists.length,
        itemBuilder: (context, index) {
          final artist = artists[index];
          return GestureDetector(
            onTap: () {
              // Navigate to artist detail
              // Navigator.pushNamed(context, '/artist', arguments: artist.id);
            },
            child: Container(
              width: 140,
              margin: const EdgeInsets.only(right: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(70),
                        child: CachedNetworkImage(
                          imageUrl: artist.picture ?? '',
                          width: 140,
                          height: 140,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            color: AppColors.backgroundTertiary,
                          ),
                          errorWidget: (context, url, error) => Container(
                            color: AppColors.backgroundTertiary,
                            child: const Icon(Icons.person, color: AppColors.textSecondary, size: 60),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    artist.name,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    'Artist',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
