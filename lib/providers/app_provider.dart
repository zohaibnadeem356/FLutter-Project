import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/vehicle.dart';
import '../models/user.dart';

class AppProvider extends ChangeNotifier {
  List<Vehicle> _vehicles = [];
  List<Map<String, dynamic>> _calculations = [];
  UserModel? _user;
  String _themeMode = 'auto';
  bool _isLoading = false;

  List<Vehicle> get vehicles => _vehicles;
  List<Map<String, dynamic>> get calculations => _calculations;
  UserModel? get user => _user;
  String get themeMode => _themeMode;
  bool get isLoading => _isLoading;

  AppProvider() {
    loadAllData();
  }

  Future<void> loadAllData() async {
    _isLoading = true;
    notifyListeners();
    
    await Future.wait([
      loadVehicles(),
      loadCalculations(),
      loadUser(),
      loadThemeMode(),
    ]);
    
    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadVehicles() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? vehiclesJson = prefs.getStringList('vehicles');
    if (vehiclesJson != null) {
      _vehicles = vehiclesJson
          .map((json) => Vehicle.fromJson(jsonDecode(json)))
          .toList();
    } else {
      _vehicles = [];
    }
    notifyListeners();
  }

  Future<void> loadCalculations() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? calculationsJson = prefs.getStringList('calculations');
    if (calculationsJson != null) {
      _calculations = calculationsJson
          .map((json) => jsonDecode(json) as Map<String, dynamic>)
          .toList();
    } else {
      _calculations = [];
    }
    notifyListeners();
  }

  Future<void> loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString('user');
    if (userJson != null) {
      _user = UserModel.fromJson(jsonDecode(userJson));
    }
    notifyListeners();
  }

  Future<void> loadThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    _themeMode = prefs.getString('themeMode') ?? 'auto';
    notifyListeners();
  }

  // Vehicle Operations
  Future<void> addVehicle(Vehicle vehicle) async {
    _vehicles.add(vehicle);
    await _saveVehicles();
    notifyListeners();
  }

  Future<void> updateVehicle(Vehicle vehicle) async {
    final index = _vehicles.indexWhere((v) => v.id == vehicle.id);
    if (index != -1) {
      _vehicles[index] = vehicle;
      await _saveVehicles();
      notifyListeners();
    }
  }

  Future<void> deleteVehicle(String vehicleId) async {
    _vehicles.removeWhere((v) => v.id == vehicleId);
    await _saveVehicles();
    notifyListeners();
  }

  Future<void> _saveVehicles() async {
    final prefs = await SharedPreferences.getInstance();
    final vehiclesJson = _vehicles.map((v) => jsonEncode(v.toJson())).toList();
    await prefs.setStringList('vehicles', vehiclesJson);
  }

  // Calculation Operations
  Future<void> addCalculation(Map<String, dynamic> calculation) async {
    _calculations.insert(0, calculation);
    if (_calculations.length > 50) {
      _calculations = _calculations.take(50).toList();
    }
    await _saveCalculations();
    notifyListeners();
  }

  Future<void> addMultipleCalculations(List<Map<String, dynamic>> newCalculations) async {
    for (var calc in newCalculations.reversed) {
      _calculations.insert(0, calc);
    }
    if (_calculations.length > 50) {
      _calculations = _calculations.take(50).toList();
    }
    await _saveCalculations();
    notifyListeners();
  }

  Future<void> deleteCalculation(int index) async {
    if (index >= 0 && index < _calculations.length) {
      _calculations.removeAt(index);
      await _saveCalculations();
      notifyListeners();
    }
  }

  Future<void> clearAllCalculations() async {
    _calculations.clear();
    await _saveCalculations();
    notifyListeners();
  }

  Future<void> _saveCalculations() async {
    final prefs = await SharedPreferences.getInstance();
    final historyJson = _calculations.map((c) => jsonEncode(c)).toList();
    await prefs.setStringList('calculations', historyJson);
  }

  // User Operations
  Future<void> updateUser(String name) async {
    _user = UserModel(name: name, createdAt: DateTime.now());
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user', jsonEncode(_user!.toJson()));
    notifyListeners();
  }

  // Theme Operations
  Future<void> updateThemeMode(String mode) async {
    _themeMode = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('themeMode', mode);
    notifyListeners();
  }

  // Onboarding
  Future<void> setOnboardingComplete() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hasSeenOnboarding', true);
  }

  // Refresh all data
  Future<void> refreshAll() async {
    await loadAllData();
  }
}