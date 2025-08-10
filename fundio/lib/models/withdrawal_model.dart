import 'package:cloud_firestore/cloud_firestore.dart';

class WithdrawalModel {
  final String id;
  final String accountId;
  final String userId;
  final double amount;
  final String currency;
  final String reason;
  final String status; // 'pending', 'approved', 'rejected'
  final DateTime createdAt;
  final DateTime? processedAt;
  final String? adminNotes;

  WithdrawalModel({
    required this.id,
    required this.accountId,
    required this.userId,
    required this.amount,
    required this.currency,
    required this.reason,
    required this.status,
    required this.createdAt,
    this.processedAt,
    this.adminNotes,
  });

  factory WithdrawalModel.fromJson(Map<String, dynamic> json, String id) {
    return WithdrawalModel(
      id: id,
      accountId: json['accountId'] ?? '',
      userId: json['userId'] ?? '',
      amount: (json['amount'] ?? 0.0).toDouble(),
      currency: json['currency'] ?? 'ZMW',
      reason: json['reason'] ?? '',
      status: json['status'] ?? 'pending',
      createdAt: json['createdAt'] != null
          ? (json['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      processedAt: json['processedAt'] != null
          ? (json['processedAt'] as Timestamp).toDate()
          : null,
      adminNotes: json['adminNotes'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'accountId': accountId,
      'userId': userId,
      'amount': amount,
      'currency': currency,
      'reason': reason,
      'status': status,
      'createdAt': createdAt,
      'processedAt': processedAt,
      'adminNotes': adminNotes,
    };
  }

  WithdrawalModel copyWith({
    String? accountId,
    String? userId,
    double? amount,
    String? currency,
    String? reason,
    String? status,
    DateTime? processedAt,
    String? adminNotes,
  }) {
    return WithdrawalModel(
      id: id,
      accountId: accountId ?? this.accountId,
      userId: userId ?? this.userId,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      reason: reason ?? this.reason,
      status: status ?? this.status,
      createdAt: createdAt,
      processedAt: processedAt ?? this.processedAt,
      adminNotes: adminNotes ?? this.adminNotes,
    );
  }
}