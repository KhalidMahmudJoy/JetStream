import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/colors.dart';
import '../../../providers/search_provider.dart';
import '../../../providers/player_provider.dart';
import '../../../providers/library_provider.dart';
import '../../../shared/widgets/shimmer_loader.dart';
import '../../../shared/models/track.dart';
import 'package:cached_network_image/cached_network_image.dart';

class SearchScreenComplete extends StatefulWidget {
  const SearchScreenComplete({super.key});

  @override
  State<SearchScreenComplete> createState() => _SearchScreenCompleteState();
}

class _SearchScreenCompleteState extends State<SearchScreenComplete> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocus = FocusNode();

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final searchProvider = context.watch<SearchProvider>();

    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      body: SafeArea(
        child: Column(
          children: [
            _buildSearchBar(searchProvider),
            _buildFilterChips(searchProvider),
            Expanded(
              child: _buildSearchResults(searchProvider),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar(SearchProvider searchProvider) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: TextField(
        controller: _searchController,
        focusNode: _searchFocus,
        style: const TextStyle(color: AppColors.textPrimary),
        decoration: InputDecoration(
          hintText: 'Search songs, artists, albums...',
          hintStyle: const TextStyle(color: AppColors.textSecondary),
          prefixIcon: const Icon(Icons.search, color: AppColors.accentPrimary),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, color: AppColors.textSecondary),
                  onPressed: () {
                    _searchController.clear();
                    searchProvider.clearResults();
                    setState(() {});
                  },
                )
              : null,
          filled: true,
          fillColor: AppColors.backgroundSecondary,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.accentPrimary, width: 2),
          ),
        ),
        onChanged: (value) {
          setState(() {});
          if (value.isEmpty) {
            searchProvider.clearResults();
          } else {
            Future.delayed(const Duration(milliseconds: 500), () {
              if (_searchController.text == value && value.isNotEmpty) {
                searchProvider.search(value);
              }
            });
          }
        },
      ),
    );
  }

  Widget _buildFilterChips(SearchProvider searchProvider) {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _buildFilterChip('All', SearchFilter.all, searchProvider),
          const SizedBox(width: 8),
          _buildFilterChip('Tracks', SearchFilter.tracks, searchProvider),
          const SizedBox(width: 8),
          _buildFilterChip('Albums', SearchFilter.albums, searchProvider),
          const SizedBox(width: 8),
          _buildFilterChip('Artists', SearchFilter.artists, searchProvider),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, SearchFilter filter, SearchProvider searchProvider) {
    final isSelected = searchProvider.currentFilter == filter;
    
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        searchProvider.setFilter(filter);
      },
      backgroundColor: AppColors.backgroundSecondary,
      selectedColor: AppColors.accentPrimary.withOpacity(0.2),
      labelStyle: TextStyle(
        color: isSelected ? AppColors.accentPrimary : AppColors.textSecondary,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
      ),
      side: BorderSide(
        color: isSelected ? AppColors.accentPrimary : AppColors.backgroundTertiary,
      ),
    );
  }

  Widget _buildSearchResults(SearchProvider searchProvider) {
    if (_searchController.text.isEmpty) {
      return _buildSearchHistory(searchProvider);
    }

    if (searchProvider.isLoading) {
      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 10,
        itemBuilder: (context, index) => const ShimmerTrackTile(),
      );
    }

    if (searchProvider.lastQuery.isNotEmpty && 
        searchProvider.trackResults.isEmpty && 
        searchProvider.albumResults.isEmpty && 
        searchProvider.artistResults.isEmpty) {
      return _buildEmptyState();
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (searchProvider.currentFilter == SearchFilter.all || 
            searchProvider.currentFilter == SearchFilter.tracks)
          if (searchProvider.trackResults.isNotEmpty) ...[
            _buildSectionHeader('Tracks', searchProvider.trackResults.length),
            ...searchProvider.trackResults.take(5).map((track) => _buildTrackTile(track)),
            const SizedBox(height: 16),
          ],
        
        if (searchProvider.currentFilter == SearchFilter.all || 
            searchProvider.currentFilter == SearchFilter.albums)
          if (searchProvider.albumResults.isNotEmpty) ...[
            _buildSectionHeader('Albums', searchProvider.albumResults.length),
            SizedBox(
              height: 200,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: searchProvider.albumResults.length,
                itemBuilder: (context, index) {
                  final album = searchProvider.albumResults[index];
                  return _buildAlbumCard(album);
                },
              ),
            ),
            const SizedBox(height: 16),
          ],
        
        if (searchProvider.currentFilter == SearchFilter.all || 
            searchProvider.currentFilter == SearchFilter.artists)
          if (searchProvider.artistResults.isNotEmpty) ...[
            _buildSectionHeader('Artists', searchProvider.artistResults.length),
            SizedBox(
              height: 180,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: searchProvider.artistResults.length,
                itemBuilder: (context, index) {
                  final artist = searchProvider.artistResults[index];
                  return _buildArtistCard(artist);
                },
              ),
            ),
          ],
      ],
    );
  }

  Widget _buildSectionHeader(String title, int count) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            '$count results',
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrackTile(Track track) {
    final libraryProvider = context.watch<LibraryProvider>();
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

  Widget _buildAlbumCard(album) {
    return Container(
      width: 140,
      margin: const EdgeInsets.only(right: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: CachedNetworkImage(
              imageUrl: album.coverArt ?? '',
              width: 140,
              height: 140,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                color: AppColors.backgroundTertiary,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            album.title,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
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
    );
  }

  Widget _buildArtistCard(artist) {
    return Container(
      width: 120,
      margin: const EdgeInsets.only(right: 12),
      child: Column(
        children: [
          ClipOval(
            child: CachedNetworkImage(
              imageUrl: artist.pictureUrl,
              width: 120,
              height: 120,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                color: AppColors.backgroundTertiary,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            artist.name,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSearchHistory(SearchProvider searchProvider) {
    if (searchProvider.searchHistory.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search,
              size: 80,
              color: AppColors.textSecondary.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            const Text(
              'Search for music',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Find your favorite songs, artists, and albums',
              style: TextStyle(
                color: AppColors.textTertiary,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Recent Searches',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: () => searchProvider.clearHistory(),
              child: const Text(
                'Clear All',
                style: TextStyle(color: AppColors.accentPrimary),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ...searchProvider.searchHistory.map((query) => ListTile(
          leading: const Icon(Icons.history, color: AppColors.textSecondary),
          title: Text(
            query,
            style: const TextStyle(color: AppColors.textPrimary),
          ),
          trailing: IconButton(
            icon: const Icon(Icons.close, color: AppColors.textSecondary),
            onPressed: () => searchProvider.removeFromHistory(query),
          ),
          onTap: () {
            _searchController.text = query;
            searchProvider.search(query);
          },
        )),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 80,
            color: AppColors.textSecondary.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          const Text(
            'No results found',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Try searching for something else',
            style: TextStyle(
              color: AppColors.textTertiary,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  void _playTrack(Track track) {
    final playerProvider = context.read<PlayerProvider>();
    final libraryProvider = context.read<LibraryProvider>();
    final searchProvider = context.read<SearchProvider>();
    
    playerProvider.playTrack(track, playlist: searchProvider.trackResults);
    libraryProvider.addToRecentlyPlayed(track);
  }
}
