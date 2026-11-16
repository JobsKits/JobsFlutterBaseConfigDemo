// 独立运行：flutter run -t "lib/demos/输入框封装教学/JobsTextField.dart"
// 使用本工程 pubspec.yaml 声明的依赖与资源。

import 'package:jobs_flutter_base_config/demo_hub/legacy_launch.dart';
import 'package:flutter/material.dart';
import 'package:jobs_runners/jobs_runners.dart';

/// 独立运行与目录预览共用同一份原始教学逻辑。
void main() => launchLegacyStandalone(legacyOriginalMain, title: '输入框封装教学');

// 公共测试器路径

void legacyOriginalMain() => legacyCaptureApp(
  JobsMaterialRunner(
    JobsTextField(
      controller: TextEditingController(),
      hintText: 'Enter first value',
    ),
    title: 'XXX',
  ),
);

class JobsTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;

  const JobsTextField({
    super.key,
    required this.controller,
    required this.hintText,
  });
  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      decoration: legacyInputDecoration(
        context,
        InputDecoration(hintText: hintText, border: const OutlineInputBorder()),
      ),
    );
  }
}

Widget buildLegacyDemo(BuildContext context) =>
    LegacyLaunchPage(action: legacyOriginalMain, title: 'JobsTextField');
