import 'package:cloud_firestore/cloud_firestore.dart';

class CommunityModel {
  String id;
  String userName;
  String userId;
  String text;
  String photoUrl;
  Timestamp timestamp;
  int likes;

  CommunityModel({
    this.id = '',
    required this.userName,
    required this.userId,
    required this.text,
    this.photoUrl = '',
    required this.timestamp,
    this.likes = 0,
  });

  factory CommunityModel.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;

    if (data == null) {
      return CommunityModel(
        id: doc.id,
        userName: 'Unknown',
        userId: '',
        text: 'Error loading data',
        timestamp: Timestamp.now(),
      );
    }

    String name = data['userName']?.toString() ?? 'Anonymous';

    // LOGIKA PENYELAMAT: Cek satu per satu secara manual
    String finalPhotoUrl = '';

    // 1. Cek 'userPhoto' (Format standar kita dari CommunityController)
    if (data['userPhoto'] != null && data['userPhoto'].toString().isNotEmpty) {
      finalPhotoUrl = data['userPhoto'].toString();
    }
    // 2. Cek 'photoUrl' (Format dari ProfileController atau TMDB)
    else if (data['photoUrl'] != null &&
        data['photoUrl'].toString().isNotEmpty) {
      finalPhotoUrl = data['photoUrl'].toString();
    }
    // 3. Cek 'avatar' (Format lain/legacy)
    else if (data['avatar'] != null && data['avatar'].toString().isNotEmpty) {
      finalPhotoUrl = data['avatar'].toString();
    }

    // 4. FALLBACK CERDAS: Jika tetap kosong, pakai generator avatar berdasarkan nama
    if (finalPhotoUrl.isEmpty) {
      // Menggunakan layanan UI Avatars (Gratis)
      // Ini akan membuat gambar inisial dengan warna background random
      final safeName = name.replaceAll(' ', '+'); // Ganti spasi dengan +
      finalPhotoUrl =
          'https://ui-avatars.com/api/?name=$safeName&background=random&color=fff&size=128';
    }

    // Handling Timestamp agar tidak crash
    Timestamp safeTimestamp;
    try {
      safeTimestamp = data['timestamp'] as Timestamp;
    } catch (e) {
      safeTimestamp = Timestamp.now();
    }

    return CommunityModel(
      id: doc.id,
      userName: name,
      userId: data['userId']?.toString() ?? '',
      text: data['text']?.toString() ?? '',

      // Gunakan hasil pencarian foto di atas
      photoUrl: finalPhotoUrl,

      timestamp: safeTimestamp,
      likes: int.tryParse(data['likes']?.toString() ?? '0') ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userName': userName,
      'userId': userId,
      'text': text,
      'userPhoto': photoUrl, // Konsisten simpan sebagai 'userPhoto'
      'timestamp': timestamp,
      'likes': likes,
    };
  }
}
