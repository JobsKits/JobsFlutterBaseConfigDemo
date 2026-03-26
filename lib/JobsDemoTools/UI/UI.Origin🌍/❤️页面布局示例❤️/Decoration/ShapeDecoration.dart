import 'package:flutter/material.dart';
import 'package:jobs_runners/jobs_runners.dart'; // 公共测试器路径

// ShapeDecoration 允许你使用特定的形状和渐变来装饰容器
void main() =>
    runApp(const JobsMaterialRunner(MyApp(), title: 'ShapeDecoration Demo'));

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
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
    );
  }
}
