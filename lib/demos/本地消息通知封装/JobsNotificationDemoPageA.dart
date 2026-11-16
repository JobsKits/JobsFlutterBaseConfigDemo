import 'package:jobs_flutter_base_config/demo_hub/legacy_launch.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jobs_flutter_base_config/JobsDemoTools/JobsFlutterTools/JobsNotification/JobsNotification/JobsNotification.dart';
import 'package:jobs_flutter_base_config/JobsDemoTools/JobsFlutterTools/JobsNotification/JobsNotification/JobsNotificationDemo/JobsNotificationDemoPageB.dart';
import 'package:jobs_flutter_base_config/JobsDemoTools/JobsFlutterTools/JobsNotification/JobsNotification/JobsNotificationDemo/JobsNotificationDemoPageC.dart';

class JobsNotificationDemoPageA extends StatelessWidget {
  const JobsNotificationDemoPageA({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton(
            onPressed: () {
              JobsNotification.post('msg', '来自 PageA 的通知 🚀');
            },
            child: LegacyText('📮 发送通知：msg'),
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => Get.to(() => JobsNotificationDemoPageB()),
            child: LegacyText('➡️ 跳转到 PageB (UI监听)'),
          ),
          ElevatedButton(
            onPressed: () => Get.to(() => JobsNotificationDemoPageC()),
            child: LegacyText('➡️ 跳转到 PageC (逻辑监听)'),
          ),
        ],
      ),
    );
  }
}
