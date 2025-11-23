import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/utils/app_routes.dart';

class ProfileController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Data User
  final userEmail = "".obs;
  final userName = "User".obs; // Nanti bisa ambil dari Firestore 'users'

  // Data Tiket
  final myTickets = <Map<String, dynamic>>[].obs;
  final isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    loadUserProfile();
    loadMyTickets();
  }

  void loadUserProfile() {
    User? user = _auth.currentUser;
    if (user != null) {
      userEmail.value = user.email ?? "";
      // Optional: Ambil nama dari koleksi 'users' berdasarkan UID
      _firestore.collection('users').doc(user.uid).get().then((doc) {
        if (doc.exists) {
          userName.value = doc.data()?['name'] ?? "User";
        }
      });
    }
  }

  void loadMyTickets() async {
    User? user = _auth.currentUser;
    if (user == null) return;

    try {
      isLoading.value = true;
      // Query ke Firestore: Ambil tiket yang userId-nya sama dengan user login
      // Order by bookingDate descending (terbaru di atas)
      final querySnapshot = await _firestore
          .collection('tickets')
          .where('userId', isEqualTo: user.uid)
          .orderBy('bookingDate', descending: true)
          .get();

      final List<Map<String, dynamic>> tickets = [];

      for (var doc in querySnapshot.docs) {
        // Masukkan data tiket + ID dokumennya
        Map<String, dynamic> data = doc.data();
        data['ticketId'] = doc.id;
        tickets.add(data);
      }

      myTickets.value = tickets;
    } catch (e) {
      print("Error loading tickets: $e");
      // Note: Jika error permission/index, pastikan rule Firestore benar
      // atau field 'bookingDate' sudah di-index jika query kompleks
    } finally {
      isLoading.value = false;
    }
  }

  void logout() async {
    await _auth.signOut();
    Get.offAllNamed(AppRoutes.login);
  }
}
