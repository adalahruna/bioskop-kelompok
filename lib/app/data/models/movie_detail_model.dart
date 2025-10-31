import '../../core/utils/api_constants.dart';

// Model kecil untuk menampung data genre
class GenreModel {
  final int id;
  final String name;
  GenreModel({required this.id, required this.name});

  factory GenreModel.fromJson(Map<String, dynamic> json) {
    return GenreModel(id: json['id'], name: json['name']);
  }
}

// Model utama untuk detail film
class MovieDetailModel {
  final int id;
  final String title;
  final String overview;
  final String? posterPath;
  final String? backdropPath;
  final double voteAverage;
  final int runtime; // Durasi film (data ini tidak ada di MovieModel)
  final String releaseDate;
  final List<GenreModel> genres; // List genre (bukan cuma ID)

  MovieDetailModel({
    required this.id,
    required this.title,
    required this.overview,
    this.posterPath,
    this.backdropPath,
    required this.voteAverage,
    required this.runtime,
    required this.releaseDate,
    required this.genres,
  });

  factory MovieDetailModel.fromJson(Map<String, dynamic> json) {
    // Ambil list genre dari JSON dan ubah menjadi List<GenreModel>
    var genreList = json['genres'] as List;
    List<GenreModel> genres = genreList
        .map((g) => GenreModel.fromJson(g))
        .toList();

    return MovieDetailModel(
      id: json['id'],
      title: json['title'],
      overview: json['overview'],
      posterPath: json['poster_path'],
      backdropPath: json['backdrop_path'],
      voteAverage: (json['vote_average'] as num).toDouble(),
      runtime: json['runtime'] ?? 0, // 'runtime' bisa jadi null
      releaseDate: json['release_date'] ?? '',
      genres: genres,
    );
  }

  // Getter untuk URL gambar (sama seperti MovieModel)
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

  // Helper untuk format durasi
  String get formattedRuntime {
    final int hours = runtime ~/ 60;
    final int minutes = runtime % 60;
    return '${hours}h ${minutes}m';
  }

  // Helper untuk format tahun rilis
  String get releaseYear {
    if (releaseDate.isEmpty) return '';
    return releaseDate.split('-')[0];
  }
}
