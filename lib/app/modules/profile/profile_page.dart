import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import 'profile_controller.dart';

class ProfilePage extends GetView<ProfileController> {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2, // 2 Tab: Movies & Dining
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
            // 1. Header Profil
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
                labelStyle: GoogleFonts.poppins(fontWeight: FontWeight.bold),
                indicatorSize: TabBarIndicatorSize.tab,
                dividerColor: Colors.transparent,
                tabs: const [
                  Tab(text: "Movies"),
                  Tab(text: "Dining"),
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
                    // Tab 1: List Tiket
                    _buildTicketList(),

                    // Tab 2: List Makanan
                    _buildFoodOrderList(),
                  ],
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  // --- WIDGETS ---

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
          // Avatar
          Container(
            padding: const EdgeInsets.all(3),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.primaryGold,
            ),
            child: const CircleAvatar(
              radius: 35,
              backgroundColor: AppTheme.darkBackground,
              child: Icon(Icons.person, size: 40, color: AppTheme.primaryGold),
            ),
          ),
          const SizedBox(width: 20),

          // Info User
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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

  // --- LIST TIKET ---
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
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          height: 140,
          decoration: BoxDecoration(
            color: AppTheme.secondaryBackground,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.05)),
          ),
          child: Row(
            children: [
              // Poster Film
              ClipRRect(
                borderRadius: const BorderRadius.horizontal(
                  left: Radius.circular(16),
                ),
                child: Image.network(
                  ticket['posterUrl'] ?? 'https://via.placeholder.com/100',
                  width: 100,
                  height: 140,
                  fit: BoxFit.cover,
                  errorBuilder: (ctx, err, stack) =>
                      Container(width: 100, color: Colors.grey),
                ),
              ),

              // Info Tiket
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
                            Icons.event_seat,
                            size: 14,
                            color: AppTheme.primaryGold,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            "Seats: ${ticket['seats']}",
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
                            Icons.confirmation_number,
                            size: 14,
                            color: AppTheme.primaryGold,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            "Rp ${ticket['totalPrice']}",
                            style: GoogleFonts.poppins(
                              color: Colors.grey,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      // Badge Status
                      Align(
                        alignment: Alignment.bottomRight,
                        child: Container(
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

  // --- LIST MAKANAN ---
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
              // Header Order
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
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

              // Daftar Item Makanan
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

              // Total
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
