import 'package:jobs_flutter_base_config/demo_hub/legacy_launch.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jobs_flutter_base_config/JobsDemoTools/Data/Data.3rd/GetXDemo/GetxController的生命周期/LifecycleController.dart';
import 'package:jobs_flutter_base_config/JobsDemoTools/Data/Data.3rd/GetXDemo/GetxController的生命周期/SecondPage.dart';
import 'package:jobs_runners/jobs_runners.dart';

void legacyOriginalMain() => legacyCaptureApp(
  JobsGetRunner(LifecycleDemoPage(), title: 'GetxController的生命周期演示'),
);

class LifecycleDemoPage extends StatelessWidget {
  const LifecycleDemoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<LifecycleController>(
      init: LifecycleController(),
      builder: (_) {
        return Center(
          child: ElevatedButton(
            onPressed: () {
              Get.to(() => SecondPage());
            },
            child: LegacyText('跳转到第二页'),
          ),
        );
      },
    );
  }
}

/// 独立运行与目录预览共用同一份原始教学逻辑。
void main() => launchLegacyStandalone(legacyOriginalMain, title: '控制器跨页生命周期');
