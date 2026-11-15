import 'package:jobs_flutter_base_config/demo_hub/legacy_launch.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

void legacyOriginalMain() {
  legacyCaptureApp(
    LegacyAppBoundary(
      app: GetMaterialApp(
        navigatorKey: Get.key, // 必须
        home: HomePage(),
      ),
    ),
  );
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});
  @override
  Widget build(BuildContext context) {
    final controller = Get.put(Legacy127HomeController());
    return Scaffold(
      appBar: AppBar(title: const LegacyText('GetX 控制器跳转示例')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: controller.showAlert,
              child: const LegacyText('使用 Get.context 弹窗'),
            ),
            ElevatedButton(
              onPressed: controller.navigateUsingNavigator,
              child: const LegacyText('使用 Get.key 跳转页面'),
            ),
            ElevatedButton(
              onPressed: controller.navigateUsingGet,
              child: const LegacyText('使用 Get.to 跳转页面'),
            ),
          ],
        ),
      ),
    );
  }
}

class Legacy127HomeController extends GetxController {
  void showAlert() {
    final context = Get.context;
    if (context != null) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const LegacyText('Hello'),
          content: const LegacyText('这是通过 Get.context 弹出的弹窗'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const LegacyText('关闭'),
            ),
          ],
        ),
      );
    } else {
      legacyDebugPrint('❌ Get.context is null');
    }
  }

  void navigateUsingNavigator() {
    final navigator = Get.key.currentState;
    if (navigator != null) {
      navigator.push(MaterialPageRoute(builder: (_) => const NextPage()));
    } else {
      legacyDebugPrint('❌ Navigator is null');
    }
  }

  void navigateUsingGet() {
    Get.to(() => const NextPage());
  }
}

class NextPage extends StatelessWidget {
  const NextPage({super.key});

  /// 不写这一句，系统会默认给一个：NextPage(); // ✅ 合法，照样能跳转
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const LegacyText('下一页')),
      body: const Center(child: LegacyText('这是新页面')),
    );
  }
}

/// 独立运行与目录预览共用同一份原始教学逻辑。
void main() =>
    launchLegacyStandalone(legacyOriginalMain, title: '旧例·GetX命名路由示例四');

typedef HomeController = Legacy127HomeController;
