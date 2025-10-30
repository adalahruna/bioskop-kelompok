import 'package:dio/dio.dart';
import '../models/movie_model.dart';
import '../../core/utils/api_constants.dart';

class TmdbProvider {
  final Dio _dio = Dio();
  final String _apiKey = ApiConstants.tmdbApiKey;
  final String _baseUrl = ApiConstants.tmdbBaseUrl;

  // Fungsi untuk mengambil data film
  Future<List<MovieModel>> _fetchMovies(String endpoint) async {
    try {
      final response = await _dio.get(
        '$_baseUrl/$endpoint',
        queryParameters: {
          'api_key': _apiKey,
          'language': 'en-US',
          'page': 1,
        },
      );

 // API TMDB mengembalikan list film di dalam key 'results'
      final List results = response.data['results'];
      
      // Ubah setiap item di list JSON menjadi MovieModel
      return results.map((movieJson) => MovieModel.fromJson(movieJson)).toList();
      
    } on DioException catch (e) {
      // Tangani error
      print("DioError: $e");
      return [];
    } catch (e) {
      print("Error: $e");
      return [];
    }
  }

 // Ambil film yang sedang tayang
  Future<List<MovieModel>> getNowPlayingMovies() async {
    return _fetchMovies('movie/now_playing');
  }

  // Ambil film yang akan datang
  Future<List<MovieModel>> getUpcomingMovies() async {
    return _fetchMovies('movie/upcoming');
  }
  
  // (Nanti kita bisa tambah fungsi getGenres, getMovieDetail, dll di sini)
}
