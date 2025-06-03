import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class DealDetailScreen extends StatelessWidget {
  final Map<String, dynamic> dealData;

  const DealDetailScreen({super.key, required this.dealData});

  String _formatDate(Timestamp ts) {
    return DateFormat('yyyy/MM/dd - hh:mm a').format(ts.toDate());
  }

  IconData _getIconForField(String key) {
    switch (key) {
      case 'email':
        return Icons.email;
      case 'phone':
        return Icons.phone;
      case 'weight':
      case 'height':
        return Icons.accessibility;
      case 'work_type':
        return Icons.work;
      case 'work_days':
        return Icons.calendar_today;
      case 'screen_time':
        return Icons.smartphone;
      case 'drives_long':
        return Icons.drive_eta;
      default:
        return Icons.info_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    final status = dealData['deal_status'] ?? 'pending';
    final name = dealData['name'] ?? 'Unnamed Deal';
    final submittedAt = dealData['submitted_at'] as Timestamp?;
    final otherFields = Map.of(dealData)
      ..removeWhere(
          (key, _) => ['name', 'deal_status', 'submitted_at'].contains(key));

    return Scaffold(
      backgroundColor: const Color(0xFFF9F6FB),
      appBar: AppBar(
        title: const Text("Deal Details"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(name,
                style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF6A2E76))),
            const SizedBox(height: 8),
            Text("Status: ${status.toUpperCase()}",
                style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 4),
            if (submittedAt != null)
              Text("Submitted at: ${_formatDate(submittedAt)}",
                  style: const TextStyle(fontSize: 14, color: Colors.black54)),
            const Divider(height: 32),
            const Text("Deal Data:",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.separated(
                itemCount: otherFields.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final key = otherFields.keys.elementAt(index);
                  final value = otherFields[key].toString();
                  return Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        )
                      ],
                    ),
                    child: Row(
                      children: [
                        Icon(_getIconForField(key), color: Color(0xFF6A2E76)),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                key.replaceAll('_', ' ').toUpperCase(),
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black54,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                value,
                                style: const TextStyle(fontSize: 14),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
