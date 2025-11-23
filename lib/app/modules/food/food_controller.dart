import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../data/models/food_model.dart';
import '../../data/models/cart_item_model.dart'; // Import model cart
import '../../core/utils/app_routes.dart';
import '../../core/theme/app_theme.dart';

class FoodController extends GetxController {
  final selectedCategory = "All".obs;
  final categories = ["All", "Snack", "Drink", "Combo"];

  // Data Dummy Makanan
  final allFoods = <FoodModel>[
    FoodModel(
      name: "Caramel Popcorn",
      price: "Rp 45.000",
      category: "Snack",
      rating: 4.8,
      description: "Popcorn renyah dengan lapisan karamel manis premium.",
      image:
          "https://images.unsplash.com/photo-1578849278619-e73505e9610f?q=80&w=500&auto=format&fit=crop",
    ),
    FoodModel(
      name: "Nachos Supreme",
      price: "Rp 50.000",
      category: "Snack",
      rating: 4.5,
      description:
          "Keripik tortilla jagung asli disajikan dengan saus keju hangat.",
      image:
          "https://images.unsplash.com/photo-1513456852971-30c0b8199d4d?q=80&w=500&auto=format&fit=crop",
    ),
    FoodModel(
      name: "Hotdog Premium",
      price: "Rp 55.000",
      category: "Snack",
      rating: 4.6,
      description: "Sosis sapi jumbo dalam roti lembut dengan saus mustard.",
      image:
          "https://images.unsplash.com/photo-1612392062631-94dd858cba88?q=80&w=500&auto=format&fit=crop",
    ),
    FoodModel(
      name: "Coca Cola Large",
      price: "Rp 25.000",
      category: "Drink",
      rating: 4.9,
      description: "Kesegaran soda klasik dalam ukuran besar.",
      image:
          "https://images.unsplash.com/photo-1622483767028-3f66f32aef97?q=80&w=500&auto=format&fit=crop",
    ),
    FoodModel(
      name: "Iced Lemon Tea",
      price: "Rp 30.000",
      category: "Drink",
      rating: 4.7,
      description: "Teh dingin segar dengan perasan lemon asli.",
      image:
          "https://images.unsplash.com/photo-1513558161293-cdaf765ed2fd?q=80&w=500&auto=format&fit=crop",
    ),
    FoodModel(
      name: "Couple Combo",
      price: "Rp 85.000",
      category: "Combo",
      rating: 5.0,
      description: "Paket hemat untuk berdua: 1 Popcorn Besar + 2 Minuman.",
      image:
          "https://images.unsplash.com/photo-1585647347384-2593bc35786b?q=80&w=500&auto=format&fit=crop",
    ),
  ].obs;

  final displayedFoods = <FoodModel>[].obs;

  // --- CART LOGIC ---
  final cartItems = <CartItemModel>[].obs;
  final isCheckingOut = false.obs;

  @override
  void onInit() {
    super.onInit();
    displayedFoods.assignAll(allFoods);
  }

  void changeCategory(String category) {
    selectedCategory.value = category;
    if (category == "All") {
      displayedFoods.assignAll(allFoods);
    } else {
      displayedFoods.assignAll(
        allFoods.where((f) => f.category == category).toList(),
      );
    }
  }

  // Menambah ke keranjang
  void addToCart(FoodModel food) {
    // Cek apakah item sudah ada di keranjang
    var existingItem = cartItems.firstWhereOrNull(
      (item) => item.food.name == food.name,
    );

    if (existingItem != null) {
      existingItem.quantity++;
      cartItems.refresh(); // Trigger update UI
    } else {
      cartItems.add(CartItemModel(food: food));
    }

    Get.snackbar(
      "Added",
      "${food.name} added to bag",
      duration: const Duration(seconds: 1),
      backgroundColor: Colors.black54,
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
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

  // Menghitung Total Harga Seluruh Keranjang
  double get grandTotal {
    return cartItems.fold(0, (sum, item) => sum + item.totalPrice);
  }

  int get totalItemsCount {
    return cartItems.fold(0, (sum, item) => sum + item.quantity);
  }

  void navigateToCart() {
    Get.toNamed(AppRoutes.cart);
  }

  // Checkout ke Firestore
  void checkout() async {
    if (cartItems.isEmpty) return;

    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      Get.snackbar("Error", "Please login first");
      return;
    }

    isCheckingOut.value = true;

    try {
      // Simpan detail pesanan
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

      // Reset Keranjang
      cartItems.clear();

      // Kembali ke Home atau Food
      Get.back(); // Tutup halaman cart
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
