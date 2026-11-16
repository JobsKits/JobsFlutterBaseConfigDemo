import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jobs_demo_foundation/jobs_demo_foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../demo_hub/interop_strings.dart';

const nativeRoundTripChannel = MethodChannel(
  'jobs_platform_lab/native_round_trip',
);

Future<Map<String, dynamic>> loadNativeBridgeParameters() async {
  // 引擎先运行才能安装原生 handler；只对启动期 MissingPlugin 做短暂重试。
  for (var attempt = 0; attempt < 10; attempt++) {
    try {
      return await nativeRoundTripChannel
              .invokeMapMethod<String, dynamic>('load')
              .timeout(const Duration(seconds: 3)) ??
          {};
    } on MissingPluginException {
      if (attempt == 9) rethrow;
      await Future<void>.delayed(const Duration(milliseconds: 50));
    }
  }
  return {};
}

Future<void> launchNativeBridgeEntry() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    final values = await loadNativeBridgeParameters();
    final language = values['locale'] as String?;
    final settings = JobsDemoSettings(
      locale: jobsDemoLocales.firstWhere(
        (value) => value.toLanguageTag() == language,
        orElse: () => const Locale('zh'),
      ),
      themeMode: ThemeMode.values.firstWhere(
        (mode) => mode.name == values['theme'],
        orElse: () => ThemeMode.system,
      ),
    );
    runApp(
      JobsDemoApp(
        settings: settings,
        showSettings: false,
        home: NativeBridgeEmbeddedDemo(parameters: values),
      ),
    );
  } catch (error) {
    // 握手失败仍给用户退出入口，不能留下无反馈的第二引擎黑屏。
    runApp(
      JobsDemoApp(
        settings: JobsDemoSettings(),
        showSettings: false,
        home: NativeBridgeEmbeddedDemo(
          parameters: const {},
          initialError: '$error',
        ),
      ),
    );
  }
}

class NativeBridgeEmbeddedDemo extends StatefulWidget {
  const NativeBridgeEmbeddedDemo({
    super.key,
    required this.parameters,
    this.initialError,
  });
  final Map<String, dynamic> parameters;
  final String? initialError;
  @override
  State<NativeBridgeEmbeddedDemo> createState() => _NativeBridgeEmbeddedState();
}

class _NativeBridgeEmbeddedState extends State<NativeBridgeEmbeddedDemo> {
  late final input = TextEditingController(
    text: widget.parameters['prefill'] as String? ?? '',
  );
  late String? error = widget.initialError;
  String? pluginValue;
  bool busy = false;

  @override
  void dispose() {
    input.dispose();
    super.dispose();
  }

  Future<void> finish({bool cancelled = false}) async {
    if (busy) return;
    setState(() => busy = true);
    try {
      await nativeRoundTripChannel.invokeMethod<void>('finish', {
        'requestId': widget.parameters['requestId'],
        'value': input.text,
        'cancelled': cancelled,
        'engine': 'secondary',
      });
    } catch (e) {
      if (mounted) setState(() => error = '$e');
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  Future<void> verifyPlugins() async {
    setState(() => busy = true);
    try {
      final preferences = await SharedPreferences.getInstance();
      final key = 'interop.${widget.parameters['requestId']}';
      if (!await preferences.setString(key, input.text)) {
        throw StateError('SharedPreferences write failed');
      }
      final value = preferences.getString(key);
      await preferences.remove(key);
      if (mounted) {
        setState(() {
          pluginValue = value;
          error = null;
        });
      }
    } catch (e) {
      if (mounted) setState(() => error = '$e');
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: false,
    onPopInvokedWithResult: (didPop, _) {
      if (!didPop) finish(cancelled: true);
    },
    child: Scaffold(
      appBar: JobsDemoAppBar(
        title: Text(interopTr(context, '独立Flutter引擎')),
        leading: IconButton(
          onPressed: busy ? null : () => finish(cancelled: true),
          tooltip: tr(context, '取消'),
          icon: const Icon(Icons.close),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          SelectableText(
            const JsonEncoder.withIndent('  ').convert(widget.parameters),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: input,
            decoration: InputDecoration(labelText: interopTr(context, '回传内容')),
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: busy ? null : finish,
            child: Text(interopTr(context, '回传并关闭Flutter')),
          ),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: busy ? null : verifyPlugins,
            child: Text(interopTr(context, '独立引擎插件读写')),
          ),
          if (busy) const LinearProgressIndicator(),
          if (pluginValue != null)
            SelectableText('SharedPreferences: $pluginValue'),
          if (error != null)
            SelectableText(
              error!,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
        ],
      ),
    ),
  );
}
