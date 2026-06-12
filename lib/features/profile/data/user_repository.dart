import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/app_user.dart';

class UserRepository {
  UserRepository({FirebaseAuth? firebaseAuth, FirebaseFirestore? firestore})
    : _auth = firebaseAuth ?? FirebaseAuth.instance,
      _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  String? get currentUserId => _auth.currentUser?.uid;

  Stream<AppUser?> watchCurrentUser() {
    final uid = currentUserId;

    if (uid == null) {
      return Stream.value(null);
    }

    return _firestore.collection('users').doc(uid).snapshots().map((snapshot) {
      if (!snapshot.exists) {
        return null;
      }

      return AppUser.fromFirestore(snapshot);
    });
  }

  Future<AppUser?> getCurrentUser() async {
    final uid = currentUserId;

    if (uid == null) {
      return null;
    }

    final snapshot = await _firestore.collection('users').doc(uid).get();

    if (!snapshot.exists) {
      return null;
    }

    return AppUser.fromFirestore(snapshot);
  }

  Future<void> updateCurrentUserProfile({
    required String displayName,
    required String bio,
    required String location,
  }) async {
    final uid = currentUserId;

    if (uid == null) {
      throw StateError('Kein eingeloggter Nutzer vorhanden.');
    }

    await _firestore.collection('users').doc(uid).update({
      'displayName': displayName.trim(),
      'bio': bio.trim(),
      'location': location.trim(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}
