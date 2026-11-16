// 独立运行：flutter run -t "lib/demos/GetX视图控制器教学/GetViewDemo.dart"
// 使用本工程 pubspec.yaml 声明的依赖与资源。

import 'package:jobs_flutter_base_config/demo_hub/legacy_launch.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jobs_runners/jobs_runners.dart';
import 'package:jobs_demo_foundation/jobs_demo_foundation.dart';

/// 独立运行与目录预览共用同一份原始教学逻辑。
void main() => launchLegacyStandalone(legacyOriginalMain, title: 'GetX视图控制器教学');

// 公共测试器路径

/// GetView 是 GetX 框架提供的一个工具，用于方便地创建视图。
/// 因为它继承自 StatelessWidget，所以它是无状态的。无状态小部件没有内部状态，不会在构建后发生变化。
///
/// 在这个示例中，MyView 是一个 `GetView<Legacy157MyController>`，它是无状态的（因为继承自 StatelessWidget）。
/// 控制器的状态由 GetxController 管理，并通过 Obx 来更新 UI。

/// 程序入口，注册控制器
void legacyOriginalMain() {
  Get.put(Legacy157MyController()); // 注册控制器（必须）
  legacyCaptureApp(const JobsMaterialRunner(MyView(), title: 'GetView 示例'));
}

class Legacy157MyController extends GetxController {
  var count = 0.obs;
  void increment() {
    count++;
  }
}

class MyView extends GetView<Legacy157MyController> {
  const MyView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: JobsDemoAppBar(title: const LegacyText('GetView Example')),
      body: Center(child: Obx(() => LegacyText('Count: ${controller.count}'))),
      floatingActionButton: FloatingActionButton(
        onPressed: controller.increment,
        child: const Icon(Icons.add),
      ),
    );
  }
}

typedef MyController = Legacy157MyController;

Widget buildLegacyDemo(BuildContext context) => LegacyLaunchPage(
  action: legacyOriginalMain,
  title: 'GetViewDemo',
  onDispose: () {
    if (Get.isRegistered<MyController>()) Get.delete<MyController>();
  },
);
