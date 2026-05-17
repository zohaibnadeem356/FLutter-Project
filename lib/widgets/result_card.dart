import 'package:flutter/material.dart';
import '../models/trip_calculation.dart';
import '../models/vehicle.dart';

class ResultCard extends StatelessWidget {
  final TripCalculation calculation;
  final Vehicle? vehicle;  // Add this line

  const ResultCard({
    super.key,
    required this.calculation,
    this.vehicle,  // Add this line
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // Get vehicle icon based on type
    IconData vehicleIcon = Icons.directions_car;
    if (vehicle?.type == 'bike') {
      vehicleIcon = Icons.motorcycle;
    } else if (vehicle?.type == 'other') {
      vehicleIcon = Icons.agriculture;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[900] : Colors.black,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          // Vehicle Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(vehicleIcon, color: Colors.white, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        vehicle?.name ?? 'Vehicle',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        'Efficiency: ${vehicle?.fuelEfficiency.toStringAsFixed(1) ?? "0"} ${vehicle?.efficiencyUnit ?? "km/L"}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white54,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Rs ${calculation.totalCost.toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Details
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    _buildDetail('Distance', '${calculation.distance.toStringAsFixed(1)} km'),
                    _buildDetail('Fuel Needed', '${calculation.fuelNeeded.toStringAsFixed(1)} L'),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _buildDetail('Fuel Price', 'Rs ${calculation.fuelPrice.toStringAsFixed(2)}/L'),
                    _buildDetail('Cost/km', 'Rs ${(calculation.totalCost / calculation.distance).toStringAsFixed(2)}'),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetail(String label, String value) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: Colors.white54,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}