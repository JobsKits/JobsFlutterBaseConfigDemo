import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:jobs_flutter_base_config/demos/网络请求库教学/演示数据回退.dart';

// 验证旧网络教学的实际传输、逐请求回退和服务恢复，不访问真实后端。
void main() {
  test(
    'HTTP retries remote after failure and accepts later real data',
    () async {
      var count = 0;
      final client = LegacyHttpClient(
        LegacyFallbackHttpClient(
          upstream: MockClient((_) async {
            count++;
            if (count == 1) throw http.ClientException('offline');
            return http.Response(
              jsonEncode({
                'data': {
                  'profile': {'nickname': 'Remote'},
                },
              }),
              200,
            );
          }),
        ),
      );
      final local = await client.getJson('/api/get/dashboard');
      expect(local.headers['x-jobs-data-source'], 'local-demo');
      expect((local.jsonBody as Map)['data']['profile']['nickname'], 'Jobs');
      final remote = await client.getJson('/api/get/dashboard');
      expect((remote.jsonBody as Map)['data']['profile']['nickname'], 'Remote');
      expect(count, 2);
      client.transport.close();
    },
  );

  test(
    'HTTP invalid success body falls back and offline error remains error',
    () async {
      final client = LegacyHttpClient(
        LegacyFallbackHttpClient(
          upstream: MockClient((_) async => http.Response('html', 200)),
        ),
      );
      final response = await client.getJson('/api/methods');
      expect((response.jsonBody as Map)['data']['items'], hasLength(7));
      final error = await client.getJson('/api/errors/get');
      expect(error.isError, isTrue);
      final download = await client.downloadBytes('/api/download/file');
      expect(download.bodyBytes, isNotEmpty);
      client.transport.close();
    },
  );

  test('HTTP upload also uses injected transport and can recover', () async {
    var count = 0;
    final client = LegacyHttpClient(
      LegacyFallbackHttpClient(
        upstream: MockClient((request) async {
          count++;
          if (count == 1) throw http.ClientException('offline');
          return http.Response(
            jsonEncode({
              'data': {'fileName': 'remote.txt'},
            }),
            200,
          );
        }),
      ),
    );
    final local = await client.uploadMultipart(
      path: '/api/upload/file',
      fields: {},
      fileField: 'file',
      fileName: 'demo.txt',
      fileBytes: [1, 2],
    );
    expect(local.headers['x-jobs-data-source'], 'local-demo');
    final remote = await client.uploadMultipart(
      path: '/api/upload/file',
      fields: {},
      fileField: 'file',
      fileName: 'demo.txt',
      fileBytes: [1, 2],
    );
    expect((remote.jsonBody as Map)['data']['fileName'], 'remote.txt');
    expect(count, 2);
    client.transport.close();
  });

  test('Dio fallback never prevents subsequent remote request', () async {
    final dio = createLegacyDio();
    final adapter = _RecoveringAdapter();
    dio.httpClientAdapter = adapter;
    final local = await dio.get('/api/get/dashboard');
    expect(local.headers.value('x-jobs-data-source'), 'local-demo');
    final remote = await dio.get('/api/get/dashboard');
    expect(remote.data['data']['profile']['nickname'], 'Remote');
    expect(adapter.count, 2);
    dio.close();
  });

  test('Dio fallback preserves binary download and error semantics', () async {
    final dio = createLegacyDio()..httpClientAdapter = _OfflineAdapter();
    final bytes = await dio.get<List<int>>(
      '/api/download/file',
      options: Options(responseType: ResponseType.bytes),
    );
    expect(utf8.decode(bytes.data!), contains('Jobs Flutter'));
    final error = await dio.get('/api/errors/put');
    expect(error.statusCode, 400);
    final missing = await dio.post(
      '/api/upload/file',
      data: FormData.fromMap({'description': 'error'}),
    );
    expect(missing.statusCode, 400);
    dio.close();
  });
}

class _RecoveringAdapter implements HttpClientAdapter {
  int count = 0;
  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    count++;
    if (count == 1)
      throw DioException(
        requestOptions: options,
        type: DioExceptionType.connectionError,
      );
    return ResponseBody.fromString(
      jsonEncode({
        'data': {
          'profile': {'nickname': 'Remote'},
        },
      }),
      200,
      headers: {
        Headers.contentTypeHeader: ['application/json'],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

class _OfflineAdapter implements HttpClientAdapter {
  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async => throw DioException(
    requestOptions: options,
    type: DioExceptionType.connectionError,
  );
  @override
  void close({bool force = false}) {}
}
