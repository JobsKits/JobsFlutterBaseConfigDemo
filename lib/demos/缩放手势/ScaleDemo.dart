// 独立运行：flutter run -t "lib/demos/缩放手势/ScaleDemo.dart"
// 使用本工程 pubspec.yaml 声明的依赖与资源。

import 'package:jobs_flutter_base_config/demo_hub/legacy_launch.dart';
import 'package:flutter/material.dart';
import 'package:jobs_runners/jobs_runners.dart';
import 'package:jobs_demo_foundation/jobs_demo_foundation.dart';

/// 独立运行与目录预览共用同一份原始教学逻辑。
void main() => launchLegacyStandalone(legacyOriginalMain, title: '缩放手势');

// 公共测试器路径

void legacyOriginalMain() => legacyCaptureApp(
  const JobsMaterialRunner(ScaleDemo(), title: 'Scale Gesture Demo'),
);

class ScaleDemo extends StatelessWidget {
  const ScaleDemo({super.key});
  @override
  Widget build(BuildContext context) {
    return const Center(child: ScaleWidget());
  }
}

class ScaleWidget extends StatefulWidget {
  const ScaleWidget({super.key});
  @override
  State<ScaleWidget> createState() => _ScaleWidgetState();
}

class _ScaleWidgetState extends State<ScaleWidget> {
  double _scale = 1.0;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onScaleStart: (details) {
        legacyDebugPrint('Scale start');
      },
      onScaleUpdate: (details) {
        setState(() {
          _scale = details.scale;
        });
        legacyDebugPrint('Scale update: ${details.scale}');
      },
      onScaleEnd: (details) {
        legacyDebugPrint('Scale end');
      },
      child: Transform.scale(
        scale: _scale,
        child: Container(
          color: Colors.red,
          width: 100,
          height: 100,
          child: const Center(
            child: LegacyText(
              'Scale Me',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }
}

Widget buildLegacyDemo(BuildContext context) => JobsDemoActionHost(
  child: Scaffold(
    appBar: JobsDemoAppBar(actionHost: true, title: const LegacyText('缩放手势')),
    body: SafeArea(child: const ScaleDemo()),
  ),
);
