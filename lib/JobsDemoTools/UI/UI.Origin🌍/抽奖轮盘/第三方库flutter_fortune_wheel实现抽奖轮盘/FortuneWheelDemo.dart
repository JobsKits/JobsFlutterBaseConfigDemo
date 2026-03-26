import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_fortune_wheel/flutter_fortune_wheel.dart';
import 'package:get/get.dart';
import 'package:jobs_runners/jobs_runners.dart';
import 'package:jobs_flutter_base_config/core/app_config.dart';

// 使用第三方库 flutter_fortune_wheel 实现抽奖轮盘
// 优点：更快实现、高级动画、插件维护良好。
// 缺点：自定义性较差、不支持完全自由布局。

void main() => runApp(const JobsMaterialRunner(FortuneWheelDemo(),
    title: '抽奖轮盘@flutter_fortune_wheel'));

class FortuneWheelDemo extends StatefulWidget {
  const FortuneWheelDemo({super.key});

  @override
  State<FortuneWheelDemo> createState() => _FortuneWheelDemoState();
}

class _FortuneWheelDemoState extends State<FortuneWheelDemo> {
  final List<String> items = [
    '一等奖'.tr,
    '二等奖'.tr,
    '三等奖'.tr,
    '谢谢参与'.tr,
    '四等奖'.tr,
    '再试一次'.tr,
  ];

  final StreamController<int> _controller = StreamController<int>();

  int selected = 0;

  @override
  void dispose() {
    _controller.close();
    super.dispose();
  }

  void _spinWheel() {
    setState(() {
      selected = Random().nextInt(items.length);
      _controller.add(selected);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          child: FortuneWheel(
            selected: _controller.stream,
            items: [
              for (final it in items)
                FortuneItem(
                  child: Text(it, style: const TextStyle(fontSize: 18)),
                  style: const FortuneItemStyle(
                    color: Colors.amberAccent,
                    borderColor: Colors.orange,
                    borderWidth: 1,
                  ),
                ),
            ],
            onAnimationEnd: () {
              final result = items[selected];
              showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  title: Text('🎉 恭喜你'.tr),
                  content: Text('抽中了：$result'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('确定'.tr),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: _spinWheel,
          child: Text(
            '点击抽奖'.tr,
            style: normalTextStyle(),
          ),
        ),
        const SizedBox(height: 40),
      ],
    );
  }
}
