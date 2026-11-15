import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:jobs_demo_foundation/jobs_demo_foundation.dart';

import '../../demo_hub/ui_parity_strings.dart';

class MarqueeTextDemo extends StatefulWidget {
  const MarqueeTextDemo({super.key});
  @override
  State<MarqueeTextDemo> createState() => _MarqueeTextState();
}

class _MarqueeTextState extends State<MarqueeTextDemo> {
  final input = TextEditingController(
    text: 'Jobs Flutter • UIKit • SwiftUI • Dart',
  );
  double speed = 40, interval = 2;
  bool playing = true, pictures = false, fit = true;
  int direction = 0, mode = 0, taps = 0, longPresses = 0, current = 0;
  @override
  void dispose() {
    input.dispose();
    super.dispose();
  }

  double contentWidth(BuildContext context) {
    final painter = TextPainter(
      text: TextSpan(
        text: '${input.text} 1',
        style: Theme.of(context).textTheme.labelLarge,
      ),
      textDirection: Directionality.of(context),
      textScaler: MediaQuery.textScalerOf(context),
    )..layout();
    final width = painter.width + 72;
    painter.dispose();
    return math.max(100, width);
  }

  Widget item(BuildContext context, int index) => Padding(
    padding: const EdgeInsets.all(4),
    child: pictures
        ? GestureDetector(
            onTap: () => setState(() => taps++),
            onLongPress: () => setState(() => longPresses++),
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.asset('assets/Images/flower.png', fit: BoxFit.cover),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: ColoredBox(
                    color: Theme.of(context).colorScheme.surface
                        .withValues(alpha: .9),
                    child: Text(
                      '${uiTr(context, '图片')} ${index + 1}',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          )
        : TextButton.icon(
            onPressed: () => setState(() => taps++),
            onLongPress: () => setState(() => longPresses++),
            icon: const Icon(Icons.campaign),
            label: Text(
              '${input.text} ${index + 1}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
  );
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(uiTr(context, '跑马灯文字'))),
    body: LayoutBuilder(
      builder: (context, constraints) => ListView(
        padding: const EdgeInsets.all(20),
        children: [
          TextField(
            controller: input,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(labelText: uiTr(context, '内容')),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 6,
            children: [
              for (var i = 0; i < 4; i++)
                ChoiceChip(
                  label: Text(uiTr(context, ['左', '右', '上', '下'][i])),
                  selected: direction == i,
                  onSelected: (_) => setState(() => direction = i),
                ),
            ],
          ),
          Wrap(
            spacing: 6,
            children: [
              for (var i = 0; i < 3; i++)
                ChoiceChip(
                  label: Text(uiTr(context, ['连续滚动', '间隔分页', '分页轮播'][i])),
                  selected: mode == i,
                  onSelected: (_) => setState(() => mode = i),
                ),
            ],
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(uiTr(context, '图片')),
            value: pictures,
            onChanged: (value) => setState(() => pictures = value),
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(uiTr(context, '内容自适应')),
            value: fit,
            onChanged: (value) => setState(() => fit = value),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: pictures ? 160 : 104,
            child: DecoratedBox(
              decoration: BoxDecoration(
                border: Border.all(
                  color: Theme.of(context).colorScheme.outline,
                ),
              ),
              child: JobsMarqueeView(
                key: ValueKey('$direction-$mode-$pictures-$fit'),
                itemCount: 3,
                itemBuilder: item,
                direction: [
                  AxisDirection.left,
                  AxisDirection.right,
                  AxisDirection.up,
                  AxisDirection.down,
                ][direction],
                mode: JobsMarqueeMode.values[mode],
                itemExtent: direction < 2
                    ? (mode == 2 || !fit || pictures
                          ? math.max(100, constraints.maxWidth - 40)
                          : contentWidth(context))
                    : pictures
                    ? 160
                    : 104,
                speed: speed,
                interval: Duration(milliseconds: (interval * 1000).round()),
                paused: !playing,
                onItemChanged: (value) {
                  if (mounted) setState(() => current = value);
                },
              ),
            ),
          ),
          Text(
            '${uiTr(context, '条目')}: ${current + 1} · ${uiTr(context, '点击')}: $taps · ${uiTr(context, '长按')}: $longPresses',
          ),
          Text('${uiTr(context, '速度')}: ${speed.round()} px/s'),
          Slider(
            value: speed,
            min: 10,
            max: 200,
            onChanged: (value) => setState(() => speed = value),
          ),
          Text('${uiTr(context, '间隔')}: ${interval.toStringAsFixed(1)}s'),
          Slider(
            value: interval,
            min: .5,
            max: 5,
            onChanged: (value) => setState(() => interval = value),
          ),
          FilledButton(
            onPressed: () => setState(() => playing = !playing),
            child: Text(uiTr(context, playing ? '暂停' : '播放')),
          ),
        ],
      ),
    ),
  );
}

void main() =>
    runApp(const JobsDemoApp(home: MarqueeTextDemo(), title: '跑马灯文字'));
