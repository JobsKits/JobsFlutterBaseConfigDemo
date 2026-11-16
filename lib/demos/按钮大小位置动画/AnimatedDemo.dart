// 独立运行：flutter run -t "lib/demos/按钮大小位置动画/AnimatedDemo.dart"
// 使用本工程 pubspec.yaml 声明的依赖与资源。

import 'package:jobs_flutter_base_config/demo_hub/legacy_launch.dart';
import 'package:flutter/material.dart';
import 'package:jobs_runners/jobs_runners.dart';
import 'package:jobs_demo_foundation/jobs_demo_foundation.dart';

/// 独立运行与目录预览共用同一份原始教学逻辑。
void main() => launchLegacyStandalone(legacyOriginalMain, title: '按钮大小位置动画');

// 公共测试器路径

/// 创建一个点击后会“动画改变大小和位置”的按钮 Demo 页面
/// 方便测试或展示 Flutter 中 AnimatedPositioned 和 AnimatedContainer 的组合使用效果。
void legacyOriginalMain() =>
    legacyCaptureApp(const JobsMaterialRunner(HomePage(), title: 'XXX'));

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // 初始大小和位置
  double _width = 50.0;
  double _height = 50.0;

  bool _isInitialPosition = true;

  // 切换大小和位置的函数
  void _changeSizeAndPosition() {
    setState(() {
      if (_isInitialPosition) {
        _width = 100.0;
        _height = 80.0;
      } else {
        _width = 50.0;
        _height = 50.0;
      }
      _isInitialPosition = !_isInitialPosition;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: JobsDemoAppBar(title: const LegacyText('Animated Button Demo')),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final width = _width.clamp(0.0, constraints.maxWidth);
            final height = _height.clamp(0.0, constraints.maxHeight);
            final maxLeft = constraints.maxWidth - width;
            final maxTop = constraints.maxHeight - height;
            return Stack(
              children: [
                AnimatedPositioned(
                  left: _isInitialPosition
                      ? maxLeft / 2
                      : 50.0.clamp(0.0, maxLeft),
                  top: _isInitialPosition
                      ? maxTop / 2
                      : 100.0.clamp(0.0, maxTop),
                  duration: const Duration(seconds: 1), // 过渡动画的持续时间
                  curve: Curves.easeInOut, // 过渡动画的曲线
                  child: AnimatedContainer(
                    width: width,
                    height: height,
                    duration: const Duration(seconds: 1), // 过渡动画的持续时间
                    curve: Curves.easeInOut, // 过渡动画的曲线
                    child: ElevatedButton(
                      onPressed: _changeSizeAndPosition,
                      child: const LegacyText('Click Me'),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

Widget buildLegacyDemo(BuildContext context) => const HomePage();
