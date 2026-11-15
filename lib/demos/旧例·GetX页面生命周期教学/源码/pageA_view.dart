import 'package:jobs_flutter_base_config/demo_hub/legacy_launch.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:jobs_flutter_base_config/JobsDemoTools/UI/UI.3rd🌹/GetX/GetX管理的页面的生命周期/GetX.PageB/views/pageB_view.dart';
import 'package:jobs_flutter_base_config/JobsDemoTools/UI/UI.3rd🌹/GetX/GetX管理的页面的生命周期/GetX.PageA/controllers/pageA_controllers.dart';

class PageAView extends GetView<PageAControllers> {
  const PageAView({super.key});
  @override
  Widget build(BuildContext context) {
    /// iOS 的命名风格
    PageAControllers self = Get.put(PageAControllers());
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Get.to(() => const PageBView());
            debugPrint(self.changeText());
          },
          child: const LegacyText('Go to Page B'),
        ),
      ),
    );
  }
}
