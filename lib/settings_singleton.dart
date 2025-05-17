import 'package:flutter/material.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:we_chat/constants.dart';



class SettingsSingleton extends ChangeNotifier {
  static final SettingsSingleton instance = SettingsSingleton._internal();

  factory SettingsSingleton() => instance;

  SettingsSingleton._internal() {
    locale = Locale(SingletonSharedPreference.loadLangCode());
  }

  late Locale locale;

  Future<void> changeLocale(String selectedLanguage) async {
    if (selectedLanguage != locale.languageCode) {
      locale = Locale(selectedLanguage);

      await SingletonSharedPreference.setLangCode(selectedLanguage);
      notifyListeners();
      // Future.delayed(const Duration(milliseconds: 15), () {
      //   notifyListeners();
      // });
    }
  }

  bool _isAuthenticated = false;

  bool get isAuthenticated => _isAuthenticated;

  Future<void> checkAuthStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    _isAuthenticated = validateToken(token!);
    notifyListeners();
  }

  bool validateToken(String token) {
    return token.isNotEmpty;
  }

  Future<void> login(String token) async {
    // token = (await ApiTokenBox.getToken())!;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
    _isAuthenticated = true;
    notifyListeners();
  }

  Future<void> logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');

    _isAuthenticated = false;
    notifyListeners();
  }
}

class SingletonSharedPreference {
  late final SharedPreferences _pref;
  static late SingletonSharedPreference instance;
  factory SingletonSharedPreference(SharedPreferences pref) {
    instance = SingletonSharedPreference._internal(pref);
    return instance;
  }
  SingletonSharedPreference._internal(this._pref);
  static String loadLangCode() {
    return instance._pref.getString(SharedPrefKeys.languageCode) ??
        SharedPrefKeys.defaultCode;
  }

  static Future<bool> setLangCode(String code) {
    return instance._pref.setString(SharedPrefKeys.languageCode, code);
  }
}
