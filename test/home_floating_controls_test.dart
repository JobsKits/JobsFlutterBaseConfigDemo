import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jobs_demo_foundation/jobs_demo_foundation.dart';
import 'package:jobs_flutter_base_config/demo_hub/home_floating_controls.dart';
import 'package:jobs_flutter_base_config/demo_hub/home_floating_strings.dart';
import 'package:jobs_platform_lab/jobs_platform_lab.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final calls = <String>[];
  setUp(() {
    JobsDemoStrings.registerTranslations(homeFloatingTranslations);
    calls.clear();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(JobsPlatformLab.methods, (call) async {
          calls.add(call.method);
          return null;
        });
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('jobs_platform_lab/events'),
          (_) async => null,
        );
  });

  Future<void> mount(
    WidgetTester tester, {
    bool active = true,
    bool clock = true,
    ValueChanged<bool>? onClock,
    HomeFloatingController? controller,
    VoidCallback? onPress,
    VoidCallback? onDebug,
    VoidCallback? onOpenClock,
    Size viewport = const Size(800, 600),
    Locale locale = const Locale('zh'),
    double textScale = 1,
    EdgeInsets safeInsets = EdgeInsets.zero,
  }) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = viewport;
    await tester.pumpWidget(
      MaterialApp(
        locale: locale,
        supportedLocales: jobsDemoLocales,
        localizationsDelegates: jobsDemoLocalizationDelegates,
        theme: jobsDemoTheme(Brightness.light),
        home: MediaQuery(
          data: MediaQueryData(
            size: viewport,
            disableAnimations: true,
            textScaler: TextScaler.linear(textScale),
            padding: safeInsets,
          ),
          child: HomeFloatingControls(
            active: active,
            showClock: clock,
            onClockVisibilityChanged: onClock ?? (_) {},
            controller: controller,
            onPress: onPress,
            onOpenDebug: onDebug,
            onOpenClock: onOpenClock,
            child: const Scaffold(body: Text('首页内容')),
          ),
        ),
      ),
    );
    await tester.pump();
  }

  tearDown(() {
    final view =
        TestWidgetsFlutterBinding.instance.platformDispatcher.views.first;
    view.resetDevicePixelRatio();
    view.resetPhysicalSize();
  });

  Future<void> unmount(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox());
    await tester.pump();
  }

  Future<void> hold(WidgetTester tester, Finder finder) async {
    final gesture = await tester.startGesture(tester.getCenter(finder));
    await tester.pump(const Duration(milliseconds: 810));
    await gesture.up();
    await tester.pump(const Duration(milliseconds: 200));
  }

  Future<void> dragClock(
    WidgetTester tester,
    Finder clock,
    Offset delta,
  ) async {
    final gesture = await tester.startGesture(tester.getCenter(clock));
    await tester.pump(const Duration(milliseconds: 600));
    await gesture.moveBy(delta);
    await tester.pump();
    await gesture.up();
    await tester.pump();
  }

  testWidgets('时间全屏拖动吸边，计时刷新与临时独占不会重置位置', (tester) async {
    await mount(tester);
    final clock = find.byKey(const ValueKey('floating-clock'));
    final origin = tester.getTopLeft(clock);
    await dragClock(tester, clock, const Offset(340, 280));
    await tester.pump();
    final moved = tester.getTopLeft(clock);
    final movedRect = tester.getRect(clock);
    expect(moved.dy, greaterThan(origin.dy + 200));
    expect(
      movedRect.left == 8 ||
          movedRect.right == 792 ||
          movedRect.top == 8 ||
          movedRect.bottom == 592,
      isTrue,
    );
    await tester.pump(const Duration(seconds: 2));
    expect(tester.getTopLeft(clock), moved);
    await mount(tester, active: false);
    expect(clock, findsNothing);
    expect(calls.last, 'shake.stop');
    await mount(tester);
    expect(tester.getTopLeft(clock), moved);
    expect(calls.where((method) => method.startsWith('motion.')), isEmpty);
    await unmount(tester);
    expect(tester.takeException(), isNull);
  });

  testWidgets('时钟按十语和字号测量，手机横竖屏与平板均留安全边距', (tester) async {
    final clock = find.byKey(const ValueKey('floating-clock'));
    final clockText = find.byKey(const ValueKey('floating-clock-text'));
    for (final viewport in const [
      Size(240, 320),
      Size(390, 844),
      Size(844, 390),
      Size(1024, 768),
    ]) {
      final insets = viewport.width > viewport.height
          ? const EdgeInsets.fromLTRB(44, 0, 34, 21)
          : const EdgeInsets.fromLTRB(0, 24, 0, 20);
      for (final locale in jobsDemoLocales) {
        for (final scale in [1.0, 2.4]) {
          await mount(
            tester,
            viewport: viewport,
            locale: locale,
            textScale: scale,
            safeInsets: insets,
          );
          final bounds = tester.getRect(clock);
          final area = Rect.fromLTRB(
            insets.left + 8,
            insets.top + 8,
            viewport.width - insets.right - 8,
            viewport.height - insets.bottom - 8,
          );
          final label = '$viewport / $locale / $scale';
          expect(bounds.left, greaterThanOrEqualTo(area.left), reason: label);
          expect(bounds.top, greaterThanOrEqualTo(area.top), reason: label);
          expect(bounds.right, lessThanOrEqualTo(area.right), reason: label);
          expect(bounds.bottom, lessThanOrEqualTo(area.bottom), reason: label);
          final paragraph = tester.renderObject<RenderParagraph>(clockText);
          final plainText = paragraph.text.toPlainText();
          for (var offset = 0; offset < plainText.length; offset++) {
            if (plainText[offset].trim().isEmpty) continue;
            for (final box in paragraph.getBoxesForSelection(
              TextSelection(baseOffset: offset, extentOffset: offset + 1),
            )) {
              expect(box.left, greaterThanOrEqualTo(-.01), reason: label);
              expect(
                box.right,
                lessThanOrEqualTo(paragraph.size.width + .01),
                reason: label,
              );
            }
          }
          expect(find.byType(FittedBox), findsNothing);
          expect(tester.takeException(), isNull, reason: label);
        }
      }
    }
    await unmount(tester);
  });

  testWidgets('时钟宽度取文字而非设备比例，大字换行增高且尺寸改变仍吸边', (tester) async {
    final clock = find.byKey(const ValueKey('floating-clock'));
    await mount(tester, viewport: const Size(390, 844));
    final phone = tester.getSize(clock);
    await mount(tester, viewport: const Size(1024, 768));
    expect(tester.getSize(clock), phone);
    await mount(
      tester,
      viewport: const Size(1024, 768),
      locale: const Locale('de'),
    );
    expect(tester.getSize(clock).width, greaterThan(phone.width));
    await dragClock(tester, clock, const Offset(1400, 0));
    await tester.pump();
    expect(tester.getRect(clock).right, closeTo(1016, .01));

    await mount(
      tester,
      viewport: const Size(240, 320),
      locale: const Locale('de'),
      textScale: 2.4,
    );
    final wrapped = tester.getRect(clock);
    expect(wrapped.right, closeTo(232, .01));
    expect(wrapped.height, greaterThan(phone.height));
    expect(wrapped.top, greaterThanOrEqualTo(8));
    expect(wrapped.bottom, lessThanOrEqualTo(312));
    await mount(tester, viewport: const Size(390, 844));
    expect(tester.getRect(clock).right, closeTo(382, .01));
    await dragClock(tester, clock, const Offset(0, 1000));
    await tester.pump();
    expect(tester.getRect(clock).bottom, closeTo(836, .01));
    await mount(
      tester,
      viewport: const Size(844, 390),
      locale: const Locale('fr'),
      textScale: 1.8,
      safeInsets: const EdgeInsets.fromLTRB(44, 0, 34, 21),
    );
    final landscape = tester.getRect(clock);
    expect(landscape.right, closeTo(802, .01));
    expect(landscape.bottom, closeTo(361, .01));
    expect(landscape.left, greaterThanOrEqualTo(52));
    expect(landscape.top, greaterThanOrEqualTo(8));
    await unmount(tester);
    expect(tester.takeException(), isNull);
  });

  testWidgets('时间短按进入页面，长按拖动不兼触短按，显隐由宿主设置恢复', (tester) async {
    bool? preference;
    var opens = 0;
    await mount(
      tester,
      onClock: (value) => preference = value,
      onOpenClock: () => opens++,
    );
    final clock = find.byKey(const ValueKey('floating-clock'));
    await tester.tap(clock);
    expect(opens, 1);
    final origin = tester.getTopLeft(clock);
    await tester.drag(clock, const Offset(120, 0));
    expect(tester.getTopLeft(clock), origin);
    await dragClock(tester, clock, const Offset(340, 280));
    expect(tester.getTopLeft(clock), isNot(origin));
    expect(opens, 1);
    expect(preference, isNull);
    expect(find.byType(AlertDialog), findsNothing);
    await mount(tester, clock: false);
    expect(clock, findsNothing);
    await mount(tester, clock: true);
    expect(clock, findsOneWidget);
    await unmount(tester);
  });

  testWidgets('导火索长按释放归零且不会触发短按跳转', (tester) async {
    var presses = 0;
    await mount(tester, onPress: () => presses++);
    final button = find.byKey(const ValueKey('floating-press'));
    final gesture = await tester.startGesture(tester.getCenter(button));
    await tester.pump(const Duration(milliseconds: 810));
    await tester.pump(const Duration(milliseconds: 600));
    final progress = tester.widget<CircularProgressIndicator>(
      find.byType(CircularProgressIndicator),
    );
    expect(progress.value, greaterThan(0.4));
    await gesture.up();
    await tester.pump();
    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(presses, 0);
    await unmount(tester);
  });

  testWidgets('旋转按钮暂停并可恢复，独占与后台停止动画', (tester) async {
    await mount(tester);
    final spin = find.byKey(const ValueKey('floating-spin'));
    expect(find.bySemanticsLabel('暂停旋转与计时'), findsOneWidget);
    await tester.tap(spin);
    await tester.pump();
    expect(find.bySemanticsLabel('继续旋转与计时'), findsOneWidget);
    await tester.tap(spin);
    await tester.pump();
    expect(find.bySemanticsLabel('暂停旋转与计时'), findsOneWidget);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    await tester.pump();
    expect(spin, findsNothing);
    expect(calls.last, 'shake.stop');
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pump();
    expect(spin, findsOneWidget);
    await unmount(tester);
  });

  testWidgets('Bug初始隐藏，手动或摇动恢复，长按隐藏并保留拖动位置', (tester) async {
    final controller = HomeFloatingController();
    var opened = 0;
    await mount(tester, controller: controller, onDebug: () => opened++);
    final bug = find.byKey(const ValueKey('floating-debug'));
    expect(bug, findsNothing);
    controller.showDebugEntry();
    await tester.pump();
    expect(bug, findsOneWidget);
    await tester.tap(bug);
    expect(opened, 1);
    await tester.drag(bug, const Offset(-240, -50));
    await tester.pump();
    final position = tester.getTopLeft(bug);
    await hold(tester, bug);
    expect(bug, findsNothing);
    await TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .handlePlatformMessage(
          'jobs_platform_lab/events',
          const StandardMethodCodec().encodeSuccessEnvelope({
            'topic': 'shake',
            'data': {'event': 'shake'},
          }),
          (_) {},
        );
    await tester.pump();
    expect(bug, findsOneWidget);
    expect(tester.getTopLeft(bug), position);
    await mount(tester, active: false, controller: controller);
    controller.showDebugEntry();
    await tester.pump();
    expect(bug, findsNothing);
    await unmount(tester);
    controller.dispose();
  });

  test('悬浮控件词库覆盖十种语言', () {
    for (final values in homeFloatingTranslations.values) {
      expect(values, hasLength(10));
      expect(values.every((value) => value.trim().isNotEmpty), isTrue);
    }
  });
}
