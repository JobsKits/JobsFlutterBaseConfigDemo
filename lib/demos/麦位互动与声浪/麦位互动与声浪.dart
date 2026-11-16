// 独立运行：flutter run -t "lib/demos/麦位互动与声浪/麦位互动与声浪.dart"
// 使用本工程 pubspec.yaml 声明的依赖与资源。

import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:jobs_demo_foundation/jobs_demo_foundation.dart';

import '../../demo_hub/interaction_strings.dart';
import '../../demo_hub/interaction_support.dart';

void main() =>
    runApp(const JobsDemoApp(home: VoiceSeatDemo(), title: '麦位互动与声浪'));

class VoiceSeat {
  const VoiceSeat({this.name, this.muted = false});
  final String? name;
  final bool muted;
}

class VoiceSeatController extends ChangeNotifier {
  List<VoiceSeat> seats = initialSeats();
  int selected = 0;
  double level = .65;
  static List<VoiceSeat> initialSeats() => List.generate(
    8,
    (i) => VoiceSeat(
      name: switch (i) {
        1 => 'Mia',
        5 => 'Alex',
        _ => null,
      },
    ),
  );
  int get mine => seats.indexWhere((seat) => seat.name == 'Jobs');
  bool get canJoin => seats.isNotEmpty && seats[selected].name == null;
  void select(int index) {
    if (index < 0 || index >= seats.length) return;
    selected = index;
    notifyListeners();
  }

  bool join() {
    if (!canJoin) return false;
    if (mine >= 0) seats[mine] = const VoiceSeat();
    seats[selected] = const VoiceSeat(name: 'Jobs');
    notifyListeners();
    return true;
  }

  void leave() {
    if (mine < 0) return;
    seats[mine] = const VoiceSeat();
    notifyListeners();
  }

  void toggleMute() {
    if (mine < 0) return;
    final index = mine;
    seats[index] = VoiceSeat(name: 'Jobs', muted: !seats[index].muted);
    notifyListeners();
  }

  void volume(double value) {
    level = value.clamp(0, 1);
    notifyListeners();
  }

  void clear() {
    seats = [];
    selected = 0;
    notifyListeners();
  }

  void reset() {
    seats = initialSeats();
    selected = 0;
    notifyListeners();
  }

  Map<String, Object> toJson() => {
    'seats': seats
        .map((seat) => {'name': seat.name, 'muted': seat.muted})
        .toList(),
    'selected': selected,
    'level': level,
  };
  bool apply(Object? value) {
    if (value is! Map ||
        value['seats'] is! List ||
        value['selected'] is! int ||
        value['level'] is! num) {
      return false;
    }
    final rows = value['seats'] as List;
    if (rows.length > 16 ||
        !(value['level'] as num).isFinite ||
        (value['level'] as num) < 0 ||
        (value['level'] as num) > 1) {
      return false;
    }
    final next = <VoiceSeat>[];
    for (final row in rows) {
      if (row is! Map ||
          (row['name'] != null && row['name'] is! String) ||
          row['muted'] is! bool) {
        return false;
      }
      next.add(
        VoiceSeat(name: row['name'] as String?, muted: row['muted'] as bool),
      );
    }
    if (next.where((s) => s.name == 'Jobs').length > 1 ||
        (next.isNotEmpty &&
            ((value['selected'] as int) < 0 ||
                (value['selected'] as int) >= next.length))) {
      return false;
    }
    seats = next;
    selected = next.isEmpty ? 0 : value['selected'] as int;
    level = (value['level'] as num).toDouble();
    notifyListeners();
    return true;
  }
}

class VoiceSeatDemo extends StatefulWidget {
  const VoiceSeatDemo({super.key, this.repository, this.controller});
  final InteractionRepository? repository;
  final VoiceSeatController? controller;
  @override
  State<VoiceSeatDemo> createState() => _VoiceSeatState();
}

