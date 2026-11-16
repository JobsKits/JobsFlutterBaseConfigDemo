// 独立运行：flutter run -t "lib/demos/GetX页面生命周期教学/GetXLifeCycleDemo.dart"
// 使用本工程 pubspec.yaml 声明的依赖与资源。

import 'package:jobs_flutter_base_config/demo_hub/legacy_launch.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:jobs_flutter_base_config/JobsDemoTools/UI/UI.3rd🌹/GetX/GetX管理的页面的生命周期/GetX.PageA/views/pageA_view.dart';

/// 独立运行与目录预览共用同一份原始教学逻辑。
void main() =>
    launchLegacyStandalone(legacyOriginalMain, title: 'GetX页面生命周期教学');

void legacyOriginalMain() {
  legacyCaptureApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.inactive:
        // 应用程序处于非活动状态
        legacyDebugPrint('应用程序处于非活动状态');
        break;
      case AppLifecycleState.paused:
        // 应用程序处于后台
        legacyDebugPrint('应用程序处于后台');
        break;
      case AppLifecycleState.resumed:
        // 应用程序处于前台并可交互
        legacyDebugPrint('应用程序处于前台并可交互');
        break;
      case AppLifecycleState.detached:
        // 应用程序没有关联的 Flutter 引擎
        legacyDebugPrint('应用程序没有关联的 Flutter 引擎');
        break;
      case AppLifecycleState.hidden:
        // AppLifecycleState.hidden 是 Flutter 中的一个枚举值，它表示应用程序的状态在 iOS 平台上被隐藏时的状态。
        // 具体来说，AppLifecycleState.hidden 是在 iOS 上当用户按下主屏幕按钮或切换到另一个应用程序时，Flutter 应用程序进入后台并且不再可见的状态。
        // 在 Android 平台上没有完全对应的状态。
        // 在 Android 上，当应用程序进入后台时，通常会接收到 AppLifecycleState.paused 状态。
        legacyDebugPrint('Handle this case');
    }
    super.didChangeAppLifecycleState(state);
  }

  @override
  Widget build(BuildContext context) {
    return LegacyAppBoundary(
      app: GetMaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(primarySwatch: Colors.blue),
        home: const PageAView(),
      ),
    );
  }
}

Widget buildLegacyDemo(BuildContext context) =>
    LegacyLaunchPage(action: legacyOriginalMain, title: 'GetXLifeCycleDemo');
