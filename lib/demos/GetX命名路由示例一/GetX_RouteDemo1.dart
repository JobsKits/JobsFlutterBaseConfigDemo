// 独立运行：flutter run -t "lib/demos/GetX命名路由示例一/GetX_RouteDemo1.dart"
// 使用本工程 pubspec.yaml 声明的依赖与资源。

import 'package:jobs_flutter_base_config/demo_hub/legacy_launch.dart';
import 'package:get/get.dart';
import 'package:jobs_flutter_base_config/JobsDemoTools/Data/Data.3rd/GetXDemo/GetX_RouteDemo/GetX_RouteDemo1/home_binding.dart';
import 'package:jobs_flutter_base_config/JobsDemoTools/Data/Data.3rd/GetXDemo/GetX_RouteDemo/GetX_RouteDemo1/home_view.dart';
import 'package:flutter/material.dart';

/// 独立运行与目录预览共用同一份原始教学逻辑。
void main() => launchLegacyStandalone(legacyOriginalMain, title: 'GetX命名路由示例一');

// 使用GetMaterialApp设置路由，并将HomeBinding和HomeView关联起来
// 将page和binding分开有几个好处：
// 关注点分离：page只负责UI，binding只负责依赖注入和状态管理。这样使得代码更加模块化和可维护。
// 懒加载：binding允许依赖在需要的时候才加载（比如通过Get.lazyPut）。这样可以提升应用性能，避免不必要的资源消耗。
// 更好的测试性：将依赖注入逻辑和UI逻辑分开，使得每一部分更容易测试。你可以单独测试Controller和其他逻辑，而不必依赖于UI部分。
// 复用性：相同的binding可以在不同的页面中复用。这样你可以创建共享的依赖逻辑，不需要在每个页面中重复编写相同的注入代码。
// binding参数是一个继承自Bindings的类实例。见：class HomeBinding extends Bindings
// 它的主要职责是依赖注入，包括Controller、Repository、Bloc、ViewModel等。
// GetX的依赖注入是通过binding实现的。在GetX中，binding用于在页面初始化时，将Controller、Repository和其他依赖项注入到页面中
void legacyOriginalMain() {
  legacyCaptureApp(
    LegacyAppBoundary(
      app: GetMaterialApp(
        initialRoute: '/',
        getPages: [
          GetPage(
            name: '/',
            page: () => const HomeView(),
            binding: HomeBinding(),
          ),
        ],
      ),
    ),
  );
}

Widget buildLegacyDemo(BuildContext context) =>
    LegacyLaunchPage(action: legacyOriginalMain, title: 'GetX_RouteDemo1');
