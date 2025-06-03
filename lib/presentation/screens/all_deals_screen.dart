import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import '../widgets/loading.dart';

class AllDealsScreen extends StatefulWidget {
  const AllDealsScreen({super.key});

  @override
  State<AllDealsScreen> createState() => _AllDealsScreenState();
}

class _AllDealsScreenState extends State<AllDealsScreen> {
  DateTime? _fromDate;
  DateTime? _toDate;
  List<Map<String, dynamic>> _deals = [];
  bool _isLoading = true;

  List<String> selectedBranches = [];
  List<String> selectedStatuses = [];

  final List<String> allBranches = [
    'Cairo festival city',
    'City Center Almaza',
    'Mall Of Egypt',
    'City Center Alexanderia'
  ];
  final List<String> allStatuses = ['done', 'pending', 'no_deal'];

  @override
  void initState() {
    super.initState();
    _fetchDeals();
  }

  Future<void> _fetchDeals() async {
    setState(() {
      _isLoading = true;
    });

    final usersSnapshot =
        await FirebaseFirestore.instance.collection('users').get();

    List<Map<String, dynamic>> result = [];

    for (var userDoc in usersSnapshot.docs) {
      final userData = userDoc.data();
      final email = userData['email'] ?? 'Unknown';

      final formsSnapshot = await userDoc.reference
          .collection('forms')
          .orderBy('submitted_at', descending: true)
          .get();

      for (var form in formsSnapshot.docs) {
        final formData = form.data();
        final submittedAt = formData['submitted_at']?.toDate();
        if (submittedAt == null) continue;

        if (_fromDate != null && submittedAt.isBefore(_fromDate!)) continue;
        if (_toDate != null && submittedAt.isAfter(_toDate!)) continue;

        final branch = userData['branch'] ?? 'Unknown';
        final status = formData['deal_status'] ?? 'unknown';

        if (selectedBranches.isNotEmpty && !selectedBranches.contains(branch)) {
          continue;
        }

        if (selectedStatuses.isNotEmpty && !selectedStatuses.contains(status)) {
          continue;
        }

        result.add({
          'email': email,
          'submitted_at': submittedAt,
          'status': status,
          'name': formData['name'] ?? 'Unnamed Deal',
          'branch': branch,
        });
      }
    }

    setState(() {
      _deals = result;
      _isLoading = false;
    });
  }

  Future<bool> _requestStoragePermission() async {
    if (Platform.isAndroid) {
      if (await Permission.manageExternalStorage.isGranted) {
        return true;
      }

      var status = await Permission.manageExternalStorage.request();
      return status.isGranted;
    }
    return true;
  }

  Future<void> _exportDealsToCSV() async {
    if (_deals.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No deals to export.')),
      );
      return;
    }

