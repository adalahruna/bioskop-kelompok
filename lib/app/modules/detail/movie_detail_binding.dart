import 'package:get/get.dart';
import 'movie_detail_controller.dart';
// Provider TMDB sudah didaftarkan di HomeBinding,
// jadi tidak perlu didaftarkan ulang di sini.

class MovieDetailBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MovieDetailController>(() => MovieDetailController());
  }
}
