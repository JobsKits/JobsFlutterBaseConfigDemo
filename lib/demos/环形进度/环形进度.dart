import 'dart:async';

import 'package:flutter/material.dart';
import 'package:jobs_demo_foundation/jobs_demo_foundation.dart';

void main() => runApp(const JobsDemoApp(home: CircularProgressDemo()));

class CircularProgressDemo extends StatefulWidget {
  const CircularProgressDemo({super.key});
  @override
  State<CircularProgressDemo> createState() => _CircularProgressDemoState();
}

class _CircularProgressDemoState extends State<CircularProgressDemo> {
  double _progress = .35;
  Timer? _timer;
  void _toggle() {
    if (_timer != null) {
      _timer?.cancel();
      setState(() => _timer = null);
      return;
    }
    if (_progress >= 1) _progress = 0;
    _timer = Timer.periodic(
      const Duration(milliseconds: 80),
      (_) => setState(() {
        _progress = (_progress + .01).clamp(0, 1);
        if (_progress == 1) {
          _timer?.cancel();
          _timer = null;
        }
      }),
    );
    setState(() {});
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(tr(context, '环形进度'))),
    body: ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const SizedBox(height: 32),
        Center(
          child: SizedBox(
            width: 220,
            height: 220,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox.expand(
                  child: CircularProgressIndicator(
                    value: _progress,
                    strokeWidth: 18,
                    strokeCap: StrokeCap.round,
                    backgroundColor: Theme.of(context)
                        .colorScheme
                        .surfaceContainerHighest,
                  ),
                ),
                Text(
                  '${(_progress * 100).round()}%',
                  style: Theme.of(context).textTheme.displayMedium,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 36),
        Slider(
          value: _progress,
          onChanged: (value) => setState(() => _progress = value),
        ),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 12,
          children: [
            FilledButton.icon(
              onPressed: _toggle,
              icon: Icon(_timer == null ? Icons.play_arrow : Icons.pause),
              label: Text(tr(context, _timer == null ? '播放' : '暂停')),
            ),
            OutlinedButton(
              onPressed: () => setState(() {
                _timer?.cancel();
                _timer = null;
                _progress = 0;
              }),
              child: Text(tr(context, '恢复默认')),
            ),
          ],
        ),
      ],
    ),
  );
}
