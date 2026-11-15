import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jobs_demo_foundation/jobs_demo_foundation.dart';

import '../../demo_hub/ui_parity_strings.dart';

class AnimatedNumbersDemo extends StatefulWidget {
  const AnimatedNumbersDemo({super.key});
  @override
  State<AnimatedNumbersDemo> createState() => _AnimatedNumbersState();
}

class _AnimatedNumbersState extends State<AnimatedNumbersDemo>
    with SingleTickerProviderStateMixin {
  late final AnimationController animation;
  final start = TextEditingController(), end = TextEditingController();
  double from = 60, to = 0, seconds = 10;
  bool buttons = false;
  @override
  void initState() {
    super.initState();
    animation = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
  }

  void run() {
    FocusManager.instance.primaryFocus?.unfocus();
    setState(() {
      from = double.tryParse(start.text) ?? 60;
      to = double.tryParse(end.text) ?? 0;
      animation.forward(from: 0);
    });
  }

  void syncStart(String value) {
    animation.stop();
    setState(() {
      from = double.tryParse(value) ?? 60;
      to = from;
      animation.reset();
    });
  }

  @override
  void dispose() {
    animation.dispose();
    start.dispose();
    end.dispose();
    super.dispose();
  }

  Widget input(
    TextEditingController controller,
    String title, {
    ValueChanged<String>? onChanged,
  }) => TextField(
    controller: controller,
    keyboardType: TextInputType.number,
    inputFormatters: [
      FilteringTextInputFormatter.digitsOnly,
      LengthLimitingTextInputFormatter(15),
    ],
    onChanged: onChanged,
    decoration: InputDecoration(labelText: uiTr(context, title)),
  );
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(uiTr(context, '数字标签与按钮动效'))),
    body: ListView(
      padding: const EdgeInsets.all(16),
      children: [
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(uiTr(context, '按钮标题')),
          value: buttons,
          onChanged: (value) {
            animation.stop();
            setState(() => buttons = value);
          },
        ),
        if (!buttons) ...[
          input(start, '起点', onChanged: syncStart),
          const SizedBox(height: 12),
          input(end, '终点'),
          const SizedBox(height: 24),
          AnimatedBuilder(
            animation: animation,
            builder: (context, _) => SizedBox(
              height: 110,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: JobsFormattedNumber(
                  key: const ValueKey('animated-label-value'),
                  value: from + (to - from) * animation.value,
                  style: Theme.of(context).textTheme.displayLarge,
                ),
              ),
            ),
          ),
          Text('60 → 0 · 0.9s · 60fps', textAlign: TextAlign.center),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            children: [
              FilledButton(
                key: const ValueKey('animated-label-start'),
                onPressed: run,
                child: Text(uiTr(context, '开始')),
              ),
              OutlinedButton(
                onPressed: animation.stop,
                child: Text(uiTr(context, '停止')),
              ),
            ],
          ),
        ] else ...[
          Text('${uiTr(context, '时长')}: ${seconds.toStringAsFixed(1)}s'),
          Slider(
            value: seconds,
            min: .9,
            max: 10,
            onChanged: (value) => setState(() => seconds = value),
          ),
          for (var index = 0; index < 5; index++)
            _AnimatedButtonCard(
              index: index,
              duration: Duration(milliseconds: (seconds * 1000).round()),
            ),
        ],
      ],
    ),
  );
}

class _AnimatedButtonCard extends StatefulWidget {
  const _AnimatedButtonCard({required this.index, required this.duration});
  final int index;
  final Duration duration;
  @override
  State<_AnimatedButtonCard> createState() => _AnimatedButtonState();
}

class _AnimatedButtonState extends State<_AnimatedButtonCard>
    with TickerProviderStateMixin {
  late final AnimationController progress, rotation;
  final start = TextEditingController(), end = TextEditingController();
  late double from, to;
  int generation = 0;
  bool get subtitle => widget.index == 1 || widget.index >= 3;
  bool get icon => widget.index >= 2;
  @override
  void initState() {
    super.initState();
    from = widget.index == 1 || widget.index >= 3 ? 199 : 99;
    to = widget.index == 0
        ? 199
        : widget.index == 1
        ? 99
        : widget.index == 2
        ? 299
        : 9;
    progress = AnimationController(vsync: this, duration: widget.duration);
    rotation = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
  }

  void run() {
    final current = ++generation;
    FocusManager.instance.primaryFocus?.unfocus();
    setState(() {
      from = double.tryParse(start.text) ?? (subtitle ? 199 : 99);
      to =
          double.tryParse(end.text) ??
          (widget.index == 0
              ? 199
              : widget.index == 1
              ? 99
              : widget.index == 2
              ? 299
              : 9);
      progress.duration = widget.duration;
      if (widget.index == 4) rotation.repeat();
    });
    progress.forward(from: 0).whenCompleteOrCancel(() {
      if (mounted && generation == current) {
        rotation.stop();
        setState(() {});
      }
    });
  }

  void stop() {
    generation++;
    progress.stop();
    rotation.stop();
  }

  @override
  void dispose() {
    generation++;
    progress.dispose();
    rotation.dispose();
    start.dispose();
    end.dispose();
    super.dispose();
  }

  Widget numeric(double value) => JobsFormattedNumber(
    value: value,
    decimals: widget.index <= 2 ? 2 : 0,
    grouping: true,
    prefix: widget.index >= 3 ? '${uiTr(context, '倒计时')} ' : '¥',
    suffix: widget.index >= 3
        ? ' ${uiTr(context, '秒')}'
        : ' / ${uiTr(context, '月')}',
    style: TextStyle(fontSize: subtitle ? 16 : 24, fontWeight: FontWeight.w600),
    fractionStyle: TextStyle(
      fontSize: 12,
      color: Theme.of(context).colorScheme.error,
    ),
  );
  Widget field(TextEditingController controller, String key) => TextField(
    controller: controller,
    keyboardType: TextInputType.number,
    inputFormatters: [
      FilteringTextInputFormatter.digitsOnly,
      LengthLimitingTextInputFormatter(15),
    ],
    decoration: InputDecoration(labelText: uiTr(context, key)),
  );
  @override
  Widget build(BuildContext context) => Card(
    margin: const EdgeInsets.symmetric(vertical: 10),
    child: Padding(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            '${widget.index + 1}. ${uiTr(context, subtitle ? '副标题' : '标题')}${widget.index == 0 ? '' : ' · ${uiTr(context, '富文本')}'}',
          ),
          const SizedBox(height: 10),
          field(start, '起点'),
          const SizedBox(height: 8),
          field(end, '终点'),
          const SizedBox(height: 12),
          AnimatedBuilder(
            animation: progress,
            builder: (context, _) => FilledButton.tonal(
              key: ValueKey('animated-number-button-${widget.index}'),
              onPressed: run,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (icon) ...[
                      RotationTransition(
                        turns: Tween(begin: 0.0, end: -1.0).animate(rotation),
                        child: Icon(
                          widget.index >= 3 ? Icons.schedule : Icons.star,
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (subtitle) Text(uiTr(context, '标题')),
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            child: numeric(from + (to - from) * progress.value),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          TextButton(onPressed: stop, child: Text(uiTr(context, '停止'))),
        ],
      ),
    ),
  );
}

void main() =>
    runApp(const JobsDemoApp(home: AnimatedNumbersDemo(), title: '数字标签与按钮动效'));
