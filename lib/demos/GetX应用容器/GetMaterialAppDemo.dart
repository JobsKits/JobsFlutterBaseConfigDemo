// 独立运行：flutter run -t "lib/demos/GetX应用容器/GetMaterialAppDemo.dart"
// 使用本工程 pubspec.yaml 声明的依赖与资源。

import 'package:jobs_flutter_base_config/demo_hub/legacy_launch.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jobs_demo_foundation/jobs_demo_foundation.dart';

/// 独立运行与目录预览共用同一份原始教学逻辑。
void main() => launchLegacyStandalone(legacyOriginalMain, title: 'GetX应用容器');

void legacyOriginalMain() {
  legacyCaptureApp(const GetMaterialAppDemo());
}

class GetMaterialAppDemo extends StatelessWidget {
  const GetMaterialAppDemo({super.key});
  @override
  Widget build(BuildContext context) {
    return LegacyAppBoundary(
      app: GetMaterialApp(
        debugShowCheckedModeBanner: false,

        /// 是否显示右上角的红色 DEBUG 标识（横幅）
        home: GetCounterPage(),
      ),
    );
  }
}

class Legacy24CounterController extends GetxController {
  var count = 0.obs;
  void increment() => count++;
}

class GetCounterPage extends StatelessWidget {
  final controller = Get.put(Legacy24CounterController());

  GetCounterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: JobsDemoAppBar(title: const LegacyText('GetMaterialApp 示例')),
      body: Center(
        child: Obx(
          () => LegacyText(
            '点击次数: ${controller.count}\n'
            '🆚 GetMaterialApp 相比 MaterialApp：\n'
            '• 内建路由、状态管理、依赖注入\n'
            '• 使用 Obx 实现响应式，无需 setState\n'
            '• Get.put() 自动注入控制器，无需手动管理生命周期',
            style: const TextStyle(fontSize: 20),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: controller.increment,
        child: const Icon(Icons.add),
      ),
    );
  }
}

typedef CounterController = Legacy24CounterController;

Widget buildLegacyDemo(BuildContext context) => LegacyLaunchPage(
  action: legacyOriginalMain,
  title: 'GetMaterialAppDemo',
  onDispose: () {
    if (Get.isRegistered<CounterController>()) Get.delete<CounterController>();
  },
);
