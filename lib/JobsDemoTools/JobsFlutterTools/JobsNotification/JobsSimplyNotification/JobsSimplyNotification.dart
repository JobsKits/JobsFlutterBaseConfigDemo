import 'package:flutter/material.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:jobs_flutter_base_config/JobsDemoTools/JobsFlutterTools/JobsNotification/JobsSimplyNotification/JobsSimplyNotificationDemo/JobsSimplyNotificationDemoPageA.dart';
import 'package:jobs_runners/jobs_runners.dart';

void main() => runApp(JobsGetRunner(JobsSimplyNotificationDemoPageA(),
    title: 'Page A - GetX全局通知'));

class JobsSimplyNotification {
  static final RxMap<String, dynamic> _events = <String, dynamic>{}.obs;

  static void post(String name, dynamic data) {
    _events[name] = data;
  }

  static Obx listen(String name, Widget Function(dynamic data) builder) {
    return Obx(() => builder(_events[name]));
  }
}
