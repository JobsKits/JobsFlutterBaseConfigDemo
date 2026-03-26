import 'package:flutter/material.dart';
import 'package:jobs_runners/jobs_runners.dart'; // 公共测试器路径

// FlutterLogoDecoration 是一个特殊的装饰类，用于显示 Flutter 的 logo
void main() => runApp(
    const JobsMaterialRunner(MyApp(), title: 'FlutterLogoDecoration Demo'));

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: DecoratedBox(
        decoration: FlutterLogoDecoration(),
        child: SizedBox(
          width: 200,
          height: 200,
        ),
      ),
    );
  }
}
