import 'package:jobs_flutter_base_config/demo_hub/legacy_launch.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jobs_runners/jobs_runners.dart'; // 公共测试器路径
import 'package:jobs_flutter_base_config/JobsDemoTools/Data/Data.3rd/监听/跨页面监听/controllers/form_controller.dart';
import 'package:jobs_flutter_base_config/JobsDemoTools/Data/Data.3rd/监听/跨页面监听/widgets/JobsButton.dart';
import 'package:jobs_flutter_base_config/JobsDemoTools/Data/Data.3rd/监听/跨页面监听/widgets/JobsTextField.dart';

// flutter的demo，界面上有2个输入框，一个按钮。要求输入框有值的情况下，按钮才能按。
// 按钮点击事件是发出手机震动
// 状态管理用getx
// 按钮和输入框要进行封装成2个不同的类

void legacyOriginalMain() {
  legacyCaptureApp(
    JobsGetRunner.builder(
      title: 'Obx 测试',
      builder: (ctx) => HomeScreen(),
      bindings: null,
    ),
  );
}

class HomeScreen extends StatelessWidget {
  HomeScreen({super.key});
  final FormController formController = Get.put(FormController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const LegacyText('Flutter GetX Demo')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            JobsTextField(
              controller: formController.firstTextController,
              hintText: legacyControlLabel(context, 'Enter first value'),
            ),
            const SizedBox(height: 10),
            JobsTextField(
              controller: formController.secondTextController,
              hintText: legacyControlLabel(context, 'Enter second value'),
            ),
            const SizedBox(height: 20),
            JobsButton(
              onPressed: formController.onButtonPressed,
              isButtonEnabled: formController.isButtonEnabled,
            ),
          ],
        ),
      ),
    );
  }
}

/// 独立运行与目录预览共用同一份原始教学逻辑。
void main() => launchLegacyStandalone(legacyOriginalMain, title: '旧例·跨页面状态监听');
