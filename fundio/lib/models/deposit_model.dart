import 'package:cloud_firestore/cloud_firestore.dart';

class DepositModel {
  final String id;
  final String accountId;
  final String userId;
  final double amount;
  final String originalCurrency;
  final String? proofUrl;
  final String status; // 'pending', 'approved', 'rejected'
  final DateTime createdAt;
  final String? paymentMethod;

  DepositModel({
    required this.id,
    required this.accountId,
    required this.userId,
    required this.amount,
    required this.originalCurrency,
    this.proofUrl,
    required this.status,
    required this.createdAt,
    this.paymentMethod,
  });

  factory DepositModel.fromJson(Map<String, dynamic> json, String id) {
    return DepositModel(
      id: id,
      accountId: json['accountId'] ?? '',
      userId: json['userId'] ?? '',
      amount: (json['amount'] ?? 0.0).toDouble(),
      originalCurrency: json['originalCurrency'] ?? 'ZMW',
      proofUrl: json['proofUrl'],
      status: json['status'] ?? 'pending',
      createdAt: json['createdAt'] != null
          ? (json['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      paymentMethod: json['paymentMethod'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'accountId': accountId,
      'userId': userId,
      'amount': amount,
      'originalCurrency': originalCurrency,
      'proofUrl': proofUrl,
      'status': status,
      'createdAt': createdAt,
      'paymentMethod': paymentMethod,
    };
  }

  DepositModel copyWith({
    String? accountId,
    String? userId,
    double? amount,
    String? originalCurrency,
    String? proofUrl,
    String? status,
    String? paymentMethod,
  }) {
    return DepositModel(
      id: id,
      accountId: accountId ?? this.accountId,
      userId: userId ?? this.userId,
      amount: amount ?? this.amount,
      originalCurrency: originalCurrency ?? this.originalCurrency,
      proofUrl: proofUrl ?? this.proofUrl,
      status: status ?? this.status,
      createdAt: createdAt,
      paymentMethod: paymentMethod ?? this.paymentMethod,
    );
  }
}