import 'package:cloud_firestore/cloud_firestore.dart';

class CommunityModel {
  String id;
  String userName;
  String userId;
  String text;
  Timestamp timestamp; // Waktu posting
  int likes;

  CommunityModel({
    this.id = '',
    required this.userName,
    required this.userId,
    required this.text,
    required this.timestamp,
    this.likes = 0,
  });

  // Dari Firestore ke Aplikasi
  factory CommunityModel.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CommunityModel(
      id: doc.id,
      userName: data['userName'] ?? 'Anonymous',
      userId: data['userId'] ?? '',
      text: data['text'] ?? '',
      timestamp: data['timestamp'] ?? Timestamp.now(),
      likes: data['likes'] ?? 0,
    );
  }

  // Dari Aplikasi ke Firestore
  Map<String, dynamic> toMap() {
    return {
      'userName': userName,
      'userId': userId,
      'text': text,
      'timestamp': timestamp,
      'likes': likes,
    };
  }
}
