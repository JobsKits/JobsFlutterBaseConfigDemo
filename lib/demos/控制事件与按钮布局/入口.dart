import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:jobs_demo_foundation/jobs_demo_foundation.dart';

import '../../demo_hub/ui_parity_strings.dart';

class ControlEventsDemo extends StatefulWidget {
  const ControlEventsDemo({super.key});
  @override
  State<ControlEventsDemo> createState() => _ControlEventsState();
}

class _ControlEventsState extends State<ControlEventsDemo>
    with SingleTickerProviderStateMixin {
  final events = <String>[];
  final states = WidgetStatesController();
  late final AnimationController rotation;
  Timer? debounce;
  bool enabled = true,
      selected = false,
      rotating = false,
      locked = false,
      pressedLong = false,
      grid = false;
  double inset = 12, gap = 8, slider = 30;
  int layout = 0;
  @override
  void initState() {
    super.initState();
    states.addListener(statesChanged);
    rotation = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
  }

  void statesChanged() {
    if (SchedulerBinding.instance.schedulerPhase ==
        SchedulerPhase.persistentCallbacks) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() {});
      });
    } else if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    states.removeListener(statesChanged);
    states.dispose();
    rotation.dispose();
    debounce?.cancel();
    super.dispose();
  }

  void record(String event) {
    if (!mounted) return;
    setState(() {
      events.insert(
        0,
        '${DateTime.now().toIso8601String().substring(11, 23)} $event',
      );
      if (events.length > 25) events.removeLast();
    });
  }

  String get stateName => !enabled
      ? '禁用'
      : states.value.contains(WidgetState.pressed)
      ? '按下'
      : selected
      ? '已选择'
      : states.value.contains(WidgetState.hovered)
      ? '悬停'
      : states.value.contains(WidgetState.focused)
      ? '焦点'
      : '普通';
  Widget section(String name, List<Widget> children) => Card(
    margin: const EdgeInsets.only(bottom: 16),
    child: Padding(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            uiTr(context, name),
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    ),
  );
  Widget buttonContent() {
    final icon = Icon(
      selected ? Icons.visibility : Icons.visibility_off,
      size: states.value.contains(WidgetState.pressed) ? 28 : 22,
    );
    final title = Text(
      uiTr(context, stateName),
      key: const ValueKey('button-state-title'),
    );
    final children = layout == 0 || layout == 3
        ? [icon, SizedBox(width: gap, height: gap), title]
        : [title, SizedBox(width: gap, height: gap), icon];
    return layout.isEven
        ? Column(mainAxisSize: MainAxisSize.min, children: children)
        : Row(mainAxisSize: MainAxisSize.min, children: children);
  }

  Color background(Set<WidgetState> value) {
    final colors = Theme.of(context).colorScheme;
    return value.contains(WidgetState.disabled)
        ? colors.surfaceContainerHighest
        : value.contains(WidgetState.pressed)
        ? colors.tertiary
        : selected
        ? colors.secondary
        : colors.primary;
  }

  Color foreground(Set<WidgetState> value) {
    final colors = Theme.of(context).colorScheme;
    return value.contains(WidgetState.disabled)
        ? colors.onSurfaceVariant
        : value.contains(WidgetState.pressed)
        ? colors.onTertiary
        : selected
        ? colors.onSecondary
        : colors.onPrimary;
  }

  void rotate() {
    if (locked) return;
    setState(() {
      locked = true;
      rotating = !rotating;
      if (rotating)
        rotation.repeat();
      else
        rotation.reset();
    });
    record(rotating ? 'startRotating' : 'stopRotating');
    debounce = Timer(const Duration(milliseconds: 250), () {
      if (mounted) setState(() => locked = false);
    });
  }

  Widget coverageCell(int index) => Stack(
    children: [
      ListTile(
        leading: const Icon(Icons.layers),
        title: Text('Flutter $index'),
        subtitle: const Text('Cell'),
      ),
      Positioned.fill(
        child: TextButton(
          key: ValueKey('covered-cell-$index'),
          onPressed: () => record('coveredCell:$index'),
          child: const SizedBox.expand(),
        ),
      ),
    ],
  );
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(uiTr(context, '控制事件与按钮布局')),
      actions: [
        IconButton(
          tooltip: uiTr(context, '清空'),
          onPressed: () => setState(events.clear),
          icon: const Icon(Icons.clear_all),
        ),
      ],
    ),
    body: ListView(
      padding: const EdgeInsets.all(16),
      children: [
        section('状态', [
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            key: const ValueKey('button-enabled'),
            title: Text(uiTr(context, '启用')),
            value: enabled,
            onChanged: (value) {
              setState(() => enabled = value);
              record('enabled:$value');
            },
          ),
          Wrap(
            spacing: 6,
            children: [
              for (var i = 0; i < 4; i++)
                ChoiceChip(
                  label: Text(uiTr(context, ['上', '右', '下', '左'][i])),
                  selected: layout == i,
                  onSelected: (_) => setState(() => layout = i),
                ),
            ],
          ),
          Text('${uiTr(context, '内边距')}: ${inset.round()}'),
          Slider(
            value: inset,
            min: 0,
            max: 32,
            onChanged: (v) => setState(() => inset = v),
          ),
          Text('${uiTr(context, '间距')}: ${gap.round()}'),
          Slider(
            value: gap,
            min: 0,
            max: 24,
            onChanged: (v) => setState(() => gap = v),
          ),
          Listener(
            onPointerDown: (_) => record('touchDown'),
            onPointerMove: (_) => record('touchDrag'),
            onPointerUp: (_) => record('touchUp'),
            onPointerCancel: (_) => record('touchCancel'),
            child: FilledButton(
              key: const ValueKey('state-button'),
              statesController: states,
              onPressed: enabled
                  ? () {
                      setState(() => selected = !selected);
                      record('touchUpInside');
                    }
                  : null,
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.resolveWith(background),
                foregroundColor: WidgetStateProperty.resolveWith(foreground),
                padding: WidgetStatePropertyAll(
                  EdgeInsets.symmetric(horizontal: inset, vertical: 12),
                ),
                overlayColor: WidgetStateProperty.resolveWith(
                  (value) => value.contains(WidgetState.hovered)
                      ? Theme.of(context).colorScheme.onPrimary
                            .withValues(alpha: .15)
                      : null,
                ),
              ),
              child: buttonContent(),
            ),
          ),
        ]),
        section('主副标题', [
          FilledButton.tonal(
            onPressed: () => record('subtitle'),
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                children: [
                  Text(uiTr(context, '标题')),
                  Text(
                    uiTr(context, '副标题'),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          FilledButton(
            onPressed: () => record('richTitle'),
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                children: [
                  Text.rich(
                    TextSpan(
                      children: [
                        const TextSpan(
                          text: '¥99',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        TextSpan(
                          text: ' / ${uiTr(context, '月')}',
                          style: const TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                  Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(text: '${uiTr(context, '原价')} '),
                        const TextSpan(
                          text: '¥199',
                          style: TextStyle(
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ]),
        section('菜单', [
          PopupMenuButton<String>(
            tooltip: uiTr(context, '菜单'),
            onSelected: (value) async {
              if (value == '复制')
                await Clipboard.setData(const ClipboardData(text: 'Jobs'));
              if (context.mounted) record(uiTr(context, value));
            },
            itemBuilder: (_) => [
              for (final value in ['复制', '分享', '删除'])
                PopupMenuItem(value: value, child: Text(uiTr(context, value))),
            ],
            child: FilledButton.tonal(
              onPressed: null,
              child: Text(uiTr(context, '操作')),
            ),
          ),
          const SizedBox(height: 8),
          FilledButton.icon(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
            onPressed: () => record('destructive'),
            icon: const Icon(Icons.delete),
            label: Text(uiTr(context, '删除')),
          ),
        ]),
        section('手势与旋转', [
          FilledButton.icon(
            key: const ValueKey('rotate-button'),
            onPressed: locked ? null : rotate,
            icon: RotationTransition(
              turns: rotation,
              child: const Icon(Icons.sync),
            ),
            label: Text(uiTr(context, rotating ? '停止' : '旋转')),
          ),
          const SizedBox(height: 8),
          RawGestureDetector(
            gestures: {
              LongPressGestureRecognizer:
                  GestureRecognizerFactoryWithHandlers<
                    LongPressGestureRecognizer
                  >(
                    () => LongPressGestureRecognizer(
                      duration: const Duration(milliseconds: 800),
                    ),
                    (instance) {
                      instance.onLongPressStart = (_) {
                        setState(() => pressedLong = true);
                        record('longPress.began');
                      };
                      instance.onLongPressEnd = (_) {
                        setState(() => pressedLong = false);
                        record('longPress.ended');
                      };
                      instance.onLongPressCancel = () {
                        if (mounted) setState(() => pressedLong = false);
                        record('longPress.cancelled');
                      };
                    },
                  ),
            },
            child: AnimatedOpacity(
              opacity: pressedLong ? .6 : 1,
              duration: const Duration(milliseconds: 100),
              child: FilledButton.tonal(
                onPressed: () => record('tap'),
                child: Text('${uiTr(context, '长按')} 0.8s'),
              ),
            ),
          ),
        ]),
        section('控制事件', [
          TextField(
            decoration: InputDecoration(labelText: uiTr(context, '内容')),
            onChanged: (v) => record('editingChanged:$v'),
            onSubmitted: (v) => record('editingDidEnd:$v'),
          ),
          Slider(
            value: slider,
            max: 100,
            onChanged: (value) {
              setState(() => slider = value);
              record('valueChanged:${value.round()}');
            },
          ),
          TextButton(
            onPressed: () async {
              final date = await showDatePicker(
                context: context,
                firstDate: DateTime(1900),
                lastDate: DateTime(2100),
              );
              if (date != null)
                record(
                  'dateChanged:${date.toIso8601String().substring(0, 10)}',
                );
            },
            child: Text(uiTr(context, '日期')),
          ),
        ]),
        section('按钮覆盖单元格', [
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(uiTr(context, '分组列表与网格')),
            value: grid,
            onChanged: (value) => setState(() => grid = value),
          ),
          if (grid)
            LayoutBuilder(
              builder: (context, c) => Wrap(
                children: [
                  for (var i = 0; i < 4; i++)
                    SizedBox(
                      width: c.maxWidth < 320 ? c.maxWidth : c.maxWidth / 2,
                      child: coverageCell(i),
                    ),
                ],
              ),
            )
          else ...[
            for (var i = 0; i < 2; i++) coverageCell(i),
          ],
        ]),
        for (final event in events) SelectableText(event),
      ],
    ),
  );
}

void main() =>
    runApp(const JobsDemoApp(home: ControlEventsDemo(), title: '控制事件与按钮布局'));
