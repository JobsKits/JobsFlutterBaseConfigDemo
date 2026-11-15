import 'package:jobs_flutter_base_config/demo_hub/legacy_launch.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jobs_runners/jobs_runners.dart';
import 'package:jobs_flutter_base_config/JobsDemoTools/UI/UI.Origin🌍/TabBar切换/Common/MyTabCtrl.dart';
import 'package:jobs_flutter_base_config/JobsDemoTools/UI/UI.Origin🌍/TabBar切换/Common/HomeBinding.dart';

void legacyOriginalMain() => legacyCaptureApp(
  JobsGetRunner(HomePage(), bindings: HomeBinding(), title: '简单测试'.tr),
);

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    late final MyTabCtrl homeController;
    if (Get.isRegistered<MyTabCtrl>()) {
      homeController = Get.find<MyTabCtrl>();
    }
    return Scaffold(
      body: Obx(() {
        return IndexedStack(
          index: homeController.currentIndex.value,
          children: [
            homeController.pageA ?? Container(),
            homeController.pageB ?? Container(),
            homeController.pageC ?? Container(),
          ],
        );
      }),
      bottomNavigationBar: Obx(
        () => BottomNavigationBar(
          currentIndex: homeController.currentIndex.value,
          onTap: (index) {
            homeController.changeTabIndex(index);
          },
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: legacyControlLabel(context, 'A'),
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.business),
              label: legacyControlLabel(context, 'B'),
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.school),
              label: legacyControlLabel(context, 'C'),
            ),
          ],
        ),
      ),
    );
  }
}

/// 独立运行与目录预览共用同一份原始教学逻辑。
void main() => launchLegacyStandalone(legacyOriginalMain, title: '旧例·标签分页示例四');
