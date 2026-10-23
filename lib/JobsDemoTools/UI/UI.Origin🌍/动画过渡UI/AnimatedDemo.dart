import 'package:flutter/material.dart';
import 'package:jobs_runners/jobs_runners.dart'; // 公共测试器路径

/// 创建一个点击后会“动画改变大小和位置”的按钮 Demo 页面
/// 方便测试或展示 Flutter 中 AnimatedPositioned 和 AnimatedContainer 的组合使用效果。
void main() => runApp(const JobsMaterialRunner(HomePage(), title: 'XXX'));

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  _HomePageState createState() => _HomePageState();
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
      appBar: AppBar(
        title: const Text('Animated Button Demo'),
      ),
      body: SafeArea(
        child: LayoutBuilder(builder: (context, constraints) {
          final width = _width.clamp(0.0, constraints.maxWidth);
          final height = _height.clamp(0.0, constraints.maxHeight);
          final maxLeft = constraints.maxWidth - width;
          final maxTop = constraints.maxHeight - height;
          return Stack(
            children: [
              AnimatedPositioned(
                left:
                    _isInitialPosition ? maxLeft / 2 : 50.0.clamp(0.0, maxLeft),
                top: _isInitialPosition ? maxTop / 2 : 100.0.clamp(0.0, maxTop),
                duration: const Duration(seconds: 1), // 过渡动画的持续时间
                curve: Curves.easeInOut, // 过渡动画的曲线
                child: AnimatedContainer(
                  width: width,
                  height: height,
                  duration: const Duration(seconds: 1), // 过渡动画的持续时间
                  curve: Curves.easeInOut, // 过渡动画的曲线
                  child: ElevatedButton(
                    onPressed: _changeSizeAndPosition,
                    child: const Text('Click Me'),
                  ),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}
