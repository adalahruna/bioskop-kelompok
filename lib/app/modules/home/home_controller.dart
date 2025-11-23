import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../core/utils/app_routes.dart';
import '../../data/models/movie_model.dart';
import '../../data/providers/tmdb_provider.dart';
import '../../data/models/food_model.dart';

class HomeController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TmdbProvider _tmdbProvider = Get.find<TmdbProvider>();

  final userName = "Guest".obs;
  final isLoading = true.obs;

  // Data List untuk UI
  final trendingMovies = <MovieModel>[].obs;
  final popularFoods = <FoodModel>[].obs;

  // Gambar Carousel Utama
  final promoImages = [
    "https://image.tmdb.org/t/p/w1280/8pjWz2lt2xRcLgKCFwL6E0aKsc.jpg",
    "https://image.tmdb.org/t/p/w1280/qrGtVFBI1hoSJma8hdE3h4dy13s.jpg",
    "https://image.tmdb.org/t/p/w1280/pRmF6VBsRnvWCb6tXWYnZa4JRock.jpg",
  ].obs;

  @override
  void onInit() {
    super.onInit();
    _loadUserName();
    _fetchDashboardData();
  }

  void _loadUserName() {
    User? user = _auth.currentUser;
    if (user != null && user.email != null) {
      userName.value = user.email!.split('@')[0];
    }
  }

  void _fetchDashboardData() async {
    try {
      isLoading.value = true;

      // 1. Ambil Film Trending
      final movies = await _tmdbProvider.getNowPlayingMovies();
      trendingMovies.value = movies.take(5).toList();

      // 2. Isi Data Dummy Makanan Populer (DIPERBARUI)
      // Sekarang sudah menyertakan 'rating' dan 'description'
      popularFoods.value = [
        FoodModel(
          name: "Caramel Popcorn",
          price: "Rp 45.000",
          category: "Snack",
          image:
              "https://images.unsplash.com/photo-1578849278619-e73505e9610f?q=80&w=500&auto=format&fit=crop",
          rating: 4.8, // Baru
          description:
              "Popcorn renyah dengan lapisan karamel manis premium.", // Baru
        ),
        FoodModel(
          name: "Coca Cola Large",
          price: "Rp 25.000",
          category: "Drink",
          image:
              "https://images.unsplash.com/photo-1622483767028-3f66f32aef97?q=80&w=500&auto=format&fit=crop",
          rating: 4.9, // Baru
          description: "Kesegaran soda klasik dalam ukuran besar.", // Baru
        ),
        FoodModel(
          name: "Nachos Cheese",
          price: "Rp 50.000",
          category: "Snack",
          image:
              "https://images.unsplash.com/photo-1513456852971-30c0b8199d4d?q=80&w=500&auto=format&fit=crop",
          rating: 4.5, // Baru
          description:
              "Keripik tortilla jagung dengan saus keju hangat.", // Baru
        ),
      ];
    } catch (e) {
      print("Error fetching dashboard data: $e");
    } finally {
      isLoading.value = false;
    }
  }

  // --- NAVIGASI ---
  void navigateToMovies() => Get.toNamed(AppRoutes.movies);
  void navigateToFood() => Get.toNamed(AppRoutes.food);
  void navigateToProfile() => Get.toNamed(AppRoutes.profile);

  void goToMovieDetail(int id) {
    Get.toNamed(AppRoutes.movieDetail, arguments: id);
  }

  void showFeatureNotReady(String title) {
    Get.snackbar(
      "Info",
      "$title is under development",
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(20),
      backgroundColor: Colors.black.withOpacity(0.8),
      colorText: Colors.white,
    );
  }
}
