import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../models/trip_calculation.dart';
import '../models/vehicle.dart';
import '../widgets/custom_input_field.dart';
import '../widgets/result_card.dart';

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  final _distanceController = TextEditingController();
  final _fuelPriceController = TextEditingController(text: '280.0');

  List<TripCalculation> _allResults = [];
  List<Vehicle> _currentVehicles = [];
  String _selectedUnit = 'km';
  bool _isCalculating = false;
  bool _isRoundTrip = false;

  @override
  void initState() {
    super.initState();
    _loadVehicles();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadVehicles();
  }

  void _loadVehicles() {
    final appProvider = Provider.of<AppProvider>(context, listen: false);
    setState(() {
      _currentVehicles = List.from(appProvider.vehicles);
    });
  }

  void _calculateForAllVehicles() {
    final appProvider = Provider.of<AppProvider>(context, listen: false);

    _loadVehicles();

    if (_distanceController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter distance first')),
      );
      return;
    }

    if (_currentVehicles.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add vehicles first in Vehicles tab')),
      );
      return;
    }

    setState(() {
      _isCalculating = true;
      _allResults.clear();
    });

    final distance = double.parse(_distanceController.text);
    final fuelPrice = double.parse(_fuelPriceController.text);

    double distanceInKm = distance;
    if (_selectedUnit == 'miles') {
      distanceInKm = distance * 1.60934;
    }

    if (_isRoundTrip) {
      distanceInKm = distanceInKm * 2;
    }

    List<TripCalculation> results = [];
    List<Map<String, dynamic>> newCalculations = [];

    for (var vehicle in _currentVehicles) {
      double efficiencyInKmPerL = vehicle.fuelEfficiency;

      if (vehicle.efficiencyUnit == 'L/100km') {
        if (vehicle.fuelEfficiency > 0) {
          efficiencyInKmPerL = 100 / vehicle.fuelEfficiency;
        }
      } else if (vehicle.efficiencyUnit == 'mpg') {
        efficiencyInKmPerL = vehicle.fuelEfficiency * 0.425144;
      }

      final fuelNeeded = distanceInKm / efficiencyInKmPerL;
      final totalCost = fuelNeeded * fuelPrice;

      final calculation = TripCalculation(
        distance: distanceInKm,
        fuelEfficiency: efficiencyInKmPerL,
        fuelPrice: fuelPrice,
        totalCost: totalCost,
        fuelNeeded: fuelNeeded,
        timestamp: DateTime.now(),
      );

      results.add(calculation);

      final resultWithVehicle = {
        ...calculation.toJson(),
        'vehicleName': vehicle.name,
        'vehicleType': vehicle.type,
        'id': DateTime.now().millisecondsSinceEpoch.toString() + vehicle.id,
      };
      newCalculations.add(resultWithVehicle);
    }

    setState(() {
      _allResults = results;
      _isCalculating = false;
    });

    appProvider.addMultipleCalculations(newCalculations);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Calculated for ${_currentVehicles.length} vehicle(s)'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _clearForm() {
    setState(() {
      _distanceController.clear();
      _fuelPriceController.text = '280.0';
      _allResults = [];
      _isRoundTrip = false;
    });
  }

  // Greeting based on time of day
  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final appProvider = Provider.of<AppProvider>(context);
    final vehicles = appProvider.vehicles;
    final hasVehicles = vehicles.isNotEmpty;
    final userName = appProvider.user?.name ?? 'User';

    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.white,
      appBar: AppBar(
        backgroundColor: isDark ? Colors.black : Colors.white,
        foregroundColor: isDark ? Colors.white : Colors.black,
        elevation: 0,
        centerTitle: false,
        title: const Text(
          'Trip Estimator',
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700),
        ),
        actions: [
          if (_allResults.isNotEmpty)
            IconButton(
              icon: Icon(Icons.refresh, color: isDark ? Colors.white : Colors.black),
              onPressed: _clearForm,
            ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await appProvider.refreshAll();
          _loadVehicles();
          setState(() {});
          return Future.value();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // ✅ Welcome Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isDark
                        ? [Colors.grey[900]!, Colors.grey[850]!]
                        : [Colors.black, const Color(0xFF222222)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    // Left: text
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _getGreeting() + ' 👋',
                            style: const TextStyle(
                              fontSize: 13,
                              color: Colors.white60,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 0.3,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            userName,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              letterSpacing: -0.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Right: icon
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(
                        Icons.local_gas_station,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              Text(
                'Calculate Trip\nCost',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  color: isDark ? Colors.white : Colors.black,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 16),

              // Round Trip Toggle
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey[900] : Colors.grey[50],
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Round Trip', style: TextStyle(fontSize: 16)),
                    Switch(
                      value: _isRoundTrip,
                      onChanged: (value) {
                        setState(() {
                          _isRoundTrip = value;
                          _allResults = [];
                        });
                      },
                      activeColor: Colors.black,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Distance Input
              CustomInputField(
                controller: _distanceController,
                label: 'Distance',
                hint: 'Enter distance',
                icon: Icons.route,
                unit: _selectedUnit,
                onUnitChanged: (value) {
                  setState(() {
                    _selectedUnit = value;
                    _allResults = [];
                  });
                },
                units: const ['km', 'miles'],
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Enter distance';
                  if (double.tryParse(value) == null || double.parse(value) <= 0) {
                    return 'Invalid distance';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Fuel Price Input
              CustomInputField(
                controller: _fuelPriceController,
                label: 'Fuel Price',
                hint: 'Price per liter',
                icon: Icons.local_gas_station,
                unit: 'Rs/L',
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Enter price';
                  if (double.tryParse(value) == null || double.parse(value) <= 0) {
                    return 'Invalid price';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Calculate Button
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: _calculateForAllVehicles,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDark ? Colors.white : Colors.black,
                    foregroundColor: isDark ? Colors.black : Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    hasVehicles ? 'Calculate for All Vehicles' : 'Add Vehicles First',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // No Vehicles Warning
              if (vehicles.isEmpty)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.warning_amber, color: Colors.orange),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'No vehicles added. Go to Vehicles tab to add your car or bike.',
                          style: TextStyle(color: isDark ? Colors.white70 : Colors.black87),
                        ),
                      ),
                    ],
                  ),
                ),

              // Loading Indicator
              if (_isCalculating)
                const Center(
                  child: Column(
                    children: [
                      SizedBox(height: 20),
                      SizedBox(
                        height: 30,
                        width: 30,
                        child: CircularProgressIndicator(strokeWidth: 2.5),
                      ),
                      SizedBox(height: 12),
                      Text('Calculating...'),
                    ],
                  ),
                ),

              // Results for Each Vehicle
              if (_allResults.isNotEmpty && !_isCalculating) ...[
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'RESULTS',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: _isRoundTrip ? Colors.green : Colors.blue,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        _isRoundTrip ? 'Round Trip' : 'One Way',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ...List.generate(_allResults.length, (index) {
                  if (index >= _currentVehicles.length) {
                    return const SizedBox.shrink();
                  }
                  return ResultCard(
                    calculation: _allResults[index],
                    vehicle: _currentVehicles[index],
                  );
                }),
              ],

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}