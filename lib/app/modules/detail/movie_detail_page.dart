import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import 'movie_detail_controller.dart';

// --- INI TAMBAHANNYA ---
// Import model Anda, yang di dalamnya ada 'GenreModel'
import '../../data/models/movie_detail_model.dart';

class MovieDetailPage extends GetView<MovieDetailController> {
  const MovieDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Kita tidak pakai AppBar, tapi pakai CustomScrollView
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: AppTheme.primaryGold),
          );
        }

        final movie = controller.movie.value;
        if (movie == null) {
          return const Center(
            child: Text(
              "Detail film tidak ditemukan.",
              style: TextStyle(color: AppTheme.lightText),
            ),
          );
        }

        // Stack untuk menumpuk Tombol "Get Tickets" di atas konten
        return Stack(
          children: [
            // Konten utama yang bisa di-scroll
            CustomScrollView(
              slivers: [
                // 1. App Bar yang berisi gambar backdrop
                _buildSliverAppBar(
                  movie,
                ), // Tipe data sudah jelas (MovieDetailModel)
                // 2. Konten di bawah gambar (Judul, Sinopsis, dll)
                SliverList(
                  delegate: SliverChildListDelegate([
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Judul Film
                          Text(
                            movie.title,
                            style: GoogleFonts.playfairDisplay(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.lightText,
                            ),
                          ),
                          const SizedBox(height: 12),

                          // Info Rating, Durasi, Rilis
                          _buildMovieInfo(movie), // Tipe data sudah jelas

                          const SizedBox(height: 24),

                          // Genre Tags
                          _buildGenreTags(movie.genres),

                          const SizedBox(height: 24),

                          // Sinopsis
                          Text(
                            "Synopsis",
                            style: GoogleFonts.poppins(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.primaryGold,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            movie.overview,
                            style: GoogleFonts.poppins(
                              fontSize: 15,
                              color: AppTheme.lightText.withOpacity(0.8),
                              height: 1.6,
                            ),
                          ),

                          // Beri jarak agar tidak tertutup tombol (penting!)
                          const SizedBox(height: 120),
                        ],
                      ),
                    ),
                  ]),
                ),
              ],
            ),

            // Tombol "Get Tickets" yang menempel di bawah
            _buildStickyButton(),

            // Tombol Back kustom
            _buildBackButton(),
          ],
        );
      }),
    );
  }

  // --- PERBAIKAN DI SINI ---
  // Beri tipe data 'MovieDetailModel' pada parameter 'movie'
  Widget _buildSliverAppBar(MovieDetailModel movie) {
    return SliverAppBar(
      expandedHeight: 300.0, // Tinggi gambar saat full
      pinned: true, // App bar tetap terlihat saat scroll
      backgroundColor: AppTheme.darkBackground,
      elevation: 0,
      iconTheme: const IconThemeData(color: AppTheme.primaryGold),
      automaticallyImplyLeading: false, // Kita pakai tombol back kustom
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            // Gambar Backdrop
            Image.network(movie.fullBackdropPath, fit: BoxFit.cover),
            // Gradient hitam di bawah gambar agar menyatu
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    AppTheme.darkBackground.withOpacity(0.7),
                    AppTheme.darkBackground,
                  ],
                  stops: const [0.5, 0.9, 1.0],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- PERBAIKAN DI SINI ---
  // Beri tipe data 'MovieDetailModel' pada parameter 'movie'
  Widget _buildMovieInfo(MovieDetailModel movie) {
    return Row(
      children: [
        // Rating
        const Icon(Icons.star, color: AppTheme.primaryGold, size: 20),
        const SizedBox(width: 4),
        Text(
          movie.voteAverage.toStringAsFixed(1), // 1 angka desimal
          style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(width: 16),

        // Durasi
        const Icon(Icons.timer_outlined, color: AppTheme.primaryGold, size: 20),
        const SizedBox(width: 4),
        Text(
          movie.formattedRuntime, // "1h 45m"
          style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const SizedBox(width: 16),

        // Tahun Rilis
        const Icon(
          Icons.calendar_today_outlined,
          color: AppTheme.primaryGold,
          size: 18,
        ),
        const SizedBox(width: 4),
        Text(
          movie.releaseYear, // "2024"
          style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  // Widget untuk Genre
  Widget _buildGenreTags(List<GenreModel> genres) {
    // <- 'GenreModel' sekarang dikenali
    return Wrap(
      // Wrap agar bisa pindah baris jika genre banyak
      spacing: 8.0,
      runSpacing: 4.0,
      children: genres.map((genre) {
        return Chip(
          label: Text(
            genre.name,
            style: GoogleFonts.poppins(
              color: AppTheme.darkText,
              fontWeight: FontWeight.w600,
            ),
          ),
          backgroundColor: AppTheme.primaryGold.withOpacity(0.8),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        );
      }).toList(),
    );
  }

  // Widget untuk Tombol "Get Tickets"
  Widget _buildStickyButton() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        height: 100,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        // Gradient agar tidak menutupi konten secara kasar
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppTheme.darkBackground.withOpacity(0.0),
              AppTheme.darkBackground.withOpacity(0.9),
              AppTheme.darkBackground,
            ],
            stops: const [0.0, 0.5, 1.0],
          ),
        ),
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed:
                controller.navigateToBooking, // Panggil fungsi controller
            child: const Text("Get Tickets"),
          ),
        ),
      ),
    );
  }

  // Widget untuk tombol Back
  Widget _buildBackButton() {
    return Positioned(
      top: 40, // Sesuaikan dengan status bar
      left: 12,
      child: SafeArea(
        child: Container(
          decoration: BoxDecoration(
            color: AppTheme.darkBackground.withOpacity(0.5),
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppTheme.primaryGold),
            onPressed: () => Get.back(),
          ),
        ),
      ),
    );
  }
}
