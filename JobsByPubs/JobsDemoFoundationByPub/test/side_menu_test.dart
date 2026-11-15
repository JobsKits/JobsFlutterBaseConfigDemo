import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jobs_demo_foundation/jobs_demo_foundation.dart';

// 验证真实拖动、遮罩、全宽和返回收敛；在本包运行 flutter test。
void main() {
  Future<void> mount(
    WidgetTester tester,
    JobsSideMenuController controller, {
    bool fullWidth = false,
  }) => tester.pumpWidget(
    MaterialApp(
      locale: const Locale('en'),
      supportedLocales: jobsDemoLocales,
      localizationsDelegates: jobsDemoLocalizationDelegates,
      home: JobsSideMenu(
        controller: controller,
        fullWidth: fullWidth,
        menu: const Center(child: Text('menu-content')),
        child: const Scaffold(body: Center(child: Text('body-content'))),
      ),
    ),
  );

  testWidgets('edge drag opens partial menu and left drag closes', (
    tester,
  ) async {
    final controller = JobsSideMenuController();
    await mount(tester, controller);
    await tester.dragFrom(const Offset(8, 300), const Offset(610, 0));
    await tester.pumpAndSettle();
    expect(controller.isOpen, isTrue);
    final menu = tester.getRect(find.text('menu-content'));
    expect(menu.center.dx, lessThan(400));
    await tester.dragFrom(const Offset(500, 300), const Offset(-500, 0));
    await tester.pumpAndSettle();
    expect(controller.isOpen, isFalse);
    await tester.pumpWidget(const SizedBox());
    controller.dispose();
  });

  testWidgets('short drag settles closed without leaving a scrim', (
    tester,
  ) async {
    final controller = JobsSideMenuController();
    await mount(tester, controller);
    final gesture = await tester.startGesture(const Offset(8, 300));
    await gesture.moveBy(const Offset(80, 0));
    await tester.pump(const Duration(milliseconds: 300));
    await gesture.up();
    await tester.pumpAndSettle();
    expect(controller.isOpen, isFalse);
    expect(find.text('body-content'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
    controller.dispose();
  });

  testWidgets('full width fills viewport and close button works', (
    tester,
  ) async {
    final controller = JobsSideMenuController();
    await mount(tester, controller, fullWidth: true);
    controller.open();
    await tester.pumpAndSettle();
    expect(tester.getCenter(find.text('menu-content')).dx, closeTo(400, 1));
    await tester.tap(find.byTooltip('Close menu'));
    await tester.pumpAndSettle();
    expect(controller.isOpen, isFalse);
    await tester.pumpWidget(const SizedBox());
    controller.dispose();
  });

  testWidgets('scrim and system back close the menu', (tester) async {
    final controller = JobsSideMenuController();
    await mount(tester, controller);
    controller.open();
    await tester.pumpAndSettle();
    await tester.tapAt(const Offset(760, 300));
    await tester.pumpAndSettle();
    expect(controller.isOpen, isFalse);
    controller.open();
    await tester.pumpAndSettle();
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(controller.isOpen, isFalse);
    await tester.pumpWidget(const SizedBox());
    controller.dispose();
  });

  testWidgets('disabled menu cannot be opened', (tester) async {
    final controller = JobsSideMenuController();
    await tester.pumpWidget(
      MaterialApp(
        home: JobsSideMenu(
          controller: controller,
          enabled: false,
          menu: const Text('menu'),
          child: const Scaffold(body: Text('body')),
        ),
      ),
    );
    controller.open();
    await tester.pumpAndSettle();
    expect(find.text('body'), findsOneWidget);
    expect(tester.getRect(find.text('menu')).right, lessThanOrEqualTo(0));
    await tester.pumpWidget(const SizedBox());
    controller.dispose();
  });
}
