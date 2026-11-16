// 独立运行：flutter run -t "lib/demos/组件抽奖轮盘/FortuneWheelDemo.dart"
// 使用本工程 pubspec.yaml 声明的依赖与资源。

import 'package:jobs_flutter_base_config/demo_hub/legacy_launch.dart';

import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_fortune_wheel/flutter_fortune_wheel.dart';
import 'package:get/get.dart';
import 'package:jobs_runners/jobs_runners.dart';
import 'package:jobs_flutter_base_config/core/app_config.dart';
import 'package:jobs_demo_foundation/jobs_demo_foundation.dart';

/// 独立运行与目录预览共用同一份原始教学逻辑。
void main() => launchLegacyStandalone(legacyOriginalMain, title: '组件抽奖轮盘');

// 使用第三方库 flutter_fortune_wheel 实现抽奖轮盘
// 优点：更快实现、高级动画、插件维护良好。
// 缺点：自定义性较差、不支持完全自由布局。

void legacyOriginalMain() => legacyCaptureApp(
  const JobsMaterialRunner(
    FortuneWheelDemo(),
    title: '抽奖轮盘@flutter_fortune_wheel',
  ),
);

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
                  child: LegacyText(it, style: const TextStyle(fontSize: 18)),
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
                  title: LegacyText('🎉 恭喜你'.tr),
                  content: LegacyText('抽中了：$result'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: LegacyText('确定'.tr),
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
          child: LegacyText('点击抽奖'.tr, style: normalTextStyle()),
        ),
        const SizedBox(height: 40),
      ],
    );
  }
}

Widget buildLegacyDemo(BuildContext context) => JobsDemoActionHost(
  child: Scaffold(
    appBar: JobsDemoAppBar(actionHost: true, title: const LegacyText('组件抽奖轮盘')),
    body: SafeArea(child: const FortuneWheelDemo()),
  ),
);
