class Track {
  final String id;
  final String title;
  final String artist;
  final String? artistId;
  final String? album;
  final String? albumId;
  final String? albumArt;
  final int? duration; // in seconds
  final String? previewUrl;
  final bool isLiked;

  Track({
    required this.id,
    required this.title,
    required this.artist,
    this.artistId,
    this.album,
    this.albumId,
    this.albumArt,
    this.duration,
    this.previewUrl,
    this.isLiked = false,
  });

  factory Track.fromJson(Map<String, dynamic> json) {
    return Track(
      id: json['id'].toString(),
      title: json['title'] ?? '',
      artist: json['artist']?['name'] ?? '',
      artistId: json['artist']?['id']?.toString(),
      album: json['album']?['title'],
      albumId: json['album']?['id']?.toString(),
      albumArt: json['album']?['cover_medium'] ?? json['album']?['cover_big'],
      duration: json['duration'],
      previewUrl: json['preview'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'artist': artist,
      'artistId': artistId,
      'album': album,
      'albumId': albumId,
      'albumArt': albumArt,
      'duration': duration,
      'previewUrl': previewUrl,
      'isLiked': isLiked,
    };
  }

  Track copyWith({
    String? id,
    String? title,
    String? artist,
    String? artistId,
    String? album,
    String? albumId,
    String? albumArt,
    int? duration,
    String? previewUrl,
    bool? isLiked,
  }) {
    return Track(
      id: id ?? this.id,
      title: title ?? this.title,
      artist: artist ?? this.artist,
      artistId: artistId ?? this.artistId,
      album: album ?? this.album,
      albumId: albumId ?? this.albumId,
      albumArt: albumArt ?? this.albumArt,
      duration: duration ?? this.duration,
      previewUrl: previewUrl ?? this.previewUrl,
      isLiked: isLiked ?? this.isLiked,
    );
  }
}
