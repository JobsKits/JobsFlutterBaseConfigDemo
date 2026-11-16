// 独立运行：flutter run -t "lib/demos/弹性换行与填充对照/Flexible + Expanded.dart"
// 使用本工程 pubspec.yaml 声明的依赖与资源。

import 'package:jobs_flutter_base_config/demo_hub/legacy_launch.dart';
import 'package:flutter/material.dart';
import 'package:jobs_runners/jobs_runners.dart';

/// 独立运行与目录预览共用同一份原始教学逻辑。
void main() => launchLegacyStandalone(legacyOriginalMain, title: '弹性换行与填充对照');

// 公共测试器路径

// Expanded 不能直接嵌套在 Flexible 中使用
// Expanded 本身是一个 Flexible
// 所以直接使用 Flexible 和 Expanded 的组合是多余的
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

Widget buildLegacyDemo(BuildContext context) =>
    LegacyLaunchPage(action: legacyOriginalMain, title: 'Flexible+Expanded');
