import 'package:jobs_flutter_base_config/demo_hub/legacy_launch.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jobs_flutter_base_config/JobsDemoTools/JobsFlutterTools/JobsNotification/JobsSimplyNotification/JobsSimplyNotification.dart';
import 'package:jobs_flutter_base_config/JobsDemoTools/JobsFlutterTools/JobsNotification/JobsSimplyNotification/JobsSimplyNotificationDemo/JobsSimplyNotificationDemoPageB.dart';
import 'package:jobs_flutter_base_config/JobsDemoTools/JobsFlutterTools/JobsNotification/JobsSimplyNotification/JobsSimplyNotificationDemo/JobsSimplyNotificationDemoPageC.dart';

class JobsSimplyNotificationDemoPageA extends StatelessWidget {
  const JobsSimplyNotificationDemoPageA({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton(
            onPressed: () {
              JobsSimplyNotification.post('hello', '来自 Page A 的通知 ✉️');
            },
            child: LegacyText('📮 发送通知 hello'),
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => Get.to(() => JobsSimplyNotificationDemoPageB()),
            child: LegacyText('➡️ 进入 Page B'),
          ),
          ElevatedButton(
            onPressed: () => Get.to(() => JobsSimplyNotificationDemoPageC()),
            child: LegacyText('➡️ 进入 Page C'),
          ),
        ],
      ),
    );
  }
}
