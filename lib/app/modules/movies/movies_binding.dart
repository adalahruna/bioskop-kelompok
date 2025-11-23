import 'package:get/get.dart';
import 'movies_controller.dart';
// Kita pastikan provider TMDB tersedia
import '../../data/providers/tmdb_provider.dart';

class MoviesBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MoviesController>(() => MoviesController());
    // Pastikan TmdbProvider ada di memori saat halaman ini dibuka
    Get.lazyPut<TmdbProvider>(() => TmdbProvider());
  }
}
