// 独立运行：flutter run -t "lib/demos/单击双击与长按/TapDemo.dart"
// 使用本工程 pubspec.yaml 声明的依赖与资源。

import 'package:jobs_flutter_base_config/demo_hub/legacy_launch.dart';
import 'package:flutter/material.dart';
import 'package:jobs_runners/jobs_runners.dart';
import 'package:jobs_demo_foundation/jobs_demo_foundation.dart';

/// 独立运行与目录预览共用同一份原始教学逻辑。
void main() => launchLegacyStandalone(legacyOriginalMain, title: '单击双击与长按');

void legacyOriginalMain() => legacyCaptureApp(
  const JobsMaterialRunner(TapDemo(), title: 'Tap Gesture Demo'),
);

class TapDemo extends StatelessWidget {
  const TapDemo({super.key});
  @override
  Widget build(BuildContext context) {
    return Center(
      child: GestureDetector(
        onTap: () {
          legacyDebugPrint('Single tap');
        },
        onDoubleTap: () {
          legacyDebugPrint('Double tap');
        },
        onLongPress: () {
          legacyDebugPrint('Long press');
        },
        child: Container(
          color: Colors.blue,
          width: 100,
          height: 100,
          child: const Center(
            child: LegacyText('Tap Me', style: TextStyle(color: Colors.white)),
          ),
        ),
      ),
    );
  }
}

Widget buildLegacyDemo(BuildContext context) => JobsDemoActionHost(
  child: Scaffold(
    appBar: JobsDemoAppBar(
      actionHost: true,
      title: const LegacyText('单击双击与长按'),
    ),
    body: SafeArea(child: const TapDemo()),
  ),
);
