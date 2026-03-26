import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jobs_runners/jobs_runners.dart'; // 公共测试器路径
import 'home_controller.dart';

void main() => runApp(const JobsMaterialRunner(HomeView(), title: 'Home'));

// 使用Obx来监听count的变化，并在按钮按下时调用 controller.increment() 方法
class HomeView extends StatelessWidget {
  const HomeView({super.key});
  @override
  Widget build(BuildContext context) {
    late final HomeController controller;
    if (Get.isRegistered<HomeController>()) {
      controller = Get.find<HomeController>();
    }
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Obx(() => Text(
              'Button pressed ${controller.count} times',
              style: Theme.of(context).textTheme.headlineMedium,
            )),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: controller.increment,
          child: const Text('Increment'),
        ),
      ],
    );
  }
}
