import 'package:get/get.dart';
import '../../data/models/movie_detail_model.dart';
import '../../data/providers/tmdb_provider.dart';
import '../../core/utils/app_routes.dart'; // Import Routes

class MovieDetailController extends GetxController {
  final TmdbProvider _tmdbProvider = Get.find<TmdbProvider>();
  late final int movieId;
  final movie = Rx<MovieDetailModel?>(null);
  final isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
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

  // --- UPDATE FUNGSI INI ---
  void navigateToBooking() {
    if (movie.value == null) return;

    // Kita kirim Map berisi data lengkap, bukan cuma ID
    Get.toNamed(
      AppRoutes.booking,
      arguments: {
        'id': movie.value!.id,
        'title': movie.value!.title,
        'poster': movie.value!.fullPosterPath,
        'backdrop': movie.value!.fullBackdropPath,
      },
    );
  }
}
