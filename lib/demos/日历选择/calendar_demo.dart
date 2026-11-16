// 独立运行：flutter run -t "lib/demos/日历选择/calendar_demo.dart"
// 使用本工程 pubspec.yaml 声明的依赖与资源。

import 'package:flutter/material.dart';

import '../../demo_hub/extra_support.dart';

import 'package:jobs_demo_foundation/jobs_demo_foundation.dart';

void main() => runApp(const JobsDemoApp(home: CalendarDemo()));

class CalendarDemo extends StatefulWidget {
  const CalendarDemo({super.key});

  @override
  State<CalendarDemo> createState() => _CalendarDemoState();
}

class _CalendarDemoState extends State<CalendarDemo> {
  late DateTime _month;
  final _selected = <DateTime>{};
  DateTime? _rangeStart;
  DateTime? _rangeEnd;
  String _mode = '1';
  final _painted = <DateTime>{};
  DateTime? _paintStart;
  static const holidays = <String, String>{
    '1/1': '新年',
    '4/5': '清明节',
    '5/1': '劳动节',
    '6/4': '端午节',
    '10/1': '国庆节',
    '9/13': '中秋节',
    '12/25': '圣诞节',
    '11/30': '博尼法西奥日',
    '6/12': '独立日',
    '4/9': '勇士日',
    '11/1': '万灵节',
    '12/30': '黎刹日',
  };
  void _paintDay(
    Offset offset,
    double width,
    double height,
    int leading,
    int days,
  ) {
    if (offset.dx < 0 || offset.dx >= width || offset.dy < 0) return;
    final index =
        (offset.dy / (height + 4)).floor() * 7 +
        (offset.dx / ((width + 4) / 7)).floor();
    final number = index - leading + 1;
    if (number < 1 || number > days) return;
    final day = DateTime(_month.year, _month.month, number);
    if (!_painted.add(day)) return;
    _paintStart ??= day;
    if (_mode == 'range') {
      setState(() {
        _rangeStart = day.isBefore(_paintStart!) ? day : _paintStart;
        _rangeEnd = day.isBefore(_paintStart!) ? _paintStart : day;
      });
    } else {
      _select(day);
    }
  }

  @override
  void initState() {
    super.initState();
    final today = DateTime.now();
    _month = DateTime(today.year, today.month);
    _selected.add(DateUtils.dateOnly(today));
  }

  String _date(DateTime value) =>
      '${value.year}-${value.month.toString().padLeft(2, '0')}-${value.day.toString().padLeft(2, '0')}';

  void _select(DateTime day) => setState(() {
    if (_mode == 'range') {
      if (_rangeStart == null || _rangeEnd != null) {
        _rangeStart = day;
        _rangeEnd = null;
      } else if (day.isBefore(_rangeStart!)) {
        _rangeEnd = _rangeStart;
        _rangeStart = day;
      } else {
        _rangeEnd = day;
      }
    } else if (_mode == 'many') {
      if (!_selected.remove(day)) _selected.add(day);
    } else {
      _selected
        ..clear()
        ..add(day);
    }
  });

  bool _isSelected(DateTime day) {
    if (_mode != 'range') return _selected.contains(day);
    if (_rangeStart == null) return false;
    return !day.isBefore(_rangeStart!) &&
        !day.isAfter(_rangeEnd ?? _rangeStart!);
  }

