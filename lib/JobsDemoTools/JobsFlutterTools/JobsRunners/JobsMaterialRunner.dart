import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get_utils/src/extensions/export.dart';
// import 'package:google_fonts/google_fonts.dart' show GoogleFonts;

// import 'package:jobs_flutter_base_config/JobsDemoTools/JobsFlutterTools/JobsRunners/JobsMaterialRunner.dart';// 公共测试器路径
// void main() => runApp(const JobsMaterialRunner(CustomOverlayDemo(),title:'XXX'));
// void main() {
//   runApp(JobsMaterialRunner.builder(
//     title: 'Flutter Bloc Demo',
//     builder: (ctx) {
//       return BlocProvider(
//         create: (_) => CounterBloc(),
//         child: const CounterPage(),
//       );
//     },
//   ));
// }

/// 通用组件测试器(Android 风格)，自动生成可运行页面
/// 通用组件测试器：支持 child 和 builder 两种形式
/// ScreenUtilInit 只能搭配 MaterialApp 使用，不支持其他组件
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
        designSize: const Size(1125, 2436), // ← 设计稿尺寸
        minTextAdapt: true, // ← 修复 _minTextAdapt 初始化报错
        child: child,
        builder: (context, _) => MaterialApp(
          debugShowCheckedModeBanner: false,
          title: title ?? (child?.runtimeType.toString() ?? 'Builder'),
          theme: ThemeData(
            useMaterial3: true,// Material Design 3 (Material You)
            primarySwatch: Colors.blue,
            colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.blue)
                .copyWith(secondary: Colors.orange),
            // textTheme: GoogleFonts.latoTextTheme(
            //   Theme.of(context).textTheme,
            // ),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
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
