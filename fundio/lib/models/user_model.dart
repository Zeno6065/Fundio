import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String id;
  final String username;
  final String email;
  final String defaultCurrency;
  final DateTime createdAt;

  UserModel({
    required this.id,
    required this.username,
    required this.email,
    required this.defaultCurrency,
    required this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json, String id) {
    return UserModel(
      id: id,
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      defaultCurrency: json['defaultCurrency'] ?? 'ZMW',
      createdAt: json['createdAt'] != null
          ? (json['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'email': email,
      'defaultCurrency': defaultCurrency,
      'createdAt': createdAt,
    };
  }

  UserModel copyWith({
    String? username,
    String? email,
    String? defaultCurrency,
  }) {
    return UserModel(
      id: id,
      username: username ?? this.username,
      email: email ?? this.email,
      defaultCurrency: defaultCurrency ?? this.defaultCurrency,
      createdAt: createdAt,
    );
  }
}