    bool permissionGranted = await _requestStoragePermission();
    if (!permissionGranted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
          'Storage permission denied. Please enable it in Settings > Apps > Permissions.',
        )),
      );
      return;
    }

    List<List<dynamic>> csvData = [
      ['Name', 'Email', 'Branch', 'Status', 'Submitted At']
    ];

    for (var deal in _deals) {
      csvData.add([
        deal['name'],
        deal['email'],
        deal['branch'],
        deal['status'],
        deal['submitted_at'].toString().split('.')[0].replaceAll('T', ' ')
      ]);
    }

    String csv = const ListToCsvConverter().convert(csvData);

    try {
      final directory = Directory('/storage/emulated/0/Download');
      final path =
          '${directory.path}/deals_export_${DateTime.now().millisecondsSinceEpoch}.csv';
      final file = File(path);

      await file.writeAsString(csv);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Exported to Downloads folder:\n$path')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to export CSV: $e')),
      );
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'done':
        return Colors.green.shade100;
      case 'pending':
        return Colors.orange.shade100;
      case 'no_deal':
        return Colors.red.shade100;
      default:
        return Colors.grey.shade200;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'done':
        return Icons.check_circle;
      case 'pending':
        return Icons.access_time;
      case 'no_deal':
        return Icons.cancel;
      default:
        return Icons.help_outline;
    }
  }

  Future<void> _pickDateRange() async {
    final pickedFrom = await showDatePicker(
      context: context,
      initialDate: _fromDate ?? DateTime.now(),
      firstDate: DateTime(2023),
      lastDate: DateTime.now(),
    );
    if (pickedFrom == null) return;

    final pickedTo = await showDatePicker(
      context: context,
      initialDate: _toDate ?? DateTime.now(),
      firstDate: pickedFrom,
      lastDate: DateTime.now(),
    );
    if (pickedTo == null) return;

    setState(() {
      _fromDate = pickedFrom;
      _toDate = pickedTo;
    });

    _fetchDeals();
  }

  void _showMultiSelectDialog({
    required List<String> options,
    required List<String> selected,
    required String title,
    required Function(List<String>) onConfirm,
  }) async {
    final List<String> tempSelected = List.from(selected);

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Select $title'),
        content: StatefulBuilder(
          builder: (context, setStateDialog) => Column(
            mainAxisSize: MainAxisSize.min,
            children: options.map((option) {
              return CheckboxListTile(
                value: tempSelected.contains(option),
                title: Text(option),
                onChanged: (val) {
                  setStateDialog(() {
                    if (val == true) {
                      tempSelected.add(option);
                    } else {
                      tempSelected.remove(option);
                    }
                  });
                },
              );
            }).toList(),
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              onConfirm(tempSelected);
              Navigator.pop(context);
            },
            child: const Text("Apply"),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F6FC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 2,
        title: const Text(
          'All Deals',
          style:
              TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF6A2E76)),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.date_range, color: Color(0xFF6A2E76)),
            onPressed: _pickDateRange,
          ),
          IconButton(
            icon: const Icon(Icons.business_center, color: Color(0xFF6A2E76)),
            tooltip: "Filter by Branch",
            onPressed: () {
              _showMultiSelectDialog(
                options: allBranches,
                selected: selectedBranches,
                title: "Branches",
                onConfirm: (selected) {
                  setState(() {
                    selectedBranches = selected;
                  });
                  _fetchDeals();
                },
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.filter_alt, color: Color(0xFF6A2E76)),
            tooltip: "Filter by Status",
            onPressed: () {
              _showMultiSelectDialog(
                options: allStatuses,
                selected: selectedStatuses,
                title: "Statuses",
                onConfirm: (selected) {
                  setState(() {
                    selectedStatuses = selected;
                  });
                  _fetchDeals();
                },
              );
            },
          ),
          if (_fromDate != null ||
              _toDate != null ||
              selectedBranches.isNotEmpty ||
              selectedStatuses.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: TextButton.icon(
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFF6A2E76),
                ),
                icon: const Icon(Icons.clear),
                label: const Text("Clear"),
                onPressed: () {
                  setState(() {
                    _fromDate = null;
                    _toDate = null;
                    selectedBranches.clear();
                    selectedStatuses.clear();
                  });
                  _fetchDeals();
                },
              ),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: AppLoader())
          : _deals.isEmpty
              ? const Center(child: Text("No deals found in selected range."))
              : ListView.builder(
                  itemCount: _deals.length + 1,
                  padding: const EdgeInsets.all(16),
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return Card(
                        color: Colors.white,
                        elevation: 3,
                        margin: const EdgeInsets.only(bottom: 20),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Row(
                            children: [
                              const Icon(Icons.analytics,
                                  color: Color(0xFF6A2E76)),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  "Showing ${_deals.length} deal(s)",
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF6A2E76),
                                  ),
                                ),
                              ),
                              const Icon(Icons.checklist_rtl,
                                  color: Colors.black45)
                            ],
                          ),
                        ),
                      );
                    }

                    final deal = _deals[index - 1];
                    final statusColor = _getStatusColor(deal['status']);
                    final statusIcon = _getStatusIcon(deal['status']);
                    return Card(
                      color: statusColor,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      elevation: 3,
                      child: ListTile(
                        leading:
                            Icon(statusIcon, color: const Color(0xFF6A2E76)),
                        title: Text(
                          deal['name'],
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(deal['email'],
                                style: const TextStyle(color: Colors.black87)),
                            const SizedBox(height: 4),
                            Text(
                              "${deal['status'].toUpperCase()} • ${deal['submitted_at'].toString().split('.')[0].replaceAll('T', ' ')}",
                              style: const TextStyle(
                                  fontSize: 12, color: Colors.black54),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _exportDealsToCSV,
        label: const Text(
          "Export CSV",
          style: TextStyle(color: Colors.white),
        ),
        icon: const Icon(
          Icons.download,
          color: Colors.white,
        ),
        backgroundColor: const Color(0xFF6A2E76),
      ),
    );
  }
}
