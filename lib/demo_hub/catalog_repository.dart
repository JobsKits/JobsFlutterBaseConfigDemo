import 'dart:convert';

import 'package:http/http.dart' as http;

/// 服务只提供目录排序和用户偏好，页面构造始终来自随包源码。
class CatalogRepository {
  CatalogRepository({
    http.Client? client,
    Uri? baseUrl,
    this.timeout = const Duration(milliseconds: 900),
  }) : _client = client ?? http.Client(),
       baseUrl =
           baseUrl ??
           Uri.parse(
             const String.fromEnvironment(
               'DEMO_API_BASE',
               defaultValue: 'http://localhost:8080/',
             ),
           );
  final http.Client _client;
  final Uri baseUrl;
  final Duration timeout;

  Uri _url(String path) => baseUrl.resolve(path);

  Future<List<String>?> loadOrder() async {
    try {
      final response = await _client.get(_url('api/demos')).timeout(timeout);
      if (response.statusCode != 200) return null;
      final value = jsonDecode(response.body);
      if (value is! Map || value['ids'] is! List) return null;
      return List<String>.from(value['ids'] as List);
    } catch (_) {
      return null;
    }
  }

  Future<void> savePreference(String key, Object value) async {
    try {
      await _client
          .put(
            _url('api/demo-preferences/$key'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'value': value}),
          )
          .timeout(timeout);
    } catch (_) {
      // 离线演示继续使用已经持久化的本地偏好，下次写入重新请求。
    }
  }

  void close() => _client.close();
}
