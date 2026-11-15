import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:jobs_demo_foundation/jobs_demo_foundation.dart';
import 'package:jobs_flutter_base_config/demo_hub/legacy_launch.dart';
import 'package:jobs_flutter_base_config/demo_hub/legacy_catalog.dart';

// 验证旧main局部运行、异步日志可见性、Timer归属与命名路由实际往返。
void main() {
  testWidgets('异步日志在原main返回后出现，退出取消周期任务', (tester) async {
    var ticks = 0;
    void example() {
      Timer.periodic(const Duration(milliseconds: 20), (_) {
        ticks++;
        legacyDebugPrint('tick $ticks');
      });
    }

    await tester.pumpWidget(
      JobsDemoScope(
        settings: JobsDemoSettings(),
        child: MaterialApp(
          home: LegacyLaunchPage(title: 'console', action: example),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    await tester.pump();
    expect(find.textContaining('tick'), findsWidgets);
    final before = ticks;
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 1));
    expect(ticks, before);
    expect(tester.takeException(), isNull);
  });
  testWidgets('旧命名路由实际传参进入详情并返回', (tester) async {
    final entry = legacyDemos.singleWhere((e) => e.id == 'legacy-complete-118');
    await tester.pumpWidget(
      JobsDemoScope(
        settings: JobsDemoSettings(),
        child: GetMaterialApp(
          locale: const Locale('zh'),
          supportedLocales: jobsDemoLocales,
          localizationsDelegates: jobsDemoLocalizationDelegates,
          home: Builder(builder: entry.builder),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));
    final button = find.text(
      legacyUiTextForLocale(
        const Locale('zh'),
        'Get.toNamed → DetailPage（传 arguments）',
      ),
    );
    expect(button, findsOneWidget);
    await tester.tap(button);
    await tester.pumpAndSettle();
    expect(find.textContaining('命名路由传参'), findsWidgets);
    await tester.tap(
      find.text(legacyUiTextForLocale(const Locale('zh'), '返回并携带数据')),
    );
    await tester.pumpAndSettle();
    expect(button, findsOneWidget);
    expect(tester.takeException(), isNull);
  });
  testWidgets('void main返回后捕获的页面也会刷新，退出不再执行回调', (tester) async {
    var captures = 0;
    void example() {
      Timer(const Duration(milliseconds: 20), () {
        captures++;
        legacyCaptureApp(const Scaffold(body: Text('late page')));
      });
    }

    await tester.pumpWidget(
      JobsDemoScope(
        settings: JobsDemoSettings(),
        child: MaterialApp(
          home: LegacyLaunchPage(title: 'late', action: example),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    await tester.pump();
    expect(find.text('late page'), findsOneWidget);
    expect(captures, 1);
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 1));
    expect(captures, 1);
  });
}
