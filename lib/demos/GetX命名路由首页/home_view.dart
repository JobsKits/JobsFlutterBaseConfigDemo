// 独立运行：flutter run -t "lib/demos/GetX命名路由首页/home_view.dart"
// 使用本工程 pubspec.yaml 声明的依赖与资源。

import 'package:jobs_flutter_base_config/demo_hub/legacy_launch.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jobs_runners/jobs_runners.dart'; // 公共测试器路径
import 'package:jobs_flutter_base_config/JobsDemoTools/Data/Data.3rd/GetXDemo/GetX_RouteDemo/GetX_RouteDemo1/home_controller.dart';

/// 独立运行与目录预览共用同一份原始教学逻辑。
void main() => launchLegacyStandalone(legacyOriginalMain, title: 'GetX命名路由首页');

void legacyOriginalMain() =>
    legacyCaptureApp(const JobsMaterialRunner(HomeView(), title: 'Home'));

// 使用Obx来监听count的变化，并在按钮按下时调用 controller.increment() 方法
class HomeView extends StatelessWidget {
  const HomeView({super.key});
  @override
  Widget build(BuildContext context) {
    late final HomeController controller;
    if (Get.isRegistered<HomeController>()) {
      controller = Get.find<HomeController>();
    }
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Obx(
          () => LegacyText(
            'Button pressed ${controller.count} times',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: controller.increment,
          child: const LegacyText('Increment'),
        ),
      ],
    );
  }
}

Widget buildLegacyDemo(BuildContext context) =>
    LegacyLaunchPage(action: legacyOriginalMain, title: 'GetX_RouteDemo1·126');
