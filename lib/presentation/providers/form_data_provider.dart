import 'package:flutter/material.dart';

class FormDataProvider extends ChangeNotifier {
  final Map<String, dynamic> _formData = {};

  void update(String key, dynamic value) {
    _formData[key] = value;
    notifyListeners();
  }

  dynamic getValue(String key) => _formData[key];

  Map<String, dynamic> get allData => _formData;
}
