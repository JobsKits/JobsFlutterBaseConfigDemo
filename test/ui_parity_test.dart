import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jobs_demo_foundation/jobs_demo_foundation.dart';
import 'package:jobs_flutter_base_config/demo_hub/ui_parity_catalog.dart';
import 'package:jobs_flutter_base_config/demo_hub/ui_parity_strings.dart';
import 'package:shared_preferences/shared_preferences.dart';

// 覆盖全部新 UI 的小屏明暗挂载/退出，以及实际编辑、手势与导航路径。
void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));
  for (final demo in uiParityDemos) {
    for (final dark in [false, true]) {
      testWidgets(
        '${demo.title} ${dark ? 'dark' : 'light'} mounts on compact large text',
        (tester) async {
          tester.view.physicalSize = const Size(320, 568);
          tester.view.devicePixelRatio = 1;
          addTearDown(tester.view.resetPhysicalSize);
          addTearDown(tester.view.resetDevicePixelRatio);
          final settings = JobsDemoSettings(
            locale: const Locale('de'),
            themeMode: dark ? ThemeMode.dark : ThemeMode.light,
          );
          await tester.pumpWidget(
            JobsDemoApp(
              settings: settings,
              showSettings: false,
              home: Builder(
                builder: (context) => MediaQuery(
                  data: MediaQuery.of(context)
                      .copyWith(textScaler: TextScaler.linear(1.6)),
                  child: demo.builder(context),
                ),
              ),
            ),
          );
          await tester.pump(const Duration(milliseconds: 100));
          await tester.pump(const Duration(milliseconds: 1000));
          expect(tester.takeException(), isNull, reason: demo.title);
          await tester.pumpWidget(const SizedBox.shrink());
          await tester.pump(const Duration(seconds: 2));
          expect(tester.takeException(), isNull);
          settings.dispose();
        },
      );
    }
  }
  test('Every UI translation includes the complete ten-language row', () {
    for (final row in uiParityTranslations.entries) {
      expect(row.value.length, 10, reason: row.key);
      expect(
        row.value.every((v) => v.trim().isNotEmpty),
        isTrue,
        reason: row.key,
      );
    }
  });
  Future<void> page(WidgetTester tester, String name) async {
    final entry = uiParityDemos.singleWhere((e) => e.title == name);
    await tester.pumpWidget(
      JobsDemoApp(
        settings: JobsDemoSettings(),
        showSettings: false,
        home: Builder(builder: entry.builder),
      ),
    );
    await tester.pump(const Duration(milliseconds: 100));
  }

  testWidgets('Cart stepper edits totals and clamps typed limits', (
    tester,
  ) async {
    await page(tester, '购物车步进');
    await tester.tap(find.byIcon(Icons.add_circle_outline).first);
    await tester.pump();
    expect(find.text('总计: 40'), findsOneWidget);
    final field = find.byType(TextFormField).first;
    await tester.enterText(field, '1000');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pump();
    expect(find.text('99'), findsOneWidget);
  });
  testWidgets('Card stack swipes and undo restores the dismissed card', (
    tester,
  ) async {
    await page(tester, '滑动卡片堆');
    await tester.drag(find.text('Flutter'), const Offset(360, 0));
    await tester.pump();
    expect(find.text('Flutter'), findsNothing);
    await tester.tap(find.byIcon(Icons.undo));
    await tester.pump();
    expect(find.text('Flutter'), findsOneWidget);
  });
  testWidgets('Country search selects the preserved full country dataset', (
    tester,
  ) async {
    await page(tester, '国家地区区号');
    await tester.enterText(find.byType(TextField), 'CN');
    await tester.pump();
    expect(find.text('+86'), findsOneWidget);
    await tester.tap(find.text('+86'));
    await tester.pump();
    expect(find.text('已选择: CN +86'), findsOneWidget);
  });
  testWidgets('Directional push uses a real route and returns safely', (
    tester,
  ) async {
    await page(tester, '四向页面转场');
    await tester.ensureVisible(find.widgetWithText(FilledButton, '开始'));
    await tester.pump();
    await tester.tap(find.widgetWithText(FilledButton, '开始'));
    await tester.pumpAndSettle();
    expect(find.widgetWithText(FilledButton, '上一页'), findsOneWidget);
    await tester.tap(find.widgetWithText(FilledButton, '上一页'));
    await tester.pumpAndSettle();
    expect(find.widgetWithText(FilledButton, '开始'), findsOneWidget);
  });
  testWidgets(
    'Auth styles preserve shared inputs, validate register and reset modes',
    (tester) async {
      await page(tester, '双风格认证');
      await tester.pump(const Duration(seconds: 1));
      await tester.enterText(find.byType(TextField).at(0), 'Jobs');
      await tester.enterText(find.byType(TextField).at(1), 'demo-password');
      await tester.tap(find.widgetWithText(TextButton, '注册'));
      await tester.pumpAndSettle();
      expect(find.byType(TextField), findsNWidgets(5));
      expect(
        tester.widget<TextField>(find.byType(TextField).first).controller!.text,
        'Jobs',
      );
      await tester.enterText(find.byType(TextField).at(2), 'different');
      await tester.enterText(find.byType(TextField).at(3), '13800138000');
      await tester.enterText(find.byType(TextField).at(4), '123456');
      await tester.ensureVisible(find.widgetWithText(FilledButton, '注册'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(FilledButton, '注册'));
      await tester.pump();
      expect(find.text('密码不匹配'), findsOneWidget);
    },
  );
  test('UI data rejects malformed response and automatically recovers on a later read', () async {
    var count = 0;
    final client = MockClient((request) async {
      count++;
      return http.Response(
        count == 1
            ? 'invalid'
            : count == 2
            ? '{"value":42}'
            : '{"value":["server"]}',
        200,
      );
    });
    addTearDown(client.close);
    expect(await UiDemoStore.read('schema', ['local'], client: client), [
      'local',
    ]);
    expect(await UiDemoStore.read('schema', ['local'], client: client), [
      'local',
    ]);
    expect(await UiDemoStore.read('schema', ['local'], client: client), [
      'server',
    ]);
    final prefs = await SharedPreferences.getInstance();
    expect(jsonDecode(prefs.getString('ui.schema')!), ['server']);
  });
  test(
    'UI writes honor normalized server values and reject an obsolete response',
    () async {
      final first = Completer<http.Response>();
      final second = Completer<http.Response>();
      var writes = 0;
      final client = MockClient((request) {
        writes++;
        return writes == 1 ? first.future : second.future;
      });
      addTearDown(client.close);
      final old = UiDemoStore.write('ordering', ['one'], client: client);
      await Future<void>.delayed(Duration.zero);
      final latest = UiDemoStore.write('ordering', ['two'], client: client);
      await Future<void>.delayed(Duration.zero);
      second.complete(http.Response('{"value":["normalized"]}', 200));
      expect(await latest, ['normalized']);
      first.complete(http.Response('{"value":["obsolete"]}', 200));
      expect(await old, isNull);
      final prefs = await SharedPreferences.getInstance();
      expect(jsonDecode(prefs.getString('ui.ordering')!), ['normalized']);
    },
  );
  testWidgets(
    'Nested comments preserve replies as a tree and persist changes',
    (tester) async {
      await page(tester, '评论与回复');
      await tester.tap(find.widgetWithText(TextButton, '回复').first);
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'first reply');
      await tester.tap(find.widgetWithText(FilledButton, '确认'));
      await tester.pumpAndSettle();
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.text('first reply'), findsOneWidget);
      await tester.tap(find.widgetWithText(TextButton, '回复').last);
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'nested reply');
      await tester.tap(find.widgetWithText(FilledButton, '确认'));
      await tester.pumpAndSettle();
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.text('nested reply'), findsOneWidget);
      final prefs = await SharedPreferences.getInstance();
      final tree = jsonDecode(prefs.getString('ui.comment-tree')!) as List;
      expect(
        tree.first['children'].first['children'].first['body'],
        'nested reply',
      );
    },
  );
}
