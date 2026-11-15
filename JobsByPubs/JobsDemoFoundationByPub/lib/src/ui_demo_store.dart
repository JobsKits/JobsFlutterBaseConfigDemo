import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

/// UI 教学数据也正常访问服务端；离线时只保存本地演示状态。
class UiDemoStore {
  static const _base = String.fromEnvironment(
    'DEMO_API_BASE',
    defaultValue: 'http://localhost:8080/',
  );
  static final _versions = <String, int>{};
  static bool _compatible(Object? value, Object? expected) {
    if (expected == null) return value == null || value is String;
    if (expected is List)
      return value is List &&
          (expected.isEmpty ||
              value.every((item) => _compatible(item, expected.first)));
    if (expected is Map)
      return value is Map &&
          expected.entries.every(
            (entry) =>
                value.containsKey(entry.key) &&
                _compatible(value[entry.key], entry.value),
          );
    if (expected is num) return value is num;
    if (expected is bool) return value is bool;
    return value is String;
  }

  static Future<Object?> read(
    String key,
    Object? fallback, {
    http.Client? client,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    Object? local = fallback;
    try {
      final data = prefs.getString('ui.$key');
      if (data != null) {
        final decoded = jsonDecode(data);
        if (_compatible(decoded, fallback)) local = decoded;
      }
    } catch (_) {}
    try {
      final response =
          await (client?.get(Uri.parse(_base).resolve('api/ui-demos/$key')) ??
                  http.get(Uri.parse(_base).resolve('api/ui-demos/$key')))
              .timeout(const Duration(milliseconds: 900));
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final value = jsonDecode(response.body);
        if (value is Map &&
            value.containsKey('value') &&
            _compatible(value['value'], fallback)) {
          await prefs.setString('ui.$key', jsonEncode(value['value']));
          return value['value'];
        }
      }
    } catch (_) {}
    return local;
  }

  static Future<Object?> write(
    String key,
    Object? value, {
    http.Client? client,
  }) async {
    final version = (_versions[key] ?? 0) + 1;
    _versions[key] = version;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('ui.$key', jsonEncode(value));
    try {
      final uri = Uri.parse(_base).resolve('api/ui-demos/$key');
      final headers = {'Content-Type': 'application/json'};
      final body = jsonEncode({'value': value});
      final response =
          await (client?.put(uri, headers: headers, body: body) ??
                  http.put(uri, headers: headers, body: body))
              .timeout(const Duration(milliseconds: 900));
      if (response.statusCode >= 200 &&
          response.statusCode < 300 &&
          response.body.isNotEmpty) {
        final remote = jsonDecode(response.body);
        if (remote is Map &&
            remote.containsKey('value') &&
            _compatible(remote['value'], value) &&
            _versions[key] == version) {
          await prefs.setString('ui.$key', jsonEncode(remote['value']));
          return remote['value'];
        }
      }
    } catch (_) {}
    return _versions[key] == version ? value : null;
  }
}
