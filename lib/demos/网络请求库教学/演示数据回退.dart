import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;
import 'package:jobs_flutter_base_config/JobsDemoTools/Data/Data.3rd/网络请求/Dio/HttpDemo/shared/demo_http.dart';

const legacyDemoApiBase = String.fromEnvironment(
  'JOBS_METHOD_API_BASE',
  defaultValue: 'http://127.0.0.1:18080',
);
const legacyDemoApiTimeout = Duration(
  milliseconds: int.fromEnvironment(
    'JOBS_METHOD_API_TIMEOUT_MS',
    defaultValue: 900,
  ),
);

const localMethodCatalog = [
  {'method': 'GET', 'path': '/api/get/dashboard', 'description': '读取嵌套对象与页面数据'},
  {
    'method': 'POST',
    'path': '/api/post/orders',
    'description': '提交查询条件并读取订单列表',
  },
  {'method': 'PUT', 'path': '/api/put/profile', 'description': '完整更新个人资料'},
  {'method': 'PATCH', 'path': '/api/patch/settings', 'description': '局部更新设置'},
  {
    'method': 'DELETE',
    'path': '/api/delete/order/ORD-20260324-0001',
    'description': '删除订单',
  },
  {'method': 'UPLOAD', 'path': '/api/upload/file', 'description': '内存文件与表单上传'},
  {
    'method': 'DOWNLOAD',
    'path': '/api/download/file',
    'description': '文件下载与字节预览',
  },
];

class LegacyLocalResponse {
  LegacyLocalResponse(this.status, this.bytes, this.headers);
  final int status;
  final Uint8List bytes;
  final Map<String, String> headers;
  Object? get json => jsonDecode(utf8.decode(bytes));
}

LegacyLocalResponse legacyLocalResponse(
  Uri uri, {
  bool uploadWithoutFile = false,
}) {
  final failure =
      uri.path.contains('/errors/') ||
      uri.queryParameters['fileName'] == 'not-found.txt' ||
      uploadWithoutFile;
  final isDownload = uri.path.contains('/download/') && !failure;
  final body = failure
      ? <String, Object?>{
          'code': 400,
          'message': '演示错误：请求参数或文件不存在',
          'source': 'local-demo',
        }
      : {
          'code': 0,
          'message': '本地演示数据',
          'source': 'local-demo',
          'data': {
            'items': localMethodCatalog,
            'pageTitle': 'Jobs Demo',
            'welcomeText': 'API 未部署时仍可观摩解析与交互',
            'profile': {
              'nickname': 'Jobs',
              'city': 'Bangkok',
              'email': 'jobs@example.com',
              'membership': {'level': 'Demo'},
            },
            'stats': {'orderCount': 3, 'pendingCount': 1, 'totalAmount': 1280},
            'quickActions': ['OC', 'Swift', 'Flutter'],
            'records': [
              {
                'orderNo': 'ORD-20260324-0001',
                'user': {
                  'name': 'Jobs',
                  'phone': 'Demo',
                  'address': {'province': '', 'city': 'Bangkok', 'detail': ''},
                },
                'summary': {'statusText': '已支付', 'finalAmount': 128},
                'tags': ['本地演示'],
                'products': [
                  {
                    'name': 'Flutter 教学',
                    'count': 1,
                    'sku': 'DEMO-01',
                    'price': 128,
                  },
                ],
              },
            ],
            'settings': {
              'theme': 'dark',
              'notifications': true,
              'fontScale': 1.1,
            },
            'deletedOrderId': 'ORD-20260324-0001',
            'fileName': 'flutter_upload_demo.txt',
            'size': 35,
            'contentType': 'text/plain',
            'description': 'Flutter 上传示例文件',
            'preview': 'This is a demo upload from Flutter.',
          },
        };
  return LegacyLocalResponse(
    failure ? 400 : 200,
    Uint8List.fromList(
      utf8.encode(
        isDownload
            ? 'Jobs Flutter download demo\nOC / Swift / Flutter\n'
            : jsonEncode(body),
      ),
    ),
    {
      'content-type': isDownload
          ? 'text/plain; charset=utf-8'
          : 'application/json; charset=utf-8',
      'x-jobs-data-source': 'local-demo',
      if (isDownload)
        'content-disposition': 'attachment; filename="download-demo.txt"',
    },
  );
}

