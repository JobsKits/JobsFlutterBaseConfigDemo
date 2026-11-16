// 独立运行：flutter run -t "lib/demos/Lottie动画/Lottie动画.dart"
// 使用本工程 pubspec.yaml 声明的依赖与资源。

import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:jobs_demo_foundation/jobs_demo_foundation.dart';

import '../../demo_hub/ui_parity_strings.dart';
import '../../demo_hub/ui_parity_support.dart';

import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:lottie/lottie.dart';

void main() =>
    runApp(const JobsDemoApp(home: LottieAnimationDemo(), title: 'Lottie动画'));

class LottieAnimationDemo extends StatefulWidget {
  const LottieAnimationDemo({super.key});
  @override
  State<LottieAnimationDemo> createState() => _LottieAnimationState();
}

class _LottieAnimationState extends State<LottieAnimationDemo>
    with SingleTickerProviderStateMixin {
  late final controller = AnimationController(vsync: this);
  double speed = 1;
  bool repeat = true;
  Uint8List? custom;
  final sample = utf8.encode(
    jsonEncode({
      'v': '5.7.4',
      'fr': 30,
      'ip': 0,
      'op': 90,
      'w': 300,
      'h': 300,
      'nm': 'Jobs orbit',
      'ddd': 0,
      'assets': [],
      'layers': [
        {
          'ddd': 0,
          'ind': 1,
          'ty': 4,
          'nm': 'Orbit',
          'sr': 1,
          'ks': {
            'o': {'a': 0, 'k': 100},
            'r': {
              'a': 1,
              'k': [
                {
                  't': 0,
                  's': [0],
                  'e': [360],
                  'i': {
                    'x': [.6],
                    'y': [1],
                  },
                  'o': {
                    'x': [.4],
                    'y': [0],
                  },
                },
                {
                  't': 90,
                  's': [360],
                },
              ],
            },
            'p': {
              'a': 0,
              'k': [150, 150, 0],
            },
            'a': {
              'a': 0,
              'k': [0, 0, 0],
            },
            's': {
              'a': 0,
              'k': [100, 100, 100],
            },
          },
          'shapes': [
            {
              'ty': 'el',
              'p': {
                'a': 0,
                'k': [0, 0],
              },
              's': {
                'a': 0,
                'k': [180, 180],
              },
            },
            {
              'ty': 'st',
              'c': {
                'a': 0,
                'k': [.09, .4, .32, 1],
              },
              'o': {'a': 0, 'k': 100},
              'w': {'a': 0, 'k': 10},
              'lc': 2,
              'lj': 2,
            },
            {
              'ty': 'tm',
              's': {'a': 0, 'k': 0},
              'e': {'a': 0, 'k': 72},
              'o': {'a': 0, 'k': 0},
            },
          ],
          'ip': 0,
          'op': 90,
          'st': 0,
          'bm': 0,
        },
      ],
    }),
  );
  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void play() {
    repeat ? controller.repeat() : controller.forward(from: 0);
    setState(() {});
  }

  Future<void> open() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
      withData: true,
    );
    if (mounted && result?.files.single.bytes != null) {
      controller.stop();
      setState(() => custom = result!.files.single.bytes);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: JobsDemoAppBar(
      title: Text(uiTr(context, 'Lottie动画')),
      actions: [
        IconButton(
          tooltip: uiTr(context, '读取'),
          onPressed: open,
          icon: const Icon(Icons.folder_open),
        ),
      ],
    ),
    body: ListView(
      padding: const EdgeInsets.all(20),
      children: [
        SizedBox(
          height: 300,
          child: Lottie.memory(
            custom ?? Uint8List.fromList(sample),
            controller: controller,
            onLoaded: (composition) {
              controller.duration = Duration(
                microseconds: (composition.duration.inMicroseconds / speed)
                    .round(),
              );
              setState(() {});
            },
            errorBuilder: (context, error, stack) =>
                uiEmpty(context, () => setState(() => custom = null)),
          ),
        ),
        AnimatedBuilder(
          animation: controller,
          builder: (context, _) => Slider(
            value: controller.value,
            onChanged: (v) {
              controller.stop();
              controller.value = v;
            },
          ),
        ),
        Text('${uiTr(context, '速度')}: ${speed.toStringAsFixed(1)}×'),
        Slider(
          value: speed,
          min: .25,
          max: 3,
          divisions: 11,
          onChanged: (v) {
            final old = speed;
            setState(() => speed = v);
            if (controller.duration != null)
              controller.duration = Duration(
                microseconds: (controller.duration!.inMicroseconds * old / v)
                    .round(),
              );
          },
        ),
        SwitchListTile(
          title: Text(uiTr(context, '播放')),
          value: repeat,
          onChanged: (v) => setState(() => repeat = v),
        ),
        Wrap(
          spacing: 8,
          children: [
            FilledButton(onPressed: play, child: Text(uiTr(context, '播放'))),
            OutlinedButton(
              onPressed: () {
                controller.stop();
                setState(() {});
              },
              child: Text(uiTr(context, '暂停')),
            ),
            TextButton(
              onPressed: () {
                controller.reset();
                setState(() {});
              },
              child: Text(uiTr(context, '重置')),
            ),
          ],
        ),
      ],
    ),
  );
}
