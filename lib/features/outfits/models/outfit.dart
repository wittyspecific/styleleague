import 'package:cloud_firestore/cloud_firestore.dart';

class Outfit {
  final String id;
  final String userId;
  final String username;
  final String displayName;
  final String caption;
  final String category;
  final String? imageUrl;
  final double averageRating;
  final int ratingCount;
  final int pointsGenerated;
  final String status;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Outfit({
    required this.id,
    required this.userId,
    required this.username,
    required this.displayName,
    required this.caption,
    required this.category,
    required this.imageUrl,
    required this.averageRating,
    required this.ratingCount,
    required this.pointsGenerated,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Outfit.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> document,
  ) {
    final data = document.data() ?? {};

    return Outfit(
      id: data['id'] as String? ?? document.id,
      userId: data['userId'] as String? ?? '',
      username: data['username'] as String? ?? '',
      displayName: data['displayName'] as String? ?? '',
      caption: data['caption'] as String? ?? '',
      category: data['category'] as String? ?? '',
      imageUrl: data['imageUrl'] as String?,
      averageRating: (data['averageRating'] as num?)?.toDouble() ?? 0.0,
      ratingCount: data['ratingCount'] as int? ?? 0,
      pointsGenerated: data['pointsGenerated'] as int? ?? 0,
      status: data['status'] as String? ?? 'active',
      createdAt: _timestampToDateTime(data['createdAt']),
      updatedAt: _timestampToDateTime(data['updatedAt']),
    );
  }

  static DateTime? _timestampToDateTime(dynamic value) {
    if (value is Timestamp) {
      return value.toDate();
    }

    return null;
  }
}
