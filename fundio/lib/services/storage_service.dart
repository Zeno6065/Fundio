import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final Uuid _uuid = const Uuid();

  // Upload profile image
  Future<String> uploadProfileImage(File file) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('User not authenticated');
    }

    final fileExtension = file.path.split('.').last;
    final fileName = '${user.uid}_${DateTime.now().millisecondsSinceEpoch}.$fileExtension';
    final storageRef = _storage.ref().child('profile_images/$fileName');

    final uploadTask = storageRef.putFile(file);
    final snapshot = await uploadTask.whenComplete(() {});
    final downloadUrl = await snapshot.ref.getDownloadURL();

    return downloadUrl;
  }

  // Upload account image
  Future<String> uploadAccountImage(String accountId, File file) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('User not authenticated');
    }

    final fileExtension = file.path.split('.').last;
    final fileName = '${accountId}_${DateTime.now().millisecondsSinceEpoch}.$fileExtension';
    final storageRef = _storage.ref().child('account_images/$fileName');

    final uploadTask = storageRef.putFile(file);
    final snapshot = await uploadTask.whenComplete(() {});
    final downloadUrl = await snapshot.ref.getDownloadURL();

    return downloadUrl;
  }

  // Upload deposit receipt
  Future<String> uploadDepositReceipt(String depositId, File file) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('User not authenticated');
    }

    final fileExtension = file.path.split('.').last;
    final fileName = '${depositId}_${DateTime.now().millisecondsSinceEpoch}.$fileExtension';
    final storageRef = _storage.ref().child('deposit_receipts/$fileName');

    final uploadTask = storageRef.putFile(file);
    final snapshot = await uploadTask.whenComplete(() {});
    final downloadUrl = await snapshot.ref.getDownloadURL();

    return downloadUrl;
  }

  // Delete file by URL
  Future<void> deleteFile(String fileUrl) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('User not authenticated');
    }

    try {
      // Extract the path from the URL
      final ref = _storage.refFromURL(fileUrl);
      await ref.delete();
    } catch (e) {
      throw Exception('Failed to delete file: $e');
    }
  }

  // Generate a signed URL with expiration
  Future<String> getSignedUrl(String fileUrl, {Duration expiration = const Duration(hours: 1)}) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('User not authenticated');
    }

    try {
      final ref = _storage.refFromURL(fileUrl);
      final signedUrl = await ref.getDownloadURL();
      return signedUrl;
    } catch (e) {
      throw Exception('Failed to generate signed URL: $e');
    }
  }
}