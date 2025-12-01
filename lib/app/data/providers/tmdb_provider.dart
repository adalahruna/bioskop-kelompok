import 'package:dio/dio.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Untuk Timestamp
import '../models/movie_model.dart';
import '../models/movie_detail_model.dart';
import '../models/cast_model.dart';
import '../models/community_model.dart';
import '../../core/utils/api_constants.dart';

class TmdbProvider {
  final Dio _dio = Dio();
  final String _apiKey = ApiConstants.tmdbApiKey;
  final String _baseUrl = ApiConstants.tmdbBaseUrl;

  // Helper function untuk mengambil list film standar
  Future<List<MovieModel>> _fetchMovies(String endpoint) async {
    try {
      final response = await _dio.get(
        '$_baseUrl/$endpoint',
        queryParameters: {
          'api_key': _apiKey,
          'language': 'en-US',
          'page': 1,
          'include_adult': false,
        },
      );

      final List results = response.data['results'];
      return results
          .map((movieJson) => MovieModel.fromJson(movieJson))
          .toList();
    } on DioException catch (e) {
      print("DioError fetching $endpoint: $e");
      return [];
    } catch (e) {
      print("Error fetching $endpoint: $e");
      return [];
    }
  }

  // 1. Ambil film yang sedang tayang (Home - Trending)
  Future<List<MovieModel>> getNowPlayingMovies() async {
    return _fetchMovies('movie/now_playing');
  }

  // 2. Ambil film yang akan datang (Home/Movies)
  Future<List<MovieModel>> getUpcomingMovies() async {
    return _fetchMovies('movie/upcoming');
  }

  // 3. Ambil film Top Rated (Untuk halaman Rentals)
  Future<List<MovieModel>> getTopRatedMovies() async {
    return _fetchMovies('movie/top_rated');
  }

  // 4. Ambil detail satu film berdasarkan ID
  Future<MovieDetailModel?> getMovieDetail(int movieId) async {
    try {
      final response = await _dio.get(
        '$_baseUrl/movie/$movieId',
        queryParameters: {'api_key': _apiKey, 'language': 'en-US'},
      );

      return MovieDetailModel.fromJson(response.data);
    } on DioException catch (e) {
      print("DioError fetching detail: $e");
      return null;
    } catch (e) {
      print("Error fetching detail: $e");
      return null;
    }
  }

  // 5. Cari film berdasarkan query (keyword)
  Future<List<MovieModel>> searchMovies(String query) async {
    try {
      final response = await _dio.get(
        '$_baseUrl/search/movie',
        queryParameters: {
          'api_key': _apiKey,
          'language': 'en-US',
          'query': query,
          'page': 1,
          'include_adult': false,
        },
      );

      final List results = response.data['results'];
      return results
          .map((movieJson) => MovieModel.fromJson(movieJson))
          .toList();
    } catch (e) {
      print("Error searching movies: $e");
      return [];
    }
  }

  // 6. Ambil Daftar Pemeran (Credits)
  Future<List<CastModel>> getMovieCast(int movieId) async {
    try {
      final response = await _dio.get(
        '$_baseUrl/movie/$movieId/credits',
        queryParameters: {'api_key': _apiKey, 'language': 'en-US'},
      );

      final List castList = response.data['cast'];
      // Kita ambil 10 pemeran utama saja biar tidak kepanjangan
      return castList.take(10).map((json) => CastModel.fromJson(json)).toList();
    } catch (e) {
      print("Error fetching cast: $e");
      return [];
    }
  }

  // 7. Ambil Review/Ulasan dari TMDB (Untuk Community)
  Future<List<CommunityModel>> getMovieReviews(int movieId) async {
    try {
      final response = await _dio.get(
        '$_baseUrl/movie/$movieId/reviews',
        queryParameters: {'api_key': _apiKey, 'language': 'en-US', 'page': 1},
      );

      final List results = response.data['results'];

      // Ambil 5 review teratas dan konversi ke model CommunityModel kita
      return results.take(5).map((json) {
        // Ambil Avatar Path dari TMDB (kadang ada, kadang null)
        String avatarPath = json['author_details']['avatar_path'] ?? '';

        // Fix URL Avatar TMDB (kadang formatnya aneh, ada yg path doang, ada yg full url)
        if (avatarPath.isNotEmpty) {
          if (!avatarPath.startsWith('http')) {
            avatarPath = 'https://image.tmdb.org/t/p/w200$avatarPath';
          } else if (avatarPath.startsWith('/http')) {
            avatarPath = avatarPath.substring(1); // Hapus slash depan jika ada
          }
        }

        return CommunityModel(
          id: json['id'] ?? '',
          userName: json['author'] ?? 'TMDB Reviewer',
          userId: 'tmdb_bot',
          text: json['content'] ?? '',
          // Parsing tanggal created_at (ISO 8601) ke Firestore Timestamp
          timestamp: Timestamp.fromDate(
            DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
          ),
          photoUrl: avatarPath, // Gunakan URL avatar yang sudah difix
          likes: 0,
        );
      }).toList();
    } catch (e) {
      print("Error fetching TMDB reviews: $e");
      return [];
    }
  }
}
