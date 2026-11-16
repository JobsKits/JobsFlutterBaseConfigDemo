// 独立运行：flutter run -t "lib/demos/GetX控制器查找/GetX_FindDemo.dart"
// 使用本工程 pubspec.yaml 声明的依赖与资源。

import 'package:jobs_flutter_base_config/demo_hub/legacy_launch.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jobs_runners/jobs_runners.dart';

/// 独立运行与目录预览共用同一份原始教学逻辑。
void main() => launchLegacyStandalone(legacyOriginalMain, title: 'GetX控制器查找');

// 公共测试器路径

// 这个类给我们演示了：如何使用 GetX 来管理状态
void legacyOriginalMain() {
  // 初始化 GetX
  WidgetsFlutterBinding.ensureInitialized();
  Get.put(Legacy47CounterController()); // 初始化 Legacy47CounterController
  legacyCaptureApp(
    JobsMaterialRunner.builder(
      title: 'GetX Demo',
      builder: (ctx) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 使用 GetBuilder 来监听控制器中 count 变量的变化，并自动刷新 UI
              GetBuilder<Legacy47CounterController>(
                builder: (controller) => LegacyText(
                  'Count: ${controller.count}',
                  style: const TextStyle(fontSize: 24),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (Get.isRegistered<Legacy47CounterController>()) {
                    // Get.find 是 Flutter GetX 状态管理库中的一个方法，用于查找和获取已经注册的控制器或服务。
                    // 通过 Get.find 获取 Legacy47CounterController 实例，并调用其中的方法
                    Get.find<Legacy47CounterController>().increment();
                  }
                },
                child: const LegacyText('Increment'),
              ),
            ],
          ),
        );
      },
    ),
  );
}

// 创建一个控制器类
class Legacy47CounterController extends GetxController {
  var count = 0.obs; // 使用 .obs 将 count 变量转换为响应式变量
  void increment() {
    count.value++;
    update(); // 手动触发 UI 刷新
  }
}

typedef CounterController = Legacy47CounterController;

Widget buildLegacyDemo(BuildContext context) => LegacyLaunchPage(
  action: legacyOriginalMain,
  title: 'GetX_FindDemo',
  onDispose: () {
    if (Get.isRegistered<CounterController>()) Get.delete<CounterController>();
  },
);
