import 'package:jobs_flutter_base_config/demo_hub/legacy_launch.dart';
import 'package:flutter/material.dart';
import 'package:jobs_runners/jobs_runners.dart'; // 公共测试器路径

void legacyOriginalMain() => legacyCaptureApp(
  const JobsMaterialRunner(DragDemo(), title: 'Drag Gesture Demo'),
);

class DragDemo extends StatelessWidget {
  const DragDemo({super.key});
  @override
  Widget build(BuildContext context) {
    return Center(
      child: GestureDetector(
        onHorizontalDragUpdate: (details) {
          legacyDebugPrint('Horizontal drag: ${details.delta.dx}');
        },
        onVerticalDragUpdate: (details) {
          legacyDebugPrint('Vertical drag: ${details.delta.dy}');
        },
        onPanUpdate: (details) {
          legacyDebugPrint('Pan: ${details.delta}');
        },
        child: Container(
          color: Colors.green,
          width: 100,
          height: 100,
          child: const Center(
            child: LegacyText('Drag Me', style: TextStyle(color: Colors.white)),
          ),
        ),
      ),
    );
  }
}

/// 独立运行与目录预览共用同一份原始教学逻辑。
void main() => launchLegacyStandalone(legacyOriginalMain, title: '拖动手势');
