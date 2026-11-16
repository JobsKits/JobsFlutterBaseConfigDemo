// 独立运行：flutter run -t "lib/demos/自定义浮层/JobsOverlay.dart"
// 使用本工程 pubspec.yaml 声明的依赖与资源。

import 'package:jobs_flutter_base_config/demo_hub/legacy_launch.dart';
import 'package:flutter/material.dart';
import 'package:jobs_runners/jobs_runners.dart';
import 'package:jobs_demo_foundation/jobs_demo_foundation.dart';

/// 独立运行与目录预览共用同一份原始教学逻辑。
void main() => launchLegacyStandalone(legacyOriginalMain, title: '自定义浮层');

// 公共测试器路径

void legacyOriginalMain() => legacyCaptureApp(
  const JobsMaterialRunner(JobsOverlay(), title: 'Custom Overlay Demo'),
);

class JobsOverlay extends StatefulWidget {
  const JobsOverlay({super.key});

  @override
  State<JobsOverlay> createState() => _CustomOverlayDemoState();
}

class _CustomOverlayDemoState extends State<JobsOverlay> {
  OverlayEntry? _overlayEntry;

  OverlayEntry _createOverlayEntry(ThemeData theme) {
    return OverlayEntry(
      builder: (context) => Positioned.fill(
        child: SafeArea(
          minimum: const EdgeInsets.all(16),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: SingleChildScrollView(
                child: Material(
                  elevation: 4.0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        LegacyText(
                          'This is a custom overlay',
                          style: theme.textTheme.headlineLarge,
                        ),
                        const SizedBox(height: 10),
                        ElevatedButton(
                          onPressed: () {
                            _overlayEntry?.remove();
                            _overlayEntry = null;
                          },
                          child: const LegacyText('Close'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showOverlay(BuildContext context) {
    if (_overlayEntry != null) {
      _overlayEntry?.remove();
      _overlayEntry = null;
    }

    _overlayEntry = _createOverlayEntry(Theme.of(context));
    Overlay.of(context).insert(_overlayEntry!);
  }

  @override
  void dispose() {
    _overlayEntry?.remove();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () => _showOverlay(context),
      child: const LegacyText('Show Custom Overlay'),
    );
  }
}

Widget buildLegacyDemo(BuildContext context) => JobsDemoActionHost(
  child: Scaffold(
    appBar: JobsDemoAppBar(actionHost: true, title: const LegacyText('自定义浮层')),
    body: SafeArea(child: const Center(child: JobsOverlay())),
  ),
);
