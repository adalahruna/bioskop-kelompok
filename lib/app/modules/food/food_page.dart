import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import 'food_controller.dart';
import '../../data/models/food_model.dart';

class FoodPage extends StatelessWidget {
  const FoodPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Pastikan controller ada
    final controller = Get.put(FoodController());

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Snacks & Drinks",
          style: GoogleFonts.playfairDisplay(
            color: AppTheme.primaryGold,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: AppTheme.primaryGold),
        actions: [
          // Opsional: Ikon cart di atas (bisa dihapus jika sudah ada Live Bar di bawah)
          // Tapi kita biarkan sebagai alternatif akses
          Obx(
            () => Stack(
              children: [
                IconButton(
                  icon: const Icon(
                    Icons.shopping_bag_outlined,
                    color: AppTheme.primaryGold,
                  ),
                  onPressed: controller.navigateToCart,
                ),
                if (controller.totalItemsCount > 0)
                  Positioned(
                    right: 8,
                    top: 8,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        "${controller.totalItemsCount}",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // 1. Search Bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
            child: TextField(
              controller: controller.searchController,
              onChanged: (val) => controller.searchFood(val),
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: "Search menu...",
                hintStyle: TextStyle(color: Colors.grey.withOpacity(0.5)),
                prefixIcon: const Icon(
                  Icons.search,
                  color: AppTheme.primaryGold,
                ),
                filled: true,
                fillColor: AppTheme.secondaryBackground,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 20),
              ),
            ),
          ),

          // 2. Filter Kategori
          Container(
            height: 50,
            margin: const EdgeInsets.symmetric(vertical: 16),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: controller.categories.length,
              itemBuilder: (context, index) {
                final category = controller.categories[index];
                return Obx(() {
                  final isSelected =
                      controller.selectedCategory.value == category;
                  return GestureDetector(
                    onTap: () => controller.changeCategory(category),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.only(right: 12),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppTheme.primaryGold
                            : AppTheme.secondaryBackground,
                        borderRadius: BorderRadius.circular(25),
                        border: Border.all(
                          color: isSelected
                              ? AppTheme.primaryGold
                              : Colors.grey.withOpacity(0.3),
                        ),
                      ),
                      child: Center(
                        child: Text(
                          category,
                          style: GoogleFonts.poppins(
                            color: isSelected
                                ? AppTheme.darkText
                                : AppTheme.lightText,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  );
                });
              },
            ),
          ),

          // 3. List Makanan
          Expanded(
            child: Obx(
              () => ListView.builder(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                itemCount: controller.displayedFoods.length,
                itemBuilder: (context, index) {
                  final food = controller.displayedFoods[index];
                  return _buildFoodListCard(context, food, controller);
                },
              ),
            ),
          ),

          // 4. Live Cart Bar
          Obx(() {
            if (controller.totalItemsCount == 0) return const SizedBox.shrink();

            return GestureDetector(
              onTap: controller.navigateToCart,
              child: Container(
                width: double.infinity,
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.primaryGold,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.5),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Info Total Item & Harga
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "${controller.totalItemsCount} items",
                          style: GoogleFonts.poppins(
                            color: AppTheme.darkText,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          "Rp ${(controller.grandTotal).toStringAsFixed(0)}",
                          style: GoogleFonts.poppins(
                            color: AppTheme.darkText,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),

                    // Tombol View Cart
                    Row(
                      children: [
                        Text(
                          "View Cart",
                          style: GoogleFonts.poppins(
                            color: AppTheme.darkText,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(
                          Icons.shopping_bag_outlined,
                          color: AppTheme.darkText,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  // --- POPUP DETAIL DIALOG ---
  void _showDetailDialog(
    BuildContext context,
    FoodModel food,
    FoodController controller,
  ) {
    Get.dialog(
      Dialog(
        backgroundColor: AppTheme.secondaryBackground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Gambar Besar
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
              child: Image.network(
                food.image,
                height: 250,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (ctx, err, stack) =>
                    Container(height: 250, color: Colors.grey),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Nama & Harga
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          food.name,
                          style: GoogleFonts.playfairDisplay(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryGold,
                          ),
                        ),
                      ),
                      Text(
                        food.price,
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Deskripsi
                  Text(
                    food.description,
                    style: GoogleFonts.poppins(
                      color: Colors.grey,
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Tombol Add to Cart Besar
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        controller.addToCart(food);
                        Get.back(); // Tutup dialog
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryGold,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        "Add to Cart",
                        style: GoogleFonts.poppins(
                          color: AppTheme.darkText,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
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

  Widget _buildFoodListCard(
    BuildContext context,
    FoodModel food,
    FoodController controller,
  ) {
    return GestureDetector(
      // Klik kartu membuka popup detail
      onTap: () => _showDetailDialog(context, food, controller),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: AppTheme.secondaryBackground,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Gambar Makanan
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                bottomLeft: Radius.circular(16),
              ),
              child: Image.network(
                food.image,
                width: 110,
                height: 120,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    Container(width: 110, height: 120, color: Colors.grey),
              ),
            ),

            // Info Makanan
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Kategori Kecil
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
                            food.category.toUpperCase(),
                            style: GoogleFonts.poppins(
                              fontSize: 8,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primaryGold,
                            ),
                          ),
                        ),
                        // Rating Bintang
                        Row(
                          children: [
                            const Icon(
                              Icons.star,
                              color: Colors.amber,
                              size: 14,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              food.rating.toString(),
                              style: GoogleFonts.poppins(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),

                    // Nama Makanan
                    Text(
                      food.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.lightText,
                      ),
                    ),

                    // Deskripsi Singkat
                    Text(
                      food.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        fontSize: 10,
                        color: Colors.grey,
                      ),
                    ),

                    const SizedBox(height: 8),

                    // Harga & Tombol Add (Quick Add)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          food.price,
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.primaryGold,
                          ),
                        ),

                        // Tombol Add (+)
                        InkWell(
                          onTap: () => controller.addToCart(food),
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryGold,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.add,
                              size: 18,
                              color: AppTheme.darkText,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