class _VoiceSeatState extends State<VoiceSeatDemo>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late final model = widget.controller ?? VoiceSeatController();
  late final repository = widget.repository ?? InteractionRepository();
  late final waves = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1800),
  );
  bool foreground = true;
  bool remote = false;
  int revision = 0;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    model.addListener(_modelChanged);
    _reload();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncAnimation();
  }

  void _syncAnimation() {
    final active =
        foreground &&
        TickerMode.valuesOf(context).enabled &&
        !MediaQuery.disableAnimationsOf(context) &&
        model.seats.any((seat) => seat.name != null && !seat.muted);
    if (active && !waves.isAnimating) {
      waves.repeat();
    } else if (!active && waves.isAnimating)
      waves.stop();
  }

  void _modelChanged() {
    if (mounted) {
      _syncAnimation();
      setState(() {});
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    foreground = state == AppLifecycleState.resumed;
    _syncAnimation();
  }

  Future<void> _reload() async {
    final token = ++revision;
    if (model.seats.isEmpty) model.reset();
    final value = await repository.read('voice-seats');
    if (mounted && token == revision && model.apply(value)) {
      setState(() => remote = true);
    }
  }

  Future<void> _save() async {
    final token = ++revision;
    setState(() => remote = false);
    final value = await repository.write('voice-seats', model.toJson());
    if (mounted && token == revision && model.apply(value)) {
      setState(() => remote = true);
    }
  }

  void _change(VoidCallback action) {
    action();
    unawaited(_save());
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: JobsDemoAppBar(title: Text(interactionTr(context, '麦位互动与声浪'))),
      body: Column(
        children: [
          interactionStatus(
            context,
            remote: remote,
            reload: _reload,
            clear: () => _change(model.clear),
          ),
          Expanded(
            child: model.seats.isEmpty
                ? interactionEmpty(context, _reload)
                : LayoutBuilder(
                    builder: (context, constraints) => ListView(
                      padding: const EdgeInsets.all(16),
                      children: [
                        Text(
                          interactionTr(context, '仅演示波形，不接入真实音频或RTC'),
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          interactionTr(context, '后台时暂停波形'),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          '${interactionTr(context, '选中麦位')}: ${model.selected + 1} · ${interactionTr(context, model.seats[model.selected].name == null ? '空闲' : '已占用')}',
                        ),
                        const SizedBox(height: 12),
                        GridView.builder(
                          key: const ValueKey('voice-seat-grid'),
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: model.seats.length,
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: constraints.maxWidth >= 620
                                    ? 4
                                    : 2,
                                crossAxisSpacing: 12,
                                mainAxisSpacing: 12,
                                mainAxisExtent:
                                    150 *
                                    MediaQuery.textScalerOf(context)
                                        .scale(14)
                                        .clamp(14, 22) /
                                    14,
                              ),
                          itemBuilder: (context, index) {
                            final seat = model.seats[index];
                            final chosen = model.selected == index;
                            return Semantics(
                              selected: chosen,
                              label:
                                  '${interactionTr(context, '选中麦位')} ${index + 1}',
                              child: Material(
                                color: chosen
                                    ? colors.primaryContainer
                                    : colors.surfaceContainerHighest,
                                shape: RoundedRectangleBorder(
                                  side: BorderSide(
                                    color: chosen
                                        ? colors.primary
                                        : colors.outlineVariant,
                                    width: chosen ? 2 : 1,
                                  ),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                clipBehavior: Clip.antiAlias,
                                child: InkWell(
                                  key: ValueKey('voice-seat-$index'),
                                  onTap: () =>
                                      _change(() => model.select(index)),
                                  child: Padding(
                                    padding: const EdgeInsets.all(12),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          seat.name == null
                                              ? Icons.mic_none
                                              : (seat.muted
                                                    ? Icons.mic_off
                                                    : Icons.mic),
                                          color: chosen
                                              ? colors.onPrimaryContainer
                                              : colors.onSurface,
                                          size: 28,
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          seat.name ??
                                              '${interactionTr(context, '空闲')} ${index + 1}',
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            color: chosen
                                                ? colors.onPrimaryContainer
                                                : colors.onSurface,
                                          ),
                                        ),
                                        if (seat.name == 'Jobs')
                                          Text(
                                            interactionTr(context, '我的麦位'),
                                            maxLines: 1,
                                            style: Theme.of(context)
                                                .textTheme
                                                .labelSmall,
                                          ),
                                        const SizedBox(height: 8),
                                        SizedBox(
                                          height: 20,
                                          width: 94,
                                          child: AnimatedBuilder(
                                            animation: waves,
                                            builder: (_, _) => CustomPaint(
                                              painter: _VoiceWavePainter(
                                                phase:
                                                    waves.value * math.pi * 2 +
                                                    index,
                                                level:
                                                    seat.name != null &&
                                                        !seat.muted
                                                    ? model.level
                                                    : 0,
                                                color: chosen
                                                    ? colors.onPrimaryContainer
                                                    : colors.primary,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 16),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            FilledButton.icon(
                              key: const ValueKey('voice-join'),
                              onPressed: model.canJoin
                                  ? () => _change(model.join)
                                  : null,
                              icon: const Icon(Icons.login),
                              label: Text(interactionTr(context, '入座')),
                            ),
                            OutlinedButton.icon(
                              key: const ValueKey('voice-leave'),
                              onPressed: model.mine >= 0
                                  ? () => _change(model.leave)
                                  : null,
                              icon: const Icon(Icons.logout),
                              label: Text(interactionTr(context, '离座')),
                            ),
                            OutlinedButton.icon(
                              key: const ValueKey('voice-mute'),
                              onPressed: model.mine >= 0
                                  ? () => _change(model.toggleMute)
                                  : null,
                              icon: const Icon(Icons.mic_off),
                              label: Text(
                                interactionTr(
                                  context,
                                  model.mine >= 0 &&
                                          model.seats[model.mine].muted
                                      ? '取消静音'
                                      : '静音',
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          '${interactionTr(context, '模拟声量')}: ${(model.level * 100).round()}%',
                        ),
                        Slider(
                          value: model.level,
                          onChanged: (value) {
                            revision++;
                            remote = false;
                            model.volume(value);
                          },
                          onChangeEnd: (_) => unawaited(_save()),
                        ),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    revision++;
    WidgetsBinding.instance.removeObserver(this);
    model.removeListener(_modelChanged);
    waves.dispose();
    if (widget.controller == null) model.dispose();
    if (widget.repository == null) repository.dispose();
    super.dispose();
  }
}

class _VoiceWavePainter extends CustomPainter {
  const _VoiceWavePainter({
    required this.phase,
    required this.level,
    required this.color,
  });
  final double phase;
  final double level;
  final Color color;
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    for (var i = 0; i < 12; i++) {
      final envelope = .15 + .85 * math.sin((i + 1) * math.pi / 13);
      final height =
          2 +
          (size.height - 3) *
              level *
              envelope *
              (.35 + .65 * (math.sin(phase + i * .8).abs()));
      final x = (i + .5) * size.width / 12;
      canvas.drawLine(
        Offset(x, (size.height - height) / 2),
        Offset(x, (size.height + height) / 2),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_VoiceWavePainter oldDelegate) =>
      phase != oldDelegate.phase ||
      level != oldDelegate.level ||
      color != oldDelegate.color;
}
