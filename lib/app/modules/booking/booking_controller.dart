import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/app_routes.dart';

class BookingController extends GetxController {
  late final int movieId;
  late final String movieTitle;
  late final String posterUrl;

  // Konfigurasi Kursi (0=Avail, 1=Selected, 2=Sold)
  var seats = List.generate(6, (i) => List.generate(8, (j) => 0.obs)).obs;
  var selectedSeats = <List<int>>[].obs;

  // Jadwal
  final selectedDate = Rx<DateTime>(DateTime.now());
  final selectedTime = "".obs;

  final List<String> timeSlots = [
    "10:30",
    "12:00",
    "14:30",
    "16:00",
    "18:30",
    "20:00",
    "22:30",
  ];

  final double pricePerTicket = 50000.0;

  // State Loading
  final isLoading = false.obs; // Untuk proses checkout
  final isLoadingSeats = false.obs; // Untuk proses load kursi

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments as Map<String, dynamic>;
    movieId = args['id'];
    movieTitle = args['title'];
    posterUrl = args['poster'];

    // Awal load, reset semua kursi jadi available
    _resetAllSeats();
  }

  List<DateTime> get next7Days {
    return List.generate(
      7,
      (index) => DateTime.now().add(Duration(days: index)),
    );
  }

  bool isTimeSlotExpired(String time) {
    final now = DateTime.now();
    if (selectedDate.value.day != now.day ||
        selectedDate.value.month != now.month ||
        selectedDate.value.year != now.year) {
      return false;
    }

    try {
      final parts = time.split(':');
      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);
      final slotTime = DateTime(now.year, now.month, now.day, hour, minute);
      return slotTime.isBefore(now);
    } catch (e) {
      return true;
    }
  }

  void selectDate(DateTime date) {
    selectedDate.value = date;
    selectedTime.value = ""; // Reset jam
    selectedSeats.clear(); // Reset pilihan user
    _resetAllSeats(); // Bersihkan tampilan kursi sold
  }

  void selectTime(String time) {
    if (isTimeSlotExpired(time)) {
      Get.snackbar(
        "Jadwal Lewat",
        "Film sudah mulai atau selesai.",
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
      );
      return;
    }

    selectedTime.value = time;
    selectedSeats.clear(); // Reset pilihan user saat ganti jam

    // --- LOAD KURSI YANG SUDAH DIBOOKING ---
    loadBookedSeats();
  }

  // --- LOGIKA UTAMA: CEK KETERSEDIAAN KURSI ---
  void loadBookedSeats() async {
    if (selectedTime.value.isEmpty) return;

    isLoadingSeats.value = true;
    _resetAllSeats(); // Reset dulu sebelum load baru

    try {
      // 1. Konstruksi Waktu Tayang yang dipilih
      final timeParts = selectedTime.value.split(':');
      final targetShowTime = DateTime(
        selectedDate.value.year,
        selectedDate.value.month,
        selectedDate.value.day,
        int.parse(timeParts[0]),
        int.parse(timeParts[1]),
      );

      // 2. Query ke Firestore: Cari tiket dengan MovieID & ShowTime yang sama
      final snapshot = await FirebaseFirestore.instance
          .collection('tickets')
          .where('movieId', isEqualTo: movieId)
          .where('showTime', isEqualTo: Timestamp.fromDate(targetShowTime))
          .get();

      // 3. Loop hasil query dan tandai kursi sebagai SOLD (2)
      for (var doc in snapshot.docs) {
        String bookedSeatsStr = doc['seats']; // Contoh: "A1, A2"
        List<String> bookedList = bookedSeatsStr.split(', ');

        for (String seatCode in bookedList) {
          // Parse "A1" menjadi Row 0, Col 0
          _markSeatAsSold(seatCode);
        }
      }
    } catch (e) {
      print("Error loading seats: $e");
    } finally {
      isLoadingSeats.value = false;
    }
  }

  void _markSeatAsSold(String seatCode) {
    if (seatCode.isEmpty) return;
    try {
      // seatCode[0] adalah Huruf (A-F)
      // seatCode.substring(1) adalah Angka (1-8)

      int row = seatCode.codeUnitAt(0) - 65; // 'A' ascii 65 -> jadi index 0
      int col = int.parse(seatCode.substring(1)) - 1; // '1' -> jadi index 0

      // Validasi agar tidak error array out of bound
      if (row >= 0 && row < seats.length && col >= 0 && col < seats[0].length) {
        seats[row][col].value = 2; // Tandai SOLD
      }
    } catch (e) {
      print("Error parsing seat: $seatCode");
    }
  }

  void _resetAllSeats() {
    for (var row in seats) {
      for (var seat in row) seat.value = 0; // Set semua Available
    }
  }

  void toggleSeat(int row, int col) {
    if (seats[row][col].value == 2) return; // Jangan sentuh yang sold

    if (seats[row][col].value == 0) {
      seats[row][col].value = 1;
      selectedSeats.add([row, col]);
    } else {
      seats[row][col].value = 0;
      selectedSeats.removeWhere((s) => s[0] == row && s[1] == col);
    }
    seats.refresh();
  }

  double get totalPrice => selectedSeats.length * pricePerTicket;

  String get seatNumbers {
    return selectedSeats
        .map((s) {
          String rowLetter = String.fromCharCode(65 + s[0]);
          String colNumber = (s[1] + 1).toString();
          return "$rowLetter$colNumber";
        })
        .join(", ");
  }

  void confirmBooking() async {
    if (selectedTime.value.isEmpty) {
      Get.snackbar("Pilih Jadwal", "Silakan pilih jam tayang terlebih dahulu.");
      return;
    }
    if (selectedSeats.isEmpty) {
      Get.snackbar("Pilih Kursi", "Silakan pilih minimal 1 kursi.");
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
      final timeParts = selectedTime.value.split(':');
      final showTime = DateTime(
        selectedDate.value.year,
        selectedDate.value.month,
        selectedDate.value.day,
        int.parse(timeParts[0]),
        int.parse(timeParts[1]),
      );

      await FirebaseFirestore.instance.collection('tickets').add({
        'userId': user.uid,
        'movieId': movieId,
        'movieTitle': movieTitle,
        'posterUrl': posterUrl,
        'seats': seatNumbers,
        'totalPrice': totalPrice,
        'bookingDate': FieldValue.serverTimestamp(),
        'showTime': Timestamp.fromDate(showTime),
        'status': 'active',
      });

      Get.snackbar(
        "Berhasil!",
        "Tiket berhasil dipesan.",
        backgroundColor: AppTheme.primaryGold,
        colorText: AppTheme.darkText,
      );

      Get.offAllNamed(AppRoutes.home);
    } catch (e) {
      Get.snackbar("Gagal", "Terjadi kesalahan server: $e");
    } finally {
      isLoading.value = false;
    }
  }
}
