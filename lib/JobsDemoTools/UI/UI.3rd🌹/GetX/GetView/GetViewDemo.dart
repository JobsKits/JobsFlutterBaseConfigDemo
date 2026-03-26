import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jobs_runners/jobs_runners.dart'; // 公共测试器路径

/// GetView 是 GetX 框架提供的一个工具，用于方便地创建视图。
/// 因为它继承自 StatelessWidget，所以它是无状态的。无状态小部件没有内部状态，不会在构建后发生变化。
///
/// 在这个示例中，MyView 是一个 GetView<MyController>，它是无状态的（因为继承自 StatelessWidget）。
/// 控制器的状态由 GetxController 管理，并通过 Obx 来更新 UI。

/// 程序入口，注册控制器
void main() {
  Get.put(MyController()); // 注册控制器（必须）
  runApp(const JobsMaterialRunner(MyView(), title: 'GetView 示例'));
}

class MyController extends GetxController {
  var count = 0.obs;
  void increment() {
    count++;
  }
}

class MyView extends GetView<MyController> {
  const MyView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('GetView Example'),
      ),
      body: Center(
        child: Obx(
          () => Text('Count: ${controller.count}'),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: controller.increment,
        child: const Icon(Icons.add),
      ),
    );
  }
}
