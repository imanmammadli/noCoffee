import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Thin wrapper that keeps the whole app state as one JSON string on the device.
class Storage {
  static const _key = 'taper_state_v1';
  static final SharedPreferencesAsync _prefs = SharedPreferencesAsync();

  static Future<Map<String, dynamic>?> read() async {
    final raw = await _prefs.getString(_key);
    if (raw == null) return null;
    return jsonDecode(raw) as Map<String, dynamic>;
  }

  static Future<void> write(Map<String, dynamic> data) =>
      _prefs.setString(_key, jsonEncode(data));

  static Future<void> clear() => _prefs.remove(_key);
}