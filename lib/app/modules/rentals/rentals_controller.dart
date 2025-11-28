import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart'; // Ensure intl is installed
import '../../data/models/movie_model.dart';
import '../../data/providers/tmdb_provider.dart';
import '../../core/utils/app_routes.dart';
import '../../core/theme/app_theme.dart';

class RentalsController extends GetxController {
  final TmdbProvider _tmdbProvider = Get.find<TmdbProvider>();
  final TextEditingController searchController = TextEditingController();

  // --- STATE CATALOG ---
  List<MovieModel> _allMovies = [];
  final displayedMovies = <MovieModel>[].obs;
  final isLoading = true.obs;
  final selectedGenre = 'All'.obs;
  final isDescending = false.obs;

  // --- STATE RENTAL TRANSACTION ---
  final selectedMovieForRent = Rxn<MovieModel>(); // Movie to be rented
  final startDate = Rxn<DateTime>(); // Start date
  final rentalDuration = 1.obs; // Duration (in days)
  final rentalOption = "Daily".obs; // "Daily", "Weekly", "Custom"
  final isProcessing = false.obs;

  // Base Prices
  final double dailyPrice = 15000; // IDR 15k/day
  final double weeklyPrice = 75000; // IDR 75k/week (Saver)

  final Map<String, int> genreMap = {
    'All': 0,
    'Action': 28,
    'Comedy': 35,
    'Drama': 18,
    'Horror': 27,
    'Sci-Fi': 878,
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

  // --- CATALOG LOGIC ---
  void fetchRentalCatalog() async {
    try {
      isLoading.value = true;
      // Fetch TOP RATED movies as rental catalog
      final movies = await _tmdbProvider.getTopRatedMovies();
      _allMovies = movies;
      displayedMovies.assignAll(_allMovies);
    } catch (e) {
      Get.snackbar("Error", "Failed to load rental catalog");
    } finally {
      isLoading.value = false;
    }
  }

  void onSearch(String query) {
    if (query.isEmpty) {
      displayedMovies.assignAll(_allMovies);
      return;
    }
    final lowerQuery = query.toLowerCase();
    final result = _allMovies
        .where((movie) => movie.title.toLowerCase().contains(lowerQuery))
        .toList();
    displayedMovies.assignAll(result);
  }

  void filterByGenre(String genre) {
    selectedGenre.value = genre;
    if (genre == 'All') {
      displayedMovies.assignAll(_allMovies);
    } else {
      int genreId = genreMap[genre]!;
      displayedMovies.assignAll(
        _allMovies.where((movie) => movie.genreIds.contains(genreId)).toList(),
      );
    }
  }

  void toggleSort() {
    isDescending.value = !isDescending.value;
    displayedMovies.sort(
      (a, b) => isDescending.value
          ? b.title.compareTo(a.title)
          : a.title.compareTo(b.title),
    );
  }

  // --- NAVIGATION LOGIC ---
  void openRentTransaction(MovieModel movie) {
    selectedMovieForRent.value = movie;
    // Reset form defaults
    startDate.value = DateTime.now();
    rentalDuration.value = 1;
    rentalOption.value = "Daily";

    Get.toNamed(AppRoutes.rentTransaction);
  }

  // --- TRANSACTION FORM LOGIC ---

  // Calculate Total Price
  double get totalRentPrice {
    if (rentalOption.value == "Weekly") {
      // If weekly, count weeks (ceiling)
      int weeks = (rentalDuration.value / 7).ceil();
      return weeks * weeklyPrice;
    } else {
      // If daily or custom
      return rentalDuration.value * dailyPrice;
    }
  }

  // Pick Date
  void pickDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: startDate.value ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppTheme.primaryGold,
              onPrimary: Colors.black,
              surface: AppTheme.secondaryBackground,
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      startDate.value = picked;
    }
  }

  // Set Duration Option
  void setDurationOption(String option) {
    rentalOption.value = option;
    if (option == "Daily") rentalDuration.value = 1;
    if (option == "Weekly") rentalDuration.value = 7;
    // If Custom, let user edit the slider
  }

  // Submit to Firestore
  void confirmRental() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      Get.snackbar("Error", "Please login first");
      return;
    }
    if (startDate.value == null) {
      Get.snackbar("Error", "Select start date");
      return;
    }

    isProcessing.value = true;

    try {
      final endDate = startDate.value!.add(
        Duration(days: rentalDuration.value),
      );
      final dateFormat = DateFormat('yyyy-MM-dd');

      final rentalData = {
        'userId': user.uid,
        'movieId': selectedMovieForRent.value!.id,
        'movieTitle': selectedMovieForRent.value!.title,
        'posterUrl': selectedMovieForRent.value!.fullPosterPath,
        'startDate': Timestamp.fromDate(startDate.value!),
        'endDate': Timestamp.fromDate(endDate),
        'durationDays': rentalDuration.value,
        'totalPrice': totalRentPrice,
        'status': 'active', // active, expired
        'rentedAt': FieldValue.serverTimestamp(),
      };

      await FirebaseFirestore.instance.collection('rentals').add(rentalData);

      Get.back(); // Close transaction page
      Get.snackbar(
        "Success",
        "Rental confirmed! Valid until ${dateFormat.format(endDate)}",
        backgroundColor: AppTheme.primaryGold,
        colorText: Colors.black,
        duration: const Duration(seconds: 4),
      );
    } catch (e) {
      Get.snackbar("Error", "Rental failed: $e");
    } finally {
      isProcessing.value = false;
    }
  }
}
