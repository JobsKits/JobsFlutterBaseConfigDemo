import 'dart:async';
import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:jobs_demo_foundation/jobs_demo_foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  final binding = TestWidgetsFlutterBinding.ensureInitialized();
  const channel = MethodChannel('plugins.flutter.io/shared_preferences');
  var failGet = false, failSet = false, returnFalse = false;
  var disk = <String, Object>{};

  setUp(() {
    SharedPreferences.resetStatic();
    failGet = false;
    failSet = false;
    returnFalse = false;
    disk = {};
    binding.defaultBinaryMessenger.setMockMethodCallHandler(channel, (
      call,
    ) async {
      if (call.method == 'getAll') {
        if (failGet) throw PlatformException(code: 'cache-unavailable');
        return Map<String, Object>.of(disk);
      }
      if (call.method == 'setString') {
        if (failSet) throw PlatformException(code: 'cache-write-failed');
        if (returnFalse) return false;
        final args = call.arguments as Map;
        disk[args['key'] as String] = args['value'] as String;
        return true;
      }
      throw MissingPluginException(call.method);
    });
  });
  tearDown(() {
    SharedPreferences.resetStatic();
    binding.defaultBinaryMessenger.setMockMethodCallHandler(channel, null);
  });

  test('缓存初始化失败仍发GET，恢复后服务端覆盖内存与持久化缓存', () async {
    const key = 'cache-init-fail-read';
    failGet = true;
    var requests = 0;
    final client = MockClient((request) async {
      expect(request.method, 'GET');
      requests++;
      return http.Response(
        jsonEncode({
          'value': ['server-$requests'],
        }),
        200,
      );
    });
    addTearDown(client.close);
    expect(await UiDemoStore.read(key, ['local'], client: client), [
      'server-1',
    ]);
    expect(requests, 1);
    failGet = false;
    expect(await UiDemoStore.read(key, ['local'], client: client), [
      'server-2',
    ]);
    expect(requests, 2);
    expect(jsonDecode(disk['flutter.ui.$key']! as String), ['server-2']);
  });

  test('缓存初始化失败仍发PUT，离线读取保留内存意图并可恢复为真值', () async {
    const key = 'cache-init-fail-write';
    failGet = true;
    final methods = <String>[];
    var online = false;
    final client = MockClient((request) async {
      methods.add(request.method);
      if (!online) return http.Response('', 503);
      return http.Response(
        jsonEncode({
          'value': {'page': 2},
        }),
        200,
      );
    });
    addTearDown(client.close);
    expect(await UiDemoStore.write(key, {'page': 1}, client: client), {
      'page': 1,
    });
    expect(await UiDemoStore.read(key, {'page': 0}, client: client), {
      'page': 1,
    });
    expect(methods, ['PUT', 'GET']);
    failGet = false;
    online = true;
    expect(await UiDemoStore.read(key, {'page': 0}, client: client), {
      'page': 2,
    });
    expect(jsonDecode(disk['flutter.ui.$key']! as String), {'page': 2});
  });

  test('缓存读取类型错误不会阻断GET和服务端回填', () async {
    const key = 'cache-bad-read-value';
    disk['flutter.ui.$key'] = 123;
    var requests = 0;
    final client = MockClient((_) async {
      requests++;
      return http.Response(
        jsonEncode({
          'value': ['valid'],
        }),
        200,
      );
    });
    addTearDown(client.close);
    expect(await UiDemoStore.read(key, ['local'], client: client), ['valid']);
    expect(requests, 1);
    expect(jsonDecode(disk['flutter.ui.$key']! as String), ['valid']);
  });

  for (final failure in ['throw', 'false']) {
    test('缓存写入$failure仍发PUT并接受规范化响应，后续GET可恢复', () async {
      final key = 'cache-set-$failure';
      failSet = failure == 'throw';
      returnFalse = failure == 'false';
      final methods = <String>[];
      final client = MockClient((request) async {
        methods.add(request.method);
        return http.Response(
          jsonEncode({
            'value': [request.method],
          }),
          200,
        );
      });
      addTearDown(client.close);
      expect(await UiDemoStore.write(key, ['intent'], client: client), ['PUT']);
      expect(methods, ['PUT']);
      expect(disk, isEmpty);
      failSet = false;
      returnFalse = false;
      expect(await UiDemoStore.read(key, <String>[], client: client), ['GET']);
      expect(methods, ['PUT', 'GET']);
      expect(jsonDecode(disk['flutter.ui.$key']! as String), ['GET']);
    });
  }

  test('API超时配置有默认值且夹紧到50..5000毫秒', () {
    const configured = int.fromEnvironment(
      'UI_DEMO_API_TIMEOUT_MS',
      defaultValue: 900,
    );
    expect(UiDemoStore.apiTimeout.inMilliseconds, configured.clamp(50, 5000));
  });

  test('API超时实际返回本地状态，下一次请求成功后自动覆盖', () async {
    const key = 'cache-api-timeout-recovery';
    var online = false, gets = 0;
    final client = MockClient((request) {
      if (request.method == 'PUT') return Future.value(http.Response('', 503));
      gets++;
      if (!online) return Completer<http.Response>().future;
      return Future.value(
        http.Response(
          jsonEncode({
            'value': ['recovered'],
          }),
          200,
        ),
      );
    });
    addTearDown(client.close);
    await UiDemoStore.write(key, ['local'], client: client);
    final watch = Stopwatch()..start();
    expect(await UiDemoStore.read(key, <String>[], client: client), ['local']);
    expect(
      watch.elapsed,
      greaterThanOrEqualTo(
        UiDemoStore.apiTimeout - const Duration(milliseconds: 20),
      ),
    );
    online = true;
    expect(await UiDemoStore.read(key, <String>[], client: client), [
      'recovered',
    ]);
    expect(gets, 2);
  });
}
