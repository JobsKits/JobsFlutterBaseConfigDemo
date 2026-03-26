import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jobs_runners/jobs_runners.dart'; // 公共测试器路径

// https://github.com/jonataslaw/getx
// 这个类给我们演示了如何使用 GetX 来管理状态，并自动更新 UI。
void main() {
  final CounterController counterController = Get.put(CounterController());
  runApp(JobsMaterialRunner.builder(
    title: 'GetX Demo',
    builder: (ctx) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('GetX Demo'),
        ),
        body: Center(
          // 使用 Obx 来获取状态并自动更新 UI
          child: Obx(() => Text(
                'Count: ${counterController.count.value}',
                style: const TextStyle(fontSize: 24),
              )),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            // 调用控制器的增加计数器方法
            counterController.increment();
          },
          child: const Icon(Icons.add),
        ),
      );
    },
  ));
}

class CounterController extends GetxController {
  var count = 0.obs; // 使用 RxInt 包装计数器变量
  void increment() {
    count++; // 自动触发 UI 更新
  }
}
