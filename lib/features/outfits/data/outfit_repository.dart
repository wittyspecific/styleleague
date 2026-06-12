import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../models/outfit.dart';

class OutfitRepository {
  OutfitRepository({
    FirebaseAuth? firebaseAuth,
    FirebaseFirestore? firestore,
    FirebaseStorage? storage,
  }) : _auth = firebaseAuth ?? FirebaseAuth.instance,
       _firestore = firestore ?? FirebaseFirestore.instance,
       _storage = storage ?? FirebaseStorage.instance;

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;

  Future<String> createOutfit({
    required String caption,
    required String category,
    required Uint8List imageBytes,
    required String imageExtension,
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

    if (imageBytes.isEmpty) {
      throw const FormatException('Ein Bild muss ausgewählt werden.');
    }

    if (imageBytes.length > 5 * 1024 * 1024) {
      throw const FormatException('Das Bild darf maximal 5 MB groß sein.');
    }

    final userRef = _firestore.collection('users').doc(uid);
    final outfitRef = _firestore.collection('outfits').doc();

    final extension = _normalizeImageExtension(imageExtension);
    final contentType = _contentTypeForExtension(extension);

    final storageRef = _storage.ref().child(
      'outfits/$uid/${outfitRef.id}.$extension',
    );

    final uploadTask = await storageRef.putData(
      imageBytes,
      SettableMetadata(contentType: contentType),
    );

    final imageUrl = await uploadTask.ref.getDownloadURL();

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
        'imageUrl': imageUrl,
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
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map(Outfit.fromFirestore)
              .where((outfit) => outfit.status == 'active')
              .toList();
        });
  }

  String _normalizeImageExtension(String extension) {
    final normalized = extension.toLowerCase().replaceAll('.', '').trim();

    switch (normalized) {
      case 'png':
        return 'png';
      case 'webp':
        return 'webp';
      case 'jpeg':
      case 'jpg':
        return 'jpg';
      default:
        return 'jpg';
    }
  }

  String _contentTypeForExtension(String extension) {
    switch (extension) {
      case 'png':
        return 'image/png';
      case 'webp':
        return 'image/webp';
      case 'jpg':
      default:
        return 'image/jpeg';
    }
  }
}
