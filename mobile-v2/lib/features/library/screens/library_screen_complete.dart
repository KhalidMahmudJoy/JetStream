import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/colors.dart';
import '../../../providers/library_provider.dart';
import '../../../providers/player_provider.dart';
import '../../../shared/models/track.dart';
import 'package:cached_network_image/cached_network_image.dart';

class LibraryScreenComplete extends StatefulWidget {
  const LibraryScreenComplete({super.key});

  @override
  State<LibraryScreenComplete> createState() => _LibraryScreenCompleteState();
}

class _LibraryScreenCompleteState extends State<LibraryScreenComplete> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final libraryProvider = context.watch<LibraryProvider>();

    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundPrimary,
        elevation: 0,
        title: Row(
          children: [
            const Icon(Icons.library_music, color: AppColors.accentPrimary, size: 28),
            const SizedBox(width: 12),
            const Text(
              'Your Library',
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
            icon: const Icon(Icons.add, color: AppColors.accentPrimary, size: 28),
            onPressed: _showCreatePlaylistModal,
            tooltip: 'Create Playlist',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.accentPrimary,
          indicatorWeight: 3,
          labelColor: AppColors.accentPrimary,
          unselectedLabelColor: AppColors.textSecondary,
          labelStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          unselectedLabelStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          tabs: [
            Tab(text: 'Playlists (${libraryProvider.playlists.length})'),
            Tab(text: 'Liked (${libraryProvider.likedSongs.length})'),
            Tab(text: 'Recent (${libraryProvider.recentlyPlayed.length})'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildPlaylistsTab(libraryProvider),
          _buildLikedSongsTab(libraryProvider),
          _buildRecentlyPlayedTab(libraryProvider),
        ],
      ),

    );
  }

  Widget _buildPlaylistsTab(LibraryProvider libraryProvider) {
    if (libraryProvider.playlists.isEmpty) {
      return _buildEmptyState(
        Icons.queue_music,
        'No Playlists Yet',
        'Create your first playlist',
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: libraryProvider.playlists.length,
      itemBuilder: (context, index) {
        final playlist = libraryProvider.playlists[index];
        return _buildPlaylistCard(playlist);
      },
    );
  }

  Widget _buildPlaylistCard(playlist) {
    return InkWell(
      onTap: () {},
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.backgroundSecondary,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: AppColors.backgroundTertiary,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(12),
                  ),
                ),
                child: const Center(
                  child: Icon(
                    Icons.library_music,
                    size: 48,
                    color: AppColors.accentPrimary,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    playlist.name,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${playlist.trackIds.length} songs',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
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

  Widget _buildLikedSongsTab(LibraryProvider libraryProvider) {
    if (libraryProvider.likedSongs.isEmpty) {
      return _buildEmptyState(
        Icons.favorite_border,
        'No Liked Songs',
        'Start liking songs to see them here',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: libraryProvider.likedSongs.length,
      itemBuilder: (context, index) {
        final track = libraryProvider.likedSongs[index];
        return _buildTrackTile(track, libraryProvider);
      },
    );
  }

  Widget _buildRecentlyPlayedTab(LibraryProvider libraryProvider) {
    if (libraryProvider.recentlyPlayed.isEmpty) {
      return _buildEmptyState(
        Icons.history,
        'No Recently Played',
        'Start listening to see your history',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: libraryProvider.recentlyPlayed.length,
      itemBuilder: (context, index) {
        final track = libraryProvider.recentlyPlayed[index];
        return _buildTrackTile(track, libraryProvider, showLike: false);
      },
    );
  }

  Widget _buildTrackTile(Track track, LibraryProvider libraryProvider, {bool showLike = true}) {
    final isLiked = libraryProvider.isLiked(track.id);

    return InkWell(
      onTap: () => _playTrack(track),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: CachedNetworkImage(
                imageUrl: track.albumArt ?? '',
                width: 56,
                height: 56,
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
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    track.title,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    track.artist,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            if (showLike)
              IconButton(
                icon: Icon(
                  isLiked ? Icons.favorite : Icons.favorite_border,
                  color: isLiked ? AppColors.secondaryPrimary : AppColors.textSecondary,
                ),
                onPressed: () => libraryProvider.toggleLike(track),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(IconData icon, String title, String subtitle) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 80,
            color: AppColors.textSecondary.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: const TextStyle(
              color: AppColors.textTertiary,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _showCreatePlaylistModal() {
    final nameController = TextEditingController();
    final descController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.backgroundSecondary,
        title: const Text(
          'Create Playlist',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: InputDecoration(
                hintText: 'Playlist name',
                hintStyle: const TextStyle(color: AppColors.textSecondary),
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
              decoration: InputDecoration(
                hintText: 'Description (optional)',
                hintStyle: const TextStyle(color: AppColors.textSecondary),
                filled: true,
                fillColor: AppColors.backgroundTertiary,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.isNotEmpty) {
                context.read<LibraryProvider>().createPlaylist(
                  nameController.text,
                  descController.text,
                );
                Navigator.pop(context);
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

  void _playTrack(Track track) {
    final playerProvider = context.read<PlayerProvider>();
    final libraryProvider = context.read<LibraryProvider>();
    
    playerProvider.playTrack(track);
    libraryProvider.addToRecentlyPlayed(track);
  }
}
