// main.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jobs_runners/jobs_runners.dart'; // 公共测试器路径
import 'CounterBloc.dart';
import 'CounterEvent.dart';
import 'CounterState.dart';

// 演示了如何使用flutter_bloc库，实现一个计数器的功能。
void main() {
  runApp(JobsMaterialRunner.builder(
    title: 'Flutter Bloc Demo',
    builder: (ctx) {
      return BlocProvider(
        create: (_) => CounterBloc(),
        child: const CounterPage(),
      );
    },
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Bloc Demo',
      home: BlocProvider(
        create: (context) => CounterBloc(),
        child: const CounterPage(),
      ),
    );
  }
}

class CounterPage extends StatelessWidget {
  const CounterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter Bloc Demo'),
      ),
      body: Center(
        child: BlocBuilder<CounterBloc, CounterState>(
          builder: (context, state) {
            return Text(
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
