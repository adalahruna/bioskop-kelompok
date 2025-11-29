import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart'; // Jangan lupa package intl
import '../../core/theme/app_theme.dart';
import 'booking_controller.dart';

class BookingPage extends GetView<BookingController> {
  const BookingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          controller.movieTitle,
          style: GoogleFonts.playfairDisplay(
            color: AppTheme.primaryGold,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: AppTheme.primaryGold),
      ),
      body: Column(
        children: [
          // 1. Selector Tanggal (Horizontal)
          _buildDateSelector(),

          const SizedBox(height: 20),

          // 2. Selector Jam Tayang (Chips)
          _buildTimeSelector(),

          const SizedBox(height: 20),

          // 3. Layar Bioskop & Grid Kursi (Expanded agar mengisi sisa ruang)
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _buildScreenDisplay(),
                  const SizedBox(height: 20),
                  _buildSeatGrid(),
                  const SizedBox(height: 20),
                  _buildLegend(),
                  const SizedBox(
                    height: 80,
                  ), // Space bawah agar tidak tertutup panel
                ],
              ),
            ),
          ),

          // 4. Panel Checkout (Sticky Bottom)
          _buildCheckoutPanel(),
        ],
      ),
    );
  }

  // --- WIDGET TANGGAL ---
  Widget _buildDateSelector() {
    return SizedBox(
      height: 90,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: controller.next7Days.length,
        itemBuilder: (context, index) {
          final date = controller.next7Days[index];
          final isToday = index == 0;

          return Obx(() {
            // Cek apakah tanggal ini dipilih
            final isSelected =
                controller.selectedDate.value.day == date.day &&
                controller.selectedDate.value.month == date.month;

            return GestureDetector(
              onTap: () => controller.selectDate(date),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: 70,
                margin: const EdgeInsets.only(right: 12),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppTheme.primaryGold
                      : AppTheme.secondaryBackground,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected
                        ? AppTheme.primaryGold
                        : Colors.white.withOpacity(0.1),
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      DateFormat('MMM').format(date).toUpperCase(),
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: isSelected ? Colors.black : Colors.grey,
                      ),
                    ),
                    Text(
                      DateFormat('d').format(date),
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: isSelected ? Colors.black : Colors.white,
                      ),
                    ),
                    Text(
                      isToday ? "Today" : DateFormat('E').format(date),
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: isSelected ? Colors.black : Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            );
          });
        },
      ),
    );
  }

  // --- WIDGET JAM ---
  Widget _buildTimeSelector() {
    return SizedBox(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: controller.timeSlots.length,
        itemBuilder: (context, index) {
          final time = controller.timeSlots[index];

          return Obx(() {
            final isSelected = controller.selectedTime.value == time;
            // Cek apakah jam ini sudah lewat (Realtime check)
            final isExpired = controller.isTimeSlotExpired(time);

            return GestureDetector(
              onTap: isExpired ? null : () => controller.selectTime(time),
              child: Container(
                margin: const EdgeInsets.only(right: 12),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: isExpired
                      ? Colors.grey.withOpacity(0.1) // Warna mati jika expired
                      : (isSelected
                            ? AppTheme.primaryGold
                            : Colors.transparent),
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(
                    color: isExpired
                        ? Colors.transparent
                        : (isSelected ? AppTheme.primaryGold : Colors.grey),
                  ),
                ),
                child: Center(
                  child: Text(
                    time,
                    style: GoogleFonts.poppins(
                      color: isExpired
                          ? Colors.grey.withOpacity(
                              0.3,
                            ) // Teks mati jika expired
                          : (isSelected ? Colors.black : Colors.white),
                      fontWeight: FontWeight.w600,
                      decoration: isExpired ? TextDecoration.lineThrough : null,
                    ),
                  ),
                ),
              ),
            );
          });
        },
      ),
    );
  }

  Widget _buildScreenDisplay() {
    return Container(
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
    );
  }

  Widget _buildSeatGrid() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Obx(
          () => Column(
            children: List.generate(controller.seats.length, (rowIndex) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(controller.seats[rowIndex].length, (
                  colIndex,
                ) {
                  return _buildSeatItem(rowIndex, colIndex);
                }),
              );
            }),
          ),
        ),
      ),
    );
  }

  Widget _buildSeatItem(int row, int col) {
    return Obx(() {
      int status = controller.seats[row][col].value;
      Color seatColor;

      if (status == 0)
        seatColor = Colors.grey.shade800;
      else if (status == 1)
        seatColor = AppTheme.primaryGold;
      else
        seatColor = Colors.red.shade900;

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
          width: 14,
          height: 14,
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Obx(
                    () => Text(
                      controller.selectedSeats.isEmpty
                          ? "No Seat"
                          : controller.seatNumbers,
                      style: GoogleFonts.poppins(
                        color: AppTheme.lightText,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  Obx(() {
                    String time = controller.selectedTime.value.isEmpty
                        ? "Select Time"
                        : "${DateFormat('dd MMM').format(controller.selectedDate.value)}, ${controller.selectedTime.value}";
                    return Text(
                      time,
                      style: GoogleFonts.poppins(
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                    );
                  }),
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
                  const Text(
                    "Total Price",
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
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
