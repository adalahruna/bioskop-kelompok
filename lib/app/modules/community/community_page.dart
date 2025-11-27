import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import 'community_controller.dart';
import '../widgets/movie_poster_card.dart';

class CommunityPage extends StatelessWidget {
  const CommunityPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(CommunityController());

    return Scaffold(
      appBar: AppBar(
        title: Obx(
          () => Text(
            controller.selectedMovie.value == null
                ? "Community Forum"
                : "Movie Discussion",
            style: GoogleFonts.playfairDisplay(
              color: AppTheme.primaryGold,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        iconTheme: const IconThemeData(color: AppTheme.primaryGold),
        leading: Obx(() {
          if (controller.selectedMovie.value != null) {
            return IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: controller.backToList,
            );
          }
          return const BackButton();
        }),
      ),
      body: Obx(() {
        // TAMPILAN 1: LIST FILM (TOPIK)
        if (controller.selectedMovie.value == null) {
          return _buildTopicList(controller);
        }

        // TAMPILAN 2: RUANG DISKUSI
        return _buildDiscussionRoom(controller, context);
      }),
    );
  }

  // --- VIEW 1: PILIH FILM ---
  Widget _buildTopicList(CommunityController controller) {
    return Column(
      children: [
        // Search Bar
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: TextField(
            controller: controller.searchController,
            onChanged: (val) => controller.searchTopics(val),
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: "Search movie topic...",
              hintStyle: TextStyle(color: Colors.grey.withOpacity(0.5)),
              prefixIcon: const Icon(Icons.search, color: AppTheme.primaryGold),
              filled: true,
              fillColor: AppTheme.secondaryBackground,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 20),
            ),
          ),
        ),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              "Select a movie to join discussion",
              style: GoogleFonts.poppins(color: Colors.grey, fontSize: 12),
            ),
          ),
        ),

        Expanded(
          child: Obx(() {
            if (controller.isLoading.value) {
              return const Center(
                child: CircularProgressIndicator(color: AppTheme.primaryGold),
              );
            }

            if (controller.filteredMovies.isEmpty) {
              return Center(
                child: Text(
                  "No movies found",
                  style: GoogleFonts.poppins(color: Colors.grey),
                ),
              );
            }

            return GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3, // 3 kolom
                childAspectRatio: 0.6,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: controller.filteredMovies.length,
              itemBuilder: (context, index) {
                final movie = controller.filteredMovies[index];
                return Column(
                  children: [
                    Expanded(
                      child: MoviePosterCard(
                        posterUrl: movie.fullPosterPath,
                        onTap: () => controller.openDiscussion(movie),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      movie.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        fontSize: 10,
                        color: Colors.white70,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                );
              },
            );
          }),
        ),
      ],
    );
  }

  // --- VIEW 2: DETAIL DISKUSI ---
  Widget _buildDiscussionRoom(
    CommunityController controller,
    BuildContext context,
  ) {
    final movie = controller.selectedMovie.value!;

    return Column(
      children: [
        // Area Scrollable untuk Info Film & Komentar
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Header Detail Film
                Container(
                  padding: const EdgeInsets.all(16),
                  color: AppTheme.secondaryBackground,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Poster
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          movie.fullPosterPath,
                          width: 80,
                          height: 120,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Info Teks
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              movie.title,
                              style: GoogleFonts.playfairDisplay(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.primaryGold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            // Rating & Tahun (Butuh release_date di model)
                            Row(
                              children: [
                                const Icon(
                                  Icons.star,
                                  color: Colors.amber,
                                  size: 16,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  "${movie.voteAverage.toStringAsFixed(1)} / 10",
                                  style: GoogleFonts.poppins(
                                    color: Colors.white,
                                    fontSize: 12,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                const Icon(
                                  Icons.calendar_today,
                                  color: Colors.grey,
                                  size: 14,
                                ),
                                const SizedBox(width: 4),
                                // Asumsi movie model punya releaseDate (atau kita handle jika null)
                                Text(
                                  "Released",
                                  style: GoogleFonts.poppins(
                                    color: Colors.grey,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            // Sinopsis Singkat
                            Text(
                              movie.overview,
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: Colors.white70,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // 2. Cast List
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Text(
                    "Top Cast",
                    style: GoogleFonts.poppins(
                      color: AppTheme.lightText,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                SizedBox(
                  height: 90,
                  child: Obx(() {
                    if (controller.movieCast.isEmpty) {
                      return Padding(
                        padding: const EdgeInsets.only(left: 16),
                        child: Text(
                          "Loading cast...",
                          style: GoogleFonts.poppins(
                            color: Colors.grey,
                            fontSize: 10,
                          ),
                        ),
                      );
                    }
                    return ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: controller.movieCast.length,
                      itemBuilder: (context, index) {
                        final actor = controller.movieCast[index];
                        return Container(
                          width: 60,
                          margin: const EdgeInsets.only(right: 12),
                          child: Column(
                            children: [
                              CircleAvatar(
                                radius: 24,
                                backgroundImage: NetworkImage(
                                  actor.profilePath,
                                ),
                                backgroundColor: Colors.grey[800],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                actor.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.poppins(
                                  fontSize: 8,
                                  color: Colors.white,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  }),
                ),

                const Divider(color: Colors.grey, thickness: 0.2, height: 30),

                // 3. Header Diskusi
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.forum_outlined,
                        color: AppTheme.primaryGold,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "Live Discussion",
                        style: GoogleFonts.poppins(
                          color: AppTheme.lightText,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),

                // 4. List Komentar
                Obx(() {
                  if (controller.comments.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.all(30.0),
                      child: Center(
                        child: Text(
                          "No comments yet.\nStart the discussion!",
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(color: Colors.grey),
                        ),
                      ),
                    );
                  }
                  // Menggunakan ListView.builder dengan shrinkWrap agar bisa di dalam SingleChildScrollView
                  // Note: Untuk performa chat yang sangat panjang, lebih baik pakai Expanded + Column di luar SingleChildScrollView
                  // Tapi untuk tugas ini, ini sudah cukup oke.
                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    itemCount: controller.comments.length,
                    itemBuilder: (context, index) {
                      final comment = controller.comments[index];
                      return _buildCommentBubble(comment);
                    },
                  );
                }),

                // Spasi untuk input field agar tidak tertutup
                const SizedBox(height: 80),
              ],
            ),
          ),
        ),

        // 5. Input Pesan (Sticky di Bawah)
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            color: AppTheme.secondaryBackground,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 5,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller.messageController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: "Add a comment...",
                    hintStyle: TextStyle(color: Colors.grey.withOpacity(0.5)),
                    filled: true,
                    fillColor: Colors.black.withOpacity(0.3),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              CircleAvatar(
                backgroundColor: AppTheme.primaryGold,
                radius: 22,
                child: IconButton(
                  onPressed: controller.sendComment,
                  icon: const Icon(
                    Icons.send,
                    color: AppTheme.darkBackground,
                    size: 18,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCommentBubble(dynamic comment) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: AppTheme.primaryGold.withOpacity(0.2),
            child: const Icon(
              Icons.person,
              size: 20,
              color: AppTheme.primaryGold,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      comment.userName,
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Bisa tambah timestamp di sini jika mau
                  ],
                ),
                const SizedBox(height: 2),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(12),
                      bottomLeft: Radius.circular(12),
                      bottomRight: Radius.circular(12),
                    ),
                  ),
                  child: Text(
                    comment.text,
                    style: GoogleFonts.poppins(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 13,
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
}
