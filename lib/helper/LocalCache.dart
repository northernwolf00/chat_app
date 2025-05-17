import 'package:shared_preferences/shared_preferences.dart';

class LocalCache {
  static late SharedPreferences _prefs;

  static Future init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static bool isPinned(String userId) =>
      _prefs.getBool('pinned_$userId') ?? false;

  static bool isFavorite(String userId) =>
      _prefs.getBool('favorite_$userId') ?? false;

  static Future<void> setPinned(String userId, bool value) async =>
      await _prefs.setBool('pinned_$userId', value);

  static Future<void> setFavorite(String userId, bool value) async =>
      await _prefs.setBool('favorite_$userId', value);
}
