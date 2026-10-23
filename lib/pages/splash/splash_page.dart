import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'splash_view.dart';

class SplashPage extends StatelessWidget {
  const SplashPage({super.key});
  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(1125, 2436), // ✅ UI 设计稿的尺寸（宽 x 高），一般来自 AppConfig
      minTextAdapt: true, // ✅ 启用字体最小适配
      splitScreenMode: true,
      rebuildFactor: RebuildFactors.change,
      builder: (_, __) => const SplashView(), // ✅ 真正展示的页面
    );
  }
}
