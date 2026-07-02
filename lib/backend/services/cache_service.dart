import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

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

    return List<dynamic>.from(
      jsonDecode(cached),
    );
  }

  static Future<dynamic> getObject(
    String key,
  ) async {
    final prefs = await SharedPreferences.getInstance();

    final cached = prefs.getString(key);

    if (cached == null) return null;

    return jsonDecode(cached);
  }
}