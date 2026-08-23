import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'cache_keys.dart';

class CacheService {
  static Future<void> save(
    String key,
    dynamic value,
  ) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(
      key,
      jsonEncode(value),
    );

    await prefs.setInt(
      '${key}_time',
      DateTime.now().millisecondsSinceEpoch,
    );
  }

  static Future<List<dynamic>> getList(
    String key,
  ) async {
    final prefs = await SharedPreferences.getInstance();

    final cached = prefs.getString(key);

    if (cached == null) {
      return [];
    }

    try {
      return List<dynamic>.from(
        jsonDecode(cached),
      );
    } catch (e) {
      return [];
    }
  }

  static Future<dynamic> getObject(
    String key,
  ) async {
    final prefs = await SharedPreferences.getInstance();

    final cached = prefs.getString(key);

    if (cached == null) return null;

    try {
      return jsonDecode(cached);
    } catch (e) {
      return null;
    }
  }

  
  static Future<void> remove(
    String key,
  ) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove(key);
    await prefs.remove('${key}_time');
  }

  // --------------------------------------------------
  // EXISTS
  // --------------------------------------------------

  static Future<bool> exists(
    String key,
  ) async {
    final prefs = await SharedPreferences.getInstance();

    return prefs.containsKey(key);
  }

  // --------------------------------------------------
  // CLEAR EVERYTHING
  // --------------------------------------------------

  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.clear();
  }
}