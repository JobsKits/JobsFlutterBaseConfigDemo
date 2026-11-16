import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:jobs_demo_foundation/jobs_demo_foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../lib/demo_hub/curated_catalog.dart';
import '../lib/demo_hub/data_parity_catalog.dart';
import '../lib/demo_hub/extra_catalog.dart';
import '../lib/demo_hub/interop_catalog.dart';
import '../lib/demo_hub/legacy_catalog.dart';
import '../lib/demo_hub/native_catalog.dart';
import '../lib/demo_hub/parallel_catalog.dart';
import '../lib/demo_hub/platform_catalog.dart';
import '../lib/demo_hub/ui_parity_catalog.dart';

// 遍历真实目录builder，检查公共入口接线；不替代具体Demo或真机能力验收。
void main() {
  final entries = <({String id, WidgetBuilder builder})>[
    for (final entry in [
      ...legacyDemos,
      ...nativeDemos,
      ...dataParityDemos,
      ...interopDemos,
      ...extraDemos,
      ...uiParityDemos,
      ...platformDemos,
      ...curatedDemos,
    ])
      (id: entry.id, builder: entry.builder),
    for (final entry in parallelDemos) (id: entry.id, builder: entry.builder),
  ];

  testWidgets(
    'all registered Demo builders expose exactly one working theme/action entry',
    (tester) async {
      SharedPreferences.setMockInitialValues({});
      final registeredIds = entries.map((e) => e.id).toSet();
      final snapshot = jsonDecode(
        File('test/fixtures/demo_toolbar_baseline_2026_11_16.json')
            .readAsStringSync(),
      ) as Map<String, dynamic>;
      final baselineIds = (snapshot['ids'] as List).cast<String>().toSet();
      expect(
        baselineIds,
        hasLength(299),
        reason: 'Previously verified baseline snapshot',
      );
      expect(
        registeredIds,
        hasLength(entries.length),
        reason: 'Every registration must have a unique stable ID',
      );
      expect(
        registeredIds,
        containsAll(baselineIds),
        reason: 'Adding a Demo must preserve all previously verified IDs',
      );
      final checkedIds = <String>{};
      for (final entry in entries) {
        final settings = JobsDemoSettings(themeMode: ThemeMode.light);
        await tester.pumpWidget(
          JobsDemoScope(
            settings: settings,
            child: AnimatedBuilder(
              animation: settings,
              builder: (_, __) => GetMaterialApp(
                theme: jobsDemoTheme(Brightness.light),
                darkTheme: jobsDemoTheme(Brightness.dark),
                themeMode: settings.themeMode,
                supportedLocales: jobsDemoLocales,
                localizationsDelegates: jobsDemoLocalizationDelegates,
                home: Builder(builder: entry.builder),
              ),
            ),
          ),
        );
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 200));
        await tester.pump();
        expect(tester.takeException(), isNull, reason: entry.id);
        final direct = find.byKey(const ValueKey('demo-theme-action'));
        final menu = find.byKey(const ValueKey('demo-actions-menu'));
        expect(
          direct.evaluate().length + menu.evaluate().length,
          1,
          reason: entry.id,
        );
        if (menu.evaluate().isNotEmpty) {
          await tester.tap(menu);
          await tester.pump();
          await tester.pump(const Duration(milliseconds: 350));
          await tester.tap(find.byKey(const ValueKey('demo-theme-menu-item')));
        } else {
          await tester.tap(direct);
        }
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 350));
        await tester.pump();
        expect(settings.themeMode, ThemeMode.dark, reason: entry.id);
        for (final toolbar in find.byType(JobsDemoAppBar).evaluate()) {
          expect(
            Theme.of(toolbar).brightness,
            Brightness.dark,
            reason: '${entry.id}: actual Material toolbar theme',
          );
        }
        for (final page in find.byType(CupertinoPageScaffold).evaluate()) {
          expect(
            CupertinoTheme.of(page).brightness,
            Brightness.dark,
            reason: '${entry.id}: actual Cupertino page theme',
          );
        }
        expect(tester.takeException(), isNull, reason: entry.id);
        await tester.pumpWidget(const SizedBox());
        await tester.pump(const Duration(seconds: 1));
        expect(tester.takeException(), isNull, reason: entry.id);
        settings.dispose();
        checkedIds.add(entry.id);
      }
      expect(
        checkedIds,
        unorderedEquals(registeredIds),
        reason: 'The actual theme interaction must run for the complete current registry',
      );
      debugPrint(
        'Demo toolbar coverage: ${checkedIds.length} registered; ${baselineIds.length} baseline IDs preserved',
      );
    },
    variant: TargetPlatformVariant.only(TargetPlatform.linux),
  );
}
