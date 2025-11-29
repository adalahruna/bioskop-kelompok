import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../data/models/food_model.dart';
import '../../data/models/cart_item_model.dart';
import '../../core/utils/app_routes.dart';
import '../../core/theme/app_theme.dart';

class FoodController extends GetxController {
  final selectedCategory = "All".obs;
  final categories = ["All", "Snack", "Drink", "Combo"];

  // --- KONFIGURASI SUPABASE ---
  final String baseUrl =
      'https://lyypmixrenhvidobfqaw.supabase.co/storage/v1/object/public/products/';

  // SEARCH CONTROLLER (BARU)
  final TextEditingController searchController = TextEditingController();

  // List Menu Makanan Lengkap
  late final List<FoodModel> allFoods;

  final displayedFoods = <FoodModel>[].obs;
  final cartItems = <CartItemModel>[].obs;
  final isCheckingOut = false.obs;

  @override
  void onInit() {
    super.onInit();
    _initializeMenu();
    displayedFoods.assignAll(allFoods);
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }

  // --- LOGIKA SEARCH (BARU) ---
  void searchFood(String query) {
    if (query.isEmpty) {
      // Jika kosong, kembalikan sesuai kategori yang dipilih
      changeCategory(selectedCategory.value);
    } else {
      final lowerQuery = query.toLowerCase();
      // Cari di semua makanan (Global search)
      final result = allFoods
          .where((f) => f.name.toLowerCase().contains(lowerQuery))
          .toList();
      displayedFoods.assignAll(result);
    }
  }

  void _initializeMenu() {
    allFoods = [
      // --- MAKANAN (SNACKS) ---
      FoodModel(
        name: "Popcorn Caramel",
        price: "Rp 50.000",
        category: "Snack",
        rating: 4.9,
        description: "Popcorn klasik bioskop dengan lapisan karamel tebal.",
        image: "${baseUrl}popcorn.jpg",
      ),
      FoodModel(
        name: "Chicken Popcorn Bucket",
        price: "Rp 65.000",
        category: "Snack",
        rating: 4.8,
        description: "Ayam goreng tepung bite-sized dalam bucket jumbo.",
        image: "${baseUrl}chicken_bucket.jpg",
      ),
      FoodModel(
        name: "French Fries",
        price: "Rp 40.000",
        category: "Snack",
        rating: 4.5,
        description: "Kentang goreng renyah dengan taburan garam laut.",
        image: "${baseUrl}french_fries.jpg",
      ),
      FoodModel(
        name: "Hot Dog Premium",
        price: "Rp 55.000",
        category: "Snack",
        rating: 4.6,
        description: "Sosis sapi panggang dengan roti lembut dan saus mustard.",
        image: "${baseUrl}hotdog.jpg",
      ),
      FoodModel(
        name: "Cheese Balls",
        price: "Rp 45.000",
        category: "Snack",
        rating: 4.7,
        description: "Bola-bola keju lumer yang digoreng keemasan.",
        image: "${baseUrl}cheese_balls.jpg",
      ),
      FoodModel(
        name: "Beef Burger",
        price: "Rp 60.000",
        category: "Snack",
        rating: 4.8,
        description: "Burger daging sapi asli dengan keju dan sayuran segar.",
        image: "${baseUrl}burger.jpg",
      ),
      FoodModel(
        name: "Takoyaki",
        price: "Rp 45.000",
        category: "Snack",
        rating: 4.6,
        description: "8 pcs bola gurita khas Jepang dengan saus spesial.",
        image: "${baseUrl}takoyaki.jpg",
      ),
      FoodModel(
        name: "Churros",
        price: "Rp 35.000",
        category: "Snack",
        rating: 4.5,
        description: "Donat spanyol renyah dengan taburan gula kayu manis.",
        image: "${baseUrl}churros.jpg",
      ),
      FoodModel(
        name: "Beef Kebab",
        price: "Rp 45.000",
        category: "Snack",
        rating: 4.7,
        description: "Tortilla wrap isi daging sapi panggang dan sayuran.",
        image: "${baseUrl}kebab.jpg",
      ),
      FoodModel(
        name: "Soft Cookies",
        price: "Rp 25.000",
        category: "Snack",
        rating: 4.9,
        description: "Cookies coklat lumer yang hangat dan lembut.",
        image: "${baseUrl}cookies.jpg",
      ),

      // --- MINUMAN (DRINKS) ---
      FoodModel(
        name: "Mineral Water",
        price: "Rp 15.000",
        category: "Drink",
        rating: 5.0,
        description: "Air mineral pegunungan yang menyegarkan (600ml).",
        image: "${baseUrl}mineral_water.jpg",
      ),
      FoodModel(
        name: "Coca Cola",
        price: "Rp 30.000",
        category: "Drink",
        rating: 4.8,
        description: "Minuman bersoda rasa kola yang legendaris.",
        image: "${baseUrl}coke.jpg",
      ),
      FoodModel(
        name: "Dr. Pepper",
        price: "Rp 35.000",
        category: "Drink",
        rating: 4.6,
        description: "Minuman soda unik dengan campuran 23 rasa.",
        image: "${baseUrl}dr_pepper.jpg",
      ),
      FoodModel(
        name: "Pepsi",
        price: "Rp 30.000",
        category: "Drink",
        rating: 4.7,
        description: "Minuman soda kola yang manis dan segar.",
        image: "${baseUrl}pepsi.jpg",
      ),
      FoodModel(
        name: "Americano",
        price: "Rp 35.000",
        category: "Drink",
        rating: 4.5,
        description: "Kopi hitam panas dari biji kopi pilihan.",
        image: "${baseUrl}black_coffee.jpg",
      ),
      FoodModel(
        name: "Strawberry Milkshake",
        price: "Rp 45.000",
        category: "Drink",
        rating: 4.9,
        description: "Susu kocok rasa strawberry yang creamy dan kental.",
        image: "${baseUrl}milkshake.jpg",
      ),
      FoodModel(
        name: "Fanta Orange",
        price: "Rp 30.000",
        category: "Drink",
        rating: 4.6,
        description: "Minuman soda rasa jeruk yang ceria.",
        image: "${baseUrl}fanta.jpg",
      ),
      FoodModel(
        name: "Iced Latte",
        price: "Rp 40.000",
        category: "Drink",
        rating: 4.8,
        description: "Kopi susu gula aren dingin kekinian.",
        image: "${baseUrl}iced_latte.jpg",
      ),
      FoodModel(
        name: "Tea",
        price: "Rp 25.000",
        category: "Drink",
        rating: 4.7,
        description: "Teh manis dingin klasik bioskop.",
        image: "${baseUrl}tea.jpg",
      ),
      FoodModel(
        name: "Sprite",
        price: "Rp 30.000",
        category: "Drink",
        rating: 4.7,
        description: "Minuman soda rasa lemon-lime yang jernih.",
        image: "${baseUrl}sprite.jpg",
      ),

      // --- COMBO ---
      FoodModel(
        name: "Solo Combo",
        price: "Rp 75.000",
        category: "Combo",
        rating: 4.9,
        description: "1 Popcorn + 1 Coca Cola. Pas untuk sendirian.",
        image: "${baseUrl}combo_solo.jpg",
      ),
      FoodModel(
        name: "Chicken Feast Combo",
        price: "Rp 110.000",
        category: "Combo",
        rating: 5.0,
        description: "Chicken Bucket + Fries + Coca Cola.",
        image: "${baseUrl}combo_chicken.jpg",
      ),
      FoodModel(
        name: "Seafood Snack Combo",
        price: "Rp 95.000",
        category: "Combo",
        rating: 4.7,
        description: "Fish Roll + Fries + Sprite segar.",
        image: "${baseUrl}combo_fish.jpg",
      ),
      FoodModel(
        name: "Burger Meal Combo",
        price: "Rp 100.000",
        category: "Combo",
        rating: 4.8,
        description: "Beef Burger + Fries + Coca Cola.",
        image: "${baseUrl}combo_burger.jpg",
      ),
    ];
  }

