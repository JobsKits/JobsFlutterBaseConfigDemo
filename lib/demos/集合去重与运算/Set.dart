// 独立运行：flutter run -t "lib/demos/集合去重与运算/Set.dart"
// 使用本工程 pubspec.yaml 声明的依赖与资源。

import 'package:jobs_flutter_base_config/demo_hub/legacy_launch.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jobs_runners/jobs_runners.dart';

/// 独立运行与目录预览共用同一份原始教学逻辑。
void main() => launchLegacyStandalone(legacyOriginalMain, title: '集合去重与运算');

// 公共测试器路径

void legacyOriginalMain() {
  final controller = Get.put(Legacy37RotaryController()); // 注册控制器
  legacyCaptureApp(
    JobsMaterialRunner.builder(
      title: 'CustomRxString Demo',
      builder: (ctx) {
        return Center(
          child: Obx(
            () => LegacyText('Currency ID: ${controller.currencyId.value}'),
          ),
        );
      },
    ),
  );
}

class Legacy37RotaryController extends GetxController {
  final currencyId = CustomRxString('701'); // 自定义的 RxString
  void someMethod() {
    currencyId.value = '702'; // 触发 setter 打印堆栈
  }

  @override
  void onInit() {
    super.onInit();
    someMethod();
  }
}

class CustomRxString extends RxString {
  CustomRxString(super.initial);
  @override
  set value(dynamic val) {
    super.value = val;
    legacyDebugPrint('currencyId setter called');
    legacyDebugPrint(StackTrace.current.toString()); // 打印当前这行代码是如何被调用的路径（堆栈）
  }
}

typedef RotaryController = Legacy37RotaryController;

Widget buildLegacyDemo(BuildContext context) => LegacyLaunchPage(
  action: legacyOriginalMain,
  title: 'Set',
  onDispose: () {
    if (Get.isRegistered<RotaryController>()) Get.delete<RotaryController>();
  },
);
