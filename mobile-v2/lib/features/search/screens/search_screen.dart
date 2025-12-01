import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/typography.dart';
import '../../../core/theme/spacing.dart';
import '../../../providers/search_provider.dart';
import '../../../providers/player_provider.dart';
import '../../../providers/library_provider.dart';
import '../../../shared/widgets/shimmer_loader.dart';
import '../../../shared/widgets/glass_container.dart';
import '../../../shared/models/track.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    final query = _searchController.text;
    context.read<SearchProvider>().search(query);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final searchProvider = context.watch<SearchProvider>();

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
          SafeArea(
            child: Column(
              children: [
                // Search Bar
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: GlassContainer(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    borderRadius: BorderRadius.circular(12),
                    color: AppColors.backgroundSecondary.withOpacity(0.5),
                    child: TextField(
                      controller: _searchController,
                      style: AppTypography.bodyMedium,
                      decoration: InputDecoration(
                        hintText: 'Search tracks, albums, artists...',
                        hintStyle: const TextStyle(color: AppColors.textTertiary),
                        prefixIcon: const Icon(Icons.search, color: AppColors.textSecondary),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear, color: AppColors.textSecondary),
                                onPressed: () {
                                  _searchController.clear();
                                  searchProvider.clearResults();
                                },
                              )
                            : null,
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ),

                // Filter Chips
                SizedBox(
                  height: 40,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                    children: [
                      _buildFilterChip('All', searchProvider.currentFilter == SearchFilter.all, () {
                        searchProvider.setFilter(SearchFilter.all);
                      }),
                      _buildFilterChip('Tracks', searchProvider.currentFilter == SearchFilter.tracks, () {
                        searchProvider.setFilter(SearchFilter.tracks);
                      }),
                      _buildFilterChip('Albums', searchProvider.currentFilter == SearchFilter.albums, () {
                        searchProvider.setFilter(SearchFilter.albums);
                      }),
                      _buildFilterChip('Artists', searchProvider.currentFilter == SearchFilter.artists, () {
                        searchProvider.setFilter(SearchFilter.artists);
                      }),
                    ],
                  ),
                ),

                const SizedBox(height: AppSpacing.md),

                // Results
                Expanded(
                  child: _buildResults(searchProvider),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResults(SearchProvider searchProvider) {
    if (searchProvider.isLoading) {
      return GridView.builder(
        padding: const EdgeInsets.all(AppSpacing.md),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: AppSpacing.md,
          mainAxisSpacing: AppSpacing.md,
          childAspectRatio: 0.75,
        ),
        itemCount: 6,
        itemBuilder: (context, index) => const ShimmerCard(),
      );
    }

    if (_searchController.text.isEmpty) {
      return _buildEmptyState();
    }

    final trackResults = searchProvider.trackResults;

    if (trackResults.isEmpty) {
      return _buildNoResults();
    }

    return GridView.builder(
      padding: const EdgeInsets.all(AppSpacing.md),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: AppSpacing.md,
        mainAxisSpacing: AppSpacing.md,
        childAspectRatio: 0.75,
      ),
      itemCount: trackResults.length,
      itemBuilder: (context, index) {
        final track = trackResults[index];
        return _buildTrackCard(track, index, searchProvider);
      },
    );
  }

  Widget _buildTrackCard(Track track, int index, SearchProvider searchProvider) {
    return GestureDetector(
      onTap: () {
        final playerProvider = context.read<PlayerProvider>();
        final libraryProvider = context.read<LibraryProvider>();
        
        playerProvider.playTrack(track, playlist: searchProvider.trackResults);
        libraryProvider.addToRecentlyPlayed(track);
      },
      child: GlassContainer(
        padding: EdgeInsets.zero,
        borderRadius: BorderRadius.circular(12),
        color: AppColors.backgroundSecondary.withOpacity(0.5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(12),
                    ),
                    child: CachedNetworkImage(
                      imageUrl: track.albumArt ?? '',
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: AppColors.backgroundTertiary,
                        child: const Center(
                          child: CircularProgressIndicator(
                            color: AppColors.accentPrimary,
                            strokeWidth: 2,
                          ),
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: AppColors.backgroundTertiary,
                        child: const Icon(
                          Icons.music_note,
                          color: AppColors.textSecondary,
                          size: 40,
                        ),
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
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.sm),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
          ],
        ),
      ).animate().fadeIn(delay: Duration(milliseconds: index * 50)).scale(
            begin: const Offset(0.8, 0.8),
            duration: const Duration(milliseconds: 300),
          ),
    );
  }

  Widget _buildEmptyState() {
    final searchProvider = context.watch<SearchProvider>();
    final searchHistory = searchProvider.searchHistory;

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      children: [
        // Search History
        if (searchHistory.isNotEmpty) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recent Searches',
                style: AppTypography.h6.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
              TextButton(
                onPressed: () {
                  searchProvider.clearHistory();
                },
                child: Text(
                  'Clear',
                  style: AppTypography.label.copyWith(
                    color: AppColors.accentPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          ...searchHistory.map((query) => _buildHistoryItem(query, searchProvider)),
          const SizedBox(height: AppSpacing.xl),
        ],

        // Trending Suggestions
        Text(
          'Trending Searches',
          style: AppTypography.h6.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        ..._getTrendingSuggestions().map((suggestion) => 
          _buildSuggestionItem(suggestion)
        ),
      ],
    );
  }

  Widget _buildHistoryItem(String query, SearchProvider searchProvider) {
    return GlassContainer(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      borderRadius: BorderRadius.circular(8),
      color: AppColors.backgroundSecondary.withOpacity(0.3),
      child: Row(
        children: [
          const Icon(
            Icons.history,
            color: AppColors.textSecondary,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: InkWell(
              onTap: () {
                _searchController.text = query;
                searchProvider.search(query);
              },
              child: Text(
                query,
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(
              Icons.close,
              color: AppColors.textTertiary,
              size: 18,
            ),
            onPressed: () {
              searchProvider.removeFromHistory(query);
            },
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestionItem(String suggestion) {
    return GlassContainer(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      borderRadius: BorderRadius.circular(8),
      color: AppColors.backgroundSecondary.withOpacity(0.3),
      child: InkWell(
        onTap: () {
          _searchController.text = suggestion;
          context.read<SearchProvider>().search(suggestion);
        },
        child: Row(
          children: [
            const Icon(
              Icons.trending_up,
              color: AppColors.accentPrimary,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                suggestion,
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              color: AppColors.textTertiary,
              size: 14,
            ),
          ],
        ),
      ),
    );
  }

  List<String> _getTrendingSuggestions() {
    return [
      'Top Hits 2024',
      'Chill Vibes',
      'Workout Music',
      'Pop Hits',
      'Rock Classics',
      'Hip Hop',
      'Electronic Dance',
      'Jazz & Blues',
      'Classical Music',
      'Indie Hits',
    ];
  }

  Widget _buildNoResults() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.search_off,
            size: 64,
            color: AppColors.textTertiary,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'No results found',
            style: AppTypography.h6.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Try searching with different keywords',
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textTertiary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected, VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.only(right: AppSpacing.sm),
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        selectedColor: AppColors.accentPrimary,
        backgroundColor: AppColors.backgroundTertiary,
        labelStyle: AppTypography.label.copyWith(
          color: isSelected ? AppColors.black : AppColors.textSecondary,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        ),
        onSelected: (selected) {
          if (selected) onTap();
        },
        side: BorderSide.none,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
    );
  }
}
