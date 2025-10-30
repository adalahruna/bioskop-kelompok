import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'app/core/theme/app_theme.dart';
import 'app/core/utils/app_pages.dart';
import 'app/core/utils/app_routes.dart';
//tes techa
// Import Firebase
import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_auth/firebase_auth.dart'; // (Belum kita pakai di sini)
import 'firebase_options.dart'; // File yang digenerasi FlutterFire

void main() async {
  // Pastikan Firebase terinisialisasi
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: "Cinema Noir",
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,

      // Untuk saat ini, kita paksa SELALU mulai dari Login
      initialRoute: AppRoutes.login,

      getPages: AppPages.pages, // Daftar semua halaman
    );
  }
}
