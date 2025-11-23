import 'package:dio/dio.dart';
import '../models/movie_model.dart';
import '../models/movie_detail_model.dart';
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
        queryParameters: {'api_key': _apiKey, 'language': 'en-US', 'page': 1},
      );

      final List results = response.data['results'];
      return results
          .map((movieJson) => MovieModel.fromJson(movieJson))
          .toList();
    } on DioException catch (e) {
      print("DioError: $e");
      return [];
    } catch (e) {
      print("Error: $e");
      return [];
    }
  }

  // 1. Ambil film yang sedang tayang
  Future<List<MovieModel>> getNowPlayingMovies() async {
    return _fetchMovies('movie/now_playing');
  }

  // 2. Ambil film yang akan datang
  Future<List<MovieModel>> getUpcomingMovies() async {
    return _fetchMovies('movie/upcoming');
  }

  // 3. Ambil detail satu film berdasarkan ID
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

  // 4. Cari film berdasarkan query (keyword)
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
}
