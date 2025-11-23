import 'package:get/get.dart';

// Import file-file login
import '../../modules/auth/login/login_binding.dart';
import '../../modules/auth/login/login_page.dart';

// Import file-file register
import '../../modules/auth/register/register_binding.dart';
import '../../modules/auth/register/register_page.dart';

// Import file-file home
import '../../modules/home/home_binding.dart';
import '../../modules/home/home_page.dart';

// Import file-file detail
import '../../modules/detail/movie_detail_binding.dart';
import '../../modules/detail/movie_detail_page.dart';

// Import file-file booking
import '../../modules/booking/booking_binding.dart';
import '../../modules/booking/booking_page.dart';

// Import file-file profile
import '../../modules/profile/profile_binding.dart';
import '../../modules/profile/profile_page.dart';

// --- IMPORT BARU (MOVIES & FOOD) ---
import '../../modules/movies/movies_binding.dart';
import '../../modules/movies/movies_page.dart';
import '../../modules/food/food_page.dart';

// Import file routes
import 'app_routes.dart';

class AppPages {
  static final List<GetPage> pages = [
    // Login & Register
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

    // Home (Dashboard)
    GetPage(
      name: AppRoutes.home,
      page: () => const HomePage(),
      binding: HomeBinding(),
      transition: Transition.fadeIn,
    ),

    // Movie Detail
    GetPage(
      name: AppRoutes.movieDetail,
      page: () => const MovieDetailPage(),
      binding: MovieDetailBinding(),
      transition: Transition.rightToLeftWithFade,
    ),

    // Booking
    GetPage(
      name: AppRoutes.booking,
      page: () => const BookingPage(),
      binding: BookingBinding(),
      transition: Transition.downToUp,
    ),

    // Profile
    GetPage(
      name: AppRoutes.profile,
      page: () => const ProfilePage(),
      binding: ProfileBinding(),
      transition: Transition.fadeIn,
    ),

    // --- HALAMAN BARU ---
    GetPage(
      name: AppRoutes.movies,
      page: () => const MoviesPage(),
      binding: MoviesBinding(), // Binding untuk ambil API film
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.food,
      page: () => const FoodPage(),
      // FoodPage sederhana, belum butuh binding khusus
      transition: Transition.rightToLeft,
    ),
  ];
}
