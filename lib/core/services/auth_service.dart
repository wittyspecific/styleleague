import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UsernameTakenException implements Exception {}

class AuthService {
  AuthService({
    FirebaseAuth? firebaseAuth,
    FirebaseFirestore? firestore,
  })  : _auth = firebaseAuth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  Future<void> registerWithEmail({
    required String email,
    required String password,
    required String username,
  }) async {
    final normalizedUsername = _normalizeUsername(username);

    final credential = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );

    final user = credential.user;

    if (user == null) {
      throw FirebaseAuthException(
        code: 'user-not-created',
        message: 'Der Nutzer konnte nicht erstellt werden.',
      );
    }

    try {
      final userRef = _firestore.collection('users').doc(user.uid);
      final usernameRef =
          _firestore.collection('usernames').doc(normalizedUsername);

      await _firestore.runTransaction((transaction) async {
        final usernameSnapshot = await transaction.get(usernameRef);

        if (usernameSnapshot.exists) {
          throw UsernameTakenException();
        }

        transaction.set(usernameRef, {
          'uid': user.uid,
          'createdAt': FieldValue.serverTimestamp(),
        });

        transaction.set(userRef, {
          'id': user.uid,
          'email': email.trim(),
          'username': normalizedUsername,
          'displayName': normalizedUsername,
          'profileImageUrl': null,
          'bio': '',
          'points': 0,
          'rank': null,
          'role': 'user',
          'status': 'active',
          'createdAt': FieldValue.serverTimestamp(),
          'lastActiveAt': FieldValue.serverTimestamp(),
        });
      });

      await user.updateDisplayName(normalizedUsername);
    } catch (error) {
      await user.delete();
      rethrow;
    }
  }

  Future<void> loginWithEmail({
    required String email,
    required String password,
  }) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );

    final user = credential.user;

    if (user != null) {
      await _firestore.collection('users').doc(user.uid).update({
        'lastActiveAt': FieldValue.serverTimestamp(),
      });
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
  }

  String _normalizeUsername(String username) {
    final normalized = username.trim().toLowerCase();

    final isValid = RegExp(r'^[a-z0-9._]{3,20}$').hasMatch(normalized);

    if (!isValid) {
      throw FormatException(
        'Der Benutzername darf nur Kleinbuchstaben, Zahlen, Punkte und Unterstriche enthalten.',
      );
    }

    return normalized;
  }
}