import 'package:get/get.dart';
import 'rentals_controller.dart';
import '../../data/providers/tmdb_provider.dart';

class RentalsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<RentalsController>(() => RentalsController());
    Get.lazyPut<TmdbProvider>(() => TmdbProvider());
  }
}
