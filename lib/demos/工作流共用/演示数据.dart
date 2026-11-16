import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

typedef WorkflowJson = Map<String, dynamic>;

class WorkflowResult {
  const WorkflowResult(this.value, {required this.online});
  final WorkflowJson value;
  final bool online;
}

/// Only these teaching workflows use this transport; domain validation stays local.
class WorkflowStore {
  WorkflowStore({http.Client? client, Duration? timeout, Uri? base})
    : _client = client ?? http.Client(),
      timeout =
          timeout ??
          const Duration(
            milliseconds: int.fromEnvironment(
              'WORKFLOW_API_TIMEOUT_MS',
              defaultValue: 800,
            ),
          ),
      base =
          base ??
          Uri.parse(
            const String.fromEnvironment(
              'DEMO_API_BASE',
              defaultValue: 'http://localhost:8080/',
            ),
          );

  final http.Client _client;
  final Duration timeout;
  final Uri base;
  final _versions = <String, int>{};
  Future<void> _cacheQueue = Future.value();
  bool _closed = false;

  Future<void> checkpoint(String key, WorkflowJson value) {
    final encoded = jsonEncode(value);
    _cacheQueue = _cacheQueue.catchError((Object _) {}).then((_) async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('workflow.$key', encoded);
    });
    return _cacheQueue;
  }

  Future<WorkflowResult> load(
    String key,
    WorkflowJson fallback,
    bool Function(WorkflowJson) accepts,
  ) => _request(key, fallback, accepts, false);
  Future<WorkflowResult> save(
    String key,
    WorkflowJson value,
    bool Function(WorkflowJson) accepts,
  ) => _request(key, value, accepts, true);

  Future<WorkflowResult> _request(
    String key,
    WorkflowJson value,
    bool Function(WorkflowJson) accepts,
    bool write,
  ) async {
    final version = (_versions[key] ?? 0) + 1;
    _versions[key] = version;
    var local = value;
    SharedPreferences? prefs;
    try {
      prefs = await SharedPreferences.getInstance();
    } catch (_) {}
    bool current() => !_closed && _versions[key] == version;
    if (!current()) return WorkflowResult(local, online: false);
    final cacheKey = 'workflow.$key';
    try {
      if (write) {
        await checkpoint(key, value);
      } else {
        final cached = jsonDecode(prefs?.getString(cacheKey) ?? 'null');
        if (cached is Map<String, dynamic> && accepts(cached)) local = cached;
      }
    } catch (_) {
      // A damaged or unavailable cache must not prevent the API attempt.
    }
    try {
      final uri = base.resolve('api/ui-demos/$key');
      final request = write
          ? _client.put(
              uri,
              headers: {'Content-Type': 'application/json'},
              body: jsonEncode({'value': value}),
            )
          : _client.get(uri);
      final limit = Duration(
        milliseconds: timeout.inMilliseconds.clamp(50, 5000),
      );
      final response = await request.timeout(limit);
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final body = jsonDecode(utf8.decode(response.bodyBytes));
        final remote = body is Map ? body['value'] : null;
        if (remote is Map<String, dynamic> && accepts(remote) && current()) {
          await checkpoint(key, remote);
          return WorkflowResult(remote, online: true);
        }
      }
    } catch (_) {
      // Offline writes are explicitly demo results, never financial operations.
    }
    return WorkflowResult(local, online: false);
  }

  void close() {
    _closed = true;
    _client.close();
  }
}
