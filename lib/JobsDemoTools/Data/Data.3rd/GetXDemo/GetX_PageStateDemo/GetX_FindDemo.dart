import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jobs_runners/jobs_runners.dart'; // 公共测试器路径

// 这个类给我们演示了：如何使用 GetX 来管理状态
void main() {
  // 初始化 GetX
  WidgetsFlutterBinding.ensureInitialized();
  Get.put(CounterController()); // 初始化 CounterController
  runApp(JobsMaterialRunner.builder(
    title: 'GetX Demo',
    builder: (ctx) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 使用 GetBuilder 来监听控制器中 count 变量的变化，并自动刷新 UI
            GetBuilder<CounterController>(
              builder: (controller) => Text(
                'Count: ${controller.count}',
                style: const TextStyle(fontSize: 24),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (Get.isRegistered<CounterController>()) {
                  // Get.find 是 Flutter GetX 状态管理库中的一个方法，用于查找和获取已经注册的控制器或服务。
                  // 通过 Get.find 获取 CounterController 实例，并调用其中的方法
                  Get.find<CounterController>().increment();
                }
              },
              child: const Text('Increment'),
            ),
          ],
        ),
      );
    },
  ));
}

// 创建一个控制器类
class CounterController extends GetxController {
  var count = 0.obs; // 使用 .obs 将 count 变量转换为响应式变量
  void increment() {
    count.value++;
    update(); // 手动触发 UI 刷新
  }
}
