import 'package:flutter/material.dart';

class UserModel {
  final String name;
  final DateTime? createdAt;

  UserModel({
    required this.name,
    this.createdAt,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'createdAt': createdAt?.toIso8601String(),
      };

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      name: json['name'] ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : null,
    );
  }
}