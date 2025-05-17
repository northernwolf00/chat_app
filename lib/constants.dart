import 'package:flutter/material.dart';

class SharedPrefKeys {
  static const String languageCode = 'languageCode';
  static const String defaultCode = 'tr';
  static const String appLanguage = 'AppLanguage';
}

class Constants {
 
}

class AppConstants {
  static const Locale defaultLocale = Locale('tr');
  static const List<Locale> supportedLocales = [
    Locale('en', 'US'),
    Locale('ru', 'RU'),
    Locale('tr', 'TM'),
  ];
}
