import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:jobs_demo_foundation/jobs_demo_foundation.dart';
import 'package:jobs_flutter_base_config/demos/原生网络请求教学/入口.dart';
import 'package:jobs_flutter_base_config/demos/网络请求库教学/入口.dart';
import 'package:jobs_flutter_base_config/demos/网络请求库教学/演示数据回退.dart';

// 两种真实旧解析页面均走可注入离线传输，检查七种方法可进入、请求和返回。
void main() {
  for (final useDio in [false, true]) {
    for (final method in [
      'GET',
      'POST',
      'PUT',
      'PATCH',
      'DELETE',
      'UPLOAD',
      'DOWNLOAD',
    ]) {
      testWidgets('${useDio ? 'Dio' : 'HTTP'} $method offline route', (
        tester,
      ) async {
        final dio = createLegacyDio()..httpClientAdapter = _OfflineAdapter();
        final client = LegacyHttpClient(
          LegacyFallbackHttpClient(
            upstream: MockClient(
              (_) async => throw http.ClientException('offline'),
            ),
          ),
        );
        await tester.pumpWidget(
          MaterialApp(
            locale: const Locale('zh'),
            localizationsDelegates: jobsDemoLocalizationDelegates,
            supportedLocales: jobsDemoLocales,
            home: useDio
                ? LegacyDioCatalog(client: dio)
                : LegacyHttpCatalog(client: client),
          ),
        );
        await tester.pumpAndSettle();
        await tester.scrollUntilVisible(find.text(method), 250);
        await tester.tap(find.text(method));
        await tester.pumpAndSettle();
        await tester.tap(find.text('发起请求'));
        await tester.pumpAndSettle();
        expect(find.textContaining('请求成功'), findsOneWidget);
        expect(tester.takeException(), isNull);
        await tester.tap(
          find.byTooltip('返回'),
        ); // 兼容 Get 旧 Material 类型与新 SDK 的独立 UI 包。
        await tester.pumpAndSettle();
        await tester.pumpWidget(const SizedBox());
        await tester.pump();
        if (useDio)
          client.transport.close();
        else
          dio.close();
        expect(tester.takeException(), isNull);
      });
    }
  }
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
