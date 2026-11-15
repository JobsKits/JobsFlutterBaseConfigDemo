import 'dart:async';

import 'legacy_strings.dart';
export 'legacy_strings.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:jobs_demo_foundation/jobs_demo_foundation.dart';
import 'package:jobs_runners/jobs_runners.dart';

const _captureKey = #jobsLegacyAppCapture;
const _logKey = #jobsLegacyLogCapture;
const _disposeKey = #jobsLegacyDispose;

/// 旧 main 的页面参数在局部构建，不在宿主中再次调用全局 runApp。
void legacyCaptureApp(Widget page) {
  final capture = Zone.current[_captureKey] as void Function(Widget)?;
  if (capture == null) throw StateError('旧入口需要由 LegacyLaunchPage 执行');
  capture(page);
}

void launchLegacyStandalone(
  Function action, {
  required String title,
  bool supportsWeb = true,
  List<TargetPlatform>? supportedPlatforms,
}) {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    JobsDemoApp(
      title: title,
      home: LegacyLaunchPage(
        action: action,
        title: title,
        supportsWeb: supportsWeb,
        supportedPlatforms: supportedPlatforms,
      ),
    ),
  );
}

class LegacyLaunchPage extends StatefulWidget {
  const LegacyLaunchPage({
    super.key,
    required this.action,
    required this.title,
    this.onDispose,
    this.supportsWeb = true,
    this.supportedPlatforms,
  });
  final Function action;
  final String title;
  final VoidCallback? onDispose;
  final bool supportsWeb;
  final List<TargetPlatform>? supportedPlatforms;
  @override
  State<LegacyLaunchPage> createState() => _LegacyLaunchPageState();
}

class _LegacyLaunchPageState extends State<LegacyLaunchPage> {
  Widget? root;
  Object? error;
  bool loading = true;
  final logs = <String>[];
  int generation = 0;
  final timers = <Timer>{};
  final disposers = <VoidCallback>[];
  bool logUpdatePending = false;

