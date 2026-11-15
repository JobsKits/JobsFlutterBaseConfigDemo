import 'package:flutter/material.dart';
import 'package:jobs_demo_foundation/jobs_demo_foundation.dart';

void main() => runApp(const JobsDemoApp(home: ThrottleDebounceDemo()));

class ThrottleDebounceDemo extends StatefulWidget {
  const ThrottleDebounceDemo({super.key});

  @override
  State<ThrottleDebounceDemo> createState() => _ThrottleDebounceDemoState();
}

class _ThrottleDebounceDemoState extends State<ThrottleDebounceDemo> {
  final _debouncer = JobsDebouncer(const Duration(milliseconds: 500));
  final _throttle = JobsThrottle(const Duration(milliseconds: 500));
  int _raw = 0;
  int _throttled = 0;
  int _debounced = 0;
  String _latest = '';
  String _throttleValue = '';
  String _debounceValue = '';

  void _event(String value) {
    setState(() {
      _raw++;
      _latest = value;
    });
    _throttle.call(
      () => setState(() {
        _throttled++;
        _throttleValue = value;
      }),
    );
    _debouncer.call(() {
      if (mounted) {
        setState(() {
          _debounced++;
          _debounceValue = value;
        });
      }
    });
  }

  @override
  void dispose() {
    _debouncer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(tr(context, '节流防抖'))),
    body: ListView(
      padding: const EdgeInsets.all(20),
      children: [
        TextField(
          key: const ValueKey('debounce-input'),
          decoration: InputDecoration(labelText: tr(context, '输入')),
          onChanged: _event,
        ),
        const SizedBox(height: 16),
        FilledButton(
          onPressed: () => _event('${_raw + 1}'),
          child: Text(tr(context, '生成')),
        ),
        const SizedBox(height: 20),
        for (final row in [
          (tr(context, '原始事件'), _raw, _latest),
          ('${tr(context, '节流执行')} · 500 ms', _throttled, _throttleValue),
          ('${tr(context, '防抖执行')} · 500 ms', _debounced, _debounceValue),
        ])
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      row.$1,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${row.$2}',
                      style: Theme.of(context).textTheme.displaySmall,
                    ),
                    Text(row.$3, maxLines: 2, overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
            ),
          ),
        OutlinedButton(
          onPressed: () {
            _debouncer.cancel();
            _throttle.reset();
            setState(() {
              _raw = 0;
              _throttled = 0;
              _debounced = 0;
              _latest = '';
              _throttleValue = '';
              _debounceValue = '';
            });
          },
          child: Text(tr(context, '清空')),
        ),
      ],
    ),
  );
}
