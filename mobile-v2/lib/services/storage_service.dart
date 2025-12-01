import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../shared/models/track.dart';
import '../shared/models/playlist.dart';
import 'package:uuid/uuid.dart';

/// Storage Service for local persistence
/// Manages liked songs, playlists, recently played, and settings
class StorageService {
  static const String _likedSongsKey = 'liked_songs';
  static const String _playlistsKey = 'playlists';
  static const String _recentlyPlayedKey = 'recently_played';
  static const String _settingsKey = 'settings';
  static const String _searchHistoryKey = 'search_history';

  final SharedPreferences _prefs;
  final Uuid _uuid = const Uuid();

  StorageService(this._prefs);

  static Future<StorageService> init() async {
    final prefs = await SharedPreferences.getInstance();
    return StorageService(prefs);
  }

  // ========== Liked Songs ==========

  Future<List<Track>> getLikedSongs() async {
    final String? data = _prefs.getString(_likedSongsKey);
    if (data == null) return [];

    final List<dynamic> decoded = json.decode(data);
    return decoded.map((item) => Track.fromJson(item)).toList();
  }

  Future<void> addLikedSong(Track track) async {
    final songs = await getLikedSongs();
    if (!songs.any((s) => s.id == track.id)) {
      songs.insert(0, track.copyWith(isLiked: true));
      await _saveLikedSongs(songs);
    }
  }

  Future<void> removeLikedSong(String trackId) async {
    final songs = await getLikedSongs();
    songs.removeWhere((s) => s.id == trackId);
    await _saveLikedSongs(songs);
  }

  Future<bool> isTrackLiked(String trackId) async {
    final songs = await getLikedSongs();
    return songs.any((s) => s.id == trackId);
  }

  Future<void> _saveLikedSongs(List<Track> songs) async {
    final encoded = json.encode(songs.map((s) => s.toJson()).toList());
    await _prefs.setString(_likedSongsKey, encoded);
  }

  // ========== Playlists ==========

  Future<List<Playlist>> getPlaylists() async {
    final String? data = _prefs.getString(_playlistsKey);
    if (data == null) return [];

    final List<dynamic> decoded = json.decode(data);
    return decoded.map((item) => Playlist.fromJson(item)).toList();
  }

