import 'package:get/get.dart';
import '../../data/models/movie_model.dart';
import '../../data/providers/tmdb_provider.dart';
import '../../core/utils/app_routes.dart';

class MoviesController extends GetxController {
  // Kita ambil provider TMDB
  final TmdbProvider _tmdbProvider = Get.find<TmdbProvider>();

  final nowPlayingMovies = <MovieModel>[].obs;
  final upcomingMovies = <MovieModel>[].obs;

  final isLoading = true.obs;
  final genres = [
    'Action',
    'Sci-Fi',
    'Drama',
    'Comedy',
    'Horror',
    'Animation',
  ].obs;
  final selectedGenre = 'Action'.obs;

  @override
  void onInit() {
    super.onInit();
    fetchMovies();
  }

  void fetchMovies() async {
    try {
      isLoading.value = true;
      // Panggil API (sama seperti logika lama)
      final results = await Future.wait([
        _tmdbProvider.getNowPlayingMovies(),
        _tmdbProvider.getUpcomingMovies(),
      ]);

      nowPlayingMovies.value = results[0];
      upcomingMovies.value = results[1];
    } catch (e) {
      Get.snackbar("Error", "Gagal memuat film: ${e.toString()}");
    } finally {
      isLoading.value = false;
    }
  }

  void changeGenre(String genre) {
    selectedGenre.value = genre;
    Get.snackbar("Filter", "Menampilkan genre $genre");
  }

  // Fungsi untuk pindah ke detail
  void goToDetail(int id) {
    Get.toNamed(AppRoutes.movieDetail, arguments: id);
  }
}
