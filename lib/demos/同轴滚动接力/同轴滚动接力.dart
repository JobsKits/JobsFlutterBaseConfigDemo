// 独立运行：flutter run -t "lib/demos/同轴滚动接力/同轴滚动接力.dart"
// 使用本工程 pubspec.yaml 声明的依赖与资源。

import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:jobs_demo_foundation/jobs_demo_foundation.dart';

import '../../demo_hub/interaction_strings.dart';
import '../../demo_hub/interaction_support.dart';

void main() =>
    runApp(const JobsDemoApp(home: ScrollHandoffDemo(), title: '同轴滚动接力'));

enum ScrollRelayOwner { idle, inner, outer }

class ScrollHandoffController extends ChangeNotifier {
  final inner = ScrollController();
  final outer = ScrollController();
  final pages = PageController();
  ScrollRelayOwner owner = ScrollRelayOwner.idle;
  int handoffs = 0;
  bool _startsInside = false;
  bool _disposed = false;

  void begin({required bool inside}) {
    if (_disposed) return;
    _startsInside = inside;
    owner = inside ? ScrollRelayOwner.inner : ScrollRelayOwner.outer;
    notifyListeners();
  }

  double _consume(
    ScrollController controller,
    double delta,
    ScrollRelayOwner next,
  ) {
    if (!controller.hasClients) return delta;
    final before = controller.offset;
    final after = (before + delta)
        .clamp(
          controller.position.minScrollExtent,
          controller.position.maxScrollExtent,
        )
        .toDouble();
    if ((after - before).abs() < .001) return delta;
    if (owner != next) {
      handoffs++;
      owner = next;
    }
    controller.jumpTo(after);
    return delta - (after - before);
  }

  /// Pixel overflow is handed on within the same update, without a lost frame.
  void move(double scrollDelta) {
    if (_disposed || scrollDelta == 0) return;
    var rest = scrollDelta;
    if (!_startsInside) {
      rest = _consume(outer, rest, ScrollRelayOwner.outer);
    } else if (rest > 0) {
      rest = _consume(inner, rest, ScrollRelayOwner.inner);
      _consume(outer, rest, ScrollRelayOwner.outer);
    } else {
      rest = _consume(outer, rest, ScrollRelayOwner.outer);
      _consume(inner, rest, ScrollRelayOwner.inner);
    }
    notifyListeners();
  }

  void observeOwner(ScrollRelayOwner value) {
    if (_disposed) return;
    owner = value;
    notifyListeners();
  }

  void finish() {
    if (_disposed) return;
    owner = ScrollRelayOwner.idle;
    notifyListeners();
  }

  void reset() {
    if (_disposed) return;
    if (inner.hasClients) inner.jumpTo(0);
    if (outer.hasClients) outer.jumpTo(0);
    if (pages.hasClients) pages.jumpToPage(0);
    owner = ScrollRelayOwner.idle;
    handoffs = 0;
    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    inner.dispose();
    outer.dispose();
    pages.dispose();
    super.dispose();
  }
}

class ScrollHandoffDemo extends StatefulWidget {
  const ScrollHandoffDemo({super.key, this.controller, this.repository});
  final ScrollHandoffController? controller;
  final InteractionRepository? repository;
  @override
  State<ScrollHandoffDemo> createState() => _ScrollHandoffState();
}

class _ScrollHandoffState extends State<ScrollHandoffDemo> {
  late final relay = widget.controller ?? ScrollHandoffController();
  late final repository = widget.repository ?? InteractionRepository();
  final innerKey = GlobalKey();
  bool orthogonal = false;
  bool remote = false;
  double slop = kTouchSlop;
  int revision = 0;
  List<String> rows = List.generate(24, (i) => '${i + 1}');
  @override
  void initState() {
    super.initState();
    _reload();
  }

  Future<void> _reload() async {
    final token = ++revision;
    if (rows.isEmpty) {
      setState(() => rows = List.generate(24, (i) => '${i + 1}'));
    }
    final value = interactionRows(await repository.read('scroll-handoff'));
    if (mounted && token == revision && value != null) {
      setState(() {
        rows = value;
        remote = true;
      });
    }
  }

