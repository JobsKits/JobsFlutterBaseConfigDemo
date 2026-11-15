import 'package:jobs_flutter_base_config/demo_hub/legacy_launch.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jobs_runners/jobs_runners.dart'; // 公共测试器路径

void legacyOriginalMain() => legacyCaptureApp(
  JobsMaterialRunner(
    JobsButton(
      onPressed: () {
        legacyDebugPrint('s');
      },
      isButtonEnabled: true.obs,
    ),
    title: 'JobsButton',
  ),
);

class JobsButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final RxBool isButtonEnabled;
  const JobsButton({
    super.key,
    required this.onPressed,
    required this.isButtonEnabled,
  });
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return ElevatedButton(
        onPressed: isButtonEnabled.value ? onPressed : null,
        child: const LegacyText('Submit'),
      );
    });
  }
}

/// 独立运行与目录预览共用同一份原始教学逻辑。
void main() => launchLegacyStandalone(legacyOriginalMain, title: '旧例·按钮封装教学');
