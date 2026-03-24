import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

import 'demo_helpers.dart';

class DemoHttp {
  DemoHttp._();

  static final DemoHttpClient instance = DemoHttpClient(
    baseUrl: 'http://127.0.0.1:18080',
  );
}

class DemoHttpResponse {
  DemoHttpResponse({
    required this.statusCode,
    required this.headers,
    required this.bodyBytes,
    required this.bodyText,
    this.jsonBody,
  });

  final int statusCode;
  final Map<String, String> headers;
  final Uint8List bodyBytes;
  final String bodyText;
  final Object? jsonBody;

  bool get isError => statusCode >= 400;
}

class DemoHttpClient {
  DemoHttpClient({
    required this.baseUrl,
    http.Client? client,
    this.timeout = const Duration(seconds: 5),
  }) : _client = client ?? http.Client();

  final String baseUrl;
  final Duration timeout;
  final http.Client _client;

  Uri uri(String path, {Map<String, dynamic>? queryParameters}) {
    final base = Uri.parse(baseUrl);
    final target = Uri.parse('$baseUrl$path');
    final mergedQuery = <String, String>{
      ...target.queryParameters,
      ...?queryParameters?.map((key, value) => MapEntry(key, '$value')),
    };

    return Uri(
      scheme: target.scheme.isEmpty ? base.scheme : target.scheme,
      userInfo: target.userInfo,
      host: target.host.isEmpty ? base.host : target.host,
      port: target.hasPort ? target.port : base.port,
      path: target.path,
      queryParameters: mergedQuery.isEmpty ? null : mergedQuery,
      fragment: target.fragment.isEmpty ? null : target.fragment,
    );
  }

  Future<DemoHttpResponse> getJson(
    String path, {
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
  }) {
    return _send(
      () => _client.get(
        uri(path, queryParameters: queryParameters),
        headers: {
          'Content-Type': 'application/json',
          ...?headers,
        },
      ),
    );
  }

  Future<DemoHttpResponse> postJson(
    String path, {
    Object? body,
    Map<String, String>? headers,
  }) {
    return _send(
      () => _client.post(
        uri(path),
        headers: {
          'Content-Type': 'application/json',
          ...?headers,
        },
        body: jsonEncode(body),
      ),
    );
  }

  Future<DemoHttpResponse> putJson(
    String path, {
    Object? body,
    Map<String, String>? headers,
  }) {
    return _send(
      () => _client.put(
        uri(path),
        headers: {
          'Content-Type': 'application/json',
          ...?headers,
        },
        body: jsonEncode(body),
      ),
    );
  }

  Future<DemoHttpResponse> patchJson(
    String path, {
    Object? body,
    Map<String, String>? headers,
  }) {
    return _send(
      () => _client.patch(
        uri(path),
        headers: {
          'Content-Type': 'application/json',
          ...?headers,
        },
        body: jsonEncode(body),
      ),
    );
  }

  Future<DemoHttpResponse> deleteJson(
    String path, {
    Map<String, String>? headers,
  }) {
    return _send(
      () => _client.delete(
        uri(path),
        headers: {
          'Content-Type': 'application/json',
          ...?headers,
        },
      ),
    );
  }

  Future<DemoHttpResponse> uploadMultipart({
    required String path,
    required Map<String, String> fields,
    String? fileField,
    String? fileName,
    List<int>? fileBytes,
    String? contentType,
  }) async {
    final request = http.MultipartRequest('POST', uri(path));
    request.fields.addAll(fields);

    if (fileField != null && fileName != null && fileBytes != null) {
      request.files.add(
        http.MultipartFile.fromBytes(
          fileField,
          fileBytes,
          filename: fileName,
        ),
      );
      if (contentType != null) {
        request.headers['x-demo-content-type'] = contentType;
      }
    }

    final streamedResponse = await request.send().timeout(timeout);
    final response = await http.Response.fromStream(streamedResponse);
    return _toDemoResponse(response);
  }

  Future<DemoHttpResponse> downloadBytes(
    String path, {
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
  }) async {
    final request = http.Request(
      'GET',
      uri(path, queryParameters: queryParameters),
    );
    request.headers.addAll(headers ?? const {});

    final streamedResponse = await _client.send(request).timeout(timeout);
    final response = await http.Response.fromStream(streamedResponse);
    return _toDemoResponse(response);
  }

  Future<DemoHttpResponse> _send(
    Future<http.Response> Function() task,
  ) async {
    final response = await task().timeout(timeout);
    return _toDemoResponse(response);
  }

  DemoHttpResponse _toDemoResponse(http.Response response) {
    final bodyText = utf8.decode(response.bodyBytes, allowMalformed: true);
    return DemoHttpResponse(
      statusCode: response.statusCode,
      headers: normalizeHeaders(response.headers),
      bodyBytes: Uint8List.fromList(response.bodyBytes),
      bodyText: bodyText,
      jsonBody: tryDecodeJsonFromText(bodyText),
    );
  }
}
