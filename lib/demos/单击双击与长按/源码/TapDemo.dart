import 'package:jobs_flutter_base_config/demo_hub/legacy_launch.dart';
import 'package:flutter/material.dart';
import 'package:jobs_runners/jobs_runners.dart';

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

/// 独立运行与目录预览共用同一份原始教学逻辑。
void main() => launchLegacyStandalone(legacyOriginalMain, title: '单击双击与长按');
