import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:jobs_flutter_base_config/JobsDemoTools/JobsFlutterTools/调试/JobsCommonUtil.dart';

class LifecycleController extends GetxController with WidgetsBindingObserver {
  @override
  void onInit() {
    super.onInit();
    JobsPrint('🔥 onInit');
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void onReady() {
    super.onReady();
    JobsPrint('✅ onReady');
  }

  @override
  void onClose() {
    JobsPrint('❌ onClose');
    WidgetsBinding.instance.removeObserver(this);
    super.onClose();
  }

  @override
  void dispose() {
    JobsPrint('🗑️ dispose');
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    JobsPrint('📲 AppLifecycleState = $state');
    switch (state) {
      case AppLifecycleState.resumed:
        JobsPrint('🟢 onResumed');
        break;
      case AppLifecycleState.paused:
        JobsPrint('🟡 onPaused');
        break;
      case AppLifecycleState.detached:
        JobsPrint('🔴 onDetached');
        break;
      default:
        break;
    }
  }
}
