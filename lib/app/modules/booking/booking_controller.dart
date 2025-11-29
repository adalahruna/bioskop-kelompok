import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/app_routes.dart';

class BookingController extends GetxController {
  // Data Film
  late final int movieId;
  late final String movieTitle;
  late final String posterUrl;

  // Konfigurasi Kursi (0=Avail, 1=Selected, 2=Sold)
  var seats = List.generate(6, (i) => List.generate(8, (j) => 0.obs)).obs;
  var selectedSeats = <List<int>>[].obs;

  // --- JADWAL TAYANG (BARU) ---
  final selectedDate = Rx<DateTime>(DateTime.now());
  final selectedTime = "".obs;

  // List jam tayang statis
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
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments as Map<String, dynamic>;
    movieId = args['id'];
    movieTitle = args['title'];
    posterUrl = args['poster'];

    // Reset kursi sold secara random untuk simulasi
    _randomizeSoldSeats();
  }

  // Generate 7 hari ke depan untuk dipilih
  List<DateTime> get next7Days {
    return List.generate(
      7,
      (index) => DateTime.now().add(Duration(days: index)),
    );
  }

  // Cek apakah jam tayang sudah lewat (Realtime Validation)
  bool isTimeSlotExpired(String time) {
    // Jika tanggal yang dipilih BUKAN hari ini, maka jam tidak expired
    final now = DateTime.now();
    if (selectedDate.value.day != now.day ||
        selectedDate.value.month != now.month ||
        selectedDate.value.year != now.year) {
      return false;
    }

    // Jika HARI INI, cek jamnya
    try {
      final parts = time.split(':');
      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);

      final slotTime = DateTime(now.year, now.month, now.day, hour, minute);

      // Jika waktu slot SEBELUM waktu sekarang, berarti expired
      return slotTime.isBefore(now);
    } catch (e) {
      return true; // Default disable jika error parsing
    }
  }

  void selectDate(DateTime date) {
    selectedDate.value = date;
    // Reset jam jika pindah tanggal agar user memilih ulang
    selectedTime.value = "";
    // (Opsional) Di sini bisa panggil API/Firebase untuk load kursi yang sold pada tanggal tsb
    _randomizeSoldSeats();
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
  }

  void _randomizeSoldSeats() {
    // Reset semua jadi 0
    for (var row in seats) {
      for (var seat in row) seat.value = 0;
    }
    selectedSeats.clear();

    // Randomize lagi (Simulasi kursi terjual berbeda tiap sesi)
    seats[0][2].value = 2;
    seats[0][3].value = 2;
    // Tambah random logic lain jika mau
  }

  void toggleSeat(int row, int col) {
    if (seats[row][col].value == 2) return;

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
    // Validasi Lengkap
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
      // Gabungkan Tanggal & Jam untuk disimpan
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
        'bookingDate': FieldValue.serverTimestamp(), // Waktu transaksi
        'showTime': Timestamp.fromDate(showTime), // Waktu nonton (Jadwal)
        'status': 'active',
      });

      Get.snackbar(
        "Berhasil!",
        "Tiket untuk ${DateFormat('dd MMM, HH:mm').format(showTime)} berhasil dipesan.",
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
