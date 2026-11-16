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
  static final _readVersions = <String, int>{};
  static final _pendingWrites = <String, ({int version, Object? value})>{};
  static final _memoryValues = <String, Object?>{};
  static Duration get apiTimeout => Duration(
    milliseconds: const int.fromEnvironment(
      'UI_DEMO_API_TIMEOUT_MS',
      defaultValue: 900,
    ).clamp(50, 5000),
  );

  static Future<SharedPreferences?> _preferences() async {
    try {
      return await SharedPreferences.getInstance();
    } catch (_) {
      return null;
    }
  }

  static Future<void> _cache(
    SharedPreferences? prefs,
    String key,
    String encoded,
  ) async {
    try {
      await prefs?.setString('ui.$key', encoded);
    } catch (_) {
      // 持久化不可用时继续通过内存与 API 完成本轮交互。
    }
  }

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
    final readVersion = (_readVersions[key] ?? 0) + 1;
    _readVersions[key] = readVersion;
    final writeVersion = _versions[key] ?? 0;
    final pendingAtStart = _pendingWrites.containsKey(key);
    final prefs = await _preferences();
    bool current() =>
        !pendingAtStart &&
        _readVersions[key] == readVersion &&
        (_versions[key] ?? 0) == writeVersion;
    Object? local() {
      // write 在首次 await 前登记意图，旧 GET 不能抢在本地保存前返回旧缓存。
      final pending = _pendingWrites[key];
      if (pending != null && _compatible(pending.value, fallback)) {
        return pending.value;
      }
      if (_memoryValues.containsKey(key) &&
          _compatible(_memoryValues[key], fallback)) {
        return _memoryValues[key];
      }
      try {
        final data = prefs?.getString('ui.$key');
        if (data != null) {
          final decoded = jsonDecode(data);
          if (_compatible(decoded, fallback)) {
            _memoryValues[key] = decoded;
            return decoded;
          }
        }
      } catch (_) {}
      return fallback;
    }

    try {
      final response =
          await (client?.get(Uri.parse(_base).resolve('api/ui-demos/$key')) ??
                  http.get(Uri.parse(_base).resolve('api/ui-demos/$key')))
              .timeout(apiTimeout);
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final value = jsonDecode(response.body);
        if (value is Map &&
            value.containsKey('value') &&
            _compatible(value['value'], fallback) &&
            current()) {
          _memoryValues[key] = value['value'];
          await _cache(prefs, key, jsonEncode(value['value']));
          return current() ? value['value'] : local();
        }
      }
    } catch (_) {}
    return local();
  }

  static Future<Object?> write(
    String key,
    Object? value, {
    http.Client? client,
  }) async {
    final version = (_versions[key] ?? 0) + 1;
    _versions[key] = version;
    final encoded = jsonEncode(value);
    _pendingWrites[key] = (version: version, value: value);
    _memoryValues[key] = value;
    try {
      final prefs = await _preferences();
      await _cache(prefs, key, encoded);
      try {
        final uri = Uri.parse(_base).resolve('api/ui-demos/$key');
        final headers = {'Content-Type': 'application/json'};
        final body = jsonEncode({'value': value});
        final response =
            await (client?.put(uri, headers: headers, body: body) ??
                    http.put(uri, headers: headers, body: body))
                .timeout(apiTimeout);
        if (response.statusCode >= 200 &&
            response.statusCode < 300 &&
            response.body.isNotEmpty) {
          final remote = jsonDecode(response.body);
          if (remote is Map &&
              remote.containsKey('value') &&
              _compatible(remote['value'], value) &&
              _versions[key] == version) {
            _pendingWrites[key] = (version: version, value: remote['value']);
            _memoryValues[key] = remote['value'];
            await _cache(prefs, key, jsonEncode(remote['value']));
            return remote['value'];
          }
        }
      } catch (_) {}
      return _versions[key] == version ? value : null;
    } finally {
      if (_pendingWrites[key]?.version == version) {
        _pendingWrites.remove(key);
      }
    }
  }
}