  // --- LOGIKA FILTER & CART ---
  void changeCategory(String category) {
    selectedCategory.value = category;
    // Reset search saat ganti kategori agar tidak bingung
    searchController.clear();

    if (category == "All") {
      displayedFoods.assignAll(allFoods);
    } else {
      displayedFoods.assignAll(
        allFoods.where((f) => f.category == category).toList(),
      );
    }
  }

  void addToCart(FoodModel food) {
    var existingItem = cartItems.firstWhereOrNull(
      (item) => item.food.name == food.name,
    );
    if (existingItem != null) {
      existingItem.quantity++;
      cartItems.refresh();
    } else {
      cartItems.add(CartItemModel(food: food));
    }
    Get.snackbar(
      "Added",
      "${food.name} added to bag",
      duration: const Duration(milliseconds: 1500),
      backgroundColor: AppTheme.primaryGold, // Warna Emas biar kelihatan
      colorText: AppTheme.darkText,
      snackPosition: SnackPosition.TOP,
      margin: const EdgeInsets.all(20),
    );
  }

  void removeFromCart(CartItemModel item) {
    cartItems.remove(item);
  }

  void increaseQty(CartItemModel item) {
    item.quantity++;
    cartItems.refresh();
  }

  void decreaseQty(CartItemModel item) {
    if (item.quantity > 1) {
      item.quantity--;
      cartItems.refresh();
    } else {
      removeFromCart(item);
    }
  }

  double get grandTotal {
    return cartItems.fold(0, (sum, item) => sum + item.totalPrice);
  }

  int get totalItemsCount {
    return cartItems.fold(0, (sum, item) => sum + item.quantity);
  }

  void navigateToCart() {
    Get.toNamed(AppRoutes.cart);
  }

  void checkout() async {
    if (cartItems.isEmpty) return;
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      Get.snackbar("Error", "Please login first");
      return;
    }

    isCheckingOut.value = true;
    try {
      final orderData = {
        'userId': user.uid,
        'items': cartItems
            .map(
              (i) => {
                'name': i.food.name,
                'price': i.food.price,
                'qty': i.quantity,
                'subtotal': i.totalPrice,
              },
            )
            .toList(),
        'total': grandTotal,
        'status': 'paid',
        'orderDate': FieldValue.serverTimestamp(),
        'type': 'food_order',
      };
      await FirebaseFirestore.instance.collection('orders').add(orderData);
      cartItems.clear();
      Get.back();
      Get.snackbar(
        "Success",
        "Order placed successfully!",
        backgroundColor: AppTheme.primaryGold,
        colorText: AppTheme.darkText,
      );
    } catch (e) {
      Get.snackbar("Error", "Checkout failed: $e");
    } finally {
      isCheckingOut.value = false;
    }
  }
}
