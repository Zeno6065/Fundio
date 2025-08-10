import 'package:cloud_firestore/cloud_firestore.dart';

class InviteModel {
  final String id;
  final String accountId;
  final String token;
  final DateTime expiresAt;
  final String createdBy;
  final DateTime createdAt;

  InviteModel({
    required this.id,
    required this.accountId,
    required this.token,
    required this.expiresAt,
    required this.createdBy,
    required this.createdAt,
  });

  factory InviteModel.fromJson(Map<String, dynamic> json, String id) {
    return InviteModel(
      id: id,
      accountId: json['accountId'] ?? '',
      token: json['token'] ?? '',
      expiresAt: json['expiresAt'] != null
          ? (json['expiresAt'] as Timestamp).toDate()
          : DateTime.now().add(const Duration(days: 7)),
      createdBy: json['createdBy'] ?? '',
      createdAt: json['createdAt'] != null
          ? (json['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'accountId': accountId,
      'token': token,
      'expiresAt': expiresAt,
      'createdBy': createdBy,
      'createdAt': createdAt,
    };
  }

  bool get isExpired => DateTime.now().isAfter(expiresAt);
}