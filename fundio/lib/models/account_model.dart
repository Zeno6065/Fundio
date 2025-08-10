import 'package:cloud_firestore/cloud_firestore.dart';

class PendingRequest {
  final String userId;
  final DateTime requestedAt;
  final String status; // 'pending', 'approved', 'rejected'

  PendingRequest({
    required this.userId,
    required this.requestedAt,
    required this.status,
  });

  factory PendingRequest.fromJson(Map<String, dynamic> json) {
    return PendingRequest(
      userId: json['userId'] ?? '',
      requestedAt: json['requestedAt'] != null
          ? (json['requestedAt'] as Timestamp).toDate()
          : DateTime.now(),
      status: json['status'] ?? 'pending',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'requestedAt': requestedAt,
      'status': status,
    };
  }
}

class AccountModel {
  final String id;
  final String name;
  final String description;
  final String adminId;
  final String currency;
  final double targetAmount;
  final DateTime maturityDate;
  final Map<String, dynamic> withdrawalRules;
  final List<String> members;
  final List<PendingRequest> pendingRequests;
  final DateTime createdAt;

  AccountModel({
    required this.id,
    required this.name,
    required this.description,
    required this.adminId,
    required this.currency,
    required this.targetAmount,
    required this.maturityDate,
    required this.withdrawalRules,
    required this.members,
    required this.pendingRequests,
    required this.createdAt,
  });

  factory AccountModel.fromJson(Map<String, dynamic> json, String id) {
    List<PendingRequest> requests = [];
    if (json['pendingRequests'] != null) {
      requests = (json['pendingRequests'] as List)
          .map((request) => PendingRequest.fromJson(request))
          .toList();
    }

    return AccountModel(
      id: id,
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      adminId: json['adminId'] ?? '',
      currency: json['currency'] ?? 'ZMW',
      targetAmount: (json['targetAmount'] ?? 0.0).toDouble(),
      maturityDate: json['maturityDate'] != null
          ? (json['maturityDate'] as Timestamp).toDate()
          : DateTime.now().add(const Duration(days: 365)),
      withdrawalRules: json['withdrawalRules'] ?? {},
      members: List<String>.from(json['members'] ?? []),
      pendingRequests: requests,
      createdAt: json['createdAt'] != null
          ? (json['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'adminId': adminId,
      'currency': currency,
      'targetAmount': targetAmount,
      'maturityDate': maturityDate,
      'withdrawalRules': withdrawalRules,
      'members': members,
      'pendingRequests': pendingRequests.map((request) => request.toJson()).toList(),
      'createdAt': createdAt,
    };
  }

  AccountModel copyWith({
    String? name,
    String? description,
    String? adminId,
    String? currency,
    double? targetAmount,
    DateTime? maturityDate,
    Map<String, dynamic>? withdrawalRules,
    List<String>? members,
    List<PendingRequest>? pendingRequests,
  }) {
    return AccountModel(
      id: id,
      name: name ?? this.name,
      description: description ?? this.description,
      adminId: adminId ?? this.adminId,
      currency: currency ?? this.currency,
      targetAmount: targetAmount ?? this.targetAmount,
      maturityDate: maturityDate ?? this.maturityDate,
      withdrawalRules: withdrawalRules ?? this.withdrawalRules,
      members: members ?? this.members,
      pendingRequests: pendingRequests ?? this.pendingRequests,
      createdAt: createdAt,
    );
  }
}