import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/utils/app_routes.dart';

class ProfileController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Data User
  final userEmail = "".obs;
  final userName = "Guest".obs;

  // Data History
  final myTickets = <Map<String, dynamic>>[].obs;
  final myFoodOrders = <Map<String, dynamic>>[].obs; // History Makanan

  final isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    loadUserProfile();
    loadHistory();
  }

  void loadUserProfile() {
    User? user = _auth.currentUser;
    if (user != null) {
      userEmail.value = user.email ?? "";

      // Coba ambil nama dari Firestore
      _firestore.collection('users').doc(user.uid).get().then((doc) {
        if (doc.exists && doc.data() != null) {
          userName.value = doc.data()!['name'] ?? "User";
        } else {
          // Fallback: Ambil nama dari email
          userName.value = user.email!.split('@')[0];
        }
      });
    }
  }

  void loadHistory() async {
    User? user = _auth.currentUser;
    if (user == null) return;

    try {
      isLoading.value = true;

      // 1. Ambil Tiket Film (Terbaru di atas)
      // Note: Pastikan Index Firestore sudah dibuat jika query ini error
      final ticketSnapshot = await _firestore
          .collection('tickets')
          .where('userId', isEqualTo: user.uid)
          .orderBy('bookingDate', descending: true)
          .get();

      myTickets.value = ticketSnapshot.docs.map((doc) {
        var data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();

      // 2. Ambil Pesanan Makanan (Terbaru di atas)
      final orderSnapshot = await _firestore
          .collection('orders')
          .where('userId', isEqualTo: user.uid)
          .orderBy('orderDate', descending: true)
          .get();

      myFoodOrders.value = orderSnapshot.docs.map((doc) {
        var data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      print("Error loading history: $e");
    } finally {
      isLoading.value = false;
    }
  }

  void logout() async {
    await _auth.signOut();
    Get.offAllNamed(AppRoutes.login);
  }
}
