import 'package:flutter/material.dart';
import 'package:flutter_plugin_engagelab/flutter_plugin_engagelab.dart';
import 'package:jobs_runners/jobs_runners.dart'; // 公共测试器路径

// App 生命周期监听主要通过实现 WidgetsBindingObserver 接口来完成。这个接口提供了一系列回调，可以监听：
// 1️⃣ App 前后台切换（如 iOS 的 applicationDidEnterBackground / applicationDidBecomeActive）
// 2️⃣ 屏幕尺寸
// 3️⃣ 语言切换
// 4️⃣ 内存压力警告等

// 以下是一个示例代码，展示如何在Flutter中实现视图即将显示和视图已经显示的功能：

void main() =>
    runApp(JobsMaterialRunner(MyHomePage(), title: 'Lifecycle Demo'));

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with WidgetsBindingObserver {
  @override
  Widget build(BuildContext context) {
    FlutterPluginEngagelab.printMy("View will appear");
    ; // Called each time the widget is built
    return const Center(
      child: Text('Hello, World!'),
    );
  }

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
        FlutterPluginEngagelab.printMy('应用程序处于非活动状态');
        break;
      case AppLifecycleState.paused:
        // 应用程序处于后台
        FlutterPluginEngagelab.printMy('应用程序处于后台');
        break;
      case AppLifecycleState.resumed:
        // 应用程序处于前台并可交互
        FlutterPluginEngagelab.printMy('应用程序处于前台并可交互');
        break;
      case AppLifecycleState.detached:
        // 应用程序没有关联的 Flutter 引擎
        FlutterPluginEngagelab.printMy('应用程序没有关联的 Flutter 引擎（很少用）');
        break;
      case AppLifecycleState.hidden:
        // AppLifecycleState.hidden 是 Flutter 中的一个枚举值，它表示应用程序的状态在 iOS 平台上被隐藏时的状态。
        // 具体来说，AppLifecycleState.hidden 是在 iOS 上当用户按下主屏幕按钮或切换到另一个应用程序时，Flutter 应用程序进入后台并且不再可见的状态。
        // 在 Android 平台上没有完全对应的状态。
        // 在 Android 上，当应用程序进入后台时，通常会接收到 AppLifecycleState.paused 状态。
        FlutterPluginEngagelab.printMy('Handle this case');
    }
    super.didChangeAppLifecycleState(state);
  }
}
