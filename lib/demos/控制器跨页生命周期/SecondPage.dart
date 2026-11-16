import 'package:jobs_flutter_base_config/demo_hub/legacy_launch.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jobs_demo_foundation/jobs_demo_foundation.dart';

class SecondPage extends StatelessWidget {
  const SecondPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: JobsDemoAppBar(title: LegacyText('第二页')),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Get.back();
          },
          child: LegacyText('返回上一页'),
        ),
      ),
    );
  }
}
