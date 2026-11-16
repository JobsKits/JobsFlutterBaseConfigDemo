// 独立运行：flutter run -t "lib/demos/层叠布局教学/Stack.dart"
// 使用本工程 pubspec.yaml 声明的依赖与资源。

import 'package:jobs_flutter_base_config/demo_hub/legacy_launch.dart';
import 'package:flutter/material.dart';
import 'package:jobs_runners/jobs_runners.dart';

/// 独立运行与目录预览共用同一份原始教学逻辑。
void main() => launchLegacyStandalone(legacyOriginalMain, title: '层叠布局教学');

// 公共测试器路径

// 这个示例展示了如何使用 Stack 小部件在同一屏幕上重叠显示多个小部件
// Positioned 小部件用于将按钮定位到 Stack 的右下角。通过指定 bottom 和 right 属性，可以精确控制按钮的位置。
void legacyOriginalMain() =>
    legacyCaptureApp(const JobsMaterialRunner(MyApp(), title: 'Stack Demo'));

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return LegacyAppBoundary(
      app: MaterialApp(
        home: Center(
          child: Stack(
            alignment: Alignment.center,
            children: <Widget>[
              // 背景图像
              SizedBox(
                width: 300,
                height: 300,
                child: legacyNetworkImage(
                  'https://flutter.dev/images/catalog-widget-placeholder.png',
                  fit: BoxFit.cover,
                ),
              ),
              // 居中的文本
              const LegacyText(
                'Hello, Flutter!',
                style: TextStyle(
                  fontSize: 24,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              // 右下角的按钮
              Positioned(
                bottom: 10,
                right: 10,
                child: ElevatedButton(
                  onPressed: () {},
                  child: const LegacyText('Button'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Widget buildLegacyDemo(BuildContext context) =>
    LegacyLaunchPage(action: legacyOriginalMain, title: 'Stack');
