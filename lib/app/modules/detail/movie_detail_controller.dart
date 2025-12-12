import 'package:flutter/material.dart'; // Butuh Colors
import 'package:get/get.dart';
import '../../data/models/movie_detail_model.dart';
import '../../data/providers/tmdb_provider.dart';
import '../../core/utils/app_routes.dart';
import '../../core/theme/app_theme.dart';

class MovieDetailController extends GetxController {
  final TmdbProvider _tmdbProvider = Get.find<TmdbProvider>();
  late final int movieId;
  final movie = Rx<MovieDetailModel?>(null);
  final isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    movieId = Get.arguments as int; // Pastikan argumen cuma ID (int)
    fetchMovieDetail();
  }

  void fetchMovieDetail() async {
    try {
      isLoading.value = true;
      final result = await _tmdbProvider.getMovieDetail(movieId);
      if (result != null) {
        movie.value = result;
      } else {
        Get.snackbar("Error", "Gagal memuat detail film.");
      }
    } catch (e) {
      Get.snackbar("Error", "Terjadi kesalahan: ${e.toString()}");
    } finally {
      isLoading.value = false;
    }
  }

  // --- LOGIKA BARU: CEK STATUS RILIS (DIPERBAIKI) ---
  bool get isUpcoming {
    if (movie.value == null) return false;

    // Ambil string tanggal (bisa null/kosong dari API)
    String? dateStr = movie.value?.releaseDate;

    // 1. Jika tanggal kosong (TBA) atau null, anggap sebagai Upcoming (Aman)
    // Supaya tidak sengaja terbuka untuk booking jika datanya belum siap
    if (dateStr == null || dateStr.isEmpty) {
      print("DEBUG: Tanggal kosong/null -> Default Upcoming True");
      return true;
    }

    try {
      // 2. Parse tanggal rilis
      DateTime release = DateTime.parse(dateStr);
      DateTime now = DateTime.now();
      // Normalisasi 'hari ini' ke jam 00:00:00 agar perbandingan adil
      DateTime today = DateTime(now.year, now.month, now.day);

      // 3. Bandingkan
      // Jika rilis SETELAH hari ini, berarti Upcoming (True)
      bool status = release.isAfter(today);

      // Debugging: Cek di terminal apakah tanggal terbaca benar
      print(
        "DEBUG MOVIE DATE: $dateStr vs TODAY: $today | Is Upcoming? $status",
      );

      return status;
    } catch (e) {
      print("DEBUG DATE ERROR: $e");
      // Jika error parsing (misal format tanggal aneh), anggap Upcoming (Aman)
      // Daripada membiarkan user membeli tiket yang datanya rusak
      return true;
    }
  }

  void navigateToBooking() {
    if (movie.value == null) return;

    // CEK DULU SEBELUM PINDAH
    if (isUpcoming) {
      Get.snackbar(
        "Coming Soon",
        "Sabar ya! Tiket film ini belum rilis dan belum bisa dibeli.",
        backgroundColor: Colors.grey.shade900,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(20),
        duration: const Duration(seconds: 3),
      );
      return; // Stop, jangan pindah halaman
    }

    Get.toNamed(
      AppRoutes.booking,
      arguments: {
        'id': movie.value!.id,
        'title': movie.value!.title,
        'poster': movie.value!.fullPosterPath,
        'backdrop': movie.value!.fullBackdropPath,
      },
    );
  }
}
