// 独立运行：flutter run -t "lib/demos/简易通知封装/JobsSimplyNotification.dart"
// 使用本工程 pubspec.yaml 声明的依赖与资源。

import 'package:jobs_flutter_base_config/demo_hub/legacy_launch.dart';
import 'package:flutter/material.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:jobs_flutter_base_config/JobsDemoTools/JobsFlutterTools/JobsNotification/JobsSimplyNotification/JobsSimplyNotificationDemo/JobsSimplyNotificationDemoPageA.dart';
import 'package:jobs_runners/jobs_runners.dart';

/// 独立运行与目录预览共用同一份原始教学逻辑。
void main() => launchLegacyStandalone(legacyOriginalMain, title: '简易通知封装');

void legacyOriginalMain() => legacyCaptureApp(
  JobsGetRunner(JobsSimplyNotificationDemoPageA(), title: 'Page A - GetX全局通知'),
);

class JobsSimplyNotification {
  static final RxMap<String, dynamic> _events = <String, dynamic>{}.obs;

  static void post(String name, dynamic data) {
    _events[name] = data;
  }

  static Obx listen(String name, Widget Function(dynamic data) builder) {
    return Obx(() => builder(_events[name]));
  }
}

Widget buildLegacyDemo(BuildContext context) => LegacyLaunchPage(
  action: legacyOriginalMain,
  title: 'JobsSimplyNotification',
);
