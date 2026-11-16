import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart' show CupertinoIcons;
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:jobs_demo_foundation/jobs_demo_foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'catalog_repository.dart';
import 'home_layout.dart';
import 'home_strings.dart';
import 'home_floating_controls.dart';
import 'home_floating_strings.dart';
import 'world_clock_page.dart';

import 'interop_catalog.dart';
import 'interop_strings.dart';
import 'extra_catalog.dart';
import 'extra_strings.dart';
import 'legacy_catalog.dart';
import 'parallel_catalog.dart';
import 'native_catalog.dart';
import 'data_parity_catalog.dart';
import 'lab_strings.dart';
import 'ui_parity_catalog.dart';
import 'ui_parity_strings.dart';
import 'platform_catalog.dart';
import 'platform_strings.dart';
import 'curated_catalog.dart';
import 'geometry_strings.dart';
import 'interaction_strings.dart';
import 'workflow_strings.dart';
import 'render_strings.dart';
import '../demos/离线文字识别/识别文案.dart';

part 'home_page.dart';

class DemoHubApp extends StatefulWidget {
  const DemoHubApp({
    super.key,
    required this.settings,
    this.repository,
    this.splashDuration = const Duration(seconds: 2),
  });
  final JobsDemoSettings settings;
  final CatalogRepository? repository;
  final Duration splashDuration;
  @override
  State<DemoHubApp> createState() => _DemoHubAppState();
}

class _DemoHubAppState extends State<DemoHubApp> {
  late final repository = widget.repository ?? CatalogRepository();
  @override
  void initState() {
    super.initState();
    registerOCRTranslations();
    JobsDemoStrings.registerTranslations(homeTranslations);
    JobsDemoStrings.registerTranslations(homeFloatingTranslations);
    JobsDemoStrings.registerTranslations(labTranslations);
    JobsDemoStrings.registerTranslations(interopTranslations);
    JobsDemoStrings.registerTranslations(extraTranslations);
    JobsDemoStrings.registerTranslations(uiParityTranslations);
    JobsDemoStrings.registerTranslations(platformTranslations);
    registerGeometryTranslations();
    JobsDemoStrings.registerTranslations(interactionTranslations);
    JobsDemoStrings.registerTranslations(workflowTranslations);
    registerRenderTranslations();
    widget.settings.addListener(syncLocale);
  }

  void syncLocale() {
    if (Get.locale != widget.settings.locale) {
      unawaited(Get.updateLocale(widget.settings.locale));
    }
  }

  @override
  void dispose() {
    widget.settings.removeListener(syncLocale);
    if (widget.repository == null) repository.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => JobsDemoScope(
    settings: widget.settings,
    child: AnimatedBuilder(
      animation: widget.settings,
      builder: (context, _) => GetMaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Jobs Flutter',
        theme: jobsDemoTheme(Brightness.light),
        darkTheme: jobsDemoTheme(Brightness.dark),
        themeMode: widget.settings.themeMode,
        locale: widget.settings.locale,
        supportedLocales: jobsDemoLocales,
        localizationsDelegates: jobsDemoLocalizationDelegates,
        getPages: [
          GetPage(
            name: "/widget",
            page: () => platformDemos
                .firstWhere((e) => e.id == "platform-widget")
                .builder(context),
          ),
        ],
        home: DemoSplash(
          duration: widget.splashDuration,
          next: () => DemoHome(repository: repository),
        ),
      ),
    ),
  );
}

class DemoSplash extends StatefulWidget {
  const DemoSplash({
    super.key,
    required this.next,
    this.duration = const Duration(seconds: 2),
  });
  final Widget Function() next;
  final Duration duration;
  @override
  State<DemoSplash> createState() => _DemoSplashState();
}

class _DemoSplashState extends State<DemoSplash> {
  Timer? timer;
  bool leaving = false;
  @override
  void initState() {
    super.initState();
    timer = Timer(widget.duration, leave);
  }

  void leave() {
    if (!mounted || leaving) return;
    leaving = true;
    timer?.cancel();
    Navigator.of(
      context,
    ).pushReplacement(MaterialPageRoute<void>(builder: (_) => widget.next()));
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      key: const ValueKey('splash'),
      body: SafeArea(
        child: Stack(
          children: [
            Positioned(
              top: 12,
              right: 16,
              child: TextButton(
                onPressed: leave,
                child: Text(tr(context, '跳过')),
              ),
            ),
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Jobs',
                    style: Theme.of(context).textTheme.displayLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: colors.primary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Flutter',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    tr(context, '功能实验室'),
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 40),
                  FilledButton(
                    onPressed: leave,
                    child: Text(tr(context, '开始探索')),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SplashDone extends StatelessWidget {
  const _SplashDone();
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(tr(context, '开屏演示'))),
    body: Center(
      child: FilledButton(
        onPressed: () => Navigator.pop(context),
        child: Text(tr(context, '开始探索')),
      ),
    ),
  );
}
