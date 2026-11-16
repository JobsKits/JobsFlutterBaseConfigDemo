// 独立运行：flutter run -t "lib/demos/页面生命周期基类/JobsPageDemo.dart"
// 使用本工程 pubspec.yaml 声明的依赖与资源。

import 'package:jobs_flutter_base_config/demo_hub/legacy_launch.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jobs_runners/jobs_runners.dart'; // 公共测试器路径
import 'package:jobs_flutter_base_config/JobsDemoTools/JobsFlutterTools/页面的生命周期监听（基类）/BaseLifecycleStateful.dart';
import 'package:jobs_demo_foundation/jobs_demo_foundation.dart';

/// 独立运行与目录预览共用同一份原始教学逻辑。
void main() => launchLegacyStandalone(legacyOriginalMain, title: '页面生命周期基类');

void legacyOriginalMain() => legacyCaptureApp(
  const JobsMaterialRunner(JobsPageDemo(), title: '生命周期的监听Demo'),
);

class JobsPageDemo extends BaseLifecycleStatefulWidget {
  const JobsPageDemo({super.key});

  @override
  State<JobsPageDemo> createState() => _JobsPageDemoState();
}

class _JobsPageDemoState
    extends BaseLifecycleStatefulWidgetState<JobsPageDemo> {
  String status = "等待状态变化".tr;

  @override
  void onAppResumed() {
    setState(() {
      status = "📲 回到前台".tr;
    });
    legacyDebugPrint("✅ App 已回到前台".tr);
  }

  @override
  void onAppPaused() {
    setState(() {
      status = "⏸️ 进入后台".tr;
    });
    legacyDebugPrint("⛔ App 进入后台".tr);
  }

  @override
  Widget build(BuildContext context) {
    return Center(child: LegacyText(status));
  }
}

Widget buildLegacyDemo(BuildContext context) => JobsDemoActionHost(
  child: Scaffold(
    appBar: JobsDemoAppBar(
      actionHost: true,
      title: const LegacyText('页面生命周期基类'),
    ),
    body: SafeArea(child: const JobsPageDemo()),
  ),
);
