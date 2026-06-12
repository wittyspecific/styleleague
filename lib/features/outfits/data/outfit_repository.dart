import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/outfit.dart';

class OutfitRepository {
  OutfitRepository({FirebaseAuth? firebaseAuth, FirebaseFirestore? firestore})
    : _auth = firebaseAuth ?? FirebaseAuth.instance,
      _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  Future<String> createOutfit({
    required String caption,
    required String category,
  }) async {
    final uid = _auth.currentUser?.uid;

    if (uid == null) {
      throw StateError('Kein eingeloggter Nutzer vorhanden.');
    }

    final normalizedCaption = caption.trim();
    final normalizedCategory = category.trim();

    if (normalizedCaption.isEmpty) {
      throw const FormatException('Die Beschreibung darf nicht leer sein.');
    }

    if (normalizedCaption.length > 150) {
      throw const FormatException(
        'Die Beschreibung darf maximal 150 Zeichen enthalten.',
      );
    }

    if (normalizedCategory.isEmpty) {
      throw const FormatException('Eine Kategorie muss ausgewählt werden.');
    }

    final userRef = _firestore.collection('users').doc(uid);
    final outfitRef = _firestore.collection('outfits').doc();

    await _firestore.runTransaction((transaction) async {
      final userSnapshot = await transaction.get(userRef);

      if (!userSnapshot.exists) {
        throw StateError('Das Nutzerprofil wurde nicht gefunden.');
      }

      final userData = userSnapshot.data() ?? {};

      final username = userData['username'] as String? ?? '';
      final displayName = userData['displayName'] as String? ?? username;

      transaction.set(outfitRef, {
        'id': outfitRef.id,
        'userId': uid,
        'username': username,
        'displayName': displayName,
        'caption': normalizedCaption,
        'category': normalizedCategory,
        'imageUrl': null,
        'averageRating': 0.0,
        'ratingCount': 0,
        'pointsGenerated': 0,
        'status': 'active',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      transaction.update(userRef, {
        'outfitCount': FieldValue.increment(1),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    });

    return outfitRef.id;
  }

  Stream<List<Outfit>> watchLatestOutfits({int limit = 20}) {
    return _firestore
        .collection('outfits')
        .where('status', isEqualTo: 'active')
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map(Outfit.fromFirestore).toList();
        });
  }
}
