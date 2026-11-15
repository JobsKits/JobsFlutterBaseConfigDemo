import 'package:jobs_flutter_base_config/demo_hub/legacy_launch.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jobs_runners/jobs_runners.dart';
import 'package:jobs_flutter_base_config/JobsDemoTools/UI/UI.Origin🌍/TabBar切换/Common/MyTabCtrl.dart';

void legacyOriginalMain() =>
    legacyCaptureApp(JobsGetRunner(HomePage(), title: '简单测试'.tr));

class HomePage extends StatelessWidget {
  HomePage({super.key});
  final MyTabCtrl tabController = Get.put(MyTabCtrl());
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() {
        return tabController.currentWidget;
      }),
      bottomNavigationBar: Obx(
        () => BottomNavigationBar(
          currentIndex: tabController.currentIndex.value,
          onTap: tabController.changeTabIndex,
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
void main() => launchLegacyStandalone(legacyOriginalMain, title: '旧例·标签分页示例三');
