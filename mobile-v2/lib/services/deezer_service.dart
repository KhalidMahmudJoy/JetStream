import 'dart:convert';
import 'package:http/http.dart' as http;
import '../shared/models/track.dart';
import '../shared/models/album.dart';
import '../shared/models/artist.dart';

/// Deezer API Service
/// Provides access to Deezer's public API for music streaming
class DeezerService {
  static const String baseUrl = 'https://api.deezer.com';
  static const String corsProxy = 'https://corsproxy.io/?';
  
  final http.Client _client;
  final bool useCorsProxy;

  DeezerService({
    http.Client? client,
    this.useCorsProxy = false,
  }) : _client = client ?? http.Client();

  String _buildUrl(String endpoint) {
    final url = '$baseUrl$endpoint';
    return useCorsProxy ? '$corsProxy$url' : url;
  }

  /// Search for all types (tracks, albums, artists)
  Future<Map<String, dynamic>> search(String query, {int limit = 25}) async {
    try {
      final tracks = await searchTracks(query, limit: limit);
      final albums = await searchAlbums(query, limit: limit);
      final artists = await searchArtists(query, limit: limit);
      
      return {
        'tracks': tracks,
        'albums': albums,
        'artists': artists,
      };
    } catch (e) {
      return {
        'tracks': <Track>[],
        'albums': <Album>[],
        'artists': <Artist>[],
      };
    }
  }

  /// Get chart data
  Future<Map<String, dynamic>> getChart({int limit = 25}) async {
    try {
      print('Fetching chart data...');
      final tracks = await getChartTracks(limit: limit);
      print('Fetched ${tracks.length} tracks');
      final albums = await getChartAlbums(limit: limit);
      print('Fetched ${albums.length} albums');
      final artists = await getChartArtists(limit: limit);
      print('Fetched ${artists.length} artists');
      
      return {
        'tracks': tracks,
        'albums': albums,
        'artists': artists,
      };
    } catch (e) {
      print('Error fetching chart data: $e');
      return {
        'tracks': <Track>[],
        'albums': <Album>[],
        'artists': <Artist>[],
      };
    }
  }

  /// Search for tracks, albums, or artists
  Future<List<Track>> searchTracks(String query, {int limit = 25}) async {
    try {
      final url = _buildUrl('/search?q=$query&limit=$limit');
      final response = await _client.get(
        Uri.parse(url),
        headers: {'User-Agent': 'JetStream/1.0 (Mobile)'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List tracks = data['data'] ?? [];
        return tracks.map((track) => Track.fromJson(track)).toList();
      } else {
        throw Exception('Failed to search tracks: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error searching tracks: $e');
    }
  }

  /// Search for albums
  Future<List<Album>> searchAlbums(String query, {int limit = 25}) async {
    try {
      final url = _buildUrl('/search/album?q=$query&limit=$limit');
      final response = await _client.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List albums = data['data'] ?? [];
        return albums.map((album) => Album.fromJson(album)).toList();
      } else {
        throw Exception('Failed to search albums: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error searching albums: $e');
    }
  }

  /// Search for artists
  Future<List<Artist>> searchArtists(String query, {int limit = 25}) async {
    try {
      final url = _buildUrl('/search/artist?q=$query&limit=$limit');
      final response = await _client.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List artists = data['data'] ?? [];
        return artists.map((artist) => Artist.fromJson(artist)).toList();
      } else {
        throw Exception('Failed to search artists: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error searching artists: $e');
    }
  }

  /// Get track by ID
  Future<Track> getTrack(String id) async {
    try {
      final url = _buildUrl('/track/$id');
      final response = await _client.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return Track.fromJson(data);
      } else {
        throw Exception('Failed to get track: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error getting track: $e');
    }
  }

  /// Get album by ID with tracks
  Future<Album> getAlbum(String id) async {
    try {
      final url = _buildUrl('/album/$id');
      final response = await _client.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return Album.fromJson(data);
      } else {
        throw Exception('Failed to get album: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error getting album: $e');
    }
  }

  /// Get album tracks
  Future<List<Track>> getAlbumTracks(String id) async {
    try {
      final url = _buildUrl('/album/$id/tracks');
      final response = await _client.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List tracks = data['data'] ?? [];
        return tracks.map((track) => Track.fromJson(track)).toList();
      } else {
        throw Exception('Failed to get album tracks: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error getting album tracks: $e');
    }
  }

  /// Get artist by ID
  Future<Artist> getArtist(String id) async {
    try {
      final url = _buildUrl('/artist/$id');
      final response = await _client.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return Artist.fromJson(data);
      } else {
        throw Exception('Failed to get artist: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error getting artist: $e');
    }
  }

  /// Get artist top tracks
  Future<List<Track>> getArtistTopTracks(String id, {int limit = 25}) async {
    try {
      final url = _buildUrl('/artist/$id/top?limit=$limit');
      final response = await _client.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List tracks = data['data'] ?? [];
        return tracks.map((track) => Track.fromJson(track)).toList();
      } else {
        throw Exception('Failed to get artist top tracks: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error getting artist top tracks: $e');
    }
  }

  /// Get chart (trending tracks, albums, artists)
  Future<List<Track>> getChartTracks({int limit = 25}) async {
    try {
      final url = _buildUrl('/chart/0/tracks?limit=$limit');
      final response = await _client.get(
        Uri.parse(url),
        headers: {'User-Agent': 'JetStream/1.0 (Mobile)'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List tracks = data['data'] ?? [];
        return tracks.map((track) => Track.fromJson(track)).toList();
      } else {
        throw Exception('Failed to get chart tracks: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error getting chart tracks: $e');
    }
  }

  /// Get chart albums
  Future<List<Album>> getChartAlbums({int limit = 25}) async {
    try {
      final url = _buildUrl('/chart/0/albums?limit=$limit');
      final response = await _client.get(
        Uri.parse(url),
        headers: {'User-Agent': 'JetStream/1.0 (Mobile)'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List albums = data['data'] ?? [];
        return albums.map((album) => Album.fromJson(album)).toList();
      } else {
        throw Exception('Failed to get chart albums: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error getting chart albums: $e');
    }
  }

  /// Get chart artists
  Future<List<Artist>> getChartArtists({int limit = 25}) async {
    try {
      final url = _buildUrl('/chart/0/artists?limit=$limit');
      final response = await _client.get(
        Uri.parse(url),
        headers: {'User-Agent': 'JetStream/1.0 (Mobile)'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List artists = data['data'] ?? [];
        return artists.map((artist) => Artist.fromJson(artist)).toList();
      } else {
        throw Exception('Failed to get chart artists: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error getting chart artists: $e');
    }
  }

  void dispose() {
    _client.close();
  }
}
