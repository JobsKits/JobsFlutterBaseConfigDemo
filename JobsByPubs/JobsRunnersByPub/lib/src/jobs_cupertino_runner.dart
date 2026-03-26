import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

/// 通用组件测试器（iOS / Cupertino 风格）
/// 支持 child 和 builder 两种形式
class JobsCupertinoRunner extends StatelessWidget {
  final Widget Function(BuildContext context)? builder;
  final Widget? child;
  final String? title;

  const JobsCupertinoRunner._internal({
    this.builder,
    this.child,
    this.title,
    super.key,
  });

  const JobsCupertinoRunner(Widget child, {String? title, Key? key})
      : this._internal(child: child, title: title, key: key);

  factory JobsCupertinoRunner.builder({
    required Widget Function(BuildContext context) builder,
    String? title,
    Key? key,
  }) =>
      JobsCupertinoRunner._internal(builder: builder, title: title, key: key);

  @override
  Widget build(BuildContext context) => ScreenUtilInit(
        designSize: const Size(1125, 2436),
        minTextAdapt: true,
        child: child,
        builder: (context, _) => CupertinoApp(
          debugShowCheckedModeBanner: false,
          theme: const CupertinoThemeData(
            primaryColor: CupertinoColors.activeBlue,
            textTheme: CupertinoTextThemeData(
              navTitleTextStyle: TextStyle(fontSize: 20),
            ),
          ),
          home: Builder(
            builder: (ctx) => CupertinoPageScaffold(
              navigationBar: CupertinoNavigationBar(
                middle:
                    Text(title ?? (child?.runtimeType.toString() ?? 'Builder')),
              ),
              child: SafeArea(
                child: builder != null
                    ? builder!(ctx)
                    : child ?? Center(child: Text('请传入 child 或 builder'.tr)),
              ),
            ),
          ),
        ),
      );
}
