import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:carousel_slider/carousel_slider.dart';
import '../../core/theme/app_theme.dart';
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
              // 1. Header (Sapaan & Profil)
              _buildHeader(),

              const SizedBox(height: 10),

              // 2. Carousel Promo (Fokus Utama)
              _buildPromoCarousel(),

              const SizedBox(height: 30),

              // 3. Menu Bar (Tombol Kecil Minimalis)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Text(
                  "Quick Menu",
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
                      icon: Icons.local_activity_outlined,
                      label: "Events",
                      onTap: () => controller.showFeatureNotReady("Events"),
                    ),
                    _buildCompactMenuBtn(
                      icon: Icons.card_giftcard_outlined,
                      label: "Offers",
                      onTap: () => controller.showFeatureNotReady("Offers"),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // 4. Trending Movies (List Horizontal)
              _buildSectionHeader(
                "Trending Now",
                () => controller.navigateToMovies(),
              ),
              _buildTrendingMoviesList(),

              const SizedBox(height: 30),

              // 5. Popular Food (List Horizontal)
              _buildSectionHeader(
                "Best Sellers",
                () => controller.navigateToFood(),
              ),
              _buildPopularFoodList(),

              const SizedBox(height: 40),

              // 6. Footer Informasi Perusahaan
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
                  "Hello, ${controller.userName.value}",
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
          autoPlayInterval: const Duration(seconds: 6),
          enlargeCenterPage: true,
          viewportFraction: 0.9,
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
                  image: DecorationImage(
                    image: NetworkImage(url),
                    fit: BoxFit.cover,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.5),
                      blurRadius: 15,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.8),
                      ],
                      stops: const [0.6, 1.0],
                    ),
                  ),
                ),
              );
            },
          );
        }).toList(),
      ),
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
            highlightColor: AppTheme.primaryGold.withOpacity(0.1),
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
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
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

  Widget _buildTrendingMoviesList() {
    return SizedBox(
      height: 240, // Tinggi container list
      child: Obx(() {
        if (controller.isLoading.value && controller.trendingMovies.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(color: AppTheme.primaryGold),
          );
        }
        return ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: controller.trendingMovies.length,
          itemBuilder: (context, index) {
            final movie = controller.trendingMovies[index];
            return Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Poster dengan ukuran pasti agar tidak error
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
                    child: Text(
                      movie.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        color: AppTheme.lightText,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
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

  Widget _buildPopularFoodList() {
    return SizedBox(
      height: 160, // Tinggi area list makanan
      child: Obx(() {
        return ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: controller.popularFoods.length,
          itemBuilder: (context, index) {
            final food = controller.popularFoods[index];
            return _buildFoodCard(food);
          },
        );
      }),
    );
  }

  Widget _buildFoodCard(FoodModel food) {
    return GestureDetector(
      onTap: controller.navigateToFood, // Masuk ke menu makanan
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
            // Gambar Makanan
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                food.image,
                width: 80,
                height: 80,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    Container(width: 80, height: 80, color: Colors.grey),
              ),
            ),
            const SizedBox(width: 12),
            // Info Makanan
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryGold.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      food.category,
                      style: GoogleFonts.poppins(
                        color: AppTheme.primaryGold,
                        fontSize: 10,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    food.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      color: AppTheme.lightText,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    food.price,
                    style: GoogleFonts.poppins(
                      color: Colors.grey,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
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
          "© 2025 Noir Entertainment Group",
          style: GoogleFonts.poppins(
            color: Colors.grey.withOpacity(0.5),
            fontSize: 10,
          ),
        ),
      ],
    );
  }
}
