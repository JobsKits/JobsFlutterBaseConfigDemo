// 独立运行：flutter run -t "lib/demos/滑动手势/SwipeDemo.dart"
// 使用本工程 pubspec.yaml 声明的依赖与资源。

import 'package:jobs_flutter_base_config/demo_hub/legacy_launch.dart';
import 'package:flutter/material.dart';
import 'package:jobs_runners/jobs_runners.dart';
import 'package:jobs_demo_foundation/jobs_demo_foundation.dart';

/// 独立运行与目录预览共用同一份原始教学逻辑。
void main() => launchLegacyStandalone(legacyOriginalMain, title: '滑动手势');

// 公共测试器路径

void legacyOriginalMain() => legacyCaptureApp(
  const JobsMaterialRunner(SwipeDemo(), title: 'Swipe Gesture Demo'),
);

class SwipeDemo extends StatelessWidget {
  const SwipeDemo({super.key});
  @override
  Widget build(BuildContext context) {
    return const Center(child: SwipeWidget());
  }
}

class SwipeWidget extends StatefulWidget {
  const SwipeWidget({super.key});

  @override
  State<SwipeWidget> createState() => _SwipeWidgetState();
}

class _SwipeWidgetState extends State<SwipeWidget> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanEnd: (details) {
        if (details.velocity.pixelsPerSecond.dx > 0) {
          legacyDebugPrint('Swipe right');
        } else if (details.velocity.pixelsPerSecond.dx < 0) {
          legacyDebugPrint('Swipe left');
        }
      },
      child: Container(
        color: Colors.yellow,
        width: 100,
        height: 100,
        child: const Center(
          child: LegacyText('Swipe Me', style: TextStyle(color: Colors.black)),
        ),
      ),
    );
  }
}

Widget buildLegacyDemo(BuildContext context) => JobsDemoActionHost(
  child: Scaffold(
    appBar: JobsDemoAppBar(actionHost: true, title: const LegacyText('滑动手势')),
    body: SafeArea(child: const SwipeDemo()),
  ),
);
