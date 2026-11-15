import 'dart:async';
import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:jobs_demo_foundation/jobs_demo_foundation.dart';
import 'package:jobs_lab_runtime/jobs_lab_runtime.dart';

import '../../demo_hub/lab_support.dart';
import '../微应用白名单桥接/微应用白名单桥接.dart';

void main() =>
    runApp(const JobsDemoApp(home: MiniPlatformDemo(), title: '微应用平台容器'));

class MiniPlatformDemo extends StatefulWidget {
  const MiniPlatformDemo({super.key});
  @override
  State<MiniPlatformDemo> createState() => _State();
}

class _State extends State<MiniPlatformDemo> {
  final store = JobsLabSandbox('platform_registry');
  final manifest = TextEditingController(
    text: '{"id":"notes","version":1,"capabilities":["echo","storage.get","storage.set"]}',
  );
  Map<String, String> installed = {};
  String output = '';
  @override
  void initState() {
    super.initState();
    unawaited(load());
  }

  @override
  void dispose() {
    manifest.dispose();
    super.dispose();
  }

  Future<void> load() async {
    final rows = await store.entries();
    if (mounted) setState(() => installed = rows);
  }

  Future<void> install() async {
    try {
      final model = Map<String, dynamic>.from(jsonDecode(manifest.text) as Map);
      final id = model['id'];
      final version = model['version'];
      final capabilities = model['capabilities'];
      if (id is! String ||
          !RegExp(r'^[a-z0-9_-]{1,40}$').hasMatch(id) ||
          version is! int ||
          version < 1 ||
          capabilities is! List ||
          capabilities.any(
            (e) => !{'echo', 'storage.get', 'storage.set'}.contains(e),
          ))
        throw const FormatException('Invalid application manifest');
      final previous = installed[id];
      if (previous != null &&
          (jsonDecode(previous) as Map)['version'] > version)
        throw StateError('Version downgrade rejected');
      final payload = jsonEncode(model);
      await store.write(id, payload);
      if (mounted)
        setState(
          () => output = 'SHA-256: ${sha256.convert(utf8.encode(payload))}',
        );
      await load();
    } catch (error) {
      if (mounted) setState(() => output = error.toString());
    }
  }

  @override
  Widget build(BuildContext context) => LabFrame(
    title: '微应用平台容器',
    children: [
      TextField(
        controller: manifest,
        minLines: 3,
        maxLines: 6,
        decoration: const InputDecoration(labelText: 'Manifest / JSON'),
      ),
      labAction(context, '安装', install),
      labOutput(context, output),
      if (installed.isEmpty) JobsEmptyState(title: '无数据', onReload: load),
      for (final item in installed.entries)
        ListTile(
          title: Text(item.key),
          subtitle: Text(item.value),
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) {
                final model = jsonDecode(item.value) as Map;
                return MicroBridgeDemo(
                  app: item.key,
                  capabilities: Set<String>.from(model['capabilities'] as List),
                );
              },
            ),
          ),
          trailing: IconButton(
            tooltip: labTr(context, '删除'),
            icon: const Icon(Icons.delete_outline),
            onPressed: () async {
              await store.remove(item.key);
              await load();
            },
          ),
        ),
    ],
  );
}
