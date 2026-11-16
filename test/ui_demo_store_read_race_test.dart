import 'dart:async';
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:jobs_demo_foundation/jobs_demo_foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 直接控制 get 的 Future，精确安排读取续体与本地写入续体的先后。
class _ReadClient extends http.BaseClient {
  final entered = Completer<void>();
  final response = Completer<http.Response>();
  @override
  Future<http.Response> get(Uri url, {Map<String, String>? headers}) {
    entered.complete();
    return response.future;
  }

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) =>
      throw UnsupportedError('Only controlled GET is supported');
}

http.Response _value(Object? value) =>
    http.Response(jsonEncode({'value': value}), 200);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('旧GET晚于新写成功返回，不覆盖新缓存或返回旧响应', () async {
    const key = 'read-write-success';
    final client = _ReadClient();
    addTearDown(client.close);
    final read = UiDemoStore.read(key, {'page': 0}, client: client);
    await client.entered.future;
    final writer = MockClient((_) async => _value({'page': 2}));
    addTearDown(writer.close);
    expect(await UiDemoStore.write(key, {'page': 1}, client: writer), {
      'page': 2,
    });
    client.response.complete(_value({'page': 0}));
    expect(await read, {'page': 2});
    final prefs = await SharedPreferences.getInstance();
    expect(jsonDecode(prefs.getString('ui.$key')!), {'page': 2});
  });

  test('旧GET续体先排队但write尚未保存本地缓存时，返回最新写意图', () async {
    const key = 'read-write-local-window';
    SharedPreferences.setMockInitialValues({
      'ui.$key': jsonEncode({'page': 0}),
    });
    final client = _ReadClient();
    addTearDown(client.close);
    final read = UiDemoStore.read(key, {'page': -1}, client: client);
    await client.entered.future;
    client.response.complete(_value({'page': 8}));
    final writer = MockClient((_) async => http.Response('', 503));
    addTearDown(writer.close);
    final write = UiDemoStore.write(key, {'page': 1}, client: writer);
    expect(await read, {'page': 1});
    expect(await write, {'page': 1});
    final prefs = await SharedPreferences.getInstance();
    expect(jsonDecode(prefs.getString('ui.$key')!), {'page': 1});
  });

  test('两个GET乱序完成，较旧GET使用最新兼容缓存且不覆写', () async {
    const key = 'read-read-order';
    final oldClient = _ReadClient(), newClient = _ReadClient();
    addTearDown(oldClient.close);
    addTearDown(newClient.close);
    final oldRead = UiDemoStore.read(key, <String>[], client: oldClient);
    await oldClient.entered.future;
    final newRead = UiDemoStore.read(key, <String>[], client: newClient);
    await newClient.entered.future;
    newClient.response.complete(_value(['new']));
    expect(await newRead, ['new']);
    oldClient.response.complete(_value(['old']));
    expect(await oldRead, ['new']);
    final prefs = await SharedPreferences.getInstance();
    expect(jsonDecode(prefs.getString('ui.$key')!), ['new']);
  });

  test('失效GET失败时读取当前缓存，不恢复开始时的本地快照', () async {
    const key = 'read-fail-after-write';
    SharedPreferences.setMockInitialValues({
      'ui.$key': jsonEncode(['before']),
    });
    final client = _ReadClient();
    addTearDown(client.close);
    final read = UiDemoStore.read(key, ['fallback'], client: client);
    await client.entered.future;
    final writer = MockClient((_) async => http.Response('', 503));
    addTearDown(writer.close);
    await UiDemoStore.write(key, ['saved'], client: writer);
    client.response.completeError(const FormatException('offline'));
    expect(await read, ['saved']);
    final prefs = await SharedPreferences.getInstance();
    expect(jsonDecode(prefs.getString('ui.$key')!), ['saved']);
  });

  test('失效GET失败且最新缓存不兼容时保持调用方fallback契约', () async {
    const key = 'read-fail-incompatible';
    final client = _ReadClient();
    addTearDown(client.close);
    final read = UiDemoStore.read(key, ['fallback'], client: client);
    await client.entered.future;
    final writer = MockClient((_) async => http.Response('', 503));
    addTearDown(writer.close);
    await UiDemoStore.write(key, {'other-schema': 1}, client: writer);
    client.response.complete(http.Response('invalid json', 200));
    expect(await read, ['fallback']);
    final prefs = await SharedPreferences.getInstance();
    expect(jsonDecode(prefs.getString('ui.$key')!), {'other-schema': 1});
  });

  test('每个key独立，离线后下一次成功GET仍可更新为服务端真值', () async {
    final responses = [
      http.Response('', 500),
      _value(['server']),
    ];
    final reader = MockClient((_) async => responses.removeAt(0));
    final writer = MockClient((_) async => _value(['other-key']));
    addTearDown(reader.close);
    addTearDown(writer.close);
    expect(await UiDemoStore.read('read-recovery', ['local'], client: reader), [
      'local',
    ]);
    await UiDemoStore.write('different-key', ['value'], client: writer);
    expect(await UiDemoStore.read('read-recovery', ['local'], client: reader), [
      'server',
    ]);
    final prefs = await SharedPreferences.getInstance();
    expect(jsonDecode(prefs.getString('ui.read-recovery')!), ['server']);
  });

  test('PUT进行中启动的GET不能把optimistic缓存改回服务端旧值', () async {
    const key = 'read-starts-during-write';
    final put = Completer<http.Response>(), putEntered = Completer<void>();
    final writer = MockClient((_) {
      putEntered.complete();
      return put.future;
    });
    final reader = _ReadClient();
    addTearDown(writer.close);
    addTearDown(reader.close);
    final write = UiDemoStore.write(key, {'page': 1}, client: writer);
    await putEntered.future;
    final read = UiDemoStore.read(key, {'page': 0}, client: reader);
    await reader.entered.future;
    reader.response.complete(_value({'page': 0}));
    expect(await read, {'page': 1});
    final prefs = await SharedPreferences.getInstance();
    expect(jsonDecode(prefs.getString('ui.$key')!), {'page': 1});
    put.complete(_value({'page': 2}));
    expect(await write, {'page': 2});
    expect(jsonDecode(prefs.getString('ui.$key')!), {'page': 2});
  });

  test('PUT期间启动的GET晚返回时使用服务端规范化后的最新缓存', () async {
    const key = 'read-during-write-late';
    final put = Completer<http.Response>(), putEntered = Completer<void>();
    final writer = MockClient((_) {
      putEntered.complete();
      return put.future;
    });
    final reader = _ReadClient();
    addTearDown(writer.close);
    addTearDown(reader.close);
    final write = UiDemoStore.write(key, ['intent'], client: writer);
    await putEntered.future;
    final read = UiDemoStore.read(key, <String>[], client: reader);
    await reader.entered.future;
    put.complete(_value(['normalized']));
    await write;
    reader.response.complete(_value(['before-put']));
    expect(await read, ['normalized']);
    final prefs = await SharedPreferences.getInstance();
    expect(jsonDecode(prefs.getString('ui.$key')!), ['normalized']);
  });

  test('本地编码失败会清理pending意图，后续读取仍可用fallback', () async {
    const key = 'read-after-write-local-failure';
    final client = MockClient((_) async => http.Response('', 503));
    addTearDown(client.close);
    await expectLater(
      UiDemoStore.write(key, [Object()], client: client),
      throwsA(isA<JsonUnsupportedObjectError>()),
    );
    expect(await UiDemoStore.read(key, <String>[], client: client), isEmpty);
  });

  test('旧write响应保护保持，不让新写之后的旧PUT覆盖缓存', () async {
    const key = 'write-protection-preserved';
    final oldResponse = Completer<http.Response>();
    final oldEntered = Completer<void>();
    final older = MockClient((_) {
      oldEntered.complete();
      return oldResponse.future;
    });
    final newer = MockClient((_) async => _value(['new-normalized']));
    addTearDown(older.close);
    addTearDown(newer.close);
    final oldWrite = UiDemoStore.write(key, ['old'], client: older);
    await oldEntered.future;
    expect(await UiDemoStore.write(key, ['new'], client: newer), [
      'new-normalized',
    ]);
    oldResponse.complete(_value(['old-normalized']));
    expect(await oldWrite, isNull);
    final prefs = await SharedPreferences.getInstance();
    expect(jsonDecode(prefs.getString('ui.$key')!), ['new-normalized']);
  });
}
