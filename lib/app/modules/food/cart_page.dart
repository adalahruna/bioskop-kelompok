import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import 'food_controller.dart';
import '../../data/models/cart_item_model.dart';

class CartPage extends GetView<FoodController> {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "My Order",
          style: GoogleFonts.playfairDisplay(
            color: AppTheme.primaryGold,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: AppTheme.primaryGold),
      ),
      body: Obx(() {
        if (controller.cartItems.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.remove_shopping_cart_outlined,
                  size: 80,
                  color: Colors.grey,
                ),
                const SizedBox(height: 16),
                Text(
                  "Your cart is empty",
                  style: GoogleFonts.poppins(color: Colors.grey, fontSize: 16),
                ),
              ],
            ),
          );
        }

        return Column(
          children: [
            // List Item
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: controller.cartItems.length,
                itemBuilder: (context, index) {
                  final item = controller.cartItems[index];
                  return _buildCartItem(item);
                },
              ),
            ),

            // Bottom Summary
            _buildBottomSummary(),
          ],
        );
      }),
    );
  }

  Widget _buildCartItem(CartItemModel item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.secondaryBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          // Gambar
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              item.food.image,
              width: 70,
              height: 70,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 16),

          // Info & Kontrol
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.food.name,
                  style: GoogleFonts.poppins(
                    color: AppTheme.lightText,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                Text(
                  item.food.price,
                  style: GoogleFonts.poppins(color: Colors.grey, fontSize: 12),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _qtyBtn(Icons.remove, () => controller.decreaseQty(item)),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text(
                        "${item.quantity}",
                        style: GoogleFonts.poppins(
                          color: AppTheme.lightText,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    _qtyBtn(Icons.add, () => controller.increaseQty(item)),
                    const Spacer(),
                    Text(
                      "Rp ${(item.totalPrice / 1000).toStringAsFixed(0)}.000",
                      style: GoogleFonts.poppins(
                        color: AppTheme.primaryGold,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _qtyBtn(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.withOpacity(0.5)),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Icon(icon, size: 16, color: AppTheme.lightText),
      ),
    );
  }

  Widget _buildBottomSummary() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: AppTheme.secondaryBackground,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Total", style: GoogleFonts.poppins(color: Colors.grey)),
              Obx(
                () => Text(
                  "Rp ${(controller.grandTotal / 1000).toStringAsFixed(0)}.000",
                  style: GoogleFonts.poppins(
                    color: AppTheme.lightText,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: controller.isCheckingOut.value
                  ? null
                  : controller.checkout,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryGold,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: controller.isCheckingOut.value
                  ? const CircularProgressIndicator(color: Colors.black)
                  : Text(
                      "Checkout Now",
                      style: GoogleFonts.poppins(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
