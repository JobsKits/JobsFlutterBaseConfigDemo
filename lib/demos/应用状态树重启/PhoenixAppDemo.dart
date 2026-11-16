// 独立运行：flutter run -t "lib/demos/应用状态树重启/PhoenixAppDemo.dart"
// 使用本工程 pubspec.yaml 声明的依赖与资源。

import 'package:jobs_flutter_base_config/demo_hub/legacy_launch.dart';
import 'package:flutter/material.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:jobs_demo_foundation/jobs_demo_foundation.dart';

/// 独立运行与目录预览共用同一份原始教学逻辑。
void main() => launchLegacyStandalone(legacyOriginalMain, title: '应用状态树重启');

void legacyOriginalMain() {
  legacyCaptureApp(Phoenix(child: const PhoenixAppDemo()));
}

class PhoenixAppDemo extends StatelessWidget {
  const PhoenixAppDemo({super.key});
  @override
  Widget build(BuildContext context) {
    return LegacyAppBoundary(
      app: MaterialApp(
        home: Scaffold(
          appBar: JobsDemoAppBar(title: const LegacyText('Phoenix 示例')),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const LegacyText(
                  '🌀 Phoenix 提供全局热重启能力\n'
                  '• 调用 Phoenix.rebirth(context)\n'
                  '• 整个 App 状态树将重新启动',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => Phoenix.rebirth(context),
                  child: const LegacyText('重启 App'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

Widget buildLegacyDemo(BuildContext context) =>
    LegacyLaunchPage(action: legacyOriginalMain, title: 'PhoenixAppDemo');
