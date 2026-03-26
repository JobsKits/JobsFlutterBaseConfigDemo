import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jobs_flutter_base_config/JobsDemoTools/Data/Data.3rd/GetXDemo/GetxController的生命周期/LifecycleController.dart';
import 'package:jobs_flutter_base_config/JobsDemoTools/Data/Data.3rd/GetXDemo/GetxController的生命周期/SecondPage.dart';
import 'package:jobs_runners/jobs_runners.dart';

void main() =>
    runApp(JobsGetRunner(LifecycleDemoPage(), title: 'GetxController的生命周期演示'));

class LifecycleDemoPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetBuilder<LifecycleController>(
      init: LifecycleController(),
      builder: (_) {
        return Center(
          child: ElevatedButton(
            onPressed: () {
              Get.to(() => SecondPage());
            },
            child: Text('跳转到第二页'),
          ),
        );
      },
    );
  }
}
