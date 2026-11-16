// 独立运行：flutter run -t "lib/demos/键盘高度与视图指标/Keyboard.dart"
// 使用本工程 pubspec.yaml 声明的依赖与资源。

import 'package:jobs_flutter_base_config/demo_hub/legacy_launch.dart';
import 'package:flutter/material.dart';
import 'package:jobs_runners/jobs_runners.dart';
import 'package:jobs_demo_foundation/jobs_demo_foundation.dart';

/// 独立运行与目录预览共用同一份原始教学逻辑。
void main() => launchLegacyStandalone(legacyOriginalMain, title: '键盘高度与视图指标');

// 公共测试器路径

// 监听键盘实时的高度变化

void legacyOriginalMain() => legacyCaptureApp(
  const JobsMaterialRunner(
    KeyboardHeightScreen(),
    title: 'Keyboard Height Demo',
  ),
);

class KeyboardHeightScreen extends StatefulWidget {
  const KeyboardHeightScreen({super.key});

  @override
  State<KeyboardHeightScreen> createState() => _KeyboardHeightScreenState();
}

class _KeyboardHeightScreenState extends State<KeyboardHeightScreen>
    with WidgetsBindingObserver {
  double _keyboardHeight = 0.0;
  @override
  void initState() {
    super.initState();
    // 监听键盘弹出事件
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    // 移除监听
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeMetrics() => _keyboardVisibilityObserver();

  void _keyboardVisibilityObserver() {
    if (!mounted) return;
    final view = View.of(context);
    final bottom = view.viewInsets.bottom / view.devicePixelRatio;
    final bool isKeyboardVisible = bottom > 0;
    final double keyboardHeight = isKeyboardVisible ? bottom : 0.0;
    setState(() {
      _keyboardHeight = keyboardHeight;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: JobsDemoAppBar(title: const LegacyText('Keyboard Height Demo')),
      body: GestureDetector(
        onTap: () {
          // 点击屏幕其他地方收起键盘
          FocusScope.of(context).unfocus();
        },
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(
                decoration: legacyInputDecoration(
                  context,
                  InputDecoration(labelText: 'Keyboard input'),
                ),
              ),
              const LegacyText('Tap anywhere to dismiss the keyboard'),
              const SizedBox(height: 20),
              LegacyText('Keyboard height: $_keyboardHeight'),
            ],
          ),
        ),
      ),
    );
  }
}

Widget buildLegacyDemo(BuildContext context) =>
    LegacyLaunchPage(action: legacyOriginalMain, title: 'Keyboard');
