import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Added missing import
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

  final String _imageBaseUrl =
      'https://lyypmixrenhvidobfqaw.supabase.co/storage/v1/object/public/products/';

  // Data List
  final nowPlayingMovies = <MovieModel>[].obs;
  final topRatedMovies = <MovieModel>[].obs;
  final upcomingMovies = <MovieModel>[].obs;
  final rentalMovies = <MovieModel>[].obs;
  final popularFoods = <FoodModel>[].obs;
  final communityPosts = <CommunityModel>[].obs;

  late final RxList<String> promoImages;

  @override
  void onInit() {
    super.onInit();
    promoImages = [
      "${_imageBaseUrl}banner1.jpg",
      "${_imageBaseUrl}banner2.jpg",
      "${_imageBaseUrl}banner3.jpg",
    ].obs;

    _loadUserName();
    _fetchDashboardData();
  }

  void _loadUserName() async {
    User? user = _auth.currentUser;
    if (user != null) {
      // Langsung coba ambil dari Firestore, skip default email
      try {
        var userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
        if (userDoc.exists) {
          var data = userDoc.data();
          if (data != null &&
              data['name'] != null &&
              data['name'].toString().isNotEmpty) {
            userName.value = data['name'];
          }
        }
      } catch (e) {
        // Fallback silent
      }
    }
  }

  void _fetchDashboardData() async {
    try {
      isLoading.value = true;

      final results = await Future.wait([
        _tmdbProvider.getNowPlayingMovies(),
        _tmdbProvider.getTopRatedMovies(),
        _tmdbProvider.getUpcomingMovies(),
      ]);

      nowPlayingMovies.value = results[0].take(5).toList();
      topRatedMovies.value = results[1].take(5).toList();

      // --- PERBAIKAN LOGIKA COMING SOON ---
      // Filter list Upcoming: Hanya ambil yang tanggal rilisnya > Hari Ini
      DateTime now = DateTime.now();
      DateTime today = DateTime(now.year, now.month, now.day);

      List<MovieModel> rawUpcoming = results[2];

      // Filter: Hanya yang rilis SETELAH hari ini
      var trueUpcoming = rawUpcoming.where((movie) {
        try {
          DateTime release = DateTime.parse(movie.releaseDate);
          return release.isAfter(today);
        } catch (e) {
          return false;
        }
      }).toList();

      // Jika hasil filter kosong (misal semua upcoming sudah rilis),
      // fallback ambil 5 terakhir dari raw list (biasanya tanggalnya paling jauh)
      if (trueUpcoming.isEmpty) {
        // Sort descending by date (paling jauh di depan)
        rawUpcoming.sort((a, b) => b.releaseDate.compareTo(a.releaseDate));
        trueUpcoming = rawUpcoming;
      }

      upcomingMovies.value = trueUpcoming.take(5).toList();
      // ------------------------------------

      var rentals = List<MovieModel>.from(results[1]);
      rentals.shuffle();
      rentalMovies.value = rentals.take(5).toList();

      if (nowPlayingMovies.isNotEmpty) {
        final firstMovieId = nowPlayingMovies[0].id;
        final reviews = await _tmdbProvider.getMovieReviews(firstMovieId);
        communityPosts.value = reviews;
      }

      popularFoods.value = [
        FoodModel(
          name: "Popcorn Caramel",
          price: "Rp 50.000",
          category: "Snack",
          rating: 4.9,
          description: "Popcorn klasik.",
          image: "${_imageBaseUrl}popcorn.jpg",
        ),
        FoodModel(
          name: "Coca Cola",
          price: "Rp 30.000",
          category: "Drink",
          rating: 4.8,
          description: "Soda dingin.",
          image: "${_imageBaseUrl}coke.jpg",
        ),
        FoodModel(
          name: "Combo Couple",
          price: "Rp 95.000",
          category: "Combo",
          rating: 5.0,
          description: "Paket hemat.",
          image: "${_imageBaseUrl}combo_solo.jpg",
        ),
        FoodModel(
          name: "Nachos Cheese",
          price: "Rp 50.000",
          category: "Snack",
          rating: 4.5,
          description: "Tortilla keju.",
          image: "${_imageBaseUrl}cheese_balls.jpg",
        ),
      ];
    } catch (e) {
      print("Error fetching dashboard data: $e");
    } finally {
      isLoading.value = false;
    }
  }

  void navigateToMovies({String type = 'now_playing'}) {
    Get.toNamed(AppRoutes.movies, arguments: type);
  }

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
