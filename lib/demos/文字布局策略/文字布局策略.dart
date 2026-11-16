// 独立运行：flutter run -t "lib/demos/文字布局策略/文字布局策略.dart"
// 使用本工程 pubspec.yaml 声明的依赖与资源。

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:jobs_demo_foundation/jobs_demo_foundation.dart';

import '../../demo_hub/ui_parity_strings.dart';

void main() =>
    runApp(const JobsDemoApp(home: TextStrategiesDemo(), title: '文字布局策略'));

class TextStrategiesDemo extends StatefulWidget {
  const TextStrategiesDemo({super.key});
  @override
  State<TextStrategiesDemo> createState() => _TextStrategiesState();
}

class _TextStrategiesState extends State<TextStrategiesDemo> {
  final input = TextEditingController(
    text: 'Flutter • Jobs • UIKit • SwiftUI • Dart • Responsive text',
  );
  double width = 240, font = 22, angle = 0;
  int mode = 0;
  bool buttonTarget = false, paused = false;
  int taps = 0;
  static const modes = [
    '缩略',
    '多行省略',
    '缩小',
    '往返滚动',
    '连续滚动',
    '宽度自适应',
    '自动换行',
    '手动换行',
    '富文本',
  ];
  @override
  void dispose() {
    input.dispose();
    super.dispose();
  }

  Widget content() {
    final style = TextStyle(
      fontSize: font,
      color: Theme.of(context).colorScheme.onPrimaryContainer,
    );
    final text = input.text;
    return switch (mode) {
      0 => Text(
        text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: style,
      ),
      1 => Text(
        text,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: style,
      ),
      2 => FittedBox(
        fit: BoxFit.scaleDown,
        alignment: AlignmentDirectional.centerStart,
        child: Text(text, maxLines: 1, style: style),
      ),
      3 || 4 => JobsScrollingText(
        text: text,
        style: style,
        pingPong: mode == 3,
        paused: paused,
      ),
      5 => Text(
        text,
        maxLines: 1,
        softWrap: false,
        overflow: TextOverflow.ellipsis,
        style: style,
      ),
      6 => Text(text, softWrap: true, style: style),
      7 => Text(text.replaceAll(' • ', '\n'), style: style),
      _ => Text.rich(
        TextSpan(
          style: style,
          children: [
            TextSpan(
              text: 'Flutter\n',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            TextSpan(
              text: text,
              style: TextStyle(
                decoration: TextDecoration.underline,
                backgroundColor: Theme.of(context)
                    .colorScheme
                    .tertiaryContainer,
              ),
            ),
          ],
        ),
      ),
    };
  }

  Widget preview(double available) {
    final style = TextStyle(fontSize: font);
    final painter = TextPainter(
      text: TextSpan(text: input.text, style: style),
      textDirection: Directionality.of(context),
      textScaler: MediaQuery.textScalerOf(context),
      maxLines: 1,
    )..layout();
    final measured = painter.width + 24;
    painter.dispose();
    final actual = mode == 5
        ? math.min(measured, available)
        : math.min(width, available);
    final height = mode == 0 || mode == 2 || mode == 3 || mode == 4 || mode == 5
        ? 72.0
        : 156.0;
    final child = Align(
      alignment: AlignmentDirectional.centerStart,
      child: content(),
    );
    return SizedBox(
      key: const ValueKey('text-strategy-preview'),
      width: actual,
      height: height,
      child: buttonTarget
          ? FilledButton.tonal(
              onPressed: () => setState(() => taps++),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: ClipRect(child: child),
            )
          : DecoratedBox(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                border: Border.all(
                  color: Theme.of(context).colorScheme.outline,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: ClipRect(child: child),
              ),
            ),
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: JobsDemoAppBar(title: Text(uiTr(context, '文字布局策略'))),
    body: LayoutBuilder(
      builder: (context, constraints) => ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: input,
            maxLines: 3,
            minLines: 1,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(labelText: uiTr(context, '内容')),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: [
              for (var index = 0; index < modes.length; index++)
                ChoiceChip(
                  label: Text(uiTr(context, modes[index])),
                  selected: mode == index,
                  onSelected: (_) => setState(() => mode = index),
                ),
            ],
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(uiTr(context, '按钮标题')),
            value: buttonTarget,
            onChanged: (v) => setState(() => buttonTarget = v),
          ),
          Text('${uiTr(context, '宽度')}: ${width.round()}'),
          Slider(
            value: width.clamp(100, math.max(100, constraints.maxWidth - 32)),
            min: 100,
            max: math.max(100, constraints.maxWidth - 32),
            onChanged: (v) => setState(() => width = v),
          ),
          Text('${uiTr(context, '字号')}: ${font.round()}'),
          Slider(
            value: font,
            min: 12,
            max: 48,
            onChanged: (v) => setState(() => font = v),
          ),
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: preview(constraints.maxWidth - 32),
          ),
          if (buttonTarget) Text('${uiTr(context, '点击')}: $taps'),
          if (mode == 3 || mode == 4)
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(uiTr(context, '暂停')),
              value: paused,
              onChanged: (v) => setState(() => paused = v),
            ),
          const SizedBox(height: 16),
          Text(uiTr(context, '角度')),
          Slider(
            value: angle,
            min: -math.pi,
            max: math.pi,
            onChanged: (v) => setState(() => angle = v),
          ),
          SizedBox(
            height: 180,
            child: ClipRect(
              child: Center(
                child: Transform.rotate(
                  angle: angle,
                  child: Text(
                    input.text,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: font),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
