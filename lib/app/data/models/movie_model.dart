import '../../core/utils/api_constants.dart';

class MovieModel {
  final int id;
  final String title;
  final String overview;
  final String? posterPath;
  final String? backdropPath;
  final double voteAverage;
  final List<int> genreIds;
  
  // Field penting untuk Sorting Date
  final String releaseDate; 

  MovieModel({
    required this.id,
    required this.title,
    required this.overview,
    this.posterPath,
    this.backdropPath,
    required this.voteAverage,
    required this.genreIds,
    required this.releaseDate,
  });

  factory MovieModel.fromJson(Map<String, dynamic> json) {
    return MovieModel(
      id: json['id'] ?? 0,
      title: json['title'] ?? 'No Title',
      overview: json['overview'] ?? '',
      posterPath: json['poster_path'],
      backdropPath: json['backdrop_path'],
      // Handle tipe data num (int/double) agar aman
      voteAverage: (json['vote_average'] as num?)?.toDouble() ?? 0.0,
      genreIds: List<int>.from(json['genre_ids'] ?? []),
      
      // Ambil tanggal rilis. Jika kosong/null, beri default tanggal tua
      // agar saat disort "Newest", film ini ada di paling bawah.
      releaseDate: json['release_date'] ?? "1900-01-01",
    );
  }
  
  // Getter URL Gambar
  String get fullPosterPath {
    if (posterPath != null) {
      return "${ApiConstants.tmdbImageBaseUrl_w500}$posterPath";
    }
    return "https://via.placeholder.com/500x750.png?text=No+Poster";
  }
  
  String get fullBackdropPath {
    if (backdropPath != null) {
      return "${ApiConstants.tmdbImageBaseUrl_w1280}$backdropPath";
    }
    return "https://via.placeholder.com/1280x720.png?text=No+Image";
  }

  // Helper tambahan: Ambil tahun saja (Misal: "2024")
  String get year {
    if (releaseDate.isEmpty || releaseDate.length < 4) return "";
    return releaseDate.substring(0, 4);
  }
}