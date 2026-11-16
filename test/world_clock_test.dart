import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jobs_demo_foundation/jobs_demo_foundation.dart';
import 'package:jobs_flutter_base_config/demo_hub/world_clock.dart';
import 'package:jobs_flutter_base_config/demo_hub/world_clock_page.dart';
import 'package:jobs_flutter_base_config/demo_hub/world_clock_strings.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('12小时制的午夜中午与下午明确AM/PM，24小时制保持完整时分秒', () {
    expect(
      clockTime(DateTime.utc(2026, 1, 1, 0, 5, 6), use12Hour: true),
      '12:05:06 AM',
    );
    expect(
      clockTime(DateTime.utc(2026, 1, 1, 12, 5, 6), use12Hour: true),
      '12:05:06 PM',
    );
    expect(
      clockTime(DateTime.utc(2026, 1, 1, 23, 5, 6), use12Hour: true),
      '11:05:06 PM',
    );
    expect(clockTime(DateTime.utc(2026, 1, 1, 0, 5, 6)), '00:05:06');
    expect(clockTime(DateTime.utc(2026, 1, 1, 23, 5, 6)), '23:05:06');
  });

  test('全球偏移含半小时四十五分钟，冬夏各一条并保留巴黎纽约', () {
    for (final instant in [
      DateTime.utc(2026, 1, 15),
      DateTime.utc(2026, 7, 15),
    ]) {
      final zones = WorldClockCatalog.zonesAt(instant);
      final offsets = zones
          .map((e) => e.at(instant).timeZoneOffset.inMinutes)
          .toList();
      expect(offsets, orderedEquals(offsets.toSet().toList()..sort()));
      expect(offsets.first, -12 * 60);
      expect(offsets.last, 14 * 60);
      expect(offsets, containsAll([-570, 330, 345, 390, 525, 570]));
      expect(offsets, contains(instant.month == 1 ? 825 : 765));
      expect(zones.any((e) => e.location.name == 'Europe/Paris'), isTrue);
      expect(zones.any((e) => e.location.name == 'America/New_York'), isTrue);
      expect(
        zones
            .where((e) => !worldClockTranslations.containsKey(e.city))
            .map((e) => '${e.city}:${e.location.name}')
            .toList(),
        isEmpty,
      );
    }
    expect(clockUtcOffset(const Duration(minutes: -210)), 'UTC−03:30');
    expect(clockUtcOffset(const Duration(minutes: 345)), 'UTC+05:45');
  });

  test('纽约巴黎夏令时跳时和跨日星期使用当地时间', () {
    WorldClockCatalog.initialize();
    final newYork = WorldClockZone('纽约', tz.getLocation('America/New_York'));
    final paris = WorldClockZone('巴黎', tz.getLocation('Europe/Paris'));
    expect(newYork.at(DateTime.utc(2026, 3, 8, 6, 59)).hour, 1);
    expect(newYork.at(DateTime.utc(2026, 3, 8, 7)).hour, 3);
    expect(paris.at(DateTime.utc(2026, 3, 29, 0, 59)).hour, 1);
    expect(paris.at(DateTime.utc(2026, 3, 29, 1)).hour, 3);
    final instant = DateTime.utc(2026, 11, 16, 1);
    expect(newYork.at(instant).day, 15);
    expect(newYork.at(instant).weekday, DateTime.sunday);
    expect(paris.at(instant).day, 16);
    expect(paris.at(instant).weekday, DateTime.monday);
  });

  testWidgets('世界时钟十语明暗主题大字窄屏展示日期星期并能滚动', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(280, 650);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    for (final locale in jobsDemoLocales) {
      for (final brightness in Brightness.values) {
        await tester.pumpWidget(
          MaterialApp(
            key: ValueKey('$locale/$brightness'),
            locale: locale,
            supportedLocales: jobsDemoLocales,
            localizationsDelegates: jobsDemoLocalizationDelegates,
            theme: jobsDemoTheme(brightness),
            builder: (context, child) => MediaQuery(
              data: MediaQuery.of(context)
                  .copyWith(textScaler: TextScaler.linear(2)),
              child: child!,
            ),
            home: WorldClockPage(
              now: () => DateTime.utc(2026, 11, 16, 1, 2, 3),
            ),
          ),
        );
        await tester.pump();
        expect(
          find.byKey(const ValueKey('world-clock-current')),
          findsOneWidget,
          reason: '$locale/$brightness',
        );
        expect(
          find.byKey(const PageStorageKey('world-clock-list')),
          findsOneWidget,
        );
        await tester.drag(find.byType(ListView), const Offset(0, -500));
        await tester.pump(const Duration(milliseconds: 100));
        expect(tester.takeException(), isNull, reason: '$locale/$brightness');
      }
    }
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('世界时钟只在当前页面前台刷新，返回和恢复立即校时', (tester) async {
    var reads = 0;
    final navigator = GlobalKey<NavigatorState>();
    await tester.pumpWidget(
      MaterialApp(
        navigatorKey: navigator,
        localizationsDelegates: jobsDemoLocalizationDelegates,
        home: WorldClockPage(
          now: () {
            reads++;
            return DateTime.utc(2026, 11, 16, 1, 2, reads);
          },
        ),
      ),
    );
    await tester.pump();
    var count = reads;
    await tester.pump(const Duration(seconds: 2));
    expect(reads, greaterThan(count));
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    count = reads;
    await tester.pump(const Duration(seconds: 3));
    expect(reads, count);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pump();
    expect(reads, greaterThan(count));
    navigator.currentState!.push(
      MaterialPageRoute<void>(
        builder: (_) => const Scaffold(body: Text('覆盖页面')),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    count = reads;
    await tester.pump(const Duration(seconds: 3));
    expect(reads, count);
    navigator.currentState!.pop();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(reads, greaterThan(count));
    await tester.pumpWidget(const SizedBox());
    expect(tester.takeException(), isNull);
  });

  testWidgets('12小时开关立即刷新并持久化，切换保留滚动位置', (tester) async {
    final changes = <bool>[];
    Widget page() => MaterialApp(
      localizationsDelegates: jobsDemoLocalizationDelegates,
      home: WorldClockPage(
        now: () => DateTime.utc(2026, 11, 16, 1, 2, 3),
        onFormatChanged: changes.add,
      ),
    );
    await tester.pumpWidget(page());
    await tester.pump();
    final toggle = find.byKey(const ValueKey('world-clock-12-hour'));
    expect(tester.widget<SwitchListTile>(toggle).value, isFalse);
    await tester.tap(toggle);
    await tester.pump();
    expect(tester.widget<SwitchListTile>(toggle).value, isTrue);
    expect(
      find.textContaining(RegExp(r'\d{2}:\d{2}:\d{2} (AM|PM)')),
      findsWidgets,
    );
    expect(changes, [true]);
    expect(
      (await SharedPreferences.getInstance()).getBool('hub.worldClock12Hour'),
      isTrue,
    );
    await tester.drag(find.byType(ListView), const Offset(0, -450));
    await tester.pump(const Duration(seconds: 1));
    final scroll = tester.state<ScrollableState>(
      find.descendant(
        of: find.byType(ListView),
        matching: find.byType(Scrollable),
      ),
    );
    final position = scroll.position.pixels;
    expect(position, greaterThan(0));
    await tester.tap(toggle);
    await tester.pump();
    expect(scroll.position.pixels, position);
    expect(
      find.textContaining(RegExp(r'\d{2}:\d{2}:\d{2} (AM|PM)')),
      findsNothing,
    );
    await tester.tap(toggle);
    await tester.pump();
    await tester.pumpWidget(const SizedBox());
    await tester.pumpWidget(page());
    await tester.pump();
    expect(tester.widget<SwitchListTile>(toggle).value, isTrue);
    await tester.pumpWidget(const SizedBox());
    expect(tester.takeException(), isNull);
  });
}
