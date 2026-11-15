import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jobs_demo_foundation/jobs_demo_foundation.dart';
import 'package:jobs_platform_lab/jobs_platform_lab.dart';

import '../../demo_hub/platform_support.dart';
import '../../demo_hub/platform_strings.dart';

void main() => runApp(const JobsDemoApp(home: ARSpaceLabDemo()));

class ARSpaceLabDemo extends StatefulWidget {
  const ARSpaceLabDemo({super.key});
  @override
  State<ARSpaceLabDemo> createState() => _ARSpaceLabDemoState();
}

class _ARSpaceLabDemoState extends State<ARSpaceLabDemo> {
  final state = NativeLabState('ar');
  int? viewId;
  String model = 'cube';
  Future<void> command(
    String action, [
    Map<String, dynamic> extras = const {},
  ]) =>
      state.run('ar.command', {'viewId': viewId, 'action': action, ...extras});
  @override
  void dispose() {
    if (viewId != null) {
      unawaited(
        JobsPlatformLab.invoke<void>('ar.command', {
          'viewId': viewId,
          'action': 'pause',
        }).catchError((_) {}),
      );
    }
    state.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => NativeLabPanel(
    title: 'AR空间实验室',
    state: state,
    children: [
      SizedBox(
        height: 280,
        child: !kIsWeb && defaultTargetPlatform == TargetPlatform.iOS
            ? UiKitView(
                viewType: 'jobs_platform_lab/ar',
                creationParams: const {},
                creationParamsCodec: const StandardMessageCodec(),
                onPlatformViewCreated: (id) => setState(() => viewId = id),
              )
            : Center(child: Text(platformText(context, '平台不支持'))),
      ),
      Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          for (final e in const {
            'preview': '预览',
            'start': '开始AR',
            'place': '放置模型',
            'smaller': '缩小',
            'larger': '放大',
            'rotate': '旋转',
            'clear': '清空',
          }.entries)
            FilledButton.tonal(
              onPressed: viewId == null ? null : () => command(e.key),
              child: Text(platformText(context, e.value)),
            ),
        ],
      ),
      Wrap(
        spacing: 8,
        children: [
          for (final e in const {
            'cube': '方块',
            'sphere': '球体',
            'robot': '机器人',
          }.entries)
            ChoiceChip(
              label: Text(platformText(context, e.value)),
              selected: model == e.key,
              onSelected: (_) {
                setState(() => model = e.key);
                command('select', {'model': e.key});
              },
            ),
        ],
      ),
    ],
  );
}
