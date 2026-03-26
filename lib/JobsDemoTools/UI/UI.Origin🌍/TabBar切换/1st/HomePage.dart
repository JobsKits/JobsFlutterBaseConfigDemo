import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jobs_flutter_base_config/JobsDemoTools/UI/UI.Origin🌍/TabBar切换/Common/MyTabCtrl.dart';
import 'package:jobs_runners/jobs_runners.dart'; // 公共测试器路径
import 'package:jobs_flutter_base_config/pages/Others/Pages.dart';

void main() => runApp(JobsGetRunner.builder(
      title: '简单测试'.tr,
      builder: (ctx) => HomePage(),
    ));

class HomePage extends StatelessWidget {
  HomePage({super.key});
  final MyTabCtrl tabController = Get.put(MyTabCtrl());
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() {
        switch (tabController.currentIndex.value) {
          case 0:
            return tabController.pageA ??= const LazyLoadWidget('PageA');
          case 1:
            return tabController.pageB ??= const LazyLoadWidget('PageB');
          case 2:
            return tabController.pageC ??= const LazyLoadWidget('PageC');
          default:
            return tabController.pageA ??= const LazyLoadWidget('PageA');
        }
      }),
      bottomNavigationBar: Obx(() => BottomNavigationBar(
            currentIndex: tabController.currentIndex.value,
            onTap: tabController.changeTabIndex,
            items: [
              BottomNavigationBarItem(icon: Icon(Icons.home), label: 'A'.tr),
              BottomNavigationBarItem(
                  icon: Icon(Icons.business), label: 'B'.tr),
              BottomNavigationBarItem(icon: Icon(Icons.school), label: 'C'.tr),
            ],
          )),
    );
  }
}

class LazyLoadWidget extends StatelessWidget {
  final String page;
  const LazyLoadWidget(this.page, {super.key});
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Future.delayed(const Duration(milliseconds: 500)),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (page == 'PageA') {
            return const PageA();
          } else if (page == 'PageB') {
            return const PageB();
          } else if (page == 'PageC') {
            return const PageC();
          } else {
            return Center(child: Text('Unknown page'.tr));
          }
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }
}
