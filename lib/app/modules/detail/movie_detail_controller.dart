import 'package:get/get.dart';
import '../../data/models/movie_detail_model.dart';
import '../../data/providers/tmdb_provider.dart';
import '../../core/theme/app_theme.dart';

class MovieDetailController extends GetxController {
  final TmdbProvider _tmdbProvider = Get.find<TmdbProvider>();

  // Variabel untuk menampung ID film yang dikirim dari HomePage
  late final int movieId;

  // State untuk data film detail
  final movie = Rx<MovieDetailModel?>(null);
  final isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    // Ambil movieId yang dikirim sebagai 'arguments'
    movieId = Get.arguments as int;
    fetchMovieDetail();
  }

  void fetchMovieDetail() async {
    try {
      isLoading.value = true;
      final result = await _tmdbProvider.getMovieDetail(movieId);
      if (result != null) {
        movie.value = result;
      } else {
        Get.snackbar("Error", "Gagal memuat detail film.");
      }
    } catch (e) {
      Get.snackbar("Error", "Terjadi kesalahan: ${e.toString()}");
    } finally {
      isLoading.value = false;
    }
  }

  void navigateToBooking() {
    // Nanti kita arahkan ke halaman booking
    // Get.toNamed(AppRoutes.booking, arguments: movieId);
    Get.snackbar(
      "Fitur",
      "Halaman booking untuk ${movie.value?.title} akan segera hadir!",
      backgroundColor: AppTheme.primaryGold, // (Perlu import app_theme)
      colorText: AppTheme.darkText, // (Perlu import app_theme)
    );
  }
}

// Catatan: Jika AppTheme error, tambahkan import ini di atas:
// import '../../core/theme/app_theme.dart';