  void releaseResources() {
    for (final timer in timers) {
      timer.cancel();
    }
    timers.clear();
    for (final close in disposers.reversed) {
      close();
    }
    disposers.clear();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => execute());
  }

  bool get allowed => kIsWeb
      ? widget.supportsWeb
      : widget.supportedPlatforms == null ||
            widget.supportedPlatforms!.contains(defaultTargetPlatform);

  Future<void> execute() async {
    if (!mounted || !allowed) return;
    releaseResources();
    final run = ++generation;
    setState(() {
      loading = true;
      error = null;
      root = null;
      logs.clear();
    });

    void notify() {
      if (logUpdatePending) return;
      logUpdatePending = true;
      scheduleMicrotask(() {
        logUpdatePending = false;
        if (mounted && run == generation) setState(() {});
      });
    }

    void record(String? text, {int? wrapWidth}) {
      if (text == null || !mounted || run != generation) return;
      logs.add(text);
      if (logs.length > 300) logs.removeAt(0);
      notify();
    }

    try {
      await runZoned(
        () async {
          final result = Function.apply(widget.action, const []);
          if (result is Future) await result;
        },
        zoneValues: {
          _captureKey: (Widget value) {
            if (mounted && run == generation) {
              root = value;
              notify();
            }
          },
          _logKey: record,
          _disposeKey: (VoidCallback close) {
            if (mounted && run == generation) {
              disposers.add(close);
            } else {
              close();
            }
          },
        },
        zoneSpecification: ZoneSpecification(
          print: (_, _, _, line) => record(line),
          createTimer: (self, parent, zone, duration, callback) {
            final timer = parent.createTimer(zone, duration, () {
              if (mounted && run == generation) callback();
            });
            if (mounted && run == generation) {
              timers.add(timer);
            } else {
              timer.cancel();
            }
            return timer;
          },
          createPeriodicTimer: (self, parent, zone, duration, callback) {
            final timer = parent.createPeriodicTimer(zone, duration, (timer) {
              if (mounted && run == generation) {
                callback(timer);
              } else {
                timer.cancel();
              }
            });
            if (mounted && run == generation) {
              timers.add(timer);
            } else {
              timer.cancel();
            }
            return timer;
          },
        ),
      );
    } catch (value, stack) {
      error = value;
      record('$value\n$stack');
    } finally {
      if (mounted && run == generation) setState(() => loading = false);
    }
  }

  @override
  void dispose() {
    generation++;
    releaseResources();
    widget.onDispose?.call();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    legacyDisplayLocale =
        Localizations.maybeLocaleOf(context) ??
        JobsDemoScope.maybeOf(context)?.locale ??
        const Locale('zh');
    if (!allowed)
      return Scaffold(
        appBar: AppBar(title: LegacyText(widget.title)),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.devices, size: 48),
                const SizedBox(height: 16),
                Text(tr(context, '当前平台不支持此设备功能')),
                const SizedBox(height: 16),
                Text(
                  widget.supportedPlatforms?.map((e) => e.name).join(' / ') ??
                      '',
                ),
                TextButton(
                  onPressed: execute,
                  child: Text(tr(context, '重新加载')),
                ),
              ],
            ),
          ),
        ),
      );
    if (root != null) {
      return ScreenUtilInit(
        designSize: const Size(1125, 2436),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (context, _) => _LegacyRoot(root: root!, title: widget.title),
      );
    }
    return Scaffold(
      appBar: AppBar(title: LegacyText(widget.title)),
      body: Column(
        children: [
          if (loading) const LinearProgressIndicator(),
          if (error != null)
            ListTile(
              key: const ValueKey('legacy-launch-error'),
              leading: const Icon(Icons.error_outline),
              title: Text(tr(context, '失败')),
              subtitle: Text('$error'),
            ),
          Expanded(
            child: logs.isEmpty
                ? Center(child: Text(tr(context, loading ? '运行中' : '无数据')))
                : SelectionArea(
                    child: ListView(
                      padding: const EdgeInsets.all(16),
                      children: [
                        for (final line in logs)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Text(line),
                          ),
                      ],
                    ),
                  ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: FilledButton(
                onPressed: loading ? null : execute,
                child: Text(tr(context, '开始')),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LegacyRoot extends StatelessWidget {
  const _LegacyRoot({required this.root, required this.title});
  final Widget root;
  final String title;
  @override
  Widget build(BuildContext context) {
    legacyDisplayLocale =
        Localizations.maybeLocaleOf(context) ??
        JobsDemoScope.maybeOf(context)?.locale ??
        const Locale('zh');
    Widget page = root;
    if (page is JobsMaterialRunner) {
      page = page.builder?.call(context) ?? page.child ?? const SizedBox();
    } else if (page is JobsGetRunner) {
      page.bindings?.dependencies();
      page = page.builder?.call(context) ?? page.child ?? const SizedBox();
    } else if (page is JobsCupertinoRunner) {
      page = page.builder?.call(context) ?? page.child ?? const SizedBox();
    } else if (page is GetMaterialApp) {
      page.initialBinding?.dependencies();
      if (page.home != null) {
        page = page.home!;
      } else if (page.getPages?.isNotEmpty ?? false) {
        final app = page;
        final route = app.getPages!.firstWhere(
          (e) => e.name == app.initialRoute,
          orElse: () => app.getPages!.first,
        );
        route.binding?.dependencies();
        page = route.page();
      }
    } else if (page is MaterialApp && page.home != null) {
      page = page.home!;
    } else if (page is CupertinoApp && page.home != null) {
      page = page.home!;
    }
    return Scaffold(
      appBar: AppBar(title: LegacyText(title)),
      body: SafeArea(child: page),
    );
  }
}

/// 给教学应用根建立局部 Navigator，同时继承宿主主题与语言。
class LegacyAppBoundary extends StatefulWidget {
  const LegacyAppBoundary({super.key, required this.app});
  final Widget app;
  @override
  State<LegacyAppBoundary> createState() => _LegacyAppBoundaryState();
}

class _LegacyAppBoundaryState extends State<LegacyAppBoundary> {
  final navigation = _LegacyNavigation();
  Map<String, Map<String, String>>? previousTranslations;
  @override
  void initState() {
    super.initState();
    _legacyNavigators.add(navigation);
    final app = widget.app;
    if (app is GetMaterialApp && app.translations != null) {
      previousTranslations = {
        for (final e in Get.translations.entries)
          e.key: Map<String, String>.from(e.value),
      };
      Get.addTranslations(app.translations!.keys);
    }
  }

  @override
  void didUpdateWidget(LegacyAppBoundary oldWidget) {
    super.didUpdateWidget(oldWidget);
    final previous = oldWidget.app;
    final current = widget.app;
    ThemeMode? previousMode, currentMode;
    Locale? previousLocale, currentLocale;
    Brightness? previousBrightness, currentBrightness;
    if (previous is MaterialApp) {
      previousMode = previous.themeMode;
      previousLocale = previous.locale;
      previousBrightness = previous.theme?.brightness;
    }
    if (current is MaterialApp) {
      currentMode = current.themeMode;
      currentLocale = current.locale;
      currentBrightness = current.theme?.brightness;
    }
    if (previous is GetMaterialApp) {
      previousMode = previous.themeMode;
      previousLocale = previous.locale;
      previousBrightness = previous.theme?.brightness;
    }
    if (current is GetMaterialApp) {
      currentMode = current.themeMode;
      currentLocale = current.locale;
      currentBrightness = current.theme?.brightness;
    }
    if (previousMode != currentMode ||
        previousLocale != currentLocale ||
        previousBrightness != currentBrightness) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        final settings = JobsDemoScope.maybeOf(context);
        if (previousMode != currentMode && currentMode != null)
          settings?.setThemeMode(currentMode);
        else if (previousBrightness != currentBrightness &&
            currentBrightness != null)
          settings?.setThemeMode(
            currentBrightness == Brightness.dark
                ? ThemeMode.dark
                : ThemeMode.light,
          );
        if (previousLocale != currentLocale && currentLocale != null)
          settings?.setLocale(currentLocale);
      });
    }
  }

  @override
  void dispose() {
    _legacyNavigators.remove(navigation);
    if (previousTranslations != null) {
      Get.clearTranslations();
      Get.addTranslations(previousTranslations!);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    legacyDisplayLocale =
        Localizations.maybeLocaleOf(context) ??
        JobsDemoScope.maybeOf(context)?.locale ??
        const Locale('zh');
    final settings = JobsDemoScope.maybeOf(context);
    navigation.settings = settings;
    final value = widget.app;
    if (value is MaterialApp) {
      return MaterialApp(
        navigatorKey: navigation.key,
        debugShowCheckedModeBanner: false,
        theme: settings == null
            ? value.theme ?? Theme.of(context)
            : jobsDemoTheme(Brightness.light),
        darkTheme: settings == null
            ? value.darkTheme ?? Theme.of(context)
            : jobsDemoTheme(Brightness.dark),
        themeMode: settings?.themeMode ?? value.themeMode,
        locale:
            settings?.locale ??
            Localizations.maybeLocaleOf(context) ??
            value.locale ??
            const Locale('zh'),
        supportedLocales: jobsDemoLocales,
        localizationsDelegates: [
          ...?value.localizationsDelegates,
          ...jobsDemoLocalizationDelegates,
        ],
        home: value.home,
        routes: value.routes ?? const {},
        initialRoute: value.initialRoute,
        onGenerateRoute: value.onGenerateRoute,
        onUnknownRoute: value.onUnknownRoute,
        navigatorObservers: value.navigatorObservers ?? const [],
        builder: value.builder,
      );
    }
    if (value is GetMaterialApp) {
      final locale =
          settings?.locale ??
          Localizations.maybeLocaleOf(context) ??
          value.locale ??
          const Locale('zh');
      Get.locale = Locale(
        locale.languageCode,
        locale.scriptCode ?? locale.countryCode,
      );
      value.initialBinding?.dependencies();
      Route<dynamic>? routeFactory(RouteSettings route) {
        for (final page in value.getPages ?? <GetPage>[]) {
          final expected = page.name.split('/');
          final actual = route.name?.split('/') ?? [];
          if (expected.length != actual.length) continue;
          final parameters = <String, String>{};
          var matches = true;
          for (var i = 0; i < expected.length; i++) {
            if (expected[i].startsWith(':')) {
              parameters[expected[i].substring(1)] = actual[i];
            } else if (expected[i] != actual[i]) {
              matches = false;
              break;
            }
          }
          if (!matches) continue;
          return MaterialPageRoute<dynamic>(
            settings: route,
            builder: (_) {
              navigation.arguments = route.arguments;
              navigation.parameters = parameters;
              page.binding?.dependencies();
              return page.page();
            },
          );
        }
        return value.onGenerateRoute?.call(route);
      }

      return MaterialApp(
        navigatorKey: navigation.key,
        debugShowCheckedModeBanner: false,
        theme: settings == null
            ? value.theme ?? Theme.of(context)
            : jobsDemoTheme(Brightness.light),
        darkTheme: settings == null
            ? value.darkTheme ?? Theme.of(context)
            : jobsDemoTheme(Brightness.dark),
        themeMode: settings?.themeMode ?? value.themeMode,
        locale:
            settings?.locale ??
            Localizations.maybeLocaleOf(context) ??
            value.locale ??
            const Locale('zh'),
        supportedLocales: jobsDemoLocales,
        localizationsDelegates: [
          ...?value.localizationsDelegates,
          ...jobsDemoLocalizationDelegates,
        ],
        home: value.home,
        routes: value.routes ?? const {},
        initialRoute: value.initialRoute,
        onGenerateRoute: routeFactory,
        onUnknownRoute: value.onUnknownRoute,
        navigatorObservers: value.navigatorObservers ?? const [],
        builder: value.builder,
      );
    }
    if (value is CupertinoApp) {
      return CupertinoApp(
        navigatorKey: navigation.key,
        debugShowCheckedModeBanner: false,
        theme: CupertinoThemeData(brightness: Theme.of(context).brightness),
        locale: settings?.locale,
        supportedLocales: jobsDemoLocales,
        localizationsDelegates: [
          ...?value.localizationsDelegates,
          ...jobsDemoLocalizationDelegates,
        ],
        home: value.home,
        routes: value.routes ?? const {},
        initialRoute: value.initialRoute,
        onGenerateRoute: value.onGenerateRoute,
        onUnknownRoute: value.onUnknownRoute,
        navigatorObservers: value.navigatorObservers ?? const [],
        builder: value.builder,
      );
    }
    return value;
  }
}

void legacyLog(Object? value, {String name = ''}) =>
    legacyDebugPrint(name.isEmpty ? '$value' : '$name: $value');

void legacyDebugPrint(String? message, {int? wrapWidth}) {
  final sink =
      Zone.current[_logKey] as void Function(String?, {int? wrapWidth})?;
  if (sink != null) {
    sink(message, wrapWidth: wrapWidth);
  } else {
    debugPrint(message, wrapWidth: wrapWidth);
  }
}

Image legacyNetworkImage(
  String url, {
  double? width,
  double? height,
  BoxFit? fit,
  ImageLoadingBuilder? loadingBuilder,
  ImageErrorWidgetBuilder? errorBuilder,
  Map<String, String>? headers,
  Color? color,
  BlendMode? colorBlendMode,
  AlignmentGeometry alignment = Alignment.center,
  ImageRepeat repeat = ImageRepeat.noRepeat,
  bool gaplessPlayback = false,
  String? semanticLabel,
  bool excludeFromSemantics = false,
  FilterQuality filterQuality = FilterQuality.medium,
  bool matchTextDirection = false,
}) => Image.network(
  url,
  width: width,
  height: height,
  fit: fit,
  headers: headers,
  color: color,
  colorBlendMode: colorBlendMode,
  alignment: alignment,
  repeat: repeat,
  gaplessPlayback: gaplessPlayback,
  semanticLabel: semanticLabel,
  excludeFromSemantics: excludeFromSemantics,
  filterQuality: filterQuality,
  matchTextDirection: matchTextDirection,
  loadingBuilder: loadingBuilder,
  errorBuilder:
      errorBuilder ??
      (_, _, _) => Image.asset(
        'assets/Images/flower.png',
        width: width,
        height: height,
        fit: fit,
      ),
);

void legacyOnDispose(VoidCallback callback) {
  final register = Zone.current[_disposeKey] as void Function(VoidCallback)?;
  register?.call(callback);
}

final _legacyNavigators = <_LegacyNavigation>[];

void legacyChangeLocale(Locale locale) {
  final resolved = jobsDemoLocales.firstWhere(
    (e) =>
        e.languageCode == locale.languageCode &&
        (e.scriptCode == locale.scriptCode ||
            (e.scriptCode == null && locale.scriptCode == null)),
    orElse: () => locale,
  );
  if (_legacyNavigators.isNotEmpty)
    _legacyNavigators.last.settings?.setLocale(resolved);
  Get.locale = Locale(
    resolved.languageCode,
    resolved.scriptCode ?? resolved.countryCode,
  );
}

class _LegacyNavigation {
  JobsDemoSettings? settings;
  final key = GlobalKey<NavigatorState>();
  Object? arguments;
  Map<String, String> parameters = {};
}

dynamic get legacyRouteArguments =>
    _legacyNavigators.isEmpty ? null : _legacyNavigators.last.arguments;
Map<String, String> get legacyRouteParameters =>
    _legacyNavigators.isEmpty ? {} : _legacyNavigators.last.parameters;
Future<T?>? legacyToNamed<T>(String route, {Object? arguments}) =>
    _legacyNavigators.last.key.currentState?.pushNamed<T>(
      route,
      arguments: arguments,
    );
Future<T?>? legacyOffAllNamed<T>(String route, {Object? arguments}) =>
    _legacyNavigators.last.key.currentState?.pushNamedAndRemoveUntil<T>(
      route,
      (_) => false,
      arguments: arguments,
    );
void legacyBack<T>({T? result}) {
  final navigator = _legacyNavigators.isEmpty
      ? null
      : _legacyNavigators.last.key.currentState;
  if (navigator?.canPop() ?? false) {
    navigator!.pop<T>(result);
  } else {
    Get.back<T>(result: result);
  }
}
