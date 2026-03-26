// main.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jobs_flutter_base_config/JobsDemoTools/JobsFlutterTools/调试/JobsCommonUtil.dart';
import 'package:jobs_runners/jobs_runners.dart';

// ✅ 操作说明：
// 点击“➕ 增加计数”按钮：
// ever 每次触发；
// once 只触发第一次；
// interval 每隔 1 秒只触发一次；
// everAll 也会触发。

// 输入框中输入内容（如：abc）：
// 每次变动不会立即触发 debounce；
// 停止输入约 800ms 后才触发；
// everAll 也会触发。

void main() => runApp(JobsGetRunner(RxListenerDemo(), title: '🎯 GetX 监听器演示'));

class RxListenerDemo extends StatelessWidget {
  final MyController controller = Get.put(MyController());

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Obx(() => Text('🧮 当前计数：${controller.counter}',
              style: TextStyle(fontSize: 24))),
          ElevatedButton(
            onPressed: () => controller.counter.value++,
            child: const Text('➕ 增加计数'),
          ),
          const SizedBox(height: 20),
          TextField(
            decoration: const InputDecoration(labelText: '🔤 输入关键词'),
            onChanged: (val) => controller.keyword.value = val,
          ),
        ],
      ),
    );
  }
}

class MyController extends GetxController {
  // 声明两个响应式变量
  final RxInt counter = 0.obs;
  final RxString keyword = ''.obs;

  // 初始化监听器
  @override
  void onInit() {
    super.onInit();

    // 每次改变都触发
    ever(counter, (val) => JobsPrint("🔁 ever: counter = $val"));

    // 只触发第一次
    once(counter, (val) => JobsPrint("🎯 once: counter = $val"));

    // 防抖：停止改变后 800ms 再触发
    debounce(keyword, (val) => JobsPrint("⏳ debounce: keyword = $val"),
        time: Duration(milliseconds: 800));

    // 节流：每隔 1s 触发一次
    interval(counter, (val) => JobsPrint("🚦 interval: counter = $val"),
        time: Duration(seconds: 1));

    // 同时监听多个 Rx
    everAll([counter, keyword], (valList) {
      JobsPrint(
          "📦 everAll: counter = ${counter.value}, keyword = ${keyword.value}");
    });
  }
}
