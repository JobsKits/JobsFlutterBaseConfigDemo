import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jobs_runners/jobs_runners.dart'; // 公共测试器路径

/// 页面IU和页面数据是一一对应的，一般情况下是不推荐页面没有进去，而页面对应的数据（Controller）先进栈。
/// 如果在某些情况下，页面对应的数据（Controller）先进栈，那么需要在适当的时候进行移除，也就是涉及到Get.delete
/// 否则当页面需要正常进入的时候，页面对应的数据（Controller）是不会正常走oninit()和onready()方法的
void main() {
  runApp(JobsMaterialRunner.builder(
    title: 'Flutter Bloc Demo',
    builder: (ctx) {
      return HomePage();
    },
  ));
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});
  @override
  Widget build(BuildContext context) {
    final CounterController counterController = Get.put(CounterController());
    return Scaffold(
      appBar: AppBar(
        title: const Text('Get.delete Demo'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Obx(() => Text(
                  'Count: ${counterController.count}',
                  style: const TextStyle(fontSize: 24),
                )),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: counterController.increment,
              child: const Text('Increment'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // 删除控制器
                Get.delete<CounterController>();
                // 检查控制器是否已被删除
                if (!Get.isRegistered<CounterController>()) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('CounterController has been deleted'),
                    ),
                  );
                }
              },
              child: const Text('Delete CounterController'),
            ),
          ],
        ),
      ),
    );
  }
}

class CounterController extends GetxController {
  var count = 0.obs;
  void increment() {
    count++;
  }
}
