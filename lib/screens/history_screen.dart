import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<Map<String, dynamic>> _calculations = [];
  List<Map<String, dynamic>>? _deletedItems;
  int? _deletedIndex;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadData();
  }

  void _loadData() {
    final appProvider = Provider.of<AppProvider>(context);
    setState(() {
      _calculations = List.from(appProvider.calculations);
    });
  }

  void _deleteItem(int index) async {
    final appProvider = Provider.of<AppProvider>(context, listen: false);
    final deletedItem = _calculations[index];
    
    setState(() {
      _deletedItems = [deletedItem];
      _deletedIndex = index;
      _calculations.removeAt(index);
    });
    
    await appProvider.deleteCalculation(index);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Calculation deleted'),
          action: SnackBarAction(
            label: 'UNDO',
            onPressed: () async {
              if (_deletedItems != null && _deletedIndex != null) {
                setState(() {
                  _calculations.insert(_deletedIndex!, _deletedItems!.first);
                  _deletedItems = null;
                  _deletedIndex = null;
                });
                // Need to re-add at correct position
                final allCalcs = await appProvider.calculations;
                // Refresh
                _loadData();
              }
            },
          ),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  Future<void> _clearAll() async {
    if (_calculations.isEmpty) return;

    final appProvider = Provider.of<AppProvider>(context, listen: false);
    final deletedItems = List<Map<String, dynamic>>.from(_calculations);
    
    setState(() {
      _calculations.clear();
    });
    
    await appProvider.clearAllCalculations();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('All calculations cleared'),
          action: SnackBarAction(
            label: 'UNDO',
            onPressed: () async {
              for (var item in deletedItems.reversed) {
                await appProvider.addCalculation(item);
              }
              _loadData();
            },
          ),
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.white,
      appBar: AppBar(
        backgroundColor: isDark ? Colors.black : Colors.white,
        foregroundColor: isDark ? Colors.white : Colors.black,
        elevation: 0,
        title: const Text(
          'History',
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700),
        ),
        actions: [
          if (_calculations.isNotEmpty)
            TextButton(
              onPressed: _clearAll,
              child: const Text(
                'Clear All',
                style: TextStyle(color: Colors.red, fontWeight: FontWeight.w600),
              ),
            ),
        ],
      ),
      body: _calculations.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.history, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'No calculations yet',
                    style: TextStyle(color: isDark ? Colors.grey[600] : Colors.grey[500]),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Calculate a trip to see history',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? Colors.grey[700] : Colors.grey[400],
                    ),
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: () async {
                _loadData();
                return Future.value();
              },
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _calculations.length,
                itemBuilder: (context, index) {
                  final calc = _calculations[index];
                  final id = calc['id'] ?? index.toString();
                  return Dismissible(
                    key: Key(id),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 20),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(Icons.delete, color: Colors.white),
                    ),
                    onDismissed: (_) => _deleteItem(index),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.grey[900] : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isDark ? Colors.grey[800]! : Colors.grey[200]!,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.black,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(Icons.local_gas_station, color: Colors.white, size: 20),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      calc['vehicleName'] ?? 'Vehicle',
                                      style: const TextStyle(fontWeight: FontWeight.w600),
                                    ),
                                    Text(
                                      'Rs ${calc['totalCost']?.toStringAsFixed(2) ?? '0'}',
                                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                '${calc['distance']?.toStringAsFixed(0) ?? '0'} km',
                                style: TextStyle(color: isDark ? Colors.grey[500] : Colors.grey[600]),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Fuel: ${calc['fuelNeeded']?.toStringAsFixed(1) ?? '0'} L • ${calc['fuelEfficiency']?.toStringAsFixed(1) ?? '0'} km/L',
                            style: TextStyle(fontSize: 12, color: isDark ? Colors.grey[500] : Colors.grey[600]),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _formatDate(DateTime.parse(calc['timestamp'])),
                            style: TextStyle(fontSize: 10, color: isDark ? Colors.grey[600] : Colors.grey[400]),
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

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} • ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}