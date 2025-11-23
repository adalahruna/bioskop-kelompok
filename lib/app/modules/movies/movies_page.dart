import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import '../widgets/movie_poster_card.dart';
import 'movies_controller.dart';

class MoviesPage extends GetView<MoviesController> {
  const MoviesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Movies Collection",
          style: GoogleFonts.playfairDisplay(color: AppTheme.primaryGold),
        ),
        iconTheme: const IconThemeData(color: AppTheme.primaryGold),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: AppTheme.primaryGold),
          );
        }
        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),

              // Filter Genre
              _buildSectionTitle("Filter by Genre"),
              _buildGenreFilter(),

              const SizedBox(height: 20),

              // List Now Playing
              _buildSectionTitle("Now Playing"),
              _buildMovieList(controller.nowPlayingMovies),

              const SizedBox(height: 20),

              // List Coming Soon
              _buildSectionTitle("Coming Soon"),
              _buildMovieList(controller.upcomingMovies),

              const SizedBox(height: 30),
            ],
          ),
        );
      }),
    );
  }

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

  Widget _buildMovieList(List<dynamic> movies) {
    return Container(
      height: 200,
      margin: const EdgeInsets.only(top: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: movies.length,
        itemBuilder: (context, index) {
          final movie = movies[index];
          return MoviePosterCard(
            posterUrl: movie.fullPosterPath,
            onTap: () => controller.goToDetail(movie.id),
          );
        },
      ),
    );
  }
}
