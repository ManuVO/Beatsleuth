class Album {
  final String name;
  final String id;
  final String releaseDate;
  final int totalTracks;
  final String label;
  final String albumType;
  final Map<String, String> externalUrls;
  
  Album({
    required this.name,
    required this.id,
    required this.releaseDate,
    required this.totalTracks,
    required this.label,
    required this.albumType,
    required this.externalUrls,
  });

  factory Album.fromJson(Map<String, dynamic> json) {
    return Album(
      name: json['name'],
      id: json['id'],
      releaseDate: json['release_date'],
      totalTracks: json['total_tracks'],
      label: json['label'],
      albumType: json['album_type'],
      externalUrls: json['external_urls'] = Map<String, String>.from(json['external_urls']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'id': id,
      'release_date': releaseDate,
      'total_tracks': totalTracks,
      'label': label,
      'album_type': albumType,
      'external_urls': externalUrls,
    };
  }
}
