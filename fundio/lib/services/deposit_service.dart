import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/deposit_model.dart';

class DepositService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Create a new deposit
  Future<String> createDeposit({
    required String accountId,
    required double amount,
    required String currency,
    required String paymentMethod,
    String? notes,
  }) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('User not authenticated');
    }

    // Verify account exists and user is a member
    final accountDoc = await _firestore.collection('accounts').doc(accountId).get();
    if (!accountDoc.exists) {
      throw Exception('Account not found');
    }

    final members = List<String>.from(accountDoc.data()?['members'] ?? []);
    if (!members.contains(user.uid)) {
      throw Exception('You are not a member of this account');
    }

    final depositRef = _firestore.collection('deposits').doc();
    
    final deposit = {
      'accountId': accountId,
      'userId': user.uid,
      'amount': amount,
      'currency': currency,
      'paymentMethod': paymentMethod,
      'notes': notes,
      'status': 'pending',
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };

    await depositRef.set(deposit);
    return depositRef.id;
  }

  // Get deposit by ID
  Future<DepositModel?> getDeposit(String depositId) async {
    final doc = await _firestore.collection('deposits').doc(depositId).get();
    if (doc.exists) {
      return DepositModel.fromJson(doc.data()!, doc.id);
    }
    return null;
  }

  // Get deposits for an account
  Future<List<DepositModel>> getAccountDeposits(String accountId) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('User not authenticated');
    }

    // Verify account exists and user is a member
    final accountDoc = await _firestore.collection('accounts').doc(accountId).get();
    if (!accountDoc.exists) {
      throw Exception('Account not found');
    }

    final members = List<String>.from(accountDoc.data()?['members'] ?? []);
    if (!members.contains(user.uid)) {
      throw Exception('You are not a member of this account');
    }

    final querySnapshot = await _firestore
        .collection('deposits')
        .where('accountId', isEqualTo: accountId)
        .orderBy('createdAt', descending: true)
        .get();

    return querySnapshot.docs
        .map((doc) => DepositModel.fromJson(doc.data(), doc.id))
        .toList();
  }

  // Get deposits for an account stream
  Stream<List<DepositModel>> getAccountDepositsStream(String accountId) {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('User not authenticated');
    }

    return _firestore
        .collection('deposits')
        .where('accountId', isEqualTo: accountId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => DepositModel.fromJson(doc.data(), doc.id))
            .toList());
  }

  // Get user's deposits
  Future<List<DepositModel>> getUserDeposits() async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('User not authenticated');
    }

    final querySnapshot = await _firestore
        .collection('deposits')
        .where('userId', isEqualTo: user.uid)
        .orderBy('createdAt', descending: true)
        .get();

    return querySnapshot.docs
        .map((doc) => DepositModel.fromJson(doc.data(), doc.id))
        .toList();
  }

  // Approve deposit (admin only)
  Future<void> approveDeposit(String depositId) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('User not authenticated');
    }

    final depositDoc = await _firestore.collection('deposits').doc(depositId).get();
    if (!depositDoc.exists) {
      throw Exception('Deposit not found');
    }

    final deposit = DepositModel.fromJson(depositDoc.data()!, depositDoc.id);
    
    // Verify account exists and user is an admin
    final accountDoc = await _firestore.collection('accounts').doc(deposit.accountId).get();
    if (!accountDoc.exists) {
      throw Exception('Account not found');
    }

    final adminId = accountDoc.data()?['adminId'];
    if (adminId != user.uid) {
      throw Exception('Only the admin can approve deposits');
    }

    await _firestore.collection('deposits').doc(depositId).update({
      'status': 'approved',
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // Reject deposit (admin only)
  Future<void> rejectDeposit(String depositId, String reason) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('User not authenticated');
    }

    final depositDoc = await _firestore.collection('deposits').doc(depositId).get();
    if (!depositDoc.exists) {
      throw Exception('Deposit not found');
    }

    final deposit = DepositModel.fromJson(depositDoc.data()!, depositDoc.id);
    
    // Verify account exists and user is an admin
    final accountDoc = await _firestore.collection('accounts').doc(deposit.accountId).get();
    if (!accountDoc.exists) {
      throw Exception('Account not found');
    }

    final adminId = accountDoc.data()?['adminId'];
    if (adminId != user.uid) {
      throw Exception('Only the admin can reject deposits');
    }

    await _firestore.collection('deposits').doc(depositId).update({
      'status': 'rejected',
      'rejectionReason': reason,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // Get total approved deposits for an account
  Future<double> getTotalApprovedDeposits(String accountId) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('User not authenticated');
    }

    // Verify account exists and user is a member
    final accountDoc = await _firestore.collection('accounts').doc(accountId).get();
    if (!accountDoc.exists) {
      throw Exception('Account not found');
    }

    final members = List<String>.from(accountDoc.data()?['members'] ?? []);
    if (!members.contains(user.uid)) {
      throw Exception('You are not a member of this account');
    }

    final querySnapshot = await _firestore
        .collection('deposits')
        .where('accountId', isEqualTo: accountId)
        .where('status', isEqualTo: 'approved')
        .get();

    double total = 0;
    for (final doc in querySnapshot.docs) {
      final deposit = DepositModel.fromJson(doc.data(), doc.id);
      // Note: In a real app, you would need to handle currency conversion
      total += deposit.amount;
    }

    return total;
  }

  // Get user contribution percentage for an account
  Future<Map<String, double>> getUserContributionPercentages(String accountId) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('User not authenticated');
    }

    // Verify account exists and user is a member
    final accountDoc = await _firestore.collection('accounts').doc(accountId).get();
    if (!accountDoc.exists) {
      throw Exception('Account not found');
    }

    final members = List<String>.from(accountDoc.data()?['members'] ?? []);
    if (!members.contains(user.uid)) {
      throw Exception('You are not a member of this account');
    }

    final querySnapshot = await _firestore
        .collection('deposits')
        .where('accountId', isEqualTo: accountId)
        .where('status', isEqualTo: 'approved')
        .get();

    // Calculate total deposits and user contributions
    double total = 0;
    Map<String, double> userContributions = {};

    for (final doc in querySnapshot.docs) {
      final deposit = DepositModel.fromJson(doc.data(), doc.id);
      total += deposit.amount;

      if (userContributions.containsKey(deposit.userId)) {
        userContributions[deposit.userId] = 
            (userContributions[deposit.userId] ?? 0) + deposit.amount;
      } else {
        userContributions[deposit.userId] = deposit.amount;
      }
    }

    // Calculate percentages
    Map<String, double> percentages = {};
    if (total > 0) {
      userContributions.forEach((userId, amount) {
        percentages[userId] = (amount / total) * 100;
      });
    }

    return percentages;
  }
}