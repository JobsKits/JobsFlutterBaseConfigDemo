import 'package:jobs_flutter_base_config/demo_hub/legacy_launch.dart';
// lib/pages/app_level_containers/cupertino_app_demo.dart
import 'package:flutter/cupertino.dart';

void legacyOriginalMain() => legacyCaptureApp(const CupertinoAppDemo());

class CupertinoAppDemo extends StatelessWidget {
  const CupertinoAppDemo({super.key});
  @override
  Widget build(BuildContext context) {
    return LegacyAppBoundary(
      app: const CupertinoApp(
        debugShowCheckedModeBanner: false,

        /// 是否显示右上角的红色 DEBUG 标识（横幅）
        home: CupertinoHomePage(),
      ),
    );
  }
}

class CupertinoHomePage extends StatelessWidget {
  const CupertinoHomePage({super.key});
  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: LegacyText('CupertinoApp 示例'),
      ),
      child: const Center(
        child: LegacyText(
          '这是 CupertinoApp 的结构\n'
          '🍎 CupertinoApp 是 iOS 风格的应用入口\n'
          '• 用于构建 iOS 原生风格页面结构\n'
          '• 自动使用 Cupertino 样式导航与动画\n'
          '• 与 MaterialApp 互斥，只能用一个',
        ),
      ),
    );
  }
}

/// 独立运行与目录预览共用同一份原始教学逻辑。
void main() =>
    launchLegacyStandalone(legacyOriginalMain, title: '旧例·Cupertino应用容器');
