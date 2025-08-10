import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/withdrawal_model.dart';
import '../models/account_model.dart';

class WithdrawalService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Create a new withdrawal request
  Future<String> createWithdrawalRequest({
    required String accountId,
    required double amount,
    required String currency,
    required String paymentMethod,
    required String paymentDetails,
    String? reason,
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

    final account = AccountModel.fromJson(accountDoc.data()!, accountDoc.id);
    if (!account.members.contains(user.uid)) {
      throw Exception('You are not a member of this account');
    }

    // Check if withdrawal is allowed based on account rules
    _validateWithdrawalRequest(account, amount);

    final withdrawalRef = _firestore.collection('withdrawals').doc();
    
    final withdrawal = {
      'accountId': accountId,
      'userId': user.uid,
      'amount': amount,
      'currency': currency,
      'paymentMethod': paymentMethod,
      'paymentDetails': paymentDetails,
      'reason': reason,
      'status': 'pending',
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };

    await withdrawalRef.set(withdrawal);
    return withdrawalRef.id;
  }

  // Validate withdrawal request against account rules
  void _validateWithdrawalRequest(AccountModel account, double amount) {
    // Check if maturity date has passed
    if (account.withdrawalRules['onlyAfterMaturity'] == true && 
        DateTime.now().isBefore(account.maturityDate)) {
      throw Exception('Withdrawals are only allowed after the maturity date');
    }

    // Check if target amount has been reached
    if (account.withdrawalRules['onlyAfterTargetReached'] == true) {
      // In a real app, you would calculate the total deposits here
      // For simplicity, we're assuming the account has a currentAmount field
      final currentAmount = account.withdrawalRules['currentAmount'] ?? 0.0;
      if (currentAmount < account.targetAmount) {
        throw Exception('Withdrawals are only allowed after the target amount is reached');
      }
    }

    // Check if amount is within allowed percentage
    if (account.withdrawalRules['maxPercentagePerWithdrawal'] != null) {
      final maxPercentage = account.withdrawalRules['maxPercentagePerWithdrawal'] as double;
      final currentAmount = account.withdrawalRules['currentAmount'] ?? 0.0;
      final maxAllowedAmount = currentAmount * (maxPercentage / 100);
      
      if (amount > maxAllowedAmount) {
        throw Exception('Withdrawal amount exceeds the maximum allowed percentage');
      }
    }
  }

  // Get withdrawal by ID
  Future<WithdrawalModel?> getWithdrawal(String withdrawalId) async {
    final doc = await _firestore.collection('withdrawals').doc(withdrawalId).get();
    if (doc.exists) {
      return WithdrawalModel.fromJson(doc.data()!, doc.id);
    }
    return null;
  }

  // Get withdrawals for an account
  Future<List<WithdrawalModel>> getAccountWithdrawals(String accountId) async {
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
        .collection('withdrawals')
        .where('accountId', isEqualTo: accountId)
        .orderBy('createdAt', descending: true)
        .get();

    return querySnapshot.docs
        .map((doc) => WithdrawalModel.fromJson(doc.data(), doc.id))
        .toList();
  }

  // Get withdrawals for an account stream
  Stream<List<WithdrawalModel>> getAccountWithdrawalsStream(String accountId) {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('User not authenticated');
    }

    return _firestore
        .collection('withdrawals')
        .where('accountId', isEqualTo: accountId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => WithdrawalModel.fromJson(doc.data(), doc.id))
            .toList());
  }

  // Get user's withdrawals
  Future<List<WithdrawalModel>> getUserWithdrawals() async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('User not authenticated');
    }

    final querySnapshot = await _firestore
        .collection('withdrawals')
        .where('userId', isEqualTo: user.uid)
        .orderBy('createdAt', descending: true)
        .get();

    return querySnapshot.docs
        .map((doc) => WithdrawalModel.fromJson(doc.data(), doc.id))
        .toList();
  }

  // Approve withdrawal (admin only)
  Future<void> approveWithdrawal(String withdrawalId) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('User not authenticated');
    }

    final withdrawalDoc = await _firestore.collection('withdrawals').doc(withdrawalId).get();
    if (!withdrawalDoc.exists) {
      throw Exception('Withdrawal not found');
    }

    final withdrawal = WithdrawalModel.fromJson(withdrawalDoc.data()!, withdrawalDoc.id);
    
    // Verify account exists and user is an admin
    final accountDoc = await _firestore.collection('accounts').doc(withdrawal.accountId).get();
    if (!accountDoc.exists) {
      throw Exception('Account not found');
    }

    final adminId = accountDoc.data()?['adminId'];
    if (adminId != user.uid) {
      throw Exception('Only the admin can approve withdrawals');
    }

    await _firestore.collection('withdrawals').doc(withdrawalId).update({
      'status': 'approved',
      'adminNotes': 'Approved by admin',
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // Reject withdrawal (admin only)
  Future<void> rejectWithdrawal(String withdrawalId, String reason) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('User not authenticated');
    }

    final withdrawalDoc = await _firestore.collection('withdrawals').doc(withdrawalId).get();
    if (!withdrawalDoc.exists) {
      throw Exception('Withdrawal not found');
    }

    final withdrawal = WithdrawalModel.fromJson(withdrawalDoc.data()!, withdrawalDoc.id);
    
    // Verify account exists and user is an admin
    final accountDoc = await _firestore.collection('accounts').doc(withdrawal.accountId).get();
    if (!accountDoc.exists) {
      throw Exception('Account not found');
    }

    final adminId = accountDoc.data()?['adminId'];
    if (adminId != user.uid) {
      throw Exception('Only the admin can reject withdrawals');
    }

    await _firestore.collection('withdrawals').doc(withdrawalId).update({
      'status': 'rejected',
      'adminNotes': reason,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // Mark withdrawal as completed (admin only)
  Future<void> completeWithdrawal(String withdrawalId) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('User not authenticated');
    }

    final withdrawalDoc = await _firestore.collection('withdrawals').doc(withdrawalId).get();
    if (!withdrawalDoc.exists) {
      throw Exception('Withdrawal not found');
    }

    final withdrawal = WithdrawalModel.fromJson(withdrawalDoc.data()!, withdrawalDoc.id);
    
    // Verify account exists and user is an admin
    final accountDoc = await _firestore.collection('accounts').doc(withdrawal.accountId).get();
    if (!accountDoc.exists) {
      throw Exception('Account not found');
    }

    final adminId = accountDoc.data()?['adminId'];
    if (adminId != user.uid) {
      throw Exception('Only the admin can mark withdrawals as completed');
    }

    // Check if withdrawal is approved
    if (withdrawal.status != 'approved') {
      throw Exception('Only approved withdrawals can be marked as completed');
    }

    await _firestore.collection('withdrawals').doc(withdrawalId).update({
      'status': 'completed',
      'adminNotes': 'Marked as completed by admin',
      'completedAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // Get total approved and completed withdrawals for an account
  Future<double> getTotalWithdrawals(String accountId) async {
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
        .collection('withdrawals')
        .where('accountId', isEqualTo: accountId)
        .where('status', whereIn: ['approved', 'completed'])
        .get();

    double total = 0;
    for (final doc in querySnapshot.docs) {
      final withdrawal = WithdrawalModel.fromJson(doc.data(), doc.id);
      // Note: In a real app, you would need to handle currency conversion
      total += withdrawal.amount;
    }

    return total;
  }

  // Get total completed withdrawals for an account
  Future<double> getTotalCompletedWithdrawals(String accountId) async {
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
        .collection('withdrawals')
        .where('accountId', isEqualTo: accountId)
        .where('status', isEqualTo: 'completed')
        .get();

    double total = 0;
    for (final doc in querySnapshot.docs) {
      final withdrawal = WithdrawalModel.fromJson(doc.data(), doc.id);
      // Note: In a real app, you would need to handle currency conversion
      total += withdrawal.amount;
    }

    return total;
  }
}