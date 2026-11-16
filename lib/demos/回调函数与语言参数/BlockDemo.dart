// 独立运行：flutter run -t "lib/demos/回调函数与语言参数/BlockDemo.dart"
// 使用本工程 pubspec.yaml 声明的依赖与资源。

import 'package:jobs_flutter_base_config/demo_hub/legacy_launch.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jobs_flutter_base_config/JobsDemoTools/Data/Data.Origin🌍/Block/ACtrl.dart';
import 'package:jobs_demo_foundation/jobs_demo_foundation.dart';

/// 独立运行与目录预览共用同一份原始教学逻辑。
void main() => launchLegacyStandalone(legacyOriginalMain, title: '回调函数与语言参数');

// 模拟 Objective-C 中的 Block
void legacyOriginalMain() {
  legacyCaptureApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return LegacyAppBoundary(app: GetMaterialApp(home: HomeScreen()));
  }
}

class HomeScreen extends StatelessWidget {
  HomeScreen({super.key});
  final ACtrl aCtrl = Get.put(ACtrl());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: JobsDemoAppBar(
        title: const LegacyText('Locale Callback Example'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: () {
                // 在外层设置回调函数
                aCtrl.setLocaleCallback(() {
                  return Get.deviceLocale ?? const Locale('en', 'US');
                });
                legacyDebugPrint("Callback has been set.");
              },
              child: const LegacyText('Set Locale Callback'),
            ),
            ElevatedButton(
              onPressed: () {
                aCtrl.useLocaleCallback();
                aCtrl.useJobsCallback();
              },
              child: const LegacyText('Use Locale Callback'),
            ),
          ],
        ),
      ),
    );
  }
}

Widget buildLegacyDemo(BuildContext context) =>
    LegacyLaunchPage(action: legacyOriginalMain, title: 'BlockDemo');
