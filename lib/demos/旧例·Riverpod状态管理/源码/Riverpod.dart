import 'package:jobs_flutter_base_config/demo_hub/legacy_launch.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// 🚀 入口点：用 ProviderScope 包裹整个 App
void legacyOriginalMain() {
  legacyCaptureApp(const ProviderScope(child: MyApp()));
}

// ===================== 🧱 状态模型 =====================
class CounterModel extends StateNotifier<int> {
  CounterModel() : super(0);

  void increment() => state++;
}

class ThemeModel extends StateNotifier<bool> {
  ThemeModel() : super(false);

  void toggleTheme() => state = !state;
}

// ===================== 📦 Riverpod Provider 定义 =====================
final counterProvider = StateNotifierProvider<CounterModel, int>(
  (ref) => CounterModel(),
);
final themeProvider = StateNotifierProvider<ThemeModel, bool>(
  (ref) => ThemeModel(),
);

// ===================== 🌎 App =====================
class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = ref.watch(themeProvider);

    return LegacyAppBoundary(
      app: MaterialApp(
        theme: ThemeData.light(),
        darkTheme: ThemeData.dark(),
        themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
        home: const HomePage(),
      ),
    );
  }
}

// ===================== 🏠 HomePage =====================
class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const LegacyText('Riverpod 全演示 Demo'),
        actions: [
          IconButton(
            icon: const Icon(Icons.brightness_6),
            onPressed: () => ref.read(themeProvider.notifier).toggleTheme(),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            CounterLabel(),
            CounterDisplay(),
            SizedBox(height: 30),
            ConsumerWidgetDemo(),
            SizedBox(height: 30),
            SelectWidgetDemo(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => ref.read(counterProvider.notifier).increment(),
        child: const Icon(Icons.add),
      ),
    );
  }
}

// ===================== 🎯 Sub Widgets =====================

class CounterDisplay extends ConsumerWidget {
  const CounterDisplay({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final count = ref.watch(counterProvider);
    return LegacyText(
      '$count',
      style: Theme.of(context).textTheme.displayMedium,
    );
  }
}

class CounterLabel extends StatelessWidget {
  const CounterLabel({super.key});

  @override
  Widget build(BuildContext context) {
    legacyDebugPrint('CounterLabel rebuild');
    return const LegacyText('你点击了按钮的次数是：', style: TextStyle(fontSize: 18));
  }
}

// 🎯 Consumer 用法演示
class ConsumerWidgetDemo extends ConsumerWidget {
  const ConsumerWidgetDemo({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final count = ref.watch(counterProvider);

    return Column(
      children: [
        const LegacyText('（通过 ConsumerWidget 监听）'),
        LegacyText('$count', style: Theme.of(context).textTheme.displayMedium),
      ],
    );
  }
}

// 🎯 select 精准监听用法
class SelectWidgetDemo extends ConsumerWidget {
  const SelectWidgetDemo({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = ref.watch(themeProvider.select((value) => value));

    return Column(
      children: [
        const LegacyText('（通过 select 精准监听 isDark）'),
        LegacyText('当前主题：${isDark ? '🌙 暗色' : '☀️ 亮色'}'),
      ],
    );
  }
}

/// 独立运行与目录预览共用同一份原始教学逻辑。
void main() =>
    launchLegacyStandalone(legacyOriginalMain, title: '旧例·Riverpod状态管理');