Dio createLegacyDio() {
  final dio = Dio(
    BaseOptions(
      baseUrl: legacyDemoApiBase,
      connectTimeout: legacyDemoApiTimeout,
      receiveTimeout: legacyDemoApiTimeout,
      sendTimeout: legacyDemoApiTimeout,
      validateStatus: (value) => value != null && value < 500,
    ),
  );
  Response<dynamic> fallback(RequestOptions request) {
    final local = legacyLocalResponse(
      request.uri,
      uploadWithoutFile:
          request.data is FormData && (request.data as FormData).files.isEmpty,
    );
    return Response<dynamic>(
      requestOptions: request,
      statusCode: local.status,
      headers: Headers.fromMap(
        local.headers.map((key, value) => MapEntry(key, [value])),
      ),
      data: request.responseType == ResponseType.bytes
          ? local.bytes
          : local.json,
    );
  }

  dio.interceptors.add(
    InterceptorsWrapper(
      onResponse: (response, handler) {
        final body = response.data;
        if (response.requestOptions.responseType != ResponseType.bytes &&
            response.statusCode! < 400 &&
            (body is! Map || body['data'] is! Map)) {
          handler.resolve(fallback(response.requestOptions));
        } else {
          handler.next(response);
        }
      },
      onError: (error, handler) =>
          handler.resolve(fallback(error.requestOptions)),
    ),
  );
  return dio;
}

/// 每次先发送真实请求；网络/超时/不可解析响应只回退当前请求，不锁定演示模式。
class LegacyFallbackHttpClient extends http.BaseClient {
  LegacyFallbackHttpClient({http.Client? upstream})
    : upstream = upstream ?? http.Client();
  final http.Client upstream;
  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    try {
      final streamed = await upstream
          .send(request)
          .timeout(legacyDemoApiTimeout);
      final response = await http.Response.fromStream(streamed)
          .timeout(legacyDemoApiTimeout);
      final bytes = response.bodyBytes;
      final isDownload = request.url.path.contains('/download/');
      final body = isDownload ? null : jsonDecode(utf8.decode(bytes));
      if (response.statusCode >= 500 ||
          (!isDownload &&
              response.statusCode < 400 &&
              (body is! Map || body['data'] is! Map))) {
        throw const FormatException('Invalid demo response');
      }
      return http.StreamedResponse(
        Stream.value(bytes),
        response.statusCode,
        headers: response.headers,
      );
    } catch (_) {
      final missingUpload =
          request is http.MultipartRequest && request.files.isEmpty;
      final local = legacyLocalResponse(
        request.url,
        uploadWithoutFile: missingUpload,
      );
      return http.StreamedResponse(
        Stream.value(local.bytes),
        local.status,
        headers: local.headers,
      );
    }
  }

  @override
  void close() => upstream.close();
}

class LegacyHttpClient extends DemoHttpClient {
  LegacyHttpClient(this.transport)
    : super(
        baseUrl: legacyDemoApiBase,
        client: transport,
        timeout: legacyDemoApiTimeout * 3,
      );
  final LegacyFallbackHttpClient transport;
  @override
  Future<DemoHttpResponse> uploadMultipart({
    required String path,
    required Map<String, String> fields,
    String? fileField,
    String? fileName,
    List<int>? fileBytes,
    String? contentType,
  }) async {
    final request = http.MultipartRequest('POST', uri(path))
      ..fields.addAll(fields);
    if (fileField != null && fileName != null && fileBytes != null)
      request.files.add(
        http.MultipartFile.fromBytes(fileField, fileBytes, filename: fileName),
      );
    final response = await http.Response.fromStream(
      await transport.send(request),
    );
    final body = utf8.decode(response.bodyBytes);
    return DemoHttpResponse(
      statusCode: response.statusCode,
      headers: response.headers,
      bodyBytes: Uint8List.fromList(response.bodyBytes),
      bodyText: body,
      jsonBody: jsonDecode(body),
    );
  }
}
