import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jobs_demo_foundation/jobs_demo_foundation.dart';
import 'package:jobs_flutter_base_config/demo_hub/parallel_catalog.dart';
import 'package:jobs_flutter_base_config/demos/空态重载/空态重载.dart';
import 'package:jobs_flutter_base_config/demos/悬浮时钟/悬浮时钟.dart';
import 'package:jobs_flutter_base_config/demos/验证码输入/验证码输入.dart';
import 'package:jobs_flutter_base_config/demos/手势解锁/手势解锁.dart';
import 'package:jobs_flutter_base_config/demos/钱包卡片/钱包卡片.dart';
import 'package:jobs_flutter_base_config/demos/滑动解锁/滑动解锁.dart';
import 'package:shared_preferences/shared_preferences.dart';

// 运行 flutter test test/parallel_demo_test.dart；覆盖新增页面挂载、退出及实际操作。
void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));
  Future<void> mount(
    WidgetTester tester,
    Widget page, {
    bool compact = false,
  }) async {
    tester.view.physicalSize = compact
        ? const Size(320, 568)
        : const Size(800, 700);
    tester.view.devicePixelRatio = 1;
    final settings = JobsDemoSettings(
      themeMode: compact ? ThemeMode.dark : ThemeMode.light,
      locale: compact ? const Locale('de') : const Locale('en'),
    );
    await tester.pumpWidget(
      JobsDemoApp(
        settings: settings,
        showSettings: false,
        home: MediaQuery(
          data: MediaQueryData(
            size: compact ? const Size(320, 568) : const Size(800, 700),
            textScaler: TextScaler.linear(compact ? 1.8 : 1),
          ),
          child: page,
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 350));
  }

  Future<void> unmount(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox());
    await tester.pump();
  }

  for (final entry in parallelDemos) {
    for (final compact in [false, true]) {
      testWidgets(
        '${entry.id} ${compact ? 'compact dark large text' : 'light'} mounts and exits',
        (tester) async {
          addTearDown(tester.view.resetPhysicalSize);
          addTearDown(tester.view.resetDevicePixelRatio);
          await mount(
            tester,
            Builder(builder: entry.builder),
            compact: compact,
          );
          expect(tester.takeException(), isNull);
          await unmount(tester);
          expect(tester.takeException(), isNull);
        },
      );
    }
  }

  testWidgets('empty list retries then clears without losing reload control', (
    tester,
  ) async {
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await mount(tester, const EmptyStateDemo());
    await tester.tap(find.text('Reload'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('Item 1'), findsOneWidget);
    await tester.tap(find.byTooltip('Clear list'));
    await tester.pump();
    expect(find.text('No data yet'), findsOneWidget);
    await unmount(tester);
  });

  testWidgets('code input accepts six digits and reset clears it', (
    tester,
  ) async {
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await mount(tester, const CodeInputDemo());
    await tester.enterText(find.byType(TextField), '12a34567');
    await tester.pump();
    expect(find.text('Verified'), findsOneWidget);
    expect(
      tester.widget<TextField>(find.byType(TextField)).controller!.text,
      '123456',
    );
    await tester.tap(find.text('Reset'));
    await tester.pump();
    expect(
      tester.widget<TextField>(find.byType(TextField)).controller!.text,
      '',
    );
    await unmount(tester);
  });

  testWidgets('clock drags below header and snaps to right edge', (
    tester,
  ) async {
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await mount(tester, const FloatingClockDemo());
    final clock = find.byKey(const ValueKey('floating-clock'));
    final start = tester.getCenter(clock);
    final gesture = await tester.startGesture(start);
    await gesture.moveBy(const Offset(24, 24));
    await tester.pump();
    await gesture.moveBy(const Offset(550, 280));
    await tester.pump();
    await gesture.up();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    final rect = tester.getRect(clock);
    expect(rect.right, closeTo(800, 1));
    expect(rect.top, greaterThan(400));
    await unmount(tester);
  });

  testWidgets('wallet rotates actual selected card', (tester) async {
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await mount(tester, const WalletCardsDemo());
    expect(find.text('1 / 3'), findsOneWidget);
    await tester.tap(find.text('Switch card'));
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('2 / 3'), findsOneWidget);
    await unmount(tester);
  });

  testWidgets('slide unlock only completes at end and can reset', (
    tester,
  ) async {
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await mount(tester, const SlideUnlockDemo());
    final rect = tester.getRect(find.byType(Slider));
    await tester.tapAt(rect.center);
    await tester.pump();
    expect(find.text('Unlocked'), findsNothing);
    await tester.tapAt(rect.centerRight - const Offset(20, 0));
    await tester.pump();
    expect(find.text('Unlocked'), findsOneWidget);
    await tester.tap(find.text('Lock again'));
    await tester.pump();
    expect(find.text('Unlocked'), findsNothing);
    await unmount(tester);
  });

  testWidgets('pattern stores first path and compares next path', (
    tester,
  ) async {
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await mount(tester, const PatternUnlockDemo());
    final canvas = find.byKey(const ValueKey('pattern-canvas'));
    final bounds = tester.getRect(canvas);
    Future<void> draw() async {
      final p0 = bounds.topLeft + Offset(bounds.width / 6, bounds.height / 6);
      final gesture = await tester.startGesture(p0);
      await gesture.moveTo(p0 + Offset(bounds.width / 3, 0));
      await tester.pump();
      await gesture.moveTo(p0 + Offset(bounds.width * 2 / 3, 0));
      await tester.pump();
      await gesture.moveTo(
        p0 + Offset(bounds.width * 2 / 3, bounds.height / 3),
      );
      await tester.pump();
      await gesture.up();
      await tester.pump();
    }

    await draw();
    expect(find.text('Draw the pattern again'), findsOneWidget);
    await draw();
    expect(find.text('Unlocked'), findsOneWidget);
    await unmount(tester);
  });
}
