class Artist {
  final String id;
  final String name;
  final String? picture;
  final int? fanCount;
  final int? albumCount;

  Artist({
    required this.id,
    required this.name,
    this.picture,
    this.fanCount,
    this.albumCount,
  });

  factory Artist.fromJson(Map<String, dynamic> json) {
    return Artist(
      id: json['id'].toString(),
      name: json['name'] ?? '',
      picture: json['picture_medium'] ?? json['picture_big'],
      fanCount: json['nb_fan'],
      albumCount: json['nb_album'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'picture': picture,
      'fanCount': fanCount,
      'albumCount': albumCount,
    };
  }
}
