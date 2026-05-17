import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../models/vehicle.dart';

class VehicleScreen extends StatefulWidget {
  const VehicleScreen({super.key});

  @override
  State<VehicleScreen> createState() => _VehicleScreenState();
}

class _VehicleScreenState extends State<VehicleScreen> {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final appProvider = Provider.of<AppProvider>(context);
    final vehicles = appProvider.vehicles;

    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.white,
      appBar: AppBar(
        backgroundColor: isDark ? Colors.black : Colors.white,
        foregroundColor: isDark ? Colors.white : Colors.black,
        elevation: 0,
        title: const Text(
          'My Vehicles',
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _addVehicle(context, appProvider),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await appProvider.refreshAll();
          return Future.value();
        },
        child: vehicles.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.directions_car, size: 80, color: Colors.grey[400]),
                    const SizedBox(height: 20),
                    Text(
                      'No Vehicles Added',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white70 : Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Tap + to add your car or bike',
                      style: TextStyle(color: isDark ? Colors.white54 : Colors.black45),
                    ),
                  ],
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: vehicles.length,
                itemBuilder: (context, index) {
                  final vehicle = vehicles[index];
                  final type = VehicleType.fromString(vehicle.type);

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.grey[900] : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isDark ? Colors.grey[800]! : Colors.grey[200]!,
                      ),
                    ),
                    child: ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(type.icon, color: Colors.white, size: 24),
                      ),
                      title: Text(
                        vehicle.name,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      subtitle: Text(
                        '${vehicle.fuelEfficiency.toStringAsFixed(1)} ${vehicle.efficiencyUnit}',
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, size: 20),
                            onPressed: () => _editVehicle(context, appProvider, vehicle),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline, size: 20, color: Colors.red),
                            onPressed: () => _deleteVehicle(context, appProvider, vehicle),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }

  void _addVehicle(BuildContext context, AppProvider provider) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => VehicleFormDialog(
        onSave: (vehicle) async {
          await provider.addVehicle(vehicle);
          if (context.mounted) Navigator.pop(context);
        },
      ),
    );
  }

  void _editVehicle(BuildContext context, AppProvider provider, Vehicle vehicle) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => VehicleFormDialog(
        vehicle: vehicle,
        onSave: (updatedVehicle) async {
          await provider.updateVehicle(updatedVehicle);
          if (context.mounted) Navigator.pop(context);
        },
      ),
    );
  }

  void _deleteVehicle(BuildContext context, AppProvider provider, Vehicle vehicle) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Vehicle'),
        content: Text('Are you sure you want to delete ${vehicle.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              await provider.deleteVehicle(vehicle.id);
              if (context.mounted) Navigator.pop(context);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

class VehicleFormDialog extends StatefulWidget {
  final Vehicle? vehicle;
  final Function(Vehicle) onSave;

  const VehicleFormDialog({super.key, this.vehicle, required this.onSave});

  @override
  State<VehicleFormDialog> createState() => _VehicleFormDialogState();
}

class _VehicleFormDialogState extends State<VehicleFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _efficiencyController;
  late String _selectedType;
  late String _selectedUnit;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.vehicle?.name ?? '');
    _efficiencyController =
        TextEditingController(text: widget.vehicle?.fuelEfficiency.toString() ?? '15.0');
    _selectedType = widget.vehicle?.type ?? 'car';
    _selectedUnit = widget.vehicle?.efficiencyUnit ?? 'km/L';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _efficiencyController.dispose();
    super.dispose();
  }

  String _getTitle() {
    return widget.vehicle == null ? 'Add Vehicle' : 'Edit Vehicle';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 20,
        right: 20,
        top: 20,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[400],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              _getTitle(),
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Vehicle Name',
                hintText: 'e.g., Honda Civic, Yamaha R15',
                prefixIcon: Icon(Icons.directions_car),
              ),
              validator: (value) => value == null || value.isEmpty ? 'Enter name' : null,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedType,
              decoration: const InputDecoration(
                labelText: 'Vehicle Type',
                prefixIcon: Icon(Icons.category),
              ),
              items: const [
                DropdownMenuItem(value: 'car', child: Text('Car')),
                DropdownMenuItem(value: 'bike', child: Text('Bike')),
                DropdownMenuItem(value: 'other', child: Text('Other')),
              ],
              onChanged: (value) => setState(() => _selectedType = value!),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _efficiencyController,
                    decoration: const InputDecoration(
                      labelText: 'Fuel Efficiency',
                      prefixIcon: Icon(Icons.speed),
                    ),
                    keyboardType: TextInputType.numberWithOptions(decimal: true),
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Enter efficiency';
                      if (double.tryParse(value) == null || double.parse(value) <= 0) {
                        return 'Invalid';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  width: 100,
                  height: 56,
                  decoration: BoxDecoration(
                    color: isDark ? Colors.grey[800] : Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: DropdownButton<String>(
                      value: _selectedUnit,
                      underline: const SizedBox(),
                      items: const [
                        DropdownMenuItem(value: 'km/L', child: Text('km/L')),
                        DropdownMenuItem(value: 'L/100km', child: Text('L/100km')),
                        DropdownMenuItem(value: 'mpg', child: Text('mpg')),
                      ],
                      onChanged: (value) => setState(() => _selectedUnit = value!),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        final vehicle = Vehicle(
                          id: widget.vehicle?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
                          name: _nameController.text,
                          type: _selectedType,
                          fuelEfficiency: double.parse(_efficiencyController.text),
                          efficiencyUnit: _selectedUnit,
                        );
                        widget.onSave(vehicle);
                      }
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
                    child: const Text('Save'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}