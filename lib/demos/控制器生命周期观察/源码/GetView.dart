import 'package:jobs_flutter_base_config/demo_hub/legacy_launch.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

// 如果要在 GetView 中直接使用 WidgetsBindingObserver，
// 你需要利用 GetView 的 controller 属性来管理生命周期，同时确保 WidgetsBindingObserver 逻辑在适当的地方实现。
// 虽然 GetView 本身是一个 StatelessWidget，但你可以将 WidgetsBindingObserver 的逻辑放到 Controller 中，并且在 GetView 中触发相应的操作。
// 下面是一个示例，展示如何在 GetView 中实现 WidgetsBindingObserver：

/// 在Dart中,!操作符被称为"非空断言操作符",它告诉编译器该变量绝不会为null。
/// 但是,如果你在一个可能为null的变量后面使用!操作符,并且这个变量实际上为null,那么就会触发一个NullPointerException异常,导致应用程序崩溃。
void legacyOriginalMain() {
  legacyCaptureApp(
    LegacyAppBoundary(
      app: GetMaterialApp(
        initialBinding: BindingsBuilder(() {
          Get.put(Legacy38RotaryController());
        }),
        home: const RotaryView(),
      ),
    ),
  );
}

class Legacy38RotaryController extends GetxController
    with WidgetsBindingObserver {
  var isLoading = false.obs;
  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    super.onClose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      isLoading.value = false;
      legacyDebugPrint("App resumed");
    }
  }
}

class RotaryView extends GetView<Legacy38RotaryController> {
  const RotaryView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const LegacyText('Rotary View')),
      body: Obx(
        () => controller.isLoading.value
            ? const Center(child: CircularProgressIndicator())
            : const Center(child: LegacyText('Rotary View Content')),
      ),
    );
  }
}

/// 独立运行与目录预览共用同一份原始教学逻辑。
void main() => launchLegacyStandalone(legacyOriginalMain, title: '控制器生命周期观察');

typedef RotaryController = Legacy38RotaryController;
