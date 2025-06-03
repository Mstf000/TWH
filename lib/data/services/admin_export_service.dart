import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';

class ExportService {
  Future<void> exportAllDealsToExcel() async {
    final status = await Permission.storage.request();
    if (!status.isGranted) throw Exception('Storage permission denied');

    final excel = Excel.createExcel();
    final Sheet sheet = excel['Deals'];

    // Header
    sheet.appendRow(['User Email', 'Deal Name', 'Status', 'Submitted At']);

    final usersSnapshot =
        await FirebaseFirestore.instance.collection('users').get();

    for (final user in usersSnapshot.docs) {
      final email = user.data()['email'] ?? 'Unknown';
      final forms = await user.reference.collection('forms').get();

      for (final form in forms.docs) {
        final data = form.data();
        sheet.appendRow([
          email,
          data['name'] ?? 'Unnamed',
          data['deal_status'] ?? 'pending',
          (data['submitted_at'] as Timestamp?)?.toDate().toString() ?? ''
        ]);
      }
    }

    final dir = await getExternalStorageDirectory();
    final path = "${dir!.path}/deals_export.xlsx";

    final fileBytes = excel.encode();
    if (fileBytes != null) {
      final file = File(path);
      await file.writeAsBytes(fileBytes);
      print('Saved to $path');

      // Optionally open it
      // await OpenFile.open(file.path);
    }
  }
}
