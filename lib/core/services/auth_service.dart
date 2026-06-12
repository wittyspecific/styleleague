import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

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
      await _createUserProfile(
        user: user,
        username: normalizedUsername,
        email: email.trim(),
        displayName: normalizedUsername,
        profileImageUrl: null,
      );

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
      await _updateLastActive(user.uid);
    }
  }

  Future<void> signInWithGoogle() async {
    UserCredential credential;

    if (kIsWeb) {
      final googleProvider = GoogleAuthProvider();
      credential = await _auth.signInWithPopup(googleProvider);
    } else {
      final googleUser = await GoogleSignIn.instance.authenticate();
      final googleAuth = googleUser.authentication;

      final googleCredential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );

      credential = await _auth.signInWithCredential(googleCredential);
    }

    final user = credential.user;

    if (user == null) {
      throw FirebaseAuthException(
        code: 'google-user-not-found',
        message: 'Google-Nutzer konnte nicht geladen werden.',
      );
    }

    await _ensureGoogleUserProfile(user);
  }

  Future<void> logout() async {
    if (!kIsWeb) {
      await GoogleSignIn.instance.signOut();
    }

    await _auth.signOut();
  }

  Future<void> _ensureGoogleUserProfile(User user) async {
    final userRef = _firestore.collection('users').doc(user.uid);
    final userSnapshot = await userRef.get();

    if (userSnapshot.exists) {
      await _updateLastActive(user.uid);
      return;
    }

    final generatedUsername = _generateGoogleUsername(user);

    await _createUserProfile(
      user: user,
      username: generatedUsername,
      email: user.email ?? '',
      displayName: user.displayName ?? generatedUsername,
      profileImageUrl: user.photoURL,
    );
  }

  Future<void> _createUserProfile({
    required User user,
    required String username,
    required String email,
    required String displayName,
    required String? profileImageUrl,
  }) async {
    final userRef = _firestore.collection('users').doc(user.uid);
    final usernameRef = _firestore.collection('usernames').doc(username);

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
        'email': email,
        'username': username,
        'displayName': displayName,
        'profileImageUrl': profileImageUrl,
        'bio': '',
        'points': 0,
        'rank': null,
        'role': 'user',
        'status': 'active',
        'createdAt': FieldValue.serverTimestamp(),
        'lastActiveAt': FieldValue.serverTimestamp(),
        'authProvider': user.providerData.isNotEmpty
            ? user.providerData.first.providerId
            : 'password',
      });
    });
  }

  Future<void> _updateLastActive(String uid) async {
    await _firestore.collection('users').doc(uid).update({
      'lastActiveAt': FieldValue.serverTimestamp(),
    });
  }

  String _normalizeUsername(String username) {
    final normalized = username.trim().toLowerCase();

    final isValid = RegExp(r'^[a-z0-9._]{3,20}$').hasMatch(normalized);

    if (!isValid) {
      throw const FormatException(
        'Der Benutzername darf nur Kleinbuchstaben, Zahlen, Punkte und Unterstriche enthalten.',
      );
    }

    return normalized;
  }

  String _generateGoogleUsername(User user) {
    final source = user.displayName ?? user.email?.split('@').first ?? 'user';

    var base = source
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9._]'), '')
        .replaceAll(RegExp(r'[._]{2,}'), '.');

    if (base.length < 3) {
      base = 'user';
    }

    final cleanedUid = user.uid
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]'), '');

    final suffix = cleanedUid.length >= 6
        ? cleanedUid.substring(0, 6)
        : cleanedUid.padRight(6, 'x');

    final maxBaseLength = 20 - suffix.length - 1;

    if (base.length > maxBaseLength) {
      base = base.substring(0, maxBaseLength);
    }

    return '${base}_$suffix';
  }
}