// 独立运行：flutter run -t "lib/demos/填充与换行组合/Expanded + Wrap.dart"
// 使用本工程 pubspec.yaml 声明的依赖与资源。

import 'package:jobs_flutter_base_config/demo_hub/legacy_launch.dart';
import 'package:flutter/material.dart';
import 'package:jobs_runners/jobs_runners.dart';
import 'package:jobs_demo_foundation/jobs_demo_foundation.dart';

/// 独立运行与目录预览共用同一份原始教学逻辑。
void main() => launchLegacyStandalone(legacyOriginalMain, title: '填充与换行组合');

// 公共测试器路径

// Row: 主容器，包含一个 Icon 和一个 Expanded 小部件。
// Expanded: 允许子小部件（Wrap）在 Row 中扩展和收缩，从而实现文本换行。
// Wrap: 确保文本在超过可用宽度时换行。
// Text: 文本小部件，在必要时换行。
// 这种设置确保了当文本超过屏幕宽度时，文本会自动换行，同时仍然是 Row 布局的一部分。
void legacyOriginalMain() => legacyCaptureApp(
  const JobsMaterialRunner(ExpandedWrapDemo(), title: 'Expanded + Wrap Demo'),
);

class ExpandedWrapDemo extends StatelessWidget {
  const ExpandedWrapDemo({super.key});
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
          Expanded(
            child: Wrap(
              children: [
                LegacyText(
                  '这是一个长文本，如果超过屏幕宽度，它应该换行显示。文本应该正确换行并完全可见。',
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

Widget buildLegacyDemo(BuildContext context) => JobsDemoActionHost(
  child: Scaffold(
    appBar: JobsDemoAppBar(
      actionHost: true,
      title: const LegacyText('填充与换行组合'),
    ),
    body: SafeArea(child: const Center(child: ExpandedWrapDemo())),
  ),
);
