// --- HAPUS IMPORT app_theme.dart ---
// import '../../core/theme/app_theme.dart';

// --- TAMBAHKAN IMPORT INI ---
import '../../core/utils/api_constants.dart'; // Import konstanta API kita

class MovieModel {
  final int id;
  final String title;
  final String overview;
  final String? posterPath;
  final String? backdropPath;
  final double voteAverage;
  final List<int> genreIds;

  MovieModel({
    required this.id,
    required this.title,
    required this.overview,
    this.posterPath,
    this.backdropPath,
    required this.voteAverage,
    required this.genreIds,
  });

  // Factory untuk mengubah JSON (dari API) menjadi MovieModel
  factory MovieModel.fromJson(Map<String, dynamic> json) {
    return MovieModel(
      id: json['id'],
      title: json['title'],
      overview: json['overview'],
      posterPath: json['poster_path'],
      backdropPath: json['backdrop_path'],
      voteAverage: (json['vote_average'] as num).toDouble(),
      genreIds: List<int>.from(json['genre_ids']),
    );
  }
  
  // Getter untuk mendapatkan URL gambar penuh
  String get fullPosterPath {
    if (posterPath != null) {
      // Sekarang 'ApiConstants' sudah dikenali
      return "${ApiConstants.tmdbImageBaseUrl_w500}$posterPath";
    }
    // Sediakan gambar placeholder jika tidak ada poster
    return "https://via.placeholder.com/500x750.png?text=No+Poster";
  }
  
  String get fullBackdropPath {
    if (backdropPath != null) {
      // Sekarang 'ApiConstants' sudah dikenali
      return "${ApiConstants.tmdbImageBaseUrl_w1280}$backdropPath";
    }
    // Sediakan gambar placeholder
    return "https://via.placeholder.com/1280x720.png?text=No+Image";
  }
}