// 独立运行：flutter run -t "lib/demos/礼物双槽连击/礼物双槽连击.dart"
// 使用本工程 pubspec.yaml 声明的依赖与资源。

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:jobs_demo_foundation/jobs_demo_foundation.dart';

import '../../demo_hub/interaction_strings.dart';
import '../../demo_hub/interaction_support.dart';

void main() =>
    runApp(const JobsDemoApp(home: GiftComboDemo(), title: '礼物双槽连击'));

class GiftCombo {
  const GiftCombo(this.giftId, this.count, {this.expiresAt});
  final String giftId;
  final int count;
  final DateTime? expiresAt;
  Map<String, Object?> toJson() => {
    'giftId': giftId,
    'count': count,
    if (expiresAt != null) 'expiresAt': expiresAt!.millisecondsSinceEpoch,
  };
}

class GiftComboEvent {
  const GiftComboEvent(this.eventId, this.giftId, {this.count = 1});
  final String eventId;
  final String giftId;
  final int count;
}

class GiftComboRecord {
  const GiftComboRecord(this.combo, {required this.cancelled});
  final GiftCombo combo;
  final bool cancelled;
}

/// Gift identity, transport identity and stable slot identity have separate roles.
class GiftComboController extends ChangeNotifier {
  GiftComboController({
    this.duration = const Duration(milliseconds: 2600),
    DateTime Function()? now,
  }) : _now = now ?? DateTime.now;
  final Duration duration;
  final DateTime Function() _now;
  final _slots = <GiftCombo?>[null, null];
  final _pending = <GiftCombo>[];
  final _timers = <int, Timer>{};
  final _seen = <String>{};
  final _history = <GiftComboRecord>[];
  bool _disposed = false;
  int version = 0;
  void _changed() {
    version++;
    notifyListeners();
  }

  List<GiftCombo?> get slots => List.unmodifiable(_slots);
  List<GiftCombo> get pending => List.unmodifiable(_pending);
  List<GiftComboRecord> get history => List.unmodifiable(_history);
  int get timerCount => _timers.length;
  bool get isEmpty => _pending.isEmpty && _slots.every((slot) => slot == null);
  bool add(GiftComboEvent event) {
    if (_disposed ||
        event.eventId.isEmpty ||
        event.giftId.isEmpty ||
        event.count <= 0 ||
        event.count > 9999 ||
        _seen.contains(event.eventId)) {
      return false;
    }
    _seen.add(event.eventId);
    if (_seen.length > 256) _seen.remove(_seen.first);
    final active = _slots.indexWhere((slot) => slot?.giftId == event.giftId);
    if (active >= 0) {
      final next = GiftCombo(
        event.giftId,
        (_slots[active]!.count + event.count).clamp(1, 1000000),
        expiresAt: _now().add(duration),
      );
      _slots[active] = next;
      _arm(active, next);
    } else {
      final waiting = _pending.indexWhere(
        (combo) => combo.giftId == event.giftId,
      );
      if (waiting >= 0) {
        _pending[waiting] = GiftCombo(
          event.giftId,
          (_pending[waiting].count + event.count).clamp(1, 1000000),
        );
      } else {
        _pending.add(GiftCombo(event.giftId, event.count));
      }
      _fill();
    }
    _changed();
    return true;
  }

  void _arm(int index, GiftCombo combo) {
    _timers.remove(index)?.cancel();
    final remaining = combo.expiresAt!.difference(_now());
    _timers[index] = Timer(
      remaining.isNegative ? Duration.zero : remaining,
      () {
        if (_disposed || !identical(_slots[index], combo)) return;
        _timers.remove(index);
        _record(combo, cancelled: false);
        _slots[index] = null;
        _fill();
        _changed();
      },
    );
  }

  void _fill() {
    for (var slot = 0; slot < 2 && _pending.isNotEmpty; slot++) {
      if (_slots[slot] != null) continue;
      final waiting = _pending.removeAt(0);
      final active = GiftCombo(
        waiting.giftId,
        waiting.count,
        expiresAt: _now().add(duration),
      );
      _slots[slot] = active;
      _arm(slot, active);
    }
  }

  void _record(GiftCombo combo, {required bool cancelled}) {
    _history.insert(0, GiftComboRecord(combo, cancelled: cancelled));
    if (_history.length > 30) _history.removeLast();
  }

  void cancel(String giftId) {
    if (_disposed) return;
    var changed = false;
    for (var index = 0; index < 2; index++) {
      final slot = _slots[index];
      if (slot?.giftId != giftId) continue;
      _timers.remove(index)?.cancel();
      _record(slot!, cancelled: true);
      _slots[index] = null;
      changed = true;
    }
    final waiting = _pending.indexWhere((combo) => combo.giftId == giftId);
    if (waiting >= 0) {
      _record(_pending.removeAt(waiting), cancelled: true);
      changed = true;
    }
    if (changed) {
      _fill();
      _changed();
    }
  }

