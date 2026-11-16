// 独立运行：flutter run -t "lib/demos/调试环境面板/调试环境面板.dart"
// 使用本工程 pubspec.yaml 声明的依赖与资源。

import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:http/http.dart' as http;
import 'package:jobs_demo_foundation/jobs_demo_foundation.dart';

import '../../demo_hub/lab_support.dart';

void main() =>
    runApp(const JobsDemoApp(home: DebugEnvironmentDemo(), title: '调试环境面板'));

class DebugEnvironmentDemo extends StatefulWidget {
  const DebugEnvironmentDemo({super.key});
  @override
  State<DebugEnvironmentDemo> createState() => _State();
}

class _State extends State<DebugEnvironmentDemo> {
  final address = TextEditingController(
    text: 'http://localhost:18080/api/methods',
  );
  final client = http.Client();
  String output = 'local demo';
  int requests = 0;
  int generation = 0;
  double raster = 0;
  double buildTime = 0;
  int frames = 0;
  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addTimingsCallback(timings);
    unawaited(load());
  }

  void timings(List<FrameTiming> batch) {
    if (!mounted || batch.isEmpty) return;
    setState(() {
      frames += batch.length;
      raster =
          batch
              .map((e) => e.rasterDuration.inMicroseconds)
              .reduce((a, b) => a + b) /
          batch.length /
          1000;
      buildTime =
          batch
              .map((e) => e.buildDuration.inMicroseconds)
              .reduce((a, b) => a + b) /
          batch.length /
          1000;
    });
  }

  Future<void> load() async {
    final token = ++generation;
    setState(() => requests++);
    final watch = Stopwatch()..start();
    try {
      final response = await client
          .get(Uri.parse(address.text))
          .timeout(const Duration(milliseconds: 900));
      if (response.statusCode != 200)
        throw StateError('HTTP ${response.statusCode}');
      final object = jsonDecode(response.body);
      if (mounted && token == generation)
        setState(
          () => output =
              'server / ${watch.elapsedMilliseconds} ms\n${const JsonEncoder.withIndent('  ').convert(object)}',
        );
    } catch (error) {
      if (mounted && token == generation)
        setState(
          () => output =
              'local demo / ${watch.elapsedMilliseconds} ms\n${jsonEncode({
                'methods': ['GET', 'POST', 'PUT', 'PATCH', 'DELETE'],
                'attempt': requests,
              })}\n$error',
        );
    }
  }

  @override
  void dispose() {
    generation++;
    SchedulerBinding.instance.removeTimingsCallback(timings);
    client.close();
    address.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => LabFrame(
    title: '调试环境面板',
    children: [
      TextField(
        controller: address,
        decoration: const InputDecoration(labelText: 'API environment URL'),
      ),
      labAction(context, '重新加载', load),
      labOutput(
        context,
        'frames: $frames\nbuild: ${buildTime.toStringAsFixed(2)} ms\nraster: ${raster.toStringAsFixed(2)} ms\nrequests: $requests',
      ),
      labOutput(context, output),
    ],
  );
}
