import 'dart:async';

import 'package:dart_ping_ios/dart_ping_ios.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_plugin_engagelab/flutter_plugin_engagelab.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:jobs_flutter_base_config/JobsDemoTools/Data/Data.3rd/本地数据存取/sp_util.dart';
import 'package:jobs_flutter_base_config/JobsDemoTools/JobsFlutterTools/调试/JobsCommonUtil.dart';
import 'package:jobs_flutter_base_config/JobsDemoTools/Utils/AppLifecycleCtrl.dart';
import 'package:jobs_flutter_base_config/JobsDemoTools/Utils/AppNavigatorObserver.dart';
import 'package:jobs_flutter_base_config/JobsDemoTools/Utils/CommonColor.dart';
import 'package:provider/provider.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:wakelock_plus/wakelock_plus.dart';

import 'core/app_initializer.dart';
import 'notifier/locale_notifier.dart';
import 'pages/Splash/splash_page.dart';
import 'routes/app_pages.dart';
import 'services/theme_service.dart';
import 'utils/global_observer.dart';

// Future<void> main() async{SystemChrome->}
// runApp(MultiProvider.child(JobsApp(StatelessWidget)))->
// GestureDetector->
// Consumer<LocaleNotifier>->
// GetMaterialApp->
// SplashPage()

Future<void> main() async {
  FlutterError.onError = (FlutterErrorDetails details) {
    // 打印错误到控制台
    FlutterError.dumpErrorToConsole(details);
    JobsPrint(details.toString());
    // JobsPrint(details.exception.toString());
    // JobsPrint(details.stack.toString());
    // JobsPrint(details.exceptionAsString().toString());
  };

  /// 初始化时区数据库
  tz.initializeTimeZones();

  // 设置状态栏样式
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.white, // 状态栏背景颜色
    statusBarIconBrightness: Brightness.dark, // 状态栏图标颜色（黑色）
    statusBarBrightness: Brightness.light, // 适用于iOS

    systemNavigationBarColor: Colors.white, // 导航栏背景颜色
    systemNavigationBarIconBrightness: Brightness.dark, // 导航栏图标为黑色
    systemNavigationBarDividerColor: Colors.white, // 导航栏分割线颜色（可选）
  ));

  /// 用于确保Flutter框架已经初始化
  ///💥某些情况下可以省略，最新版本的Flutter中不需要显示调用，但是为了确保向下兼容，还是加上
  WidgetsFlutterBinding.ensureInitialized();

  DartPingIOS.register();
  SystemChrome.setPreferredOrientations([]).then((_) async {
    WakelockPlus.enable();
    Get.put(AppLifecycleCtrl()); // 注册生命周期监听

    String currentLanguage = SpUtil.getString("currentLanguageType") ?? "zh";
    final AppNavigatorObserver appNavigatorObserver = AppNavigatorObserver();

    runZonedGuarded(() {
      /// 跟随宿主声明的支持方向，开合设备时按当前窗口重新布局。
      SystemChrome.setPreferredOrientations([]).then((_) {
        runApp(
          ScreenUtilInit(
            designSize: const Size(1125, 2436), // 目前给到的设计图尺寸，如有变动，后续再改
            minTextAdapt: true,
            splitScreenMode: true,
            rebuildFactor: RebuildFactors.change,
            builder: (context, child) {
              return GetMaterialApp(
                  debugShowCheckedModeBanner: false,
                  title: '澳门'.tr,
                  navigatorObservers: [appNavigatorObserver],
                  localizationsDelegates: const [
                    GlobalMaterialLocalizations.delegate,
                    GlobalWidgetsLocalizations.delegate,
                    GlobalCupertinoLocalizations.delegate,
                  ],
                  // supportedLocales: supportedLocales,
                  // initialRoute: AppPages.INITIAL,
                  // initialBinding: MainBindings(),
                  // getPages: AppPages.routes,
                  // builder: EasyLoading.init(),
                  // translations: AppTranslations(),
                  locale: Locale(currentLanguage),
                  fallbackLocale: const Locale("en"));
            },
          ),
        );
      });
    }, (error, stackTrace) {
      /// 处理未捕获的异常
      JobsPrint(error.toString());
      JobsPrint(stackTrace.toString());
    });

    EasyLoading.instance
      ..indicatorType = EasyLoadingIndicatorType.fadingCircle
      ..loadingStyle = EasyLoadingStyle.custom
      ..backgroundColor = Colors.white
      ..indicatorColor = theme01MainColor
      ..textColor = theme01MainColor
      ..dismissOnTap = true; // 点击不能关闭加载框
    // ..maskType = EasyLoadingMaskType.custom
    // ..maskColor = Colors.black.withOpacity(0.1)
  });

  await AppInitializer.init();

  SystemChrome.setPreferredOrientations([]).then((_) {
    runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => LocaleNotifier()),
        ],
        child: const JobsApp(),
      ),
    );
  });

  // App 启动后将角标置为0
  FlutterPluginEngagelab.setNotificationBadge(0);
  FlutterPluginEngagelab.resetNotificationBadge();
}

class JobsApp extends StatelessWidget {
  const JobsApp({super.key});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Consumer<LocaleNotifier>(
        builder: (_, localeNotifier, __) {
          return GetMaterialApp(
            debugShowCheckedModeBanner: false,
            title: "Flutter 脚手架".tr,
            locale: localeNotifier.locale,
            fallbackLocale: const Locale("en"),
            theme: ThemeService.instance.lightTheme,
            darkTheme: ThemeService.instance.darkTheme,
            themeMode: ThemeService.instance.themeMode,
            getPages: AppPages.routes,
            initialRoute: AppPages.initial,
            navigatorObservers: [GlobalRouteObserver()],
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
            ],
            supportedLocales: const [Locale("en"), Locale("zh")],
            home: const SplashPage(),
          );
        },
      ),
    );
  }
}
