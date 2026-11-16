import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:jobs_demo_foundation/jobs_demo_foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../lib/demo_hub/catalog_repository.dart';
import '../lib/demo_hub/demo_hub_app.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({'hub.showClock': false}));

  testWidgets(
    'directory cards follow Swift geometry and preserve fold actions in both themes',
    (tester) async {
      tester.view.physicalSize = const Size(402, 874);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final settings = JobsDemoSettings(themeMode: ThemeMode.light);
      final repository = CatalogRepository(
        client: MockClient((_) async => http.Response('{}', 503)),
      );
      await tester.pumpWidget(
        DemoHubApp(
          settings: settings,
          repository: repository,
          splashDuration: Duration.zero,
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      final group = find.byKey(const ValueKey('group-交互与动画'));
      final surface = find.descendant(
        of: group,
        matching: find.byWidgetPredicate(
          (widget) =>
              widget is Material &&
              widget.borderRadius == BorderRadius.circular(14),
        ),
      );
      expect(surface, findsOneWidget);
      expect(tester.getTopLeft(surface).dx, 26);
      expect(tester.getSize(surface).width, 350);
      expect(tester.widget<Material>(surface).color, const Color(0xfff2f2f7));
      final header = find.byKey(const ValueKey('group-toggle-交互与动画'));
      final headerWidget = tester.widget<ListTile>(header);
      expect(headerWidget.minTileHeight, 64);
      expect(headerWidget.titleTextStyle!.fontSize, 17);
      expect(headerWidget.subtitleTextStyle!.fontSize, 13);
      final row = find.byKey(const ValueKey('demo-parallel-side-menu'));
      final tile = tester.widget<ListTile>(row);
      expect(tile.minTileHeight, 56);
      expect(tile.titleTextStyle!.fontSize, 17);
      expect(tile.subtitleTextStyle!.fontSize, 12);
      expect(
        find.descendant(of: group, matching: find.byType(Divider)),
        findsWidgets,
      );
      await tester.tap(header);
      await tester.pump();
      expect(row, findsNothing);
      settings.setThemeMode(ThemeMode.dark);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 350));
      expect(tester.widget<Material>(surface).color, const Color(0xff191b20));
      await tester.tap(header);
      await tester.pump();
      expect(row, findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
      settings.dispose();
      repository.close();
    },
  );
}
