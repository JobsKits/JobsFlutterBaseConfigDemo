import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jobs_runners/jobs_runners.dart'; // 公共测试器路径

void main() => runApp(const JobsMaterialRunner(A(), title: 'XXX'));

class A extends GetView<ACtrl> {
  const A({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ACtrl>(
      init: ACtrl(),
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
            child: const Text("Start Timer"),
          ),
          const SizedBox(height: 20),
          Obx(() => Text(
                controller.isUpdated.value
                    ? "Content updated after 1 seconds"
                    : "Press the button to start timer",
                style: const TextStyle(fontSize: 24),
              )),
        ],
      ),
    );
  }
}

class ACtrl extends GetxController {
  BuildContext? context;
  var isUpdated = false.obs;

  void startTimer() {
    Future.delayed(const Duration(seconds: 1), () {
      isUpdated.value = true;
      update(["register"]);
    });
  }
}
