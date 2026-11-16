import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jobs_demo_foundation/jobs_demo_foundation.dart';
import 'package:jobs_demo_foundation/jobs_edge_refresh.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  Future<void> mount(
    WidgetTester tester,
    JobsDemoSettings settings, {
    required Future<void> Function() onRefresh,
    ScrollController? scrollController,
    ScrollPhysics? physics,
    int itemCount = 1,
    bool showSettings = false,
  }) => tester.pumpWidget(
    JobsDemoApp(
      settings: settings,
      showSettings: false,
      home: Scaffold(
        body: Column(
          children: [
            if (showSettings) const JobsControlStyleSettings(),
            Expanded(
              child: JobsAdaptiveRefresh(
                onRefresh: onRefresh,
                child: ListView.builder(
                  controller: scrollController,
                  physics: physics,
                  itemCount: itemCount,
                  itemExtent: 56,
                  itemBuilder: (context, index) => Text('item-$index'),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );

  test(
    'refresh preference survives a new settings instance and rejects unknown values',
    () async {
      final first = JobsDemoSettings();
      await first.init();
      expect(first.refreshStyle, JobsRefreshStyle.flutter);
      first.setRefreshStyle(JobsRefreshStyle.jobs);
      final second = JobsDemoSettings();
      await second.init();
      expect(second.refreshStyle, JobsRefreshStyle.jobs);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('jobs_demo_refresh_style', 'removed-style');
      final unknown = JobsDemoSettings();
      await unknown.init();
      expect(unknown.refreshStyle, JobsRefreshStyle.flutter);
      first.dispose();
      second.dispose();
      unknown.dispose();
    },
  );

  testWidgets(
    'global choices immediately switch real implementations and preserve list position',
    (tester) async {
      final settings = JobsDemoSettings(locale: const Locale('en'));
      await settings.init();
      await mount(
        tester,
        settings,
        onRefresh: () async {},
        itemCount: 40,
        showSettings: true,
      );
      expect(find.byType(RefreshIndicator), findsOneWidget);
      await tester.drag(find.byType(ListView), const Offset(0, -360));
      await tester.pumpAndSettle();
      final original = tester.state<ScrollableState>(find.byType(Scrollable));
      final offset = original.position.pixels;
      expect(offset, greaterThan(0));
      await tester.tap(find.text('Jobs component'));
      await tester.pumpAndSettle();
      expect(settings.refreshStyle, JobsRefreshStyle.jobs);
      expect(find.byType(RefreshIndicator), findsNothing);
      expect(find.byType(JobsEdgeRefreshView), findsOneWidget);
      final changed = tester.state<ScrollableState>(find.byType(Scrollable));
      expect(identical(original, changed), isTrue);
      expect(changed.position.pixels, closeTo(offset, .01));
      expect(
        tester
            .widget<ChoiceChip>(
              find.ancestor(
                of: find.text('Jobs component'),
                matching: find.byType(ChoiceChip),
              ),
            )
            .selected,
        isTrue,
      );
      await tester.tap(find.text('Flutter default'));
      await tester.pumpAndSettle();
      expect(find.byType(RefreshIndicator), findsOneWidget);
      await tester.pumpWidget(const SizedBox());
      settings.dispose();
    },
  );

  for (final physics in [
    const ClampingScrollPhysics(),
    const BouncingScrollPhysics(),
  ]) {
    testWidgets(
      'Jobs refresh works on a short list with ${physics.runtimeType} and runs once',
      (tester) async {
        final settings = JobsDemoSettings(
          locale: const Locale('en'),
          refreshStyle: JobsRefreshStyle.jobs,
        );
        final pending = Completer<void>();
        var calls = 0;
        await mount(
          tester,
          settings,
          physics: physics,
          onRefresh: () {
            calls++;
            return pending.future;
          },
        );
        expect(find.byType(RefreshIndicator), findsNothing);
        final gesture = await tester.startGesture(
          tester.getCenter(find.byType(ListView)),
        );
        await gesture.moveBy(const Offset(0, 20));
        await tester.pump();
        await gesture.moveBy(const Offset(0, 240));
        await tester.pump();
        final view = tester.widget<JobsEdgeRefreshView>(
          find.byType(JobsEdgeRefreshView),
        );
        expect(
          view.controller.phase,
          JobsEdgeRefreshPhase.ready,
          reason: 'distance ${view.controller.distance}',
        );
        await gesture.up();
        await tester.pump(const Duration(seconds: 1));
        expect(calls, 1);
        expect(find.text('Refreshing'), findsOneWidget);
        await tester.drag(find.byType(ListView), const Offset(0, 200));
        await tester.pump(const Duration(milliseconds: 100));
        expect(calls, 1);
        pending.complete();
        await tester.pumpAndSettle();
        expect(find.text('Refreshing'), findsNothing);
        await tester.pumpWidget(const SizedBox());
        settings.dispose();
      },
    );
  }

  testWidgets('short pull and bottom overscroll never trigger a refresh', (
    tester,
  ) async {
    final settings = JobsDemoSettings(refreshStyle: JobsRefreshStyle.jobs);
    final scroll = ScrollController();
    var calls = 0;
    await mount(
      tester,
      settings,
      scrollController: scroll,
      itemCount: 40,
      onRefresh: () async {
        calls++;
      },
    );
    await tester.drag(find.byType(ListView), const Offset(0, 30));
    await tester.pumpAndSettle();
    expect(calls, 0);
    scroll.jumpTo(scroll.position.maxScrollExtent);
    await tester.pump();
    await tester.drag(find.byType(ListView), const Offset(0, -260));
    await tester.pumpAndSettle();
    expect(calls, 0);
    final view = tester.widget<JobsEdgeRefreshView>(
      find.byType(JobsEdgeRefreshView),
    );
    expect(view.controller.phase, JobsEdgeRefreshPhase.idle);
    await tester.pumpWidget(const SizedBox());
    scroll.dispose();
    settings.dispose();
  });

  for (final style in JobsRefreshStyle.values) {
    testWidgets('$style follows the finger, caps the gap and refreshes once', (
      tester,
    ) async {
      final settings = JobsDemoSettings(refreshStyle: style);
      final scroll = ScrollController();
      final pending = Completer<void>();
      var calls = 0;
      await mount(
        tester,
        settings,
        scrollController: scroll,
        onRefresh: () {
          calls++;
          return pending.future;
        },
      );
      final row = find.text('item-0');
      final top = tester.getTopLeft(row).dy;
      final gesture = await tester.startGesture(
        tester.getCenter(find.byType(ListView)),
      );
      await gesture.moveBy(const Offset(0, 100));
      await tester.pump();
      final firstPull = -scroll.position.pixels;
      expect(firstPull, greaterThan(0));
      expect(firstPull, lessThanOrEqualTo(100));
      expect(tester.getTopLeft(row).dy, closeTo(top + firstPull, .01));
      await gesture.moveBy(const Offset(0, 20));
      await tester.pump();
      final resisted = -scroll.position.pixels - firstPull;
      expect(resisted, greaterThan(0));
      expect(resisted, lessThan(20));
      await gesture.moveBy(const Offset(0, 1200));
      await tester.pump();
      expect(-scroll.position.pixels, greaterThan(firstPull));
      expect(-scroll.position.pixels, lessThanOrEqualTo(120.01));
      expect(calls, 0);
      await gesture.up();
      for (var frame = 0; frame < 100 && calls == 0; frame++) {
        await tester.pump(const Duration(milliseconds: 16));
      }
      expect(calls, 1);
      await tester.drag(find.byType(ListView), const Offset(0, 300));
      await tester.pump(const Duration(milliseconds: 100));
      expect(calls, 1);
      pending.complete();
      await tester.pumpAndSettle();
      expect(scroll.position.pixels, closeTo(0, .5));
      expect(tester.getTopLeft(row).dy, closeTo(top, .5));
      await tester.pumpWidget(const SizedBox());
      scroll.dispose();
      settings.dispose();
    });

    testWidgets('$style bounds a fast edge fling and cancels a reversed pull', (
      tester,
    ) async {
      final settings = JobsDemoSettings(refreshStyle: style);
      final scroll = ScrollController();
      var calls = 0;
      var largestGap = 0.0;
      scroll.addListener(() {
        final p = scroll.position;
        final gap = p.pixels < p.minScrollExtent
            ? p.minScrollExtent - p.pixels
            : p.pixels > p.maxScrollExtent
            ? p.pixels - p.maxScrollExtent
            : 0.0;
        if (gap > largestGap) largestGap = gap;
      });
      await mount(
        tester,
        settings,
        scrollController: scroll,
        itemCount: 40,
        onRefresh: () async {
          calls++;
        },
      );
      scroll.jumpTo(600);
      await tester.pump();
      await tester.fling(find.byType(ListView), const Offset(0, 150), 8000);
      await tester.pumpAndSettle();
      expect(largestGap, greaterThan(0));
      expect(largestGap, lessThanOrEqualTo(120.01));
      expect(scroll.position.pixels, closeTo(0, .5));
      expect(calls, 0);

      final gesture = await tester.startGesture(
        tester.getCenter(find.byType(ListView)),
      );
      await gesture.moveBy(const Offset(0, 260));
      await tester.pump();
      await gesture.moveBy(const Offset(0, -300));
      await tester.pump();
      await gesture.up();
      await tester.pumpAndSettle();
      expect(calls, 0);
      await tester.pumpWidget(const SizedBox());
      scroll.dispose();
      settings.dispose();
    });
  }

  test('refresh setting and indicator labels have all ten translations', () {
    for (final key in [
      '全局控件样式',
      '下拉刷新',
      'Flutter 默认',
      'Jobs 封装',
      '松开刷新',
      '正在刷新',
    ]) {
      final values = JobsDemoStrings.translations[key]!;
      expect(values, hasLength(jobsDemoLocales.length));
      expect(values.every((value) => value.trim().isNotEmpty), isTrue);
      for (final locale in jobsDemoLocales) {
        expect(
          JobsDemoStrings(locale).text(key),
          values[jobsDemoLocales.indexOf(locale)],
        );
      }
    }
  });
}
