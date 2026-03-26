import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'CounterController.dart';
/// 页面
class CounterPage extends GetView<CounterController> {
  const CounterPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('GetView 示例')),
      body: Center(
        child: Obx(() => Text('当前计数：${controller.count.value}',
            style: const TextStyle(fontSize: 24))),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton(
        onPressed: controller.increment,
        child: const Icon(Icons.add),
      ),
    );
  }
}
