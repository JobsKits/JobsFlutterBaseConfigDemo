import 'package:flutter/material.dart';
import 'package:jobs_runners/jobs_runners.dart'; // 公共测试器路径

// BoxDecoration 是最常见的装饰类，它可以用来设置背景颜色、背景图像、边框、阴影、渐变等
void main() =>
    runApp(const JobsMaterialRunner(MyApp(), title: 'BoxDecoration Demo'));

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Container(
        width: 200,
        height: 200,
        decoration: BoxDecoration(
          color: Colors.blue,
          borderRadius: BorderRadius.circular(10),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 10,
              offset: Offset(2, 2),
            ),
          ],
        ),
      ),
    );
  }
}
