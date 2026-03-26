import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jobs_runners/jobs_runners.dart';
import 'package:jobs_flutter_base_config/JobsDemoTools/UI/UI.Origin🌍/TabBar切换/Common/MyTabCtrl.dart';
import 'package:jobs_flutter_base_config/core/app_config.dart';
import 'package:jobs_flutter_base_config/pages/Others/Pages.dart';

final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();

void main() => runApp(JobsGetRunner(
    PageA(
      onTap: () {
        if (Get.isRegistered<MyTabCtrl>()) {
          Get.find<MyTabCtrl>().changeTabIndex(1); // 跳转到 PageB tab
        }
        Get.to(() => const PageB()); // 👈 免路由表跳转
      },
      buttonChild: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.arrow_forward),
          SizedBox(width: 8),
          Text('跳转到 B 页面'.tr),
        ],
      ),
    ),
    navigatorObservers: [routeObserver],
    title: '路由变化的监听测试'.tr));

/// 自定义路由监听器
class JobsRouteObserver extends NavigatorObserver {
  @override
  void didPush(Route route, Route? previousRoute) {
    super.didPush(route, previousRoute);
    debugLog('🟢 Push -> ${route.settings.name}');
  }

  @override
  void didPop(Route route, Route? previousRoute) {
    super.didPop(route, previousRoute);
    debugLog('🔴 Pop <- ${route.settings.name}');
  }

  @override
  void didRemove(Route route, Route? previousRoute) {
    super.didRemove(route, previousRoute);
    debugLog('🗑 Remove -> ${route.settings.name}');
  }

  @override
  void didReplace({Route? newRoute, Route? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    debugLog('🔁 Replace -> ${newRoute?.settings.name}');
  }
}
