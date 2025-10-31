import 'package:get/get.dart';

// ... (import login, register, home)
import '../../modules/auth/login/login_binding.dart';
import '../../modules/auth/login/login_page.dart';
import '../../modules/auth/register/register_binding.dart';
import '../../modules/auth/register/register_page.dart';
import '../../modules/home/home_binding.dart';
import '../../modules/home/home_page.dart';

// --- IMPORT BARU ---
import '../../modules/detail/movie_detail_binding.dart';
import '../../modules/detail/movie_detail_page.dart';

// Import file routes
import 'app_routes.dart';

class AppPages {
  static final List<GetPage> pages = [
    // ... (GetPage login, register, home)
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

    // --- GETPAGE BARU ---
    GetPage(
      name: AppRoutes.movieDetail,
      page: () => const MovieDetailPage(),
      binding: MovieDetailBinding(),
      transition: Transition.rightToLeftWithFade,
    ),
  ];
}
