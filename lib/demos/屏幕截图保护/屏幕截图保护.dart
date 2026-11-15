import 'dart:async';

import 'package:flutter/material.dart';
import 'package:jobs_demo_foundation/jobs_demo_foundation.dart';
import 'package:jobs_platform_lab/jobs_platform_lab.dart';

import '../../demo_hub/platform_support.dart';
import '../../demo_hub/platform_strings.dart';

void main() => runApp(const JobsDemoApp(home: ScreenProtectionLabDemo()));

class ScreenProtectionLabDemo extends StatefulWidget {
  const ScreenProtectionLabDemo({super.key});
  @override
  State<ScreenProtectionLabDemo> createState() =>
      _ScreenProtectionLabDemoState();
}

class _ScreenProtectionLabDemoState extends State<ScreenProtectionLabDemo> {
  final state = NativeLabState('screen');
  bool enabled = false;
  @override
  void dispose() {
    if (JobsPlatformLab.hasNativeBridge) {
      unawaited(
        JobsPlatformLab.invoke<void>('screen.protect', {
          'enabled': false,
        }).catchError((_) {}),
      );
    }
    state.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => NativeLabPanel(
    title: '屏幕保护与截图',
    state: state,
    children: [
      SwitchListTile(
        title: Text(platformText(context, '录屏时遮挡内容')),
        value: enabled,
        onChanged: (v) {
          setState(() => enabled = v);
          state.run('screen.protect', {
            'enabled': v,
            'message': platformText(context, '录屏时遮挡内容'),
          });
        },
      ),
      Card(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            'Jobs Flutter • 2026',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
        ),
      ),
      Text(platformText(context, 'iOS不能阻止系统截图')),
      nativeButton(context, state, '重新加载', 'screen.status'),
    ],
  );
}
