import 'package:get/get.dart';

// ... (import login, register, home)
import '../../modules/auth/login/login_binding.dart';
import '../../modules/auth/login/login_page.dart';
import '../../modules/auth/register/register_binding.dart';
import '../../modules/auth/register/register_page.dart';
import '../../modules/home/home_binding.dart';
import '../../modules/home/home_page.dart';
import '../../modules/detail/movie_detail_binding.dart';
import '../../modules/detail/movie_detail_page.dart';

// --- IMPORT BARU ---
import '../../modules/booking/booking_binding.dart';
import '../../modules/booking/booking_page.dart';

import 'app_routes.dart';

class AppPages {
  static final List<GetPage> pages = [
    // ... (Login, Register, Home, Detail tetap sama)
    GetPage(
      name: AppRoutes.login,
      page: () => const LoginPage(),
      binding: LoginBinding(),
    ),
    GetPage(
      name: AppRoutes.register,
      page: () => const RegisterPage(),
      binding: RegisterBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.home,
      page: () => const HomePage(),
      binding: HomeBinding(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: AppRoutes.movieDetail,
      page: () => const MovieDetailPage(),
      binding: MovieDetailBinding(),
      transition: Transition.rightToLeftWithFade,
    ),

    // --- GETPAGE BARU ---
    GetPage(
      name: AppRoutes.booking,
      page: () => const BookingPage(),
      binding: BookingBinding(),
      transition: Transition.downToUp, // Transisi dari bawah ke atas (keren)
    ),
  ];
}
