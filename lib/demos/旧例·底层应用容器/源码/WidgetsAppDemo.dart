import 'package:jobs_flutter_base_config/demo_hub/legacy_launch.dart';
import 'package:flutter/widgets.dart';

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

/// 独立运行与目录预览共用同一份原始教学逻辑。
void main() => launchLegacyStandalone(legacyOriginalMain, title: '旧例·底层应用容器');
