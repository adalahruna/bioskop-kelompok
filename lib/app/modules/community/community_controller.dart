import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../data/models/community_model.dart';
import '../../data/models/movie_model.dart';
import '../../data/models/cast_model.dart';
import '../../data/providers/tmdb_provider.dart';

class CommunityController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TmdbProvider _tmdbProvider = Get.find<TmdbProvider>();

  final messageController = TextEditingController();
  final searchController = TextEditingController();

  final isLoading = true.obs;

  // STATE LIST FILM (Untuk Search)
  final allDiscussionMovies = <MovieModel>[];
  final filteredMovies = <MovieModel>[].obs;

  // STATE DISKUSI AKTIF
  final selectedMovie = Rxn<MovieModel>();
  final movieCast = <CastModel>[].obs;

  // Dua Sumber Komentar
  RxList<CommunityModel> firestoreComments = <CommunityModel>[].obs;
  RxList<CommunityModel> tmdbReviews = <CommunityModel>[].obs;

  // Getter untuk menggabungkan Firestore + TMDB
  List<CommunityModel> get comments {
    final all = <CommunityModel>[...firestoreComments, ...tmdbReviews];
    // Urutkan berdasarkan waktu terbaru
    all.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return all;
  }

  @override
  void onInit() {
    super.onInit();
    loadDiscussionTopics();
  }

  @override
  void onClose() {
    messageController.dispose();
    searchController.dispose();
    super.onClose();
  }

  void loadDiscussionTopics() async {
    try {
      isLoading.value = true;
      final movies = await _tmdbProvider.getNowPlayingMovies();
      allDiscussionMovies.assignAll(movies);
      filteredMovies.assignAll(movies);
    } finally {
      isLoading.value = false;
    }
  }

  // Logika Search Film
  void searchTopics(String query) {
    if (query.isEmpty) {
      filteredMovies.assignAll(allDiscussionMovies);
    } else {
      final lowerQuery = query.toLowerCase();
      final result = allDiscussionMovies.where((movie) {
        return movie.title.toLowerCase().contains(lowerQuery);
      }).toList();
      filteredMovies.assignAll(result);
    }
  }

  void openDiscussion(MovieModel movie) async {
    selectedMovie.value = movie;
    isLoading.value = true;

    // Reset Data sebelum memuat yang baru
    firestoreComments.clear();
    tmdbReviews.clear();
    movieCast.clear();

    try {
      // 1. Ambil Cast (Pemeran)
      final cast = await _tmdbProvider.getMovieCast(movie.id);
      movieCast.value = cast;

      // 2. Ambil Review dari TMDB
      final reviews = await _tmdbProvider.getMovieReviews(movie.id);
      tmdbReviews.assignAll(reviews);

      // 3. Binding Stream Komentar Firestore (Realtime)
      firestoreComments.bindStream(_getCommentsStream(movie.id));
    } finally {
      isLoading.value = false;
    }
  }

  void backToList() {
    selectedMovie.value = null;
    firestoreComments.clear(); // Hapus stream
    tmdbReviews.clear();
    messageController.clear();
  }

  Stream<List<CommunityModel>> _getCommentsStream(int movieId) {
    return _firestore
        .collection('movie_discussions')
        .where('movieId', isEqualTo: movieId.toString())
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((query) {
          return query.docs
              .map((item) => CommunityModel.fromDocument(item))
              .toList();
        });
  }

  void sendComment() async {
    if (messageController.text.trim().isEmpty) return;
    if (selectedMovie.value == null) return;

    User? user = _auth.currentUser;
    if (user == null) {
      Get.snackbar("Error", "Login to comment");
      return;
    }

    try {
      // Default value jika data tidak ditemukan
      String senderName = user.email!.split('@')[0];
      String senderPhoto = "";

      // 1. Ambil Data Profil Terbaru dari Firestore 'users'
      // Menggunakan GetOptions source server agar data selalu fresh
      final userDoc = await _firestore
          .collection('users')
          .doc(user.uid)
          .get(const GetOptions(source: Source.server));

      if (userDoc.exists) {
        final userData = userDoc.data();
        if (userData != null) {
          senderName = userData['name'] ?? senderName;
          // Ambil foto profil (pastikan key 'photoUrl' sesuai dengan di ProfileController)
          senderPhoto = userData['photoUrl'] ?? "";
        }
      }

      // 2. Simpan Komentar dengan Data Profil Asli
      final commentData = {
        'userName': senderName,
        'userId': user.uid,
        'userPhoto': senderPhoto, // Simpan URL foto agar muncul di chat bubble
        'text': messageController.text.trim(),
        'timestamp': FieldValue.serverTimestamp(),
        'likes': 0,
        'movieId': selectedMovie.value!.id.toString(),
        'movieTitle': selectedMovie.value!.title,
      };

      await _firestore.collection('movie_discussions').add(commentData);
      messageController.clear();
    } catch (e) {
      Get.snackbar("Error", "Failed to send: $e");
    }
  }
}
