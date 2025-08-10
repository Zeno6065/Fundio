import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Get current user stream
  Stream<User?> get userStream => _auth.authStateChanges();

  // Sign in with email and password
  Future<UserCredential> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      rethrow;
    }
  }

  // Register with email and password
  Future<UserCredential> registerWithEmailAndPassword(
    String email,
    String password,
    String username,
    String defaultCurrency,
  ) async {
    try {
      // Create user in Firebase Auth
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Create user document in Firestore
      await _createUserDocument(
        userCredential.user!.uid,
        email,
        username,
        defaultCurrency,
      );

      return userCredential;
    } catch (e) {
      rethrow;
    }
  }

  // Create user document in Firestore
  Future<void> _createUserDocument(
    String uid,
    String email,
    String username,
    String defaultCurrency,
  ) async {
    await _firestore.collection('users').doc(uid).set({
      'email': email,
      'username': username,
      'defaultCurrency': defaultCurrency,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Reset password
  Future<void> resetPassword(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  // Update user profile
  Future<void> updateUserProfile(String username, String defaultCurrency) async {
    final user = _auth.currentUser;
    if (user != null) {
      await _firestore.collection('users').doc(user.uid).update({
        'username': username,
        'defaultCurrency': defaultCurrency,
      });
    }
  }

  // Update profile with various fields
  Future<void> updateProfile({
    String? photoURL,
    String? displayName,
    String? phone,
  }) async {
    final user = _auth.currentUser;
    if (user != null) {
      final updateData = <String, dynamic>{};
      
      if (photoURL != null) updateData['photoURL'] = photoURL;
      if (displayName != null) updateData['username'] = displayName;
      if (phone != null) updateData['phone'] = phone;
      
      if (updateData.isNotEmpty) {
        await _firestore.collection('users').doc(user.uid).update(updateData);
      }
    }
  }

  // Get user data
  Future<UserModel?> getUserData() async {
    final user = _auth.currentUser;
    if (user != null) {
      final doc = await _firestore.collection('users').doc(user.uid).get();
      if (doc.exists) {
        return UserModel.fromJson(doc.data()!, doc.id);
      }
    }
    return null;
  }

  // Get user data stream
  Stream<UserModel?> getUserDataStream() {
    final user = _auth.currentUser;
    if (user != null) {
      return _firestore.collection('users').doc(user.uid).snapshots().map(
            (doc) => doc.exists ? UserModel.fromJson(doc.data()!, doc.id) : null,
          );
    }
    return Stream.value(null);
  }
}