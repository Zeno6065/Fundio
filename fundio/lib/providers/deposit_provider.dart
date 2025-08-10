import 'package:flutter/material.dart';
import '../models/deposit_model.dart';
import '../services/deposit_service.dart';

enum DepositStatus {
  initial,
  loading,
  loaded,
  error,
}

class DepositProvider extends ChangeNotifier {
  final DepositService _depositService = DepositService();
  
  DepositStatus _status = DepositStatus.initial;
  List<DepositModel> _deposits = [];
  String? _errorMessage;
  String? _currentAccountId;

  // Getters
  DepositStatus get status => _status;
  List<DepositModel> get deposits => _deposits;
  String? get errorMessage => _errorMessage;
  String? get currentAccountId => _currentAccountId;

  // Set current account
  void setCurrentAccount(String accountId) {
    _currentAccountId = accountId;
    loadAccountDeposits(accountId);
  }

  // Load account deposits
  Future<void> loadAccountDeposits(String accountId) async {
    try {
      _status = DepositStatus.loading;
      notifyListeners();

      _deposits = await _depositService.getAccountDeposits(accountId);
      _status = DepositStatus.loaded;
    } catch (e) {
      _status = DepositStatus.error;
      _errorMessage = e.toString();
    } finally {
      notifyListeners();
    }
  }

  // Create deposit
  Future<String> createDeposit({
    required String accountId,
    required double amount,
    required String currency,
    required String paymentMethod,
    String? notes,
  }) async {
    try {
      _status = DepositStatus.loading;
      notifyListeners();

      final depositId = await _depositService.createDeposit(
        accountId: accountId,
        amount: amount,
        currency: currency,
        paymentMethod: paymentMethod,
        notes: notes,
      );

      // Reload deposits
      await loadAccountDeposits(accountId);

      return depositId;
    } catch (e) {
      _status = DepositStatus.error;
      _errorMessage = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  // Approve deposit
  Future<void> approveDeposit(String depositId) async {
    try {
      await _depositService.approveDeposit(depositId);

      // Reload deposits if we have a current account
      if (_currentAccountId != null) {
        await loadAccountDeposits(_currentAccountId!);
      }
    } catch (e) {
      _status = DepositStatus.error;
      _errorMessage = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  // Reject deposit
  Future<void> rejectDeposit(String depositId, String reason) async {
    try {
      await _depositService.rejectDeposit(depositId, reason);

      // Reload deposits if we have a current account
      if (_currentAccountId != null) {
        await loadAccountDeposits(_currentAccountId!);
      }
    } catch (e) {
      _status = DepositStatus.error;
      _errorMessage = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  // Get total approved deposits
  Future<double> getTotalApprovedDeposits(String accountId) async {
    try {
      return await _depositService.getTotalApprovedDeposits(accountId);
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  // Get user contribution percentages
  Future<Map<String, double>> getUserContributionPercentages(String accountId) async {
    try {
      return await _depositService.getUserContributionPercentages(accountId);
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  // Expose fetch for UI
  Future<List<DepositModel>> getAccountDeposits(String accountId) {
    return _depositService.getAccountDeposits(accountId);
  }

  // Clear error
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}