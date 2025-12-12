import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import 'movie_detail_controller.dart';
import '../../data/models/movie_detail_model.dart';

class MovieDetailPage extends GetView<MovieDetailController> {
  const MovieDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Kita tidak pakai AppBar biasa, tapi pakai CustomScrollView agar bisa efek parallax
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

        return Stack(
          children: [
            // Konten utama yang bisa di-scroll
            CustomScrollView(
              slivers: [
                // 1. App Bar yang berisi gambar backdrop
                _buildSliverAppBar(movie),

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
                          _buildMovieInfo(movie),

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

                          // Beri jarak agar tidak tertutup tombol sticky di bawah
                          const SizedBox(height: 120),
                        ],
                      ),
                    ),
                  ]),
                ),
              ],
            ),

            // Tombol "Get Tickets" / "Coming Soon" yang menempel di bawah
            _buildStickyButton(),

            // Tombol Back kustom di pojok kiri atas
            _buildBackButton(),
          ],
        );
      }),
    );
  }

  // Widget untuk Sliver App Bar (Gambar Backdrop)
  Widget _buildSliverAppBar(MovieDetailModel movie) {
    return SliverAppBar(
      expandedHeight: 300.0,
      pinned: true,
      backgroundColor: AppTheme.darkBackground,
      elevation: 0,
      iconTheme: const IconThemeData(color: AppTheme.primaryGold),
      automaticallyImplyLeading: false,
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(movie.fullBackdropPath, fit: BoxFit.cover),
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

  // Widget untuk Info (Rating, Durasi, Tanggal)
  Widget _buildMovieInfo(MovieDetailModel movie) {
    return Row(
      children: [
        const Icon(Icons.star, color: AppTheme.primaryGold, size: 20),
        const SizedBox(width: 4),
        Text(
          movie.voteAverage.toStringAsFixed(1),
          style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(width: 16),

        const Icon(Icons.timer_outlined, color: AppTheme.primaryGold, size: 20),
        const SizedBox(width: 4),
        Text(
          movie.formattedRuntime,
          style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const SizedBox(width: 16),

        const Icon(
          Icons.calendar_today_outlined,
          color: AppTheme.primaryGold,
          size: 18,
        ),
        const SizedBox(width: 4),
        Text(
          movie.releaseYear,
          style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  Widget _buildGenreTags(List<GenreModel> genres) {
    return Wrap(
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

  // --- PERBAIKAN: TOMBOL DENGAN IKON & WARNA JELAS ---
  Widget _buildStickyButton() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        height: 100,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
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
          child: Obx(() {
            bool upcoming = controller.isUpcoming;

            // Menggunakan ElevatedButton.icon agar perubahannya lebih terlihat
            return ElevatedButton.icon(
              onPressed: upcoming
                  ? () => controller
                        .navigateToBooking() // Tetap panggil untuk munculkan snackbar
                  : controller.navigateToBooking, // Pindah halaman

              style: ElevatedButton.styleFrom(
                // Warna Abu-abu Gelap untuk Coming Soon, Emas untuk Tayang
                backgroundColor: upcoming
                    ? const Color(0xFF424242)
                    : AppTheme.primaryGold,
                foregroundColor: upcoming ? Colors.white70 : AppTheme.darkText,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                elevation: upcoming
                    ? 0
                    : 4, // Hilangkan bayangan jika Coming Soon
              ),
              // Ikon Gembok (Lock) jika belum tayang, Tiket jika sudah
              icon: Icon(
                upcoming ? Icons.lock_clock : Icons.confirmation_number,
              ),
              label: Text(
                upcoming ? "Coming Soon" : "Get Tickets",
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildBackButton() {
    return Positioned(
      top: 40,
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
