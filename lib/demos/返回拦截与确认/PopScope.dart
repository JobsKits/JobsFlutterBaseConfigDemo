// 独立运行：flutter run -t "lib/demos/返回拦截与确认/PopScope.dart"
// 使用本工程 pubspec.yaml 声明的依赖与资源。

import 'package:jobs_flutter_base_config/demo_hub/legacy_launch.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jobs_runners/jobs_runners.dart';
import 'package:jobs_flutter_base_config/JobsDemoTools/JobsFlutterTools/PopScope监听和自定义返回按钮行为/PopConfirmWrapper.dart';
import 'package:jobs_flutter_base_config/core/app_config.dart';
import 'package:jobs_flutter_base_config/pages/Others/Pages.dart';
import 'package:jobs_demo_foundation/jobs_demo_foundation.dart';

/// 独立运行与目录预览共用同一份原始教学逻辑。
void main() => launchLegacyStandalone(legacyOriginalMain, title: '返回拦截与确认');

// 点击按钮以后：跳转到 PageC
// 在PageC点击导航栏返回键，会出现一个弹窗，点击确定才可以真正的返回
void legacyOriginalMain() =>
    legacyCaptureApp(JobsGetRunner(const MyPage(), title: '自定义 PopScope 示例'));

class MyPage extends StatelessWidget {
  const MyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return PopConfirmWrapper(
      child: Center(
        child: ElevatedButton(
          onPressed: () => Get.to(() => const PageC()),
          child: LegacyText('跳转到 PageC', style: normalTextStyle()),
        ),
      ),
    );
  }
}

Widget buildLegacyDemo(BuildContext context) => JobsDemoActionHost(
  child: Scaffold(
    appBar: JobsDemoAppBar(
      actionHost: true,
      title: const LegacyText('返回拦截与确认'),
    ),
    body: SafeArea(child: const MyPage()),
  ),
);
