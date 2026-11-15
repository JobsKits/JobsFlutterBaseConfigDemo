import 'package:flutter/material.dart';
import 'package:jobs_demo_foundation/jobs_demo_foundation.dart';

import '../../demo_hub/ui_parity_strings.dart';

class EnvironmentObserverDemo extends StatefulWidget {
  const EnvironmentObserverDemo({super.key});
  @override
  State<EnvironmentObserverDemo> createState() => _EnvironmentObserverState();
}

class _EnvironmentObserverState extends State<EnvironmentObserverDemo>
    with WidgetsBindingObserver {
  final events = <String>[];
  int changes = 0;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeMetrics() {
    if (mounted)
      setState(() {
        events.insert(0, 'metrics ${++changes}');
        if (events.length > 30) events.removeLast();
      });
  }

  @override
  void didChangePlatformBrightness() {
    if (mounted) setState(() => events.insert(0, 'brightness ${++changes}'));
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (mounted) setState(() => events.insert(0, state.name));
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final data = {
      'size': '${media.size.width.round()} × ${media.size.height.round()}',
      'brightness': Theme.of(context).brightness.name,
      'platformBrightness': media.platformBrightness.name,
      'textScale': media.textScaler.scale(16).toStringAsFixed(1),
      'pixelRatio': media.devicePixelRatio.toStringAsFixed(1),
      'padding': '${media.padding}',
      'viewInsets': '${media.viewInsets}',
    };
    return Scaffold(
      appBar: AppBar(title: Text(uiTr(context, '界面环境监听'))),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          for (final e in data.entries)
            ListTile(title: Text(e.key), subtitle: Text(e.value)),
          const Divider(),
          for (final event in events) Text(event),
        ],
      ),
    );
  }
}

void main() =>
    runApp(const JobsDemoApp(home: EnvironmentObserverDemo(), title: '界面环境监听'));
