import 'dart:io';
import 'dart:typed_data'; // PENTING: Untuk Uint8List agar aman di semua platform
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
// PENTING: Sembunyikan 'User' dari Supabase agar tidak bentrok dengan Firebase User
import 'package:supabase_flutter/supabase_flutter.dart' hide User;
import 'package:image_picker/image_picker.dart';
import '../../core/utils/app_routes.dart';
import '../../core/theme/app_theme.dart';

class ProfileController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final SupabaseClient _supabase = Supabase.instance.client;

  // Data User
  final userEmail = "".obs;
  final userName = "Guest".obs;
  final userPhotoUrl = "".obs;

  // Data History
  final myTickets = <Map<String, dynamic>>[].obs;
  final myFoodOrders = <Map<String, dynamic>>[].obs;
  final myRentals = <Map<String, dynamic>>[].obs;

  final isLoading = true.obs;
  final isUploading = false.obs;

  // Controller untuk Edit Nama
  final nameEditController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    loadAllData();
  }

  void loadAllData() async {
    isLoading.value = true;
    await loadUserProfile();
    await loadHistory();
    isLoading.value = false;
  }

  Future<void> loadUserProfile() async {
    User? user = _auth.currentUser;
    if (user != null) {
      userEmail.value = user.email ?? "";

      try {
        _firestore.collection('users').doc(user.uid).snapshots().listen((doc) {
          if (doc.exists && doc.data() != null) {
            var data = doc.data()!;
            userName.value = data['name'] ?? user.email!.split('@')[0];
            userPhotoUrl.value = data['photoUrl'] ?? "";
          }
        });
      } catch (e) {
        print("Error load profile: $e");
      }
    }
  }

  // --- LOGIKA UPLOAD FOTO (FIXED WEB BLOB ISSUE) ---
  void pickAndUploadImage() async {
    final ImagePicker picker = ImagePicker();

    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 50,
      maxWidth: 500,
    );

    if (image == null) return;

    isUploading.value = true;
    User? user = _auth.currentUser;

    try {
      // 1. Baca File sebagai Bytes
      final Uint8List imageBytes = await image.readAsBytes();

      // --- PERBAIKAN DI SINI ---
      // Jangan ambil ekstensi dari image.path karena di Web itu bentuknya Blob URL
      // Kita paksa saja jadi .jpg agar bersih
      final String fileName =
          '${user!.uid}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final String path = 'profiles/$fileName';

      // 2. Upload Binary ke Supabase
      await _supabase.storage
          .from('avatars')
          .uploadBinary(
            path,
            imageBytes,
            fileOptions: const FileOptions(
              upsert: true,
              contentType: 'image/jpeg',
            ),
          );

      // 3. Ambil URL Publik
      final String publicUrl = _supabase.storage
          .from('avatars')
          .getPublicUrl(path);

      // 4. Update Firestore
      await _firestore.collection('users').doc(user.uid).update({
        'photoUrl': publicUrl,
      });

      // Update UI Lokal langsung agar terasa cepat
      userPhotoUrl.value = publicUrl;

      Get.snackbar(
        "Success",
        "Foto profil berhasil diupdate!",
        backgroundColor: AppTheme.primaryGold,
        colorText: Colors.black,
      );
    } catch (e) {
      print("Error upload: $e");
      Get.snackbar(
        "Error",
        "Gagal upload foto. Pastikan Bucket 'avatars' Public.",
      );
    } finally {
      isUploading.value = false;
    }
  }

  // --- LOGIKA EDIT NAMA ---
  void showEditNameDialog() {
    nameEditController.text = userName.value;
    Get.defaultDialog(
      title: "Edit Name",
      titleStyle: const TextStyle(
        color: AppTheme.primaryGold,
        fontWeight: FontWeight.bold,
      ),
      backgroundColor: AppTheme.secondaryBackground,
      content: Padding(
        padding: const EdgeInsets.all(16.0),
        child: TextField(
          controller: nameEditController,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            labelText: "Full Name",
            labelStyle: TextStyle(color: Colors.grey),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.grey),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: AppTheme.primaryGold),
            ),
          ),
        ),
      ),
      confirm: ElevatedButton(
        onPressed: () {
          updateName();
          Get.back();
        },
        style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryGold),
        child: const Text("Save", style: TextStyle(color: Colors.black)),
      ),
      cancel: TextButton(
        onPressed: () => Get.back(),
        child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
      ),
    );
  }

  void updateName() async {
    User? user = _auth.currentUser;
    if (user != null && nameEditController.text.isNotEmpty) {
      await _firestore.collection('users').doc(user.uid).update({
        'name': nameEditController.text.trim(),
      });
    }
  }

  // --- LOGIKA HISTORY ---
  Future<void> loadHistory() async {
    User? user = _auth.currentUser;
    if (user == null) return;

    try {
      // 1. Tiket Film
      final ticketSnapshot = await _firestore
          .collection('tickets')
          .where('userId', isEqualTo: user.uid)
          .orderBy('bookingDate', descending: true)
          .get();
      myTickets.value = ticketSnapshot.docs
          .map((doc) => {...doc.data(), 'id': doc.id})
          .toList();

      // 2. Pesanan Makanan
      final orderSnapshot = await _firestore
          .collection('orders')
          .where('userId', isEqualTo: user.uid)
          .orderBy('orderDate', descending: true)
          .get();
      myFoodOrders.value = orderSnapshot.docs
          .map((doc) => {...doc.data(), 'id': doc.id})
          .toList();

      // 3. Sewa Film
      final rentalSnapshot = await _firestore
          .collection('rentals')
          .where('userId', isEqualTo: user.uid)
          .orderBy('rentedAt', descending: true)
          .get();
      myRentals.value = rentalSnapshot.docs
          .map((doc) => {...doc.data(), 'id': doc.id})
          .toList();
    } catch (e) {
      print("Error loading history: $e");
    }
  }

  void logout() async {
    await _auth.signOut();
    Get.offAllNamed(AppRoutes.login);
  }
}
