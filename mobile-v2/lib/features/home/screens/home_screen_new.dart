import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/colors.dart';
import '../../../providers/player_provider.dart';
import '../../../providers/library_provider.dart';
import '../../../services/deezer_service.dart';
import '../../../shared/models/track.dart';
import '../../../shared/widgets/music_card.dart';
import '../../../shared/widgets/shimmer_loader.dart';

class HomeScreenComplete extends StatefulWidget {
  const HomeScreenComplete({super.key});

  @override
  State<HomeScreenComplete> createState() => _HomeScreenCompleteState();
}

class _HomeScreenCompleteState extends State<HomeScreenComplete> {
  final DeezerService _deezerService = DeezerService();
  List<Track> _trendingTracks = [];
  List<Track> _recentlyPlayed = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    
    try {
      final chartData = await _deezerService.getChart();
      final libraryProvider = context.read<LibraryProvider>();
      
      setState(() {
        _trendingTracks = chartData['tracks']?.take(10).toList() ?? [];
        _recentlyPlayed = libraryProvider.recentlyPlayed.take(10).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      body: RefreshIndicator(
        onRefresh: _loadData,
        color: AppColors.accentPrimary,
        backgroundColor: AppColors.backgroundSecondary,
        child: SafeArea(
          child: CustomScrollView(
            slivers: [
              SliverAppBar(
                floating: true,
                backgroundColor: AppColors.backgroundPrimary,
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getGreeting(),
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                    const Text(
                      'JetStream',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
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
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildQuickPlay(),
                      const SizedBox(height: 24),
                      if (_recentlyPlayed.isNotEmpty) ...[
                        _buildRecentlyPlayed(),
                        const SizedBox(height: 24),
                      ],
                      _buildTrending(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 18) return 'Good Afternoon';
    return 'Good Evening';
  }

  Widget _buildQuickPlay() {
    final libraryProvider = context.watch<LibraryProvider>();
    final likedCount = libraryProvider.likedSongs.length;
    final playlistCount = libraryProvider.playlists.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Play',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          childAspectRatio: 3,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
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
              () {},
            ),
            _buildQuickPlayCard(
              'Recently Played',
              _recentlyPlayed.length.toString(),
              Icons.history,
              AppColors.accentPrimary,
              () {},
            ),
            _buildQuickPlayCard(
              'Trending',
              'Top ${_trendingTracks.length}',
              Icons.trending_up,
              AppColors.secondaryPrimary,
              () {},
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickPlayCard(String title, String subtitle, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.backgroundSecondary,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(8),
                  bottomLeft: Radius.circular(8),
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
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Recently Played',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 200,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: 5,
              itemBuilder: (context, index) {
                return Container(
                  width: 140,
                  margin: const EdgeInsets.only(right: 12),
                  child: const ShimmerCard(),
                );
              },
            ),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Recently Played',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 210,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _recentlyPlayed.length,
            itemBuilder: (context, index) {
              final track = _recentlyPlayed[index];
              return Container(
                margin: const EdgeInsets.only(right: 12),
                child: MusicCard.fromTrack(
                  track,
                  () => _playTrack(track),
                  onPlayTap: () => _playTrack(track),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTrending() {
    if (_isLoading) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Trending Now',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 200,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: 5,
              itemBuilder: (context, index) {
                return Container(
                  width: 140,
                  margin: const EdgeInsets.only(right: 12),
                  child: const ShimmerCard(),
                );
              },
            ),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Trending Now',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 210,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _trendingTracks.length,
            itemBuilder: (context, index) {
              final track = _trendingTracks[index];
              return Container(
                margin: const EdgeInsets.only(right: 12),
                child: MusicCard.fromTrack(
                  track,
                  () => _playTrack(track),
                  onPlayTap: () => _playTrack(track),
                ),
              );
            },
          ),
        ),
      ],
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
    }
  }
}