  Future<void> _write() async {
    final token = ++revision;
    // State operations are sent as a complete demonstration snapshot.
    final value = await repository.write('scroll-handoff-settings', {
      'orthogonal': orthogonal,
      'slop': slop,
    });
    if (!mounted ||
        token != revision ||
        value is! Map ||
        value['orthogonal'] is! bool ||
        value['slop'] is! num) {
      return;
    }
    setState(() {
      orthogonal = value['orthogonal'] as bool;
      slop = (value['slop'] as num).toDouble().clamp(4, 64);
      remote = true;
    });
  }

  bool _inside(Offset point) {
    final box = innerKey.currentContext?.findRenderObject();
    return box is RenderBox &&
        box.hasSize &&
        (box.localToGlobal(Offset.zero) & box.size).contains(point);
  }

  Widget _row(int index) => ListTile(
    leading: CircleAvatar(child: Text('${index + 1}')),
    title: Text('${interactionTr(context, '记录')} ${rows[index]}'),
    subtitle: Text(interactionTr(context, '内层列表')),
  );
  Widget _sameAxis() => RawGestureDetector(
    key: const ValueKey('relay-gesture'),
    behavior: HitTestBehavior.opaque,
    gestures: {
      VerticalDragGestureRecognizer:
          GestureRecognizerFactoryWithHandlers<VerticalDragGestureRecognizer>(
            () =>
                VerticalDragGestureRecognizer()
                  ..onlyAcceptDragOnThreshold = true,
            (recognizer) {
              recognizer.gestureSettings = DeviceGestureSettings(
                touchSlop: slop,
              );
              recognizer.onStart = (event) =>
                  relay.begin(inside: _inside(event.globalPosition));
              recognizer.onUpdate = (event) =>
                  relay.move(-(event.primaryDelta ?? 0));
              recognizer.onEnd = (_) => relay.finish();
              recognizer.onCancel = relay.finish;
            },
          ),
    },
    child: SingleChildScrollView(
      key: const ValueKey('relay-outer'),
      controller: relay.outer,
      physics: const NeverScrollableScrollPhysics(),
      child: Column(
        children: [
          Container(
            height: 110,
            padding: const EdgeInsets.all(16),
            alignment: Alignment.centerLeft,
            color: Theme.of(context).colorScheme.secondaryContainer,
            child: Text(
              interactionTr(context, '先滚内层，到边界后交给外层'),
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSecondaryContainer,
              ),
            ),
          ),
          Card(
            margin: const EdgeInsets.all(12),
            clipBehavior: Clip.antiAlias,
            child: SizedBox(
              key: innerKey,
              height: 290,
              child: ListView.builder(
                key: const ValueKey('relay-inner'),
                controller: relay.inner,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: rows.length,
                itemBuilder: (_, index) => _row(index),
              ),
            ),
          ),
          Container(
            height: 310,
            padding: const EdgeInsets.all(24),
            alignment: Alignment.topLeft,
            color: Theme.of(context).colorScheme.tertiaryContainer,
            child: Text(
              interactionTr(context, '反向先收回外层再滚内层'),
              style: TextStyle(
                color: Theme.of(context).colorScheme.onTertiaryContainer,
              ),
            ),
          ),
        ],
      ),
    ),
  );
  Widget _orthogonal() => NotificationListener<ScrollNotification>(
    onNotification: (event) {
      if (event is ScrollStartNotification && event.dragDetails != null) {
        relay.observeOwner(
          event.metrics.axis == Axis.horizontal
              ? ScrollRelayOwner.outer
              : ScrollRelayOwner.inner,
        );
      } else if (event is ScrollEndNotification) {
        relay.finish();
      }
      return false;
    },
    child: PageView.builder(
      key: const ValueKey('orthogonal-pages'),
      controller: relay.pages,
      itemCount: 3,
      itemBuilder: (context, page) => Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Text(
              '${interactionTr(context, '横向翻页，纵向列表')} · ${page + 1}/3',
            ),
          ),
          Expanded(
            child: MediaQuery(
              data: MediaQuery.of(context).copyWith(
                gestureSettings: const DeviceGestureSettings(
                  touchSlop: kTouchSlop,
                ),
              ),
              child: ListView.builder(
                key: PageStorageKey('orthogonal-list-$page'),
                itemCount: rows.length,
                itemBuilder: (_, index) => _row(index),
              ),
            ),
          ),
        ],
      ),
    ),
  );
  Future<void> _clear() async {
    final token = ++revision;
    setState(() {
      rows = [];
      remote = false;
    });
    final value = interactionRows(
      await repository.write('scroll-handoff', rows),
    );
    if (mounted && token == revision && value != null) {
      setState(() {
        rows = value;
        remote = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: JobsDemoAppBar(
      title: Text(interactionTr(context, '同轴滚动接力')),
      actions: [
        IconButton(
          tooltip: interactionTr(context, '重置位置'),
          onPressed: relay.reset,
          icon: const Icon(Icons.restart_alt),
        ),
      ],
    ),
    body: LayoutBuilder(
      builder: (context, constraints) => Column(
        children: [
          ConstrainedBox(
            constraints: BoxConstraints(maxHeight: constraints.maxHeight * .52),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  interactionStatus(
                    context,
                    remote: remote,
                    reload: _reload,
                    clear: _clear,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Wrap(
                      spacing: 8,
                      children: [
                        ChoiceChip(
                          label: Text(interactionTr(context, '同轴模式')),
                          selected: !orthogonal,
                          onSelected: (_) {
                            relay.reset();
                            setState(() => orthogonal = false);
                            unawaited(_write());
                          },
                        ),
                        ChoiceChip(
                          key: const ValueKey('orthogonal-mode'),
                          label: Text(interactionTr(context, '正交模式')),
                          selected: orthogonal,
                          onSelected: (_) {
                            relay.reset();
                            setState(() => orthogonal = true);
                            unawaited(_write());
                          },
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: Text(interactionTr(context, '手势阈值')),
                        ),
                        Expanded(
                          flex: 3,
                          child: Slider(
                            value: slop,
                            min: 4,
                            max: 64,
                            divisions: 15,
                            label: '${slop.round()} px',
                            onChanged: (value) => setState(() => slop = value),
                            onChangeEnd: (_) => unawaited(_write()),
                          ),
                        ),
                        Text('${slop.round()} px'),
                      ],
                    ),
                  ),
                  AnimatedBuilder(
                    animation: relay,
                    builder: (context, _) => Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      child: Wrap(
                        spacing: 12,
                        children: [
                          Text(
                            '${interactionTr(context, '当前接管')}: ${interactionTr(context, switch (relay.owner) {
                              ScrollRelayOwner.inner => '内层列表',
                              ScrollRelayOwner.outer => '外层容器',
                              _ => '等待手势',
                            })}',
                          ),
                          Text(
                            '${interactionTr(context, '边界交接次数')}: ${relay.handoffs}',
                          ),
                          Text(
                            '↕ ${relay.inner.hasClients ? relay.inner.offset.toStringAsFixed(0) : '0'} / ${relay.outer.hasClients ? relay.outer.offset.toStringAsFixed(0) : '0'} px',
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (!orthogonal)
                    Text(
                      interactionTr(context, '手势结束即停'),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                ],
              ),
            ),
          ),
          Expanded(
            child: rows.isEmpty
                ? interactionEmpty(context, _reload)
                : MediaQuery(
                    data: MediaQuery.of(context).copyWith(
                      gestureSettings: DeviceGestureSettings(touchSlop: slop),
                    ),
                    child: orthogonal ? _orthogonal() : _sameAxis(),
                  ),
          ),
        ],
      ),
    ),
  );
  @override
  void dispose() {
    revision++;
    if (widget.repository == null) repository.dispose();
    if (widget.controller == null) relay.dispose();
    super.dispose();
  }
}
