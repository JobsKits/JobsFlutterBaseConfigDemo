import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:jobs_demo_foundation/jobs_demo_foundation.dart';
import 'package:jobs_flutter_base_config/demo_hub/legacy_catalog.dart';
import 'package:shared_preferences/shared_preferences.dart';

// 遍历每个旧教学入口的进入与退出；依赖硬件/外部SDK的页面单独设备验收。
void main() {
  SharedPreferences.setMockInitialValues({});
  for (final entry in legacyDemos) {
    testWidgets('${entry.id} ${entry.title}', (tester) async {
      await tester.pumpWidget(
        JobsDemoScope(
          settings: JobsDemoSettings(),
          child: GetMaterialApp(
            supportedLocales: jobsDemoLocales,
            localizationsDelegates: jobsDemoLocalizationDelegates,
            home: Builder(builder: entry.builder),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 150));
      expect(tester.takeException(), isNull);
      expect(find.byKey(const ValueKey('legacy-launch-error')), findsNothing);
      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(seconds: 1));
      expect(tester.takeException(), isNull);
    }, variant: TargetPlatformVariant.only(TargetPlatform.linux));
  }
}
