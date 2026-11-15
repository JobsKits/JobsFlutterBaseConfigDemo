import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:jobs_demo_foundation/jobs_demo_foundation.dart';
import 'package:jobs_flutter_base_config/demo_hub/catalog_repository.dart';
import 'package:jobs_flutter_base_config/demo_hub/demo_hub_app.dart';
import 'package:shared_preferences/shared_preferences.dart';

// 验证开屏移除、目录搜索/收藏恢复、全局外观及离线 API 契约。
void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

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
    await tester.pumpAndSettle();
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
    await tester.tap(find.byKey(const ValueKey('hub-search')));
    await tester.enterText(
      find.byKey(const ValueKey('hub-search')),
      'unmatched-function-1429',
    );
    await tester.pumpAndSettle();
    expect(find.text('没有匹配的功能'), findsOneWidget);
    expect(find.byKey(const PageStorageKey('demo-list')), findsNothing);
    await tester.tap(find.widgetWithText(FilledButton, '清空搜索'));
    await tester.pumpAndSettle();
    expect(find.byKey(const PageStorageKey('demo-list')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('侧滑菜单设置半开全开，收藏空态可恢复目录', (tester) async {
    await launch(tester);
    await tester.tap(find.byTooltip('打开菜单'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(ListTile, '收藏'));
    await tester.pumpAndSettle();
    expect(find.text('尚无收藏'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('hub-search')));
    await tester.enterText(find.byKey(const ValueKey('hub-search')), 'calendar');
    await tester.pumpAndSettle();
    expect(find.text('日历选择'), findsOneWidget);
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.text('尚无收藏'), findsOneWidget);
    await tester.tap(find.widgetWithText(FilledButton, '全部功能'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('设置').last);
    await tester.pumpAndSettle();
    await tester.tap(find.byType(SwitchListTile));
    await tester.pumpAndSettle();
    expect(find.text('全开'), findsOneWidget);
    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
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
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull, reason: '$locale / $mode');
        expect(find.text(JobsDemoStrings(locale).text('功能实验室')), findsOneWidget);
        expect(find.byKey(const ValueKey('demo-home')), findsOneWidget);
      }
    }
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
    await repo.savePreference('favorites', ['clock']);
    expect(requests.last.method, 'PUT');
    expect(jsonDecode(requests.last.body), {
      'value': ['clock'],
    });
  });
}
