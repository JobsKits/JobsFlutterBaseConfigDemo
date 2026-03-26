import 'package:flutter/material.dart';
import 'package:jobs_runners/jobs_runners.dart'; // 公共测试器路径
import 'A_Widget.dart';

void main() => runApp(const JobsMaterialRunner(MyApp(), title: 'Flutter Demo'));

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return const OtherWidget();
  }
}

class OtherWidget extends StatelessWidget {
  const OtherWidget({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Other Widget'),
      ),
      body: Center(
        child: const A_Widget()
            .buildTextWidget(), // 调用 BettingCasinoMyBetListView 中的方法
      ),
    );
  }
}
