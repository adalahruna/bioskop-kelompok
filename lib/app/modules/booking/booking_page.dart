import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import 'booking_controller.dart';

class BookingPage extends GetView<BookingController> {
  const BookingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          controller.movieTitle, // Judul film di App Bar
          style: GoogleFonts.playfairDisplay(
            color: AppTheme.primaryGold,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        children: [
          // 1. Layar Bioskop
          const SizedBox(height: 20),
          Container(
            height: 40,
            width: double.infinity,
            margin: const EdgeInsets.symmetric(horizontal: 40),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppTheme.primaryGold.withOpacity(0),
                  AppTheme.primaryGold.withOpacity(0.5),
                  AppTheme.primaryGold.withOpacity(0),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              border: const Border(
                top: BorderSide(color: AppTheme.primaryGold, width: 4),
              ),
            ),
            child: Center(
              child: Text(
                "SCREEN",
                style: GoogleFonts.poppins(
                  color: AppTheme.primaryGold,
                  letterSpacing: 4,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),

          const SizedBox(height: 40),

          // 2. Grid Kursi
          Expanded(
            child: Center(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal, // Biar aman di HP kecil
                child: Obx(
                  () => Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(controller.seats.length, (
                      rowIndex,
                    ) {
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          controller.seats[rowIndex].length,
                          (colIndex) {
                            return _buildSeat(rowIndex, colIndex);
                          },
                        ),
                      );
                    }),
                  ),
                ),
              ),
            ),
          ),

          // 3. Legenda (Keterangan Warna)
          _buildLegend(),

          const SizedBox(height: 20),

          // 4. Bottom Sheet (Checkout)
          _buildCheckoutPanel(),
        ],
      ),
    );
  }

  Widget _buildSeat(int row, int col) {
    return Obx(() {
      int status = controller.seats[row][col].value;
      Color seatColor;

      if (status == 0)
        seatColor = Colors.grey.shade800; // Tersedia
      else if (status == 1)
        seatColor = AppTheme.primaryGold; // Dipilih
      else
        seatColor = Colors.red.shade900; // Sold (2)

      return GestureDetector(
        onTap: () => controller.toggleSeat(row, col),
        child: Container(
          margin: const EdgeInsets.all(6),
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: seatColor,
            borderRadius: BorderRadius.circular(6),
            border: status == 1
                ? Border.all(color: Colors.white, width: 2)
                : null,
          ),
        ),
      );
    });
  }

  Widget _buildLegend() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _legendItem(Colors.grey.shade800, "Available"),
        const SizedBox(width: 20),
        _legendItem(AppTheme.primaryGold, "Selected"),
        const SizedBox(width: 20),
        _legendItem(Colors.red.shade900, "Sold"),
      ],
    );
  }

  Widget _legendItem(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: GoogleFonts.poppins(color: AppTheme.lightText, fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildCheckoutPanel() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: AppTheme.secondaryBackground,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Info Kursi & Harga
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Obx(
                    () => Text(
                      controller.selectedSeats.isEmpty
                          ? "Select seat"
                          : controller.seatNumbers,
                      style: GoogleFonts.poppins(
                        color: AppTheme.lightText,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Seat Numbers",
                    style: GoogleFonts.poppins(
                      color: Colors.grey,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Obx(
                    () => Text(
                      "Rp ${controller.totalPrice.toStringAsFixed(0)}",
                      style: GoogleFonts.poppins(
                        color: AppTheme.primaryGold,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Total Price",
                    style: GoogleFonts.poppins(
                      color: Colors.grey,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Tombol Konfirmasi
          SizedBox(
            width: double.infinity,
            height: 50,
            child: Obx(
              () => ElevatedButton(
                onPressed: controller.isLoading.value
                    ? null
                    : controller.confirmBooking,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryGold,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: controller.isLoading.value
                    ? const CircularProgressIndicator(color: Colors.black)
                    : Text(
                        "Confirm Booking",
                        style: GoogleFonts.poppins(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
