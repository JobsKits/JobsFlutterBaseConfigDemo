import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:jobs_demo_foundation/jobs_demo_foundation.dart';
import 'package:jobs_lab_runtime/jobs_lab_runtime.dart';

import '../../demo_hub/lab_support.dart';
import '../../demo_hub/micro_web_view.dart';
import '../../demo_hub/micro_document.dart';

void main() =>
    runApp(const JobsDemoApp(home: MicroBridgeDemo(), title: '微应用白名单桥接'));

class MicroBridgeDemo extends StatefulWidget {
  const MicroBridgeDemo({
    super.key,
    this.app,
    this.capabilities = const {'echo', 'storage.get', 'storage.set'},
  });
  final String? app;
  final Set<String> capabilities;
  @override
  State<MicroBridgeDemo> createState() => _State();
}

class _State extends State<MicroBridgeDemo> {
  String appId = 'notes';
  bool storageGranted = true;
  final logs = <String>[];
  @override
  void initState() {
    super.initState();
    appId = widget.app ?? 'notes';
    storageGranted =
        widget.capabilities.contains('storage.get') ||
        widget.capabilities.contains('storage.set');
  }

  JobsLabBridge bridge() {
    final store = JobsLabSandbox('micro_$appId');
    return JobsLabBridge(
      appId: appId,
      allowedMethods: {
        if (widget.capabilities.contains('echo')) 'echo',
        if (storageGranted)
          ...widget.capabilities.where((name) => name.startsWith('storage.')),
      },
      capabilities: {
        'echo': (params) => params['value'],
        'storage.get': (params) => store.read(params['key'] as String),
        'storage.set': (params) async {
          await store.write(params['key'] as String, params['value'] as String);
          return true;
        },
      },
    );
  }

  Future<Map<String, Object?>> request(Object? message) async {
    final result = await bridge().dispatch(message);
    if (mounted)
      setState(() {
        logs.insert(0, jsonEncode(result));
        if (logs.length > 10) logs.removeLast();
      });
    return result;
  }

  @override
  Widget build(BuildContext context) => LabFrame(
    title: '微应用白名单桥接',
    children: [
      Wrap(
        spacing: 8,
        children: [
          for (final app
              in widget.app == null ? ['notes', 'tasks'] : [widget.app!])
            ChoiceChip(
              label: Text(app),
              selected: appId == app,
              onSelected: (_) => setState(() => appId = app),
            ),
        ],
      ),
      SwitchListTile(
        title: const Text('storage.get / storage.set'),
        value: storageGranted,
        onChanged:
            widget.capabilities.any((name) => name.startsWith('storage.'))
            ? (value) => setState(() => storageGranted = value)
            : null,
      ),
      SizedBox(
        height: 350,
        child: MicroWebView(
          key: ValueKey(appId),
          html: microDocument(context, appId),
          onRequest: request,
        ),
      ),
      for (final log in logs) labOutput(context, log),
    ],
  );
}
