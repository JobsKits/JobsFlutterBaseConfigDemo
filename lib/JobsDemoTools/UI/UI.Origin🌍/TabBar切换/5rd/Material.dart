import 'package:flutter/material.dart';
import 'package:get/get_utils/get_utils.dart';
import 'package:jobs_runners/jobs_runners.dart';

void main() => runApp(JobsMaterialRunner.builder(
      title: 'Flutter Tab Demo'.tr,
      builder: (ctx) => MyHomePage(),
    ));

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    Center(child: Text('首页'.tr)),
    Center(child: Text('发现'.tr)),
    Center(child: Text('我的'.tr)),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (int index) => setState(() => _currentIndex = index),
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: '首页'.tr),
          BottomNavigationBarItem(icon: Icon(Icons.explore), label: '发现'.tr),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: '我的'.tr),
        ],
      ),
    );
  }
}
