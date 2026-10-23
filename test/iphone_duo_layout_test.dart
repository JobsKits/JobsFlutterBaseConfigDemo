import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jobs_flutter_base_config/JobsDemoTools/JobsFlutterTools/JobsFlutterTool.dart';
import 'package:jobs_flutter_base_config/JobsDemoTools/JobsFlutterTools/JobsSafeArea/JobsSafeArea.dart';
import 'package:jobs_flutter_base_config/JobsDemoTools/JobsFlutterTools/JobsSafeArea/JobsSmartSafeArea.dart';
import 'package:jobs_flutter_base_config/JobsDemoTools/JobsFlutterTools/广告轮播图/JobsBannerCarousel.dart';
import 'package:jobs_flutter_base_config/JobsDemoTools/UI/UI.Origin🌍/动画过渡UI/AnimatedDemo.dart'
    as animated;
import 'package:jobs_flutter_base_config/JobsDemoTools/UI/UI.Origin🌍/弹出框/弹出框@GridView.dart'
    as grid;
import 'package:jobs_flutter_base_config/JobsDemoTools/UI/UI.Origin🌍/弹出框/弹出框@表格.dart'
    as table;
import 'package:jobs_flutter_base_config/main.dart' as entry;
import 'package:jobs_runners/jobs_runners.dart';

