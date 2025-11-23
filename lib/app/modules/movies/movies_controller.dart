import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../data/models/movie_model.dart';
import '../../data/providers/tmdb_provider.dart';
import '../../core/utils/app_routes.dart';

class MoviesController extends GetxController {
  final TmdbProvider _tmdbProvider = Get.find<TmdbProvider>();
  final TextEditingController searchController = TextEditingController();

  // Data Utama
  // _allMovies: Menyimpan data mentah dari API (backup untuk reset)
  List<MovieModel> _allMovies = [];

  // displayedMovies: Data yang ditampilkan di UI (hasil filter/sort)
  final displayedMovies = <MovieModel>[].obs;

  final isLoading = true.obs;

  // Filter State
  final selectedGenre = 'All'.obs;
  final isDescending = false.obs; // False = A-Z, True = Z-A

  // Map Genre Sederhana (Nama -> ID TMDB)
  // TMDB menggunakan ID untuk genre, bukan string.
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
    fetchInitialMovies();
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }

  // 1. Ambil data awal (Now Playing sebagai default)
  void fetchInitialMovies() async {
    try {
      isLoading.value = true;
      // Kita ambil banyak data sekaligus untuk browsing
      final movies = await _tmdbProvider.getNowPlayingMovies();

      _allMovies = movies;
      displayedMovies.assignAll(_allMovies); // Tampilkan semua
    } catch (e) {
      Get.snackbar("Error", "Gagal memuat film");
    } finally {
      isLoading.value = false;
    }
  }

  // 2. Fitur Pencarian (Search)
  void onSearch(String query) async {
    if (query.isEmpty) {
      // Jika kosong, kembalikan ke list awal
      displayedMovies.assignAll(_allMovies);
      return;
    }

    isLoading.value = true;
    try {
      // Panggil API Search
      final results = await _tmdbProvider.searchMovies(query);
      displayedMovies.assignAll(results);
    } finally {
      isLoading.value = false;
    }
  }

  // 3. Fitur Filter Genre (Client-side)
  void filterByGenre(String genre) {
    selectedGenre.value = genre;

    if (genre == 'All') {
      displayedMovies.assignAll(_allMovies);
    } else {
      int genreId = genreMap[genre]!;
      // Filter list lokal yang punya genreId tersebut
      final filtered = _allMovies
          .where((movie) => movie.genreIds.contains(genreId))
          .toList();
      displayedMovies.assignAll(filtered);
    }

    // Terapkan sorting ulang setelah filter
    _applySort();
  }

  // 4. Fitur Sorting (A-Z / Z-A)
  void toggleSort() {
    isDescending.value = !isDescending.value;
    _applySort();
  }

  void _applySort() {
    displayedMovies.sort((a, b) {
      if (isDescending.value) {
        return b.title.compareTo(a.title); // Z-A
      } else {
        return a.title.compareTo(b.title); // A-Z
      }
    });
  }

  void goToDetail(int id) {
    Get.toNamed(AppRoutes.movieDetail, arguments: id);
  }
}
