import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'login_controller.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/app_routes.dart'; // <-- PASTIKAN INI DI-IMPORT

class LoginPage extends GetView<LoginController> {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 1. Judul Elegan
                Text(
                  "Cinema Noir",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 48,
                    fontWeight: FontWeight.w900,
                    color: AppTheme.primaryGold,
                  ),
                ),
                Text(
                  "An elegant movie experience.",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    color: AppTheme.lightText.withOpacity(0.7),
                  ),
                ),
                const SizedBox(height: 60),

                // 2. Form Email
                TextField(
                  controller: controller.emailController,
                  keyboardType: TextInputType.emailAddress,
                  style: const TextStyle(color: AppTheme.lightText),
                  decoration: const InputDecoration(
                    labelText: "Email",
                    prefixIcon: Icon(
                      Icons.email_outlined,
                      color: AppTheme.primaryGold,
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // 3. Form Password
                TextField(
                  controller: controller.passwordController,
                  obscureText: true,
                  style: const TextStyle(color: AppTheme.lightText),
                  decoration: const InputDecoration(
                    labelText: "Password",
                    prefixIcon: Icon(
                      Icons.lock_outline,
                      color: AppTheme.primaryGold,
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    // --- UBAH BAGIAN INI ---
                    onPressed: () {
                      // 1. Siapkan controller sementara untuk dialog
                      // Kita isi default-nya dengan apa yang sudah diketik user di halaman login
                      final resetEmailController = TextEditingController(
                        text: controller.emailController.text,
                      );

                      // 2. Tampilkan Dialog Input
                      Get.defaultDialog(
                        title: "Reset Password",
                        titleStyle: GoogleFonts.playfairDisplay(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryGold, // Sesuaikan warna judul
                        ),
                        backgroundColor: AppTheme.secondaryBackground, // Background gelap
                        radius: 16,
                        content: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Column(
                            children: [
                              Text(
                                "Masukkan email Anda untuk menerima link reset password.",
                                textAlign: TextAlign.center,
                                style: GoogleFonts.poppins(
                                  fontSize: 12, 
                                  color: Colors.grey
                                ),
                              ),
                              const SizedBox(height: 16),
                              TextField(
                                controller: resetEmailController,
                                keyboardType: TextInputType.emailAddress,
                                style: const TextStyle(color: AppTheme.lightText),
                                decoration: const InputDecoration(
                                  labelText: "Email",
                                  prefixIcon: Icon(
                                    Icons.email_outlined,
                                    color: AppTheme.primaryGold,
                                  ),
                                  // Gunakan style input yang sama dengan tema
                                  filled: true,
                                  fillColor: Colors.black26, 
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Tombol Kirim
                        confirm: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryGold,
                            foregroundColor: AppTheme.darkText,
                          ),
                          onPressed: () {
                            controller.sendPasswordResetEmail(
                              resetEmailController.text.trim(),
                            );
                          },
                          child: const Text("Kirim Link"),
                        ),
                        // Tombol Batal
                        cancel: TextButton(
                          onPressed: () => Get.back(),
                          child: const Text(
                            "Batal", 
                            style: TextStyle(color: Colors.grey)
                          ),
                        ),
                      );
                    },
                    // -----------------------
                    child: Text(
                      "Forgot Password?",
                      style: GoogleFonts.poppins(color: AppTheme.primaryGold),
                    ),
                  ),
                ),
                const SizedBox(height: 30),

                // 4. Tombol Login
                Obx(
                  () => controller.isLoading.value
                      ? const Center(
                          child: CircularProgressIndicator(
                            color: AppTheme.primaryGold,
                          ),
                        )
                      : ElevatedButton(
                          onPressed: controller.login,
                          child: const Text("LOGIN"),
                        ),
                ),
                const SizedBox(height: 40),

                // 5. Pilihan Daftar (di-nonaktifkan sementara)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Don't have an account? ",
                      style: TextStyle(
                        color: AppTheme.lightText.withOpacity(0.7),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        // --- INI PERUBAHANNYA ---
                        // Mengarahkan ke halaman Register
                        Get.toNamed(AppRoutes.register);
                      },
                      child: const Text(
                        "Sign Up",
                        style: TextStyle(
                          color: AppTheme.primaryGold,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
