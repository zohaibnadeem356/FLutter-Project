class TripCalculation {
  final double distance;
  final double fuelEfficiency;
  final double fuelPrice;
  final double totalCost;
  final double fuelNeeded;
  final DateTime timestamp;

  TripCalculation({
    required this.distance,
    required this.fuelEfficiency,
    required this.fuelPrice,
    required this.totalCost,
    required this.fuelNeeded,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  Map<String, dynamic> toJson() => {
        'distance': distance,
        'fuelEfficiency': fuelEfficiency,
        'fuelPrice': fuelPrice,
        'totalCost': totalCost,
        'fuelNeeded': fuelNeeded,
        'timestamp': timestamp.toIso8601String(),
      };

  factory TripCalculation.fromJson(Map<String, dynamic> json) {
    return TripCalculation(
      distance: json['distance'] ?? 0.0,
      fuelEfficiency: json['fuelEfficiency'] ?? 0.0,
      fuelPrice: json['fuelPrice'] ?? 0.0,
      totalCost: json['totalCost'] ?? 0.0,
      fuelNeeded: json['fuelNeeded'] ?? 0.0,
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'])
          : DateTime.now(),
    );
  }
}