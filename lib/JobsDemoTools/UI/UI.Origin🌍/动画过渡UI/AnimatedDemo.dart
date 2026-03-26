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
  double _left = 0.0;
  double _top = 0.0;

  bool _isInitialPosition = true;

  // 切换大小和位置的函数
  void _changeSizeAndPosition() {
    setState(() {
      if (_isInitialPosition) {
        _width = 100.0;
        _height = 80.0;
        _left = 50.0;
        _top = 100.0;
      } else {
        _width = 50.0;
        _height = 50.0;
        _left = (MediaQuery.of(context).size.width - 50) / 2;
        _top = (MediaQuery.of(context).size.height - 50) / 2;
      }
      _isInitialPosition = !_isInitialPosition;
    });
  }

  @override
  Widget build(BuildContext context) {
    // 初始位置设为屏幕居中
    if (_isInitialPosition) {
      _left = (MediaQuery.of(context).size.width - _width) / 2;
      _top = (MediaQuery.of(context).size.height - _height) / 2;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Animated Button Demo'),
      ),
      body: Stack(
        children: [
          AnimatedPositioned(
            left: _left,
            top: _top,
            duration: const Duration(seconds: 1), // 过渡动画的持续时间
            curve: Curves.easeInOut, // 过渡动画的曲线
            child: AnimatedContainer(
              width: _width,
              height: _height,
              duration: const Duration(seconds: 1), // 过渡动画的持续时间
              curve: Curves.easeInOut, // 过渡动画的曲线
              child: ElevatedButton(
                onPressed: _changeSizeAndPosition,
                child: const Text('Click Me'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
