// 独立运行：flutter run -t "lib/demos/拖动手势/DragDemo.dart"
// 使用本工程 pubspec.yaml 声明的依赖与资源。

import 'package:jobs_flutter_base_config/demo_hub/legacy_launch.dart';
import 'package:flutter/material.dart';
import 'package:jobs_runners/jobs_runners.dart';
import 'package:jobs_demo_foundation/jobs_demo_foundation.dart';

/// 独立运行与目录预览共用同一份原始教学逻辑。
void main() => launchLegacyStandalone(legacyOriginalMain, title: '拖动手势');

// 公共测试器路径

void legacyOriginalMain() => legacyCaptureApp(
  const JobsMaterialRunner(DragDemo(), title: 'Drag Gesture Demo'),
);

class DragDemo extends StatelessWidget {
  const DragDemo({super.key});

  @override
  Widget build(BuildContext context) => const DragGestureDemo();
}

Widget buildLegacyDemo(BuildContext context) => const DragGestureDemo();

class DragGestureDemo extends StatefulWidget {
  const DragGestureDemo({super.key});
  @override
  State<DragGestureDemo> createState() => _DragGestureDemoState();
}

class _DragGestureDemoState extends State<DragGestureDemo> {
  int mode = 0;
  Offset position = Offset.zero;
  String log = '';
  void update(DragUpdateDetails details) => setState(() {
    position += details.delta;
    log = '${details.localPosition} → ${details.delta}';
  });
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: JobsDemoAppBar(title: const LegacyText('拖动手势')),
    body: Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Wrap(
            spacing: 8,
            children: [
              for (var i = 0; i < 3; i++)
                ChoiceChip(
                  label: LegacyText(['自由', '水平', '垂直'][i]),
                  selected: mode == i,
                  onSelected: (_) => setState(() {
                    mode = i;
                    position = Offset.zero;
                  }),
                ),
            ],
          ),
        ),
        LegacyText(log),
        Expanded(
          child: ClipRect(
            child: Center(
              child: Transform.translate(
                offset: position,
                child: GestureDetector(
                  onPanUpdate: mode == 0 ? update : null,
                  onHorizontalDragUpdate: mode == 1 ? update : null,
                  onVerticalDragUpdate: mode == 2 ? update : null,
                  child: Container(
                    width: 120,
                    height: 120,
                    color: Theme.of(context).colorScheme.primaryContainer,
                    alignment: Alignment.center,
                    child: const LegacyText('Drag Me'),
                  ),
                ),
              ),
            ),
          ),
        ),
        TextButton(
          onPressed: () => setState(() {
            position = Offset.zero;
            log = '';
          }),
          child: LegacyText(tr(context, '重置')),
        ),
      ],
    ),
  );
}
