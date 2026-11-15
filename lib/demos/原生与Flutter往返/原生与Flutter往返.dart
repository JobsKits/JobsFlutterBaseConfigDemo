import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:jobs_demo_foundation/jobs_demo_foundation.dart';
import 'package:jobs_platform_lab/jobs_platform_lab.dart';

import '../../demo_hub/interop_strings.dart';
import '独立引擎页面.dart';

void main() => runApp(const JobsDemoApp(home: NativeFlutterRoundTripDemo()));

/// 独立文件运行时，第二个 engine 同样从当前入口库查找保留函数。
@pragma('vm:entry-point')
Future<void> jobsNativeBridgeEntry() => launchNativeBridgeEntry();

class NativeFlutterRoundTripDemo extends StatefulWidget {
  const NativeFlutterRoundTripDemo({super.key});
  @override
  State<NativeFlutterRoundTripDemo> createState() =>
      _NativeFlutterRoundTripState();
}

class _NativeFlutterRoundTripState extends State<NativeFlutterRoundTripDemo> {
  final input = TextEditingController(text: 'hello from Flutter');
  bool busy = false;
  Object? output;

  @override
  void dispose() {
    input.dispose();
    super.dispose();
  }

  bool get supported => !kIsWeb && defaultTargetPlatform == TargetPlatform.iOS;

  Future<void> openHost() async {
    if (!supported || busy) return;
    final settings = JobsDemoScope.of(context);
    final labels = <String, String>{
      for (final key in [
        '原生宿主页面',
        '原生按钮打开独立Flutter引擎',
        '等待Flutter回传',
        '关闭宿主返回首页',
        '取消',
        '失败',
      ])
        key: interopTr(context, key),
    };
    setState(() => busy = true);
    try {
      final result = await JobsPlatformLab.invoke<Object?>(
        'bridge.presentHost',
        {
          'requestId': 'interop-${DateTime.now().microsecondsSinceEpoch}',
          'prefill': input.text,
          'locale': settings.locale.toLanguageTag(),
          'theme': settings.themeMode.name,
          'labels': labels,
        },
      );
      if (mounted) setState(() => output = result);
    } catch (error) {
      if (mounted) setState(() => output = error.toString());
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(interopTr(context, '原生与Flutter往返'))),
    body: ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text(interopTr(context, '参数由父页面传入，结果先返回原生页面，再返回此页')),
        const SizedBox(height: 20),
        const SelectableText(
          'Flutter → UIViewController → FlutterEngine #2 → MethodChannel → Native → Flutter',
        ),
        const SizedBox(height: 20),
        TextField(
          controller: input,
          decoration: InputDecoration(labelText: tr(context, '内容')),
        ),
        const SizedBox(height: 16),
        FilledButton(
          onPressed: supported && !busy ? openHost : null,
          child: Text(interopTr(context, '打开原生宿主')),
        ),
        if (!supported)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Text(interopTr(context, '此往返示例需要iOS原生宿主')),
          ),
        if (busy)
          const Padding(
            padding: EdgeInsets.only(top: 16),
            child: LinearProgressIndicator(),
          ),
        if (output != null)
          Padding(
            padding: const EdgeInsets.only(top: 20),
            child: SelectableText(
              output is String
                  ? output! as String
                  : const JsonEncoder.withIndent('  ').convert(output),
            ),
          ),
      ],
    ),
  );
}
