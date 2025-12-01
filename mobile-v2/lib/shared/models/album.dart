class Album {
  final String id;
  final String title;
  final String artist;
  final String? artistId;
  final String? coverArt;
  final int? trackCount;
  final String? releaseDate;
  final List<String>? trackIds;

  Album({
    required this.id,
    required this.title,
    required this.artist,
    this.artistId,
    this.coverArt,
    this.trackCount,
    this.releaseDate,
    this.trackIds,
  });

  factory Album.fromJson(Map<String, dynamic> json) {
    return Album(
      id: json['id'].toString(),
      title: json['title'] ?? '',
      artist: json['artist']?['name'] ?? '',
      artistId: json['artist']?['id']?.toString(),
      coverArt: json['cover_medium'] ?? json['cover_big'],
      trackCount: json['nb_tracks'],
      releaseDate: json['release_date'],
      trackIds: json['tracks']?.map<String>((t) => t['id'].toString()).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'artist': artist,
      'artistId': artistId,
      'coverArt': coverArt,
      'trackCount': trackCount,
      'releaseDate': releaseDate,
      'trackIds': trackIds,
    };
  }
}