void main() {
  void configureView(WidgetTester tester) {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(390, 844);
    addTearDown(tester.view.reset);
  }

  testWidgets('安全区独立消费四边并响应左右互换，部分嵌套不漏边', (tester) async {
    const key = ValueKey('content');
    Widget page(EdgeInsets padding) => MediaQuery(
          data: MediaQueryData(size: const Size(800, 600), padding: padding),
          child: Directionality(
            textDirection: TextDirection.ltr,
            child: SafeArea(
              left: false,
              bottom: false,
              child: JobsSmartSafeArea(
                child: SizedBox.expand(key: key),
              ),
            ),
          ),
        );

    await tester.pumpWidget(page(const EdgeInsets.fromLTRB(12, 24, 60, 34)));
    expect(tester.getTopLeft(find.byKey(key)), const Offset(12, 24));
    expect(tester.getSize(find.byKey(key)), const Size(728, 542));

    await tester.pumpWidget(page(const EdgeInsets.fromLTRB(60, 24, 12, 34)));
    expect(tester.getTopLeft(find.byKey(key)), const Offset(60, 24));
    expect(tester.getSize(find.byKey(key)), const Size(728, 542));
  });

  for (final runner in ['Material', 'Get', 'Cupertino']) {
    testWidgets('$runner Runner 在同一页面内重排并保留子页面状态', (tester) async {
      configureView(tester);
      const key = ValueKey('runner-content');
      var builds = 0;
      Widget builder(BuildContext context) {
        builds += 1;
        return const SizedBox.expand(key: key);
      }

      final Widget app = switch (runner) {
        'Get' => JobsGetRunner.builder(builder: builder),
        'Cupertino' => JobsCupertinoRunner.builder(builder: builder),
        _ => JobsMaterialRunner.builder(builder: builder),
      };
      await tester.pumpWidget(app);
      await tester.pumpAndSettle();
      final firstElement = tester.element(find.byKey(key));
      final firstBuilds = builds;

      tester.view.physicalSize = const Size(880, 600);
      tester.view.padding =
          const FakeViewPadding(left: 64, right: 12, bottom: 20);
      await tester.pumpAndSettle();
      expect(tester.getSize(find.byKey(key)).width, 804);
      expect(tester.getTopLeft(find.byKey(key)).dx, 64);
      expect(builds, greaterThan(firstBuilds));
      expect(tester.element(find.byKey(key)), same(firstElement));
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('自定义 Scaffold 保留键盘避让，底部 bar 逐边避让', (tester) async {
    configureView(tester);
    tester.view.padding =
        const FakeViewPadding(left: 12, right: 64, bottom: 20);
    const barKey = ValueKey('bar');
    const bodyKey = ValueKey('body');
    await tester.pumpWidget(const MaterialApp(
      home: JobsSafeArea(
        body: SizedBox.expand(key: bodyKey, child: TextField()),
        bottomNavigationBar: SizedBox(key: barKey, height: 48),
      ),
    ));
    final scaffold = tester.widget<Scaffold>(find.byType(Scaffold).last);
    expect(scaffold.resizeToAvoidBottomInset, isTrue);
    expect(tester.getTopLeft(find.byKey(barKey)).dx, 12);
    expect(tester.getSize(find.byKey(barKey)).width, 314);
    final bodyBefore = tester.getSize(find.byKey(bodyKey)).height;
    tester.view.viewInsets = const FakeViewPadding(bottom: 300);
    await tester.pumpAndSettle();
    expect(tester.getSize(find.byKey(bodyKey)).height, lessThan(bodyBefore));
    expect(tester.takeException(), isNull);
  });

  testWidgets('尺寸监听不替换 Flutter 全局 metrics 回调且可注销', (tester) async {
    configureView(tester);
    late BuildContext context;
    await tester.pumpWidget(Directionality(
      textDirection: TextDirection.ltr,
      child: Builder(builder: (value) {
        context = value;
        return const SizedBox();
      }),
    ));
    final callback =
        WidgetsBinding.instance.platformDispatcher.onMetricsChanged;
    final cancel = JobsScreenListener(context);
    expect(WidgetsBinding.instance.platformDispatcher.onMetricsChanged,
        same(callback));
    tester.view.physicalSize = const Size(880, 600);
    await tester.pump();
    cancel();
    expect(WidgetsBinding.instance.platformDispatcher.onMetricsChanged,
        same(callback));
  });

  testWidgets('轮播按所在容器重新计算尺寸并保留当前页', (tester) async {
    configureView(tester);
    final width = ValueNotifier<double>(300);
    addTearDown(width.dispose);
    await tester.pumpWidget(MaterialApp(
      home: Center(
        child: ValueListenableBuilder<double>(
          valueListenable: width,
          builder: (context, value, child) => SizedBox(
            width: value,
            child: JobsBannerCarousel(
              itemCount: 2,
              autoPlay: false,
              viewportFraction: 1,
              itemBuilder: (context, index) => Text('page $index'),
            ),
          ),
        ),
      ),
    ));
    await tester.drag(find.byType(PageView), const Offset(-300, 0));
    await tester.pumpAndSettle();
    final controller =
        tester.widget<PageView>(find.byType(PageView)).controller!;
    expect(controller.page, closeTo(1, 0.001));
    width.value = 180;
    await tester.pumpAndSettle();
    expect(tester.getSize(find.byType(PageView)), const Size(180, 101.25));
    expect(controller.page, closeTo(1, 0.001));
    expect(tester.takeException(), isNull);
  });

  testWidgets('默认形状按钮入口在窄矮窗口可滚动', (tester) async {
    configureView(tester);
    tester.view.physicalSize = const Size(320, 240);
    entry.main();
    await tester.pumpAndSettle();
    expect(find.byType(SingleChildScrollView), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.drag(
        find.byType(SingleChildScrollView), const Offset(0, -200));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  testWidgets('动画位置按局部 body 约束重算，缩小后仍位于安全区', (tester) async {
    configureView(tester);
    await tester.pumpWidget(const MaterialApp(home: animated.HomePage()));
    await tester.tap(find.text('Click Me'));
    await tester.pumpAndSettle();
    tester.view.physicalSize = const Size(240, 220);
    tester.view.padding = const FakeViewPadding(left: 20, right: 40);
    await tester.pumpAndSettle();
    final rect = tester.getRect(find.byType(ElevatedButton));
    expect(rect.left, greaterThanOrEqualTo(20));
    expect(rect.right, lessThanOrEqualTo(200));
    expect(rect.bottom, lessThanOrEqualTo(220));
    expect(tester.takeException(), isNull);
  });

  for (final popup in [
    const grid.MembershipDiscountPopup(),
    const table.MembershipDiscountPopup()
  ]) {
    testWidgets('${popup.runtimeType} 弹层窄屏与矮屏尺寸变化后关闭按钮仍可见', (tester) async {
      configureView(tester);
      await tester.pumpWidget(MaterialApp(home: popup));
      tester.view.physicalSize = const Size(320, 320);
      tester.view.padding = const FakeViewPadding(left: 40, right: 10);
      await tester.pumpAndSettle();
      final rect = tester.getRect(find.text('关闭'));
      expect(rect.left, greaterThanOrEqualTo(40));
      expect(rect.right, lessThanOrEqualTo(310));
      expect(rect.bottom, lessThanOrEqualTo(304));
      expect(tester.takeException(), isNull);
    });
  }
}
