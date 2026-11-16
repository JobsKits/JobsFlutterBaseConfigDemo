// 独立运行：flutter run -t "lib/demos/隔离区双向消息/IsolateDemo1.dart"
// 使用本工程 pubspec.yaml 声明的依赖与资源。

import 'package:jobs_flutter_base_config/demo_hub/legacy_launch.dart';

import 'dart:isolate';

import 'package:flutter/material.dart';

/// 独立运行与目录预览共用同一份原始教学逻辑。
void main() => launchLegacyStandalone(legacyOriginalMain, title: '隔离区双向消息');

// 简单使用 Isolate.spawn
// Isolate 中的函数必须是顶级函数或静态方法（不能是闭包）。
// 主 isolate 发送消息给子 isolate 时，需要通过 SendPort 发送。
// 子 isolate 接收消息时，需要通过 ReceivePort 接收。
void legacyOriginalMain() async {
  final receivePort = ReceivePort();
  legacyOnDispose(receivePort.close); // 接收端口
  final isolate = await Isolate.spawn(computeHeavyTask, receivePort.sendPort);
  legacyOnDispose(() => isolate.kill(priority: Isolate.immediate));

  receivePort.listen((message) {
    legacyDebugPrint("👨‍💻 主线程收到计算结果：$message");
    receivePort.close();
  });
}

// 执行函数
void computeHeavyTask(SendPort sendPort) {
  int result = 0;
  for (int i = 0; i < 100000000; i++) {
    result += i;
  }
  sendPort.send(result); // 把结果发回主 isolate
}

Widget buildLegacyDemo(BuildContext context) =>
    LegacyLaunchPage(action: legacyOriginalMain, title: 'IsolateDemo1');