  void _changeMonth(int amount) => setState(() {
    _month = DateTime(_month.year, _month.month + amount);
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final material = MaterialLocalizations.of(context);
    final today = DateUtils.dateOnly(DateTime.now());
    final leadingDays = (_month.weekday - material.firstDayOfWeekIndex) % 7;
    final days = DateUtils.getDaysInMonth(_month.year, _month.month);
    final cellCount = ((leadingDays + days) / 7).ceil() * 7;
    final selected = _selected.toList()..sort();
    final summary = _mode == 'range'
        ? [_rangeStart, _rangeEnd].whereType<DateTime>().map(_date).join(' → ')
        : selected.map(_date).join(' · ');
    return Scaffold(
      appBar: JobsDemoAppBar(title: Text(tr(context, '日历'))),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ChoiceChip(
                label: const Text('1'),
                selected: _mode == '1',
                onSelected: (_) => setState(() {
                  _mode = '1';
                  if (_selected.length > 1) {
                    final first = _selected.reduce(
                      (a, b) => a.isBefore(b) ? a : b,
                    );
                    _selected
                      ..clear()
                      ..add(first);
                  }
                }),
              ),
              ChoiceChip(
                label: Text(tr(context, '多选')),
                selected: _mode == 'many',
                onSelected: (_) => setState(() => _mode = 'many'),
              ),
              ChoiceChip(
                label: Text(tr(context, '日期范围')),
                selected: _mode == 'range',
                onSelected: (_) => setState(() => _mode = 'range'),
              ),
              TextButton(
                onPressed: () => setState(() {
                  _month = DateTime(today.year, today.month);
                  _selected
                    ..clear()
                    ..add(today);
                  _rangeStart = today;
                  _rangeEnd = null;
                }),
                child: Text(tr(context, '今天')),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              IconButton(
                onPressed: _month.year > 2000 || _month.month > 1
                    ? () => _changeMonth(-1)
                    : null,
                tooltip: tr(context, '上一月'),
                icon: const Icon(Icons.chevron_left),
              ),
              Expanded(
                child: Text(
                  material.formatMonthYear(_month),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              IconButton(
                onPressed: _month.year < 2100 || _month.month < 12
                    ? () => _changeMonth(1)
                    : null,
                tooltip: tr(context, '下一月'),
                icon: const Icon(Icons.chevron_right),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: List.generate(
              7,
              (index) => Expanded(
                child: Text(
                  material.narrowWeekdays[(index +
                          material.firstDayOfWeekIndex) %
                      7],
                  textAlign: TextAlign.center,
                  style: TextStyle(color: colors.onSurfaceVariant),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          LayoutBuilder(
            builder: (context, constraints) => GestureDetector(
              onPanStart: (event) {
                _painted.clear();
                _paintStart = null;
                _paintDay(
                  event.localPosition,
                  constraints.maxWidth,
                  (constraints.maxWidth / 7).clamp(44, 64),
                  leadingDays,
                  days,
                );
              },
              onPanUpdate: (event) => _paintDay(
                event.localPosition,
                constraints.maxWidth,
                (constraints.maxWidth / 7).clamp(44, 64),
                leadingDays,
                days,
              ),
              onPanEnd: (_) {
                _painted.clear();
                _paintStart = null;
              },
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: cellCount,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 7,
                  mainAxisSpacing: 4,
                  crossAxisSpacing: 4,
                  mainAxisExtent: (constraints.maxWidth / 7).clamp(44, 64),
                ),
                itemBuilder: (context, index) {
                  final number = index - leadingDays + 1;
                  if (number < 1 || number > days)
                    return const SizedBox.shrink();
                  final day = DateTime(_month.year, _month.month, number);
                  final selected = _isSelected(day);
                  final holiday = holidays['${day.month}/${day.day}'];
                  return Semantics(
                    selected: selected,
                    button: true,
                    label: material.formatFullDate(day),
                    child: Material(
                      color: selected
                          ? (holiday == null ? colors.primary : colors.tertiary)
                          : colors.surfaceContainerLow,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: day == today
                            ? BorderSide(color: colors.primary, width: 2)
                            : BorderSide.none,
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: InkWell(
                        key: ValueKey('calendar-day-${_date(day)}'),
                        onTap: () => _select(day),
                        child: Center(
                          child: FittedBox(
                            child: Padding(
                              padding: const EdgeInsets.all(4),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    '$number',
                                    style: TextStyle(
                                      color: selected
                                          ? colors.onPrimary
                                          : colors.onSurface,
                                    ),
                                  ),
                                  if (holiday != null) ...[
                                    Text(
                                      extraTr(context, holiday),
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: selected
                                            ? colors.onPrimary
                                            : colors.tertiary,
                                      ),
                                    ),
                                    Container(
                                      width: 4,
                                      height: 4,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: selected
                                            ? colors.onPrimary
                                            : colors.tertiary,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            tr(context, '已选择'),
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          if (summary.isEmpty)
            JobsEmptyState(
              title: '无数据',
              onReload: () => setState(() {
                _selected.add(today);
                _rangeStart = today;
              }),
            )
          else
            SelectableText(summary),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: () => setState(() {
              _selected.clear();
              _rangeStart = null;
              _rangeEnd = null;
            }),
            child: Text(tr(context, '清空')),
          ),
        ],
      ),
    );
  }
}
