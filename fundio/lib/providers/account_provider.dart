import 'package:flutter/material.dart';
import '../models/account_model.dart';
import '../models/invite_model.dart';
import '../services/account_service.dart';

enum AccountStatus {
  initial,
  loading,
  loaded,
  error,
}

class AccountProvider extends ChangeNotifier {
  final AccountService _accountService = AccountService();
  
  AccountStatus _status = AccountStatus.initial;
  List<AccountModel> _accounts = [];
  AccountModel? _selectedAccount;
  String? _errorMessage;

  // Getters
  AccountStatus get status => _status;
  List<AccountModel> get accounts => _accounts;
  AccountModel? get selectedAccount => _selectedAccount;
  String? get errorMessage => _errorMessage;

  // Load user accounts
  Future<void> loadUserAccounts() async {
    try {
      _status = AccountStatus.loading;
      notifyListeners();

      _accounts = await _accountService.getUserAccounts();
      _status = AccountStatus.loaded;
    } catch (e) {
      _status = AccountStatus.error;
      _errorMessage = e.toString();
    } finally {
      notifyListeners();
    }
  }

  // Select account
  void selectAccount(String accountId) {
    _selectedAccount = _accounts.firstWhere(
      (account) => account.id == accountId,
      orElse: () => _selectedAccount!,
    );
    notifyListeners();
  }

  // Create account
  Future<String> createAccount({
    required String name,
    required String description,
    required String currency,
    required double targetAmount,
    required DateTime maturityDate,
    required Map<String, dynamic> withdrawalRules,
  }) async {
    try {
      _status = AccountStatus.loading;
      notifyListeners();

      final accountId = await _accountService.createAccount(
        name: name,
        description: description,
        currency: currency,
        targetAmount: targetAmount,
        maturityDate: maturityDate,
        withdrawalRules: withdrawalRules,
      );

      // Reload accounts
      await loadUserAccounts();

      return accountId;
    } catch (e) {
      _status = AccountStatus.error;
      _errorMessage = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  // Update account
  Future<void> updateAccount(String accountId, Map<String, dynamic> data) async {
    try {
      _status = AccountStatus.loading;
      notifyListeners();

      await _accountService.updateAccount(accountId, data);

      // Reload accounts
      await loadUserAccounts();

      // Update selected account if it's the one being updated
      if (_selectedAccount != null && _selectedAccount!.id == accountId) {
        final updatedAccount = await _accountService.getAccount(accountId);
        if (updatedAccount != null) {
          _selectedAccount = updatedAccount;
        }
      }
    } catch (e) {
      _status = AccountStatus.error;
      _errorMessage = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  // Create invite
  Future<InviteModel> createInvite(String accountId) async {
    try {
      return await _accountService.createInvite(accountId);
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  // Accept invite
  Future<void> acceptInvite(String token) async {
    try {
      _status = AccountStatus.loading;
      notifyListeners();

      await _accountService.acceptInvite(token);

      // Reload accounts
      await loadUserAccounts();
    } catch (e) {
      _status = AccountStatus.error;
      _errorMessage = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  // Approve join request
  Future<void> approveJoinRequest(String accountId, String userId) async {
    try {
      await _accountService.approveJoinRequest(accountId, userId);

      // Reload selected account
      if (_selectedAccount != null && _selectedAccount!.id == accountId) {
        final updatedAccount = await _accountService.getAccount(accountId);
        if (updatedAccount != null) {
          _selectedAccount = updatedAccount;
          notifyListeners();
        }
      }
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  // Reject join request
  Future<void> rejectJoinRequest(String accountId, String userId) async {
    try {
      await _accountService.rejectJoinRequest(accountId, userId);

      // Reload selected account
      if (_selectedAccount != null && _selectedAccount!.id == accountId) {
        final updatedAccount = await _accountService.getAccount(accountId);
        if (updatedAccount != null) {
          _selectedAccount = updatedAccount;
          notifyListeners();
        }
      }
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  // Get account by ID
  Future<void> getAccountById(String accountId) async {
    try {
      _status = AccountStatus.loading;
      notifyListeners();

      final account = await _accountService.getAccount(accountId);
      if (account != null) {
        _selectedAccount = account;
      }

      _status = AccountStatus.loaded;
    } catch (e) {
      _status = AccountStatus.error;
      _errorMessage = e.toString();
    } finally {
      notifyListeners();
    }
  }

  // Clear error
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}