  void clear() {
    if (_disposed) return;
    for (final timer in _timers.values) {
      timer.cancel();
    }
    _timers.clear();
    _slots.fillRange(0, 2, null);
    _pending.clear();
    _history.clear();
    // Keep the bounded event ledger so cancellation does not resurrect an event.
    _changed();
  }

  Map<String, Object> toJson() => {
    'active': _slots.map((s) => s?.toJson()).toList(),
    'pending': _pending.map((s) => s.toJson()).toList(),
    'seen': _seen.toList(),
  };
  bool apply(Object? value) {
    if (_disposed ||
        value is! Map ||
        value['active'] is! List ||
        value['pending'] is! List ||
        value['seen'] is! List) {
      return false;
    }
    final active = value['active'] as List;
    final pending = value['pending'] as List;
    final seen = value['seen'] as List;
    if (active.length != 2 ||
        pending.length > 200 ||
        seen.length > 256 ||
        !seen.every((e) => e is String && e.isNotEmpty)) {
      return false;
    }
    final ids = <String>{};
    GiftCombo? decode(Object? row, bool playing) {
      if (row is! Map ||
          row['giftId'] is! String ||
          (row['giftId'] as String).isEmpty ||
          row['count'] is! int ||
          (row['count'] as int) < 1 ||
          (row['count'] as int) > 1000000 ||
          !ids.add(row['giftId'] as String)) {
        return null;
      }
      if (playing && row['expiresAt'] is! int) return null;
      final stamp = playing ? row['expiresAt'] as int : null;
      if (stamp != null && (stamp < 0 || stamp > 8640000000000000)) return null;
      return GiftCombo(
        row['giftId'] as String,
        row['count'] as int,
        expiresAt: stamp == null
            ? null
            : DateTime.fromMillisecondsSinceEpoch(stamp),
      );
    }

    final nextSlots = <GiftCombo?>[];
    final nextPending = <GiftCombo>[];
    for (final row in active) {
      final item = row == null ? null : decode(row, true);
      if (row != null && item == null) return false;
      nextSlots.add(item);
    }
    for (final row in pending) {
      final item = decode(row, false);
      if (item == null) return false;
      nextPending.add(item);
    }
    for (final timer in _timers.values) {
      timer.cancel();
    }
    _timers.clear();
    _slots.setAll(0, nextSlots);
    _pending
      ..clear()
      ..addAll(nextPending);
    _seen.addAll(seen.cast<String>());
    while (_seen.length > 256) {
      _seen.remove(_seen.first);
    }
    for (var index = 0; index < 2; index++) {
      if (_slots[index] != null) _arm(index, _slots[index]!);
    }
    _fill();
    _changed();
    return true;
  }

  @override
  void dispose() {
    _disposed = true;
    for (final timer in _timers.values) {
      timer.cancel();
    }
    _timers.clear();
    super.dispose();
  }
}

class GiftComboDemo extends StatefulWidget {
  const GiftComboDemo({super.key, this.controller, this.repository});
  final GiftComboController? controller;
  final InteractionRepository? repository;
  @override
  State<GiftComboDemo> createState() => _GiftComboState();
}

class _GiftComboState extends State<GiftComboDemo> {
  late final model = widget.controller ?? GiftComboController();
  late final repository = widget.repository ?? InteractionRepository();
  static const names = {'star': '星星', 'heart': '爱心', 'rocket': '火箭'};
  static const icons = {
    'star': Icons.star_rounded,
    'heart': Icons.favorite,
    'rocket': Icons.rocket_launch,
  };
  String selected = 'star';
  GiftComboEvent? lastEvent;
  int sequence = 0;
  int revision = 0;
  bool remote = false;
  bool duplicate = false;
  @override
  void initState() {
    super.initState();
    _reload();
  }

  Future<void> _reload() async {
    final token = ++revision;
    final snapshotVersion = model.version;
    final value = await repository.read('gift-combos');
    if (mounted &&
        token == revision &&
        snapshotVersion == model.version &&
        model.apply(value)) {
      setState(() => remote = true);
    }
  }

  Future<void> _save() async {
    final token = ++revision;
    setState(() => remote = false);
    final snapshotVersion = model.version;
    final value = await repository.write('gift-combos', model.toJson());
    if (mounted &&
        token == revision &&
        snapshotVersion == model.version &&
        model.apply(value)) {
      setState(() => remote = true);
    }
  }

  void _send({bool replay = false}) {
    if (replay && lastEvent == null) return;
    final event = replay
        ? lastEvent!
        : GiftComboEvent(
            '${DateTime.now().microsecondsSinceEpoch}-${++sequence}',
            selected,
          );
    final accepted = model.add(event);
    setState(() {
      duplicate = !accepted;
      lastEvent = event;
    });
    unawaited(_save());
  }

  void _cancel(String gift) {
    model.cancel(gift);
    unawaited(_save());
  }

