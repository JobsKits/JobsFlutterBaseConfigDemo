import 'package:flutter/material.dart';
import 'package:jobs_runners/jobs_runners.dart';

void main() =>
    runApp(const JobsMaterialRunner(CenterDemo(), title: 'Center 属性演示'));

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const CenterDemo();
  }
}

class CenterDemo extends StatelessWidget {
  const CenterDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey[300],
      child: Center(
        widthFactor: 2.0, // 宽度为 child 的 2 倍
        heightFactor: 3.0, // 高度为 child 的 3 倍
        child: Container(
          color: Colors.blue,
          width: 80,
          height: 80,
          child: const Center(
            child: Text(
              '居中',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }
}
