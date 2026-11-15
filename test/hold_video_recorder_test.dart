import 'dart:async';

import 'package:camera/camera.dart';
import 'package:camera_platform_interface/camera_platform_interface.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jobs_demo_foundation/jobs_demo_foundation.dart';
import 'package:jobs_platform_lab/jobs_platform_lab.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:jobs_flutter_base_config/demos/视频录制直播/长按视频录制.dart';
import 'package:jobs_flutter_base_config/demos/视频录制直播/长按视频文案.dart';

// The camera and channel are explicit test doubles; these assertions do not
// claim a physical camera, photo library, PiP session or filter export ran.
class _RecordingClock extends Stopwatch {
  Duration value = Duration.zero;
  bool active = false;
  @override
  Duration get elapsed => value;
  @override
  bool get isRunning => active;
  @override
  void start() => active = true;
  @override
  void stop() => active = false;
  @override
  void reset() => value = Duration.zero;
}

class _CameraDouble extends CameraPlatform {
  int created = 0, starts = 0, stops = 0, disposed = 0;
  Completer<void>? startGate;
  final audioSettings = <bool>[];

  @override
  Future<List<CameraDescription>> availableCameras() async => const [
    CameraDescription(
      name: 'back',
      lensDirection: CameraLensDirection.back,
      sensorOrientation: 90,
    ),
    CameraDescription(
      name: 'front',
      lensDirection: CameraLensDirection.front,
      sensorOrientation: 90,
    ),
  ];

  @override
  Future<int> createCamera(
    CameraDescription description,
    ResolutionPreset? preset, {
    bool enableAudio = false,
  }) async {
    audioSettings.add(enableAudio);
    return ++created;
  }

  @override
  Future<void> initializeCamera(
    int id, {
    ImageFormatGroup imageFormatGroup = ImageFormatGroup.unknown,
  }) async {}

  @override
  Stream<CameraInitializedEvent> onCameraInitialized(int id) => Stream.value(
    CameraInitializedEvent(
      id,
      1280,
      720,
      ExposureMode.auto,
      true,
      FocusMode.auto,
      true,
    ),
  );

  @override
  Stream<CameraErrorEvent> onCameraError(int id) =>
      StreamController<CameraErrorEvent>().stream;

  @override
  Stream<DeviceOrientationChangedEvent> onDeviceOrientationChanged() =>
      const Stream.empty();

  @override
  Widget buildPreview(int id) => const ColoredBox(
    color: Colors.black,
    key: ValueKey('camera-double-preview'),
  );

  @override
  Future<void> startVideoRecording(int id, {Duration? maxVideoDuration}) async {
    starts++;
    await startGate?.future;
  }

  @override
  Future<XFile> stopVideoRecording(int id) async {
    stops++;
    return XFile('/app/cache/capture-$stops.mp4');
  }

  @override
  Future<void> dispose(int id) async => disposed++;
}

class _BridgeDouble {
  final calls = <MethodCall>[];
  double duration = 4;
  bool rejectPhotos = false;

  Future<Object?> handle(MethodCall call) async {
    calls.add(call);
    switch (call.method) {
      case 'video.import':
        return {
          'name': 'record.mp4',
          'path': '/app/files/record.mp4',
          'duration': duration,
          'bytes': 1000,
          'filter': 'normal',
        };
      case 'video.saveToPhotos':
        if (rejectPhotos)
          throw PlatformException(code: 'permission', message: 'denied');
        return true;
      case 'player.command':
        return {'loading': true, 'pipSupported': true};
      default:
        return true;
    }
  }

  List<MethodCall> matching(String method) =>
      calls.where((call) => call.method == method).toList();
}

Future<void> _flush(WidgetTester tester) async {
  for (var index = 0; index < 8; index++) {
    await tester.pump();
  }
}

Future<(_CameraDouble, _BridgeDouble, _RecordingClock)> _mount(
  WidgetTester tester, {
  Completer<void>? startGate,
}) async {
  final original = CameraPlatform.instance;
  final camera = _CameraDouble()..startGate = startGate;
  final bridge = _BridgeDouble();
  final clock = _RecordingClock();
  CameraPlatform.instance = camera;
  SharedPreferences.setMockInitialValues({});
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
  messenger.setMockMethodCallHandler(JobsPlatformLab.methods, bridge.handle);
  messenger.setMockMethodCallHandler(
    const MethodChannel('jobs_platform_lab/events'),
    (_) async => null,
  );
  messenger.setMockMethodCallHandler(SystemChannels.platform_views, (
    call,
  ) async {
    if (call.method == 'create') return 42;
    if (call.method == 'resize') {
      final args = call.arguments as Map;
      return {'width': args['width'], 'height': args['height']};
    }
    return null;
  });
  addTearDown(() async {
    if (startGate != null && !startGate.isCompleted) startGate.complete();
    await tester.pumpWidget(const SizedBox.shrink());
    await _flush(tester);
    CameraPlatform.instance = original;
    messenger.setMockMethodCallHandler(JobsPlatformLab.methods, null);
    messenger.setMockMethodCallHandler(
      const MethodChannel('jobs_platform_lab/events'),
      null,
    );
    messenger.setMockMethodCallHandler(SystemChannels.platform_views, null);
  });
  await tester.pumpWidget(
    JobsDemoApp(
      home: HoldVideoRecorderDemo(recordingClock: clock),
      settings: JobsDemoSettings(),
    ),
  );
  await _flush(tester);
  expect(find.byKey(const ValueKey('camera-double-preview')), findsOneWidget);
  return (camera, bridge, clock);
}