  Widget _slot(GiftCombo? combo, int index) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      key: ValueKey('gift-slot-$index'),
      constraints: const BoxConstraints(minHeight: 105),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: combo == null
            ? colors.surfaceContainerHighest
            : colors.primaryContainer,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: combo == null
          ? Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('${interactionTr(context, '槽位')} ${index + 1}'),
                Text(
                  interactionTr(context, '空槽等待新礼物'),
                  textAlign: TextAlign.center,
                ),
              ],
            )
          : Row(
              children: [
                Icon(
                  icons[combo.giftId] ?? Icons.card_giftcard,
                  color: colors.onPrimaryContainer,
                  size: 36,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        interactionTr(
                          context,
                          names[combo.giftId] ?? combo.giftId,
                        ),
                        style: TextStyle(color: colors.onPrimaryContainer),
                      ),
                      AnimatedSwitcher(
                        duration: MediaQuery.disableAnimationsOf(context)
                            ? Duration.zero
                            : const Duration(milliseconds: 180),
                        child: Text(
                          '×${combo.count}',
                          key: ValueKey('${combo.giftId}-${combo.count}'),
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(color: colors.onPrimaryContainer),
                        ),
                      ),
                      Text(
                        '${interactionTr(context, '连击')} · ${interactionTr(context, '播放中')}',
                        style: TextStyle(color: colors.onPrimaryContainer),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: interactionTr(context, '取消'),
                  onPressed: () => _cancel(combo.giftId),
                  icon: Icon(Icons.close, color: colors.onPrimaryContainer),
                ),
              ],
            ),
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: JobsDemoAppBar(title: Text(interactionTr(context, '礼物双槽连击'))),
    body: Column(
      children: [
        interactionStatus(
          context,
          remote: remote,
          reload: _reload,
          clear: () {
            model.clear();
            unawaited(_save());
          },
        ),
        Expanded(
          child: AnimatedBuilder(
            animation: model,
            builder: (context, _) => ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text(
                  interactionTr(context, '同类礼物合并，更新到期时间'),
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  children: names.entries
                      .map(
                        (entry) => ChoiceChip(
                          label: Text(interactionTr(context, entry.value)),
                          avatar: Icon(icons[entry.key], size: 18),
                          selected: selected == entry.key,
                          onSelected: (_) =>
                              setState(() => selected = entry.key),
                        ),
                      )
                      .toList(),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: [
                    FilledButton.icon(
                      key: const ValueKey('gift-send'),
                      onPressed: _send,
                      icon: const Icon(Icons.card_giftcard),
                      label: Text(interactionTr(context, '发送')),
                    ),
                    OutlinedButton(
                      key: const ValueKey('gift-replay'),
                      onPressed: lastEvent == null
                          ? null
                          : () => _send(replay: true),
                      child: Text(interactionTr(context, '重放相同事件')),
                    ),
                  ],
                ),
                if (lastEvent != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      '${interactionTr(context, '事件编号')}: ${lastEvent!.eventId}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                if (duplicate)
                  Text(
                    interactionTr(context, '重复事件已忽略'),
                    key: const ValueKey('gift-duplicate'),
                  ),
                const SizedBox(height: 12),
                for (var slot = 0; slot < 2; slot++)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _slot(model.slots[slot], slot),
                  ),
                Text(
                  '${interactionTr(context, '等待队列')} (${model.pending.length})',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                if (model.pending.isEmpty)
                  interactionEmpty(context, _reload)
                else
                  for (final combo in model.pending)
                    ListTile(
                      key: ValueKey('pending-${combo.giftId}'),
                      leading: Icon(icons[combo.giftId] ?? Icons.card_giftcard),
                      title: Text(
                        '${interactionTr(context, names[combo.giftId] ?? combo.giftId)} ×${combo.count}',
                      ),
                      trailing: IconButton(
                        tooltip: interactionTr(context, '取消'),
                        onPressed: () => _cancel(combo.giftId),
                        icon: const Icon(Icons.close),
                      ),
                    ),
                if (model.history.isNotEmpty) ...[
                  const Divider(),
                  Text(
                    interactionTr(context, '已完成'),
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  for (final entry in model.history)
                    ListTile(
                      dense: true,
                      leading: Icon(
                        entry.cancelled
                            ? Icons.cancel_outlined
                            : Icons.done_all,
                      ),
                      title: Text(
                        '${interactionTr(context, names[entry.combo.giftId] ?? entry.combo.giftId)} ×${entry.combo.count}',
                      ),
                      subtitle: Text(
                        interactionTr(context, entry.cancelled ? '已取消' : '已完成'),
                      ),
                    ),
                ],
              ],
            ),
          ),
        ),
      ],
    ),
  );
  @override
  void dispose() {
    revision++;
    if (widget.controller == null) model.dispose();
    if (widget.repository == null) repository.dispose();
    super.dispose();
  }
}
