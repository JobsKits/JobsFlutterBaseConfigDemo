import 'dart:async';

import 'package:flutter/material.dart';
import 'package:jobs_demo_foundation/jobs_demo_foundation.dart';
import 'package:jobs_platform_lab/jobs_platform_lab.dart';

import '../../demo_hub/platform_support.dart';
import '../../demo_hub/platform_strings.dart';

void main() => runApp(const JobsDemoApp(home: MotionLabDemo()));

class MotionLabDemo extends StatefulWidget {
  const MotionLabDemo({super.key});
  @override
  State<MotionLabDemo> createState() => _MotionLabDemoState();
}

class _MotionLabDemoState extends State<MotionLabDemo> {
  final state = NativeLabState('motion');
  String kind = 'device';
  @override
  void dispose() {
    if (JobsPlatformLab.hasNativeBridge) {
      unawaited(JobsPlatformLab.invoke<void>('motion.stop').catchError((_) {}));
    }
    state.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => NativeLabPanel(
    title: '传感器实验室',
    state: state,
    children: [
      Wrap(
        spacing: 8,
        children: [
          for (final e in const {
            'device': '设备姿态',
            'accelerometer': '加速度计',
            'gyroscope': '陀螺仪',
            'magnetometer': '磁力计',
          }.entries)
            ChoiceChip(
              label: Text(platformText(context, e.value)),
              selected: kind == e.key,
              onSelected: (_) => setState(() => kind = e.key),
            ),
        ],
      ),
      Wrap(
        spacing: 8,
        children: [
          nativeButton(context, state, '平台能力', 'capabilities'),
          nativeButton(context, state, '开始', 'motion.start', {
            'kind': kind,
            'intervalMs': 100,
          }),
          nativeButton(context, state, '停止', 'motion.stop'),
        ],
      ),
      ListenableBuilder(
        listenable: state,
        builder: (context, _) {
          final data = state.value;
          final roll = data is Map
              ? (data['roll'] as num?)?.toDouble() ?? 0
              : 0.0;
          final pitch = data is Map
              ? (data['pitch'] as num?)?.toDouble() ?? 0
              : 0.0;
          return SizedBox(
            height: 200,
            child: Center(
              child: Transform.rotate(
                angle: roll,
                child: Transform.translate(
                  offset: Offset(roll * 35, pitch * 35),
                  child: const Icon(Icons.smartphone, size: 100),
                ),
              ),
            ),
          );
        },
      ),
    ],
  );
}
