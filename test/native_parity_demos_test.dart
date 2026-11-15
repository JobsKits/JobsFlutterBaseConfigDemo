import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jobs_demo_foundation/jobs_demo_foundation.dart';
import 'package:jobs_flutter_base_config/demos/图形验证码/graphic_captcha_demo.dart';
import 'package:jobs_flutter_base_config/demos/手写签名板/handwriting_demo.dart';
import 'package:jobs_flutter_base_config/demos/日历选择/calendar_demo.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jobs_flutter_base_config/demos/多会话隔离/session_isolation_demo.dart';
import 'package:jobs_flutter_base_config/demos/节流防抖/throttle_debounce_demo.dart';
import 'package:jobs_flutter_base_config/demos/任务依赖编排/task_dependency_demo.dart';

// 运行 flutter test test/native_parity_demos_test.dart；验证笔迹持久化、日历范围和验证码校验。
void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('handwriting persists normalized strokes and clears on discard', (
    tester,
  ) async {
    await tester.pumpWidget(
      JobsDemoApp(
        showSettings: false,
        home: Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute<void>(
                  builder: (_) => const HandwritingDemo(),
                ),
              ),
              child: const Text('open'),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    final canvas = find.byKey(const ValueKey('handwriting-canvas'));
    await tester.drag(canvas, const Offset(40, 24));
    await tester.tap(find.text('保存'));
    await tester.pumpAndSettle();
    final preferences = await SharedPreferences.getInstance();
    final strokes =
        jsonDecode(preferences.getString('jobs_demo_handwriting_v1')!) as List;
    expect(strokes, hasLength(1));
    expect((strokes.first['points'] as List).length, greaterThan(1));
    ScaffoldMessenger.of(tester.element(canvas)).clearSnackBars();
    await tester.pumpAndSettle();
    await tester.tap(find.text('清空'));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
    expect(find.text('未保存的笔迹'), findsOneWidget);
    await tester.tap(find.text('放弃并退出'));
    await tester.pumpAndSettle();
    expect(find.text('open'), findsOneWidget);
    expect(preferences.containsKey('jobs_demo_handwriting_v1'), false);
  });

  testWidgets('calendar orders reverse range and reloads cleared selection', (
    tester,
  ) async {
    await tester.pumpWidget(
      const JobsDemoApp(showSettings: false, home: CalendarDemo()),
    );
    await tester.pumpAndSettle();
    tester.view.physicalSize = const Size(900, 1200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpAndSettle();
    final now = DateTime.now();
    String day(int value) =>
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${value.toString().padLeft(2, '0')}';
    await tester.tap(find.text('日期范围'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(ValueKey('calendar-day-${day(20)}')));
    await tester.tap(find.byKey(ValueKey('calendar-day-${day(10)}')));
    await tester.pumpAndSettle();
    expect(
      tester
          .widgetList<SelectableText>(find.byType(SelectableText))
          .map((widget) => widget.data),
      contains('${day(10)} → ${day(20)}'),
    );
    await tester.ensureVisible(find.text('清空'));
    await tester.tap(find.text('清空'));
    await tester.pumpAndSettle();
    expect(find.byType(JobsEmptyState), findsOneWidget);
    await tester.ensureVisible(find.text('重新加载'));
    await tester.tap(find.text('重新加载'));
    await tester.pumpAndSettle();
    expect(find.byType(JobsEmptyState), findsNothing);
  });

  testWidgets('captcha accepts drawn answer and rejects wrong input', (
    tester,
  ) async {
    await tester.pumpWidget(
      const JobsDemoApp(showSettings: false, home: GraphicCaptchaDemo()),
    );
    await tester.pumpAndSettle();
    final customPaint = tester.widget<CustomPaint>(
      find.byKey(const ValueKey('graphic-captcha')),
    );
    final String answer = (customPaint.painter as dynamic).code as String;
    await tester.enterText(find.byKey(const ValueKey('captcha-input')), answer);
    await tester.ensureVisible(find.text('校验'));
    await tester.tap(find.text('校验'));
    await tester.pumpAndSettle();
    expect(find.text('验证通过'), findsOneWidget);
    await tester.enterText(
      find.byKey(const ValueKey('captcha-input')),
      'wrong',
    );
    await tester.tap(find.text('校验'));
    await tester.pumpAndSettle();
    expect(find.text('验证失败'), findsOneWidget);
  });
  test(
    'snowflake serializes 5000 requests and waits on sequence overflow',
    () async {
      var calls = 0;
      const base = 1700000000000;
      final generator = JobsSnowflake(
        node: 42,
        clock: () => base + (calls++ > 4096 ? 1 : 0),
      );
      final ids = await Future.wait(
        List.generate(5000, (_) => generator.next()),
      );
      expect(ids.toSet().length, 5000);
      expect(ids.last, greaterThan(ids.first));
      expect((ids.first >> 12) & BigInt.from(1023), BigInt.from(42));
      expect(ids.first.toString().length, greaterThan(15));
    },
  );

  test('snowflake rejects rollback and recovers on a healthy clock', () async {
    var now = 1700000000000;
    final generator = JobsSnowflake(node: 1, clock: () => now);
    final first = await generator.next();
    now--;
    await expectLater(generator.next(), throwsStateError);
    now += 2;
    expect(await generator.next(), greaterThan(first));
  });

  testWidgets('throttle and debounce coalesce rapid input', (tester) async {
    await tester.pumpWidget(
      const JobsDemoApp(showSettings: false, home: ThrottleDebounceDemo()),
    );
    await tester.pumpAndSettle();
    final field = find.byKey(const ValueKey('debounce-input'));
    await tester.enterText(field, 'a');
    await tester.enterText(field, 'ab');
    await tester.enterText(field, 'abc');
    await tester.pump(const Duration(milliseconds: 550));
    expect(find.text('3'), findsOneWidget);
    expect(find.text('1'), findsNWidgets(2));
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 1));
    expect(tester.takeException(), isNull);
  });

  testWidgets('sessions persist distinct notes and restore after switch', (
    tester,
  ) async {
    await tester.pumpWidget(
      const JobsDemoApp(showSettings: false, home: SessionIsolationDemo()),
    );
    await tester.pumpAndSettle();
    final field = find.byKey(const ValueKey('session-content'));
    await tester.enterText(field, 'account A');
    await tester.tap(find.text('保存'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('会话 B'));
    await tester.pumpAndSettle();
    expect(tester.widget<TextField>(field).controller!.text, isEmpty);
    await tester.enterText(field, 'account B');
    await tester.tap(find.text('保存'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('会话 A'));
    await tester.pumpAndSettle();
    expect(tester.widget<TextField>(field).controller!.text, 'account A');
    final preferences = await SharedPreferences.getInstance();
    expect(preferences.getString('jobs_demo_session.B.note'), 'account B');
  });

  testWidgets(
    'dependency failure blocks descendants and retry persists result',
    (tester) async {
      await tester.pumpWidget(
        const JobsDemoApp(showSettings: false, home: TaskDependencyDemo()),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byType(SwitchListTile));
      await tester.pump();
      await tester.tap(find.text('开始'));
      for (var index = 0; index < 16; index++) {
        await tester.pump(const Duration(milliseconds: 100));
      }
      expect(find.text('失败'), findsOneWidget);
      expect(find.text('请先完成前置任务'), findsOneWidget);
      await tester.tap(find.byType(SwitchListTile));
      await tester.pump();
      await tester.tap(find.text('重试'));
      for (var index = 0; index < 24; index++) {
        await tester.pump(const Duration(milliseconds: 100));
      }
      await tester.pumpAndSettle();
      expect(find.text('成功'), findsNWidgets(4));
      final preferences = await SharedPreferences.getInstance();
      expect(
        jsonDecode(preferences.getString('jobs_demo_task_result')!)['value'],
        42,
      );
      await tester.tap(find.text('开始'));
      await tester.pump(const Duration(milliseconds: 100));
      await tester.tap(find.text('取消'));
      await tester.pump(const Duration(seconds: 2));
      expect(find.text('已取消'), findsNWidgets(4));
    },
  );
}
