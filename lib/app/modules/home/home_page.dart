import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:carousel_slider/carousel_slider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/app_routes.dart';
import 'home_controller.dart';
import '../widgets/movie_poster_card.dart';
import '../../data/models/movie_model.dart';
import '../../data/models/food_model.dart';

class HomePage extends GetView<HomeController> {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Header (Nama & Profil)
              _buildHeader(),
              const SizedBox(height: 10),

              // 2. Carousel Promo
              _buildPromoCarousel(),
              const SizedBox(height: 30),

              // 3. Quick Menu (Tombol Navigasi)
              _buildQuickMenuSection(),
              const SizedBox(height: 30),

              // --- KONTEN UTAMA (6 KATEGORI) ---

              // 4. Sedang Tayang
              _buildSectionHeader("Now Showing", controller.navigateToMovies),
              _buildMovieList(controller.nowPlayingMovies),
              const SizedBox(height: 30),

              // 5. Top Rated
              _buildSectionHeader(
                "Top Rated Movies",
                controller.navigateToMovies,
              ),
              _buildMovieList(controller.topRatedMovies),
              const SizedBox(height: 30),

              // 6. Akan Tayang
              _buildSectionHeader("Coming Soon", controller.navigateToMovies),
              _buildMovieList(controller.upcomingMovies),
              const SizedBox(height: 30),

              // 7. Makanan (Dining)
              _buildSectionHeader(
                "Best Snacks & Drinks",
                controller.navigateToFood,
              ),
              _buildFoodList(controller.popularFoods),
              const SizedBox(height: 30),

              // 8. Film Rental
              _buildSectionHeader(
                "Movies for Rent",
                controller.navigateToRentals,
              ),
              _buildMovieList(controller.rentalMovies, isRental: true),
              const SizedBox(height: 30),

              // 9. Komunitas (Community)
              _buildSectionHeader(
                "Community Buzz",
                controller.navigateToCommunity,
              ),
              _buildCommunityList(),

              const SizedBox(height: 40),

