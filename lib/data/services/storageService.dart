import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<String> uploadPdf(Uint8List pdfBytes, String filename) async {
    final ref = _storage.ref().child('pdf_reports').child(filename);
    final uploadTask = await ref.putData(pdfBytes);
    final downloadUrl = await ref.getDownloadURL();
    return downloadUrl;
  }
}
