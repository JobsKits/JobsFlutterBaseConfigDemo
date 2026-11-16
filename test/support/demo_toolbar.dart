import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// 页面动作现在经唯一右上菜单进入，保留测试原有的业务与几何断言。
Future<void> tapDemoMenuAction(WidgetTester tester, Finder action) async {
  await tester.tap(find.byKey(const ValueKey('demo-actions-menu')));
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 350));
  await tester.tap(action);
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 350));
}
