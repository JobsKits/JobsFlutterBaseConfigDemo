import 'package:get/get.dart';
import 'package:jobs_flutter_base_config/JobsDemoTools/UI/UI.Origin🌍/TabBar切换/Common/MyTabCtrl.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MyTabCtrl>(() => MyTabCtrl());
  }
}