  Future<Playlist> createPlaylist(String name, {String? description}) async {
    final playlists = await getPlaylists();
    final newPlaylist = Playlist(
      id: _uuid.v4(),
      name: name,
      description: description,
      tracks: [],
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    playlists.add(newPlaylist);
    await _savePlaylists(playlists);
    return newPlaylist;
  }

  Future<void> updatePlaylist(Playlist playlist) async {
    final playlists = await getPlaylists();
    final index = playlists.indexWhere((p) => p.id == playlist.id);
    if (index != -1) {
      playlists[index] = playlist.copyWith(updatedAt: DateTime.now());
      await _savePlaylists(playlists);
    }
  }

  Future<void> deletePlaylist(String playlistId) async {
    final playlists = await getPlaylists();
    playlists.removeWhere((p) => p.id == playlistId);
    await _savePlaylists(playlists);
  }

  Future<void> addTrackToPlaylist(String playlistId, Track track) async {
    final playlists = await getPlaylists();
    final index = playlists.indexWhere((p) => p.id == playlistId);
    if (index != -1) {
      final playlist = playlists[index];
      if (!playlist.tracks.any((t) => t.id == track.id)) {
        final updatedTracks = [...playlist.tracks, track];
        playlists[index] = playlist.copyWith(
          tracks: updatedTracks,
          updatedAt: DateTime.now(),
        );
        await _savePlaylists(playlists);
      }
    }
  }

  Future<void> removeTrackFromPlaylist(String playlistId, String trackId) async {
    final playlists = await getPlaylists();
    final index = playlists.indexWhere((p) => p.id == playlistId);
    if (index != -1) {
      final playlist = playlists[index];
      final updatedTracks = playlist.tracks.where((t) => t.id != trackId).toList();
      playlists[index] = playlist.copyWith(
        tracks: updatedTracks,
        updatedAt: DateTime.now(),
      );
      await _savePlaylists(playlists);
    }
  }

  Future<void> _savePlaylists(List<Playlist> playlists) async {
    final encoded = json.encode(playlists.map((p) => p.toJson()).toList());
    await _prefs.setString(_playlistsKey, encoded);
  }

  // ========== Recently Played ==========

  Future<List<Track>> getRecentlyPlayed({int limit = 50}) async {
    final String? data = _prefs.getString(_recentlyPlayedKey);
    if (data == null) return [];

    final List<dynamic> decoded = json.decode(data);
    final tracks = decoded.map((item) => Track.fromJson(item)).toList();
    return tracks.take(limit).toList();
  }

  Future<void> addRecentlyPlayed(Track track) async {
    final tracks = await getRecentlyPlayed();
    
    // Remove if already exists
    tracks.removeWhere((t) => t.id == track.id);
    
    // Add to beginning
    tracks.insert(0, track);
    
    // Keep only last 50
    if (tracks.length > 50) {
      tracks.removeRange(50, tracks.length);
    }
    
    final encoded = json.encode(tracks.map((t) => t.toJson()).toList());
    await _prefs.setString(_recentlyPlayedKey, encoded);
  }

  Future<void> clearRecentlyPlayed() async {
    await _prefs.remove(_recentlyPlayedKey);
  }

  // ========== Settings ==========

  Future<Map<String, dynamic>> getSettings() async {
    final String? data = _prefs.getString(_settingsKey);
    if (data == null) {
      return _defaultSettings;
    }
    return json.decode(data);
  }

  Future<void> saveSetting(String key, dynamic value) async {
    final settings = await getSettings();
    settings[key] = value;
    final encoded = json.encode(settings);
    await _prefs.setString(_settingsKey, encoded);
  }

  Future<void> saveSettings(Map<String, dynamic> settings) async {
    final encoded = json.encode(settings);
    await _prefs.setString(_settingsKey, encoded);
  }

  Future<void> resetSettings() async {
    await saveSettings(_defaultSettings);
  }

  static const Map<String, dynamic> _defaultSettings = {
    'theme': 'dark',
    'language': 'en',
    'audioQuality': 'medium',
    'autoPlay': true,
    'crossfade': 0,
    'gaplessPlayback': true,
    'volumeNormalization': false,
    'equalizer': 'off',
    'pushNotifications': true,
    'privateProfile': false,
    'explicitContent': true,
  };

  // ========== Search History ==========

  Future<List<String>> getSearchHistory({int limit = 20}) async {
    final String? data = _prefs.getString(_searchHistoryKey);
    if (data == null) return [];

    final List<dynamic> decoded = json.decode(data);
    final history = decoded.map((item) => item.toString()).toList();
    return history.take(limit).toList();
  }

  Future<void> addSearchHistory(String query) async {
    if (query.trim().isEmpty) return;
    
    final history = await getSearchHistory();
    
    // Remove if already exists
    history.remove(query);
    
    // Add to beginning
    history.insert(0, query);
    
    // Keep only last 20
    if (history.length > 20) {
      history.removeRange(20, history.length);
    }
    
    final encoded = json.encode(history);
    await _prefs.setString(_searchHistoryKey, encoded);
  }

  Future<void> removeSearchHistory(String query) async {
    final history = await getSearchHistory();
    history.remove(query);
    final encoded = json.encode(history);
    await _prefs.setString(_searchHistoryKey, encoded);
  }

  Future<void> clearSearchHistory() async {
    await _prefs.remove(_searchHistoryKey);
  }

  // ========== Cache Management ==========

  Future<void> clearCache() async {
    await _prefs.remove(_recentlyPlayedKey);
    // Add more cache clearing logic here
  }

  Future<int> getCacheSize() async {
    // Placeholder - calculate actual cache size
    return 0;
  }
}
