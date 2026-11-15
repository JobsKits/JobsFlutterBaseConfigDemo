import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'package:flutter/material.dart';
import 'package:jobs_demo_foundation/jobs_demo_foundation.dart';

import '../../demo_hub/lab_support.dart';
import '../../demo_hub/extra_support.dart';

void main() =>
    runApp(const JobsDemoApp(home: ProtocolModulesDemo(), title: '协议扩展与模块化'));

abstract interface class MessageTransport {
  Future<String> send(String value);
}

extension MessageTransportBatch on MessageTransport {
  Future<List<String>> batch(List<String> values) =>
      Future.wait(values.map(send));
}

mixin RequestMetrics {
  int calls = 0;
  void record() => calls++;
}

class LocalTransport with RequestMetrics implements MessageTransport {
  @override
  Future<String> send(String value) async {
    record();
    await Future<void>.delayed(const Duration(milliseconds: 30));
    return '[$calls] ${value.toUpperCase()}';
  }
}

class ProtocolModulesDemo extends StatefulWidget {
  const ProtocolModulesDemo({super.key});
  @override
  State<ProtocolModulesDemo> createState() => _State();
}

class _State extends State<ProtocolModulesDemo> {
  final transport = LocalTransport();
  String output = '';
  bool busy = false;
  int scenario = 0;
  double responseDelay = 100;
  Future<void> execute() async {
    setState(() => busy = true);
    final value = await runFutureScenario(
      scenario,
      responseMillis: responseDelay.round(),
    );
    if (mounted)
      setState(() {
        output = const JsonEncoder.withIndent('  ').convert(value);
        busy = false;
      });
  }

  Future<void> resource() async {
    final raw = await rootBundle.loadString(
      'packages/jobs_lab_runtime/assets/catalog.json',
    );
    final model = await compute(parseLabCatalog, raw);
    if (mounted)
      setState(
        () => output = const JsonEncoder.withIndent('  ').convert(model),
      );
  }

  Future<void> run() async {
    setState(() => busy = true);
    final values = await transport.batch(['Jobs', 'Swift', 'Flutter']);
    if (mounted)
      setState(() {
        output =
            'interface → implementation → mixin → extension → Future.wait\n${values.join('\n')}\nmetrics: ${transport.calls}';
        busy = false;
      });
  }

  @override
  Widget build(BuildContext context) => LabFrame(
    title: '协议扩展与模块化',
    children: [
      labAction(context, '开始', busy ? null : run),
      labAction(context, '读取', resource),
      const Divider(),
      Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          for (var i = 0; i < 5; i++)
            ChoiceChip(
              label: Text(extraTr(context, futureScenarioNames[i])),
              selected: scenario == i,
              onSelected: busy ? null : (_) => setState(() => scenario = i),
            ),
        ],
      ),
      Text('${extraTr(context, '响应延迟')}：${responseDelay.round()} ms'),
      Slider(
        value: responseDelay,
        min: 50,
        max: 500,
        divisions: 9,
        onChanged: busy ? null : (v) => setState(() => responseDelay = v),
      ),
      labAction(context, extraTr(context, '运行场景'), busy ? null : execute),
      labOutput(context, output),
    ],
  );
}

Map<String, dynamic> parseLabCatalog(String text) =>
    Map<String, dynamic>.from(jsonDecode(text) as Map);

const futureScenarioNames = ['串行依赖', '并发聚合', '失败回退', '部分成功', '竞争超时'];
Future<Map<String, Object?>> runFutureScenario(
  int scenario, {
  int responseMillis = 100,
}) async {
  final trace = <String>[];
  Future<String> request(
    String name, {
    String input = '',
    bool fail = false,
  }) async {
    await Future<void>.delayed(Duration(milliseconds: responseMillis));
    trace.add(name);
    if (fail) throw StateError('$name failed');
    return input.isEmpty ? name : '$name($input)';
  }

  Object? result;
  switch (scenario) {
    case 0:
      result = await request('login')
          .then((token) => request('profile', input: token))
          .then((profile) => request('benefits', input: profile));
    case 1:
      result = await Future.wait([
        request('feed'),
        request('profile'),
        request('offers'),
      ]);
    case 2:
      result = await request('primary', fail: true).catchError((Object e) {
        trace.add('recover-cache');
        return 'cached-profile';
      });
    case 3:
      result = await Future.wait([
        for (final name in ['feed', 'profile', 'offers'])
          request(name, fail: name == 'profile')
              .then<Map<String, Object?>>(
                (value) => {'success': true, 'value': value},
              )
              .catchError(
                (Object e) => <String, Object?>{
                  'success': false,
                  'error': '$e',
                },
              ),
      ]);
    case 4:
      try {
        result = await Future.any([
          request('remote'),
          Future<String>.delayed(
            const Duration(milliseconds: 200),
            () => throw TimeoutException('200 ms'),
          ),
        ]);
      } on TimeoutException {
        result = 'timeout';
      }
    default:
      throw ArgumentError.value(scenario, 'scenario');
  }
  return {
    'scenario': scenario,
    'result': result,
    'trace': List<String>.of(trace),
  };
}
