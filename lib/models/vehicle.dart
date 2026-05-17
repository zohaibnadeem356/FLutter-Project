import 'package:flutter/material.dart';

class Vehicle {
  final String id;
  final String name;
  final String type; // car, bike, other
  final double fuelEfficiency;
  final String efficiencyUnit; // km/L, L/100km, mpg
  final String? imagePath;
  final DateTime createdAt;

  Vehicle({
    required this.id,
    required this.name,
    required this.type,
    required this.fuelEfficiency,
    required this.efficiencyUnit,
    this.imagePath,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'type': type,
        'fuelEfficiency': fuelEfficiency,
        'efficiencyUnit': efficiencyUnit,
        'imagePath': imagePath,
        'createdAt': createdAt.toIso8601String(),
      };

  factory Vehicle.fromJson(Map<String, dynamic> json) {
    return Vehicle(
      id: json['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
      name: json['name'] ?? '',
      type: json['type'] ?? 'car',
      fuelEfficiency: json['fuelEfficiency']?.toDouble() ?? 15.0,
      efficiencyUnit: json['efficiencyUnit'] ?? 'km/L',
      imagePath: json['imagePath'],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
    );
  }

  Vehicle copyWith({
    String? name,
    String? type,
    double? fuelEfficiency,
    String? efficiencyUnit,
  }) {
    return Vehicle(
      id: id,
      name: name ?? this.name,
      type: type ?? this.type,
      fuelEfficiency: fuelEfficiency ?? this.fuelEfficiency,
      efficiencyUnit: efficiencyUnit ?? this.efficiencyUnit,
      imagePath: imagePath,
      createdAt: createdAt,
    );
  }
}

enum VehicleType {
  car('Car', Icons.directions_car),
  bike('Bike', Icons.motorcycle),
  other('Other', Icons.agriculture);

  final String label;
  final IconData icon;

  const VehicleType(this.label, this.icon);

  static VehicleType fromString(String value) {
    return VehicleType.values.firstWhere(
      (e) => e.label.toLowerCase() == value.toLowerCase(),
      orElse: () => VehicleType.car,
    );
  }
}