Future<TestGesture> _hold(WidgetTester tester) async {
  final gesture = await tester.startGesture(
    tester.getCenter(find.byKey(const ValueKey('hold-record-button'))),
  );
  await tester.pump(const Duration(milliseconds: 350));
  await _flush(tester);
  return gesture;
}

Finder _caption(WidgetTester tester, String key) => find.text(
  holdVideoText(tester.element(find.byType(HoldVideoRecorderDemo)), key),
);

void main() {
  final variant = TargetPlatformVariant.only(TargetPlatform.android);
  testWidgets(
    'under three seconds discards the camera file without importing',
    (tester) async {
      final (camera, bridge, clock) = await _mount(tester);
      final gesture = await _hold(tester);
      expect(camera.starts, 1);
      clock.value = const Duration(seconds: 2);
      await tester.pump(const Duration(seconds: 2));
      await gesture.up();
      await _flush(tester);
      expect(camera.stops, 1);
      expect(bridge.matching('video.import'), isEmpty);
      expect(bridge.matching('video.discard'), hasLength(1));
      expect(_caption(tester, '录制至少3秒'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
    variant: variant,
  );

  testWidgets(
    'release imports a valid take, photo denial preserves retry, success restores microphone capture',
    (tester) async {
      final (camera, bridge, clock) = await _mount(tester);
      final gesture = await _hold(tester);
      clock.value = const Duration(seconds: 4);
      await tester.pump(const Duration(seconds: 4));
      await gesture.up();
      await _flush(tester);
      expect(camera.stops, 1);
      expect(bridge.matching('video.import'), hasLength(1));
      expect(
        (bridge.matching('video.import').single.arguments as Map)['path'],
        '/app/cache/capture-1.mp4',
      );
      expect(camera.audioSettings, [true, false]);
      bridge.rejectPhotos = true;
      await tester.tap(_caption(tester, '保存到相册'));
      await _flush(tester);
      expect(_caption(tester, '保存失败可重试'), findsOneWidget);
      expect(bridge.matching('video.delete'), isEmpty);
      bridge.rejectPhotos = false;
      await tester.tap(_caption(tester, '保存到相册'));
      await _flush(tester);
      expect(bridge.matching('video.saveToPhotos'), hasLength(2));
      expect(find.byKey(const ValueKey('hold-record-button')), findsOneWidget);
      expect(camera.audioSettings.last, isTrue);
      expect(tester.takeException(), isNull);
    },
    variant: variant,
  );

  testWidgets('slide upward cancels even a take longer than the minimum', (
    tester,
  ) async {
    final (camera, bridge, clock) = await _mount(tester);
    final gesture = await _hold(tester);
    clock.value = const Duration(seconds: 4);
    await tester.pump(const Duration(seconds: 4));
    await gesture.moveBy(const Offset(0, -100));
    await tester.pump();
    await gesture.up();
    await _flush(tester);
    expect(camera.stops, 1);
    expect(bridge.matching('video.import'), isEmpty);
    expect(bridge.matching('video.discard'), hasLength(1));
    expect(tester.takeException(), isNull);
  }, variant: variant);

  testWidgets(
    'releasing while native start is pending cannot revive recording',
    (tester) async {
      final gate = Completer<void>();
      final (camera, bridge, _) = await _mount(tester, startGate: gate);
      final gesture = await _hold(tester);
      expect(camera.starts, 1);
      await gesture.up();
      gate.complete();
      await _flush(tester);
      expect(camera.stops, 1);
      expect(bridge.matching('video.import'), isEmpty);
      expect(bridge.matching('video.discard'), hasLength(1));
      expect(tester.takeException(), isNull);
    },
    variant: variant,
  );

  testWidgets(
    'sixty-second limit stops once and later pointer-up does not duplicate import',
    (tester) async {
      final (camera, bridge, clock) = await _mount(tester);
      final gesture = await _hold(tester);
      bridge.duration = 60;
      clock.value = const Duration(seconds: 60);
      await tester.pump(const Duration(seconds: 60));
      await _flush(tester);
      await gesture.up();
      await _flush(tester);
      expect(camera.stops, 1);
      expect(bridge.matching('video.import'), hasLength(1));
      expect(tester.takeException(), isNull);
    },
    variant: variant,
  );

  testWidgets(
    'leaving during pending native start stops and discards the late camera file',
    (tester) async {
      final gate = Completer<void>();
      final (camera, bridge, _) = await _mount(tester, startGate: gate);
      final gesture = await _hold(tester);
      await tester.pumpWidget(const SizedBox.shrink());
      gate.complete();
      await _flush(tester);
      await gesture.up();
      expect(camera.stops, 1);
      expect(bridge.matching('video.import'), isEmpty);
      expect(bridge.matching('video.discard'), hasLength(1));
      expect(tester.takeException(), isNull);
    },
    variant: variant,
  );
  testWidgets(
    'actual media duration below the minimum is rejected after import',
    (tester) async {
      final (camera, bridge, clock) = await _mount(tester);
      bridge.duration = 2.8;
      final gesture = await _hold(tester);
      clock.value = const Duration(seconds: 4);
      await tester.pump(const Duration(seconds: 4));
      await gesture.up();
      await _flush(tester);
      expect(camera.stops, 1);
      expect(bridge.matching('video.import'), hasLength(1));
      expect(bridge.matching('video.delete'), hasLength(1));
      expect(bridge.matching('video.saveToPhotos'), isEmpty);
      expect(find.byKey(const ValueKey('hold-record-button')), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
    variant: variant,
  );
}
