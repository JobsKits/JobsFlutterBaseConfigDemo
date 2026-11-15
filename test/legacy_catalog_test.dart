import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:jobs_demo_foundation/jobs_demo_foundation.dart';
import 'package:jobs_flutter_base_config/demo_hub/legacy_catalog.dart';
import 'package:shared_preferences/shared_preferences.dart';

// 检查已接入旧 Demo 能进入与退出；原生插件由设备集成验收覆盖。
void main() {
  SharedPreferences.setMockInitialValues({});
  for (final demo in legacyDemos.where(
    (e) => !e.id.startsWith('legacy-complete-'),
  )) {
    if (demo.group == '媒体与设备' ||
        demo.group == '网络与存储' ||
        demo.id == 'legacy-fortune') {
      continue;
    }
    testWidgets('${demo.id} mounts and disposes', (tester) async {
      await tester.pumpWidget(
        GetMaterialApp(
          supportedLocales: jobsDemoLocales,
          localizationsDelegates: jobsDemoLocalizationDelegates,
          home: Builder(builder: demo.builder),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(seconds: 1));
      expect(tester.takeException(), isNull);
    });
  }
}
