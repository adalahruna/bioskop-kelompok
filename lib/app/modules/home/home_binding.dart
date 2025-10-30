Dart

import 'package:get/get.dart';
import 'home_controller.dart';
import '../../data/providers/tmdb_provider.dart'; // <-- IMPORT BARU

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HomeController>(() => HomeController());
    
    // --- TAMBAHKAN INI ---
    // Daftarkan TmdbProvider agar bisa di 'find' oleh Controller
    Get.lazyPut<TmdbProvider>(() => TmdbProvider());
  }
}
