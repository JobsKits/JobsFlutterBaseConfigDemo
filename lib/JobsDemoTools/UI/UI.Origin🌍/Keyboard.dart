import 'package:flutter/material.dart';
import 'package:jobs_runners/jobs_runners.dart'; // 公共测试器路径
// 监听键盘实时的高度变化

void main() => runApp(const JobsMaterialRunner(KeyboardHeightScreen(),
    title: 'Keyboard Height Demo'));

class KeyboardHeightScreen extends StatefulWidget {
  const KeyboardHeightScreen({super.key});

  @override
  _KeyboardHeightScreenState createState() => _KeyboardHeightScreenState();
}

class _KeyboardHeightScreenState extends State<KeyboardHeightScreen> {
  double _keyboardHeight = 0.0;
  @override
  void initState() {
    super.initState();
    // 监听键盘弹出事件
    WidgetsBinding.instance
        .addObserver(_keyboardVisibilityObserver as WidgetsBindingObserver);
  }

  @override
  void dispose() {
    // 移除监听
    WidgetsBinding.instance
        .removeObserver(_keyboardVisibilityObserver as WidgetsBindingObserver);
    super.dispose();
  }

  void _keyboardVisibilityObserver() {
    final bool isKeyboardVisible = MediaQuery.of(context).viewInsets.bottom > 0;
    final double keyboardHeight =
        isKeyboardVisible ? MediaQuery.of(context).viewInsets.bottom : 0.0;
    setState(() {
      _keyboardHeight = keyboardHeight;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Keyboard Height Demo'),
      ),
      body: GestureDetector(
        onTap: () {
          // 点击屏幕其他地方收起键盘
          FocusScope.of(context).unfocus();
        },
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Tap anywhere to dismiss the keyboard'),
              const SizedBox(height: 20),
              Text('Keyboard height: $_keyboardHeight'),
            ],
          ),
        ),
      ),
    );
  }
}
