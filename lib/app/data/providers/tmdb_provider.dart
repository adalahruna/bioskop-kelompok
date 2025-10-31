import 'package:dio/dio.dart';
import '../models/movie_model.dart';
import '../models/movie_detail_model.dart'; // <-- IMPORT BARU
import '../../core/utils/api_constants.dart';

class TmdbProvider {
  final Dio _dio = Dio();
  final String _apiKey = ApiConstants.tmdbApiKey;
  final String _baseUrl = ApiConstants.tmdbBaseUrl;

  // Fungsi untuk mengambil list film (tetap sama)
  Future<List<MovieModel>> _fetchMovies(String endpoint) async {
    // ... (kode ini tetap sama, tidak perlu diubah)
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

  Future<List<MovieModel>> getNowPlayingMovies() async {
    return _fetchMovies('movie/now_playing');
  }

  Future<List<MovieModel>> getUpcomingMovies() async {
    return _fetchMovies('movie/upcoming');
  }

  // --- FUNGSI BARU DI BAWAH INI ---

  // Ambil detail satu film berdasarkan ID-nya
  Future<MovieDetailModel?> getMovieDetail(int movieId) async {
    try {
      final response = await _dio.get(
        '$_baseUrl/movie/$movieId', // Endpoint-nya berbeda
        queryParameters: {'api_key': _apiKey, 'language': 'en-US'},
      );

      // Datanya adalah satu objek JSON (bukan list)
      // Kita ubah menjadi MovieDetailModel
      return MovieDetailModel.fromJson(response.data);
    } on DioException catch (e) {
      print("DioError fetching detail: $e");
      return null;
    } catch (e) {
      print("Error fetching detail: $e");
      return null;
    }
  }
}
