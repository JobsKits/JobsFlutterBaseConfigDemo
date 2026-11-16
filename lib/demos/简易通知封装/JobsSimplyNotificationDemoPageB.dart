import 'package:jobs_flutter_base_config/demo_hub/legacy_launch.dart';
import 'package:flutter/material.dart';
import 'package:jobs_flutter_base_config/JobsDemoTools/JobsFlutterTools/JobsNotification/JobsSimplyNotification/JobsSimplyNotification.dart';
import 'package:jobs_demo_foundation/jobs_demo_foundation.dart';

class JobsSimplyNotificationDemoPageB extends StatelessWidget {
  const JobsSimplyNotificationDemoPageB({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: JobsDemoAppBar(title: LegacyText('Page B - 监听通知')),
      body: Center(
        child: JobsSimplyNotification.listen('hello', (data) {
          return LegacyText(
            'Page B 收到：$data',
            style: TextStyle(fontSize: 18, color: Colors.blue),
          );
        }),
      ),
    );
  }
}
