Dart

import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/utils/app_routes.dart';
import '../../data/models/movie_model.dart'; // <-- IMPORT BARU
import '../../data/providers/tmdb_provider.dart'; // <-- IMPORT BARU

class HomeController extends GetxController {
  // Dapatkan TmdbProvider yang sudah didaftarkan di binding
  final TmdbProvider _tmdbProvider = Get.find<TmdbProvider>();
  
  // State untuk data film
  final nowPlayingMovies = <MovieModel>[].obs;
  final upcomingMovies = <MovieModel>[].obs;
  final carouselMovies = <MovieModel>[].obs;
  
  // State untuk UI
  final isLoading = true.obs;
  
  // (Data genre statis untuk UI filter)
  final genres = ['Action', 'Sci-Fi', 'Drama', 'Comedy', 'Horror', 'Animation'].obs;
  final selectedGenre = 'Action'.obs;

  @override
  void onInit() {
    super.onInit();
    fetchAllMovieData(); // Panggil API saat controller siap
  }

  void fetchAllMovieData() async {
    try {
      isLoading.value = true;
      
      // Panggil kedua API secara bersamaan
      final results = await Future.wait([
        _tmdbProvider.getNowPlayingMovies(),
        _tmdbProvider.getUpcomingMovies(),
      ]);
      
      final nowPlayingResult = results[0];
      final upcomingResult = results[1];
      
      // Isi data untuk carousel (ambil 5 film pertama dari 'now playing')
      carouselMovies.value = nowPlayingResult.take(5).toList();
      
      // Isi data untuk list
      nowPlayingMovies.value = nowPlayingResult;
      upcomingMovies.value = upcomingResult;
      
    } catch (e) {
      Get.snackbar("Error", "Gagal memuat data film: ${e.toString()}");
    } finally {
      isLoading.value = false;
    }
  }
  
  // Fungsi filter (dummy, hanya ganti state)
  void changeGenre(String genre) {
    selectedGenre.value = genre;
    // Nanti di sini Anda bisa panggil API lagi dengan filter genre
    // _tmdbProvider.getMoviesByGenre(genreId);
    Get.snackbar("Filter", "Menampilkan genre $genre (logic filter belum diimplementasi)");
  }

  void logout() async {
    await FirebaseAuth.instance.signOut();
    Get.offAllNamed(AppRoutes.login);
  }
}
