import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'interaction_strings.dart';

/// Each request can recover independently; screens render their local state first.
class InteractionRepository {
  InteractionRepository({http.Client? client, Uri? base, Duration? timeout})
    : _client = client ?? http.Client(),
      base =
          base ??
          Uri.parse(
            const String.fromEnvironment(
              'DEMO_API_BASE',
              defaultValue: 'http://localhost:8080/',
            ),
          ),
      timeout =
          timeout ??
          const Duration(
            milliseconds: int.fromEnvironment(
              'INTERACTION_API_TIMEOUT_MS',
              defaultValue: 650,
            ),
          );
  final http.Client _client;
  final Uri base;
  final Duration timeout;
  bool _closed = false;

  Future<Object?> read(String key) => _request(key, null);
  Future<Object?> write(String key, Object value) => _request(key, value);
  Future<Object?> _request(String key, Object? value) async {
    if (_closed) return null;
    try {
      final uri = base.resolve('api/curated-interactions/$key');
      final response =
          await (value == null
                  ? _client.get(uri)
                  : _client.put(
                      uri,
                      headers: {'Content-Type': 'application/json'},
                      body: jsonEncode({'value': value}),
                    ))
              .timeout(timeout);
      if (_closed || response.statusCode < 200 || response.statusCode >= 300) {
        return null;
      }
      final decoded = jsonDecode(response.body);
      return decoded is Map<String, dynamic> ? decoded['value'] : null;
    } catch (_) {
      return null;
    }
  }

  void dispose() {
    _closed = true;
    _client.close();
  }
}

Widget interactionEmpty(BuildContext context, VoidCallback reload) => Center(
  child: Padding(
    padding: const EdgeInsets.all(20),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.inbox_outlined, size: 44),
        const SizedBox(height: 12),
        Text(interactionTr(context, '暂无数据')),
        const SizedBox(height: 12),
        FilledButton.icon(
          onPressed: reload,
          icon: const Icon(Icons.refresh),
          label: Text(interactionTr(context, '重新加载')),
        ),
      ],
    ),
  ),
);

Widget interactionStatus(
  BuildContext context, {
  required bool remote,
  required VoidCallback reload,
  VoidCallback? clear,
}) => Padding(
  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
  child: Wrap(
    spacing: 10,
    crossAxisAlignment: WrapCrossAlignment.center,
    children: [
      Chip(
        avatar: Icon(
          remote ? Icons.cloud_done_outlined : Icons.offline_bolt_outlined,
          size: 18,
        ),
        label: Text(interactionTr(context, remote ? '服务端数据' : '本地演示')),
      ),
      TextButton.icon(
        onPressed: reload,
        icon: const Icon(Icons.refresh),
        label: Text(interactionTr(context, '重新加载')),
      ),
      if (clear != null)
        IconButton(
          tooltip: interactionTr(context, '清空'),
          onPressed: clear,
          icon: const Icon(Icons.clear_all),
        ),
    ],
  ),
);

List<String>? interactionRows(Object? value) {
  if (value is! List ||
      !value.every((item) => item is String) ||
      value.length > 200) {
    return null;
  }
  return value.cast<String>();
}
