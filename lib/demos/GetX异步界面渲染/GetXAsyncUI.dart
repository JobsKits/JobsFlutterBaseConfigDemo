// 独立运行：flutter run -t "lib/demos/GetX异步界面渲染/GetXAsyncUI.dart"
// 使用本工程 pubspec.yaml 声明的依赖与资源。

import 'package:jobs_flutter_base_config/demo_hub/legacy_launch.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jobs_runners/jobs_runners.dart';

/// 独立运行与目录预览共用同一份原始教学逻辑。
void main() => launchLegacyStandalone(legacyOriginalMain, title: 'GetX异步界面渲染');

// 公共测试器路径

void legacyOriginalMain() =>
    legacyCaptureApp(const JobsMaterialRunner(A(), title: 'XXX'));

class A extends GetView<Legacy144ACtrl> {
  const A({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<Legacy144ACtrl>(
      init: Legacy144ACtrl(),
      id: "register",
      builder: (_) {
        controller.context = context;
        return Scaffold(
          backgroundColor: Colors.white,
          body: _buildView(context),
        );
      },
    );
  }

  Widget _buildView(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton(
            onPressed: () {
              controller.startTimer();
            },
            child: const LegacyText("Start Timer"),
          ),
          const SizedBox(height: 20),
          Obx(
            () => LegacyText(
              controller.isUpdated.value
                  ? "Content updated after 1 seconds"
                  : "Press the button to start timer",
              style: const TextStyle(fontSize: 24),
            ),
          ),
        ],
      ),
    );
  }
}

class Legacy144ACtrl extends GetxController {
  BuildContext? context;
  var isUpdated = false.obs;

  void startTimer() {
    Future.delayed(const Duration(seconds: 1), () {
      isUpdated.value = true;
      update(["register"]);
    });
  }
}

typedef ACtrl = Legacy144ACtrl;

Widget buildLegacyDemo(BuildContext context) => LegacyLaunchPage(
  action: legacyOriginalMain,
  title: 'GetXAsyncUI',
  onDispose: () {
    if (Get.isRegistered<ACtrl>()) Get.delete<ACtrl>();
  },
);
