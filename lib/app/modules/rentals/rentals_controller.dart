import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../data/models/movie_model.dart';
import '../../data/providers/tmdb_provider.dart';
import '../../core/utils/app_routes.dart';

class RentalsController extends GetxController {
  final TmdbProvider _tmdbProvider = Get.find<TmdbProvider>();
  final TextEditingController searchController = TextEditingController();

  // Data Utama
  List<MovieModel> _allMovies = [];
  final displayedMovies = <MovieModel>[].obs;
  final isLoading = true.obs;

  // Filter State
  final selectedGenre = 'All'.obs;
  final isDescending = false.obs;

  // Map Genre (Sama seperti Movies)
  final Map<String, int> genreMap = {
    'All': 0,
    'Action': 28,
    'Adventure': 12,
    'Comedy': 35,
    'Crime': 80,
    'Drama': 18,
    'Fantasy': 14,
    'Horror': 27,
    'Sci-Fi': 878,
    'Thriller': 53,
  };

  List<String> get genres => genreMap.keys.toList();

  @override
  void onInit() {
    super.onInit();
    fetchRentalCatalog();
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }

  void fetchRentalCatalog() async {
    try {
      isLoading.value = true;
      // Ambil data TOP RATED sebagai katalog sewa
      final movies = await _tmdbProvider.getTopRatedMovies();

      _allMovies = movies;
      displayedMovies.assignAll(_allMovies);
    } catch (e) {
      Get.snackbar("Error", "Gagal memuat katalog sewa");
    } finally {
      isLoading.value = false;
    }
  }

  void onSearch(String query) async {
    if (query.isEmpty) {
      displayedMovies.assignAll(_allMovies);
      return;
    }
    // Search Lokal (Filter dari list yang sudah ada)
    // Atau bisa panggil API searchMovies jika ingin pencarian global
    final lowerQuery = query.toLowerCase();
    final result = _allMovies.where((movie) {
      return movie.title.toLowerCase().contains(lowerQuery);
    }).toList();
    displayedMovies.assignAll(result);
  }

  void filterByGenre(String genre) {
    selectedGenre.value = genre;
    if (genre == 'All') {
      displayedMovies.assignAll(_allMovies);
    } else {
      int genreId = genreMap[genre]!;
      final filtered = _allMovies
          .where((movie) => movie.genreIds.contains(genreId))
          .toList();
      displayedMovies.assignAll(filtered);
    }
    _applySort();
  }

  void toggleSort() {
    isDescending.value = !isDescending.value;
    _applySort();
  }

  void _applySort() {
    displayedMovies.sort((a, b) {
      if (isDescending.value) {
        return b.title.compareTo(a.title);
      } else {
        return a.title.compareTo(b.title);
      }
    });
  }

  void goToDetail(int id) {
    // Masuk ke detail film yang sama
    Get.toNamed(AppRoutes.movieDetail, arguments: id);
  }
}
