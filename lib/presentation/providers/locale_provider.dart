import 'package:flutter/material.dart';

class LocaleProvider extends ChangeNotifier {
  String _locale = 'en'; // default language

  String get locale => _locale;

  void toggleLocale() {
    _locale = _locale == 'en' ? 'ar' : 'en';
    notifyListeners();
  }
}
