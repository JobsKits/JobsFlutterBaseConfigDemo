import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jobs_demo_foundation/jobs_demo_foundation.dart';
import 'package:jobs_flutter_base_config/demos/播放器实验室/播放器实验室.dart';
import 'package:jobs_flutter_base_config/demos/播放器实验室/播放质量状态.dart';
import 'package:jobs_flutter_base_config/demos/播放器实验室/播放质量文案.dart';
import 'package:jobs_platform_lab/jobs_platform_lab.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test('Ready and first position advance have distinct measured clocks', () {
    var now = Duration.zero;
    final quality = PlayerQualityState(clock: () => now);
    addTearDown(quality.dispose);
    quality.begin('url:A');
    now = const Duration(milliseconds: 120);
    quality.observe(position: 0, playing: false, ready: true);
    expect(quality.readyLatency, const Duration(milliseconds: 120));
    expect(quality.firstProgressLatency, isNull);
    now = const Duration(milliseconds: 370);
    quality.observe(position: .4, playing: true);
    expect(quality.firstProgressLatency, const Duration(milliseconds: 370));
    now = const Duration(seconds: 1);
    quality.observe(position: 1, playing: true, ready: true);
    expect(quality.readyLatency, const Duration(milliseconds: 120));
    expect(quality.firstProgressLatency, const Duration(milliseconds: 370));
  });
  test('Only explicit supported post-ready buffering is counted; pause closes interval', () {
    var now = Duration.zero;
    final quality = PlayerQualityState(clock: () => now);
    addTearDown(quality.dispose);
    quality.begin('url:A', reportsBuffering: true);
    quality.observe(position: 0, playing: false, isBuffering: true);
    expect(quality.bufferingCount, 0);
    quality.observe(
      position: 0,
      playing: true,
      ready: true,
      isBuffering: false,
    );
    now = const Duration(seconds: 1);
    quality.observe(position: 1, playing: true, isBuffering: true);
    now = const Duration(milliseconds: 1700);
    quality.observe(position: 1, playing: false, isBuffering: true);
    expect(quality.bufferingCount, 1);
    expect(quality.bufferedDuration, const Duration(milliseconds: 700));
    quality.intent(false);
    now = const Duration(seconds: 3);
    quality.observe(position: 1, playing: false, isBuffering: true);
    expect(quality.bufferingCount, 1);
    expect(quality.bufferedDuration, const Duration(milliseconds: 700));
    quality.begin('native:B');
    quality.observe(position: 1, playing: true, ready: true, isBuffering: true);
    expect(quality.bufferingReported, isFalse);
    expect(quality.bufferingCount, 0);
  });
  test('Source checkpoints isolate fallback and URL changes, preserve pause and clamp short duration', () {
    final quality = PlayerQualityState();
    addTearDown(quality.dispose);
    quality.remember('url:A', 42, false);
    quality.remember('asset:welcome', 3, true);
    expect(quality.checkpoint('url:A')!.position, 42);
    expect(quality.checkpoint('url:A')!.playing, isFalse);
    expect(quality.checkpoint('url:B'), isNull);
    expect(quality.checkpoint('url:A')!.seekPosition(10), closeTo(9.9, .001));
    expect(quality.checkpoint('url:A')!.seekPosition(.05), 0);
    quality.remember('url:A', double.nan, true);
    expect(quality.checkpoint('url:A')!.position, 42);
    quality.begin('url:A', restoring: quality.checkpoint('url:A'));
    quality.observe(position: 42, playing: false, ready: true);
    expect(quality.firstProgressLatency, isNull);
    quality.failed();
    quality.fellBack();
    quality.recovering();
    expect(
      [quality.errorCount, quality.fallbackCount, quality.recoveryCount],
      [1, 1, 1],
    );
  });
  test('Quality translations cover all ten languages', () {
    for (final row in playerQualityTranslations.entries) {
      expect(row.value.length, 10, reason: row.key);
      expect(row.value.every((s) => s.trim().isNotEmpty), isTrue);
    }
  });

  Future<void> flush(WidgetTester tester) async {
    for (var i = 0; i < 8; i++) {
      await tester.pump();
    }
  }

  Future<(dynamic, List<Map<String, dynamic>>)> nativePlayer(
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    debugDefaultTargetPlatformOverride = TargetPlatform.android;
    final commands = <Map<String, dynamic>>[];
    final messenger =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    messenger.setMockMethodCallHandler(JobsPlatformLab.methods, (call) async {
      if (call.method == 'player.command') {
        commands.add(Map<String, dynamic>.from(call.arguments as Map));
        return {'loading': true, 'pipSupported': true};
      }
      return true;
    });
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
    messenger.setMockMessageHandler('flutter/assets', (message) async {
      final key = utf8.decode(
        message!.buffer.asUint8List(
          message.offsetInBytes,
          message.lengthInBytes,
        ),
      );
      if (key == 'assets/Video/AppLaunchAssets/appLaunch_welcome.mp4')
        return ByteData.sublistView(Uint8List.fromList([0, 1, 2, 3]));
      return null;
    });
    final settings = JobsDemoSettings();
    addTearDown(() async {
      await tester.pumpWidget(const SizedBox.shrink());
      await flush(tester);
      settings.dispose();
      messenger.setMockMessageHandler('flutter/assets', null);
      messenger.setMockMethodCallHandler(JobsPlatformLab.methods, null);
      messenger.setMockMethodCallHandler(
        const MethodChannel('jobs_platform_lab/events'),
        null,
      );
      messenger.setMockMethodCallHandler(SystemChannels.platform_views, null);
      debugDefaultTargetPlatformOverride = null;
    });
    await tester.pumpWidget(
      JobsDemoApp(
        settings: settings,
        showSettings: false,
        home: const PlayerLaboratoryDemo(
          initialMode: 1,
          initialSource: 'https://example.org/a.mp4',
        ),
      ),
    );
    await tester.tap(find.byKey(const ValueKey('player-load')));
    await flush(tester);
    final dynamic state = tester.state(find.byType(PlayerLaboratoryDemo));
    return (state, commands);
  }

  testWidgets(
    'Native error falls back locally; original retry restores only original source checkpoint and pause intent',
    (tester) async {
      final (state, calls) = await nativePlayer(tester);
      final id = calls.last['viewId'];
      state.event({
        'viewId': id,
        'event': 'ready',
        'duration': 100.0,
        'position': 0.0,
        'isPlaying': true,
      });
      state.event({
        'viewId': id,
        'event': 'progress',
        'duration': 100.0,
        'position': 34.0,
        'isPlaying': true,
      });
      await state.action('pause');
      state.event({
        'viewId': id,
        'event': 'error',
        'duration': 100.0,
        'position': 34.0,
        'isPlaying': false,
      });
      await tester.runAsync(() async {
        await Future<void>.delayed(const Duration(milliseconds: 20));
      });
      await flush(tester);
      expect(
        calls.where((c) => c['action'] == 'load').last.containsKey('bytes'),
        isTrue,
      );
      final fallbackId = calls
          .where((c) => c['action'] == 'load')
          .last['viewId'];
      expect(fallbackId, isNot(id));
      state.event({
        'viewId': fallbackId,
        'event': 'ready',
        'duration': 4.0,
        'position': 0.0,
        'isPlaying': true,
      });
      await flush(tester);
      expect(
        calls.where((c) => c['action'] == 'seek'),
        isEmpty,
        reason: 'Network checkpoint must never seek the fallback asset',
      );
      unawaited(state.start(resume: true) as Future<void>);
      await flush(tester);
      expect(
        calls.where((c) => c['action'] == 'load').last['url'],
        'https://example.org/a.mp4',
      );
      expect(
        calls.where((c) => c['action'] == 'load').last['autoplay'],
        isFalse,
      );
      state.event({
        'viewId': id,
        'event': 'ready',
        'duration': 4.0,
        'position': 2.0,
        'isPlaying': true,
      });
      expect(state.ready, isFalse);
      final retryId = calls.where((c) => c['action'] == 'load').last['viewId'];
      expect(retryId, isNot(fallbackId));
      state.event({
        'viewId': retryId,
        'event': 'ready',
        'duration': 100.0,
        'position': 0.0,
        'isPlaying': false,
      });
      await flush(tester);
      expect(calls.where((c) => c['action'] == 'seek').last['seconds'], 34.0);
      expect(calls.last['action'], 'pause');
      expect((state.quality as PlayerQualityState).recoveryCount, 1);
      expect((state.quality as PlayerQualityState).fallbackCount, 1);
      await tester.scrollUntilVisible(
        find.byKey(const ValueKey('player-quality-panel')),
        280,
        scrollable: find.byType(Scrollable).first,
      );
      expect(
        find.byKey(const ValueKey('player-quality-panel')),
        findsOneWidget,
      );
    },
  );
  testWidgets(
    'Native readiness watchdog falls back once and stops at local failure; exit cancels timer',
    (tester) async {
      final (state, calls) = await nativePlayer(tester);
      await tester.pump(const Duration(milliseconds: 4100));
      await tester.runAsync(() async {
        await Future<void>.delayed(const Duration(milliseconds: 20));
      });
      await flush(tester);
      expect(calls.where((c) => c['action'] == 'load').length, 2);
      await tester.pump(const Duration(milliseconds: 4100));
      await flush(tester);
      expect(calls.where((c) => c['action'] == 'load').length, 2);
      expect(state.loading, isFalse);
      expect(state.ready, isFalse);
      expect((state.quality as PlayerQualityState).errorCount, 2);
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump(const Duration(seconds: 5));
      expect(tester.takeException(), isNull);
    },
  );
}
