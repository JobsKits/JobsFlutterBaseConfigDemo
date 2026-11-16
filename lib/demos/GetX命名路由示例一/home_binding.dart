import 'package:get/get.dart';
import 'package:jobs_flutter_base_config/JobsDemoTools/Data/Data.3rd/GetXDemo/GetX_RouteDemo/GetX_RouteDemo1/home_controller.dart';

// 定义了如何注入HomeController
class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HomeController>(() => HomeController());
    // 你可以在这里添加更多的依赖
  }
}
