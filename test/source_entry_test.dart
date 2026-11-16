import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jobs_flutter_base_config/demos/拖动手势/DragDemo.dart' as drag;
import 'package:jobs_flutter_base_config/demos/胶囊按钮切页/JobsSegmentTabs.dart'
    as tabs;
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  Future<void> renderSource(WidgetTester tester, void Function() entry) async {
    // main 内部直接 runApp，先为本用例建立新帧，避免继承上一用例的动画时间戳。
    await tester.pumpWidget(const SizedBox.shrink());
    entry();
    await tester.pump();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));
    await tester.pump();
  }

  Future<void> closeSource(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(seconds: 1));
    expect(tester.takeException(), isNull);
  }

  testWidgets('胶囊源码main可直接运行并切换实际内容', (tester) async {
    await renderSource(tester, tabs.main);
    expect(find.byType(tabs.View), findsOneWidget);
    expect(find.byType(tabs.SegmentBar), findsOneWidget);
    await tester.tap(find.widgetWithText(tabs.SegmentChip, '7日内'));
    await tester.pump();
    final pages = find.descendant(
      of: find.byType(tabs.View),
      matching: find.byType(IndexedStack),
    );
    expect(tester.widget<IndexedStack>(pages).index, 2);
    await tester.tap(find.byKey(const ValueKey('demo-theme-action')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(
      Theme.of(tester.element(find.byType(tabs.View))).brightness,
      Brightness.dark,
    );
    expect(tester.widget<IndexedStack>(pages).index, 2);
    expect(tester.takeException(), isNull);
    await closeSource(tester);
  });

  testWidgets('拖动源码main复用安全三模式，切换后按对应方向拖动', (tester) async {
    await renderSource(tester, drag.main);
    expect(find.byType(drag.DragGestureDemo), findsOneWidget);
    final target = find.descendant(
      of: find.byType(drag.DragGestureDemo),
      matching: find.byWidgetPredicate(
        (widget) =>
            widget is GestureDetector &&
            (widget.onPanUpdate != null ||
                widget.onHorizontalDragUpdate != null ||
                widget.onVerticalDragUpdate != null),
      ),
    );
    expect(target, findsOneWidget);
    await tester.tap(find.widgetWithText(ChoiceChip, '水平'));
    await tester.pump();
    final horizontalStart = tester.getTopLeft(target);
    await tester.drag(target, const Offset(70, 0));
    await tester.pump();
    final horizontalEnd = tester.getTopLeft(target);
    expect(horizontalEnd.dx - horizontalStart.dx, greaterThan(20));
    expect(horizontalEnd.dy, closeTo(horizontalStart.dy, .01));
    await tester.tap(find.widgetWithText(ChoiceChip, '垂直'));
    await tester.pump();
    final verticalStart = tester.getTopLeft(target);
    await tester.drag(target, const Offset(0, 70));
    await tester.pump();
    final verticalEnd = tester.getTopLeft(target);
    expect(verticalEnd.dx, closeTo(verticalStart.dx, .01));
    expect(verticalEnd.dy - verticalStart.dy, greaterThan(20));
    expect(find.byKey(const ValueKey('demo-theme-action')), findsOneWidget);
    expect(tester.takeException(), isNull);
    await closeSource(tester);
  });
}
