import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'app/core/theme/app_theme.dart';
import 'app/core/utils/app_pages.dart';
import 'app/core/utils/app_routes.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';

// --- IMPORT SUPABASE ---
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Init Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // 2. Init Supabase (GANTI URL & KEY DENGAN PUNYAMU)
  await Supabase.initialize(
    url: 'https://lyypmixrenhvidobfqaw.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imx5eXBtaXhyZW5odmlkb2JmcWF3Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjQzNDI1ODAsImV4cCI6MjA3OTkxODU4MH0.UCeTtoVcENwf_Iz08NKumfhz2FSZc47rmbLP0zErPJg',
  );

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
      initialRoute: FirebaseAuth.instance.currentUser == null
          ? AppRoutes.login
          : AppRoutes.home,
      getPages: AppPages.pages,
    );
  }
}
