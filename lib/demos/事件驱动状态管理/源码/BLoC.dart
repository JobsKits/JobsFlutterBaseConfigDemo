import 'package:jobs_flutter_base_config/demo_hub/legacy_launch.dart';
// main.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jobs_runners/jobs_runners.dart'; // 公共测试器路径
import 'package:jobs_flutter_base_config/JobsDemoTools/Data/Data.3rd/BLoC（未验证）/CounterBloc.dart';
import 'package:jobs_flutter_base_config/JobsDemoTools/Data/Data.3rd/BLoC（未验证）/CounterEvent.dart';
import 'package:jobs_flutter_base_config/JobsDemoTools/Data/Data.3rd/BLoC（未验证）/CounterState.dart';

// 演示了如何使用flutter_bloc库，实现一个计数器的功能。
void legacyOriginalMain() {
  legacyCaptureApp(
    JobsMaterialRunner.builder(
      title: 'Flutter Bloc Demo',
      builder: (ctx) {
        return BlocProvider(
          create: (_) => CounterBloc(),
          child: const CounterPage(),
        );
      },
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return LegacyAppBoundary(
      app: MaterialApp(
        title: 'Flutter Bloc Demo',
        home: BlocProvider(
          create: (context) => CounterBloc(),
          child: const CounterPage(),
        ),
      ),
    );
  }
}

class CounterPage extends StatelessWidget {
  const CounterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const LegacyText('Flutter Bloc Demo')),
      body: Center(
        child: BlocBuilder<CounterBloc, CounterState>(
          builder: (context, state) {
            return LegacyText(
              'Counter Value: ${state.counter}',
              style: const TextStyle(fontSize: 24.0),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.read<CounterBloc>().add(IncrementCounter());
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

/// 独立运行与目录预览共用同一份原始教学逻辑。
void main() => launchLegacyStandalone(legacyOriginalMain, title: '事件驱动状态管理');
