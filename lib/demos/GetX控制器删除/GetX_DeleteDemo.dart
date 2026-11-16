// 独立运行：flutter run -t "lib/demos/GetX控制器删除/GetX_DeleteDemo.dart"
// 使用本工程 pubspec.yaml 声明的依赖与资源。

import 'package:jobs_flutter_base_config/demo_hub/legacy_launch.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jobs_runners/jobs_runners.dart';
import 'package:jobs_demo_foundation/jobs_demo_foundation.dart';

/// 独立运行与目录预览共用同一份原始教学逻辑。
void main() => launchLegacyStandalone(legacyOriginalMain, title: 'GetX控制器删除');

// 公共测试器路径

/// 页面IU和页面数据是一一对应的，一般情况下是不推荐页面没有进去，而页面对应的数据（Controller）先进栈。
/// 如果在某些情况下，页面对应的数据（Controller）先进栈，那么需要在适当的时候进行移除，也就是涉及到Get.delete
/// 否则当页面需要正常进入的时候，页面对应的数据（Controller）是不会正常走oninit()和onready()方法的
void legacyOriginalMain() {
  legacyCaptureApp(
    JobsMaterialRunner.builder(
      title: 'Flutter Bloc Demo',
      builder: (ctx) {
        return HomePage();
      },
    ),
  );
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});
  @override
  Widget build(BuildContext context) {
    final Legacy45CounterController counterController = Get.put(
      Legacy45CounterController(),
    );
    return Scaffold(
      appBar: JobsDemoAppBar(title: const LegacyText('Get.delete Demo')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Obx(
              () => LegacyText(
                'Count: ${counterController.count}',
                style: const TextStyle(fontSize: 24),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: counterController.increment,
              child: const LegacyText('Increment'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // 删除控制器
                Get.delete<Legacy45CounterController>();
                // 检查控制器是否已被删除
                if (!Get.isRegistered<Legacy45CounterController>()) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: LegacyText(
                        'Legacy45CounterController has been deleted',
                      ),
                    ),
                  );
                }
              },
              child: const LegacyText('Delete Legacy45CounterController'),
            ),
          ],
        ),
      ),
    );
  }
}

class Legacy45CounterController extends GetxController {
  var count = 0.obs;
  void increment() {
    count++;
  }
}

typedef CounterController = Legacy45CounterController;

Widget buildLegacyDemo(BuildContext context) => LegacyLaunchPage(
  action: legacyOriginalMain,
  title: 'GetX_DeleteDemo',
  onDispose: () {
    if (Get.isRegistered<CounterController>()) Get.delete<CounterController>();
  },
);
