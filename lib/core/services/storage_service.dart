import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  StorageService._();

  static late SharedPreferences _prefs;
  static late FlutterSecureStorage _secure;

  static Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
    _secure = const FlutterSecureStorage(
      aOptions: AndroidOptions(encryptedSharedPreferences: true),
      iOptions: IOSOptions(
        accessibility: KeychainAccessibility.first_unlock_this_device,
      ),
    );
  }

  // ─── SharedPreferences ────────────────────────────────────────────────────
  static Future<bool> setString(String key, String value) =>
      _prefs.setString(key, value);

  static String? getString(String key) => _prefs.getString(key);

  static Future<bool> setBool(String key, {required bool value}) =>
      _prefs.setBool(key, value);

  static bool? getBool(String key) => _prefs.getBool(key);

  static Future<bool> setInt(String key, int value) =>
      _prefs.setInt(key, value);

  static int? getInt(String key) => _prefs.getInt(key);

  static Future<bool> setDouble(String key, double value) =>
      _prefs.setDouble(key, value);

  static double? getDouble(String key) => _prefs.getDouble(key);

  static Future<bool> setStringList(String key, List<String> value) =>
      _prefs.setStringList(key, value);

  static List<String>? getStringList(String key) =>
      _prefs.getStringList(key);

  static Future<bool> remove(String key) => _prefs.remove(key);

  static Future<bool> clear() => _prefs.clear();

  static bool containsKey(String key) => _prefs.containsKey(key);

  // ─── Secure Storage ───────────────────────────────────────────────────────
  static Future<void> setSecure(String key, String value) =>
      _secure.write(key: key, value: value);

  static Future<String?> getSecure(String key) => _secure.read(key: key);

  static Future<void> deleteSecure(String key) => _secure.delete(key: key);

  static Future<void> clearSecure() => _secure.deleteAll();

  static Future<bool> containsSecure(String key) async {
    final value = await _secure.read(key: key);
    return value != null;
  }
}
