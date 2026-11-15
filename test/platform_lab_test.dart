import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jobs_demo_foundation/jobs_demo_foundation.dart';
import 'package:jobs_platform_lab/jobs_platform_lab.dart';
import 'package:jobs_flutter_base_config/demo_hub/platform_catalog.dart';
import 'package:jobs_flutter_base_config/demo_hub/platform_support.dart';
import 'package:jobs_flutter_base_config/demo_hub/platform_strings.dart';

// Native-channel contract tests use explicit test doubles; hardware success is not inferred.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(JobsPlatformLab.methods, (call) async {
          if (call.method == 'capabilities') {
            return {'platform': 'test', 'ble': true};
          }
          if (call.method == 'audio.list' || call.method == 'video.list') {
            return [];
          }
          return true;
        });
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('jobs_platform_lab/events'),
          (_) async => null,
        );
  });
  tearDown(() {
    debugDefaultTargetPlatformOverride = null;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(JobsPlatformLab.methods, null);
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('jobs_platform_lab/events'),
          null,
        );
  });
  test(
    'channel preserves byte payload and does not fabricate a value',
    () async {
      MethodCall? request;
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(JobsPlatformLab.methods, (call) async {
            request = call;
            return {'written': 3};
          });
      expect(
        await JobsPlatformLab.invoke('ble.write', {
          'bytes': [1, 2, 255],
          'response': true,
        }),
        {'written': 3},
      );
      expect(request!.arguments, {
        'bytes': [1, 2, 255],
        'response': true,
      });
    },
  );
  test('unsupported platforms throw instead of reporting a simulated native result', () async {
    debugDefaultTargetPlatformOverride = TargetPlatform.linux;
    await expectLater(
      JobsPlatformLab.invoke('capabilities'),
      throwsUnsupportedError,
    );
  });
  test(
    'controller exposes errors and remains safe if disposed during operation',
    () async {
      debugDefaultTargetPlatformOverride = TargetPlatform.android;
      final controller = NativeLabState();
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
            JobsPlatformLab.methods,
            (_) async =>
                throw PlatformException(code: 'permission', message: 'denied'),
          );
      expect(await controller.run('audio.start'), isNull);
      expect(controller.logs.single, contains('permission'));
      controller.dispose();
      controller.add('late callback');
    },
  );
  test('platform strings have complete ten-language rows', () {
    expect(
      platformTranslations.values.every(
        (values) => values.length == 10 && values.every((v) => v.isNotEmpty),
      ),
      isTrue,
    );
  });
  test(
    'stop remains available while a publish acknowledgement is pending',
    () async {
      debugDefaultTargetPlatformOverride = TargetPlatform.android;
      final publish = Completer<bool>();
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(JobsPlatformLab.methods, (call) async {
            return call.method == 'rtmp.start' ? publish.future : true;
          });
      final controller = NativeLabState();
      final pending = controller.run('rtmp.start');
      expect(controller.busy, isTrue);
      expect(await controller.run('rtmp.stop'), isTrue);
      expect(controller.busy, isTrue);
      publish.complete(false);
      await pending;
      expect(controller.busy, isFalse);
      controller.dispose();
    },
  );
  testWidgets('edited URL is passed to the native adapter', (tester) async {
    MethodCall? request;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(JobsPlatformLab.methods, (call) async {
          request = call;
          return true;
        });
    final demo = platformDemos.singleWhere(
      (entry) => entry.id == 'platform-system',
    );
    await tester.pumpWidget(
      JobsDemoApp(
        home: Builder(builder: demo.builder),
        settings: JobsDemoSettings(),
      ),
    );
    await tester.pump();
    await tester.enterText(
      find.byType(TextField).at(1),
      'https://example.org/jobs',
    );
    await tester.pump();
    await tester.ensureVisible(find.text('打开URL'));
    await tester.tap(find.text('打开URL'));
    await tester.pump();
    expect(request?.method, 'url.open');
    expect(request?.arguments, {'url': 'https://example.org/jobs'});
  }, variant: TargetPlatformVariant.only(TargetPlatform.android));

  test('CRC16 sample protocol validates frames and MTU fragmentation', () {
    final payload = List<int>.generate(250, (index) => index);
    final encoded = JobsBleCodec.encode(payload);
    expect(JobsBleCodec.decode(encoded), payload);
    expect(JobsBleCodec.fragments(encoded, 20).expand((e) => e), encoded);
    final damaged = encoded.toList()..[3] = 255;
    expect(() => JobsBleCodec.decode(damaged), throwsFormatException);
  });
  test('BLE queue serializes retries and preserves recording replay', () async {
    final queue = JobsBleCommandQueue();
    var attempts = 0;
    final order = <int>[];
    final first = queue.enqueue(() async {
      attempts++;
      if (attempts == 1) throw StateError('transient');
      order.add(1);
      return 1;
    }, retries: 1);
    final second = queue.enqueue(() async {
      order.add(2);
      return 2;
    });
    expect(await first, 1);
    expect(await second, 2);
    expect(order, [1, 2]);
    final trace = JobsBleTrace()..append('write', [1, 2, 3]);
    final replay = JobsBleTrace()..import(trace.export());
    expect(replay.events, trace.events);
  });

  test('explicit mock peripheral runs read/write/notify lifecycle', () async {
    final events = <Map<String, dynamic>>[];
    final mock = JobsMockBlePeripheral(onEvent: events.add);
    await mock.handle('ble.scan', {});
    expect(events.single['mock'], isTrue);
    await mock.handle('ble.connect', {});
    await mock.handle('ble.notify', {'enabled': true});
    await mock.handle('ble.write', {
      'bytes': [7, 8, 9],
    });
    expect((await mock.handle('ble.read', {}))['bytes'], [7, 8, 9]);
    expect(events.last['event'], 'value');
    await mock.handle('ble.disconnect', {});
    await expectLater(mock.handle('ble.read', {}), throwsStateError);
  });
  for (final demo in platformDemos) {
    testWidgets(
      '${demo.id} mounts on unsupported AR test environment and disposes',
      (tester) async {
        await tester.pumpWidget(
          JobsDemoApp(
            home: Builder(builder: demo.builder),
            settings: JobsDemoSettings(),
          ),
        );
        await tester.pump(const Duration(milliseconds: 100));
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox.shrink());
        await tester.pump(const Duration(milliseconds: 100));
        expect(tester.takeException(), isNull);
      },
      variant: TargetPlatformVariant.only(TargetPlatform.android),
    );
  }
}
