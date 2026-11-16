// 独立运行：flutter run -t "lib/demos/Provider通知与计数/ProviderDemo1.dart"
// 使用本工程 pubspec.yaml 声明的依赖与资源。

import 'package:jobs_flutter_base_config/demo_hub/legacy_launch.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:jobs_demo_foundation/jobs_demo_foundation.dart';

/// 独立运行与目录预览共用同一份原始教学逻辑。
void main() =>
    launchLegacyStandalone(legacyOriginalMain, title: 'Provider通知与计数');

// 创建一个 CounterModel 类，表示计数器的状态
class CounterModel extends ChangeNotifier {
  int _count = 0;
  int get count => _count;
  // 增加计数器的方法
  void increment() {
    _count++;
    notifyListeners(); // 通知监听器状态已更改
  }
}

void legacyOriginalMain() {
  legacyCaptureApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    // 使用 ChangeNotifierProvider 将 CounterModel 注入到整个应用程序中
    return ChangeNotifierProvider(
      create: (context) => CounterModel(),
      child: LegacyAppBoundary(
        app: const MaterialApp(title: 'Provider Demo', home: MyHomePage()),
      ),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: JobsDemoAppBar(title: const LegacyText('Provider Demo')),
      body: Center(
        // 使用 Consumer 来获取 CounterModel，并在构建 UI 时订阅它的状态
        child: Consumer<CounterModel>(
          builder: (context, counter, child) => LegacyText(
            'Count: ${counter.count}',
            style: const TextStyle(fontSize: 24),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // 通过 Provider.of<CounterModel>(context, listen: false) 获取 CounterModel 实例
          Provider.of<CounterModel>(context, listen: false).increment();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

Widget buildLegacyDemo(BuildContext context) =>
    LegacyLaunchPage(action: legacyOriginalMain, title: 'ProviderDemo1');
