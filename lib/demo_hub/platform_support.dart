import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:jobs_platform_lab/jobs_platform_lab.dart';

import 'platform_strings.dart';

class NativeLabState extends ChangeNotifier {
  NativeLabState([String? topic]) {
    if (JobsPlatformLab.hasNativeBridge && topic != null) {
      subscription = JobsPlatformLab.events(topic).listen((event) {
        value = event['data'];
        add(event);
      }, onError: (Object error) => add(error.toString()));
    }
  }
  StreamSubscription<Map<String, dynamic>>? subscription;
  final logs = <String>[];
  dynamic value;
  bool busy = false;
  int _operations = 0;
  Future<dynamic> Function(String, Map<String, dynamic>)? executor;
  bool disposed = false;
  void add(Object? event) {
    if (disposed) return;
    String text;
    try {
      text = event is Map || event is List
          ? const JsonEncoder.withIndent('  ').convert(event)
          : event.toString();
    } on JsonUnsupportedObjectError {
      text = event.toString();
    }
    logs.insert(0, text);
    if (logs.length > 60) logs.removeLast();
    notifyListeners();
  }

  Future<dynamic> run(
    String method, [
    Map<String, dynamic> args = const {},
  ]) async {
    if (busy && !isControl(method)) return null;
    _operations++;
    busy = true;
    if (!disposed) notifyListeners();
    try {
      final response = executor == null
          ? await JobsPlatformLab.invoke<dynamic>(method, args)
          : await executor!(method, args);
      value = response;
      add({'method': method, 'result': response});
      return response;
    } catch (error) {
      add(error.toString());
      return null;
    } finally {
      busy = --_operations > 0;
      if (!disposed) notifyListeners();
    }
  }

  static bool isControl(String method) =>
      method.endsWith('.stop') ||
      method.endsWith('.cancel') ||
      method.endsWith('.stopScan') ||
      method.endsWith('.disconnect');

  @override
  void dispose() {
    disposed = true;
    unawaited(subscription?.cancel());
    super.dispose();
  }
}

class NativeLabPanel extends StatelessWidget {
  const NativeLabPanel({
    super.key,
    required this.title,
    required this.state,
    required this.children,
  });
  final String title;
  final NativeLabState state;
  final List<Widget> children;
  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: state,
    builder: (context, _) => Scaffold(
      appBar: AppBar(title: Text(platformText(context, title))),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          if (!JobsPlatformLab.hasNativeBridge)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Text(platformText(context, '平台不支持')),
            ),
          ...children,
          if (state.busy) const LinearProgressIndicator(),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: Text(
                  platformText(context, '操作日志'),
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              TextButton(
                onPressed: () {
                  state.logs.clear();
                  state.add('');
                },
                child: Text(platformText(context, '清空')),
              ),
            ],
          ),
          if (state.logs.isEmpty) Text(platformText(context, '尚无事件')),
          for (final text in state.logs.take(15))
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: SelectableText(text),
            ),
        ],
      ),
    ),
  );
}

Widget nativeButton(
  BuildContext context,
  NativeLabState state,
  String title,
  String method, [
  Map<String, dynamic> args = const {},
]) => ListenableBuilder(
  listenable: state,
  builder: (context, _) => FilledButton.tonal(
    onPressed: state.busy && !NativeLabState.isControl(method)
        ? null
        : () => state.run(method, args),
    child: Text(platformText(context, title)),
  ),
);
