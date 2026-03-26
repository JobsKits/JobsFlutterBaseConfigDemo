import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:jobs_flutter_base_config/JobsDemoTools/JobsFlutterTools/JobsNotification/JobsNotification/JobsNotificationDemo/JobsNotificationDemoPageA.dart';
import 'package:jobs_runners/jobs_runners.dart';

void main() => runApp(
    JobsGetRunner(JobsNotificationDemoPageA(), title: 'Page A - GetX全局通知'));

class JobsNotification {
  static final RxMap<String, dynamic> _events = <String, dynamic>{}.obs;

  static final Map<String, Worker> _workers = {}; // 用于清理 ever 监听

  /// 发送通知
  static void post(String name, dynamic data) {
    _events[name] = data;
  }

  /// UI监听（返回 Obx Widget）
  static Obx listen(String name, Widget Function(dynamic data) builder) {
    return Obx(() => builder(_events[name]));
  }

  /// 非UI监听（逻辑响应），封装 ever
  static void listenRaw(String name, void Function(dynamic data) callback) {
    // 清理已有的 worker（避免重复绑定）
    _workers[name]?.dispose();

    // 注册监听
    _workers[name] = ever(_events, (_) {
      if (_events.containsKey(name)) {
        callback(_events[name]);
      }
    });
  }

  /// 移除某个监听
  static void remove(String name) {
    _workers[name]?.dispose();
    _workers.remove(name);
  }

  /// 移除所有监听
  static void clearAll() {
    _workers.forEach((_, worker) => worker.dispose());
    _workers.clear();
  }
}
