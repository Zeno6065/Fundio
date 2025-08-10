import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';
import '../models/account_model.dart';
import '../models/invite_model.dart';

class AccountService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final Uuid _uuid = const Uuid();

  // Create a new account
  Future<String> createAccount({
    required String name,
    required String description,
    required String currency,
    required double targetAmount,
    required DateTime maturityDate,
    required Map<String, dynamic> withdrawalRules,
  }) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('User not authenticated');
    }

    final accountRef = _firestore.collection('accounts').doc();
    
    final account = {
      'name': name,
      'description': description,
      'adminId': user.uid,
      'currency': currency,
      'targetAmount': targetAmount,
      'maturityDate': maturityDate,
      'withdrawalRules': withdrawalRules,
      'members': [user.uid],
      'pendingRequests': [],
      'createdAt': FieldValue.serverTimestamp(),
    };

    await accountRef.set(account);
    return accountRef.id;
  }

  // Get account by ID
  Future<AccountModel?> getAccount(String accountId) async {
    final doc = await _firestore.collection('accounts').doc(accountId).get();
    if (doc.exists) {
      return AccountModel.fromJson(doc.data()!, doc.id);
    }
    return null;
  }

  // Get account stream
  Stream<AccountModel?> getAccountStream(String accountId) {
    return _firestore.collection('accounts').doc(accountId).snapshots().map(
          (doc) => doc.exists ? AccountModel.fromJson(doc.data()!, doc.id) : null,
        );
  }

  // Get user's accounts
  Future<List<AccountModel>> getUserAccounts() async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('User not authenticated');
    }

    final querySnapshot = await _firestore
        .collection('accounts')
        .where('members', arrayContains: user.uid)
        .get();

    return querySnapshot.docs
        .map((doc) => AccountModel.fromJson(doc.data(), doc.id))
        .toList();
  }

  // Get user's accounts stream
  Stream<List<AccountModel>> getUserAccountsStream() {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('User not authenticated');
    }

    return _firestore
        .collection('accounts')
        .where('members', arrayContains: user.uid)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => AccountModel.fromJson(doc.data(), doc.id))
            .toList());
  }

  // Update account
  Future<void> updateAccount(String accountId, Map<String, dynamic> data) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('User not authenticated');
    }

    final accountDoc = await _firestore.collection('accounts').doc(accountId).get();
    if (!accountDoc.exists) {
      throw Exception('Account not found');
    }

    final account = AccountModel.fromJson(accountDoc.data()!, accountDoc.id);
    if (account.adminId != user.uid) {
      throw Exception('Only the admin can update the account');
    }

    await _firestore.collection('accounts').doc(accountId).update(data);
  }

  // Create invite
  Future<InviteModel> createInvite(String accountId) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('User not authenticated');
    }

    final accountDoc = await _firestore.collection('accounts').doc(accountId).get();
    if (!accountDoc.exists) {
      throw Exception('Account not found');
    }

    final account = AccountModel.fromJson(accountDoc.data()!, accountDoc.id);
    if (!account.members.contains(user.uid)) {
      throw Exception('You are not a member of this account');
    }

    final token = _uuid.v4();
    final expiresAt = DateTime.now().add(const Duration(days: 7));

    final inviteRef = _firestore.collection('invites').doc();
    final invite = {
      'accountId': accountId,
      'token': token,
      'expiresAt': expiresAt,
      'createdBy': user.uid,
      'createdAt': FieldValue.serverTimestamp(),
    };

    await inviteRef.set(invite);

    return InviteModel(
      id: inviteRef.id,
      accountId: accountId,
      token: token,
      expiresAt: expiresAt,
      createdBy: user.uid,
      createdAt: DateTime.now(),
    );
  }

  // Get invite by token
  Future<InviteModel?> getInviteByToken(String token) async {
    final querySnapshot = await _firestore
        .collection('invites')
        .where('token', isEqualTo: token)
        .limit(1)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      return InviteModel.fromJson(
        querySnapshot.docs.first.data(),
        querySnapshot.docs.first.id,
      );
    }

    return null;
  }

  // Accept invite
  Future<void> acceptInvite(String token) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('User not authenticated');
    }

    final invite = await getInviteByToken(token);
    if (invite == null) {
      throw Exception('Invalid invite token');
    }

    if (invite.isExpired) {
      throw Exception('Invite has expired');
    }

    final accountDoc = await _firestore.collection('accounts').doc(invite.accountId).get();
    if (!accountDoc.exists) {
      throw Exception('Account not found');
    }

    final account = AccountModel.fromJson(accountDoc.data()!, accountDoc.id);
    if (account.members.contains(user.uid)) {
      throw Exception('You are already a member of this account');
    }

    // Add pending request
    final pendingRequest = PendingRequest(
      userId: user.uid,
      requestedAt: DateTime.now(),
      status: 'pending',
    );

    await _firestore.collection('accounts').doc(invite.accountId).update({
      'pendingRequests': FieldValue.arrayUnion([pendingRequest.toJson()]),
    });
  }

  // Approve join request
  Future<void> approveJoinRequest(String accountId, String userId) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('User not authenticated');
    }

    final accountDoc = await _firestore.collection('accounts').doc(accountId).get();
    if (!accountDoc.exists) {
      throw Exception('Account not found');
    }

    final account = AccountModel.fromJson(accountDoc.data()!, accountDoc.id);
    if (account.adminId != user.uid) {
      throw Exception('Only the admin can approve join requests');
    }

    // Find the pending request
    final pendingRequests = account.pendingRequests;
    final requestIndex = pendingRequests.indexWhere((req) => req.userId == userId);

    if (requestIndex == -1) {
      throw Exception('Join request not found');
    }

    // Update the request status
    pendingRequests[requestIndex] = PendingRequest(
      userId: userId,
      requestedAt: pendingRequests[requestIndex].requestedAt,
      status: 'approved',
    );

    // Add user to members and update pending requests
    await _firestore.collection('accounts').doc(accountId).update({
      'members': FieldValue.arrayUnion([userId]),
      'pendingRequests': pendingRequests.map((req) => req.toJson()).toList(),
    });
  }

  // Reject join request
  Future<void> rejectJoinRequest(String accountId, String userId) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('User not authenticated');
    }

    final accountDoc = await _firestore.collection('accounts').doc(accountId).get();
    if (!accountDoc.exists) {
      throw Exception('Account not found');
    }

    final account = AccountModel.fromJson(accountDoc.data()!, accountDoc.id);
    if (account.adminId != user.uid) {
      throw Exception('Only the admin can reject join requests');
    }

    // Find the pending request
    final pendingRequests = account.pendingRequests;
    final requestIndex = pendingRequests.indexWhere((req) => req.userId == userId);

    if (requestIndex == -1) {
      throw Exception('Join request not found');
    }

    // Update the request status
    pendingRequests[requestIndex] = PendingRequest(
      userId: userId,
      requestedAt: pendingRequests[requestIndex].requestedAt,
      status: 'rejected',
    );

    // Update pending requests
    await _firestore.collection('accounts').doc(accountId).update({
      'pendingRequests': pendingRequests.map((req) => req.toJson()).toList(),
    });
  }
}