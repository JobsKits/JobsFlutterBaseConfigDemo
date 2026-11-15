import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jobs_flutter_base_config/JobsDemoTools/JobsFlutterTools/PopScope监听和自定义返回按钮行为/PopConfirmWrapper.dart';
import 'package:jobs_flutter_base_config/JobsDemoTools/JobsFlutterTools/高仿@JXCategoryView/JobsCategoryPage.dart';
import 'package:jobs_flutter_base_config/demos/异形按钮/异形按钮.dart' as entry;

void main() {
  const vibrationChannel = MethodChannel('vibration');
  final vibrationCalls = <MethodCall>[];

  setUp(() {
    vibrationCalls.clear();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(vibrationChannel, (call) async {
      vibrationCalls.add(call);
      return null;
    });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(vibrationChannel, null);
  });

  testWidgets('实际主入口展示三种形状，点击放大后恢复', (tester) async {
    entry.main();
    await tester.pumpAndSettle();

    final buttons = find.byType(entry.CustomShapeButton);
    expect(buttons, findsNWidgets(3));
    expect(
      tester.widgetList<entry.CustomShapeButton>(buttons).map((b) => b.shape),
      [entry.Shape.triangle, entry.Shape.star, entry.Shape.parallelogram],
    );
    expect(tester.getSize(buttons.first), const Size(100, 100));

    await tester.tap(buttons.first);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(tester.getSize(buttons.first).width, greaterThan(100));
    expect(tester.getSize(buttons.first).height, greaterThan(100));

    await tester.pumpAndSettle(const Duration(milliseconds: 100));
    expect(tester.getSize(buttons.first), const Size(100, 100));
    expect(vibrationCalls, hasLength(1));
    expect(vibrationCalls.single.method, 'vibrate');
    expect(vibrationCalls.single.arguments['duration'], 200);
    expect(tester.takeException(), isNull);
  });

  testWidgets('形状按钮点击后立即卸载，延迟恢复不再访问已销毁状态', (tester) async {
    entry.main();
    await tester.pumpAndSettle();
    await tester.tap(find.byType(entry.CustomShapeButton).first);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 250));

    expect(find.byType(entry.CustomShapeButton), findsNothing);
    expect(vibrationCalls, hasLength(1));
    expect(tester.takeException(), isNull);
  });

  testWidgets('页签数量增加和减少时重建控制器，并保留或收敛选中页', (tester) async {
    final count = ValueNotifier(2);
    addTearDown(count.dispose);
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: ValueListenableBuilder<int>(
          valueListenable: count,
          builder: (context, value, child) => JobsCategoryPage(
            key: const ValueKey('category'),
            initialIndex: 1,
            items: List.generate(
              value,
              (index) => ActivityBaseBean(
                title: '页签 $index',
                child: Center(child: Text('内容 $index')),
                show: true,
              ),
            ),
          ),
        ),
      ),
    ));
    await tester.pumpAndSettle();
    final pageElement = tester.element(find.byType(JobsCategoryPage));
    expect(tester.widget<TabBar>(find.byType(TabBar)).controller!.index, 1);

    count.value = 3;
    await tester.pumpAndSettle();
    expect(tester.element(find.byType(JobsCategoryPage)), same(pageElement));
    expect(find.byType(Tab), findsNWidgets(3));
    expect(tester.widget<TabBar>(find.byType(TabBar)).controller!.index, 1);

    await tester.tap(find.text('页签 2'));
    await tester.pumpAndSettle();
    expect(tester.widget<TabBar>(find.byType(TabBar)).controller!.index, 2);
    expect(find.text('内容 2'), findsOneWidget);

    count.value = 1;
    await tester.pumpAndSettle();
    expect(tester.element(find.byType(JobsCategoryPage)), same(pageElement));
    expect(find.byType(Tab), findsOneWidget);
    expect(tester.widget<TabBar>(find.byType(TabBar)).controller!.index, 0);
    expect(find.text('内容 0'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('返回确认微任务执行前同步卸载，不再使用失效 context', (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: PopConfirmWrapper(child: Scaffold(body: Text('待离开页面'))),
    ));
    final wrapperContext = tester.element(find.byType(PopConfirmWrapper));
    final popScope = tester.widget<PopScope>(
      find.descendant(
        of: find.byType(PopConfirmWrapper),
        matching: find.byWidgetPredicate((widget) => widget is PopScope),
      ),
    );
    popScope.onPopInvokedWithResult!(false, null);

    // 在冲刷微任务之前完成卸载，复现返回事件与宿主移除的竞态。
    tester.binding.attachRootWidget(
      tester.binding.wrapWithDefaultView(const SizedBox.shrink()),
    );
    tester.binding.drawFrame();
    expect(wrapperContext.mounted, isFalse);
    await tester.pump();

    expect(find.byType(AlertDialog), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
