// 独立运行：flutter run -t "lib/demos/弹性文本换行/Flexible.dart"
// 使用本工程 pubspec.yaml 声明的依赖与资源。

import 'package:jobs_flutter_base_config/demo_hub/legacy_launch.dart';
import 'package:flutter/material.dart';
import 'package:jobs_runners/jobs_runners.dart';
import 'package:jobs_demo_foundation/jobs_demo_foundation.dart';

/// 独立运行与目录预览共用同一份原始教学逻辑。
void main() => launchLegacyStandalone(legacyOriginalMain, title: '弹性文本换行');

// 公共测试器路径

// Flexible 示例: 使用 Flexible 来让 Text 小部件在 Row 中自动换行。
void legacyOriginalMain() => legacyCaptureApp(
  const JobsMaterialRunner(FlexibleDemo(), title: 'Flexible Demo'),
);

class FlexibleDemo extends StatelessWidget {
  const FlexibleDemo({super.key});
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.blueAccent),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Icon(Icons.info, size: 24, color: Colors.blueAccent),
          SizedBox(width: 8),
          Flexible(
            child: LegacyText(
              '这是一个长文本，如果超过屏幕宽度，它应该换行显示。文本应该正确换行并完全可见。',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

Widget buildLegacyDemo(BuildContext context) => JobsDemoActionHost(
  child: Scaffold(
    appBar: JobsDemoAppBar(actionHost: true, title: const LegacyText('弹性文本换行')),
    body: SafeArea(child: const Center(child: FlexibleDemo())),
  ),
);
