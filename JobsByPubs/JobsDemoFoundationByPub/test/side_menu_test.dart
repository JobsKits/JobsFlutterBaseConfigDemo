import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jobs_demo_foundation/jobs_demo_foundation.dart';

// 验证真实拖动、遮罩、全宽和返回收敛；在本包运行 flutter test。
void main() {
  Future<void> mount(
    WidgetTester tester,
    JobsSideMenuController controller, {
    bool fullWidth = false,
    JobsSideMenuPresentation presentation = JobsSideMenuPresentation.overlay,
  }) => tester.pumpWidget(
    MaterialApp(
      locale: const Locale('en'),
      supportedLocales: jobsDemoLocales,
      localizationsDelegates: jobsDemoLocalizationDelegates,
      home: JobsSideMenu(
        controller: controller,
        fullWidth: fullWidth,
        presentation: presentation,
        menu: const Center(
          key: ValueKey('menu-panel'),
          child: Text('menu-content'),
        ),
        child: const Scaffold(
          key: ValueKey('home-page'),
          body: Center(child: Text('body-content')),
        ),
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

  for (final fullWidth in [false, true]) {
    testWidgets(
      'push joins the menu and full page at every frame ($fullWidth)',
      (tester) async {
        final controller = JobsSideMenuController();
        await mount(
          tester,
          controller,
          fullWidth: fullWidth,
          presentation: JobsSideMenuPresentation.push,
        );
        final page = find.byKey(const ValueKey('home-page'));
        final menu = find.byKey(const ValueKey('menu-panel'));
        expect(tester.getRect(page).left, 0);
        expect(tester.getRect(menu).right, closeTo(0, .01));
        controller.open();
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 90));
        final during = tester.getRect(page);
        expect(during.left, greaterThan(0));
        expect(during.left, lessThan(fullWidth ? 800 : 624));
        expect(during.width, closeTo(800, .01));
        expect(tester.getRect(menu).right, closeTo(during.left, .01));
        await tester.pumpAndSettle();
        final opened = tester.getRect(page);
        expect(opened.left, closeTo(fullWidth ? 800 : 624, .01));
        expect(opened.width, closeTo(800, .01));
        expect(opened.height, closeTo(600, .01));
        expect(tester.getRect(menu).right, closeTo(opened.left, .01));
        await tester.tap(find.byTooltip('Close menu'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 90));
        expect(
          tester.getRect(menu).right,
          closeTo(tester.getRect(page).left, .01),
        );
        await tester.pumpAndSettle();
        expect(tester.getRect(page).left, 0);
        await tester.pumpWidget(const SizedBox());
        controller.dispose();
      },
    );
  }

  testWidgets('push edge drag, exposed page scrim and back all work', (
    tester,
  ) async {
    final controller = JobsSideMenuController();
    await mount(
      tester,
      controller,
      presentation: JobsSideMenuPresentation.push,
    );
    await tester.dragFrom(const Offset(8, 300), const Offset(610, 0));
    await tester.pumpAndSettle();
    expect(controller.isOpen, isTrue);
    await tester.tapAt(const Offset(760, 300));
    await tester.pumpAndSettle();
    expect(controller.isOpen, isFalse);
    expect(tester.getRect(find.byKey(const ValueKey('home-page'))).left, 0);
    controller.open();
    await tester.pumpAndSettle();
    await tester.dragFrom(const Offset(500, 300), const Offset(-500, 0));
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

  testWidgets('overlay keeps the page stationary while the menu moves', (
    tester,
  ) async {
    final controller = JobsSideMenuController();
    await mount(tester, controller);
    controller.open();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 90));
    expect(tester.getRect(find.byKey(const ValueKey('home-page'))).left, 0);
    await tester.pumpAndSettle();
    expect(tester.getRect(find.byKey(const ValueKey('home-page'))).left, 0);
    await tester.pumpWidget(const SizedBox());
    controller.dispose();
  });
}
