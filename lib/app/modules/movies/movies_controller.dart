import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../data/models/movie_model.dart';
import '../../data/providers/tmdb_provider.dart';
import '../../core/utils/app_routes.dart';

class MoviesController extends GetxController {
  final TmdbProvider _tmdbProvider = Get.find<TmdbProvider>();
  final TextEditingController searchController = TextEditingController();

  // Data Utama
  List<MovieModel> _allMovies = []; 
  final displayedMovies = <MovieModel>[].obs;
  final isLoading = true.obs;
  
  // Filter & Sort State
  final selectedGenre = 'All'.obs;
  final isDescending = false.obs; // False = A-Z / Oldest, True = Z-A / Newest
  final sortMode = 'title'.obs;   // 'title' atau 'date'

  // Map Genre
  final Map<String, int> genreMap = {
    'All': 0, 'Action': 28, 'Adventure': 12, 'Comedy': 35, 'Crime': 80,
    'Drama': 18, 'Fantasy': 14, 'Horror': 27, 'Sci-Fi': 878, 'Thriller': 53,
  };

  List<String> get genres => genreMap.keys.toList();

  @override
  void onInit() {
    super.onInit();
    fetchInitialMovies();
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }

  void fetchInitialMovies() async {
    try {
      isLoading.value = true;
      final movies = await _tmdbProvider.getNowPlayingMovies();
      _allMovies = movies;
      displayedMovies.assignAll(_allMovies); 
    } catch (e) {
      Get.snackbar("Error", "Gagal memuat film");
    } finally {
      isLoading.value = false;
    }
  }

  void onSearch(String query) async {
    if (query.isEmpty) {
      displayedMovies.assignAll(_allMovies);
      return;
    }
    isLoading.value = true;
    try {
      final results = await _tmdbProvider.searchMovies(query);
      displayedMovies.assignAll(results);
    } finally {
      isLoading.value = false;
    }
  }

  void filterByGenre(String genre) {
    selectedGenre.value = genre;
    if (genre == 'All') {
      displayedMovies.assignAll(_allMovies);
    } else {
      int genreId = genreMap[genre]!;
      final filtered = _allMovies.where((movie) => movie.genreIds.contains(genreId)).toList();
      displayedMovies.assignAll(filtered);
    }
    _applySort(); // Terapkan ulang sorting setelah filter
  }

  // --- LOGIKA SORTING ---

  // Ganti Mode (Judul vs Tanggal)
  void changeSortMode(String mode) {
    sortMode.value = mode;
    // Reset arah sort biar natural (Title -> A-Z, Date -> Newest)
    isDescending.value = (mode == 'date'); 
    _applySort();
  }

  // Ganti Arah (Naik vs Turun)
  void toggleSortDirection() {
    isDescending.value = !isDescending.value;
    _applySort();
  }

  void _applySort() {
    displayedMovies.sort((a, b) {
      if (sortMode.value == 'date') {
        // Sort Berdasarkan Tanggal Rilis
        DateTime dateA = DateTime.tryParse(a.releaseDate) ?? DateTime(1900);
        DateTime dateB = DateTime.tryParse(b.releaseDate) ?? DateTime(1900);
        return isDescending.value 
            ? dateB.compareTo(dateA) // Terbaru -> Terlama
            : dateA.compareTo(dateB); // Terlama -> Terbaru
      } else {
        // Sort Berdasarkan Judul
        return isDescending.value
            ? b.title.compareTo(a.title) // Z -> A
            : a.title.compareTo(b.title); // A -> Z
      }
    });
  }

  void goToDetail(int id) {
    Get.toNamed(AppRoutes.movieDetail, arguments: id);
  }
}