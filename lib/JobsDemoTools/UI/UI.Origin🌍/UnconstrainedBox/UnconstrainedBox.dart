import 'package:flutter/material.dart';
import 'package:jobs_runners/jobs_runners.dart';

void main() =>
    runApp(const JobsMaterialRunner(MyApp(), title: '📐 UnconstrainedBox 示例'));

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 200,
        height: 200,
        color: Colors.grey[300],
        child: SingleChildScrollView(
          // ✅ 添加滚动防止溢出
          scrollDirection: Axis.horizontal,
          child: UnconstrainedBox(
            child: Container(
              width: 300,
              height: 100,
              color: Colors.blue,
              child: const Center(
                child: Text(
                  '突破父容器但不溢出',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
