import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:jobs_demo_foundation/jobs_demo_foundation.dart';
import 'package:jobs_flutter_base_config/demo_hub/catalog_repository.dart';
import 'package:jobs_flutter_base_config/demo_hub/demo_hub_app.dart';
import 'package:jobs_flutter_base_config/demo_hub/home_floating_controls.dart';
import 'package:shared_preferences/shared_preferences.dart';

// 验证开屏移除、目录搜索/最近使用、全局外观及离线 API 契约。
void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  Future<void> settle(WidgetTester tester) async {
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump();
  }

  Future<void> launch(WidgetTester tester, {JobsDemoSettings? settings}) async {
    await tester.pumpWidget(
      DemoHubApp(
        settings: settings ?? JobsDemoSettings(),
        repository: CatalogRepository(
          client: MockClient((_) async => http.Response('{}', 503)),
        ),
        splashDuration: const Duration(milliseconds: 100),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 101));
    await settle(tester);
  }

  testWidgets('开屏结束替换为目录，搜索独占并能清空恢复', (tester) async {
    await launch(tester);
    expect(find.byKey(const ValueKey('splash')), findsNothing);
    expect(find.byKey(const ValueKey('demo-home')), findsOneWidget);
    expect(
      Navigator.of(tester.element(find.byKey(const ValueKey('demo-home'))))
          .canPop(),
      isFalse,
    );
    expect(find.byKey(const ValueKey('hub-search')), findsNothing);
    await tester.tap(find.byKey(const ValueKey('hub-menu')));
    await settle(tester);
    await tester.tap(find.text('搜索Demo'));
    await settle(tester);
    await tester.enterText(
      find.byKey(const ValueKey('hub-search')),
      'unmatched-function-1429',
    );
    await settle(tester);
    expect(find.text('没有匹配的功能'), findsOneWidget);
    expect(find.byKey(const PageStorageKey('demo-list')), findsNothing);
    await tester.tap(find.widgetWithText(FilledButton, '清空搜索'));
    await settle(tester);
    expect(find.byKey(const PageStorageKey('demo-list')), findsNothing);
    expect(find.text('没有搜索历史'), findsOneWidget);
    await tester.tap(find.widgetWithText(TextButton, '取消'));
    await settle(tester);
    expect(find.byKey(const PageStorageKey('demo-list')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('首页项目来源副标题与世界时钟骨架导航，返回不写Demo最近', (tester) async {
    await launch(tester);
    expect(find.text('JobsFlutterBaseConfigDemo'), findsOneWidget);
    final clock = find.byKey(const ValueKey('floating-clock'));
    final position = tester.getTopLeft(clock);
    await tester.tap(clock);
    await settle(tester);
    expect(find.byKey(const ValueKey('world-clock-page')), findsOneWidget);
    expect(find.text('世界时钟'), findsOneWidget);
    expect(find.text('当前时区'), findsOneWidget);
    expect(clock, findsNothing);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getStringList('hub.recent'), isNull);
    await tester.tap(find.byType(BackButton));
    await settle(tester);
    expect(find.byKey(const ValueKey('demo-home')), findsOneWidget);
    expect(tester.getTopLeft(clock), position);
    expect(prefs.getStringList('hub.recent'), isNull);
    await tester.pumpWidget(const SizedBox());
    expect(tester.takeException(), isNull);
  });

  testWidgets('搜索历史与无结果空态在键盘上方共享页面中心轴', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(402, 874);
    tester.view.viewInsets = const FakeViewPadding(bottom: 320);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetViewInsets);
    await launch(tester);
    await tester.tap(find.byKey(const ValueKey('hub-menu')));
    await settle(tester);
    await tester.tap(find.text('搜索Demo'));
    await settle(tester);

    void expectCentered(String title) {
      final page = tester.getRect(
        find.byKey(const ValueKey('hub-search-page')),
      );
      final empty = find.byType(JobsEmptyState);
      expect(tester.getRect(empty).width, closeTo(page.width, .01));
      for (final content in [
        find.descendant(of: empty, matching: find.byIcon(Icons.inbox_outlined)),
        find.text(title),
        find.descendant(of: empty, matching: find.text('搜索功能')),
        find.descendant(of: empty, matching: find.byType(FilledButton)),
      ]) {
        for (final element in content.evaluate()) {
          final finder = find.byElementPredicate((value) => value == element);
          expect(tester.getCenter(finder).dx, closeTo(page.center.dx, .01));
        }
      }
    }

    expectCentered('没有搜索历史');
    await tester.enterText(
      find.byKey(const ValueKey('hub-search')),
      'unmatched-1429',
    );
    await settle(tester);
    expectCentered('没有匹配的功能');
    // 横屏和大字压缩垂直空间时，内容仍居中且可以滚到重载动作。
    tester.view.physicalSize = const Size(874, 402);
    tester.view.viewInsets = const FakeViewPadding(bottom: 180);
    tester.platformDispatcher.textScaleFactorTestValue = 1.6;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await settle(tester);
    expectCentered('没有匹配的功能');
    final reload = find.widgetWithText(FilledButton, '重新加载');
    await tester.ensureVisible(reload);
    expect(reload.hitTestable(), findsOneWidget);
    await tester.tap(find.byTooltip('清空搜索'));
    await settle(tester);
    expectCentered('没有搜索历史');
    expect(tester.takeException(), isNull);
  });

  testWidgets('侧滑菜单设置半开全开，最近空态可恢复且移除收藏', (tester) async {
    await launch(tester);
    await tester.tap(find.byTooltip('打开菜单'));
    await settle(tester);
    expect(find.text('收藏'), findsNothing);
    await tester.tap(find.widgetWithText(ListTile, '最近使用'));
    await settle(tester);
    expect(find.text('尚无浏览记录'), findsOneWidget);
    expect(find.byKey(const ValueKey('hub-search')), findsNothing);
    await tester.tap(find.byKey(const ValueKey('hub-menu')));
    await settle(tester);
    await tester.tap(find.text('搜索Demo'));
    await settle(tester);
    await tester.enterText(
      find.byKey(const ValueKey('hub-search')),
      'calendar',
    );
    await settle(tester);
    expect(find.text('日历选择'), findsOneWidget);
    await tester.binding.handlePopRoute();
    await settle(tester);
    expect(find.text('尚无浏览记录'), findsOneWidget);
    await tester.tap(find.widgetWithText(FilledButton, '全部功能'));
    await settle(tester);
    await tester.tap(find.byKey(const ValueKey('hub-menu')));
    await settle(tester);
    await tester.tap(find.text('设置').last);
    await settle(tester);
    await tester.scrollUntilVisible(
      find.widgetWithText(SwitchListTile, '侧滑菜单'),
      180,
      scrollable: find
          .descendant(
            of: find.byKey(const ValueKey('hub-settings-list')),
            matching: find.byType(Scrollable),
          )
          .first,
    );
    await Scrollable.ensureVisible(
      tester.element(find.widgetWithText(SwitchListTile, '侧滑菜单')),
      alignment: .5,
    );
    await tester.tap(find.widgetWithText(SwitchListTile, '侧滑菜单'));
    await settle(tester);
    expect(find.text('全开'), findsOneWidget);
    await tester.tap(find.byType(BackButton));
    await settle(tester);
    expect(
      tester.widget<JobsSideMenu>(find.byType(JobsSideMenu)).fullWidth,
      isTrue,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('十语与三种主题在目录中切换，无本地化断言', (tester) async {
    final settings = JobsDemoSettings();
    await launch(tester, settings: settings);
    for (final locale in jobsDemoLocales) {
      settings.setLocale(locale);
      for (final mode in ThemeMode.values) {
        settings.setThemeMode(mode);
        await settle(tester);
        expect(tester.takeException(), isNull, reason: '$locale / $mode');
        expect(
          find.text(JobsDemoStrings(locale).text('功能实验室')),
          findsOneWidget,
        );
        expect(find.byKey(const ValueKey('demo-home')), findsOneWidget);
      }
    }
  });

  testWidgets('iOS下拉目录跟手但位移有界，松手回弹，两种刷新样式一致', (tester) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    addTearDown(() => debugDefaultTargetPlatformOverride = null);
    final settings = JobsDemoSettings();
    await launch(tester, settings: settings);
    final list = find.byKey(const PageStorageKey('demo-list'));
    for (final style in JobsRefreshStyle.values) {
      settings.setRefreshStyle(style);
      await settle(tester);
      final scrollable = find
          .descendant(of: list, matching: find.byType(Scrollable))
          .first;
      final position = tester.state<ScrollableState>(scrollable).position;
      final header = find.byKey(const ValueKey('group-toggle-交互与动画'));
      final originalTop = tester.getTopLeft(header).dy;
      final drag = await tester.startGesture(
        tester.getTopLeft(list) + const Offset(100, 160),
      );
      await drag.moveBy(const Offset(0, 600));
      await tester.pump(const Duration(milliseconds: 100));
      await drag.moveBy(const Offset(0, 600));
      await tester.pump(const Duration(milliseconds: 100));
      final pulled = position.minScrollExtent - position.pixels;
      expect(pulled, greaterThan(30), reason: style.name);
      expect(pulled, lessThanOrEqualTo(120.01), reason: style.name);
      expect(
        tester.getTopLeft(header).dy,
        closeTo(originalTop + pulled, .01),
        reason: style.name,
      );
      await drag.up();
      await settle(tester);
      await tester.pump(const Duration(seconds: 1));
      expect(position.pixels, closeTo(position.minScrollExtent, .5));
      expect(tester.takeException(), isNull);
    }
  });

  testWidgets('搜索打开功能计入最近，去重并跨重启恢复，行菜单没有收藏', (tester) async {
    Future<void> openCalendar() async {
      await tester.tap(find.byKey(const ValueKey('hub-menu')));
      await settle(tester);
      await tester.tap(find.text('搜索Demo'));
      await settle(tester);
      await tester.enterText(
        find.byKey(const ValueKey('hub-search')),
        'calendar',
      );
      await settle(tester);
      await tester.tap(find.text('日历选择'));
      await settle(tester);
      await tester.binding.handlePopRoute();
      await settle(tester);
      await tester.tap(find.widgetWithText(TextButton, '取消'));
      await settle(tester);
    }

    await launch(tester);
    await openCalendar();
    await openCalendar();
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getStringList('hub.recent'), ['calendar']);
    await tester.pumpWidget(const SizedBox());
    await launch(tester);
    await tester.tap(find.byTooltip('打开菜单'));
    await settle(tester);
    await tester.tap(find.widgetWithText(ListTile, '最近使用'));
    await settle(tester);
    expect(find.text('日历选择'), findsOneWidget);
    await tester.tap(
      find.descendant(
        of: find.byKey(const ValueKey('demo-calendar')),
        matching: find.byType(PopupMenuButton<String>),
      ),
    );
    await settle(tester);
    expect(find.text('收藏'), findsNothing);
    expect(find.text('源码位置'), findsOneWidget);
    await tester.binding.handlePopRoute();
    await settle(tester);
    expect(tester.takeException(), isNull);
  });

  testWidgets('置顶进入独立顶部组，取消置顶返回原组且搜索不暴露悬浮层', (tester) async {
    await launch(tester);
    final initial = tester.widget<ListTile>(
      find
          .byWidgetPredicate(
            (widget) =>
                widget is ListTile &&
                widget.key is ValueKey<String> &&
                (widget.key! as ValueKey<String>).value.startsWith('demo-'),
          )
          .first,
    );
    final key = initial.key!;
    await tester.tap(find.byTooltip('置顶').first);
    await settle(tester);
    expect(find.byKey(const ValueKey('group-@pinned')), findsOneWidget);
    expect(
      find.descendant(
        of: find.byKey(const ValueKey('group-@pinned')),
        matching: find.byKey(key),
      ),
      findsOneWidget,
    );
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getStringList('hub.layout.pinned'), isNotEmpty);
    await tester.tap(find.byKey(const ValueKey('hub-menu')));
    await settle(tester);
    await tester.tap(find.text('搜索Demo'));
    await settle(tester);
    expect(
      tester
          .widget<HomeFloatingControls>(
            find.byType(HomeFloatingControls, skipOffstage: false),
          )
          .active,
      isFalse,
    );
    await tester.binding.handlePopRoute();
    await settle(tester);
    await tester.tap(find.byTooltip('取消置顶').first);
    await settle(tester);
    expect(find.byKey(const ValueKey('group-@pinned')), findsNothing);
    expect(find.byKey(key), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('组头仅保留拖动柄，拖动保留落点，关闭记忆后重启恢复', (tester) async {
    await launch(tester);
    await tester.tap(find.byKey(const ValueKey('hub-menu')));
    await settle(tester);
    await tester.tap(find.text('全部收缩'));
    await settle(tester);
    final list = find.byKey(const PageStorageKey('demo-list'));
    final firstGroup = find.byKey(const ValueKey('group-交互与动画'));
    expect(
      find.descendant(
        of: firstGroup,
        matching: find.byType(PopupMenuButton<String>),
      ),
      findsNothing,
    );
    expect(
      find.descendant(
        of: firstGroup,
        matching: find.byType(ReorderableDragStartListener),
      ),
      findsOneWidget,
    );
    final handles = find.descendant(
      of: list,
      matching: find.byType(ReorderableDragStartListener),
    );
    final first = tester.getCenter(handles.at(0));
    final second = tester.getCenter(handles.at(1));
    final drag = await tester.startGesture(first);
    await tester.pump();
    await drag.moveBy(const Offset(0, 12));
    await tester.pump(const Duration(milliseconds: 100));
    await drag.moveTo(second + const Offset(0, 65));
    await tester.pump(const Duration(milliseconds: 400));
    await drag.up();
    await settle(tester);
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getStringList('hub.layout.groups');
    expect(saved, isNotEmpty);
    await tester.tap(find.byKey(const ValueKey('hub-menu')));
    await settle(tester);
    await tester.tap(find.text('设置').last);
    await settle(tester);
    await tester.scrollUntilVisible(
      find.widgetWithText(SwitchListTile, '记住列表布局'),
      200,
      scrollable: find
          .descendant(
            of: find.byKey(const ValueKey('hub-settings-list')),
            matching: find.byType(Scrollable),
          )
          .first,
    );
    await Scrollable.ensureVisible(
      tester.element(find.widgetWithText(SwitchListTile, '记住列表布局')),
      alignment: .5,
    );
    await settle(tester);
    await tester.tap(find.widgetWithText(SwitchListTile, '记住列表布局'));
    await settle(tester);
    expect(prefs.getStringList('hub.layout.groups'), isNull);
    await tester.pumpWidget(const SizedBox());
    await launch(tester);
    expect(find.byTooltip('置顶'), findsWidgets);
    expect(prefs.getBool('hub.rememberLayout'), isFalse);
    expect(tester.takeException(), isNull);
  });

  test('目录解析失败回退，恢复后重新读服务；写入请求有JSON值', () async {
    var reads = 0;
    final requests = <http.Request>[];
    final repo = CatalogRepository(
      client: MockClient((request) async {
        requests.add(request);
        if (request.method == 'PUT') return http.Response('', 204);
        reads++;
        return reads == 1
            ? http.Response('invalid json', 200)
            : http.Response('{"ids":["menu","clock"]}', 200);
      }),
    );
    addTearDown(repo.close);
    expect(await repo.loadOrder(), isNull);
    expect(await repo.loadOrder(), ['menu', 'clock']);
    await repo.savePreference('recent', ['clock']);
    expect(requests.last.method, 'PUT');
    expect(jsonDecode(requests.last.body), {
      'value': ['clock'],
    });
  });

  testWidgets('全局主题语言刷新样式变化均请求服务，离线仍更新本地', (tester) async {
    final settings = JobsDemoSettings();
    final requests = <http.Request>[];
    final repository = CatalogRepository(
      client: MockClient((request) async {
        requests.add(request);
        return http.Response('', 503);
      }),
    );
    addTearDown(repository.close);
    await tester.pumpWidget(
      DemoHubApp(
        settings: settings,
        repository: repository,
        splashDuration: Duration.zero,
      ),
    );
    await settle(tester);
    await settle(tester);
    settings.setThemeMode(ThemeMode.dark);
    settings.setLocale(const Locale('en'));
    settings.setRefreshStyle(JobsRefreshStyle.jobs);
    await settle(tester);
    final keys = requests
        .where((request) => request.method == 'PUT')
        .map((request) => request.url.pathSegments.last)
        .toSet();
    expect(keys, containsAll(['theme', 'locale', 'refreshStyle']));
    expect(settings.refreshStyle, JobsRefreshStyle.jobs);
    expect(tester.takeException(), isNull);
  });
}
