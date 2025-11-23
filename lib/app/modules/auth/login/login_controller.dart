import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/utils/app_routes.dart'; // <-- PASTIKAN INI DI-IMPORT
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/theme/app_theme.dart';

class LoginController extends GetxController {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final isLoading = false.obs;

  // --- TAMBAHKAN FUNGSI INI ---
  void sendPasswordResetEmail(String email) async {
    if (email.isEmpty) {
      Get.snackbar(
        "Error",
        "Harap masukkan email Anda.",
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
      );
      return;
    }

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      
      // Tutup dialog jika terbuka (akan kita buat di step 2)
      if (Get.isDialogOpen ?? false) Get.back(); 

      Get.snackbar(
        "Email Terkirim",
        "Silakan cek inbox/spam email $email untuk mereset password.",
        backgroundColor: AppTheme.primaryGold,
        colorText: AppTheme.darkText,
        duration: const Duration(seconds: 4),
      );
    } on FirebaseAuthException catch (e) {
      String message = "Gagal mengirim email reset.";
      if (e.code == 'user-not-found') {
        message = "Email tidak terdaftar.";
      } else if (e.code == 'invalid-email') {
        message = "Format email tidak valid.";
      }
      
      Get.snackbar(
        "Gagal",
        message,
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar("Error", e.toString());
    }
  }
  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }

  void login() async {
    isLoading.value = true;

    try {
      String email = emailController.text.trim();
      String password = passwordController.text.trim();

      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // --- INI PERUBAHANNYA ---
      // Jika sukses, pindah ke Home
      Get.offAllNamed(AppRoutes.home);
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      if (e.code == 'user-not-found' ||
          e.code == 'wrong-password' ||
          e.code == 'invalid-credential') {
        errorMessage = 'Email atau password salah.';
      } else {
        errorMessage =
            e.message ?? "Silakan cek kembali email & password Anda.";
      }
      Get.snackbar(
        "Login Gagal",
        errorMessage,
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        "Login Gagal",
        "Terjadi kesalahan: ${e.toString()}",
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }
}
