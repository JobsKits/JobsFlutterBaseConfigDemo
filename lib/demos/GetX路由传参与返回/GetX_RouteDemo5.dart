// 独立运行：flutter run -t "lib/demos/GetX路由传参与返回/GetX_RouteDemo5.dart"
// 使用本工程 pubspec.yaml 声明的依赖与资源。

import 'package:jobs_flutter_base_config/demo_hub/legacy_launch.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jobs_demo_foundation/jobs_demo_foundation.dart';

/// 独立运行与目录预览共用同一份原始教学逻辑。
void main() => launchLegacyStandalone(legacyOriginalMain, title: 'GetX路由传参与返回');

void legacyOriginalMain() {
  legacyCaptureApp(
    LegacyAppBoundary(
      app: GetMaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'GetX 路由大全',
        initialRoute: '/',
        getPages: [
          GetPage(name: '/', page: () => const HomePage()),
          GetPage(
            name: '/detail',
            page: () => const DetailPage(),
            transition: Transition.rightToLeft,
            transitionDuration: const Duration(milliseconds: 500),
          ),
          GetPage(name: '/profile/:userId', page: () => const ProfilePage()),
          GetPage(name: '/replacement', page: () => const ReplacePage()),
          GetPage(name: '/final', page: () => const FinalPage()),
        ],
      ),
    ),
  );
}

// 首页
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: JobsDemoAppBar(title: const LegacyText('🏠 Home Page')),
      body: Center(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            ElevatedButton(
              onPressed: () {
                Get.to(
                  () => const DetailPage(),
                  arguments: {'msg': '👋 普通跳转传参'},
                );
              },
              child: const LegacyText('Get.to → DetailPage（传 arguments）'),
            ),
            ElevatedButton(
              onPressed: () {
                legacyToNamed('/detail', arguments: {'msg': '📦 命名路由传参'});
              },
              child: const LegacyText('Get.toNamed → DetailPage（传 arguments）'),
            ),
            ElevatedButton(
              onPressed: () {
                legacyToNamed('/profile/12345');
              },
              child: const LegacyText('Get.toNamed → 动态路由 /profile/:userId'),
            ),
            ElevatedButton(
              onPressed: () {
                Get.off(() => const ReplacePage());
              },
              child: const LegacyText('Get.off → 替换当前页面111'),
            ),
            ElevatedButton(
              onPressed: () {
                Get.offAll(() => const FinalPage());
              },
              child: const LegacyText('Get.offAll → 替换所有页面'),
            ),
            ElevatedButton(
              onPressed: () {
                Get.to(
                  () => const DetailPage(),
                  arguments: {'msg': '等待返回值'},
                )!.then((value) {
                  if (value != null) {
                    Get.snackbar(
                      '收到返回',
                      value.toString(),
                      snackPosition: SnackPosition.BOTTOM,
                    );
                  }
                });
              },
              child: const LegacyText('Get.to → 等待返回值'),
            ),
            ElevatedButton(
              onPressed: () {
                legacyToNamed('/final');
              },
              child: const LegacyText('Get.to → 查看自定义返回键效果'),
            ),
          ],
        ),
      ),
    );
  }
}

// 普通页面
class DetailPage extends StatelessWidget {
  const DetailPage({super.key});
  @override
  Widget build(BuildContext context) {
    final msg = legacyRouteArguments?['msg'] ?? '无参数';
    return Scaffold(
      appBar: JobsDemoAppBar(title: const LegacyText('📄 Detail Page')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            LegacyText('接收到参数: $msg', style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => legacyBack(result: '✅ 这是 DetailPage 返回的值'),
              child: const LegacyText('返回并携带数据'),
            ),
          ],
        ),
      ),
    );
  }
}

// 动态路由页面 /profile/:userId
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});
  @override
  Widget build(BuildContext context) {
    final userId = legacyRouteParameters['userId'] ?? '未知';
    return Scaffold(
      appBar: JobsDemoAppBar(title: const LegacyText('👤 Profile Page')),
      body: Center(
        child: LegacyText(
          '动态参数 userId: $userId',
          style: const TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}

// 替换页面
class ReplacePage extends StatelessWidget {
  const ReplacePage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: JobsDemoAppBar(title: const LegacyText('🧩 Replace Page')),
      body: Center(
        child: ElevatedButton(
          onPressed: () => Get.offAll(() => const FinalPage()),
          child: const LegacyText('替换全部并跳到 FinalPage'),
        ),
      ),
    );
  }
}

// 最终页面(自定义返回键文字+图标，防止黑屏)
class FinalPage extends StatelessWidget {
  const FinalPage({super.key});
  void _safeBack(BuildContext context) {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    } else {
      legacyOffAllNamed('/'); // 无栈时安全跳回首页
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: JobsDemoAppBar(
        title: const LegacyText('Final Page'),
        leading: Padding(
          padding: const EdgeInsets.only(left: 12), // 控制左右边距
          child: GestureDetector(
            onTap: () => _safeBack(context),
            behavior: HitTestBehavior.opaque,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // ✅ 图标：可换成自定义图
                Image.asset('assets/Images/flower.png', width: 18, height: 18),
                const SizedBox(width: 4),
                const LegacyText(
                  '返回',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ],
            ),
          ),
        ),
      ),
      body: const Center(child: LegacyText('这里是最终页面')),
    );
  }
}

Widget buildLegacyDemo(BuildContext context) =>
    LegacyLaunchPage(action: legacyOriginalMain, title: 'GetX_RouteDemo5');
