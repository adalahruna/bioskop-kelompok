import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_theme.dart';
import 'rentals_controller.dart';

class RentTransactionPage extends GetView<RentalsController> {
  const RentTransactionPage({super.key});

  @override
  Widget build(BuildContext context) {
    final movie = controller.selectedMovieForRent.value;
    if (movie == null)
      return const Scaffold(body: Center(child: Text("Error")));

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Rental Setup",
          style: GoogleFonts.playfairDisplay(color: AppTheme.primaryGold),
        ),
        iconTheme: const IconThemeData(color: AppTheme.primaryGold),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Info Film Singkat
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    movie.fullPosterPath,
                    width: 100,
                    height: 150,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        movie.title,
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Rating: ${movie.voteAverage}/10",
                        style: const TextStyle(color: AppTheme.primaryGold),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          "DIGITAL HD",
                          style: GoogleFonts.poppins(
                            color: Colors.blue,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 30),
            const Divider(color: Colors.grey, thickness: 0.2),
            const SizedBox(height: 20),

            // 2. Pilih Tanggal Mulai
            Text(
              "Start Watching Date",
              style: GoogleFonts.poppins(color: Colors.grey),
            ),
            const SizedBox(height: 10),
            GestureDetector(
              onTap: () => controller.pickDate(context),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.secondaryBackground,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppTheme.primaryGold.withOpacity(0.5),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Obx(
                      () => Text(
                        controller.startDate.value == null
                            ? "Select Date"
                            : DateFormat(
                                'EEEE, d MMMM yyyy',
                              ).format(controller.startDate.value!),
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    const Icon(
                      Icons.calendar_today,
                      color: AppTheme.primaryGold,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // 3. Pilihan Paket Durasi
            Text(
              "Duration Package",
              style: GoogleFonts.poppins(color: Colors.grey),
            ),
            const SizedBox(height: 10),
            Obx(
              () => Row(
                children: [
                  _buildDurationOption("Daily", "1 Day", controller),
                  const SizedBox(width: 12),
                  _buildDurationOption("Weekly", "7 Days", controller),
                  const SizedBox(width: 12),
                  _buildDurationOption("Custom", "Custom", controller),
                ],
              ),
            ),

            // Slider untuk Custom Duration (Hanya muncul jika pilih Custom)
            Obx(() {
              if (controller.rentalOption.value == "Custom") {
                return Column(
                  children: [
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Custom Days:",
                          style: GoogleFonts.poppins(color: Colors.grey),
                        ),
                        Text(
                          "${controller.rentalDuration.value} Days",
                          style: GoogleFonts.poppins(
                            color: AppTheme.primaryGold,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Slider(
                      value: controller.rentalDuration.value.toDouble(),
                      min: 1,
                      max: 30,
                      activeColor: AppTheme.primaryGold,
                      inactiveColor: AppTheme.secondaryBackground,
                      onChanged: (val) =>
                          controller.rentalDuration.value = val.toInt(),
                    ),
                  ],
                );
              }
              return const SizedBox.shrink();
            }),

            const SizedBox(height: 40),

            // 4. Total Harga & Tombol
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.secondaryBackground,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Total Price",
                        style: GoogleFonts.poppins(color: Colors.white),
                      ),
                      Obx(
                        () => Text(
                          "Rp ${controller.totalRentPrice.toStringAsFixed(0)}",
                          style: GoogleFonts.poppins(
                            color: AppTheme.primaryGold,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: Obx(
                      () => ElevatedButton(
                        onPressed: controller.isProcessing.value
                            ? null
                            : controller.confirmRental,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryGold,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: controller.isProcessing.value
                            ? const CircularProgressIndicator(
                                color: Colors.black,
                              )
                            : Text(
                                "CONFIRM RENTAL",
                                style: GoogleFonts.poppins(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDurationOption(
    String value,
    String label,
    RentalsController controller,
  ) {
    bool isSelected = controller.rentalOption.value == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => controller.setDurationOption(value),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected
                ? AppTheme.primaryGold
                : AppTheme.secondaryBackground,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? AppTheme.primaryGold
                  : Colors.grey.withOpacity(0.2),
            ),
          ),
          child: Column(
            children: [
              Text(
                label,
                style: GoogleFonts.poppins(
                  color: isSelected ? Colors.black : Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (value == "Daily")
                Text(
                  "Rp 15k",
                  style: TextStyle(
                    fontSize: 10,
                    color: isSelected ? Colors.black54 : Colors.grey,
                  ),
                ),
              if (value == "Weekly")
                Text(
                  "Rp 75k",
                  style: TextStyle(
                    fontSize: 10,
                    color: isSelected ? Colors.black54 : Colors.grey,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
