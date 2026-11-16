import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jobs_demo_foundation/jobs_demo_foundation.dart';
import 'package:jobs_demo_foundation/jobs_edge_refresh.dart';
import 'package:jobs_refresh_load/jobs_refresh_load.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('success history is per role/key and failure/cancellation never advances it', () async {
    var instant = DateTime(2026, 11, 16, 12);
    var failed = false;
    var calls = 0;
    final controller = JobsEdgeRefreshController(
      historyKey: 'inbox',
      now: () => instant,
      onTrigger: (_) async {
        calls++;
        if (failed) throw StateError('network');
      },
    );
    await controller.historyReady;
    expect(controller.lastRefreshedAt, isNull);
    expect(controller.lastLoadedAt, isNull);
    controller.setExtent(-20);
    await controller.release();
    expect(calls, 0);
    expect(await controller.run(JobsRefreshEdge.leading), isTrue);
    final refresh = instant;
    instant = instant.add(const Duration(minutes: 1));
    expect(await controller.run(JobsRefreshEdge.trailing), isTrue);
    final load = instant;
    failed = true;
    instant = instant.add(const Duration(days: 1));
    expect(await controller.run(JobsRefreshEdge.leading), isFalse);
    expect(controller.outcome, JobsEdgeRefreshOutcome.failure);
    expect(controller.lastRefreshedAt, refresh);
    expect(controller.lastLoadedAt, load);
    final restored = JobsEdgeRefreshController(
      historyKey: 'inbox',
      onTrigger: (_) async {},
    );
    final other = JobsEdgeRefreshController(
      historyKey: 'outbox',
      onTrigger: (_) async {},
    );
    await Future.wait([restored.historyReady, other.historyReady]);
    expect(restored.lastRefreshedAt, refresh);
    expect(restored.lastLoadedAt, load);
    expect(other.lastRefreshedAt, isNull);
    expect(other.lastLoadedAt, isNull);
    failed = false;
    expect(await controller.run(JobsRefreshEdge.leading), isTrue);
    expect(controller.lastRefreshedAt, instant);
    controller.dispose();
    restored.dispose();
    other.dispose();
  });

  test('in-flight leading/trailing mutually exclude and dispose ignores late completion', () async {
    final pending = Completer<void>();
    var calls = 0;
    var notifications = 0;
    final controller = JobsEdgeRefreshController(
      historyKey: 'late',
      onTrigger: (_) {
        calls++;
        return pending.future;
      },
    );
    await controller.historyReady;
    controller.addListener(() => notifications++);
    final first = controller.run(JobsRefreshEdge.leading);
    expect(await controller.run(JobsRefreshEdge.trailing), isFalse);
    controller.setExtent(100);
    expect(controller.phase, JobsEdgeRefreshPhase.running);
    expect(calls, 1);
    controller.dispose();
    final before = notifications;
    pending.complete();
    expect(await first, isFalse);
    expect(notifications, before);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getInt('jobs_refresh.late.refresh'), isNull);
  });

  test('roles can reverse and no-more blocks only the load role until refresh resets it', () async {
    var calls = 0;
    late final JobsEdgeRefreshController controller;
    controller = JobsEdgeRefreshController(
      refreshEdge: JobsRefreshEdge.trailing,
      onTrigger: (_) async {
        calls++;
        if (controller.isRefresh) controller.setHasMore(true);
      },
    );
    controller.setHasMore(false);
    expect(await controller.run(JobsRefreshEdge.leading), isFalse);
    expect(controller.outcome, JobsEdgeRefreshOutcome.noMore);
    expect(calls, 0);
    expect(await controller.run(JobsRefreshEdge.trailing), isTrue);
    expect(controller.hasMore, isTrue);
    expect(controller.lastRefreshedAt, isNotNull);
    expect(controller.lastLoadedAt, isNull);
    expect(await controller.run(JobsRefreshEdge.leading), isTrue);
    expect(controller.lastLoadedAt, isNotNull);
    expect(calls, 2);
    controller.dispose();
  });

  test('pagination failure preserves page/items, retries the same page and does not race refresh', () async {
    final requested = <int>[];
    final pending = Completer<List<int>>();
    var retry = false;
    final controller = JobsRefreshLoadController<int>(
      pageSize: 2,
      fetchPage: (page, size) {
        requested.add(page);
        if (page == 1) return Future.value([1, 2]);
        if (retry) return Future.value([3]);
        return pending.future;
      },
    );
    await controller.refresh(userInitiated: false);
    final refreshed = controller.lastRefreshedAt;
    final load = controller.loadMore(userInitiated: false);
    await controller.refresh(userInitiated: false);
    expect(requested, [1, 2]);
    pending.completeError(StateError('offline'));
    await load;
    expect(controller.page, 1);
    expect(controller.items, [1, 2]);
    expect(controller.lastRefreshedAt, refreshed);
    expect(controller.lastLoadedAt, isNull);
    retry = true;
    await controller.loadMore(userInitiated: false);
    expect(requested, [1, 2, 2]);
    expect(controller.page, 2);
    expect(controller.items, [1, 2, 3]);
    expect(controller.hasMore, isFalse);
    await controller.loadMore(userInitiated: false);
    expect(requested, [1, 2, 2]);
    await controller.refresh(userInitiated: false);
    expect(controller.page, 1);
    expect(controller.items, [1, 2]);
    expect(controller.hasMore, isTrue);
    controller.dispose();
  });

  test('pagination disposal prevents late item mutation and listener notifications', () async {
    final pending = Completer<List<int>>();
    var notifications = 0;
    final controller = JobsRefreshLoadController<int>(
      fetchPage: (_, __) => pending.future,
    );
    controller.addListener(() => notifications++);
    final refresh = controller.refresh(userInitiated: false);
    controller.dispose();
    final before = notifications;
    pending.complete([1]);
    await refresh;
    expect(controller.items, isEmpty);
    expect(notifications, before);
  });

  Future<void> mount(
    WidgetTester tester, {
    required JobsEdgeRefreshController controller,
    Axis axis = Axis.vertical,
    bool reverse = false,
    TextDirection direction = TextDirection.ltr,
    JobsDemoSettings? settings,
    void Function(JobsRefreshFeedbackEvent)? feedback,
    Widget? child,
    double? viewportHeight,
    Widget? indicatorAnimation,
  }) => tester.pumpWidget(
    JobsDemoApp(
      settings:
          settings ??
          JobsDemoSettings(
            refreshStyle: JobsRefreshStyle.jobs,
            refreshHaptics: false,
            refreshSound: false,
          ),
      showSettings: false,
      home: Directionality(
        textDirection: direction,
        child: Scaffold(
          body: SizedBox(
            height: viewportHeight,
            child: JobsEdgeRefreshView(
              axis: axis,
              controller: controller,
              onFeedback: feedback,
              indicatorBuilder: (_, state) => JobsRefreshIndicator(
                controller: state,
                axis: axis,
                animation: indicatorAnimation,
              ),
              child:
                  child ??
                  ListView.builder(
                    key: const ValueKey('list'),
                    scrollDirection: axis,
                    reverse: reverse,
                    physics: const JobsRefreshScrollPhysics(
                      parent: AlwaysScrollableScrollPhysics(),
                    ),
                    itemCount: 5,
                    itemBuilder: (_, index) => SizedBox(
                      width: 80,
                      height: 56,
                      child: Text('row-$index', key: ValueKey('row-$index')),
                    ),
                  ),
            ),
          ),
        ),
      ),
    ),
  );

  Future<void> finish(WidgetTester tester, Completer<void> pending) async {
    pending.complete();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pumpAndSettle();
  }

  for (final axis in Axis.values) {
    for (final reverse in [false, true]) {
      for (final direction in TextDirection.values) {
        for (final edge in JobsRefreshEdge.values) {
          testWidgets(
            'real short-list drag $axis reverse=$reverse $direction $edge holds content then returns',
            (tester) async {
              final pending = Completer<void>();
              final calls = <JobsRefreshEdge>[];
              final controller = JobsEdgeRefreshController(
                completionDuration: const Duration(milliseconds: 350),
                onTrigger: (value) {
                  calls.add(value);
                  return pending.future;
                },
              );
              await mount(
                tester,
                controller: controller,
                axis: axis,
                reverse: reverse,
                direction: direction,
              );
              await tester.pump();
              final list = find.byKey(const ValueKey('list'));
              final row = find.byKey(
                ValueKey(edge == JobsRefreshEdge.leading ? 'row-0' : 'row-4'),
              );
              final before = tester.getTopLeft(row);
              final position = tester
                  .state<ScrollableState>(find.byType(Scrollable))
                  .position;
              final forward =
                  position.axisDirection == AxisDirection.down ||
                  position.axisDirection == AxisDirection.right;
              final sign =
                  (forward ? 1.0 : -1.0) *
                  (edge == JobsRefreshEdge.leading ? 1.0 : -1.0);
              final delta = axis == Axis.vertical
                  ? Offset(0, sign * 150)
                  : Offset(sign * 150, 0);
              final gesture = await tester.startGesture(tester.getCenter(list));
              await gesture.moveBy(delta);
              await tester.pump();
              await gesture.moveBy(delta);
              await tester.pump();
              expect(controller.phase, JobsEdgeRefreshPhase.ready);
              expect(controller.edge, edge);
              expect(calls, isEmpty);
              final pulled = tester.getTopLeft(row) - before;
              expect(
                (axis == Axis.vertical ? pulled.dy : pulled.dx) * sign,
                greaterThan(0),
              );
              expect(position.pixels.abs(), lessThanOrEqualTo(120.01));
              await gesture.up();
              await tester.pump();
              await tester.pump(const Duration(milliseconds: 400));
              expect(calls, [edge]);
              expect(controller.busy, isTrue);
              final held = tester.getTopLeft(row) - before;
              expect(
                (axis == Axis.vertical ? held.dy : held.dx) * sign,
                greaterThanOrEqualTo(63),
              );
              expect(find.byType(JobsRefreshIndicator), findsOneWidget);
              await finish(tester, pending);
              expect(controller.phase, JobsEdgeRefreshPhase.idle);
              final returned = tester.getTopLeft(row) - before;
              expect(returned.distance, lessThan(.6));
              expect(tester.takeException(), isNull);
              await tester.pumpWidget(const SizedBox());
              controller.dispose();
            },
          );
        }
      }
    }
  }

  testWidgets(
    'finite horizontal ready drag keeps indicator and full history inside its revealed clip for both edges',
    (tester) async {
      for (final reverse in [false, true]) {
        for (final direction in TextDirection.values) {
          for (final edge in JobsRefreshEdge.values) {
            final scenario = 'reverse=$reverse $direction $edge';
            final key = 'finite-horizontal-$scenario';
            final today = DateTime.now();
            final instant = DateTime(
              today.year,
              today.month,
              today.day,
              14,
              5,
              6,
            );
            SharedPreferences.setMockInitialValues({
              'jobs_refresh.$key.refresh': instant.millisecondsSinceEpoch,
              'jobs_refresh.$key.load': instant.millisecondsSinceEpoch,
            });
            final pending = Completer<void>();
            final calls = <JobsRefreshEdge>[];
            final controller = JobsEdgeRefreshController(
              historyKey: key,
              completionDuration: const Duration(milliseconds: 350),
              onTrigger: (value) {
                calls.add(value);
                return pending.future;
              },
            );
            await controller.historyReady;
            await mount(
              tester,
              controller: controller,
              axis: Axis.horizontal,
              reverse: reverse,
              direction: direction,
              viewportHeight: 120,
              indicatorAnimation: const SizedBox.square(
                dimension: 28,
                child: Icon(Icons.sync),
              ),
            );
            await tester.pump();
            final list = find.byKey(const ValueKey('list'));
            final row = find.byKey(
              ValueKey(edge == JobsRefreshEdge.leading ? 'row-0' : 'row-4'),
            );
            final before = tester.getTopLeft(row);
            final position = tester
                .state<ScrollableState>(find.byType(Scrollable))
                .position;
            final sign =
                (position.axisDirection == AxisDirection.right ? 1.0 : -1.0) *
                (edge == JobsRefreshEdge.leading ? 1.0 : -1.0);
            final gesture = await tester.startGesture(tester.getCenter(list));
            // 用真实手势停在有限揭示区，不把列表拉满到默认112指示宽度。
            for (var step = 0; step < 30 && controller.distance < 78; step++) {
              await gesture.moveBy(Offset(sign * 12, 0));
              await tester.pump();
            }
            expect(
              controller.distance,
              inInclusiveRange(78, 90),
              reason: scenario,
            );
            expect(
              controller.phase,
              JobsEdgeRefreshPhase.ready,
              reason: scenario,
            );
            expect(controller.edge, edge, reason: scenario);
            expect(calls, isEmpty, reason: scenario);

            void expectFullyRevealed() {
              final indicator = find.byType(JobsRefreshIndicator);
              RenderClipRect? clip;
              indicator.evaluate().single.visitAncestorElements((element) {
                if (element.renderObject case final RenderClipRect value) {
                  clip = value;
                  return false;
                }
                return true;
              });
              expect(clip, isNotNull, reason: scenario);
              final revealed = clip!.localToGlobal(Offset.zero) & clip!.size;
              final indicatorBounds = tester.getRect(indicator);
              expect(
                indicatorBounds.left,
                greaterThanOrEqualTo(revealed.left - .1),
                reason: scenario,
              );
              expect(
                indicatorBounds.right,
                lessThanOrEqualTo(revealed.right + .1),
                reason: scenario,
              );
              final history = find.descendant(
                of: indicator,
                matching: find.byWidgetPredicate(
                  (widget) =>
                      widget is Text && (widget.data?.contains('上次') ?? false),
                ),
              );
              expect(history, findsOneWidget, reason: scenario);
              final paragraph = tester.renderObject<RenderParagraph>(history);
              final transform = paragraph.getTransformTo(null);
              final textBounds = MatrixUtils.transformRect(
                transform,
                Offset.zero & paragraph.size,
              );
              expect(
                textBounds.left,
                greaterThanOrEqualTo(revealed.left - .1),
                reason: scenario,
              );
              expect(
                textBounds.right,
                lessThanOrEqualTo(revealed.right + .1),
                reason: scenario,
              );
              expect(
                textBounds.top,
                greaterThanOrEqualTo(revealed.top - .1),
                reason: scenario,
              );
              expect(
                textBounds.bottom,
                lessThanOrEqualTo(revealed.bottom + .1),
                reason: scenario,
              );
              expect(
                find.textContaining('14:05:06'),
                findsOneWidget,
                reason: scenario,
              );
              final painted = paragraph.text.toPlainText();
              final timeStart = painted.indexOf('14:05:06');
              expect(timeStart, greaterThanOrEqualTo(0), reason: scenario);
              for (var index = timeStart; index < timeStart + 8; index++) {
                final boxes = paragraph.getBoxesForSelection(
                  TextSelection(baseOffset: index, extentOffset: index + 1),
                );
                expect(
                  boxes,
                  isNotEmpty,
                  reason: '$scenario time character $index',
                );
                for (final box in boxes) {
                  expect(
                    box.bottom,
                    lessThanOrEqualTo(paragraph.size.height + .1),
                    reason:
                        '$scenario time character $index local paint height',
                  );
                  final glyph = MatrixUtils.transformRect(
                    transform,
                    box.toRect(),
                  );
                  expect(
                    glyph.left,
                    greaterThanOrEqualTo(revealed.left - .1),
                    reason: scenario,
                  );
                  expect(
                    glyph.right,
                    lessThanOrEqualTo(revealed.right + .1),
                    reason: scenario,
                  );
                  expect(
                    glyph.top,
                    greaterThanOrEqualTo(revealed.top - .1),
                    reason: scenario,
                  );
                  expect(
                    glyph.bottom,
                    lessThanOrEqualTo(revealed.bottom + .1),
                    reason: scenario,
                  );
                }
              }
            }

            expectFullyRevealed();
            await tester.pump(const Duration(milliseconds: 300));
            expectFullyRevealed();
            await gesture.up();
            await tester.pump();
            await tester.pump(const Duration(milliseconds: 400));
            expect(calls, [edge], reason: scenario);
            expect(controller.busy, isTrue, reason: scenario);
            expectFullyRevealed();
            await finish(tester, pending);
            expect(
              controller.phase,
              JobsEdgeRefreshPhase.idle,
              reason: scenario,
            );
            expect(
              (tester.getTopLeft(row) - before).distance,
              lessThan(.6),
              reason: scenario,
            );
            expect(tester.takeException(), isNull, reason: scenario);
            await tester.pumpWidget(const SizedBox());
            controller.dispose();
          }
        }
      }
    },
  );

  testWidgets('adaptive wrapper borrows a controller without disposing it', (
    tester,
  ) async {
    var calls = 0;
    final controller = JobsEdgeRefreshController(
      onTrigger: (_) async => calls++,
    );
    await tester.pumpWidget(
      JobsDemoApp(
        settings: JobsDemoSettings(
          refreshStyle: JobsRefreshStyle.jobs,
          refreshHaptics: false,
          refreshSound: false,
        ),
        showSettings: false,
        home: JobsAdaptiveRefresh(
          controller: controller,
          onRefresh: () async {},
          child: ListView(children: const [Text('row')]),
        ),
      ),
    );
    await tester.pumpWidget(const SizedBox());
    expect(controller.disposed, isFalse);
    expect(await controller.run(JobsRefreshEdge.leading), isTrue);
    expect(calls, 1);
    controller.dispose();
  });

  testWidgets('nested perpendicular notifications do not arm the outer axis', (
    tester,
  ) async {
    var calls = 0;
    final controller = JobsEdgeRefreshController(
      onTrigger: (_) async => calls++,
    );
    await mount(
      tester,
      controller: controller,
      child: ListView(
        children: [
          SizedBox(
            height: 150,
            child: ListView.builder(
              key: const ValueKey('inner'),
              scrollDirection: Axis.horizontal,
              physics: const JobsRefreshScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
              itemCount: 1,
              itemBuilder: (_, __) =>
                  const SizedBox(width: 80, child: Text('inner')),
            ),
          ),
        ],
      ),
    );
    await tester.drag(
      find.byKey(const ValueKey('inner')),
      const Offset(280, 0),
    );
    await tester.pumpAndSettle();
    expect(calls, 0);
    expect(controller.phase, JobsEdgeRefreshPhase.idle);
    await tester.pumpWidget(const SizedBox());
    controller.dispose();
  });

  testWidgets(
    'feedback injection respects both switches, deduplicates active work and drops background completion',
    (tester) async {
      for (final haptics in [false, true]) {
        for (final sound in [false, true]) {
          final settings = JobsDemoSettings(
            refreshHaptics: haptics,
            refreshSound: sound,
          );
          final events = <JobsRefreshFeedbackEvent>[];
          final pending = Completer<void>();
          final controller = JobsEdgeRefreshController(
            onTrigger: (_) => pending.future,
          );
          await mount(
            tester,
            controller: controller,
            settings: settings,
            feedback: events.add,
          );
          final run = controller.run(
            JobsRefreshEdge.leading,
            userInitiated: true,
          );
          await controller.run(JobsRefreshEdge.trailing, userInitiated: true);
          await tester.pump();
          expect(
            events,
            haptics || sound ? [JobsRefreshFeedbackEvent.started] : isEmpty,
          );
          tester.binding.handleAppLifecycleStateChanged(
            AppLifecycleState.paused,
          );
          pending.complete();
          await tester.pump();
          await run;
          expect(events.length, haptics || sound ? 1 : 0);
          tester.binding.handleAppLifecycleStateChanged(
            AppLifecycleState.resumed,
          );
          await tester.pump();
          expect(events.length, haptics || sound ? 1 : 0);
          await tester.pumpWidget(const SizedBox());
          controller.dispose();
          settings.dispose();
        }
      }
    },
  );

  testWidgets(
    'haptic feedback uses actual platform channel and disabling it sends no haptic request',
    (tester) async {
      final calls = <MethodCall>[];
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        (call) async {
          calls.add(call);
          return null;
        },
      );
      addTearDown(
        () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
          SystemChannels.platform,
          null,
        ),
      );
      final feedback = JobsRefreshFeedback();
      for (final event in JobsRefreshFeedbackEvent.values) {
        await feedback.play(event, haptics: true, sound: false);
      }
      expect(
        calls
            .where((c) => c.method == 'HapticFeedback.vibrate')
            .map((c) => c.arguments),
        [
          'HapticFeedbackType.lightImpact',
          'HapticFeedbackType.selectionClick',
          'HapticFeedbackType.mediumImpact',
        ],
      );
      calls.clear();
      await feedback.play(
        JobsRefreshFeedbackEvent.started,
        haptics: false,
        sound: false,
      );
      expect(calls, isEmpty);
      await feedback.dispose();
    },
  );

  testWidgets(
    'visible indicator separates first-use, last refresh and last load times',
    (tester) async {
      var instant = DateTime(2026, 11, 16, 14, 5, 6);
      final controller = JobsEdgeRefreshController(
        historyKey: 'visible-history',
        now: () => instant,
        onTrigger: (_) async {},
      );
      await controller.historyReady;
      await mount(tester, controller: controller);
      controller.setExtent(-24);
      await tester.pump();
      expect(find.text('暂无刷新记录'), findsOneWidget);
      await controller.run(JobsRefreshEdge.leading);
      controller.setExtent(-24);
      await tester.pump();
      expect(find.textContaining('上次刷新'), findsOneWidget);
      expect(find.textContaining('14:05:06'), findsOneWidget);
      controller.setExtent(24);
      await tester.pump();
      expect(find.text('暂无加载记录'), findsOneWidget);
      instant = instant.add(const Duration(minutes: 1));
      await controller.run(JobsRefreshEdge.trailing);
      controller.setExtent(24);
      await tester.pump();
      expect(find.textContaining('上次加载'), findsOneWidget);
      expect(find.textContaining('14:06:06'), findsOneWidget);
      controller.setExtent(-24);
      await tester.pump();
      expect(find.textContaining('14:05:06'), findsOneWidget);
      await tester.pumpWidget(const SizedBox());
      controller.dispose();
    },
  );

  testWidgets(
    'both axis indicators remain bounded in ten languages, two themes and large text',
    (tester) async {
      tester.view.physicalSize = const Size(320, 568);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final settings = JobsDemoSettings(
        refreshHaptics: false,
        refreshSound: false,
      );
      final controller = JobsEdgeRefreshController(onTrigger: (_) async {});
      controller.setExtent(-24);
      for (final axis in Axis.values) {
        await tester.pumpWidget(
          JobsDemoApp(
            settings: settings,
            showSettings: false,
            home: Builder(
              builder: (context) => MediaQuery(
                data: MediaQuery.of(context)
                    .copyWith(textScaler: const TextScaler.linear(1.8)),
                child: Scaffold(
                  body: Center(
                    child: SizedBox(
                      width: axis == Axis.horizontal ? 112 : 300,
                      height: axis == Axis.horizontal ? 280 : 120,
                      child: JobsRefreshIndicator(
                        controller: controller,
                        axis: axis,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
        for (final locale in jobsDemoLocales) {
          settings.setLocale(locale);
          for (final theme in [ThemeMode.light, ThemeMode.dark]) {
            settings.setThemeMode(theme);
            await tester.pump();
            await tester.pump(const Duration(milliseconds: 300));
            expect(find.byType(JobsRefreshIndicator), findsOneWidget);
            expect(
              tester.takeException(),
              isNull,
              reason: '$axis / $locale / $theme',
            );
          }
        }
      }
      await tester.pumpWidget(const SizedBox());
      controller.dispose();
      settings.dispose();
    },
  );

  testWidgets(
    'three original cue assets are bundled and match the verified PCM generator',
    (tester) async {
      for (final event in JobsRefreshFeedbackEvent.values) {
        final asset = await rootBundle.load(
          'packages/jobs_demo_foundation/assets/audio/refresh_${event.name}.wav',
        );
        expect(
          asset.buffer.asUint8List(asset.offsetInBytes, asset.lengthInBytes),
          jobsRefreshCue(event),
        );
      }
    },
  );

  test('original feedback cues are distinct valid PCM WAV and contain real samples', () {
    final encoded = <String>{};
    for (final event in JobsRefreshFeedbackEvent.values) {
      final data = jobsRefreshCue(event);
      final view = data.buffer.asByteData();
      expect(ascii.decode(data.sublist(0, 4)), 'RIFF');
      expect(ascii.decode(data.sublist(8, 12)), 'WAVE');
      expect(view.getUint16(20, Endian.little), 1);
      expect(view.getUint16(22, Endian.little), 1);
      expect(view.getUint32(24, Endian.little), 22050);
      expect(view.getUint16(34, Endian.little), 16);
      expect(data.length, greaterThan(44));
      expect(data.skip(44).any((byte) => byte != 0), isTrue);
      encoded.add(base64Encode(data));
    }
    expect(encoded, hasLength(3));
  });
}
