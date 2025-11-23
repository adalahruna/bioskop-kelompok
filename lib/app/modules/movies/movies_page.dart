import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import 'movies_controller.dart';

class MoviesPage extends GetView<MoviesController> {
  const MoviesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // AppBar dengan Tombol Sort
      appBar: AppBar(
        title: Text(
          "Browse Movies",
          style: GoogleFonts.playfairDisplay(
            color: AppTheme.primaryGold,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: AppTheme.primaryGold),
        actions: [
          // Tombol Sort (Ascending/Descending)
          Obx(
            () => IconButton(
              onPressed: controller.toggleSort,
              icon: Icon(
                controller.isDescending.value
                    ? Icons
                          .sort_by_alpha_outlined // Icon Z-A (visualisasi)
                    : Icons.sort_by_alpha, // Icon A-Z
                color: AppTheme.primaryGold,
              ),
              tooltip: "Sort A-Z / Z-A",
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),

      body: Column(
        children: [
          // 1. Search Bar Area
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: controller.searchController,
              onSubmitted: (val) =>
                  controller.onSearch(val), // Search saat Enter
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: "Search movies...",
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear, color: Colors.grey),
                  onPressed: () {
                    controller.searchController.clear();
                    controller.onSearch(''); // Reset search
                  },
                ),
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 0,
                  horizontal: 20,
                ),
                filled: true,
                fillColor: AppTheme.secondaryBackground,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // 2. Filter Genre (Horizontal List)
          SizedBox(
            height: 40,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: controller.genres.length,
              itemBuilder: (context, index) {
                final genre = controller.genres[index];
                return Obx(() {
                  final isSelected = controller.selectedGenre.value == genre;
                  return GestureDetector(
                    onTap: () => controller.filterByGenre(genre),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.only(right: 10),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppTheme.primaryGold
                            : AppTheme.secondaryBackground,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected
                              ? AppTheme.primaryGold
                              : Colors.grey.withOpacity(0.3),
                        ),
                      ),
                      child: Center(
                        child: Text(
                          genre,
                          style: GoogleFonts.poppins(
                            color: isSelected ? Colors.black : Colors.grey,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  );
                });
              },
            ),
          ),

          const SizedBox(height: 16),

          // 3. Grid Hasil Film
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(
                  child: CircularProgressIndicator(color: AppTheme.primaryGold),
                );
              }

              if (controller.displayedMovies.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.movie_outlined,
                        size: 60,
                        color: Colors.grey,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        "No movies found.",
                        style: GoogleFonts.poppins(color: Colors.grey),
                      ),
                    ],
                  ),
                );
              }

              return GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, // 2 Kolom
                  childAspectRatio:
                      0.65, // Rasio tinggi:lebar (agar poster tidak gepeng)
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: controller.displayedMovies.length,
                itemBuilder: (context, index) {
                  final movie = controller.displayedMovies[index];
                  return _buildGridMovieCard(movie);
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  // Kartu Film untuk Grid (Desain Vertikal)
  Widget _buildGridMovieCard(dynamic movie) {
    return GestureDetector(
      onTap: () => controller.goToDetail(movie.id),
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.secondaryBackground,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Poster Image
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
                child: Image.network(
                  movie.fullPosterPath,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: Colors.grey,
                    child: const Icon(Icons.error),
                  ),
                ),
              ),
            ),

            // Info Judul & Rating
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    movie.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      color: AppTheme.lightText,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.star,
                        color: AppTheme.primaryGold,
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        movie.voteAverage.toStringAsFixed(1),
                        style: GoogleFonts.poppins(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
