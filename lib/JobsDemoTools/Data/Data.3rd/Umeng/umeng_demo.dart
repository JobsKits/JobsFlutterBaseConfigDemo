import 'dart:async';

import 'package:flutter/material.dart';

import 'umeng_demo_page.dart';
import 'umeng_demo_service.dart';

/// 独立入口：flutter run -t lib/JobsDemoTools/Data/Data.3rd/Umeng/umeng_demo.dart
void main() {
  UmengDemoService? service;
  runZonedGuarded(() {
    // Binding 与 runApp 始终在同一个 Zone；SDK 在页面授权后再创建。
    WidgetsFlutterBinding.ensureInitialized();
    final demoService = UmengDemoService();
    service = demoService;
    runApp(UmengDemoApp(service: demoService));
  }, (error, stack) {
    service?.handleUnhandled(error, stack);
  });
}

class UmengDemoApp extends StatefulWidget {
  const UmengDemoApp({super.key, required this.service});
  final UmengDemoService service;

  @override
  State<UmengDemoApp> createState() => _UmengDemoAppState();
}

class _UmengDemoAppState extends State<UmengDemoApp> {
  ThemeMode _themeMode = ThemeMode.system;
  late final _observer = UmengDemoPageObserver(widget.service);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '友盟统计与崩溃演示',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2456A6)),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2456A6),
          brightness: Brightness.dark,
        ),
      ),
      themeMode: _themeMode,
      navigatorObservers: [_observer],
      builder: (context, child) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(child: child!),
          Material(
            color: Theme.of(context).colorScheme.surface,
            child: SafeArea(
              top: false,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final entry in const {
                      ThemeMode.system: '主题：跟随系统',
                      ThemeMode.light: '主题：白天',
                      ThemeMode.dark: '主题：黑夜',
                    }.entries)
                      ChoiceChip(
                        label: Text(entry.value),
                        selected: _themeMode == entry.key,
                        onSelected: (_) {
                          setState(() => _themeMode = entry.key);
                        },
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      home: UmengDemoPage(service: widget.service),
    );
  }
}
