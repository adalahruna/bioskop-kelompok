import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/utils/app_routes.dart';
import '../../core/theme/app_theme.dart'; // Untuk warna snackbar

class BookingController extends GetxController {
  // Data Film yang diterima dari halaman Detail
  late final int movieId;
  late final String movieTitle;
  late final String posterUrl;

  // Konfigurasi Kursi
  // 0 = Tersedia, 1 = Dipilih, 2 = Sudah Dipesan (Sold)
  // Kita buat 6 baris x 8 kolom
  var seats = List.generate(6, (i) => List.generate(8, (j) => 0.obs)).obs;

  // List kursi yang dipilih user [[baris, kolom], [baris, kolom]]
  var selectedSeats = <List<int>>[].obs;

  final double pricePerTicket = 50000.0;
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    // Ambil argumen
    final args = Get.arguments as Map<String, dynamic>;
    movieId = args['id'];
    movieTitle = args['title'];
    posterUrl = args['poster'];

    // Simulasi kursi yang sudah terjual (Random)
    // Nanti ini bisa diambil dari Firestore jika mau advanced
    _randomizeSoldSeats();
  }

  void _randomizeSoldSeats() {
    // Buat beberapa kursi random jadi status 2 (Sold)
    seats[0][2].value = 2;
    seats[0][3].value = 2;
    seats[2][5].value = 2;
    seats[2][6].value = 2;
    seats[4][0].value = 2;
    seats[4][1].value = 2;
  }

  void toggleSeat(int row, int col) {
    if (seats[row][col].value == 2) return; // Jangan apa-apakan kursi Sold

    if (seats[row][col].value == 0) {
      // Pilih Kursi
      seats[row][col].value = 1;
      selectedSeats.add([row, col]);
    } else {
      // Batalkan Pilih
      seats[row][col].value = 0;
      selectedSeats.removeWhere((s) => s[0] == row && s[1] == col);
    }
    // Trigger update UI
    seats.refresh();
  }

  double get totalPrice => selectedSeats.length * pricePerTicket;

  String get seatNumbers {
    // Ubah koordinat [0,0] jadi "A1", [1,2] jadi "B3"
    return selectedSeats
        .map((s) {
          String rowLetter = String.fromCharCode(
            65 + s[0],
          ); // 65 adalah ASCII 'A'
          String colNumber = (s[1] + 1).toString();
          return "$rowLetter$colNumber";
        })
        .join(", ");
  }

  // --- FUNGSI MENYIMPAN KE FIREBASE ---
  void confirmBooking() async {
    if (selectedSeats.isEmpty) {
      Get.snackbar("Error", "Pilih minimal 1 kursi!");
      return;
    }

    isLoading.value = true;
    User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      Get.snackbar("Error", "Anda harus login ulang.");
      Get.offAllNamed(AppRoutes.login);
      return;
    }

    try {
      // Buat Data Transaksi
      await FirebaseFirestore.instance.collection('tickets').add({
        'userId': user.uid,
        'movieId': movieId,
        'movieTitle': movieTitle,
        'posterUrl': posterUrl,
        'seats': seatNumbers, // String "A1, A2"
        'totalPrice': totalPrice,
        'bookingDate': FieldValue.serverTimestamp(), // Waktu server
        'status': 'active', // active, used, cancelled
      });

      // Sukses!
      Get.snackbar(
        "Berhasil!",
        "Tiket berhasil dipesan. Cek riwayat anda.",
        backgroundColor: AppTheme.primaryGold,
        colorText: AppTheme.darkText,
      );

      // Kembali ke Home
      Get.offAllNamed(AppRoutes.home);
    } catch (e) {
      Get.snackbar("Gagal", "Terjadi kesalahan server: $e");
    } finally {
      isLoading.value = false;
    }
  }
}
