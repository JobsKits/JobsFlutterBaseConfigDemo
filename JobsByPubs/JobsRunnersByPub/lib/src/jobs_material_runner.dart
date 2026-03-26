import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get_utils/src/extensions/export.dart';

/// 通用组件测试器（Android / Material 风格）
/// 支持 child 和 builder 两种形式
class JobsMaterialRunner extends StatelessWidget {
  final Widget Function(BuildContext context)? builder;
  final Widget? child;
  final String? title;

  const JobsMaterialRunner._internal({
    this.builder,
    this.child,
    this.title,
    super.key,
  });

  const JobsMaterialRunner(Widget child, {String? title, Key? key})
      : this._internal(child: child, title: title, key: key);

  factory JobsMaterialRunner.builder({
    required Widget Function(BuildContext context) builder,
    String? title,
    Key? key,
  }) =>
      JobsMaterialRunner._internal(builder: builder, title: title, key: key);

  @override
  Widget build(BuildContext context) => ScreenUtilInit(
        designSize: const Size(1125, 2436),
        minTextAdapt: true,
        child: child,
        builder: (context, _) => MaterialApp(
          debugShowCheckedModeBanner: false,
          title: title ?? (child?.runtimeType.toString() ?? 'Builder'),
          theme: ThemeData(
            useMaterial3: true,
            primarySwatch: Colors.blue,
            colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.blue)
                .copyWith(secondary: Colors.orange),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
            ),
            appBarTheme: const AppBarTheme(
              backgroundColor: Colors.blue,
              titleTextStyle: TextStyle(color: Colors.white, fontSize: 20),
            ),
          ),
          home: Builder(
            builder: (ctx) => Scaffold(
              appBar: AppBar(
                title:
                    Text(title ?? (child?.runtimeType.toString() ?? 'Builder')),
              ),
              body: Center(
                child: builder != null
                    ? builder!(ctx)
                    : child ?? Text('请传入 child 或 builder'.tr),
              ),
            ),
          ),
        ),
      );
}
