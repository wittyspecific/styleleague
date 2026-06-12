import 'package:cloud_firestore/cloud_firestore.dart';

class AppUser {
  final String id;
  final String email;
  final String username;
  final String displayName;
  final String bio;
  final String location;
  final String? profileImageUrl;
  final String? coverImageUrl;
  final int points;
  final String level;
  final int? rank;
  final int outfitCount;
  final int followerCount;
  final int followingCount;
  final String role;
  final String status;
  final String authProvider;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? lastActiveAt;

  const AppUser({
    required this.id,
    required this.email,
    required this.username,
    required this.displayName,
    required this.bio,
    required this.location,
    required this.profileImageUrl,
    required this.coverImageUrl,
    required this.points,
    required this.level,
    required this.rank,
    required this.outfitCount,
    required this.followerCount,
    required this.followingCount,
    required this.role,
    required this.status,
    required this.authProvider,
    required this.createdAt,
    required this.updatedAt,
    required this.lastActiveAt,
  });

  factory AppUser.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> document,
  ) {
    final data = document.data() ?? {};

    return AppUser(
      id: data['id'] as String? ?? document.id,
      email: data['email'] as String? ?? '',
      username: data['username'] as String? ?? '',
      displayName: data['displayName'] as String? ?? '',
      bio: data['bio'] as String? ?? '',
      location: data['location'] as String? ?? '',
      profileImageUrl: data['profileImageUrl'] as String?,
      coverImageUrl: data['coverImageUrl'] as String?,
      points: data['points'] as int? ?? 0,
      level: data['level'] as String? ?? 'bronze',
      rank: data['rank'] as int?,
      outfitCount: data['outfitCount'] as int? ?? 0,
      followerCount: data['followerCount'] as int? ?? 0,
      followingCount: data['followingCount'] as int? ?? 0,
      role: data['role'] as String? ?? 'user',
      status: data['status'] as String? ?? 'active',
      authProvider: data['authProvider'] as String? ?? 'password',
      createdAt: _timestampToDateTime(data['createdAt']),
      updatedAt: _timestampToDateTime(data['updatedAt']),
      lastActiveAt: _timestampToDateTime(data['lastActiveAt']),
    );
  }

  static DateTime? _timestampToDateTime(dynamic value) {
    if (value is Timestamp) {
      return value.toDate();
    }

    return null;
  }
}
