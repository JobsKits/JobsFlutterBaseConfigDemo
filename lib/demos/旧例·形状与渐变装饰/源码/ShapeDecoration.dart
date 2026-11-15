import 'package:jobs_flutter_base_config/demo_hub/legacy_launch.dart';
import 'package:flutter/material.dart';
import 'package:jobs_runners/jobs_runners.dart'; // 公共测试器路径

// ShapeDecoration 允许你使用特定的形状和渐变来装饰容器
void legacyOriginalMain() => legacyCaptureApp(
  const JobsMaterialRunner(MyApp(), title: 'ShapeDecoration Demo'),
);

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return LegacyAppBoundary(
      app: MaterialApp(
        home: Container(
          width: 200,
          height: 200,
          decoration: ShapeDecoration(
            color: Colors.red,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        ),
      ),
    );
  }
}

/// 独立运行与目录预览共用同一份原始教学逻辑。
void main() => launchLegacyStandalone(legacyOriginalMain, title: '旧例·形状与渐变装饰');
