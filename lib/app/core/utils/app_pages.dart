import 'package:get/get.dart';

// Import Auth
import '../../modules/auth/login/login_binding.dart';
import '../../modules/auth/login/login_page.dart';
import '../../modules/auth/register/register_binding.dart';
import '../../modules/auth/register/register_page.dart';

// Import Home
import '../../modules/home/home_binding.dart';
import '../../modules/home/home_page.dart';

// Import Detail & Booking
import '../../modules/detail/movie_detail_binding.dart';
import '../../modules/detail/movie_detail_page.dart';
import '../../modules/booking/booking_binding.dart';
import '../../modules/booking/booking_page.dart';

// Import Profile
import '../../modules/profile/profile_binding.dart';
import '../../modules/profile/profile_page.dart';

// Import Movies
import '../../modules/movies/movies_binding.dart';
import '../../modules/movies/movies_page.dart';

// Import Food & Cart
import '../../modules/food/food_page.dart';
import '../../modules/food/cart_page.dart';

// Import Routes
import 'app_routes.dart';

class AppPages {
  static final List<GetPage> pages = [
    // --- AUTH ---
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

    // --- CORE ---
    GetPage(
      name: AppRoutes.home,
      page: () => const HomePage(),
      binding: HomeBinding(),
      transition: Transition.fadeIn,
    ),

    // --- FEATURES: MOVIE ---
    GetPage(
      name: AppRoutes.movies,
      page: () => const MoviesPage(),
      binding: MoviesBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.movieDetail,
      page: () => const MovieDetailPage(),
      binding: MovieDetailBinding(),
      transition: Transition.rightToLeftWithFade,
    ),
    GetPage(
      name: AppRoutes.booking,
      page: () => const BookingPage(),
      binding: BookingBinding(),
      transition: Transition.downToUp,
    ),

    // --- FEATURES: FOOD ---
    GetPage(
      name: AppRoutes.food,
      page: () => const FoodPage(),
      // FoodPage menginisialisasi controller-nya sendiri via Get.put
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.cart,
      page: () => const CartPage(),
      // CartPage menggunakan controller yang sama dengan FoodPage
      transition: Transition.downToUp,
    ),

    // --- USER ---
    GetPage(
      name: AppRoutes.profile,
      page: () => const ProfilePage(),
      binding: ProfileBinding(),
      transition: Transition.fadeIn,
    ),
  ];
}
