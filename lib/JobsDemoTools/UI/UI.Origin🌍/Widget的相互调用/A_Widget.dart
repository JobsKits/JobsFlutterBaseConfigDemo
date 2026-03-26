import 'package:flutter/material.dart';
import 'package:jobs_runners/jobs_runners.dart'; // 公共测试器路径

void main() => runApp(const JobsMaterialRunner(A_Widget(),
    title: 'Betting Casino My Bet List View'));

// ignore: camel_case_types
class A_Widget extends StatelessWidget {
  const A_Widget({super.key});
  @override
  Widget build(BuildContext context) {
    return Center(
      child: buildTextWidget(),
    );
  }

  Widget buildTextWidget() {
    return const Text(
      'Hello from A_Widget!',
      style: TextStyle(fontSize: 20, color: Colors.blue),
    );
  }
}
