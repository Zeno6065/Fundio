import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String id;
  final String username;
  final String email;
  final String defaultCurrency;
  final DateTime createdAt;
  final String? photoURL;
  final String? phone;

  UserModel({
    required this.id,
    required this.username,
    required this.email,
    required this.defaultCurrency,
    required this.createdAt,
    this.photoURL,
    this.phone,
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
      photoURL: json['photoURL'],
      phone: json['phone'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'email': email,
      'defaultCurrency': defaultCurrency,
      'createdAt': createdAt,
      'photoURL': photoURL,
      'phone': phone,
    };
  }

  UserModel copyWith({
    String? username,
    String? email,
    String? defaultCurrency,
    String? photoURL,
    String? phone,
  }) {
    return UserModel(
      id: id,
      username: username ?? this.username,
      email: email ?? this.email,
      defaultCurrency: defaultCurrency ?? this.defaultCurrency,
      createdAt: createdAt,
      photoURL: photoURL ?? this.photoURL,
      phone: phone ?? this.phone,
    );
  }
}