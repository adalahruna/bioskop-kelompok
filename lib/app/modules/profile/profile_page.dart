import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Penting untuk Timestamp
import 'package:intl/intl.dart'; // Untuk format tanggal
import '../../core/theme/app_theme.dart';
import 'profile_controller.dart';

class ProfilePage extends GetView<ProfileController> {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3, // 3 Tab: Movies, Dining, Rentals
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            "My Profile",
            style: GoogleFonts.playfairDisplay(
              color: AppTheme.primaryGold,
              fontWeight: FontWeight.bold,
            ),
          ),
          actions: [
            IconButton(
              onPressed: controller.logout,
              icon: const Icon(Icons.logout, color: Colors.redAccent),
              tooltip: "Logout",
            ),
          ],
        ),
        body: Column(
          children: [
            // 1. Header Profil (Foto & Nama Editable)
            _buildProfileHeader(),

            const SizedBox(height: 20),

            // 2. Custom Tab Bar
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              height: 45,
              decoration: BoxDecoration(
                color: AppTheme.secondaryBackground,
                borderRadius: BorderRadius.circular(25),
                border: Border.all(color: Colors.white.withOpacity(0.1)),
              ),
              child: TabBar(
                indicator: BoxDecoration(
                  color: AppTheme.primaryGold,
                  borderRadius: BorderRadius.circular(25),
                ),
                labelColor: AppTheme.darkText,
                unselectedLabelColor: Colors.grey,
                labelStyle: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                dividerColor: Colors.transparent,
                tabs: const [
                  Tab(text: "Movies"),
                  Tab(text: "Dining"),
                  Tab(text: "Rentals"),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // 3. Tab Content (List History)
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: AppTheme.primaryGold,
                    ),
                  );
                }

                return TabBarView(
                  children: [
                    _buildTicketList(), // Tab 1
                    _buildFoodOrderList(), // Tab 2
                    _buildRentalList(), // Tab 3
                  ],
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  // --- WIDGETS HEADER (EDITABLE) ---

  Widget _buildProfileHeader() {
    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: AppTheme.secondaryBackground,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(30)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          // --- FOTO PROFIL (UPLOAD SUPABASE) ---
          GestureDetector(
            onTap: controller.pickAndUploadImage, // Trigger Upload saat diklik
            child: Stack(
              children: [
                Container(
                  padding: const EdgeInsets.all(3),
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppTheme.primaryGold,
                  ),
                  child: Obx(() {
                    // 1. Cek jika sedang upload
                    if (controller.isUploading.value) {
                      return const CircleAvatar(
                        radius: 35,
                        backgroundColor: AppTheme.darkBackground,
                        child: CircularProgressIndicator(
                          color: AppTheme.primaryGold,
                        ),
                      );
                    }

                    // 2. Cek jika URL foto ada (dari Supabase/Firestore)
                    if (controller.userPhotoUrl.value.isNotEmpty) {
                      return CircleAvatar(
                        radius: 35,
                        backgroundColor: AppTheme.darkBackground,
                        backgroundImage: NetworkImage(
                          controller.userPhotoUrl.value,
                        ),
                        onBackgroundImageError: (_, __) =>
                            const Icon(Icons.person),
                      );
                    }

                    // 3. Default Icon
                    return const CircleAvatar(
                      radius: 35,
                      backgroundColor: AppTheme.darkBackground,
                      child: Icon(
                        Icons.person,
                        size: 40,
                        color: AppTheme.primaryGold,
                      ),
                    );
                  }),
                ),
                // Ikon Kamera Kecil (Indikator Edit)
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.camera_alt,
                      size: 14,
                      color: Colors.black,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 20),

          // --- INFO USER (EDITABLE NAME) ---
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // Nama User
                    Obx(
                      () => Text(
                        controller.userName.value,
                        style: GoogleFonts.playfairDisplay(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.lightText,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Tombol Edit Nama
                    GestureDetector(
                      onTap: controller.showEditNameDialog,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.edit,
                          size: 14,
                          color: AppTheme.primaryGold,
                        ),
                      ),
                    ),
                  ],
                ),
                Obx(
                  () => Text(
                    controller.userEmail.value,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryGold.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppTheme.primaryGold.withOpacity(0.5),
                    ),
                  ),
                  child: Text(
                    "Noir Member",
                    style: GoogleFonts.poppins(
                      color: AppTheme.primaryGold,
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
    );
  }

  // --- TAB 1: LIST TIKET BIOSKOP ---
  Widget _buildTicketList() {
    if (controller.myTickets.isEmpty) {
      return _buildEmptyState(
        "No movie tickets yet.",
        Icons.movie_filter_outlined,
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      itemCount: controller.myTickets.length,
      itemBuilder: (context, index) {
        final ticket = controller.myTickets[index];

        String dateStr = "Unknown Date";
        if (ticket['showTime'] != null && ticket['showTime'] is Timestamp) {
          DateTime date = (ticket['showTime'] as Timestamp).toDate();
          dateStr = DateFormat('EEE, d MMM • HH:mm').format(date);
        }

        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          height: 150,
          decoration: BoxDecoration(
            color: AppTheme.secondaryBackground,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.05)),
          ),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.horizontal(
                  left: Radius.circular(16),
                ),
                child: Image.network(
                  ticket['posterUrl'] ?? 'https://via.placeholder.com/100',
                  width: 100,
                  height: 150,
                  fit: BoxFit.cover,
                  errorBuilder: (ctx, err, stack) =>
                      Container(width: 100, color: Colors.grey),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        ticket['movieTitle'] ?? 'Unknown',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.lightText,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(
                            Icons.access_time,
                            size: 14,
                            color: AppTheme.primaryGold,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            dateStr,
                            style: GoogleFonts.poppins(
                              color: AppTheme.primaryGold,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(
                            Icons.event_seat,
                            size: 14,
                            color: Colors.grey,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            "Seats: ${ticket['seats']}",
                            style: GoogleFonts.poppins(
                              color: Colors.grey,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Rp ${ticket['totalPrice']}",
                            style: GoogleFonts.poppins(
                              color: Colors.grey,
                              fontSize: 13,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.green.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: Colors.green.withOpacity(0.5),
                              ),
                            ),
                            child: Text(
                              "ACTIVE",
                              style: GoogleFonts.poppins(
                                color: Colors.green,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // --- TAB 2: LIST PESANAN MAKANAN ---
  Widget _buildFoodOrderList() {
    if (controller.myFoodOrders.isEmpty) {
      return _buildEmptyState("No food orders yet.", Icons.fastfood_outlined);
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      itemCount: controller.myFoodOrders.length,
      itemBuilder: (context, index) {
        final order = controller.myFoodOrders[index];
        final List items = order['items'] ?? [];
        final total = order['total'] ?? 0;

        String orderDateStr = "-";
        if (order['orderDate'] != null && order['orderDate'] is Timestamp) {
          DateTime date = (order['orderDate'] as Timestamp).toDate();
          orderDateStr = DateFormat('d MMM yyyy, HH:mm').format(date);
        }

        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.secondaryBackground,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.05)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.receipt_long,
                            color: AppTheme.primaryGold,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            "Food Order",
                            style: GoogleFonts.poppins(
                              color: AppTheme.lightText,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 26.0, top: 4),
                        child: Text(
                          orderDateStr,
                          style: GoogleFonts.poppins(
                            color: Colors.grey,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      "PICKUP",
                      style: GoogleFonts.poppins(
                        color: Colors.blue,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const Divider(color: Colors.grey, thickness: 0.2, height: 24),
              ...items.map(
                (item) => Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "${item['qty']}x  ${item['name']}",
                        style: GoogleFonts.poppins(
                          color: Colors.grey,
                          fontSize: 13,
                        ),
                      ),
                      Text(
                        "Rp ${item['subtotal']}",
                        style: GoogleFonts.poppins(
                          color: Colors.grey,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),
              const Divider(color: Colors.grey, thickness: 0.5),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Total Paid",
                    style: GoogleFonts.poppins(
                      color: AppTheme.lightText,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    "Rp $total",
                    style: GoogleFonts.poppins(
                      color: AppTheme.primaryGold,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  // --- TAB 3: LIST SEWA FILM ---
  Widget _buildRentalList() {
    if (controller.myRentals.isEmpty) {
      return _buildEmptyState("No active rentals.", Icons.movie_outlined);
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      itemCount: controller.myRentals.length,
      itemBuilder: (context, index) {
        final rental = controller.myRentals[index];

        Timestamp? endTimestamp = rental['endDate'];
        bool isExpired = false;
        String validUntil = "-";

        if (endTimestamp != null) {
          DateTime end = endTimestamp.toDate();
          isExpired = end.isBefore(DateTime.now());
          validUntil = DateFormat('d MMM yyyy').format(end);
        }

        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          height: 150,
          decoration: BoxDecoration(
            color: AppTheme.secondaryBackground,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.05)),
          ),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.horizontal(
                  left: Radius.circular(16),
                ),
                child: Image.network(
                  rental['posterUrl'] ?? 'https://via.placeholder.com/100',
                  width: 100,
                  height: 150,
                  fit: BoxFit.cover,
                  errorBuilder: (ctx, err, stack) =>
                      Container(width: 100, color: Colors.grey),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        rental['movieTitle'] ?? 'Unknown',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.lightText,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(
                            Icons.timer,
                            size: 14,
                            color: AppTheme.primaryGold,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            "${rental['durationDays']} Days",
                            style: GoogleFonts.poppins(
                              color: Colors.grey,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(
                            Icons.calendar_today,
                            size: 14,
                            color: AppTheme.primaryGold,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            "Until: $validUntil",
                            style: GoogleFonts.poppins(
                              color: Colors.grey,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      Align(
                        alignment: Alignment.bottomRight,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: isExpired
                                ? Colors.red.withOpacity(0.2)
                                : Colors.blue.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: isExpired
                                  ? Colors.red.withOpacity(0.5)
                                  : Colors.blue.withOpacity(0.5),
                            ),
                          ),
                          child: Text(
                            isExpired ? "EXPIRED" : "ACTIVE",
                            style: GoogleFonts.poppins(
                              color: isExpired ? Colors.red : Colors.blue,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(String message, IconData icon) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 60, color: Colors.grey.withOpacity(0.3)),
          const SizedBox(height: 16),
          Text(message, style: GoogleFonts.poppins(color: Colors.grey)),
        ],
      ),
    );
  }
}
