import 'package:jobs_flutter_base_config/demo_hub/legacy_launch.dart';
import 'package:flutter/material.dart';

void legacyOriginalMain() => legacyCaptureApp(const MaterialAppDemo());

class MaterialAppDemo extends StatelessWidget {
  const MaterialAppDemo({super.key});
  @override
  Widget build(BuildContext context) {
    return LegacyAppBoundary(
      app: MaterialApp(
        /// 是否显示右上角的红色 DEBUG 标识（横幅）
        debugShowCheckedModeBanner: false,

        title: 'MaterialApp 示例',
        home: Scaffold(
          appBar: AppBar(title: const LegacyText('MaterialApp 示例')),
          body: const Center(
            child: LegacyText(
              '✅ MaterialApp 是 Flutter 默认入口容器\n'
              '• 提供主题管理、路由管理、首页指定\n'
              '• 配合 Navigator 实现传统页面跳转\n'
              '• 是 Scaffold、CupertinoApp 等容器的基础',
              style: TextStyle(fontSize: 16, color: Colors.blueGrey),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}

/// 独立运行与目录预览共用同一份原始教学逻辑。
void main() =>
    launchLegacyStandalone(legacyOriginalMain, title: '旧例·Material应用容器');
