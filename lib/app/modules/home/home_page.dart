import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:carousel_slider/carousel_slider.dart';
import '../../core/theme/app_theme.dart'; // Path: ../../
import '../../core/utils/app_routes.dart'; // Path: ../../
import 'home_controller.dart';
import '../widgets/movie_poster_card.dart'; // Path: ../
import '../../data/models/movie_model.dart'; // Path: ../../

class HomePage extends GetView<HomeController> {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Cinema Noir",
          style: GoogleFonts.playfairDisplay(
            color: AppTheme.primaryGold,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          // Tombol Search
          IconButton(
            onPressed: controller.navigateToSearch,
            icon: const Icon(Icons.search, color: AppTheme.primaryGold),
          ),

          // --- INI PERUBAHANNYA ---
          // Tombol Profil diubah jadi Tombol Logout
          IconButton(
            onPressed: controller.navigateToProfile, // Panggil fungsi logout
            icon: const Icon(
              Icons.person_outline,
              color: AppTheme.primaryGold,
            ), // Ganti ikon
          ),
          const SizedBox(width: 8),
        ],
      ),
      // Gunakan Obx untuk mendengarkan perubahan state (isLoading)
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: AppTheme.primaryGold),
          );
        }

        // Gunakan SingleChildScrollView agar bisa di-scroll
        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Carousel Poster
              _buildCarousel(controller.carouselMovies),

              const SizedBox(height: 24),

              // 2. Filter Genre
              _buildSectionTitle("Categories"),
              _buildGenreFilter(),

              const SizedBox(height: 24),

              // 3. Daftar "Now Playing"
              _buildSectionTitle("Now Playing"),
              _buildMovieList(controller.nowPlayingMovies),

              const SizedBox(height: 24),

              // 4. Daftar "Coming Soon"
              _buildSectionTitle("Coming Soon"),
              _buildMovieList(controller.upcomingMovies),

              const SizedBox(height: 30),
            ],
          ),
        );
      }),
    );
  }

  // Widget untuk Judul Section
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: AppTheme.lightText,
        ),
      ),
    );
  }

  // Widget untuk Carousel
  Widget _buildCarousel(List<MovieModel> movies) {
    if (movies.isEmpty) {
      return Container(
        height: 220,
        color: AppTheme.secondaryBackground,
        child: const Center(child: Text("No movies to display")),
      );
    }

    return CarouselSlider(
      options: CarouselOptions(
        height: 220.0,
        autoPlay: true,
        autoPlayInterval: const Duration(seconds: 5),
        enlargeCenterPage: true,
        viewportFraction: 0.85,
        aspectRatio: 16 / 9,
      ),
      items: movies.map((movie) {
        return Builder(
          builder: (BuildContext context) {
            return Container(
              width: MediaQuery.of(context).size.width,
              margin: const EdgeInsets.symmetric(horizontal: 5.0),
              decoration: BoxDecoration(
                color: AppTheme.secondaryBackground,
                borderRadius: BorderRadius.circular(12),
                image: DecorationImage(
                  image: NetworkImage(movie.fullBackdropPath), // Ambil backdrop
                  fit: BoxFit.cover,
                ),
              ),
            );
          },
        );
      }).toList(),
    );
  }

  // Widget untuk Filter Genre
  Widget _buildGenreFilter() {
    return Container(
      height: 40,
      margin: const EdgeInsets.only(top: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: controller.genres.length,
        itemBuilder: (context, index) {
          final genre = controller.genres[index];
          return Obx(() {
            final isSelected = controller.selectedGenre.value == genre;
            return GestureDetector(
              onTap: () => controller.changeGenre(genre),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppTheme.primaryGold
                      : AppTheme.secondaryBackground,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  genre,
                  style: GoogleFonts.poppins(
                    color: isSelected
                        ? AppTheme.darkText
                        : AppTheme.lightText.withOpacity(0.7),
                    fontWeight: isSelected
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
              ),
            );
          });
        },
      ),
    );
  }

  // Widget untuk List Film (Horizontal)
  Widget _buildMovieList(List<MovieModel> movies) {
    return Container(
      height: 200, // Tinggi poster
      margin: const EdgeInsets.only(top: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: movies.length,
        itemBuilder: (context, index) {
          final movie = movies[index];
          return MoviePosterCard(
            posterUrl: movie.fullPosterPath, // Ambil poster
            onTap: () {
              // Kirim ID film ke halaman detail
              Get.toNamed(AppRoutes.movieDetail, arguments: movie.id);
            },
          );
        },
      ),
    );
  }
}