              // 10. Footer
              _buildCompanyFooter(),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // --- WIDGETS ---

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Cinema Noir",
                style: GoogleFonts.playfairDisplay(
                  color: AppTheme.primaryGold,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Obx(
                () => Text(
                  "Welcome, ${controller.userName.value}",
                  style: GoogleFonts.poppins(color: Colors.grey, fontSize: 14),
                ),
              ),
            ],
          ),
          GestureDetector(
            onTap: controller.navigateToProfile,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.primaryGold,
              ),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.secondaryBackground,
                ),
                child: const Icon(
                  Icons.person,
                  color: AppTheme.primaryGold,
                  size: 20,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPromoCarousel() {
    return Obx(
      () => CarouselSlider(
        options: CarouselOptions(
          height: 200.0,
          autoPlay: true,
          enlargeCenterPage: true,
          viewportFraction: 0.92,
          aspectRatio: 16 / 9,
        ),
        items: controller.promoImages.map((url) {
          return Builder(
            builder: (BuildContext context) {
              return Container(
                width: MediaQuery.of(context).size.width,
                margin: const EdgeInsets.symmetric(horizontal: 5.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: AppTheme.secondaryBackground,
                  image: DecorationImage(
                    image: NetworkImage(url),
                    fit: BoxFit.cover,
                    onError: (obj, trace) =>
                        const AssetImage('assets/placeholder.png'),
                  ),
                ),
              );
            },
          );
        }).toList(),
      ),
    );
  }

  Widget _buildQuickMenuSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Text(
            "Quick Access",
            style: GoogleFonts.poppins(
              color: AppTheme.lightText.withOpacity(0.6),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildCompactMenuBtn(
                icon: Icons.movie_creation_outlined,
                label: "Movies",
                onTap: controller.navigateToMovies,
              ),
              _buildCompactMenuBtn(
                icon: Icons.fastfood_outlined,
                label: "Dining",
                onTap: controller.navigateToFood,
              ),
              _buildCompactMenuBtn(
                icon: Icons.forum_outlined,
                label: "Community",
                onTap: controller.navigateToCommunity,
              ),
              _buildCompactMenuBtn(
                icon: Icons.movie_filter_outlined,
                label: "Rentals",
                onTap: controller.navigateToRentals,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCompactMenuBtn({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Column(
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(20),
            splashColor: AppTheme.primaryGold.withOpacity(0.4),
            child: Container(
              width: 65,
              height: 65,
              decoration: BoxDecoration(
                color: AppTheme.secondaryBackground,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppTheme.primaryGold.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Icon(icon, color: AppTheme.primaryGold, size: 28),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: GoogleFonts.poppins(
            color: AppTheme.lightText,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title, VoidCallback onViewAll) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppTheme.lightText,
            ),
          ),
          GestureDetector(
            onTap: onViewAll,
            child: Text(
              "View All",
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: AppTheme.primaryGold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- LIST FILM (Horizontal) ---
  Widget _buildMovieList(List<MovieModel> movies, {bool isRental = false}) {
    return SizedBox(
      height: 240,
      child: Obx(() {
        if (controller.isLoading.value && movies.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(color: AppTheme.primaryGold),
          );
        }
        return ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: movies.length,
          itemBuilder: (context, index) {
            final movie = movies[index];
            return Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 170,
                    width: 115,
                    child: MoviePosterCard(
                      posterUrl: movie.fullPosterPath,
                      onTap: () => controller.goToMovieDetail(movie.id),
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: 115,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          movie.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.poppins(
                            color: AppTheme.lightText,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        if (isRental)
                          Text(
                            "Rent",
                            style: GoogleFonts.poppins(
                              color: AppTheme.primaryGold,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      }),
    );
  }

  // --- LIST MAKANAN (Horizontal) ---
  Widget _buildFoodList(List<FoodModel> foods) {
    return SizedBox(
      height: 160,
      child: Obx(() {
        return ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: foods.length,
          itemBuilder: (context, index) {
            final food = foods[index];
            return GestureDetector(
              onTap: controller.navigateToFood,
              child: Container(
                width: 240,
                margin: const EdgeInsets.only(right: 16),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.secondaryBackground,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white.withOpacity(0.05)),
                ),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        food.image,
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                        errorBuilder: (ctx, err, stack) => Container(
                          width: 80,
                          height: 80,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            food.category,
                            style: GoogleFonts.poppins(
                              color: AppTheme.primaryGold,
                              fontSize: 10,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            food.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.poppins(
                              color: AppTheme.lightText,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            food.description,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.poppins(
                              color: Colors.grey,
                              fontSize: 10,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            food.price,
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      }),
    );
  }

  // --- LIST KOMUNITAS (Horizontal Card) ---
  Widget _buildCommunityList() {
    return SizedBox(
      height: 140,
      child: Obx(() {
        if (controller.communityPosts.isEmpty) {
          return const Center(
            child: Text(
              "No discussions yet",
              style: TextStyle(color: Colors.grey),
            ),
          );
        }
        return ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: controller.communityPosts.length,
          itemBuilder: (context, index) {
            final post = controller.communityPosts[index];
            return GestureDetector(
              onTap: controller.navigateToCommunity,
              child: Container(
                width: 280,
                margin: const EdgeInsets.only(right: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.secondaryBackground,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppTheme.primaryGold.withOpacity(0.3),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 12,
                          backgroundColor: AppTheme.primaryGold,
                          child: const Icon(
                            Icons.person,
                            size: 16,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            post.userName,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.poppins(
                              color: AppTheme.primaryGold,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: Text(
                        post.text,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 12,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.thumb_up_alt_outlined,
                          size: 14,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          "${post.likes} Likes",
                          style: GoogleFonts.poppins(
                            color: Colors.grey,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      }),
    );
  }

  Widget _buildCompanyFooter() {
    return Column(
      children: [
        const Divider(
          color: AppTheme.secondaryBackground,
          thickness: 1,
          indent: 40,
          endIndent: 40,
        ),
        const SizedBox(height: 20),
        Text(
          "CINEMA NOIR",
          style: GoogleFonts.playfairDisplay(
            color: AppTheme.primaryGold.withOpacity(0.5),
            fontSize: 16,
            letterSpacing: 4,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          "Experience the Elegance of Cinema",
          style: GoogleFonts.poppins(color: Colors.grey, fontSize: 10),
        ),
        const SizedBox(height: 4),
        Text(
          "© Kelompok 8",
          style: GoogleFonts.poppins(
            color: Colors.grey.withOpacity(0.5),
            fontSize: 10,
          ),
        ),
      ],
    );
  }
}
