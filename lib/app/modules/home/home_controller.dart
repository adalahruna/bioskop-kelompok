import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../core/utils/app_routes.dart';
import '../../data/models/movie_model.dart';
import '../../data/models/community_model.dart';
import '../../data/providers/tmdb_provider.dart';
import '../../data/models/food_model.dart';

class HomeController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TmdbProvider _tmdbProvider = Get.find<TmdbProvider>();

  final userName = "Guest".obs;
  final isLoading = true.obs;

  // --- SUPABASE URL ---
  final String _imageBaseUrl =
      'https://lyypmixrenhvidobfqaw.supabase.co/storage/v1/object/public/products/';

  // --- DATA LIST UNTUK UI (RxList agar reaktif) ---
  // Kita hapus duplikasi dan gunakan nama variabel yang konsisten dengan HomePage
  final nowPlayingMovies = <MovieModel>[].obs; // Pengganti trendingMovies
  final topRatedMovies = <MovieModel>[].obs;
  final upcomingMovies = <MovieModel>[].obs;
  final rentalMovies = <MovieModel>[].obs;
  final popularFoods = <FoodModel>[].obs;
  final communityPosts = <CommunityModel>[].obs;

  // Gambar Carousel Utama
  late final RxList<String> promoImages;

  @override
  void onInit() {
    super.onInit();
    // Inisialisasi promo images
    promoImages = [
      "${_imageBaseUrl}banner1.jpg",
      "${_imageBaseUrl}banner2.jpg",
      "${_imageBaseUrl}banner3.jpg",
    ].obs;

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

      // 1. Fetch Data Film dari API
      final results = await Future.wait([
        _tmdbProvider.getNowPlayingMovies(),
        _tmdbProvider.getTopRatedMovies(),
        _tmdbProvider.getUpcomingMovies(),
      ]);

      // Assign data ke variabel RxList
      nowPlayingMovies.value = results[0].take(5).toList();
      topRatedMovies.value = results[1].take(5).toList();
      upcomingMovies.value = results[2].take(5).toList();

      // Untuk Rental, ambil dari Top Rated dan acak sedikit
      var rentals = List<MovieModel>.from(results[1]);
      rentals.shuffle();
      rentalMovies.value = rentals.take(5).toList();

      // 2. Fetch Data Komunitas (Review) dari API
      if (nowPlayingMovies.isNotEmpty) {
        final firstMovieId = nowPlayingMovies[0].id;
        final reviews = await _tmdbProvider.getMovieReviews(firstMovieId);
        communityPosts.value = reviews;
      }

      // 3. Data Makanan
      popularFoods.value = [
        FoodModel(
          name: "Popcorn Caramel",
          price: "Rp 50.000",
          category: "Snack",
          rating: 4.9,
          description: "Popcorn klasik bioskop.",
          image: "${_imageBaseUrl}popcorn.jpg",
        ),
        FoodModel(
          name: "Coca Cola",
          price: "Rp 30.000",
          category: "Drink",
          rating: 4.8,
          description: "Minuman bersoda dingin.",
          image: "${_imageBaseUrl}coke.jpg",
        ),
        FoodModel(
          name: "Combo Couple",
          price: "Rp 95.000",
          category: "Combo",
          rating: 5.0,
          description: "Paket hemat berdua.",
          image: "${_imageBaseUrl}combo_solo.jpg",
        ),
        FoodModel(
          name: "Nachos Cheese",
          price: "Rp 50.000",
          category: "Snack",
          rating: 4.5,
          description: "Tortilla dengan keju.",
          image: "${_imageBaseUrl}cheese_balls.jpg",
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
  void navigateToRentals() => Get.toNamed(AppRoutes.rentals);
  void navigateToCommunity() => Get.toNamed(AppRoutes.community);

  void goToMovieDetail(int id) {
    Get.toNamed(AppRoutes.movieDetail, arguments: id);
  }

  void showFeatureNotReady(String title) {
    Get.snackbar(
      "Info",
      "$title is coming soon!",
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.black54,
      colorText: Colors.white,
    );
  }
}
