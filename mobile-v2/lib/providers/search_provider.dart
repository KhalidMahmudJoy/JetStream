import 'package:flutter/foundation.dart';
import '../shared/models/track.dart';
import '../shared/models/album.dart';
import '../shared/models/artist.dart';
import '../services/deezer_service.dart';
import '../services/storage_service.dart';

class SearchProvider extends ChangeNotifier {
  final DeezerService _deezerService = DeezerService();
  final StorageService _storageService;
  
  List<Track> _trackResults = [];
  List<Album> _albumResults = [];
  List<Artist> _artistResults = [];
  bool _isLoading = false;
  String _lastQuery = '';
  SearchFilter _currentFilter = SearchFilter.all;
  List<String> _searchHistory = [];

  SearchProvider(this._storageService) {
    _loadSearchHistory();
  }

  Future<void> _loadSearchHistory() async {
    _searchHistory = await _storageService.getSearchHistory();
    notifyListeners();
  }

  List<Track> get trackResults => List.unmodifiable(_trackResults);
  List<Album> get albumResults => List.unmodifiable(_albumResults);
  List<Artist> get artistResults => List.unmodifiable(_artistResults);
  bool get isLoading => _isLoading;
  String get lastQuery => _lastQuery;
  SearchFilter get currentFilter => _currentFilter;
  List<String> get searchHistory => List.unmodifiable(_searchHistory);

  void setFilter(SearchFilter filter) {
    _currentFilter = filter;
    notifyListeners();
  }

  Future<void> search(String query) async {
    if (query.trim().isEmpty) {
      clearResults();
      return;
    }

    _isLoading = true;
    _lastQuery = query;
    notifyListeners();

    try {
      final results = await _deezerService.search(query);
      
      _trackResults = results['tracks'] ?? [];
      _albumResults = results['albums'] ?? [];
      _artistResults = results['artists'] ?? [];

      // Add to search history
      await _storageService.addSearchHistory(query);
      await _loadSearchHistory();
    } catch (e) {
      debugPrint('Search error: $e');
      _trackResults = [];
      _albumResults = [];
      _artistResults = [];
    }

    _isLoading = false;
    notifyListeners();
  }

  void clearResults() {
    _trackResults = [];
    _albumResults = [];
    _artistResults = [];
    _lastQuery = '';
    notifyListeners();
  }

  Future<void> clearHistory() async {
    await _storageService.clearSearchHistory();
    _searchHistory.clear();
    notifyListeners();
  }

  Future<void> removeFromHistory(String query) async {
    await _storageService.removeSearchHistory(query);
    _searchHistory.remove(query);
    notifyListeners();
  }
}

enum SearchFilter {
  all,
  tracks,
  albums,
  artists,
}
