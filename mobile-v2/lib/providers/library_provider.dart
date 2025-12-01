import 'package:flutter/foundation.dart';
import '../shared/models/track.dart';
import '../shared/models/playlist.dart';
import '../services/storage_service.dart';

class LibraryProvider extends ChangeNotifier {
  late StorageService _storageService;
  
  List<Track> _likedSongs = [];
  List<Playlist> _playlists = [];
  List<Track> _recentlyPlayed = [];
  bool _isLoading = false;

  List<Track> get likedSongs => List.unmodifiable(_likedSongs);
  List<Playlist> get playlists => List.unmodifiable(_playlists);
  List<Track> get recentlyPlayed => List.unmodifiable(_recentlyPlayed);
  bool get isLoading => _isLoading;

  LibraryProvider() {
    _initService();
  }

  Future<void> _initService() async {
    _storageService = await StorageService.init();
    await loadLibrary();
  }

  Future<void> loadLibrary() async {
    _isLoading = true;
    notifyListeners();

    _likedSongs = await _storageService.getLikedSongs();
    _playlists = await _storageService.getPlaylists();
    _recentlyPlayed = await _storageService.getRecentlyPlayed();

    _isLoading = false;
    notifyListeners();
  }

  // Liked songs
  bool isLiked(String trackId) {
    return _likedSongs.any((track) => track.id == trackId);
  }

  Future<void> toggleLike(Track track) async {
    if (isLiked(track.id)) {
      await _storageService.removeLikedSong(track.id);
      _likedSongs.removeWhere((t) => t.id == track.id);
    } else {
      await _storageService.addLikedSong(track);
      _likedSongs.insert(0, track);
    }
    notifyListeners();
  }

  Future<void> likeSong(Track track) async {
    if (!isLiked(track.id)) {
      await _storageService.addLikedSong(track);
      _likedSongs.insert(0, track);
      notifyListeners();
    }
  }

  Future<void> unlikeSong(String trackId) async {
    await _storageService.removeLikedSong(trackId);
    _likedSongs.removeWhere((t) => t.id == trackId);
    notifyListeners();
  }

  // Playlists
  Future<void> createPlaylist(String name, String description) async {
    final playlist = await _storageService.createPlaylist(name, description: description);
    _playlists.insert(0, playlist);
    notifyListeners();
  }

  Future<void> deletePlaylist(String playlistId) async {
    await _storageService.deletePlaylist(playlistId);
    _playlists.removeWhere((p) => p.id == playlistId);
    notifyListeners();
  }

  Future<void> updatePlaylist(String playlistId, String name, String description) async {
    final index = _playlists.indexWhere((p) => p.id == playlistId);
    if (index != -1) {
      final updatedPlaylist = _playlists[index].copyWith(
        name: name,
        description: description,
      );
      _playlists[index] = updatedPlaylist;
      await _storageService.updatePlaylist(updatedPlaylist);
      notifyListeners();
    }
  }

  Future<void> addTrackToPlaylist(String playlistId, Track track) async {
    await _storageService.addTrackToPlaylist(playlistId, track);
    await loadLibrary(); // Reload to get updated playlist
  }

  Future<void> removeTrackFromPlaylist(String playlistId, String trackId) async {
    await _storageService.removeTrackFromPlaylist(playlistId, trackId);
    await loadLibrary(); // Reload to get updated playlist
  }

  Playlist? getPlaylist(String playlistId) {
    try {
      return _playlists.firstWhere((p) => p.id == playlistId);
    } catch (e) {
      return null;
    }
  }

  // Recently played
  Future<void> addToRecentlyPlayed(Track track) async {
    await _storageService.addRecentlyPlayed(track);
    _recentlyPlayed.removeWhere((t) => t.id == track.id);
    _recentlyPlayed.insert(0, track);
    if (_recentlyPlayed.length > 50) {
      _recentlyPlayed.removeLast();
    }
    notifyListeners();
  }

  Future<void> clearRecentlyPlayed() async {
    await _storageService.clearRecentlyPlayed();
    _recentlyPlayed.clear();
    notifyListeners();
  }
}
