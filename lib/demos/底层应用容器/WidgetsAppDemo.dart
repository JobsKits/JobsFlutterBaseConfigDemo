// 独立运行：flutter run -t "lib/demos/底层应用容器/WidgetsAppDemo.dart"
// 使用本工程 pubspec.yaml 声明的依赖与资源。

import 'package:jobs_flutter_base_config/demo_hub/legacy_launch.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';

/// 独立运行与目录预览共用同一份原始教学逻辑。
void main() => launchLegacyStandalone(legacyOriginalMain, title: '底层应用容器');

void legacyOriginalMain() => legacyCaptureApp(const WidgetsAppDemo());

class WidgetsAppDemo extends StatelessWidget {
  const WidgetsAppDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return WidgetsApp(
      color: const Color(0xFFFFFFFF),
      builder: (context, child) => const Center(
        child: LegacyText(
          '🧱 WidgetsApp 是最基础的容器\n'
          '• 没有主题、没有 Material 组件\n'
          '• 通常作为 MaterialApp 的底层实现',
          textAlign: TextAlign.center,
        ),
      ),
      onGenerateRoute: (settings) =>
          PageRouteBuilder(pageBuilder: (_, __, ___) => const Placeholder()),
    );
  }
}

Widget buildLegacyDemo(BuildContext context) =>
    LegacyLaunchPage(action: legacyOriginalMain, title: 'WidgetsAppDemo');
