import 'package:jobs_flutter_base_config/demo_hub/legacy_launch.dart';
import 'package:flutter/material.dart';
import 'package:jobs_flutter_base_config/JobsDemoTools/JobsFlutterTools/JobsNotification/JobsNotification/JobsNotification.dart';

class JobsNotificationDemoPageB extends StatelessWidget {
  const JobsNotificationDemoPageB({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: LegacyText('Page B - UI监听')),
      body: Center(
        child: JobsNotification.listen('msg', (data) {
          return LegacyText(
            'Page B 接收到：$data',
            style: TextStyle(fontSize: 18, color: Colors.blue),
          );
        }),
      ),
    );
  }
}
