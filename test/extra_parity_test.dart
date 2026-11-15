import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jobs_demo_foundation/jobs_demo_foundation.dart';
import 'package:lunar/lunar.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../lib/demo_hub/extra_catalog.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
  });
  for (final mode in [ThemeMode.light, ThemeMode.dark]) {
    for (final entry in extraDemos) {
      testWidgets('${entry.id} ${mode.name} compact mount dispose', (t) async {
        t.view.physicalSize = const Size(320, 640);
        t.view.devicePixelRatio = 1;
        addTearDown(t.view.resetPhysicalSize);
        addTearDown(t.view.resetDevicePixelRatio);
        await t.pumpWidget(
          JobsDemoApp(
            settings: JobsDemoSettings(themeMode: mode),
            home: Builder(builder: entry.builder),
          ),
        );
        await t.pump(const Duration(milliseconds: 200));
        expect(t.takeException(), isNull);
        if (entry.id == 'extra-excel') {
          await t.tap(find.widgetWithText(ChoiceChip, '3'));
          await t.pump();
          expect(t.takeException(), isNull);
          for (final name in ['换行', '缩放', '滚动']) {
            final finder = find.widgetWithText(ChoiceChip, name);
            if (finder.evaluate().isNotEmpty) {
              await t.tap(finder);
              await t.pump();
              expect(t.takeException(), isNull);
            }
          }
        }
        await t.pumpWidget(const SizedBox());
        await t.pump();
        expect(t.takeException(), isNull);
      });
    }
  }
  test('Lunar new year and leap month are calculated', () {
    final v = Solar.fromYmd(2026, 2, 17).getLunar();
    expect(v.getMonth(), 1);
    expect(v.getDay(), 1);
    expect(Solar.fromYmd(2025, 7, 25).getLunar().getMonth(), -6);
  });
}
