import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:jobs_demo_foundation/jobs_demo_foundation.dart';
import 'package:jobs_flutter_base_config/demos/交互富文本/入口.dart';
import 'package:jobs_flutter_base_config/demos/数字标签与按钮动效/入口.dart';
import 'package:jobs_flutter_base_config/demos/四向页面转场/入口.dart';
import 'package:jobs_flutter_base_config/demos/弹出容器/入口.dart';
import 'package:jobs_flutter_base_config/demos/布局节点实验/入口.dart';
import 'package:jobs_flutter_base_config/demos/联动分类菜单/入口.dart';
import 'package:jobs_flutter_base_config/demos/控制事件与按钮布局/入口.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => SharedPreferences.setMockInitialValues({}));
  final logo = File(
    'JobsByPubs/JobsDemoFoundationByPub/assets/iconfont/logo.png',
  ).readAsBytesSync();
  testWidgets(
    'Iconfont validates network image then reuses memory and disk; clearing is scoped',
    (tester) async {
      await tester.runAsync(() async {
        var requests = 0;
        final cache = JobsIconfontCache(
          clientFactory: () => MockClient((_) async {
            requests++;
            return http.Response.bytes(logo, 200);
          }),
        );
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('unrelated', 'keep');
        expect(
          (await cache.load(JobsIconfontAsset.logo).future).source,
          JobsIconfontCacheSource.network,
        );
        expect(
          (await cache.load(JobsIconfontAsset.logo).future).source,
          JobsIconfontCacheSource.memory,
        );
        cache.clearMemory();
        expect(
          (await cache.load(JobsIconfontAsset.logo).future).source,
          JobsIconfontCacheSource.disk,
        );
        expect(requests, 1);
        await cache.clear();
        expect(prefs.getString('unrelated'), 'keep');
        expect(prefs.getString('jobs.iconfont.logo'), isNull);
      });
    },
  );
  testWidgets(
    'Iconfont rejects corrupt disk and network bytes and recovers on next load',
    (tester) async {
      await tester.runAsync(() async {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('jobs.iconfont.logo', base64Encode([1, 2, 3]));
        var fail = true;
        final cache = JobsIconfontCache(
          clientFactory: () => MockClient(
            (_) async => http.Response.bytes(fail ? [1, 2, 3] : logo, 200),
          ),
        );
        await expectLater(
          cache.load(JobsIconfontAsset.logo).future,
          throwsA(isA<Exception>()),
        );
        expect(prefs.getString('jobs.iconfont.logo'), isNull);
        fail = false;
        expect(
          (await cache.load(JobsIconfontAsset.logo).future).source,
          JobsIconfontCacheSource.network,
        );
      });
    },
  );
  testWidgets('Iconfont request cancellation prevents late cache writes', (
    tester,
  ) async {
    await tester.runAsync(() async {
      final response = Completer<http.Response>();
      final entered = Completer<void>();
      final cache = JobsIconfontCache(
        clientFactory: () => MockClient((_) {
          entered.complete();
          return response.future;
        }),
      );
      final request = cache.load(JobsIconfontAsset.logo);
      final rejected = expectLater(
        request.future,
        throwsA(isA<JobsIconfontCancelled>()),
      );
      await entered.future;
      request.cancel();
      response.complete(http.Response.bytes(logo, 200));
      await rejected;
      expect(
        (await SharedPreferences.getInstance()).getString('jobs.iconfont.logo'),
        isNull,
      );
    });
  });
  testWidgets('Iconfont raster respects logical size and pixel ratio', (
    tester,
  ) async {
    await tester.runAsync(() async {
      final bytes = await JobsIconfontGlyph.component.rasterize(
        size: 48,
        scale: 2,
        color: Colors.red,
      );
      final codec = await ui.instantiateImageCodec(bytes);
      final frame = await codec.getNextFrame();
      expect(frame.image.width, 96);
      expect(frame.image.height, 96);
      frame.image.dispose();
      codec.dispose();
    });
  });
  testWidgets(
    'Queue caps concurrent slots and update renews expiry without releasing slot',
    (tester) async {
      final queue = JobsNotificationQueue(
        duration: const Duration(seconds: 5),
        concurrency: 2,
      );
      addTearDown(queue.dispose);
      for (var i = 0; i < 5; i++)
        queue.add(JobsQueuedNotice(id: '$i', content: '$i'));
      expect(queue.active.map((e) => e.id), ['0', '1']);
      expect(queue.pending.length, 3);
      await tester.pump(const Duration(seconds: 3));
      expect(queue.update('0', 'updated'), isTrue);
      await tester.pump(const Duration(seconds: 2));
      expect(queue.active.map((e) => e.id), ['0', '2']);
      expect(queue.completed, ['1']);
      await tester.pump(const Duration(seconds: 3));
      expect(queue.active.map((e) => e.id), ['2', '3']);
      expect(queue.completed, ['1', '0']);
      queue.clear();
      await tester.pump(const Duration(seconds: 20));
      expect(queue.active, isEmpty);
      expect(queue.completed, isEmpty);
      expect(queue.update('missing', 'x'), isFalse);
    },
  );
  testWidgets(
    'Button state title reflects pressed selected and disabled; disabled cannot toggle',
    (tester) async {
      await tester.pumpWidget(
        const JobsDemoApp(showSettings: false, home: ControlEventsDemo()),
      );
      final button = find.byKey(const ValueKey('state-button'));
      await tester.ensureVisible(button);
      await tester.pump();
      final gesture = await tester.startGesture(tester.getCenter(button));
      await tester.pump(const Duration(milliseconds: 120));
      await tester.pump();
      expect(
        find.descendant(of: button, matching: find.text('按下')),
        findsOneWidget,
      );
      await gesture.up();
      await tester.pump();
      await tester.pump();
      expect(
        find.descendant(of: button, matching: find.text('已选择')),
        findsOneWidget,
      );
      final toggle = find.byKey(const ValueKey('button-enabled'));
      await tester.ensureVisible(toggle);
      await tester.pump();
      await tester.tap(
        find.descendant(of: toggle, matching: find.byType(Switch)),
      );
      await tester.pump();
      await tester.pump();
      expect(tester.widget<FilledButton>(button).onPressed, isNull);
      expect(
        find.descendant(of: button, matching: find.text('禁用')),
        findsOneWidget,
      );
    },
  );
  testWidgets(
    'Interactive label tap updates status and 450ms long press changes background',
    (tester) async {
      await tester.pumpWidget(
        const JobsDemoApp(showSettings: false, home: InteractiveTextDemo()),
      );
      final label = find.byKey(const ValueKey('interactive-label-0'));
      final initial = tester.widget<Container>(label).decoration;
      await tester.tap(label);
      await tester.pump();
      expect(find.text('原始事件: 1'), findsOneWidget);
      final gesture = await tester.startGesture(tester.getCenter(label));
      await tester.pump(const Duration(milliseconds: 460));
      await gesture.up();
      await tester.pump();
      expect(tester.widget<Container>(label).decoration, isNot(initial));
    },
  );
  testWidgets(
    'Scrolling text stays still when short and moves only overflow content',
    (tester) async {
      Future<void> mount(String text) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Center(
              child: SizedBox(
                width: 100,
                child: JobsScrollingText(
                  text: text,
                  speed: 40,
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),
          ),
        );
        await tester.pump();
      }

      Offset translation() {
        final transform = tester.widget<Transform>(find.byType(Transform).last);
        return Offset(
          transform.transform.storage[12],
          transform.transform.storage[13],
        );
      }

      await mount('Jobs');
      await tester.pump(const Duration(milliseconds: 100));
      expect(translation(), Offset.zero);
      await mount('Flutter Jobs UIKit SwiftUI Dart Responsive text');
      await tester.pump(const Duration(milliseconds: 100));
      expect(translation().dx, lessThan(0));
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );
  testWidgets(
    'Image reuse cancels old request and a late response cannot overwrite the new asset',
    (tester) async {
      final oldResponse = Completer<http.Response>(),
          oldEntered = Completer<void>();
      final newReady = Completer<void>();
      final banner = File(
        'JobsByPubs/JobsDemoFoundationByPub/assets/iconfont/font-banner.png',
      ).readAsBytesSync();
      final cache = JobsIconfontCache(
        clientFactory: () => MockClient((request) {
          if (request.url == Uri.parse(JobsIconfontAsset.logo.url)) {
            oldEntered.complete();
            return oldResponse.future;
          }
          return Future.value(http.Response.bytes(banner, 200));
        }),
      );
      Widget image(JobsIconfontAsset asset) => MaterialApp(
        home: JobsIconfontImage(
          asset: asset,
          width: 100,
          cache: cache,
          onResult: (_) {
            if (asset == JobsIconfontAsset.fontBanner && !newReady.isCompleted)
              newReady.complete();
          },
        ),
      );
      await tester.pumpWidget(image(JobsIconfontAsset.logo));
      await tester.pump();
      await tester.runAsync(
        () => oldEntered.future.timeout(const Duration(seconds: 3)),
      );
      await tester.pumpWidget(image(JobsIconfontAsset.fontBanner));
      await tester.pump();
      for (var attempt = 0; attempt < 50 && !newReady.isCompleted; attempt++) {
        await tester.pump();
        await tester.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 10)),
        );
      }
      expect(newReady.isCompleted, isTrue);
      await tester.pump();
      oldResponse.complete(http.Response.bytes(logo, 200));
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 10)),
      );
      await tester.pump();
      final provider = tester.widget<Image>(find.byType(Image)).image;
      expect(provider, isA<ResizeImage>());
      expect(
        ((provider as ResizeImage).imageProvider as MemoryImage).bytes.length,
        banner.length,
      );
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );
  testWidgets(
    'Numeric label filters non-digits, interpolates and stops at the requested integer',
    (tester) async {
      await tester.pumpWidget(
        const JobsDemoApp(showSettings: false, home: AnimatedNumbersDemo()),
      );
      await tester.enterText(find.byType(TextField).first, 'a60');
      expect(
        tester.widget<TextField>(find.byType(TextField).first).controller!.text,
        '60',
      );
      final start = find.byKey(const ValueKey('animated-label-start'));
      await tester.ensureVisible(start);
      await tester.pump();
      await tester.tap(start);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 450));
      final value = tester
          .widget<JobsFormattedNumber>(
            find.byKey(const ValueKey('animated-label-value')),
          )
          .value;
      expect(value, greaterThan(0));
      expect(value, lessThan(60));
      await tester.pump(const Duration(milliseconds: 500));
      expect(
        tester
            .widget<JobsFormattedNumber>(
              find.byKey(const ValueKey('animated-label-value')),
            )
            .value,
        0,
      );
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );
  test('Formatted numbers preserve separators, decimal precision and finite fallback', () {
    expect(
      JobsFormattedNumber.format(12345.678, decimals: 2, grouping: true),
      '12,345.68',
    );
    expect(
      JobsFormattedNumber.format(-12345.678, decimals: 0, grouping: true),
      '-12,346',
    );
    expect(JobsFormattedNumber.format(double.nan), '0');
  });
  testWidgets(
    'Navigation toolbar has observable state and inline sample pushes a real page',
    (tester) async {
      await tester.pumpWidget(
        const JobsDemoApp(
          showSettings: false,
          home: DirectionalNavigationDemo(),
        ),
      );
      expect(find.text('工具栏: 未点亮'), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('navigation-toolbar-star')));
      await tester.pump();
      expect(find.text('工具栏: 已点亮'), findsOneWidget);
      await tester.tap(find.widgetWithText(ListTile, '内联标题'));
      await tester.pumpAndSettle();
      expect(find.byType(BackButton), findsOneWidget);
      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();
      expect(find.text('工具栏: 已点亮'), findsOneWidget);
    },
  );
  testWidgets(
    'Sheet expands between detents and popover opens directly at its anchor',
    (tester) async {
      await tester.pumpWidget(
        const JobsDemoApp(
          showSettings: false,
          home: PresentationContainersDemo(),
        ),
      );
      await tester.tap(find.byKey(const ValueKey('presentation-sheet')));
      await tester.pumpAndSettle();
      final content = find.descendant(
        of: find.byType(DraggableScrollableSheet),
        matching: find.byType(ListView),
      );
      final before = tester.getSize(content).height;
      await tester.drag(content, const Offset(0, -260));
      await tester.pumpAndSettle();
      expect(tester.getSize(content).height, greaterThan(before));
      Navigator.of(tester.element(content)).pop();
      await tester.pumpAndSettle();
      final trigger = find.byKey(const ValueKey('presentation-popover'));
      final anchor = tester.getRect(trigger);
      await tester.tap(trigger);
      await tester.pumpAndSettle();
      final popover = find.byKey(const ValueKey('anchored-popover'));
      expect(popover, findsOneWidget);
      expect(
        tester.getTopLeft(popover).dy,
        greaterThanOrEqualTo(anchor.bottom),
      );
      expect(find.byType(PopupMenuItem<int>), findsNothing);
    },
  );
  testWidgets(
    'Texture node laboratory appends a text node and shuffles without losing identities',
    (tester) async {
      await tester.pumpWidget(
        const JobsDemoApp(showSettings: false, home: LayoutNodesDemo()),
      );
      await tester.pump();
      expect(find.byType(Card), findsNWidgets(10));
      await tester.tap(find.byIcon(Icons.add));
      await tester.pump();
      expect(find.byType(Card), findsNWidgets(11));
      await tester.tap(find.byIcon(Icons.shuffle));
      await tester.pump(const Duration(milliseconds: 350));
      expect(find.byType(Card), findsNWidgets(11));
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump(const Duration(seconds: 2));
    },
  );
  testWidgets(
    'Marquee supports four directions, timed stepping, pause and live button callbacks',
    (tester) async {
      var taps = 0;
      Widget demo(AxisDirection direction, {bool paused = false}) =>
          MaterialApp(
            home: Scaffold(
              body: Center(
                child: SizedBox(
                  width: 100,
                  height: 80,
                  child: JobsMarqueeView(
                    itemCount: 3,
                    itemExtent: 100,
                    direction: direction,
                    mode: JobsMarqueeMode.interval,
                    interval: const Duration(milliseconds: 200),
                    paused: paused,
                    itemBuilder: (_, index) => TextButton(
                      onPressed: () => taps++,
                      child: Text('Item $index'),
                    ),
                  ),
                ),
              ),
            ),
          );
      for (final direction in [
        AxisDirection.left,
        AxisDirection.right,
        AxisDirection.up,
        AxisDirection.down,
      ]) {
        await tester.pumpWidget(const SizedBox.shrink());
        await tester.pumpWidget(demo(direction));
        await tester.pump();
        await tester.tap(find.text('Item 0').first);
        expect(taps, greaterThan(0));
        for (var frame = 0; frame < 6; frame++)
          await tester.pump(const Duration(milliseconds: 100));
        final before = tester
            .widget<Transform>(find.byKey(const ValueKey('marquee-motion')))
            .transform
            .clone();
        expect(
          direction == AxisDirection.left || direction == AxisDirection.right
              ? before.storage[12]
              : before.storage[13],
          isNot(0),
        );
        await tester.pumpWidget(demo(direction, paused: true));
        await tester.pump(const Duration(seconds: 1));
        final after = tester
            .widget<Transform>(find.byKey(const ValueKey('marquee-motion')))
            .transform;
        expect(after.storage, before.storage);
      }
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );
  testWidgets(
    'Linked menu honors fixed content width, ratio and no-content callbacks',
    (tester) async {
      await tester.pumpWidget(
        const JobsDemoApp(showSettings: false, home: LinkedMenuDemo()),
      );
      await tester.pump();
      await tester.tap(find.widgetWithText(ChoiceChip, '内容固定宽'));
      await tester.pump();
      expect(tester.getSize(find.byType(RefreshIndicator)).width, 260);
      await tester.tap(find.widgetWithText(ChoiceChip, '比例宽度'));
      await tester.pump();
      expect(
        tester.getSize(find.byType(RefreshIndicator)).width,
        closeTo(800 * .74, .1),
      );
      final noContent = find.byKey(const ValueKey('menu-no-content'));
      final list = find.descendant(
        of: find.byType(ListView),
        matching: find.byType(Scrollable),
      );
      await tester.scrollUntilVisible(noContent, 300, scrollable: list);
      await tester.pump();
      await tester.tap(noContent);
      await tester.pump();
      expect(find.text('无内容菜单已点击'), findsOneWidget);
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump(const Duration(seconds: 2));
    },
  );
}
