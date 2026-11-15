import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jobs_demo_foundation/jobs_demo_foundation.dart';

/// 为旧 GetView 提供与页面等长的 Controller 生命周期，不清空其它 Demo 的注册。
class LegacyControllerScope<T extends GetxController> extends StatefulWidget {
  const LegacyControllerScope({
    super.key,
    required this.create,
    required this.builder,
  });
  final T Function() create;
  final WidgetBuilder builder;
  @override
  State<LegacyControllerScope<T>> createState() =>
      _LegacyControllerScopeState<T>();
}

class _LegacyControllerScopeState<T extends GetxController>
    extends State<LegacyControllerScope<T>> {
  T? owned;
  @override
  void initState() {
    super.initState();
    if (!Get.isRegistered<T>()) owned = Get.put<T>(widget.create());
  }

  @override
  void dispose() {
    if (owned != null &&
        Get.isRegistered<T>() &&
        identical(Get.find<T>(), owned)) {
      Get.delete<T>();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.builder(context);
}

/// 仅用于需要 Get 导航的独立入口；宿主直接构建页面，不嵌套第二个 App。
class LegacyGetDemoApp extends StatefulWidget {
  const LegacyGetDemoApp({
    super.key,
    required this.title,
    required this.builder,
  });
  final String title;
  final WidgetBuilder builder;
  @override
  State<LegacyGetDemoApp> createState() => _LegacyGetDemoAppState();
}

class _LegacyGetDemoAppState extends State<LegacyGetDemoApp> {
  final settings = JobsDemoSettings();
  Locale? previousLocale;
  void updateLocale() {
    if (previousLocale == settings.locale) return;
    previousLocale = settings.locale;
    Get.updateLocale(settings.locale);
  }

  @override
  void initState() {
    super.initState();
    settings.addListener(updateLocale);
    settings.init();
  }

  @override
  void dispose() {
    settings.removeListener(updateLocale);
    settings.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => JobsDemoScope(
    settings: settings,
    child: ListenableBuilder(
      listenable: settings,
      builder: (_, __) => GetMaterialApp(
        debugShowCheckedModeBanner: false,
        title: widget.title,
        theme: jobsDemoTheme(Brightness.light),
        darkTheme: jobsDemoTheme(Brightness.dark),
        themeMode: settings.themeMode,
        locale: settings.locale,
        supportedLocales: jobsDemoLocales,
        localizationsDelegates: jobsDemoLocalizationDelegates,
        home: Builder(
          builder: (context) => Scaffold(
            body: widget.builder(context),
            bottomNavigationBar: SafeArea(
              top: false,
              child: TextButton(
                onPressed: () => showModalBottomSheet<void>(
                  context: context,
                  isScrollControlled: true,
                  builder: (_) => JobsDemoScope(
                    settings: settings,
                    child: const JobsDemoSettingsPanel(),
                  ),
                ),
                child: Text(tr(context, '演示设置')),
              ),
            ),
          ),
        ),
      ),
    ),
  );
}
