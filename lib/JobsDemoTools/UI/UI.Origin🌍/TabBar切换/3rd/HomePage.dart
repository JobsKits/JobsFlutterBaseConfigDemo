import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jobs_runners/jobs_runners.dart';
import '../Common/MyTabCtrl.dart';

void main() => runApp(JobsGetRunner(HomePage(), title: '简单测试'.tr));

class HomePage extends StatelessWidget {
  HomePage({super.key});
  final MyTabCtrl tabController = Get.put(MyTabCtrl());
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() {
        return tabController.currentWidget;
      }),
      bottomNavigationBar: Obx(() => BottomNavigationBar(
            currentIndex: tabController.currentIndex.value,
            onTap: tabController.changeTabIndex,
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.home), label: 'A'),
              BottomNavigationBarItem(icon: Icon(Icons.business), label: 'B'),
              BottomNavigationBarItem(icon: Icon(Icons.school), label: 'C'),
            ],
          )),
    );
  }
}
