import 'package:flutter/material.dart';

class SharedPrefKeys {
  static const String languageCode = 'languageCode';
  static const String defaultCode = 'tr';
  static const String appLanguage = 'AppLanguage';
}

class Constants {
  static const baseUrl = "http://216.250.11.150/api";
}

class AppConstants {
  static const Locale defaultLocale = Locale('tr');
  static const List<Locale> supportedLocales = [
    Locale('en', 'US'),
    Locale('ru', 'RU'),
    Locale('tr', 'TM'),
  ];
}
