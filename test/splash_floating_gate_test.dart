import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jobs_flutter_base_config/demo_hub/home_floating_controls.dart';

void main() {
  testWidgets('浮钟等开屏离场完成才出现，重播开屏期间隐藏且返回保留位置', (tester) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.linux;
    addTearDown(() => debugDefaultTargetPlatformOverride = null);
    final navigation = GlobalKey<NavigatorState>();
    await tester.pumpWidget(
      MaterialApp(
        navigatorKey: navigation,
        home: const Scaffold(body: Text('splash')),
      ),
    );
    navigation.currentState!.pushReplacement(
      PageRouteBuilder<void>(
        transitionDuration: const Duration(milliseconds: 300),
        pageBuilder: (_, animation, secondary) => HomeFloatingControls(
          active: true,
          showClock: true,
          onClockVisibilityChanged: (_) {},
          child: const Scaffold(body: Text('home')),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 150));
    final clock = find.byKey(const ValueKey('floating-clock'));
    expect(find.text('splash'), findsOneWidget);
    expect(clock, findsNothing);
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.text('splash'), findsNothing);
    expect(clock, findsOneWidget);
    final frame = tester.getRect(clock);
    navigation.currentState!.push(
      MaterialPageRoute<void>(
        builder: (_) => const Scaffold(body: Text('replay splash')),
      ),
    );
    await tester.pump();
    expect(clock, findsNothing);
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('replay splash'), findsOneWidget);
    expect(clock, findsNothing);
    navigation.currentState!.pop();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(clock, findsOneWidget);
    expect(tester.getRect(clock), frame);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
  });
}
