import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jobs_demo_foundation/jobs_demo_foundation.dart';
import 'package:jobs_flutter_base_config/demo_hub/data_parity_catalog.dart';
import 'package:jobs_flutter_base_config/demo_hub/lab_strings.dart';
import 'package:shared_preferences/shared_preferences.dart';

// 所有数据/网络/微应用页面在窄屏大字与明暗下挂载退出；不在单测申请相机等系统权限。
void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    JobsDemoStrings.registerTranslations(labTranslations);
  });
  for (final demo in dataParityDemos) {
    for (final brightness in Brightness.values) {
      testWidgets('${demo.id} $brightness', (tester) async {
        tester.view.physicalSize = const Size(360, 780);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        await tester.pumpWidget(
          JobsDemoApp(
            settings: JobsDemoSettings(
              locale: const Locale('de'),
              themeMode: brightness == Brightness.dark
                  ? ThemeMode.dark
                  : ThemeMode.light,
            ),
            home: Builder(builder: demo.builder),
          ),
        );
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox());
        await tester.pump(const Duration(seconds: 1));
        expect(tester.takeException(), isNull);
      });
    }
  }
}
