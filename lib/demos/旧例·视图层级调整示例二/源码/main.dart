import 'package:jobs_flutter_base_config/demo_hub/legacy_launch.dart';
import 'package:get/get.dart';
import 'package:jobs_flutter_base_config/pages/Others/Pages.dart';

// 从 PageA 导航到 PageB 使用 Get.to 方法。
// 从 PageB 导航到 PageC 使用 Get.to 方法。
// 在 PageC 中，通过点击按钮，使用 Get.off 方法将 PageB 置于顶层，并关闭当前页面 PageC。
// 这样，PageB 就被置于顶层，PageC 被移除。
void legacyOriginalMain() {
  legacyCaptureApp(
    LegacyAppBoundary(
      app: GetMaterialApp(
        initialRoute: '/',
        getPages: [
          GetPage(name: '/', page: () => const PageA()),
          GetPage(name: '/pageB', page: () => const PageB()),
          GetPage(name: '/pageC', page: () => const PageC()),
        ],
      ),
    ),
  );
}

/// 独立运行与目录预览共用同一份原始教学逻辑。
void main() =>
    launchLegacyStandalone(legacyOriginalMain, title: '旧例·视图层级调整示例二');
