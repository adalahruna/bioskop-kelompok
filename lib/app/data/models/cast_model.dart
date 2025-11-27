class CastModel {
  final String name;
  final String character;
  final String profilePath;

  CastModel({
    required this.name,
    required this.character,
    required this.profilePath,
  });

  factory CastModel.fromJson(Map<String, dynamic> json) {
    return CastModel(
      name: json['name'] ?? 'Unknown',
      character: json['character'] ?? '',
      profilePath: json['profile_path'] != null
          ? 'https://image.tmdb.org/t/p/w200${json['profile_path']}'
          : 'https://via.placeholder.com/150', // Placeholder jika tidak ada foto
    );
  }
}
