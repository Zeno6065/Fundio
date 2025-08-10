import 'package:flutter/material.dart';
import '../models/withdrawal_model.dart';
import '../services/withdrawal_service.dart';

enum WithdrawalStatus {
  initial,
  loading,
  loaded,
  error,
}

class WithdrawalProvider extends ChangeNotifier {
  final WithdrawalService _withdrawalService = WithdrawalService();
  
  WithdrawalStatus _status = WithdrawalStatus.initial;
  List<WithdrawalModel> _withdrawals = [];
  String? _errorMessage;
  String? _currentAccountId;

  // Getters
  WithdrawalStatus get status => _status;
  List<WithdrawalModel> get withdrawals => _withdrawals;
  String? get errorMessage => _errorMessage;
  String? get currentAccountId => _currentAccountId;

  // Set current account
  void setCurrentAccount(String accountId) {
    _currentAccountId = accountId;
    loadAccountWithdrawals(accountId);
  }

  // Load account withdrawals
  Future<void> loadAccountWithdrawals(String accountId) async {
    try {
      _status = WithdrawalStatus.loading;
      notifyListeners();

      _withdrawals = await _withdrawalService.getAccountWithdrawals(accountId);
      _status = WithdrawalStatus.loaded;
    } catch (e) {
      _status = WithdrawalStatus.error;
      _errorMessage = e.toString();
    } finally {
      notifyListeners();
    }
  }

  // Create withdrawal request
  Future<String> createWithdrawalRequest({
    required String accountId,
    required double amount,
    required String currency,
    required String paymentMethod,
    required String paymentDetails,
    String? reason,
  }) async {
    try {
      _status = WithdrawalStatus.loading;
      notifyListeners();

      final withdrawalId = await _withdrawalService.createWithdrawalRequest(
        accountId: accountId,
        amount: amount,
        currency: currency,
        paymentMethod: paymentMethod,
        paymentDetails: paymentDetails,
        reason: reason,
      );

      // Reload withdrawals
      await loadAccountWithdrawals(accountId);

      return withdrawalId;
    } catch (e) {
      _status = WithdrawalStatus.error;
      _errorMessage = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  // Approve withdrawal
  Future<void> approveWithdrawal(String withdrawalId) async {
    try {
      await _withdrawalService.approveWithdrawal(withdrawalId);

      // Reload withdrawals if we have a current account
      if (_currentAccountId != null) {
        await loadAccountWithdrawals(_currentAccountId!);
      }
    } catch (e) {
      _status = WithdrawalStatus.error;
      _errorMessage = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  // Reject withdrawal
  Future<void> rejectWithdrawal(String withdrawalId, String reason) async {
    try {
      await _withdrawalService.rejectWithdrawal(withdrawalId, reason);

      // Reload withdrawals if we have a current account
      if (_currentAccountId != null) {
        await loadAccountWithdrawals(_currentAccountId!);
      }
    } catch (e) {
      _status = WithdrawalStatus.error;
      _errorMessage = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  // Complete withdrawal
  Future<void> completeWithdrawal(String withdrawalId) async {
    try {
      await _withdrawalService.completeWithdrawal(withdrawalId);

      // Reload withdrawals if we have a current account
      if (_currentAccountId != null) {
        await loadAccountWithdrawals(_currentAccountId!);
      }
    } catch (e) {
      _status = WithdrawalStatus.error;
      _errorMessage = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  // Get total withdrawals
  Future<double> getTotalWithdrawals(String accountId) async {
    try {
      return await _withdrawalService.getTotalWithdrawals(accountId);
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  // Get total completed withdrawals
  Future<double> getTotalCompletedWithdrawals(String accountId) async {
    try {
      return await _withdrawalService.getTotalCompletedWithdrawals(accountId);
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  // Load withdrawals for a specific account
  Future<void> loadWithdrawals(String accountId) async {
    await loadAccountWithdrawals(accountId);
  }

  // Get withdrawals by account ID
  List<WithdrawalModel> getWithdrawalsByAccountId(String accountId) {
    return _withdrawals.where((w) => w.accountId == accountId).toList();
  }

  // Create withdrawal (alias for createWithdrawalRequest)
  Future<String> createWithdrawal({
    required String accountId,
    required double amount,
    required String currency,
    required String paymentMethod,
    required String paymentDetails,
    String? reason,
  }) async {
    return await createWithdrawalRequest(
      accountId: accountId,
      amount: amount,
      currency: currency,
      paymentMethod: paymentMethod,
      paymentDetails: paymentDetails,
      reason: reason,
    );
  }

  // Clear error
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}